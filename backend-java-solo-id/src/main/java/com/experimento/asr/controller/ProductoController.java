package com.experimento.asr.controller;

import com.experimento.asr.entity.Operario;
import com.experimento.asr.entity.Producto;
import com.experimento.asr.service.ProductoService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/productos")
@CrossOrigin(origins = "*")
public class ProductoController {

    @Autowired
    private ProductoService productoService;

    /**
     * Endpoint para obtener productos
     * Valida SOLO el ID del operario (modificabilidad)
     */
    @GetMapping
    public ResponseEntity<?> obtenerProductos(
            @RequestHeader(value = "X-Operario-Id", required = false) String operarioIdHeader,
            HttpServletRequest request) {

        String ipAddress = request.getRemoteAddr();

        // Validar que se proporcione el ID
        if (operarioIdHeader == null || operarioIdHeader.trim().isEmpty()) {
            System.out.println("❌ Error: No se proporcionó X-Operario-Id - IP: " + ipAddress);
            
            Map<String, Object> error = new HashMap<>();
            error.put("error", "ID de operario requerido");
            error.put("message", "Se requiere X-Operario-Id en los headers");
            error.put("backend_type", "java-solo-id");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }

        Long operarioId;
        try {
            operarioId = Long.parseLong(operarioIdHeader.trim());
        } catch (NumberFormatException e) {
            System.out.println("❌ Error: ID inválido - " + operarioIdHeader + " - IP: " + ipAddress);
            
            Map<String, Object> error = new HashMap<>();
            error.put("error", "ID inválido");
            error.put("message", "El ID del operario debe ser un número válido");
            error.put("backend_type", "java-solo-id");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }

        // Validar que el operario exista en la base de datos
        Operario operario = productoService.validarOperarioPorId(operarioId);
        
        if (operario == null) {
            System.out.println("❌ Error: Operario no encontrado - ID: " + operarioId + " - IP: " + ipAddress);
            
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Operario no encontrado");
            error.put("message", "No existe un operario con el ID: " + operarioId);
            error.put("backend_type", "java-solo-id");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }

        // Registrar el acceso con el nombre obtenido de la BD
        String detalles = "Backend Java - Validación solo por ID (modificabilidad)";
        productoService.registrarAcceso(operario.getId(), operario.getNombre(), ipAddress, detalles);

        System.out.println("✅ Consulta exitosa - ID: " + operario.getId() + 
                         ", Nombre: " + operario.getNombre() + " - IP: " + ipAddress);

        // Obtener y retornar productos
        List<Producto> productos = productoService.obtenerTodosLosProductos();
        
        Map<String, Object> response = new HashMap<>();
        response.put("productos", productos);
        response.put("total", productos.size());
        response.put("operario_id", operario.getId());
        response.put("operario_nombre", operario.getNombre());
        response.put("backend_type", "java-solo-id");
        response.put("validacion", "Solo ID del operario");
        
        return ResponseEntity.ok(response);
    }

    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "healthy");
        health.put("backend", "java-solo-id");
        health.put("validacion", "Solo ID del operario");
        health.put("language", "Java Spring Boot");
        health.put("database_status", "connected");
        health.put("requires_auth", "ID only");
        
        return ResponseEntity.ok(health);
    }
}
