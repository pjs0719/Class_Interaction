package com.project.echoproject.dto;

import java.util.UUID;

public class FcmTokenRequest {
    private UUID id;
    private String fcmToken;

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getFcmToken() {
        return fcmToken;
    }

    public void setFcmToken(String fcmToken) {
        this.fcmToken = fcmToken;
    }
}

