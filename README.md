# Bash TCP Port Scanner

## Overview

This Bash project performs authorized TCP connect checks through `/dev/tcp`. It supports interactive use, individual ports, port ranges, configurable timeouts, and batch input.

## Usage

```bash
./portscanner.sh
./portscanner.sh 192.0.2.10 443
./portscanner.sh 192.0.2.10 20 100
./portscanner.sh -t 1 192.0.2.10 20 100
./portscanner.sh -f hosts_to_scan.txt
```

The batch-file format uses three lines per scan target:

```text
192.0.2.10
20
100
```

## Features

- Validates TCP port numbers and ranges.
- Uses a two-second default timeout.
- Accepts a custom timeout through `-t`.
- Suppresses expected connection errors and reports open ports clearly.
- Continues through each port in the requested range.
- Supports repeatable batch scanning.

## Validation

The script passes `bash -n` syntax validation and has been exercised against loopback test ports.

## Authorized Use

Run this scanner only against systems you own or have explicit permission to test.

## Author

Daniel McNamara  
B.S. Cybersecurity Candidate, Lewis University — December 2026
