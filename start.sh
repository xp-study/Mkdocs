#!/bin/bash

docker build . -t local-mkdocs

docker run -it local-mkdocs /bin/sh