import time
import logging

logger = logging.getLogger("fingerprint_backend")
logger.setLevel(logging.DEBUG)

handler = logging.StreamHandler()
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter(
    "[%(asctime)s] %(levelname)s %(message)s", datefmt="%Y-%m-%d %H:%M:%S"
)
handler.setFormatter(formatter)
logger.addHandler(handler)


class Logger:
    @staticmethod
    def enter(operation: str, data: dict = None) -> None:
        msg = f"START {operation}"
        if data:
            msg += f" | {data}"
        logger.info(msg)

    @staticmethod
    def exit(operation: str, result_count: int = None) -> None:
        msg = f"END {operation}"
        if result_count is not None:
            msg += f" | {result_count} records"
        logger.info(msg)

    @staticmethod
    def error(operation: str, error: str) -> None:
        logger.error(f"ERROR {operation} | {error}")

    @staticmethod
    def data(count: int) -> None:
        logger.info(f"DATA {count} records returned")


class LogTimer:
    def __init__(self, operation: str):
        self.operation = operation
        self.start_time = None

    def __enter__(self):
        self.start_time = time.time()
        Logger.enter(self.operation)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        duration = (time.time() - self.start_time) * 1000
        if exc_type:
            Logger.error(self.operation, str(exc_val))
        else:
            logger.info(f"END {self.operation} | {duration:.1f}ms")
        return False
