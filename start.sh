#!/bin/bash

docker build . -t local-mkdocs

docker run local-mkdocs /bin/sh  >/dev/null 2>&1 &