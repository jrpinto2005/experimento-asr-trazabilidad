package com.experimento.asr;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackendJavaSoloIdApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackendJavaSoloIdApplication.class, args);
        System.out.println("🚀 Backend Java SOLO ID iniciado");
        System.out.println("🔑 Validación: SOLO ID del operario (modificabilidad)");
    }
}
