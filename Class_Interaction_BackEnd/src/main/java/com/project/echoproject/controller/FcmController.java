package com.project.echoproject.controller;

import com.project.echoproject.domain.User;
import com.project.echoproject.dto.FcmTokenRequest;
import com.project.echoproject.service.FCMService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class FcmController {
    private final FCMService fcmService;
    public FcmController(FCMService fcmService) {
        this.fcmService = fcmService;
    }
    @PostMapping("/fcm")
    public void FcmRegister(@RequestBody FcmTokenRequest fcmTokenRequest){
        System.out.println(fcmTokenRequest.getId());
        System.out.println(fcmTokenRequest.getFcmToken());
        fcmService.updateUser(fcmTokenRequest);
    }
}
