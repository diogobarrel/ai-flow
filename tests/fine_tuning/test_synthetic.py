import pytest
from fine_tuning.synthetic_gen import generate_scenario

def test_generate_scenario_structure():
    # Test that it returns a dict with instruction and response
    scenario = generate_scenario("bootstrap a project")
    assert "instruction" in scenario
    assert "response" in scenario
    assert len(scenario["instruction"]) > 0
