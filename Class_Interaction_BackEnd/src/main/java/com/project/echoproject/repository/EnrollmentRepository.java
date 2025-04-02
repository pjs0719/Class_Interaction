package com.project.echoproject.repository;

import com.project.echoproject.domain.Classroom;
import com.project.echoproject.domain.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface EnrollmentRepository extends JpaRepository<Enrollment, UUID> {
    List<Enrollment> findByStudentEmail(String email);
    boolean existsByClassroomClassId(UUID classId);
    Optional<Enrollment> findByClassroomClassId(UUID classId);
    List<Enrollment> findByClassroom(Classroom classroom);
}
