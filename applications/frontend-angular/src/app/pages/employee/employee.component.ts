import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-employee',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './employee.component.html',
  styleUrls: ['./employee.component.css']
})
export class EmployeeComponent implements OnInit {
  employees: any[] = [];
  newEmployee = {
    name: '',
    email: '',
    department: '',
    salary: 0
  };

  ngOnInit() {
    this.loadEmployees();
  }

  loadEmployees() {
    // Mock data - in production, this would call an API
    this.employees = [
      { id: 1, name: 'Alpha Testuser', email: 'alpha.testuser@example.invalid', department: 'Engineering', salary: 75000 },
      { id: 2, name: 'Beta Testuser', email: 'beta.testuser@example.invalid', department: 'HR', salary: 65000 },
      { id: 3, name: 'Gamma Testuser', email: 'gamma.testuser@example.invalid', department: 'Finance', salary: 70000 }
    ];
  }

  addEmployee() {
    if (this.newEmployee.name && this.newEmployee.email) {
      const employee = {
        id: this.employees.length + 1,
        ...this.newEmployee
      };
      this.employees.push(employee);
      this.newEmployee = {
        name: '',
        email: '',
        department: '',
        salary: 0
      };
    }
  }

  deleteEmployee(id: number) {
    this.employees = this.employees.filter(e => e.id !== id);
  }
}
