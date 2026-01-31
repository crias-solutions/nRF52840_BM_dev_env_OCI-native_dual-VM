# Base image: Ubuntu 22.04 LTS
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ========== SYSTEM DEPENDENCIES ==========
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    gcc \
    git \
    curl \
    wget \
    unzip \
    usbip \
    hwdata \
    usbutils \
    kmod \
    python3 \
    python3-pip \
    python3-venv \
    ca-certificates \
    gnupg \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# ========== ARM GCC TOOLCHAIN v12.2.rel1 ==========
WORKDIR /opt
RUN wget -q https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz \
    && tar -xf arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz \
    && rm arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz

ENV PATH="/opt/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/bin:${PATH}"

# ========== nRF5 SDK v17.1.0 (FLATTENED) ==========
WORKDIR /opt/nrf5_sdk
RUN wget -q https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/sdks/nrf5/binaries/nrf5_sdk_17.1.0_ddde560.zip \
    && unzip -q nrf5_sdk_17.1.0_ddde560.zip \
    && if [ -d "nRF5_SDK_17.1.0_ddde560" ]; then mv nRF5_SDK_17.1.0_ddde560/* .; rmdir nRF5_SDK_17.1.0_ddde560; fi \
    && rm nrf5_sdk_17.1.0_ddde560.zip

ENV NRF5_SDK_PATH=/opt/nrf5_sdk

# Configure SDK Makefile for our toolchain
RUN sed -i 's|GNU_INSTALL_ROOT ?= .*|GNU_INSTALL_ROOT ?= /opt/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/bin/|' \
    /opt/nrf5_sdk/components/toolchain/gcc/Makefile.posix

# ========== nRF COMMAND LINE TOOLS ==========
WORKDIR /tmp
RUN wget -q https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/nrf-command-line-tools_10.24.2_amd64.deb \
    && dpkg -i nrf-command-line-tools_10.24.2_amd64.deb || apt-get install -f -y \
    && rm nrf-command-line-tools_10.24.2_amd64.deb

# ========== J-LINK (TGZ METHOD) ==========
RUN mkdir -p /opt/SEGGER \
    && wget -q --post-data "accept_license_agreement=accepted" \
       -O /tmp/JLink.tgz \
       "https://www.segger.com/downloads/jlink/JLink_Linux_x86_64.tgz" \
    && tar -xzf /tmp/JLink.tgz -C /opt/SEGGER/ \
    && rm /tmp/JLink.tgz \
    && JLINK_DIR=$(ls /opt/SEGGER | grep JLink) \
    && ln -s /opt/SEGGER/$JLINK_DIR /opt/SEGGER/JLink

ENV PATH="/opt/SEGGER/JLink:${PATH}"
ENV LD_LIBRARY_PATH="/opt/SEGGER/JLink:${LD_LIBRARY_PATH}"

# ========== NODE.JS & CLAUDE CODE CLI ==========
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g @anthropic-ai/claude-code || echo "Claude CLI installation skipped"

# ========== USB/IP KERNEL MODULE SETUP ==========
RUN echo "vhci-hcd" > /etc/modules-load.d/usbip.conf

# ========== CREATE UDEV RULE FOR J-LINK ==========
RUN echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="1366", ATTR{idProduct}=="1061", MODE="0666", GROUP="plugdev"' \
    > /etc/udev/rules.d/99-jlink.rules

# ========== WORKING DIRECTORY ==========
WORKDIR /workspace/nrf52840_project

# ========== DEFAULT COMMAND ==========
CMD ["/bin/bash"]
