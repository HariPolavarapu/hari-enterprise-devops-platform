using PayrollService.Models;

namespace PayrollService.Controllers
{
    using Microsoft.AspNetCore.Mvc;

    [ApiController]
    [Route("api/[controller]")]
    public class PayrollController : ControllerBase
    {
        private readonly ILogger<PayrollController> _logger;

        public PayrollController(ILogger<PayrollController> logger)
        {
            _logger = logger;
        }

        [HttpGet("{id}")]
        public ActionResult<ApiResponse<Payroll>> GetPayroll(int id)
        {
            _logger.LogInformation($"Getting payroll with ID: {id}");
            
            var payroll = new Payroll
            {
                Id = id,
                Status = PaymentStatus.Paid
            };

            return Ok(new ApiResponse<Payroll>(true, "Payroll retrieved successfully", payroll));
        }

        [HttpPost("calculate")]
        public async Task<ActionResult<ApiResponse<Payroll>>> CalculatePayroll([FromBody] int employeeId)
        {
            _logger.LogInformation($"Calculating payroll for employee: {employeeId}");
            
            // TODO: Call PayrollService
            var payroll = new Payroll
            {
                EmployeeId = employeeId,
                Status = PaymentStatus.Pending
            };

            return Ok(new ApiResponse<Payroll>(true, "Payroll calculated successfully", payroll));
        }

        [HttpPost("process")]
        public async Task<ActionResult<ApiResponse<Payroll>>> ProcessPayroll([FromBody] int payrollId)
        {
            _logger.LogInformation($"Processing payroll: {payrollId}");
            
            // TODO: Call PayrollService
            var payroll = new Payroll
            {
                Id = payrollId,
                Status = PaymentStatus.Processed
            };

            return Ok(new ApiResponse<Payroll>(true, "Payroll processed successfully", payroll));
        }
    }
}
