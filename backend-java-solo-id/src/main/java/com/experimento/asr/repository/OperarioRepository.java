package com.experimento.asr.repository;

import com.experimento.asr.entity.Operario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OperarioRepository extends JpaRepository<Operario, Long> {
    Optional<Operario> findById(Long id);
}
