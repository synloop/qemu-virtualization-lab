#!/usr/bin/env bash
# Usage: src/qga_send.sh <json-file>
SOCK=/tmp/qga.sock
cat "$1" | socat - UNIX-CONNECT:$SOCK | jq
