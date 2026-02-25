"""Tests for core utility functions — camelCase conversion."""

from app.core.utils import camel_dict, to_camel


class TestToCamel:
    """to_camel conversion tests."""

    def test_simple(self):
        assert to_camel("snake_case") == "snakeCase"

    def test_single_word(self):
        assert to_camel("level") == "level"

    def test_multiple_underscores(self):
        assert to_camel("next_level_xp") == "nextLevelXp"

    def test_already_camel(self):
        assert to_camel("alreadyCamel") == "alreadyCamel"

    def test_trailing_underscore(self):
        assert to_camel("trailing_") == "trailing"

    def test_empty(self):
        assert to_camel("") == ""


class TestCamelDict:
    """Recursive camelCase dict conversion tests."""

    def test_flat_dict(self):
        result = camel_dict({"xp_earned": 10, "level_up": True})
        assert result == {"xpEarned": 10, "levelUp": True}

    def test_nested_dict(self):
        result = camel_dict({
            "user_data": {
                "display_name": "Test",
                "streak_days": 5,
            }
        })
        assert result == {
            "userData": {
                "displayName": "Test",
                "streakDays": 5,
            }
        }

    def test_list_of_dicts(self):
        result = camel_dict({
            "exercise_list": [
                {"exercise_id": "ex1", "xp_earned": 10},
                {"exercise_id": "ex2", "xp_earned": 20},
            ]
        })
        assert result["exerciseList"][0]["exerciseId"] == "ex1"
        assert result["exerciseList"][1]["xpEarned"] == 20

    def test_list_of_primitives(self):
        result = camel_dict({"tag_list": ["c", "basics"]})
        assert result == {"tagList": ["c", "basics"]}

    def test_empty_dict(self):
        assert camel_dict({}) == {}

    def test_preserves_already_camel_keys(self):
        result = camel_dict({"level": 0, "xp": 50})
        assert result == {"level": 0, "xp": 50}

    def test_none_values(self):
        result = camel_dict({"started_at": None, "finished_at": None})
        assert result == {"startedAt": None, "finishedAt": None}

    def test_mixed_depth(self):
        result = camel_dict({
            "can_start": True,
            "next_available": "2026-03-01",
            "nested_info": {
                "attempt_count": 3,
                "cooldown_hours": 48,
            }
        })
        assert result["canStart"] is True
        assert result["nextAvailable"] == "2026-03-01"
        assert result["nestedInfo"]["attemptCount"] == 3
