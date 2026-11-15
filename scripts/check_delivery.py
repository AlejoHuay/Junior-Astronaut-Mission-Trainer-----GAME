"""Check the actual extracted ZIP over loopback HTTP; this does not run a browser."""
import functools
import hashlib
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import tempfile
from threading import Thread
from urllib.request import ProxyHandler, build_opener
import zipfile

ROOT = Path(__file__).resolve().parent.parent
PACKAGE = ROOT / "build/Junior-Astronaut-Mission-Trainer-F4.zip"


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


with tempfile.TemporaryDirectory(prefix="astronaut-review-", dir=ROOT / "build") as folder:
	# The temporary extraction and its automatic cleanup stay inside the workspace build directory.
    assert Path(folder).resolve().is_relative_to((ROOT / "build").resolve())
    with zipfile.ZipFile(PACKAGE) as archive:
        assert archive.testzip() is None
        for name in archive.namelist():
            assert not Path(name).is_absolute() and ".." not in Path(name).parts
        archive.extractall(folder)
    root = Path(folder)
    manifest = json.loads((root / "MANIFEST.json").read_text(encoding="utf-8"))
    for name, digest in manifest["sha256"].items():
        assert hashlib.sha256((root / name).read_bytes()).hexdigest() == digest, name
    handler = functools.partial(QuietHandler, directory=str(root / "web"))
    server = ThreadingHTTPServer(("127.0.0.1", 0), handler)
    worker = Thread(target=server.serve_forever, daemon=True)
    worker.start()
    opener = build_opener(ProxyHandler({}))
    try:
        for file in (root / "web").iterdir():
            with opener.open(f"http://127.0.0.1:{server.server_port}/{file.name}", timeout=15) as response:
                assert response.status == 200
                assert response.read() == file.read_bytes(), file.name
                if file.suffix == ".wasm":
                    assert response.headers.get_content_type() == "application/wasm"
    finally:
        server.shutdown()
        worker.join()
        server.server_close()
print("Delivery PASS: ZIP extracted, hashes verified, all web files served over HTTP; WASM MIME correct.")
print("Browser rendering and durable save persistence remain manual checks.")
