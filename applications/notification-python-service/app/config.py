import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Application configuration"""
    APP_NAME = "Notification Service"
    APP_VERSION = "1.0.0"
    DEBUG = os.getenv("DEBUG", True)
    
    # API Configuration
    API_PORT = int(os.getenv("API_PORT", 8080))
    API_HOST = os.getenv("API_HOST", "0.0.0.0")
    
    # Email Configuration
    SMTP_HOST = os.getenv("SMTP_HOST", "smtp.gmail.com")
    SMTP_PORT = int(os.getenv("SMTP_PORT", 587))
    SMTP_USER = os.getenv("SMTP_USER", "your-email@gmail.com")
    SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "your-password")
    
    # Database Configuration
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./notifications.db")
    
    # Logging
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

config = Config()
