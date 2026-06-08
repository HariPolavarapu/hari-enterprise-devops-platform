from fastapi import FastAPI
from app.routes.notification_routes import router

app = FastAPI(
title="Notification Service",
version="1.0.0"
)

app.include_router(router)

@app.get("/health")
def health_check():
return {"status": "Notification Service Running"}
