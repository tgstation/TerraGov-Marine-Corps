#define GENERIC_HAZARD \
	"Watch your ass!",\
	"Look out!",\
	"Watch out!"

#define GENERIC_ACID \
	"Don't step in that bubbling shit!",\
	"Green shit!",\
	"ACID!!",\
	"GOO!!"

#define SOLDIER_ACID \
	"Stay away from that acid!",\
	"Don't step in the acid!",\
	"They're spraying acid!",\
	"Watch out, acid!"

/datum/ai_behavior/human
	/// Assoc list of hazards to avoid and the range to stay away from them
	var/list/hazard_list = list()
	/// Lines when spotting any miscellaneous hazards
	var/list/generic_hazard_lines = list(
		FACTION_NEUTRAL = list(
			"I've never seen shit like this before!",
			GENERIC_HAZARD,
		),
	)
	/// Lines when spotting a grenade
	var/list/grenade_hazard_lines = list(
		FACTION_NEUTRAL = list(
			"Let's get away from the grenade!",
			"Grenade, get out of the way!",
			"Grenade, look out!",
			"Grenade, move!",
			"Grenade!",
			GENERIC_HAZARD,
		),
	)
	/// Lines when spotting fire
	var/list/fire_hazard_lines = list(
		FACTION_NEUTRAL = list(
			"Someone put those flames out!",
			"Stay away from that fire!",
			"Clear those flames!",
			"Move, move, fire!",
			"Look out, fire!",
			"Fire!",
			GENERIC_HAZARD,
		),
	)
	/// Lines when spotting acid spray
	var/list/acid_hazard_lines = list(
		FACTION_NEUTRAL = list(
			GENERIC_ACID,
			GENERIC_HAZARD,
		),
		FACTION_TERRAGOV = list(
			SOLDIER_ACID,
			GENERIC_HAZARD,
		),
		FACTION_NANOTRASEN = list(
			SOLDIER_ACID,
		),
		FACTION_SPECFORCE = list(
			SOLDIER_ACID,
		),
	)
	/// Lines when spotting a shuttle's landing effect
	var/list/shuttle_hazard_lines = list(
		FACTION_NEUTRAL = list(
			"Stay away from under that ship!",
			"Look out, something's landing!",
			"Get clear!",
			"Make way!",
			GENERIC_HAZARD,
		),
	)
	/// Lines when spotting a CAS laser
	var/list/cas_hazard_lines = list(
		FACTION_NEUTRAL = list(
			"They're dropping CAS!",
			"Don't get bombed!",
			"Take cover!",
			"CAS!!",
			GENERIC_HAZARD,
		),
	)
	/// Lines when spotting a facehugger
	var/list/facehugger_hazard_lines = list(
		FACTION_NEUTRAL = list(
			"SHOOT THAT FACEHUGGER!!",
			"FACEHUGGER! SHOOT!!",
			"FACEHUGGER!!",
			"WATCH YOUR ASS!!",
			"WATCH OUT!!",
			"LOOK OUT!!",
		),
	)
	/// Lines when spotting atoms related to xeno abilities
	var/list/xeno_aoe_hazard_lines = list(
		FACTION_NEUTRAL = list(
			"Watch out, that xeno's doing something!",
			"Stay away from the xeno!",
			GENERIC_HAZARD,
		),
	)

