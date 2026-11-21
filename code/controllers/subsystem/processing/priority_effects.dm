PROCESSING_SUBSYSTEM_DEF(priority_effects)
	name = "Priority Status Effects"
	flags = SS_KEEP_TIMING | SS_NO_INIT
	wait = 0.2 SECONDS // Same as SSfastprocess, high-priority status effect intervals must be a multiple of this
	priority = FIRE_PRIORITY_PRIORITY_EFFECTS
	stat_tag = "PEFF"
