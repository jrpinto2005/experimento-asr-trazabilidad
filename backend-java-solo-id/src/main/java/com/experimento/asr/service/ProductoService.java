package com.experimento.asr.service;

import com.experimento.asr.entity.LogAcceso;
import com.experimento.asr.entity.Operario;
import com.experimento.asr.entity.Producto;
import com.experimento.asr.repository.LogAccesoRepository;
import com.experimento.asr.repository.OperarioRepository;
import com.experimento.asr.repository.ProductoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductoService {

    @Autowired
    private ProductoRepository productoRepository;

    @Autowired
    private OperarioRepository operarioRepository;

    @Autowired
    private LogAccesoRepository logAccesoRepository;

    /**
     * Valida que el operario exista solo por ID
     * @param operarioId ID del operario
     * @return Operario si existe, null si no
     */
    public Operario validarOperarioPorId(Long operarioId) {
        Optional<Operario> operario = operarioRepository.findById(operarioId);
        return operario.orElse(null);
    }

    /**
     * Registra el acceso en la tabla de logs
     */
    public void registrarAcceso(Long operarioId, String operarioNombre, String ipAddress, String detalles) {
        LogAcceso log = new LogAcceso(
            operarioId,
            operarioNombre,
            "CONSULTA_PRODUCTOS",
            ipAddress,
            detalles
        );
        logAccesoRepository.save(log);
        
        System.out.println("✅ Acceso registrado - ID: " + operarioId + ", Nombre: " + operarioNombre + ", IP: " + ipAddress);
    }

    /**
     * Obtiene todos los productos
     */
    public List<Producto> obtenerTodosLosProductos() {
        return productoRepository.findAll();
    }
}
