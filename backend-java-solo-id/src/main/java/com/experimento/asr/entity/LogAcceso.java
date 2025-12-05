package com.experimento.asr.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "logs_acceso")
public class LogAcceso {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "operario_id")
    private Long operarioId;

    @Column(name = "operario_nombre", nullable = false, length = 100)
    private String operarioNombre;

    @Column(nullable = false, length = 50)
    private String accion;

    @Column(nullable = false)
    private LocalDateTime timestamp;

    @Column(name = "ip_address", length = 50)
    private String ipAddress;

    @Column(columnDefinition = "TEXT")
    private String detalles;

    // Constructors
    public LogAcceso() {
        this.timestamp = LocalDateTime.now();
    }

    public LogAcceso(Long operarioId, String operarioNombre, String accion, String ipAddress, String detalles) {
        this.operarioId = operarioId;
        this.operarioNombre = operarioNombre;
        this.accion = accion;
        this.timestamp = LocalDateTime.now();
        this.ipAddress = ipAddress;
        this.detalles = detalles;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getOperarioId() {
        return operarioId;
    }

    public void setOperarioId(Long operarioId) {
        this.operarioId = operarioId;
    }

    public String getOperarioNombre() {
        return operarioNombre;
    }

    public void setOperarioNombre(String operarioNombre) {
        this.operarioNombre = operarioNombre;
    }

    public String getAccion() {
        return accion;
    }

    public void setAccion(String accion) {
        this.accion = accion;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getDetalles() {
        return detalles;
    }

    public void setDetalles(String detalles) {
        this.detalles = detalles;
    }
}
