FROM openjdk:8-jre-alpine

MAINTAINER  DBpedia Spotlight Team <dbp-spotlight-developers@lists.sourceforge.net>

ENV SPOTLIGHT  https://sourceforge.net/projects/spotlight-multilingual-docker/files/dbpedia-spotlight-1.1.jar

# adding required packages
RUN apk update && \
    apk add bash && \
    apk add tshark && \
    apk add --no-cache curl && \
    apk upgrade curl

RUN mkdir -p /opt/spotlight/models && \ 
   cd /opt/spotlight && \
   wget -O dbpedia-spotlight.jar $SPOTLIGHT && \
   mkdir -p src/main/resources/templates/

COPY spotlight_s3.sh /bin/spotlight_s3.sh
COPY nif-21.vm /opt/spotlight/src/main/resources/templates/nif-21.vm
RUN chmod +x /bin/spotlight_s3.sh

EXPOSE 80
