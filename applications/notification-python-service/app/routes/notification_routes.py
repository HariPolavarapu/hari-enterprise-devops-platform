from fastapi import APIRouter
from pydantic import BaseModel, EmailStr
from app.services.notification_service import EmailService

router = APIRouter()

class NotificationRequest(BaseModel):
    email: EmailStr
    subject: str
    message: str

@router.post("/notify/email")
def send_email_notification(request: NotificationRequest):
    EmailService.send_email(request.email, request.subject, request.message)
    return {"status": "accepted"}
