# Use a base image with Ubuntu
FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    build-essential \
    libgsl0-dev \
    libblas3 \
    libblas-dev \
    liblapack3 \
    liblapack-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*


RUN for f in /lib/x86_64-linux-gnu/*; do \
      if [ -f "$f" ]; then \
        ln -sf "$f" "/usr/lib/$(basename $f)" 2>/dev/null || true; \
      fi \
done

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Add conda to path
ENV PATH="/opt/conda/bin:${PATH}"

# Configure conda channels and install PhyloCSF
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda install -y phylocsf

RUN git clone https://github.com/mlin/PhyloCSF.git /opt/PhyloCSF && cp -r /opt/PhyloCSF/* /opt/conda/bin/


# Clone the CESAR2.0 repository
RUN git clone https://github.com/hillerlab/CESAR2.0.git /opt/CESAR2.0

# Set the working directory
WORKDIR /opt/CESAR2.0

RUN python3 -m pip install biopython pandas

# Compile CESAR2.0
RUN make

# Add the tools directory to PATH
ENV PATH="/opt/CESAR2.0/tools:${PATH}"

# Set the default command
CMD ["/bin/bash"]