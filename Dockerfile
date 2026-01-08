FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y \
    python3 python3-pip git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

# Install vLLM with DeepSeek-OCR support
RUN pip install --upgrade vllm --torch-backend auto

# DeepSeek-OCR runtime deps
RUN pip install addict matplotlib pillow

# Cache locations (important for Salad)
ENV HF_HOME=/models
ENV TRANSFORMERS_CACHE=/models

EXPOSE 8000

CMD ["vllm", "serve", "deepseek-ai/DeepSeek-OCR", \
     "--logits_processors", "vllm.model_executor.models.deepseek_ocr:NGramPerReqLogitsProcessor", \
     "--no-enable-prefix-caching", \
     "--mm-processor-cache-gb", "0"]
