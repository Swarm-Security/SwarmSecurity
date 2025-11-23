import json
import os
import time
import glob
from pathlib import Path
from typing import List, Dict, Any


def _severity_counts(findings: List[Any]) -> Dict[str, int]:
    """Count findings per severity."""
    counts = {"Critical": 0, "High": 0, "Medium": 0, "Low": 0, "Informational": 0}
    for f in findings:
        severity = getattr(f, "severity", None)
        if severity is None and isinstance(f, dict):
            severity = f.get("severity")
        if severity in counts:
            counts[severity] += 1
    return counts


def record_benchmark(repo_url: str, findings: List[Any], duration_seconds: float, output_dir: str = "benchmarks") -> str:
    """
    Persist a benchmark record with duration and severity counts.
    Stores numbered JSON files in output_dir (run_001.json, run_002.json, ...).
    """
    os.makedirs(output_dir, exist_ok=True)

    counts = _severity_counts(findings)
    existing = sorted(Path(p) for p in glob.glob(os.path.join(output_dir, "run_*.json")))
    next_index = 1
    if existing:
        try:
            latest = existing[-1].stem.split("_")[-1]
            next_index = int(latest) + 1
        except Exception:
            next_index = len(existing) + 1

    payload = {
        "repo": repo_url,
        "duration_seconds": round(duration_seconds, 2),
        "counts": counts,
        "total_findings": len(findings),
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }

    out_path = Path(output_dir) / f"run_{next_index:03d}.json"
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)

    return str(out_path)
