package com.grammaragent.learning.service;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class MasteryCalculatorTest {

    private final MasteryCalculator calculator = new MasteryCalculator();

    @Test
    void shouldCalculateRoundedPercentageWithinSchemaPrecision() {
        assertEquals(80, calculator.calculate(4, 5));
        assertEquals(67, calculator.calculate(2, 3));
        assertEquals(0, calculator.calculate(0, 0));
    }
}
