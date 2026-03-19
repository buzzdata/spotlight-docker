# Debian-based image: Java + AWS CLI v2 work without Alpine/Python issues.
# S3 tarball provides the model (en/); DBpedia Spotlight JAR is fetched here.
FROM eclipse-temurin:11-jre

ENV SPOTLIGHT_JAR_URL="https://sourceforge.net/projects/spotlight-multilingual-docker/files/dbpedia-spotlight-1.1.jar/download"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 (glibc binary; works on Debian)
RUN curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# DBpedia Spotlight JAR (same as original dockerfile)
RUN mkdir -p /opt/spotlight \
    && curl -sSL -o /opt/spotlight/dbpedia-spotlight.jar -L "$SPOTLIGHT_JAR_URL"

COPY spotlight_s3.sh /opt/spotlight/spotlight_s3.sh
RUN chmod +x /opt/spotlight/spotlight_s3.sh

CMD ["/opt/spotlight/spotlight_s3.sh"]