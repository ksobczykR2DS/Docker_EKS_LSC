# Stage 1: Build the AWS CLI from source
# Using Alpine for minimal size and fast build
FROM alpine:3.18 AS builder

# Install build dependencies in a single layer
# Note: Combined commands reduce image layers
RUN apk update && apk add --no-cache \
    cmake \
    make \
    gcc \
    g++ \
    musl-dev \
    libffi-dev \
    python3-dev \
    py3-pip \
    curl \
    tar \
    gzip

# Set up build directory
WORKDIR /aws-cli

# Download and extract AWS CLI source
# Note: Using specific version for reproducibility
RUN curl -L "https://github.com/aws/aws-cli/archive/refs/tags/2.13.1.tar.gz" -o awscli.tar.gz && \
    tar -xzf awscli.tar.gz --strip-components=1

# Install AWS CLI
RUN pip install .

# Stage 2: Create minimal runtime image
# Using clean Alpine for smallest possible footprint
FROM alpine:3.18

# Install runtime dependencies
# Note: Only essential packages for AWS CLI operation
RUN apk add --no-cache \
    python3 \
    py3-pip

# Copy AWS CLI from builder stage
# Note: Copy only necessary files
COPY --from=builder /usr/lib/python3.11/site-packages/ /usr/lib/python3.11/site-packages/
COPY --from=builder /usr/bin/aws /usr/bin/aws

# Set working directory for AWS operations
WORKDIR /aws

# Configure container startup command
ENTRYPOINT ["aws"]