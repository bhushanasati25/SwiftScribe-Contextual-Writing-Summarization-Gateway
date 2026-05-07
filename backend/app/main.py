from fastapi import FastAPI, Request
from app.api.endpoints import router as api_router
from app.core.config import settings
from app.core.telemetry import setup_telemetry
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

# Setup Rate Limiter
limiter = Limiter(key_func=get_remote_address)

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Contextual Writing & Summarization Gateway API",
    version="1.0.0"
)

# Apply Rate Limiter
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Apply Telemetry
setup_telemetry(app)

# Include API Router
app.include_router(api_router, prefix="/api/v1")

@app.get("/health")
@limiter.limit("10/minute")
async def health_check(request: Request):
    return {"status": "ok"}
