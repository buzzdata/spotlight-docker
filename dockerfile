FROM dbpedia/dbpedia-spotlight

RUN apt-get update && apt-get install -y awscli && rm -rf /var/lib/apt/lists/*

COPY spotlight_s3.sh /opt/spotlight/spotlight_s3.sh
RUN chmod +x /opt/spotlight/spotlight_s3.sh