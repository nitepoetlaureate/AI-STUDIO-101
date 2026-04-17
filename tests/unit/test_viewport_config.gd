extends GutTest

func test_viewport_project_settings_validate() -> void:
	assert_true(ViewportConfig.validate_project_settings(), "720×540 viewport stack must match GDD")
