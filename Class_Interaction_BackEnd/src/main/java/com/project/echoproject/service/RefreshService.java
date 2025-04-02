package com.project.echoproject.service;

import com.project.echoproject.domain.Refresh;
import com.project.echoproject.repository.RefreshRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

    @Service
    public class RefreshService {
        private final RefreshRepository refreshRepository;

        @Autowired
        public RefreshService(RefreshRepository refreshRepository) {
            this.refreshRepository = refreshRepository;
        }

        public void addRefresh(String email, String refresh, Long expiredMs) {
            Date date = new Date(System.currentTimeMillis() + expiredMs);

            Refresh refreshEntity = new Refresh();
            refreshEntity.setEmail(email);
            refreshEntity.setRefresh(refresh);
            refreshEntity.setExpiration(date.toString());

            refreshRepository.save(refreshEntity);
        }

    public void deleteRefresh(String refresh){
        refreshRepository.deleteByRefresh(refresh);
    }

    public boolean existRefresh(String refresh){
        return refreshRepository.existsByRefresh(refresh);
    }

}
