import io
import subprocess
import sys
from pathlib import Path

import diagnostic_pb2 as d
from framing import read_message, write_message

HERE = Path(__file__).parent


def test_encode_decode_roundtrip():
    original = d.DiagnosticResponse(
        diagnostics=[d.Diagnostic(file="a.fish", line=3, severity=d.ERROR, message="bad")]
    )
    decoded = d.DiagnosticResponse()
    decoded.ParseFromString(original.SerializeToString())
    assert decoded == original


def test_length_prefixed_framing_single_message():
    buf = io.BytesIO()
    msg = d.Diagnostic(file="x.fish", line=1, severity=d.WARNING, message="hmm")
    write_message(buf, msg)
    buf.seek(0)
    got = read_message(buf, d.Diagnostic)
    assert got == msg


def test_length_prefixed_framing_multiple_messages():
    buf = io.BytesIO()
    msgs = [
        d.Diagnostic(file="x.fish", line=i, severity=d.INFO, message=f"note {i}")
        for i in range(3)
    ]
    for m in msgs:
        write_message(buf, m)
    buf.seek(0)
    for expected in msgs:
        assert read_message(buf, d.Diagnostic) == expected
    assert read_message(buf, d.Diagnostic) is None


def test_server_subprocess_flags_bare_rm_rf():
    proc = subprocess.Popen(
        [sys.executable, str(HERE / "server.py")],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        cwd=HERE,
    )
    try:
        request = d.DiagnosticRequest(
            file="danger.fish",
            contents="echo hello\nrm -rf $HOME\necho done\n",
        )
        write_message(proc.stdin, request)
        proc.stdin.flush()
        response = read_message(proc.stdout, d.DiagnosticResponse)
        assert len(response.diagnostics) == 1
        assert response.diagnostics[0].line == 2
        assert response.diagnostics[0].severity == d.ERROR
    finally:
        proc.stdin.close()
        proc.wait(timeout=5)


def test_server_subprocess_clean_file_has_no_diagnostics():
    proc = subprocess.Popen(
        [sys.executable, str(HERE / "server.py")],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        cwd=HERE,
    )
    try:
        request = d.DiagnosticRequest(file="clean.fish", contents="echo hello\n")
        write_message(proc.stdin, request)
        proc.stdin.flush()
        response = read_message(proc.stdout, d.DiagnosticResponse)
        assert len(response.diagnostics) == 0
    finally:
        proc.stdin.close()
        proc.wait(timeout=5)
