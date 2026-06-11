from pydantic import BaseModel
from datetime import datetime
from enum import Enum

class NotificationStatus(str, Enum):
    PENDING = "pending"
    SENT = "sent"
    FAILED = "failed"
    DELIVERED = "delivered"

class Notification(BaseModel):
    id: int = None
    recipient: str
    subject: str
    message: str
    status: NotificationStatus = NotificationStatus.PENDING
    created_at: datetime = None
    sent_at: datetime = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": 1,
                "recipient": "user@example.com",
                "subject": "Test Notification",
                "message": "This is a test notification",
                "status": "pending",
                "created_at": "2024-01-01T00:00:00",
                "sent_at": None
            }
        }

class NotificationResponse(BaseModel):
    id: int
    recipient: str
    subject: str
    message: str
    status: NotificationStatus
    created_at: datetime
    sent_at: datetime = None
