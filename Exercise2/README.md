# Exercise 2 — CI/CD Pipeline for Custom Zabbix Alpine Package

## Overview

This exercise demonstrates an automated **CI/CD pipeline** for building and publishing a **custom Zabbix APK package for Alpine Linux**.

The pipeline is implemented using **GitHub Actions** and relies on a **Docker-based Alpine build environment** to ensure reproducibility and isolation.

---

## Exercise Structure

```text
Exercise2/
APKBUILD              # Alpine package build definition for Zabbix
Dockerfile            # Docker image used as the Alpine build environment
README.md             # This documentation
deploy/
  deploy.sh         # Example deployment / installation script
```

---

## CI configuration:
```text
.github/workflows/
   main.yml              # GitHub Actions pipeline definition
```

---

## CI/CD Pipeline Description
The pipeline is triggered on:
- every push to the main branch
- manual execution via workflow_dispatch
It consists of a single job: Build and Deploy Zabbix

---

## Pipeline Steps:

### 1. Checkout Repository
```yaml
- uses: actions/checkout@v4
```
The repository is checked out on the GitHub Actions runner so that all sources are available for the build.
### 2. Build Alpine Builder Image
```bash
docker build -t zabbix-alpine-builder .
```
A custom Docker image is built from Exercise2/Dockerfile.

This image:
- is based on Alpine Linux
- contains abuild, alpine-sdk, and all required build dependencies
- creates a non-root builder user for secure package building

Using a Docker-based builder ensures:
- reproducible builds
- no dependency on the GitHub runner environment
- isolation from the host system

### 3. Build Zabbix APK Package
The package build happens inside the Docker container.
Key actions in this step:
Mount source code read-only
```bash
-v $GITHUB_WORKSPACE:/src:ro
```
This prevents accidental modification of repository files during the build.

Copy sources into a writable directory
```bash
cp -r /src /tmp/build

```
Switch to the directory containing APKBUILD
```bash
cd /tmp/build/Exercise2
```
abuild must always be executed from the directory where APKBUILD is located.

Generate and install abuild signing key
```bash
abuild-keygen -a -n
cp /home/builder/.abuild/*.pub /etc/apk/keys/
```

Run the build
```bash
abuild checksum
abuild -r
```
This produces signed .apk packages under the mounted packages/ directory.

---

### 4. Upload Build Artifacts

All generated .apk files are uploaded as GitHub Actions artifacts, making them available for:
- download
- testing
- further deployment steps

---

## Deployment Script (deploy.sh)

The deploy/deploy.sh script demonstrates how the built package could be installed on a target Alpine system.

Typical steps include:
- adding the public signing key
- installing the package via apk add
- running a simple smoke test (e.g. zabbix_agentd --version)

This script is intentionally simple and serves as an example rather than a production deployment tool.

---

## Result

At the end of the pipeline:
- Zabbix is successfully built as Alpine APK packages
- Packages are signed and validated
- Artifacts are available directly from GitHub Actions

The pipeline is fully automated and reproducible.