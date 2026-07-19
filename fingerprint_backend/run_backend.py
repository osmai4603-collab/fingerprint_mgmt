import os
import sys
import uvicorn
from app.config.settings import get_settings
from app.main import app  # 1. استيراد كائن التطبيق مباشرة


def main():
    settings = get_settings()
    host = os.environ.get("BACKEND_HOST", "127.0.0.1")
    port = settings.BACKEND_PORT

    if sys.stdout is None:
        sys.stdout = open(os.devnull, "w")
    if sys.stderr is None:
        sys.stderr = open(os.devnull, "w")

    uvicorn.run(
        app,
        host=host,
        port=port,
        log_level="info",
        reload=False,
    )


if __name__ == "__main__":
    main()
