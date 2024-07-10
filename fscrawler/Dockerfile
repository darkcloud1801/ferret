# Dockerfile
FROM dadoonet/fscrawler:latest

# Install Tesseract
RUN apt-get update && \
    apt-get install -y tesseract-ocr

## Copy FSCrawler job configuration
#COPY ./config/ /root/.fscrawler/