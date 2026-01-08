FROM python:3.10-slim

WORKDIR /app

# System deps (minimal)
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Prevent pip cache from filling disk
ENV PIP_NO_CACHE_DIR=1

RUN pip install --upgrade pip

# Install vLLM (this pulls torch as needed)
RUN pip install vllm

# DeepSeek-OCR runtime deps
RUN pip install addict matplotlib pillow

ENV HF_HOME=/models
ENV TRANSFORMERS_CACHE=/models

EXPOSE 8000

CMD ["vllm", "serve", "deepseek-ai/DeepSeek-OCR", \
     "--logits_processors", "vllm.model_executor.models.deepseek_ocr:NGramPerReqLogitsProcessor", \
     "--no-enable-prefix-caching", \
     "--mm-processor-cache-gb", "0"]
