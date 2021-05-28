ARG PYTHON
FROM python:${PYTHON}
ARG CURATOR
RUN pip install elasticsearch-curator==${CURATOR} && rm -rf /var/cache/apk/*
