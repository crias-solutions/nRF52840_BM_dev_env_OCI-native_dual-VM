# Multi-stage build for optimized image size
FROM ubuntu:22.04 AS base

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    usbip \
    usbutils \
    linux-tools-generic \
    make \
    cmake \
    unzip \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install ARM GCC Toolchain (v12.2.rel1)
WORKDIR /opt
RUN wget -q https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz \
    && tar -xf arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz \
    && rm arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz

ENV PATH="/opt/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/bin:${PATH}"

# Install nRF5 SDK (v17.1.0) with flattening fix
WORKDIR /workspace
RUN wget -q https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/sdks/nrf5/binaries/nrf5_sdk_17.1.0_ddde560.zip \
    && unzip -q nrf5_sdk_17.1.0_ddde560.zip \
    && mv nrf5_sdk_17.1.0_ddde560/* nRF5_SDK/ || mv nRF5_SDK_17.1.0_ddde560/* nRF5_SDK/ \
    && rm nrf5_sdk_17.1.0_ddde560.zip

# Configure SDK Makefile
RUN sed -i 's|GNU_INSTALL_ROOT ?= .*|GNU_INSTALL_ROOT ?= /opt/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/bin/|' \
    /workspace/nRF5_SDK/components/toolchain/gcc/Makefile.posix

# Install nRF Command Line Tools (via .tgz to avoid container issues)
WORKDIR /tmp
RUN wget -q https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/nrf-command-line-tools-10.24.2_linux-amd64.tar.gz \
    && tar -xzf nrf-command-line-tools-10.24.2_linux-amd64.tar.gz -C /opt \
    && rm nrf-command-line-tools-10.24.2_linux-amd64.tar.gz

ENV PATH="/opt/nrf-command-line-tools/bin:${PATH}"

# Install Node.js (for Claude Code CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Claude Code CLI (placeholder - adjust based on actual installation)
RUN npm install -g @anthropic-ai/claude-code-cli || echo "Claude CLI installation skipped"

# Load USB/IP kernel module (for hardware bridging)
RUN modprobe vhci-hcd || echo "vhci-hcd module not available in container"

# Create udev rule for J-Link
RUN echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="1366", ATTR{idProduct}=="1061", MODE="0666", GROUP="plugdev"' \
    > /etc/udev/rules.d/99-jlink.rules

# Set working directory
WORKDIR /workspace/nrf52840_project

# Default command
CMD ["/bin/bash"]
