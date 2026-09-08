package com.grammaragent.content;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Component
@Profile("local")
@Order(Ordered.HIGHEST_PRECEDENCE)
@ConditionalOnProperty(prefix = "app.content", name = "import-enabled", havingValue = "true", matchIfMissing = true)
@RequiredArgsConstructor
public class EnglishA1ContentImportRunner implements ApplicationRunner {

    private final EnglishA1ContentImportService importService;

    @Override
    public void run(ApplicationArguments args) {
        importService.importEnglishA1();
    }
}
