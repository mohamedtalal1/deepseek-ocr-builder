# Stage 1: Download model
FROM vllm/vllm-openai:latest AS model-downloader

# Install huggingface-hub if not already available
RUN pip install --no-cache-dir huggingface-hub

# Download the DeepSeek-OCR model and tokenizer
RUN python3 -c "from transformers import AutoModel, AutoTokenizer; \
    AutoModel.from_pretrained('deepseek-ai/DeepSeek-OCR', trust_remote_code=True); \
    AutoTokenizer.from_pretrained('deepseek-ai/DeepSeek-OCR', trust_remote_code=True)"

# Stage 2: Final runtime image
FROM vllm/vllm-openai:latest

# Copy downloaded model cache from previous stage
COPY --from=model-downloader /root/.cache /root/.cache

# Set environment variables
ENV MODEL_NAME=deepseek-ai/DeepSeek-OCR
ENV VLLM_ALLOW_LONG_MAX_MODEL_LEN=1

# Healthcheck for container orchestration
HEALTHCHECK --interval=30s --timeout=10s --start-period=5m \
  CMD curl -f http://localhost:8000/health || exit 1

# Expose the vLLM serving port
EXPOSE 8000

# Default command (can be overridden in SaladCloud)
CMD ["vllm", "serve", "deepseek-ai/DeepSeek-OCR", \
     "--logits_processors", "vllm.model_executor.models.deepseek_ocr:NGramPerReqLogitsProcessor", \
     "--no-enable-prefix-caching", \
     "--mm-processor-cache-gb", "0", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--gpu-memory-utilization", "0.9", \
     "--max-model-len", "8192"]
