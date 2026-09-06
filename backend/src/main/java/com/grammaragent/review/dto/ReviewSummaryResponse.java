package com.grammaragent.review.dto;

import java.time.OffsetDateTime;

public record ReviewSummaryResponse(
        long dueCount,
        long unmasteredCount,
        long masteredCount,
        OffsetDateTime nextReviewAt
) {
}
