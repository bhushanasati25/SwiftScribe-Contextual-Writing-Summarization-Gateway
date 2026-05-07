from fastapi import APIRouter, Depends, HTTPException, Request
from app.models.schemas import SummarizationRequest, SummarizationResponse
from app.services.summarizer import summarizer
from app.api.deps import get_redis
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/summarize", response_model=SummarizationResponse)
async def summarize_text(
    request: Request,
    summarization_request: SummarizationRequest,
    redis_client = Depends(get_redis)
):
    # Rate limit is applied in main.py via app.state.limiter if needed, 
    # but we can also apply it here explicitly if we want per-endpoint control.
    # For now, we'll assume global or main.py level configuration.
    
    try:
        if len(summarization_request.text) == 0:
            raise HTTPException(status_code=400, detail="Text cannot be empty.")
            
        response = await summarizer.summarize(summarization_request, redis_client)
        return response
    except Exception as e:
        logger.error(f"Summarization error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during summarization.")
