extends RefCounted

## Project-wide enumerations (Sprint 1 S1-06). Preload this script to access enum values.
## See GDDs: npc-personality, bonnie-traversal, bidirectional-social §3.4, chaos-meter §3.2.

enum NpcBehavior {
	ASLEEP,
	GROGGY,
	ROUTINE,
	AWARE,
	REACTING,
	RECOVERING,
	VULNERABLE,
	CLOSED_OFF,
	FLEEING,
	CHASING,
	FED,
}

enum InteractionType {
	NONE,
	CHARM,
	CHAOS,
}

enum MeterState {
	COLD,
	WARMING,
	HOT,
	CONVERGING,
	TIPPING,
	FEEDING,
}

enum ChaosSeverity {
	MINOR,
	MODERATE,
	MAJOR,
	CRITICAL,
}

enum FeedingPathType {
	NONE_PATH,
	CHARM_PATH,
	CHAOS_OVERWHELM_PATH,
}

enum BonnieState {
	IDLE,
	SNEAKING,
	WALKING,
	RUNNING,
	SLIDING,
	JUMPING,
	FALLING,
	LANDING,
	CLIMBING,
	SQUEEZING,
	DAZED,
	LEDGE_PULLUP,
	ROUGH_LANDING,
}
