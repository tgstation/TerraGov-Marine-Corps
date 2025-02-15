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
	/// The created effects that need to be deleted later.
	var/list/obj/effect/xeno/dragon_warning/telegraphed_atoms

/mob/living/carbon/xenomorph/dragon/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/voice/alien/xenos_roaring.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/death_cry()
	playsound(loc, 'sound/voice/alien/king_died.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/UnarmedAttack(atom/clicked_atom, has_proximity, modifiers)
	if(!can_attack())
		return

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

	LAZYINITLIST(telegraphed_atoms)
	var/turf/affected_turfs = block(lower_left, upper_right) // 2x3
	for(var/turf/affected_turf AS in affected_turfs)
		telegraphed_atoms += new /obj/effect/xeno/dragon_warning(affected_turf)

	ADD_TRAIT(src, TRAIT_IMMOBILE, XENO_TRAIT)
	var/was_successful = do_after(src, 0.6 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_DANGER, prog_bar = null) && can_attack()
	REMOVE_TRAIT(src, TRAIT_IMMOBILE, XENO_TRAIT)
	QDEL_LIST(telegraphed_atoms)
	if(!was_successful)
		return

	var/damage = xeno_caste.melee_damage * xeno_melee_damage_modifier
	for(var/turf/affected_tile AS in block(lower_left, upper_right))
		for(var/atom/affected_atom AS in affected_tile)
			if(isxeno(affected_atom))
				continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				affected_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5)
				affected_living.knockback(src, 2, 2)
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

/// Checks if the dragon can start to perform an attack.
/mob/living/carbon/xenomorph/dragon/proc/can_attack()
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return FALSE
	if(do_actions)
		return FALSE

/obj/effect/xeno/dragon_warning
	icon = 'icons/effects/effects.dmi'
	icon_state = "shallnotpass"
