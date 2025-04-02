package com.project.echoproject;

import com.project.echoproject.domain.ClassTime;
import com.project.echoproject.domain.Classroom;
import com.project.echoproject.domain.Enrollment;
import com.project.echoproject.service.ClassTimeService;
import com.project.echoproject.service.ClassroomService;
import com.project.echoproject.service.EnrollmentService;
import com.project.echoproject.service.FCMService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Component
public class ScheduledTask {
    private final FCMService fcmService;
    private final ClassroomService classroomService;
    private final EnrollmentService enrollmentService;
    private final ClassTimeService classTimeService;
    private final ScheduledExecutorService scheduledExecutorService;

    public ScheduledTask(FCMService fcmService, ClassroomService classroomService, EnrollmentService enrollmentService, ClassTimeService classTimeService, ScheduledExecutorService scheduledExecutorService) {
        this.fcmService = fcmService;
        this.classroomService = classroomService;
        this.enrollmentService = enrollmentService;
        this.classTimeService = classTimeService;
        this.scheduledExecutorService = scheduledExecutorService;
    }

    // 매일 아침 9시에 당일 수업을 조회
    @Scheduled(cron = "0 0 9 * * *", zone = "Asia/Seoul")
    public void classroomSchedule() {
        List<ClassTime> classTimes = null;
        DayOfWeek today = LocalDate.now(ZoneId.of("Asia/Seoul")).getDayOfWeek();
        int todayInt = convertInt(today);

        classTimes = classTimeService.findClassTime(todayInt);
        // 각 수업의 알림을 10분 전에 스케줄링
        for (ClassTime classTime : classTimes) {
            scheduleNotification(classTime);
        }
    }

    //스레드 스케쥴링
    private void scheduleNotification(ClassTime classTime) {
        LocalDateTime classStartTime = LocalDateTime.of(LocalDate.now(ZoneId.of("Asia/Seoul")), classTime.getStartTime());
        //10분 전으로 계산
        long delayInMinutes = Duration.between(LocalDateTime.now(), classStartTime.minusMinutes(10)).toMinutes();

        if (delayInMinutes > 0) {
            // 10분 전 알림을 예약
            scheduledExecutorService.schedule(() -> sendNotification(classTime), delayInMinutes, TimeUnit.MINUTES);
        }
    }

    //fcm 알림
    private void sendNotification(ClassTime classTime) {
        List<Enrollment> enrollments = enrollmentService.findByEnroll(classTime.getClassroom());
        if (enrollments != null && !enrollments.isEmpty()) {
            List<String> fcmTokens = new ArrayList<>();
            for (Enrollment enrollment : enrollments) {
                String token = enrollment.getStudent().getFcmToken();
                if (token != null) {
                    fcmTokens.add(token);
                }
            }
            // FCM 서비스로 알림 전송
            if (!fcmTokens.isEmpty()) {
                fcmService.sendClassStartNotification(fcmTokens, classTime.getClassroom().getClassName());
            }
        }
    }
    private int convertInt(DayOfWeek dayOfWeek) {
        switch (dayOfWeek) {
            case DayOfWeek.MONDAY:
                return 1;
            case DayOfWeek.TUESDAY:
                return 2;
            case DayOfWeek.WEDNESDAY:
                return 3;
            case DayOfWeek.THURSDAY:
                return 4;
            case DayOfWeek.FRIDAY:
                return 5;
            case DayOfWeek.SATURDAY:
                return 6;
            case DayOfWeek.SUNDAY:
                return 7;
            default:
                throw new IllegalArgumentException("잘못된 요일입니다.");
        }
    }
}
