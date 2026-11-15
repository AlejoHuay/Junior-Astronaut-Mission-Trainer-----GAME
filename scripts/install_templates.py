"""Extract only web templates from the official 4.7.2 TPZ into ignored .tools."""
from pathlib import Path
from zipfile import ZipFile
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("archive", type=Path)
args = parser.parse_args()
target = Path(__file__).resolve().parents[1] / ".tools" / "templates"
with ZipFile(args.archive) as archive:
    version = archive.read("templates/version.txt").decode().strip()
    if version != "4.7.2.stable":
        raise SystemExit(f"Expected 4.7.2.stable, got {version}")
    target.mkdir(parents=True, exist_ok=True)
    for name in ("web_nothreads_debug.zip", "web_nothreads_release.zip"):
        (target / name).write_bytes(archive.read(f"templates/{name}"))
        with ZipFile(target / name) as template:
            if template.testzip() is not None:
                raise SystemExit(f"Invalid template: {name}")
        print(f"Verified {name}")
