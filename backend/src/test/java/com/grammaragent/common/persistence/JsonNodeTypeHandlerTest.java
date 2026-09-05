package com.grammaragent.common.persistence;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.json.JsonMapper;
import org.apache.ibatis.type.JdbcType;
import org.junit.jupiter.api.Test;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.lang.reflect.Proxy;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;

class JsonNodeTypeHandlerTest {

    private final JsonNodeTypeHandler handler = new JsonNodeTypeHandler();

    @Test
    void shouldBindJsonAsPostgresOtherType() throws Exception {
        AtomicReference<Object[]> invocationArguments = new AtomicReference<>();
        PreparedStatement statement = (PreparedStatement) Proxy.newProxyInstance(
            getClass().getClassLoader(),
            new Class<?>[]{PreparedStatement.class},
            (proxy, method, arguments) -> {
                if (method.getName().equals("setObject")) {
                    invocationArguments.set(arguments);
                }
                return null;
            }
        );
        JsonNode value = JsonMapper.builder().build().readTree("{\"answer\":[\"am\"]}");

        handler.setNonNullParameter(statement, 1, value, JdbcType.OTHER);

        assertThat(invocationArguments.get()).containsExactly(1, value.toString(), Types.OTHER);
    }

    @Test
    void shouldReadJsonNode() throws Exception {
        ResultSet resultSet = (ResultSet) Proxy.newProxyInstance(
            getClass().getClassLoader(),
            new Class<?>[]{ResultSet.class},
            (proxy, method, arguments) -> method.getName().equals("getString")
                ? "{\"correct\":true}"
                : null
        );

        JsonNode value = handler.getNullableResult(resultSet, "payload");

        assertThat(value.path("correct").asBoolean()).isTrue();
    }
}
