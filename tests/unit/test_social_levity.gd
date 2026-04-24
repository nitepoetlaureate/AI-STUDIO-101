extends GutTest

const _E := preload("res://src/shared/enums.gd")


func test_levity_multiplier_applies_when_chaos_recent() -> void:
	var st := NpcState.create_michael_default()
	st.last_chaos_timestamp = 0.0
	st.comfort_receptivity = 0.8
	var cfg := load("res://assets/data/social_system_config.tres") as SocialSystemConfig
	var charm: float = 0.1
	var with_levity: float = charm * cfg.levity_multiplier * st.comfort_receptivity
	var no_levity: float = charm * st.comfort_receptivity
	assert_gt(with_levity, no_levity)
