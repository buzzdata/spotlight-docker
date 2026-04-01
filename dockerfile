FROM eclipse-temurin:8-jre-alpine

MAINTAINER  DBpedia Spotlight Team <dbpedia-spotlight-developers@lists.sourceforge.net>

ENV SPOTLIGHT=https://sourceforge.net/projects/spotlight-multilingual-docker/files/dbpedia-spotlight-1.1.jar

RUN apk update && \
    apk add bash && \
    apk add tshark && \
    apk add --no-cache curl && \
    apk upgrade curl

RUN mkdir -p /opt/spotlight/models && \
    cd /opt/spotlight && \
    wget -O dbpedia-spotlight.jar $SPOTLIGHT && \
    mkdir -p src/main/resources/templates/

COPY spotlight_run.sh /bin/spotlight_run.sh
COPY nif-21.vm /opt/spotlight/src/main/resources/templates/nif-21.vm
RUN chmod +x /bin/spotlight_run.sh

COPY models/spotlight-model-en.tar.gz /tmp/spotlight-model-en.tar.gz
RUN tar -C /opt/spotlight/models -xf /tmp/spotlight-model-en.tar.gz && \
    rm -f /tmp/spotlight-model-en.tar.gz

EXPOSE 80

CMD ["/bin/spotlight_run.sh"]
