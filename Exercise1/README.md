# Zabbix 7.2 APK Package for Alpine Linux

## Overview

This repository contains a native Alpine Linux packaging setup for
**Zabbix 7.2**, including:

- Zabbix Agent
- Zabbix Proxy (SQLite backend)
- Documentation (man pages)

---

## Repository Contents
├── Dockerfile   # Reproducible Alpine build environment
├── APKBUILD     # Alpine package specification for Zabbix 7.2
└── README.md    # Build and usage documentation


## Build Environment

The package is built inside a clean Alpine Linux container using Docker.

Docker is used only as a build environment, not as a runtime artifact.
The final result is a native .apk package suitable for installation
via Alpine’s apk package manager.

## Requirements
- Docker
- Internet access (to fetch Zabbix sources)

## Build Instructions

### 1. Build the Docker image
```bash
docker build -t zabbix-alpine-builder .
```

### 2. Run the build container
Mount the directory containing APKBUILD into the container:
```bash
docker run -it --rm -v "$(pwd):/home/builder/zabbix" zabbix-alpine-builder
```

### 3. Generate abuild signing key (one time)
Inside the container:
```bash
abuild-keygen -a -i
```
This generates a local signing key and installs the public key
into /etc/apk/keys.

### 4. Build the package
```bash
cd ~/zabbix
abuild checksum
abuild -r
```
The -r flag ensures the package is built in a clean chroot
environment, similar to Alpine CI.

---

## Resulting Packages
After a successful build, packages are available under:
~/packages/builder/<arch>/

## Example:
- zabbix-agent-7.2.0-r0.apk
- zabbix-proxy-7.2.0-r0.apk
- zabbix-doc-7.2.0-r0.apk

## Package Structure

The build produces the following split packages:
- zabbix-agent
Zabbix monitoring agent daemon
- zabbix-proxy
Zabbix proxy built with SQLite backend
- zabbix-doc
Manual pages (compressed, per Alpine policy)


## Dependencies:

### Runtime Dependencies
- openssl
- curl
- pcre2
- libxml2
- sqlite-libs
- libevent

### Build Dependencies
- alpine-sdk
- linux-headers
- openssl-dev
- curl-dev
- pcre2-dev
- libxml2-dev
- sqlite-dev
- libevent-dev

## Smoke Test
After building, the package can be installed locally for verification:
```bash
doas apk add --allow-untrusted zabbix-agent-7.2.0-r0.apk
```
## Verify installation:
```bash
zabbix_agentd --version
```
## Expected output includes:
zabbix_agentd (daemon) (Zabbix) 7.2.0
Revision 626558708cc
Compiled with OpenSSL 3.1.8
Running with OpenSSL 3.1.8


## Notable Implementation Details
- Zabbix Proxy requires libevent, which is explicitly included
- PCRE2 is used instead of legacy PCRE (--with-libpcre2)
- Man pages are packaged in a dedicated -doc subpackage
- Man pages are compressed (.gz) to satisfy Alpine policy
- The build user is unprivileged; root access is used only when required

## Issues Faced and Solutions

### Missing libevent Dependency

**Issue:**  
Zabbix Proxy build failed with the error:
```text
Unable to use libevent (libevent check failed)
```
**Cause:**  
Zabbix Proxy requires `libevent`, which is not automatically detected
unless explicitly included.

**Solution:**  
Added `libevent` to runtime dependencies and `libevent-dev` to build
dependencies in the APKBUILD file.

---

### PCRE vs PCRE2 Mismatch

**Issue:**  
The build failed with:
```text
cannot find pkg-config package for libpcre
```
**Cause:**  
Zabbix defaults to legacy PCRE (v1), while Alpine Linux uses PCRE2.

**Solution:**  
Enabled PCRE2 explicitly by adding the `--with-libpcre2` configure flag
and using `pcre2` / `pcre2-dev` packages.

---

### Alpine Packaging Policy: Man Pages

**Issue:**  
Build failed during postcheck due to uncompressed man pages:
```text
Found uncompressed man pages
```
**Cause:**  
Alpine requires man pages to be shipped in a dedicated `-doc` package
and compressed.

**Solution:**  
Created a `zabbix-doc` subpackage and explicitly compressed all man pages
using `gzip` during the `doc()` split step.

---

### abuild Cache and Chroot Issues

**Issue:**  
Dependencies such as `libevent` were reported as missing despite being
available in Alpine repositories.

**Cause:**  
Stale or corrupted apk cache and abuild chroot environment.

**Solution:**  
Cleaned the build environment using:
```bash
abuild clean
rm -rf ~/.abuild
rm -rf /var/cache/apk/*
apk update
```
After that re-running the build resolved the issue.