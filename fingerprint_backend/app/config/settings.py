import os
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Database
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_NAME: str = "fingerprint_db"
    DB_USER: str = "postgres"
    DB_PASSWORD: str = "postgres"

    # JWT
    JWT_SECRET: str = "default-secret-key"
    JWT_EXPIRY_HOURS: int = 24
    JWT_REFRESH_EXPIRY_DAYS: int = 30
    JWT_ALGORITHM: str = "HS256"

    # Standalone mode settings
    STANDALONE: bool = False
    MIGRATIONS_DIR: str = ""
    BACKEND_PORT: int = 8000

    @property
    def DATABASE_URL(self) -> str:
        return (
            f"postgresql://{self.DB_USER}:{self.DB_PASSWORD}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
        )

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

    @classmethod
    def from_env(cls) -> "Settings":
        standalone = os.environ.get("STANDALONE_BACKEND", "0") == "1"
        if standalone:
            return cls(
                DB_HOST=os.environ.get("DB_HOST", "localhost"),
                DB_PORT=int(os.environ.get("DB_PORT", "5432")),
                DB_NAME=os.environ.get("DB_NAME", "fingerprint_db"),
                DB_USER=os.environ.get("DB_USER", "postgres"),
                DB_PASSWORD=os.environ.get("DB_PASSWORD", "postgres"),
                JWT_SECRET=os.environ.get("JWT_SECRET", "default-secret-key"),
                STANDALONE=True,
                MIGRATIONS_DIR=os.environ.get("MIGRATIONS_DIR", ""),
                BACKEND_PORT=int(os.environ.get("BACKEND_PORT", "8000")),
            )
        return cls()


@lru_cache()
def get_settings() -> Settings:
    return Settings.from_env()
