from opentelemetry import trace
import hashlib
import time
from app.models.schemas import SummarizationRequest, SummarizationResponse
from app.core.config import settings

tracer = trace.get_tracer(__name__)

class SummarizationService:
    def __init__(self):
        print(f"Initializing NLP pipeline with model: {settings.MODEL_NAME}")
        # In a real scenario, this would initialize the transformers pipeline.
        # self.pipeline = pipeline("summarization", model=settings.MODEL_NAME)

    def _generate_cache_key(self, text: str) -> str:
        return hashlib.sha256(text.encode('utf-8')).hexdigest()

    async def summarize(self, request: SummarizationRequest, redis_client=None) -> SummarizationResponse:
        with tracer.start_as_current_span("summarize_text") as span:
            start_time = time.time()
            cache_key = self._generate_cache_key(request.text)
            span.set_attribute("cache_key", cache_key)
            
            # Check cache
            if redis_client:
                with tracer.start_as_current_span("cache_lookup"):
                    cached_result = await redis_client.get(cache_key)
                    if cached_result:
                        span.set_attribute("cache_hit", True)
                        process_time = (time.time() - start_time) * 1000
                        return SummarizationResponse(
                            original_length=len(request.text),
                            summary_length=len(cached_result),
                            summary=cached_result,
                            cached=True,
                            processing_time_ms=process_time
                        )

            span.set_attribute("cache_hit", False)

            # Mocking NLP inference
            # In production: result = self.pipeline(request.text, max_length=request.max_length, min_length=request.min_length, do_sample=False)
            with tracer.start_as_current_span("nlp_inference"):
                # Simulating work
                mock_summary = f"Summarized: {request.text[:50]}..."
                
            # Save to cache
            if redis_client:
                with tracer.start_as_current_span("cache_store"):
                    await redis_client.set(cache_key, mock_summary, ex=3600) # Cache for 1 hour

            process_time = (time.time() - start_time) * 1000
            return SummarizationResponse(
                original_length=len(request.text),
                summary_length=len(mock_summary),
                summary=mock_summary,
                cached=False,
                processing_time_ms=process_time
            )

summarizer = SummarizationService()
