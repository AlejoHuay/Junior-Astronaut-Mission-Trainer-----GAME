"""Offline provenance checks: archived bytes, selected observation and scenario link."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
catalog = json.loads((root / 'data/nasa/curated/catalog.json').read_text(encoding='utf-8'))
for record in catalog['records']:
    raw = root / record['raw_path'].removeprefix('res://')
    assert hashlib.sha256(raw.read_bytes()).hexdigest() == record['raw_sha256'], record['id']
    if record['id'].endswith('FLR-001'):
        observations = json.loads(raw.read_text(encoding='utf-8'))
        assert record['observed'] in observations
        assert record['observed']['flrID'] == record['id']
    elif record['id'] == 'OSD-267':
        metadata = json.loads(raw.read_text(encoding='utf-8'))
        assert metadata['study']['OSD-267']['studies'][0]['title'] == record['observed_title']
    elif record['id'].startswith('RadLab-'):
        table = json.loads(raw.read_text(encoding='utf-8'))
        assert record['observed'] in [dict(zip(table['columns'], row)) for row in table['data']]
        assert record['observed']['spacecraft'] == 'ISS'
        assert record['units']['absorbed_dose_rate'] == '\u00b5Gy/h'
scenarios = json.loads((root / 'data/events/scenarios.json').read_text(encoding='utf-8'))
ids = [record['id'] for record in catalog['records']]
assert scenarios['scenarios']['demo']['science_id'] in ids
print(f'Science provenance: {len(ids)} archived records verified')
