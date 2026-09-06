package com.grammaragent.question.repository;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UserAnswerCounts {

    private long total;
    private long correct;
}
