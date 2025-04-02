package com.project.echoproject.domain;

import jakarta.persistence.*;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalTime;
import java.util.UUID;

@Entity
public class ClassTime {
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    @Column(updatable = false, nullable = false)
    private UUID classTimeId;

    @ManyToOne
    @JoinColumn(nullable = false)
    private Classroom classroom;
    @Column
    private int week;
    @Column
    private LocalTime startTime;


    public Classroom getClassroom() {
        return classroom;
    }

    public void setClassroom(Classroom classroom) {
        this.classroom = classroom;
    }

    public int getWeek() {
        return week;
    }

    public void setWeek(int week) {
        this.week = week;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }
}
