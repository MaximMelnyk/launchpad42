"""Shared utility helpers for the 42 LaunchPad backend."""


def to_camel(string: str) -> str:
    """Convert snake_case string to camelCase."""
    components = string.split("_")
    return components[0] + "".join(x.title() for x in components[1:])


def camel_dict(d: dict) -> dict:
    """Recursively convert dict keys from snake_case to camelCase."""
    result: dict = {}
    for k, v in d.items():
        new_key = to_camel(k)
        if isinstance(v, dict):
            result[new_key] = camel_dict(v)
        elif isinstance(v, list):
            result[new_key] = [camel_dict(i) if isinstance(i, dict) else i for i in v]
        else:
            result[new_key] = v
    return result
