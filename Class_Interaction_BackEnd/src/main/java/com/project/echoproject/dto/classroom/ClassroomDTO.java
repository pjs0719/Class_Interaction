package com.project.echoproject.dto.classroom;

import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public class ClassroomDTO {
    private String ClassName;
    private List<String> ops;
    private List<String> StartTime;

    public String getClassName() {
        return ClassName;
    }

    public void setClassName(String className) {
        ClassName = className;
    }

    public List<String> getOps() {
        return ops;
    }

    public void setOps(List<String> ops) {
        this.ops = ops;
    }

    public List<String> getStartTime() { return StartTime; }

    public void setStartTime(List<String> startTime) { StartTime = startTime; }
}
