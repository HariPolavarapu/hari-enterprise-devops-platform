package com.hari.employee;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest
public class EmployeeServiceApplicationTests {

    @Test
    public void contextLoads() {
        assertNotNull(this.getClass());
    }
}
