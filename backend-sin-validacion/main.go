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
	log.Println("⚠️  Backend SIN VALIDACIÓN de credenciales iniciado")
	log.Println("⚠️  ADVERTENCIA: Este backend NO valida credenciales de operarios")

	// Configurar rutas
	mux := http.NewServeMux()
	mux.HandleFunc("/productos", getProductos)
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

// Handler para obtener productos (SIN validación de credenciales)
func getProductos(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		respondWithError(w, http.StatusMethodNotAllowed, "Método no permitido", "Solo se permite GET")
		return
	}

	// Obtener headers (si existen) pero NO validarlos
	operarioNombre := r.Header.Get("X-Operario-Nombre")
	operarioID := r.Header.Get("X-Operario-Id")

	// Log de advertencia si no hay credenciales
	if operarioNombre == "" || operarioID == "" {
		log.Printf("⚠️  Consulta SIN credenciales desde IP: %s", r.RemoteAddr)
	} else {
		log.Printf("ℹ️  Consulta con credenciales (no validadas): Operario=%s, ID=%s", operarioNombre, operarioID)
		// Opcionalmente registrar el acceso si hay credenciales
		registrarAccesoOpcional(operarioID, operarioNombre, "CONSULTA_PRODUCTOS_SIN_VALIDACION", r.RemoteAddr)
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

	log.Printf("📦 Se consultaron %d productos (sin validación de credenciales)", len(productos))
	respondWithJSON(w, http.StatusOK, productos)
}

// Registrar acceso opcional (si hay credenciales en los headers)
func registrarAccesoOpcional(operarioID, operarioNombre, accion, ipAddress string) {
	if operarioID == "" || operarioNombre == "" {
		return
	}

	query := `
		INSERT INTO logs_acceso (operario_id, operario_nombre, accion, ip_address, timestamp, detalles)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	detalles := fmt.Sprintf("Acceso SIN validación desde %s", ipAddress)
	_, err := db.Exec(query, operarioID, operarioNombre, accion, ipAddress, time.Now(), detalles)

	if err != nil {
		log.Printf("⚠️  Error al registrar acceso en logs: %v", err)
	} else {
		log.Printf("📝 Acceso registrado en logs (sin validación) - Operario: %s (ID: %s)", operarioNombre, operarioID)
	}
}

// Health check endpoint
func healthCheck(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"status":           "healthy",
		"backend":          "sin-validacion",
		"timestamp":        time.Now(),
		"database_status":  "connected",
		"requires_auth":    false,
		"warning":          "Este backend NO valida credenciales",
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
