package com.grammaragent.common.persistence;

import com.grammaragent.course.entity.Language;
import org.apache.ibatis.reflection.SystemMetaObject;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;

import static org.assertj.core.api.Assertions.assertThat;

class AuditMetaObjectHandlerTest {

    private final AuditMetaObjectHandler handler = new AuditMetaObjectHandler();

    @Test
    void shouldFillCreatedAtAndUpdatedAtOnInsert() {
        Language language = new Language();

        handler.insertFill(SystemMetaObject.forObject(language));

        assertThat(language.getCreatedAt()).isNotNull();
        assertThat(language.getUpdatedAt()).isNotNull();
        assertThat(language.getCreatedAt().getOffset()).isEqualTo(ZoneOffset.UTC);
        assertThat(language.getUpdatedAt().getOffset()).isEqualTo(ZoneOffset.UTC);
    }

    @Test
    void shouldRefreshUpdatedAtOnUpdate() {
        Language language = new Language();
        OffsetDateTime oldUpdatedAt = OffsetDateTime.now(ZoneOffset.UTC).minusDays(1);
        language.setUpdatedAt(oldUpdatedAt);

        handler.updateFill(SystemMetaObject.forObject(language));

        assertThat(language.getUpdatedAt()).isAfter(oldUpdatedAt);
    }
}
