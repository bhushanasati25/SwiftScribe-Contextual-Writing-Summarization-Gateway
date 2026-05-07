from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "SwiftScribe Backend"
    REDIS_URL: str = "redis://localhost:6379"
    MODEL_NAME: str = "facebook/bart-large-cnn"
    MAX_TEXT_LENGTH: int = 10000

    class Config:
        env_file = ".env"

settings = Settings()
