# nRF52840_BM_dev_env_OCI-native_dual-VM

**Zero-cost cloud-native bare-metal development environment for Nordic nRF52840 using Oracle Cloud Infrastructure's Always Free Tier.**

[![Build Docker Image](https://github.com/YOUR_USERNAME/nrf52840-oci-dev/actions/workflows/docker-build-push.yml/badge.svg)](https://github.com/YOUR_USERNAME/nrf52840-oci-dev/actions)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)

## 🎯 What This Project Does

Provisions a **dual-VM architecture** on OCI Always Free Tier:

- **Build Server VM**: Handles firmware compilation with ARM GCC toolchain and nRF5 SDK
- **Hardware Gateway VM**: Bridges your local nRF52840 DK to the cloud via USB/IP tunneling for remote flashing and debugging

**Key Features:**
- 🚀 Fully automated deployment via **Terraform**
- 🐳 **Pre-built Docker images** for fast provisioning (2-3 minutes)
- 🤖 **Claude AI integration** for agentic development workflows
- 💰 **$0/month** cost (OCI Always Free Tier)
- 🔧 Complete toolchain: ARM GCC v12.2, nRF5 SDK v17.1.0, nrfjprog, JLink
- 🌐 Develop from anywhere with VS Code Remote-SSH

## 🏗️ Architecture
┌─────────────────┐ ┌──────────────────────┐ ┌──────────────────────┐ 
│ LOCAL PC │ SSH │ BUILD SERVER VM │ SCP │ HARDWARE GATEWAY VM │ │ (nRF52840 DK) │◄───────►│ (Compilation) │◄───────►│ (USB/IP Bridge) │ │ usbipd-win │ Tunnel │ ARM GCC + nRF5 SDK │ │ nrfjprog + JLink │ 
└─────────────────┘ └──────────────────────┘ └──────────────────────┘

## 🚀 Quick Start

### Prerequisites
- Oracle Cloud account (free tier)
- Windows PC with nRF52840 DK
- Terraform installed locally
- Git configured

### 1. Clone This Repository
```bash
git clone https://github.com/YOUR_USERNAME/nrf52840-oci-dev.git
cd nrf52840-oci-dev
