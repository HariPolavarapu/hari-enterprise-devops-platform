from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class NotificationRequest(BaseModel):
email: str
message: str

@router.post("/notify/email")
def send_email_notification(request: NotificationRequest):

```
return {
    "status": "success",
    "message": f"Notification sent to {request.email}"
}
```
