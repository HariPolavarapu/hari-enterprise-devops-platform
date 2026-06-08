package com.hari.employee.controller;

import com.hari.employee.entity.Employee;
import com.hari.employee.service.EmployeeService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/employees")
public class EmployeeController {

```
private final EmployeeService employeeService;

public EmployeeController(EmployeeService employeeService) {
    this.employeeService = employeeService;
}

// CREATE EMPLOYEE
@PostMapping
public Employee createEmployee(@RequestBody Employee employee) {
    return employeeService.createEmployee(employee);
}

// GET ALL EMPLOYEES
@GetMapping
public List<Employee> getAllEmployees() {
    return employeeService.getAllEmployees();
}

// GET EMPLOYEE BY ID
@GetMapping("/{id}")
public ResponseEntity<Employee> getEmployeeById(@PathVariable Long id) {

    Optional<Employee> employee =
            employeeService.getEmployeeById(id);

    return employee.map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
}

// DELETE EMPLOYEE
@DeleteMapping("/{id}")
public ResponseEntity<Void> deleteEmployee(@PathVariable Long id) {

    employeeService.deleteEmployee(id);

    return ResponseEntity.noContent().build();
}
```

}
