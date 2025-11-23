from typing import List, Dict, Tuple, Set, TYPE_CHECKING

if TYPE_CHECKING:
    from agent.services.auditor import VulnerabilityFinding
else:
    VulnerabilityFinding = object  # runtime placeholder to avoid circular import


def deduplicate_findings(findings: List[VulnerabilityFinding]) -> List[VulnerabilityFinding]:
    """
    Keep one finding per (title, file_path) pair, preferring the highest severity.
    If duplicates carry different file path lists, merge them.
    """
    severity_rank: Dict[str, int] = {"Critical": 4, "High": 3, "Medium": 2, "Low": 1, "Informational": 0}
    unique: Dict[Tuple[str, str], VulnerabilityFinding] = {}

    for finding in findings:
        for path in finding.file_paths:
            key = (finding.title.strip().lower(), path)
            if key not in unique:
                unique[key] = finding
            else:
                existing = unique[key]
                if severity_rank.get(finding.severity, 0) > severity_rank.get(existing.severity, 0):
                    unique[key] = finding
                # Merge file paths regardless
                merged_paths: Set[str] = set(existing.file_paths) | set(finding.file_paths)
                unique[key].file_paths = list(merged_paths)

    return list(unique.values())
