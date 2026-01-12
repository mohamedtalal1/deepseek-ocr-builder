FROM vllm/vllm-openai:latest

# Don't pre-download the model - let it download on first run
# This makes the build MUCH faster and uses less disk space

ENV MODEL_NAME=deepseek-ai/DeepSeek-OCR
ENV VLLM_ALLOW_LONG_MAX_MODEL_LEN=1

# Healthcheck - allow 10 minutes for model download on first startup
HEALTHCHECK --interval=30s --timeout=10s --start-period=10m --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

CMD ["vllm", "serve", "deepseek-ai/DeepSeek-OCR", \
     "--logits_processors", "vllm.model_executor.models.deepseek_ocr:NGramPerReqLogitsProcessor", \
     "--no-enable-prefix-caching", \
     "--mm-processor-cache-gb", "0", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--gpu-memory-utilization", "0.9", \
     "--max-model-len", "8192"]
