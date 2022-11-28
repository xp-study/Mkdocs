FROM harbor.wsh-study.com/public/mkdocs-base:latest

ADD ./ /opt/Mkdocs

WORKDIR /opt/Mkdocs

EXPOSE 10000

ENTRYPOINT ["./run.sh"] 

 