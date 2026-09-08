package com.grammaragent.content;

import com.grammaragent.content.model.CurriculumContent;

public interface CurriculumContentWriter {

    ImportResult upsert(CurriculumContent content);

    record ImportResult(
            Long languageId,
            Long levelId,
            int chapters,
            int grammarPoints,
            int lessons,
            int questions,
            int prerequisites
    ) {
    }
}
