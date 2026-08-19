ARG PYTHON="python:3.13.5-slim"

# Stage 1: Requirements generation
FROM ${PYTHON} AS requirements-stage

WORKDIR /tmp

# Install pipreqs tool
RUN pip install pipreqs

# Copy the Python script
COPY data-analyzer.py .

# Generate requirements.txt
# Note: pipreqs works on directories, not individual files
RUN mkdir /tmp/app && \
    cp data-analyzer.py /tmp/app/ && \
    pipreqs /tmp/app --force && \
    cp /tmp/app/requirements.txt .

# Stage 2: Final application image
FROM ${PYTHON}

WORKDIR /app

# Copy requirements and install dependencies
COPY --from=requirements-stage /tmp/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY data-analyzer.py .

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Run the application
CMD ["python", "data-analyzer.py"]