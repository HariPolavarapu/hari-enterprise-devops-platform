import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Application configuration"""
    APP_NAME = "Notification Service"
    APP_VERSION = "1.0.0"
    DEBUG = os.getenv("DEBUG", "false").lower() == "true"
    
    # API Configuration
    API_PORT = int(os.getenv("API_PORT", 8080))
    API_HOST = os.getenv("API_HOST", "0.0.0.0")
    
    # Email Configuration
    SMTP_HOST = os.getenv("SMTP_HOST", "")
    SMTP_PORT = int(os.getenv("SMTP_PORT", 587))
    SMTP_USER = os.getenv("SMTP_USER", "")
    SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
    SMTP_FROM = os.getenv("SMTP_FROM", "no-reply@platform.invalid")
    SMTP_STARTTLS = os.getenv("SMTP_STARTTLS", "true").lower() == "true"
    
    # Database Configuration
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./notifications.db")
    
    # Logging
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

config = Config()
