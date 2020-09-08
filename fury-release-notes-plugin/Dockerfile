ARG PYTHON
FROM python:${PYTHON}

ARG SEMANTIC_VERSION
RUN pip install semantic_version==${SEMANTIC_VERSION}

COPY release-notes.py /app/release-notes.py
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
