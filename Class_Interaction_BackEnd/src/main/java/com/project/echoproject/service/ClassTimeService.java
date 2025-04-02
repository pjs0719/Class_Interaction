package com.project.echoproject.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.project.echoproject.domain.ClassTime;
import com.project.echoproject.domain.Classroom;
import com.project.echoproject.domain.Instructor;
import com.project.echoproject.domain.Opinion;
import com.project.echoproject.dto.classroom.ClassroomDTO;
import com.project.echoproject.repository.ClassTimeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ClassTimeService {
    private final ClassTimeRepository classTimeRepository;

    public ClassTimeService(ClassTimeRepository classTimeRepository) {
        this.classTimeRepository = classTimeRepository;
    }

    @Transactional(readOnly = true)
    public List<ClassTime> findClassTime(int today){
        return classTimeRepository.findByWeek(today);
    }

    @Transactional
    public List<ClassTime> createClassTime(Classroom classroom,ClassroomDTO classroomDTO) {
        UUID classId = classroom.getClassId();

        List<String> classTimes = Optional.ofNullable(classroomDTO.getStartTime()).orElse(new ArrayList<>());
        List<ClassTime> classTimesList = new ArrayList<>();

        for (String timeEntry : classTimes) {

            // timeEntry는 "2,01:05" 형태라고 가정
            ClassTime classTime = new ClassTime();
            String[] splitTime = timeEntry.split(","); // 쉼표로 분리

            int week = Integer.parseInt(splitTime[0].trim()); // 첫 번째 값: 주
            LocalTime startTime = LocalTime.parse(splitTime[1].trim()); // 두 번째 값: 시간(LocalTime 형식)

            // 변환된 값을 classTime 객체에 설정
            classTime.setWeek(week); // 가정: ClassTime 엔티티에 week 필드가 있음
            classTime.setStartTime(startTime); // 가정: ClassTime 엔티티에 startTime 필드가 있음
            classTime.setClassroom(classroom);
            classTimesList.add(classTimeRepository.save(classTime));
        }

        return classTimesList;
    }
}
