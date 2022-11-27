FROM harbor.wsh-study.com/public/mkdocs-base:latest

ADD ./ /opt/Mkdocs

WORKDIR /opt/Mkdocs

ENTRYPOINT ["mkdocs serve --dev-addr=0.0.0.0:10000"]