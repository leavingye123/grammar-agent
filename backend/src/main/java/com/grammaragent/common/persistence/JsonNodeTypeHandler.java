package com.grammaragent.common.persistence;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.json.JsonMapper;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

@MappedTypes(JsonNode.class)
@MappedJdbcTypes(value = JdbcType.OTHER, includeNullJdbcType = true)
public class JsonNodeTypeHandler extends BaseTypeHandler<JsonNode> {

    private static final JsonMapper JSON_MAPPER = JsonMapper.builder().build();

    @Override
    public void setNonNullParameter(
        PreparedStatement preparedStatement,
        int index,
        JsonNode parameter,
        JdbcType jdbcType
    ) throws SQLException {
        preparedStatement.setObject(index, parameter.toString(), Types.OTHER);
    }

    @Override
    public JsonNode getNullableResult(ResultSet resultSet, String columnName) throws SQLException {
        return parse(resultSet.getString(columnName));
    }

    @Override
    public JsonNode getNullableResult(ResultSet resultSet, int columnIndex) throws SQLException {
        return parse(resultSet.getString(columnIndex));
    }

    @Override
    public JsonNode getNullableResult(CallableStatement callableStatement, int columnIndex)
        throws SQLException {
        return parse(callableStatement.getString(columnIndex));
    }

    private JsonNode parse(String value) throws SQLException {
        if (value == null) {
            return null;
        }
        try {
            return JSON_MAPPER.readTree(value);
        } catch (JsonProcessingException exception) {
            throw new SQLException("Failed to parse PostgreSQL JSONB value", exception);
        }
    }
}

