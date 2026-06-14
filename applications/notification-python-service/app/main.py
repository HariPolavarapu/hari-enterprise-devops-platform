from fastapi import FastAPI
from app.routes.notification_routes import router
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(
    title="Notification Service",
    version="1.0.0"
)

app.include_router(router)
Instrumentator().instrument(app).expose(app)

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "notification-service"}
