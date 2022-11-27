#!/bin/bash

docker build . -t local-mkdocs

docker run -p 10000:10000 local-mkdocs /bin/sh  >/dev/null 2>&1 &