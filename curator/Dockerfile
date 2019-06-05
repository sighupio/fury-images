ARG PYTHON
FROM python:${PYTHON}
ARG CURATOR
ARG PYYAML
RUN pip install elasticsearch-curator==${CURATOR} && pip install -U pyyaml==${PYYAML} && rm -rf /var/cache/apk/*
