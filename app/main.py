import socket
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    """Returns a welcome message along with the host name."""
    return {
        "message": "Welcome to the FastAPI application!",
        "hostname": socket.gethostname(),
    }


@app.get("/health")
def health_check():
    """Returns the operational status of the application."""
    return {"status": "healthy", "hostname": socket.gethostname()}