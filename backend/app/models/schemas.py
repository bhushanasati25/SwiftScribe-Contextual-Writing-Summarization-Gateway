from pydantic import BaseModel, Field

class SummarizationRequest(BaseModel):
    text: str = Field(..., description="The text to be summarized.")
    max_length: int = Field(130, description="Maximum length of the summary.")
    min_length: int = Field(30, description="Minimum length of the summary.")

class SummarizationResponse(BaseModel):
    original_length: int
    summary_length: int
    summary: str
    cached: bool = False
    processing_time_ms: float
