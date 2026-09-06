package com.grammaragent.question.repository;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.mapper.QuestionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisQuestionRepository implements QuestionRepository {

    private final QuestionMapper questionMapper;

    @Override
    public Optional<Question> findEnabledById(Long questionId) {
        return Optional.ofNullable(questionMapper.selectOne(Wrappers.<Question>lambdaQuery()
                .eq(Question::getId, questionId)
                .eq(Question::getEnabled, true)));
    }

    @Override
    public List<Question> findEnabledByLessonId(Long lessonId) {
        return questionMapper.selectList(Wrappers.<Question>lambdaQuery()
                .eq(Question::getLessonId, lessonId)
                .eq(Question::getEnabled, true)
                .orderByAsc(Question::getSortOrder, Question::getId));
    }
}
