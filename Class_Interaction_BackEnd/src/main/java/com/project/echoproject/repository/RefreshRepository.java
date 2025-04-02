package com.project.echoproject.repository;

import com.project.echoproject.domain.Refresh;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

public interface RefreshRepository extends JpaRepository<Refresh, UUID> {
    @Transactional(readOnly = true)
    boolean existsByRefresh(String refresh);

    //CacheEvict
    @Transactional
    void deleteByRefresh(String refresh);
}
