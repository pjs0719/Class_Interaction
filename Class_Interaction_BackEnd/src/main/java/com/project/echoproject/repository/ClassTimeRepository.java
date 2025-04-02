package com.project.echoproject.repository;

import com.project.echoproject.domain.ClassTime;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ClassTimeRepository extends JpaRepository<ClassTime, UUID> {
    List<ClassTime> findByWeek(int week);
}
