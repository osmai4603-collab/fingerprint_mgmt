import time
import logging
from fastapi import Request

logger = logging.getLogger("fingerprint_backend")


async def request_diagnostics(request: Request, call_next):
    start = time.time()
    method = request.method
    path = request.url.path
    logger.info(f"START {method} {path}")

    try:
        response = await call_next(request)
        duration = (time.time() - start) * 1000
        logger.info(f"END {method} {path} | {response.status_code} | {duration:.1f}ms")
        return response
    except Exception as e:
        duration = (time.time() - start) * 1000
        logger.error(f"ERROR {method} {path} | {e} | {duration:.1f}ms")
        raise
