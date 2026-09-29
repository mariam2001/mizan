package com.absolutedevs.mizan.entity;

import com.absolutedevs.mizan.enums.RebalanceAction;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "rebalance_logs")
@Getter
@Setter
@NoArgsConstructor
public class RebalanceLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Nullable: REVIEWED_NO_CHANGE entries aren't tied to a single holding
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "holding_id")
    private Holding holding;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private RebalanceAction action;

    @Column(name = "rebalance_date", nullable = false)
    private LocalDate rebalanceDate;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
