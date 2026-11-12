FROM python:3.13.12-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install -r requirements.txt

RUN useradd -m appuser
USER appuser

COPY . .

HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]