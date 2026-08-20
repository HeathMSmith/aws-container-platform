FROM python:3.13-alpine

WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY advisor_app/ ./advisor_app/

EXPOSE 8000

USER appuser

CMD ["python", "-m", "uvicorn", "advisor_app.main:app", "--host", "0.0.0.0", "--port", "8000"]
