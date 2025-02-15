/mob/living/carbon/xenomorph/dragon
	caste_base_type = /datum/xeno_caste/dragon
	name = "Dragon"
	desc = "A massive, ancient beast with scales that shimmer like polished armor. The fiercest and most formidable creature."
	icon = 'icons/Xeno/castes/dragon.dmi'
	icon_state = "Dragon Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	health = 850
	maxHealth = 850
	plasma_stored = 0
	pixel_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	initial_language_holder = /datum/language_holder/xeno/dragon
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/hijack,
	)
	xeno_flags = XENO_ROUNY // TODO: Get real sprites to use.

/mob/living/carbon/xenomorph/dragon/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/voice/alien/xenos_roaring.ogg', 75, 0)
	RegisterSignals(src, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(taking_damage))

/mob/living/carbon/xenomorph/dragon/death_cry()
	playsound(loc, 'sound/voice/alien/king_died.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/UnarmedAttack(atom/clicked_atom, has_proximity, modifiers)
	// The reason why this does not call parent is because a majority of them return FALSE despite doing their stuff successfully.
	// For now, we'll snowflake in some important things that must be attacked normally.
	// TODO: Let them hit/interact with stuff like lights, vendors, APCs, etc without having this snowflake stuff.
	if(istype(clicked_atom, /turf/closed/wall/resin) || istype(clicked_atom, /obj/structure/mineral_door/resin))
		return ..()
	if(isAPC(clicked_atom) || istype(clicked_atom, /obj/machinery/power/geothermal))
		return ..()
	if(!can_special_attack())
		return
	try_special_attack(clicked_atom)

/mob/living/carbon/xenomorph/dragon/RangedAttack(atom/clicked_atom, params)
	. = ..()
	if(!can_special_attack())
		return
	try_special_attack(clicked_atom)

/mob/living/carbon/xenomorph/dragon/proc/try_special_attack(atom/clicked_atom)
	face_atom(clicked_atom)

	var/turf/lower_left
	var/turf/upper_right
	switch(dir)
		if(NORTH)
			lower_left = locate(x - 1, y + 1, z)
			upper_right = locate(x + 1, y + 2, z)
		if(SOUTH)
			lower_left = locate(x - 1, y - 2, z)
			upper_right = locate(x + 1, y - 1, z)
		if(WEST)
			lower_left = locate(x - 2, y - 1, z)
			upper_right = locate(x - 1, y + 1, z)
		if(EAST)
			lower_left = locate(x + 1, y - 1, z)
			upper_right = locate(x + 2, y + 1, z)

	var/list/obj/effect/xeno/dragon_warning/telegraphed_atoms = list()
	var/turf/affected_turfs = block(lower_left, upper_right) // 2x3
	for(var/turf/affected_turf AS in affected_turfs)
		telegraphed_atoms += new /obj/effect/xeno/dragon_warning(affected_turf)

	ADD_TRAIT(src, TRAIT_IMMOBILE, XENO_TRAIT)
	var/was_successful = do_after(src, 1.2 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_DANGER) && can_special_attack()
	REMOVE_TRAIT(src, TRAIT_IMMOBILE, XENO_TRAIT)
	QDEL_LIST(telegraphed_atoms)
	if(!was_successful)
		return

	var/damage = xeno_caste.melee_damage * xeno_melee_damage_modifier
	var/played_sound = FALSE
	for(var/turf/affected_tile AS in block(lower_left, upper_right))
		for(var/atom/affected_atom AS in affected_tile)
			if(isxeno(affected_atom))
				continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				affected_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5)
				affected_living.knockback(src, 2, 2)
				if(!played_sound)
					played_sound = TRUE
					playsound(src, get_sfx(SFX_ALIEN_BITE), 50, 1)
				do_attack_animation(affected_living)
				visible_message(span_danger("\The [src] smacks [affected_living]!"), \
					span_danger("We smack [affected_living]!"), null, 5) // TODO: Better flavor.
				continue
			if(!isobj(affected_atom) || !(affected_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			var/obj/affected_obj = affected_atom
			if(isvehicle(affected_obj))
				if(ismecha(affected_obj))
					affected_obj.take_damage(damage * 3, BRUTE, MELEE, armour_penetration = 50, blame_mob = src)
					continue
				if(isarmoredvehicle(affected_obj) || ishitbox(affected_obj))
					affected_obj.take_damage(damage * 1/3, BRUTE, MELEE, blame_mob = src) // Adjusted for 3x3 multitile vehicles.
					continue
				affected_obj.take_damage(damage * 2, BRUTE, MELEE, blame_mob = src)
				continue
			affected_obj.take_damage(damage, BRUTE, MELEE, blame_mob = src)
	TIMER_COOLDOWN_START(src, COOLDOWN_DRAGON_BASIC_ATTACK, 4 SECONDS)

/// Reduces damage (after-armor) taken by half as long they have plasma. Will always consume at least 1 plasma if any damage is taken.
// TODO: This needs to be BEFORE-ARMOR. Look at overriding `apply_damage` to do this!
/mob/living/carbon/xenomorph/dragon/proc/taking_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || !plasma_stored || stat == DEAD || lying_angle)
		return
	var/damage_reduction = min(amount/2, plasma_stored)
	use_plasma(ROUND_UP(damage_reduction))
	amount_mod += damage_reduction

/// Checks if the dragon can start to perform the special attack.
/mob/living/carbon/xenomorph/dragon/proc/can_special_attack()
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return FALSE
	if(lying_angle)
		return FALSE
	if(do_actions)
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_DRAGON_BASIC_ATTACK))
		return FALSE
	return TRUE

/obj/effect/xeno/dragon_warning
	icon = 'icons/effects/effects.dmi'
	icon_state = "shallnotpass"
