extends GutTest


func test_emotional_decay_moves_toward_baseline() -> void:
	var st := NpcState.create_michael_default()
	var prof: NpcProfile = load("res://assets/data/npc/michael_profile.tres") as NpcProfile
	st.emotional_level = 0.9
	var delta: float = 1.0 / 60.0
	var before: float = st.emotional_level
	st.emotional_level += (prof.baseline_tension - st.emotional_level) * prof.emotion_decay_rate * delta
	st.emotional_level = clampf(st.emotional_level, 0.0, 1.0)
	assert_lt(st.emotional_level, before)
	assert_gt(st.emotional_level, prof.baseline_tension - 0.2)
