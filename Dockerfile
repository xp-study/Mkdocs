FROM harbor.wsh-study.com/public/mkdocs-base:latest

ADD ./ /opt/Mkdocs

WORKDIR /opt/Mkdocs

ENTRYPOINT ["./run.sh"] 

 