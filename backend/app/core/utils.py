"""Shared utility helpers for the 42 LaunchPad backend."""

from datetime import date

# Keys whose dict values are identifier maps (exercise_id -> value),
# not field-name maps. Their sub-keys must NOT be camelCase-converted.
_IDENTITY_MAP_KEYS = frozenset({"last_drilled", "lastDrilled"})


def to_camel(string: str) -> str:
    """Convert snake_case string to camelCase."""
    components = string.split("_")
    return components[0] + "".join(x.title() for x in components[1:])


def camel_dict(d: dict) -> dict:
    """Recursively convert dict keys from snake_case to camelCase.

    Keys listed in _IDENTITY_MAP_KEYS have their dict values passed
    through without key conversion (they contain identifier maps).
    """
    result: dict = {}
    for k, v in d.items():
        new_key = to_camel(k)
        if k in _IDENTITY_MAP_KEYS or new_key in _IDENTITY_MAP_KEYS:
            # Identifier map — preserve sub-keys as-is
            result[new_key] = v
        elif isinstance(v, dict):
            result[new_key] = camel_dict(v)
        elif isinstance(v, list):
            result[new_key] = [camel_dict(i) if isinstance(i, dict) else i for i in v]
        else:
            result[new_key] = v
    return result


def is_date_in_range(d_str: str, start: date, end: date) -> bool:
    """Check if date string (YYYY-MM-DD) falls within range (inclusive)."""
    try:
        d = date.fromisoformat(d_str)
        return start <= d <= end
    except ValueError:
        return False
