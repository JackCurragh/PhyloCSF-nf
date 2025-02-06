# Use a base image with Ubuntu
FROM ubuntu:14.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libgsl0-dev \
    libblas3 \
    libblas-dev \
    liblapack3 \
    liblapack-dev \
    libmysqlclient18 \
    libssl1.0.0 \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

    RUN cd /tmp && \
        wget https://sourceforge.net/projects/libpng/files/libpng15/1.5.30/libpng-1.5.30.tar.xz/download && \
        tar xf libpng-1.5.30.tar.xz && \
        cd libpng-1.5.30 && \
        ./configure && \
        make && \
        make install && \
        cd .. && \
        rm -rf libpng-1.5.30*


    RUN for f in /lib/x86_64-linux-gnu/*; do \
          if [ -f "$f" ]; then \
            ln -sf "$f" "/usr/lib/$(basename $f)" 2>/dev/null || true; \
          fi \
    done


# Clone the CESAR2.0 repository
RUN git clone https://github.com/hillerlab/CESAR2.0.git /opt/CESAR2.0

# Set the working directory
WORKDIR /opt/CESAR2.0

# Compile CESAR2.0
RUN make

# Add the tools directory to PATH
ENV PATH="/opt/CESAR2.0/tools:${PATH}"

# Set the default command
CMD ["/bin/bash"]