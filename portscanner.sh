#!/usr/bin/env bash

set -u

DEFAULT_TIMEOUT=2

usage() {
    echo "Usage:"
    echo "  $0"
    echo "  $0 <target> <port>"
    echo "  $0 <target> <start-port> <end-port>"
    echo "  $0 -t <seconds> <target> <start-port> <end-port>"
    echo "  $0 -f <batch-file>"
}

validate_port() {
    [[ "$1" =~ ^[0-9]+$ ]] && (( "$1" >= 1 && "$1" <= 65535 ))
}

scan_range() {
    local target="$1"
    local start_port="$2"
    local end_port="$3"
    local timeout_seconds="$4"

    if ! validate_port "$start_port" || ! validate_port "$end_port"; then
        echo "Error: ports must be between 1 and 65535." >&2
        return 1
    fi

    if (( start_port > end_port )); then
        echo "Error: the start port cannot be greater than the end port." >&2
        return 1
    fi

    echo "Scanning ${target} ports ${start_port}-${end_port} with a ${timeout_seconds}s timeout"
    for ((port = start_port; port <= end_port; port++)); do
        if timeout "$timeout_seconds" bash -c ">/dev/tcp/${target}/${port}" 2>/dev/null; then
            printf "%-6s open\n" "$port"
        fi
    done
}

scan_batch_file() {
    local batch_file="$1"
    local timeout_seconds="$2"
    local target start_port end_port

    if [[ ! -r "$batch_file" ]]; then
        echo "Error: cannot read batch file: $batch_file" >&2
        return 1
    fi

    while IFS= read -r target && IFS= read -r start_port && IFS= read -r end_port; do
        [[ -z "$target" ]] && continue
        scan_range "$target" "$start_port" "$end_port" "$timeout_seconds"
    done < "$batch_file"
}

main() {
    local timeout_seconds="$DEFAULT_TIMEOUT"

    case "$#" in
        0)
            read -r -p "Target host: " target
            read -r -p "Starting port: " start_port
            read -r -p "Ending port: " end_port
            scan_range "$target" "$start_port" "$end_port" "$timeout_seconds"
            ;;
        2)
            if [[ "$1" == "-f" ]]; then
                scan_batch_file "$2" "$timeout_seconds"
            else
                scan_range "$1" "$2" "$2" "$timeout_seconds"
            fi
            ;;
        3)
            scan_range "$1" "$2" "$3" "$timeout_seconds"
            ;;
        5)
            if [[ "$1" != "-t" || ! "$2" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
                usage
                return 1
            fi
            timeout_seconds="$2"
            scan_range "$3" "$4" "$5" "$timeout_seconds"
            ;;
        *)
            usage
            return 1
            ;;
    esac
}

main "$@"
