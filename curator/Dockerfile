ARG PYTHON
ARG CURATOR
ARG PYYAML
FROM python:${PYTHON}
RUN pip install elasticsearch-curator==${CURATOR} && pip install -U pyyaml==${PYYAML} && rm -rf /var/cache/apk/*
