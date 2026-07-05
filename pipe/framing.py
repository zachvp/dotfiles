"""Length-prefixed protobuf message framing over a byte stream.

Wire format: 4-byte big-endian length prefix, followed by that many
bytes of serialized protobuf message. Mirrors LSP's Content-Length
framing, but with a fixed-width binary length instead of a text header.
"""
import struct

_LEN_STRUCT = struct.Struct(">I")


def write_message(stream, message):
    payload = message.SerializeToString()
    stream.write(_LEN_STRUCT.pack(len(payload)))
    stream.write(payload)
    stream.flush()


def read_message(stream, message_cls):
    header = _read_exact(stream, _LEN_STRUCT.size)
    if header is None:
        return None
    (length,) = _LEN_STRUCT.unpack(header)
    payload = _read_exact(stream, length)
    if payload is None:
        raise EOFError("stream closed mid-message")
    message = message_cls()
    message.ParseFromString(payload)
    return message


def _read_exact(stream, n):
    chunks = []
    remaining = n
    while remaining > 0:
        chunk = stream.read(remaining)
        if not chunk:
            return None if remaining == n else b""
        chunks.append(chunk)
        remaining -= len(chunk)
    return b"".join(chunks)
