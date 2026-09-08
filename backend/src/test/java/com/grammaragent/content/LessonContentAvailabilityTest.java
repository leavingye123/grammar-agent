package com.grammaragent.content;

import com.grammaragent.course.service.LearningPathService;
import com.grammaragent.lesson.enums.LessonContentStatus;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class LessonContentAvailabilityTest {

    @Test
    void zeroQuestionsIsComingSoonAndPositiveCountIsReady() {
        assertEquals(LessonContentStatus.COMING_SOON, LearningPathService.contentStatus(0));
        assertEquals(LessonContentStatus.READY, LearningPathService.contentStatus(1));
        assertEquals(LessonContentStatus.READY, LearningPathService.contentStatus(6));
    }
}
