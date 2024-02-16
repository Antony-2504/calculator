# Use an official Python runtime as a base image
FROM almalinux

# Set the working directory in the container
WORKDIR /usr/src/app/

# Install the gcloud command-line tool
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-390.0.0-linux-x86_64.tar.gz \
    && tar zxvf google-cloud-sdk-390.0.0-linux-x86_64.tar.gz \
    && ./google-cloud-sdk/install.sh

# Fetch the secret from Secret Manager and save it as key.json
RUN /google-cloud-sdk/bin/gcloud secrets versions access latest --secret=credentials-json > /usr/src/app/key.json

# Set the GOOGLE_APPLICATION_CREDENTIALS environment variable
ENV GOOGLE_APPLICATION_CREDENTIALS="/usr/src/app/key.json"

# Continue with your Dockerfile setup
RUN echo -e "[gcsfuse]\nname=gcsfuse (packages.cloud.google.com)\nbaseurl=https://packages.cloud.google.com/yum/repos/gcsfuse-el7-x86_64\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=0\ngpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg\n      https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" | tee /etc/yum.repos.d/gcsfuse.repo > /dev/null && \
    yum update -y && \
    yum install -y gcc sudo gnupg2 epel-release && \
    yum install openssl-devel bzip2-devel libffi-devel -y && \
    yum groupinstall "Development Tools" -y && \
    yum install python3.11 -y && \
    yum install python-pip python3-pip -y && \
    yum install -y fuse && \
    yum install gcsfuse -y
RUN pip3 install streamlit langchain torch networkx pandas

# Index of /apt//
# Install any needed packages specified in requirements.txt
##RUN pip install --upgrade pip && pip install -r requirements.txt
# Copy the current directory contents into the container
##COPY . .
# Run script.py when the container launches
##CMD ["python", "./embed_script.py"]
