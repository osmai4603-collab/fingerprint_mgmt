import os
import sys
import uvicorn
from app.config.settings import get_settings


def main():
    settings = get_settings()
    host = os.environ.get("BACKEND_HOST", "127.0.0.1")
    port = settings.BACKEND_PORT

    uvicorn.run(
        "app.main:app",
        host=host,
        port=port,
        log_level="info",
        reload=False,
    )


if __name__ == "__main__":
    main()
