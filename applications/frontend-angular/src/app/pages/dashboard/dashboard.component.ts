import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent {
  metrics = [
    { label: 'Total Employees', value: 150 },
    { label: 'Active Projects', value: 12 },
    { label: 'System Uptime', value: '99.9%' },
    { label: 'API Response Time', value: '45ms' }
  ];
}
