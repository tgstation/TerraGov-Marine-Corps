#define GENERIC_GRENADE_LINES \
	"Fire in the hole!",\
	"Here it comes!",\
	"Grenade out!",\
	"Catch this!",\
	"This is it!"

#define INCEND_GRENADE_LINES \
	"Burn, you piece of shit!",\
	"You're gonna burn!",\
	"Burn!"

/datum/ai_behavior/human
	///Probability of trying to throw a grenade during process
	var/nade_throw_prob = 15
	/// Lines when throwing a grenade
	var/list/nade_throw_lines = list(
		FACTION_NEUTRAL = list(
			GENERIC_GRENADE_LINES,
		),
	)
	/// Overrides `nade_throw_lines`, list of specific grenade types -> special lines for them
	var/static/list/special_nade_lines = list(
		/obj/item/explosive/grenade/incendiary = list(
			INCEND_GRENADE_LINES,
			GENERIC_GRENADE_LINES,
		),
		/obj/item/explosive/grenade/phosphorus = list(
			INCEND_GRENADE_LINES,
			GENERIC_GRENADE_LINES,
		),
		/obj/item/explosive/grenade/sticky/trailblazer = list(
			INCEND_GRENADE_LINES,
			GENERIC_GRENADE_LINES,
		),
		// Specialized bullet bomb types -> base bullet bomb
		/obj/item/explosive/grenade/bullet/laser = list(
			"Lasburster out, watch your ass!",
			"Lasburster out!",
			INCEND_GRENADE_LINES,
			GENERIC_GRENADE_LINES,
		),
		/obj/item/explosive/grenade/bullet/hefa = list(
			"HEFA out, watch your ass!",
			"HEFA out!",
			GENERIC_GRENADE_LINES,
		),
		// Specialized smoke bomb types -> base smoke bomb
		/obj/item/explosive/grenade/smokebomb/drain = list(
			"Tanglefoot out!",
		),
		/obj/item/explosive/grenade/smokebomb/antigas = list(
			"Anti-gas bomb out!",
		),
		/obj/item/explosive/grenade/smokebomb/acid = list(
			INCEND_GRENADE_LINES,
			GENERIC_GRENADE_LINES,
		),
		/obj/item/explosive/grenade/smokebomb/satrapine = list(
			"SATRAPINE GOING OUT!!",
			"SATRAPINE OUT!!",
			GENERIC_GRENADE_LINES,
		),
		/obj/item/explosive/grenade/smokebomb = list(
			"Throwing a smoke bomb!",
			"Smoke bomb out!",
			"Smoke!",
		),
	)

///Decides if we should throw a grenade
/datum/ai_behavior/human/proc/grenade_process()
	if(!length(mob_inventory.grenade_list))
		return
	if(!combat_target)
		return
	if(!prob(nade_throw_prob))
		return
	if(get_dist(mob_parent, combat_target) < 4) //lets not nade ourselves
		return
	if(isliving(combat_target))
		var/mob/living/living_target = combat_target
		if(living_target.stat)
			return
	if(!line_of_sight(mob_parent, combat_target, 7))
		return
	if(check_path(mob_parent, combat_target, PASS_THROW) != get_turf(combat_target))
		return
	if(!check_path_ff(mob_parent, combat_target))
		return
	return throw_grenade(pick(RANGE_TURFS(1, combat_target)), get_grenade()) //add a bit of randomness for FUN

///Throws the grenade
/datum/ai_behavior/human/proc/throw_grenade(atom/target, obj/item/explosive/grenade/grenade)
	if(!grenade)
		return
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return
	grenade.attack_self(mob_parent)
	if(prob(85))
		if(is_type_in_list(grenade, special_nade_lines))
			custom_speak(pick(special_nade_lines[grenade.type]), force = TRUE)
		else
			faction_list_speak(nade_throw_lines, force = TRUE)
	return mob_parent.throw_item(target, grenade)

///Finds a suitable grenade to throw
/datum/ai_behavior/human/proc/get_grenade()
	var/list/nade_options = list()
	for(var/obj/item/explosive/grenade/option AS in mob_inventory.grenade_list)
		if(isgun(option.loc))
			continue
		var/mob/living/living_parent = mob_parent
		if(istype(option, /obj/item/explosive/grenade/smokebomb) && !option.dangerous && (living_parent.health <= minimum_health * 2 * living_parent.maxHealth))
			return
		nade_options += option

	return pick(nade_options)

#undef GENERIC_GRENADE_LINES
#undef INCEND_GRENADE_LINES
