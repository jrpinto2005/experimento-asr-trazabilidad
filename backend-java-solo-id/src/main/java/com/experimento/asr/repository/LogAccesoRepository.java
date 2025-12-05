package com.experimento.asr.repository;

import com.experimento.asr.entity.LogAcceso;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LogAccesoRepository extends JpaRepository<LogAcceso, Long> {
}
