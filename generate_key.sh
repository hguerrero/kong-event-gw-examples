#!/bin/sh
# Generate 16 random bytes and encode to base64
if command -v openssl >/dev/null 2>&1; then
    # OpenSSL method (most systems)
    openssl rand -base64 16
elif command -v dd >/dev/null 2>&1 && [ -f /dev/urandom ]; then
    # Fallback using dd and urandom
    dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64
else
    echo "Error: Neither openssl nor dd with /dev/urandom available" >&2
    exit 1
fi