/datum/ai_behavior/human/find_next_dirs()
	. = ..()
	if(!.)
		return
	if(!(human_ai_behavior_flags & HUMAN_AI_AVOID_HAZARDS))
		return

	var/list/dir_options = .
	dir_options = dir_options.Copy()
	var/list/exclude_dirs = list()

	var/turf/owner_turf = get_turf(mob_parent)

	//lava
	if(can_cross_lava_turf(owner_turf)) //if we're already in lava, we skip these checks since we're probs gonna have to walk through more to get out
		for(var/dir_option in dir_options)
			var/turf/turf_option = get_step(owner_turf, dir_option)
			if(!islava(turf_option))
				continue
			if(turf_option.is_covered())
				continue
			exclude_dirs |= dir_option

		dir_options -= exclude_dirs
		if(!length(dir_options))
			return NONE //if we're NOT in lava, we do not deliberately path into lava
			//todo: Need to have NPC path around lava entirely (or jump over it), if their direct path is into lava

	//hazards
	exclude_dirs.Cut()
	for(var/atom/movable/thing AS in hazard_list)
		var/dist = get_dist(mob_parent, thing)
		if(dist > hazard_list[thing] + 1)
			continue
		if(!isturf(thing.loc)) //picked up nade etc
			continue
		if(dist == 0)
			if(length(dir_options)) //we want to get off the hazard, but if we're trying to go somewhere else already, then that dir is fine
				continue
			dir_options = CARDINAL_ALL_DIRS
			continue
		var/dir_to_hazard = get_dir(mob_parent, thing)
		exclude_dirs |= dir_to_hazard
		exclude_dirs |= turn(dir_to_hazard, 45)
		exclude_dirs |= turn(dir_to_hazard, -45)

		dir_options |= REVERSE_DIR(dir_to_hazard)
		if(dist > (ROUND_UP(hazard_list[thing] * 0.5))) //outer half of danger zone, lets add diagonals for variation
			dir_options |= turn(dir_to_hazard, 135)
			dir_options |= turn(dir_to_hazard, 225)

	dir_options -= exclude_dirs
	if(length(dir_options))
		return dir_options
	//if hazards cause movement paralysis, we just say fuck it, and ignore them since apparently every direction is dangerous

///Clear the hazard list if we change z
/datum/ai_behavior/human/proc/on_change_z(atom/movable/source, old_z, new_z)
	SIGNAL_HANDLER
	for(var/hazard in hazard_list)
		remove_hazard(hazard)

///Adds a hazard to watch for
/datum/ai_behavior/human/proc/add_hazard(datum/source, atom/hazard)
	SIGNAL_HANDLER
	var/turf/hazard_turf = get_turf(hazard)
	if(hazard_turf.z != mob_parent.z)
		return
	var/hazard_radius = hazard.get_ai_hazard_radius(mob_parent)
	if(isnull(hazard_radius))
		return
	hazard_list[hazard] = hazard_radius
	RegisterSignals(hazard, list(COMSIG_QDELETING, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(remove_hazard))
	if(get_dist(mob_parent, hazard) > 5)
		return
	if(isgrenade(hazard))
		if(prob(85))
			faction_list_speak(grenade_hazard_lines)
		return
	if(isfire(hazard))
		if(prob(20))
			faction_list_speak(fire_hazard_lines)
		return
	if(istype(hazard, /obj/effect/xenomorph/spray))
		if(prob(20))
			faction_list_speak(acid_hazard_lines)
		return
	if(istype(hazard, /obj/effect/abstract/ripple))
		if(prob(20))
			faction_list_speak(shuttle_hazard_lines)
		return
	if(istype(hazard, /obj/effect/overlay/blinking_laser/marine))
		if(prob(20))
			faction_list_speak(cas_hazard_lines)
		return
	if(isfacehugger(hazard))
		if(prob(20))
			faction_list_speak(facehugger_hazard_lines)
		return
	if(istype(hazard, /obj/effect/xeno/crush_warning) || istype(hazard, /obj/effect/xeno/abduct_warning) || istype(hazard, /obj/effect/temp_visual/behemoth/warning))
		if(prob(20))
			faction_list_speak(xeno_aoe_hazard_lines)
		return

	if(prob(20))
		faction_list_speak(generic_hazard_lines)

///Removes a hazard
/datum/ai_behavior/human/proc/remove_hazard(atom/old_hazard)
	SIGNAL_HANDLER
	hazard_list -= old_hazard
	UnregisterSignal(old_hazard, list(COMSIG_QDELETING, COMSIG_MOVABLE_Z_CHANGED))

///Checks if we are safe from any hazards
/datum/ai_behavior/human/proc/check_hazards()
	for(var/atom/movable/thing AS in hazard_list)
		if(get_dist(mob_parent, thing) <= hazard_list[thing])
			return FALSE
	return TRUE

#undef GENERIC_HAZARD
#undef GENERIC_ACID
#undef SOLDIER_ACID
