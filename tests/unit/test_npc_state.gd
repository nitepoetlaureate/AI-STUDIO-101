extends GutTest

const _E := preload("res://src/shared/enums.gd")


func test_michael_defaults_match_gdd() -> void:
	var s := NpcState.create_michael_default()
	assert_eq(s.emotional_level, 0.20, "Michael baseline_tension")
	assert_eq(s.goodwill, 0.0)
	assert_eq(s.current_behavior, _E.NpcBehavior.ROUTINE)
	assert_eq(s.comfort_receptivity, 0.55, "Michael comfort_receptivity_default")
	assert_eq(s.active_stimuli.size(), 0)
	assert_eq(s.visible_to_bonnie, false)
	assert_eq(s.last_interaction_type, _E.InteractionType.NONE)
	assert_eq(s.bonnie_hunger_context, false)
	assert_eq(s.last_interaction_timestamp, -1.0)
	assert_eq(s.recovering_comfort_stacks, 0)


func test_christen_defaults() -> void:
	var s := NpcState.create_christen_default()
	assert_eq(s.emotional_level, 0.25)
	assert_eq(s.comfort_receptivity, 0.65)


func test_chaos_meter_config_invariant() -> void:
	var cfg := load("res://assets/data/chaos_meter_config.tres") as ChaosMeterConfig
	assert_true(is_equal_approx(cfg.chaos_fill_cap + cfg.social_fill_weight, 1.0))


func test_config_resources_load() -> void:
	assert_true(load("res://assets/data/level_config.tres") is LevelConfig)
	assert_true(load("res://assets/data/bonnie_traversal_config.tres") is BonnieTraversalConfig)
	assert_true(load("res://assets/data/social_system_config.tres") is SocialSystemConfig)
	assert_true(load("res://assets/data/npc/michael_profile.tres") is NpcProfile)
	assert_true(load("res://assets/data/npc/christen_profile.tres") is NpcProfile)


func test_bonnie_state_enum_count() -> void:
	# bonnie-traversal §3.1: exactly 13 movement states (indices 0..12)
	assert_eq(_E.BonnieState.IDLE, 0)
	assert_eq(_E.BonnieState.ROUGH_LANDING, 12)
