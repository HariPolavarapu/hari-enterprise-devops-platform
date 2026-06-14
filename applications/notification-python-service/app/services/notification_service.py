import logging
import smtplib
from email.message import EmailMessage
from app.config import config

logger = logging.getLogger(__name__)

class EmailService:
    """Email notification service"""
    
    @staticmethod
    def send_email(recipient: str, subject: str, message: str) -> bool:
        """Send an email through the configured SMTP relay."""
        if not config.SMTP_HOST:
            raise RuntimeError("SMTP_HOST is not configured")
        try:
            email = EmailMessage()
            email["From"] = config.SMTP_FROM
            email["To"] = recipient
            email["Subject"] = subject
            email.set_content(message)
            with smtplib.SMTP(config.SMTP_HOST, config.SMTP_PORT, timeout=10) as client:
                if config.SMTP_STARTTLS:
                    client.starttls()
                if config.SMTP_USER:
                    client.login(config.SMTP_USER, config.SMTP_PASSWORD)
                client.send_message(email)
            return True
        except Exception as e:
            logger.error(f"Failed to send email: {str(e)}")
            return False

