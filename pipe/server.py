#!/usr/bin/env python3
"""Toy fish-lsp-shaped server: reads a DiagnosticRequest, writes a
DiagnosticResponse, both length-prefixed protobuf over stdio.

Fake analysis rule (stand-in for real fish static analysis): flags any
line containing a bare 'rm -rf' as an ERROR, just to prove the
round-trip carries real per-line data.
"""
import sys

import diagnostic_pb2 as d
from framing import read_message, write_message


def analyze(request):
    diagnostics = []
    for lineno, line in enumerate(request.contents.splitlines(), start=1):
        if "rm -rf" in line:
            diagnostics.append(
                d.Diagnostic(
                    file=request.file,
                    line=lineno,
                    severity=d.ERROR,
                    message="refusing to bless bare rm -rf",
                )
            )
    return d.DiagnosticResponse(diagnostics=diagnostics)


def main():
    stdin = sys.stdin.buffer
    stdout = sys.stdout.buffer
    while True:
        request = read_message(stdin, d.DiagnosticRequest)
        if request is None:
            break
        response = analyze(request)
        write_message(stdout, response)


if __name__ == "__main__":
    main()
