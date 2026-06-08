package com.hari.employee.service;

import com.hari.employee.entity.Employee;
import com.hari.employee.repository.EmployeeRepository;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class EmployeeService {

```
private final EmployeeRepository employeeRepository;

public EmployeeService(EmployeeRepository employeeRepository) {
    this.employeeRepository = employeeRepository;
}

// CREATE EMPLOYEE
public Employee createEmployee(Employee employee) {
    return employeeRepository.save(employee);
}

// GET ALL EMPLOYEES
public List<Employee> getAllEmployees() {
    return employeeRepository.findAll();
}

// GET EMPLOYEE BY ID
public Optional<Employee> getEmployeeById(Long id) {
    return employeeRepository.findById(id);
}

// DELETE EMPLOYEE
public void deleteEmployee(Long id) {
    employeeRepository.deleteById(id);
}
```

}
