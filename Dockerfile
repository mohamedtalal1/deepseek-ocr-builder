FROM vllm/vllm-openai:latest

# Set environment variables
ENV MODEL_NAME=deepseek-ai/DeepSeek-OCR
ENV VLLM_ALLOW_LONG_MAX_MODEL_LEN=1

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=10m --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

# vLLM images already have the environment set up. 
# We use 'vllm serve' which is the standard entrypoint for newer versions.
ENTRYPOINT ["vllm", "serve"]

# Pass the model and specific OCR parameters as arguments
CMD ["deepseek-ai/DeepSeek-OCR", \
     "--logits-processors", "vllm.model_executor.models.deepseek_ocr:NGramPerReqLogitsProcessor", \
     "--disable-log-requests", \
     "--enable-prefix-caching=False", \
     "--mm-processor-cache-gb", "0", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--gpu-memory-utilization", "0.9", \
     "--max-model-len", "8192", \
     "--trust-remote-code"]
