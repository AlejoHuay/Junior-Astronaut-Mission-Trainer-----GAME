"""Package the verified web export, documentation and notices; never upload anything."""
import hashlib
import json
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"
OUTPUT = BUILD / "Junior-Astronaut-Mission-Trainer-F4.zip"
WEB_FILES = (
    "index.html", "index.js", "index.wasm", "index.pck", "index.png",
    "index.icon.png", "index.apple-touch-icon.png",
    "index.audio.worklet.js", "index.audio.position.worklet.js",
)


def main():
    files = {"web/" + name: BUILD / "web" / name for name in WEB_FILES}
    files.update({"docs/" + path.name: path for path in (ROOT / "docs").glob("*.md")})
    files.update({
        "LEEME.md": ROOT / "docs/DELIVERY.md",
        "README-PROYECTO.md": ROOT / "README.md",
        "GODOT-LICENSES.txt": BUILD / "GODOT-LICENSES.txt",
    })
    payload = {name: path.read_bytes() for name, path in files.items()}
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    dirty = bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT, text=True).strip())
    manifest = {
        "candidate": "F4-manual-review", "source_commit": revision,
        "working_tree_modified": dirty, "manual_acceptance": "pending",
        "sha256": {name: hashlib.sha256(data).hexdigest() for name, data in payload.items()},
    }
    payload["MANIFEST.json"] = json.dumps(manifest, indent=2, ensure_ascii=False).encode("utf-8")
    with zipfile.ZipFile(OUTPUT, "w", zipfile.ZIP_DEFLATED) as archive:
        for name, data in sorted(payload.items()):
            entry = zipfile.ZipInfo(name, (2026, 1, 1, 0, 0, 0))
            entry.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(entry, data)
    with zipfile.ZipFile(OUTPUT) as archive:
        assert archive.testzip() is None, "Corrupt ZIP"
        for name, digest in manifest["sha256"].items():
            assert hashlib.sha256(archive.read(name)).hexdigest() == digest, name
    digest = hashlib.sha256(OUTPUT.read_bytes()).hexdigest()
    OUTPUT.with_suffix(".zip.sha256").write_text(f"{digest}  {OUTPUT.name}\n", encoding="ascii")
    print(f"Package verified: {OUTPUT.name}, {OUTPUT.stat().st_size} bytes, {len(payload)} files")
    print(f"SHA-256: {digest}")


if __name__ == "__main__":
    main()
