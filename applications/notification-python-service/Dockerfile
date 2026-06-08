# =========================================================

# STAGE 1 — BUILDER STAGE

# =========================================================

FROM python:3.12-slim AS builder

WORKDIR /app

# Install dependencies

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# =========================================================

# STAGE 2 — RUNTIME STAGE

# =========================================================

FROM python:3.12-slim

WORKDIR /app

# Copy installed packages from builder stage

COPY --from=builder /install /usr/local

# Copy application code

COPY app ./app

# Expose FastAPI port

EXPOSE 8000

# Start application

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
