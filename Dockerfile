# Use an official Python runtime as a base image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    sudo \
    gnupg2 \
    openssl \
    libssl-dev \
    bzip2 \
    libbz2-dev \
    libffi-dev \
    fuse \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install gcsfuse
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-bionic main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y gcsfuse

# Copy the GCP service account key into the Docker image
RUN gcloud secrets versions access latest --secret=credentials-json > /usr/src/app/key.json

# Set the GOOGLE_APPLICATION_CREDENTIALS environment variable
ENV GOOGLE_APPLICATION_CREDENTIALS="/usr/src/app/key.json"

# Install Python dependencies
COPY requirements.txt /usr/src/app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy your application code
COPY . /usr/src/app

# Run your application
CMD ["python", "main.py"]
