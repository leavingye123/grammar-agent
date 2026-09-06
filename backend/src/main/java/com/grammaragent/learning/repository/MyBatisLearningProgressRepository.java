package com.grammaragent.learning.repository;

import com.grammaragent.learning.entity.UserLearningProgress;
import com.grammaragent.learning.mapper.UserLearningProgressMapper;
import com.grammaragent.learning.service.MasteryCalculator;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;

@Repository
@RequiredArgsConstructor
public class MyBatisLearningProgressRepository implements LearningProgressRepository {

    private final UserLearningProgressMapper mapper;
    private final MasteryCalculator masteryCalculator;

    @Override
    public UserLearningProgress incrementAndGet(
            Long userId,
            Long grammarPointId,
            boolean correct,
            OffsetDateTime studiedAt) {
        mapper.insertIfAbsent(userId, grammarPointId, studiedAt);
        UserLearningProgress progress = mapper.selectForUpdate(userId, grammarPointId);
        int totalQuestions = progress.getTotalQuestions() + 1;
        int correctQuestions = progress.getCorrectQuestions() + (correct ? 1 : 0);
        progress.setTotalQuestions(totalQuestions);
        progress.setCorrectQuestions(correctQuestions);
        progress.setMasteryScore(masteryCalculator.calculate(correctQuestions, totalQuestions));
        progress.setLastStudyAt(studiedAt);
        mapper.updateById(progress);
        return progress;
    }
}
