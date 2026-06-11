import logging
from datetime import datetime
from enum import Enum

logger = logging.getLogger(__name__)

class NotificationStatus(str, Enum):
    PENDING = "pending"
    SENT = "sent"
    FAILED = "failed"
    DELIVERED = "delivered"

class Logger:
    @staticmethod
    def log_notification(notification_id: int, status: str, message: str):
        logger.info(f"Notification {notification_id}: {status} - {message}")
    
    @staticmethod
    def log_error(notification_id: int, error: str):
        logger.error(f"Notification {notification_id}: Error - {error}")

class EmailValidator:
    @staticmethod
    def is_valid_email(email: str) -> bool:
        """Validate email format"""
        import re
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(pattern, email) is not None

class DateTimeUtil:
    @staticmethod
    def get_current_datetime() -> datetime:
        """Get current datetime"""
        return datetime.utcnow()
    
    @staticmethod
    def format_datetime(dt: datetime, format: str = "%Y-%m-%d %H:%M:%S") -> str:
        """Format datetime to string"""
        return dt.strftime(format)
