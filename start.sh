#!/bin/bash

docker build . -t local-mkdocs

docker run local-mkdocs /bin/sh &