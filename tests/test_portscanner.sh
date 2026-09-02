#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCANNER="$PROJECT_DIR/portscanner.sh"
TEST_PORT=45678

bash -n "$SCANNER"

invalid_output="$(bash "$SCANNER" 127.0.0.1 0 2 2>&1 || true)"
grep -q "ports must be between 1 and 65535" <<<"$invalid_output"

range_output="$(bash "$SCANNER" 127.0.0.1 100 99 2>&1 || true)"
grep -q "start port cannot be greater" <<<"$range_output"

python3 -m http.server "$TEST_PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT
sleep 0.5

scan_output="$(bash "$SCANNER" -t 1 127.0.0.1 45676 45680)"
grep -Eq "^${TEST_PORT}[[:space:]]+open$" <<<"$scan_output"

echo "PASS: syntax validation"
echo "PASS: invalid port rejection"
echo "PASS: reversed range rejection"
echo "PASS: loopback open-port detection"
