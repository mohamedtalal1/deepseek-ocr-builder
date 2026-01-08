FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

WORKDIR /app

RUN apt-get update && apt-get install -y \
    python3 python3-pip git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

RUN python -c "import vllm; print(vllm.__version__)"

# Install PyTorch (CUDA 12.1)
RUN pip install torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121

# Install vLLM (DeepSeek-OCR compatible)
RUN pip install --upgrade vllm

# DeepSeek-OCR runtime deps
RUN pip install addict matplotlib pillow

ENV HF_HOME=/models
ENV TRANSFORMERS_CACHE=/models

EXPOSE 8000

CMD ["vllm", "serve", "deepseek-ai/DeepSeek-OCR", \
     "--logits_processors", "vllm.model_executor.models.deepseek_ocr:NGramPerReqLogitsProcessor", \
     "--no-enable-prefix-caching", \
     "--mm-processor-cache-gb", "0"]
