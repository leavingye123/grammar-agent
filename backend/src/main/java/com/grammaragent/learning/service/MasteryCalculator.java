package com.grammaragent.learning.service;

import org.springframework.stereotype.Component;

@Component
public class MasteryCalculator {

    public int calculate(int correctQuestions, int totalQuestions) {
        if (totalQuestions <= 0) {
            return 0;
        }
        return Math.toIntExact(Math.round(correctQuestions * 100.0 / totalQuestions));
    }
}
