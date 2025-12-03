import re, json
from typing import List, Dict, Any

_METRIC_RE = re.compile(r"^([a-zA-Z_:][a-zA-Z0-9_:]*)(\{([^}]*)\})?\s+([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)\s*$")
_LABEL_RE = re.compile(r"\s*([a-zA-Z_][a-zA-Z0-9_]*)=\"([^\"]*)\"\s*")

DEFAULT_PREFIXES = (
    "clickhouse_keeper_",
    "ClickHouseKeeper_",
    "keeper_",
    "raft_",
)

def parse_prometheus_text(text: str, allow_prefixes=DEFAULT_PREFIXES) -> List[Dict[str, Any]]:
    rows: List[Dict[str, Any]] = []
    if not text:
        return rows
    for line in text.splitlines():
        if not line or line.startswith('#'):
            continue
        m = _METRIC_RE.match(line.strip())
        if not m:
            continue
        name, _, label_blob, val = m.groups()
        if allow_prefixes and not any(name.startswith(p) for p in allow_prefixes):
            continue
        labels={}
        if label_blob:
            for lm in _LABEL_RE.finditer(label_blob):
                labels[lm.group(1)] = lm.group(2)
        try:
            value=float(val)
        except Exception:
            continue
        rows.append({"name": name, "value": value, "labels_json": json.dumps(labels, ensure_ascii=False)})
    return rows
