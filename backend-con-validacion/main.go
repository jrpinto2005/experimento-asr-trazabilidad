package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/lib/pq"
	"github.com/rs/cors"
)

type Producto struct {
	ID              int     `json:"id"`
	Nombre          string  `json:"nombre"`
	StockDisponible int     `json:"stock_disponible"`
	Precio          float64 `json:"precio"`
}

type Operario struct {
	ID     int    `json:"id"`
	Nombre string `json:"nombre"`
}

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message"`
}

var db *sql.DB

func main() {
	// Configuración de la base de datos
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	port := os.Getenv("PORT")

	if port == "" {
		port = "8080"
	}

	// Conectar a la base de datos
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName)

	var err error
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Error al conectar a la base de datos:", err)
	}
	defer db.Close()

	// Verificar conexión
	err = db.Ping()
	if err != nil {
		log.Fatal("Error al hacer ping a la base de datos:", err)
	}

	log.Println("✅ Conexión exitosa a la base de datos PostgreSQL")
	log.Println("🔒 Backend CON VALIDACIÓN de credenciales iniciado")

	// Configurar rutas
	mux := http.NewServeMux()
	mux.HandleFunc("/productos", validarCredenciales(getProductos))
	mux.HandleFunc("/health", healthCheck)

	// Configurar CORS
	handler := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"*"},
		AllowCredentials: true,
	}).Handler(mux)

	// Iniciar servidor
	log.Printf("🚀 Servidor escuchando en el puerto %s\n", port)
	log.Fatal(http.ListenAndServe(":"+port, handler))
}

// Middleware para validar credenciales del operario
func validarCredenciales(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		operarioNombre := r.Header.Get("X-Operario-Nombre")
		operarioID := r.Header.Get("X-Operario-Id")

		// Validar que los headers estén presentes
		if operarioNombre == "" || operarioID == "" {
			log.Printf("❌ Acceso denegado - Credenciales faltantes")
			respondWithError(w, http.StatusUnauthorized, "Credenciales requeridas", "Se requiere X-Operario-Nombre y X-Operario-Id en los headers")
			return
		}

		// Validar que el operario existe en la base de datos
		var existe bool
		query := "SELECT EXISTS(SELECT 1 FROM operarios WHERE id = $1 AND nombre = $2)"
		err := db.QueryRow(query, operarioID, operarioNombre).Scan(&existe)

		if err != nil {
			log.Printf("❌ Error al validar operario: %v", err)
			respondWithError(w, http.StatusInternalServerError, "Error interno", "Error al validar credenciales")
			return
		}

		if !existe {
			log.Printf("❌ Acceso denegado - Operario no válido: ID=%s, Nombre=%s", operarioID, operarioNombre)
			respondWithError(w, http.StatusUnauthorized, "Credenciales inválidas", "El operario no existe o las credenciales no coinciden")
			return
		}

		// Registrar el acceso en logs
		registrarAcceso(operarioID, operarioNombre, "CONSULTA_PRODUCTOS", r.RemoteAddr)

		log.Printf("✅ Acceso autorizado - Operario: %s (ID: %s)", operarioNombre, operarioID)

		// Continuar con la petición
		next(w, r)
	}
}

// Registrar acceso en la tabla de logs
func registrarAcceso(operarioID, operarioNombre, accion, ipAddress string) {
	query := `
		INSERT INTO logs_acceso (operario_id, operario_nombre, accion, ip_address, timestamp, detalles)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	detalles := fmt.Sprintf("Acceso desde %s", ipAddress)
	_, err := db.Exec(query, operarioID, operarioNombre, accion, ipAddress, time.Now(), detalles)

	if err != nil {
		log.Printf("⚠️  Error al registrar acceso en logs: %v", err)
	} else {
		log.Printf("📝 Acceso registrado en logs - Operario: %s (ID: %s)", operarioNombre, operarioID)
	}
}

// Handler para obtener productos
func getProductos(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		respondWithError(w, http.StatusMethodNotAllowed, "Método no permitido", "Solo se permite GET")
		return
	}

	query := "SELECT id, nombre, stock_disponible, precio FROM productos ORDER BY nombre"
	rows, err := db.Query(query)
	if err != nil {
		log.Printf("❌ Error al consultar productos: %v", err)
		respondWithError(w, http.StatusInternalServerError, "Error interno", "Error al consultar productos")
		return
	}
	defer rows.Close()

	var productos []Producto
	for rows.Next() {
		var p Producto
		err := rows.Scan(&p.ID, &p.Nombre, &p.StockDisponible, &p.Precio)
		if err != nil {
			log.Printf("❌ Error al escanear producto: %v", err)
			continue
		}
		productos = append(productos, p)
	}

	log.Printf("📦 Se consultaron %d productos", len(productos))
	respondWithJSON(w, http.StatusOK, productos)
}

// Health check endpoint
func healthCheck(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"status":           "healthy",
		"backend":          "con-validacion",
		"timestamp":        time.Now(),
		"database_status":  "connected",
		"requires_auth":    true,
	}
	respondWithJSON(w, http.StatusOK, response)
}

// Responder con JSON
func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	response, err := json.Marshal(payload)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`{"error": "Error al generar respuesta JSON"}`))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write(response)
}

// Responder con error
func respondWithError(w http.ResponseWriter, code int, error, message string) {
	respondWithJSON(w, code, ErrorResponse{
		Error:   error,
		Message: message,
	})
}
