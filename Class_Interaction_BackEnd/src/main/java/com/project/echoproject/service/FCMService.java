package com.project.echoproject.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.project.echoproject.domain.User;
import com.project.echoproject.dto.FcmTokenRequest;
import com.project.echoproject.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class FCMService {
    private final UserRepository userRepository;

    public FCMService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public void sendClassStartNotification(List<String> tokens, String className) {
        for (String token : tokens) {
            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder()
                            .setTitle("수업 시작 알림")
                            .setBody(className + "수업이 10분전 입니다")
                            .build())
                    .build();

            try {
                FirebaseMessaging.getInstance().send(message);
                System.out.println("Successfully sent message to: " + token);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Transactional
    public void updateUser(FcmTokenRequest fcmTokenRequest) {
        User u  = userRepository.findById(fcmTokenRequest.getId()).orElseThrow(() -> new EntityNotFoundException("user정보 존재 X 시스템 오류"));
        u.setFcmToken(fcmTokenRequest.getFcmToken());
    }
}
