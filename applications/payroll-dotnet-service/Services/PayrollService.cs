using PayrollService.Models;

namespace PayrollService.Services
{
    public interface IPayrollService
    {
        Task<Payroll> CalculatePayrollAsync(int employeeId);
        Task<Payroll> ProcessPayrollAsync(int payrollId);
        Task<List<Payroll>> GetPayrollHistoryAsync(int employeeId);
    }

    public class PayrollService : IPayrollService
    {
        private static readonly List<Payroll> _payrolls = new();
        private static int _idSequence = 1;

        public async Task<Payroll> CalculatePayrollAsync(int employeeId)
        {
            // Simple payroll calculation for demonstration purposes.
            // In production this would query an employee store and apply
            // configurable tax rules, benefits, and deductions.
            var baseSalary = 50000m;
            var bonus = baseSalary * 0.10m;
            var deductions = baseSalary * 0.20m;
            var netSalary = baseSalary + bonus - deductions;

            var payroll = new Payroll
            {
                Id = _idSequence++,
                EmployeeId = employeeId,
                PayPeriodStart = DateTime.UtcNow.AddDays(-14),
                PayPeriodEnd = DateTime.UtcNow,
                BaseSalary = baseSalary,
                Bonus = bonus,
                Deductions = deductions,
                NetSalary = netSalary,
                Status = PaymentStatus.Pending,
                CreatedDate = DateTime.UtcNow
            };

            _payrolls.Add(payroll);
            return await Task.FromResult(payroll);
        }

        public async Task<Payroll> ProcessPayrollAsync(int payrollId)
        {
            var payroll = _payrolls.FirstOrDefault(p => p.Id == payrollId);
            if (payroll == null)
            {
                throw new KeyNotFoundException($"Payroll {payrollId} not found.");
            }

            payroll.Status = PaymentStatus.Processed;
            payroll.ProcessedDate = DateTime.UtcNow;
            return await Task.FromResult(payroll);
        }

        public async Task<List<Payroll>> GetPayrollHistoryAsync(int employeeId)
        {
            var history = _payrolls
                .Where(p => p.EmployeeId == employeeId)
                .OrderByDescending(p => p.CreatedDate)
                .ToList();
            return await Task.FromResult(history);
        }
    }
}
