package com.hari.employee.repository;

import com.hari.employee.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmployeeRepository
extends JpaRepository<Employee, Long> {

}
