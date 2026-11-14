"""Reject threaded WebAssembly, even if the export preset claims no threads."""
import argparse
import io
from pathlib import Path


def uint(stream):
    value, shift = 0, 0
    while True:
        raw = stream.read(1)
        if not raw or shift > 63:
            raise ValueError("Invalid WebAssembly integer")
        byte = raw[0]
        value |= (byte & 127) << shift
        if byte < 128:
            return value
        shift += 7


def limits(stream):
    flags = uint(stream)
    uint(stream)
    if flags & 1:
        uint(stream)
    return bool(flags & 2)


def memory_modes(path):
    modes = []
    with path.open("rb") as wasm:
        if wasm.read(8) != b"\x00asm\x01\x00\x00\x00":
            raise ValueError("Invalid WebAssembly header")
        while section := wasm.read(1):
            data = io.BytesIO(wasm.read(uint(wasm)))
            if section == b"\x05":
                for _ in range(uint(data)):
                    modes.append(limits(data))
            elif section == b"\x02":
                for _ in range(uint(data)):
                    for _ in range(2):
                        data.read(uint(data))
                    kind = data.read(1)
                    if kind == b"\x00":
                        uint(data)
                    elif kind == b"\x01":
                        data.read(1)
                        limits(data)
                    elif kind == b"\x02":
                        modes.append(limits(data))
                    elif kind == b"\x03":
                        data.read(2)
                    elif kind == b"\x04":
                        uint(data)
                        uint(data)
                    else:
                        raise ValueError("Unsupported import kind")
    return modes


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", nargs="?", type=Path, default=Path("build/web"))
    args = parser.parse_args()
    for name in ("index.html", "index.js", "index.pck", "index.wasm"):
        if not (args.directory / name).is_file():
            raise SystemExit(f"Missing export file: {name}")
    modes = memory_modes(args.directory / "index.wasm")
    if not modes or any(modes):
        raise SystemExit("FAIL: WebAssembly uses shared memory or has no recognized memory. Use web_nothreads templates.")
    print("PASS: complete web export; WebAssembly memory is not shared (no thread isolation required).")
