FROM python:3-stretch

WORKDIR /app

COPY requirements.txt .

RUN pip install -rrequirements.txt

COPY demo_exporter.py .

RUN chmod 0750 demo_exporter.py

EXPOSE 8000

ENTRYPOINT ["/app/demo_exporter.py"]
CMD [""]
