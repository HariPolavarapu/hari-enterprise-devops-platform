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
RUN groupadd --system app && useradd --system --gid app app

# Copy installed packages from builder stage

COPY --from=builder /install /usr/local

# Copy application code

COPY app ./app
USER app

# Expose FastAPI port

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

# Start application

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
