FROM vllm/vllm-openai:latest

# Set working directory
WORKDIR /app

# Environment variables with defaults
ENV MODEL_NAME="deepseek-ai/deepseek-vl2-small"
ENV HOST="0.0.0.0"
ENV PORT="8000"
ENV MAX_MODEL_LEN="4096"
ENV GPU_MEMORY_UTILIZATION="0.9"
ENV TRUST_REMOTE_CODE="true"

# Create a startup script for better configuration
RUN echo '#!/bin/bash\n\
python -m vllm.entrypoints.openai.api_server \
  --model ${MODEL_NAME} \
  --host ${HOST} \
  --port ${PORT} \
  --max-model-len ${MAX_MODEL_LEN} \
  --gpu-memory-utilization ${GPU_MEMORY_UTILIZATION} \
  --trust-remote-code \
  ${VLLM_EXTRA_ARGS}' > /app/start.sh && chmod +x /app/start.sh

# Expose the API port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run the server
CMD ["/app/start.sh"]
