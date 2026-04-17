extends GutTest

func test_input_system_config_tres_defaults() -> void:
	var cfg: InputSystemConfig = load("res://assets/data/input_system_config.tres") as InputSystemConfig
	assert_not_null(cfg, "input_system_config.tres must load")
	assert_eq(cfg.stick_deadzone, 0.2, "stick_deadzone per input-system GDD §3.3")
	assert_eq(cfg.sneak_threshold, 0.35, "sneak_threshold per sprint S1-04")
	assert_eq(cfg.trigger_deadzone, 0.1, "trigger_deadzone per input-system GDD §3.3")
