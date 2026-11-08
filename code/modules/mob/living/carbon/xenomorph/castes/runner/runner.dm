/mob/living/carbon/xenomorph/runner
	caste_base_type = /datum/xeno_caste/runner
	name = "Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon = 'icons/Xeno/castes/runner.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	bubble_icon = "alienleft"
	health = 100
	maxHealth = 100
	plasma_stored = 50
	pass_flags = PASS_LOW_STRUCTURE
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -16  //Needed for 2x2
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/runner/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_LIGHT_STEP, XENO_TRAIT)

/mob/living/carbon/xenomorph/runner/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER

/mob/living/carbon/xenomorph/runner/UnarmedAttack(atom/A, has_proximity, modifiers)
	/// Runner should not be able to slash while evading.
	var/datum/action/ability/xeno_action/evasion/evasion_action = actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(evasion_action?.evade_active)
		balloon_alert(src, "Cannot slash while evading")
		return
	return ..()

/mob/living/carbon/xenomorph/runner/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!ishuman(over))
		return
	if(!back)
		balloon_alert(over,"This runner isn't wearing a saddle!")
		return
	if(!do_after(over, 3 SECONDS, NONE, src))
		return
	var/obj/item/storage/backpack/marine/duffelbag/xenosaddle/saddle = back
	dropItemToGround(saddle,TRUE)

/mob/living/carbon/xenomorph/runner/can_mount(mob/living/user, target_mounting = FALSE)
	. = ..()
	if(!target_mounting)
		user = pulling
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_pulled = user
	if(human_pulled.stat == DEAD)
		return FALSE
	if(!istype(back, /obj/item/storage/backpack/marine/duffelbag/xenosaddle)) //cant ride without a saddle
		return FALSE
	return TRUE

/mob/living/carbon/xenomorph/runner/resisted_against(datum/source)
	user_unbuckle_mob(source, source)

/mob/living/carbon/xenomorph/runner/melter
	caste_base_type = /datum/xeno_caste/runner/melter
	/// What type of damage should the second instance do?
	var/second_damage_type = BRUTE
	/// What armor is the second instance of damage calculated against?
	var/second_damage_armor = MELEE
	/// The amount of melting acid stacks to be applied.
	var/applied_acid_stacks = 2

/mob/living/carbon/xenomorph/runner/melter/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_XENOMORPH_ATTACK_OBJ, PROC_REF(on_attack_obj))
	RegisterSignal(src, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack_living))

/mob/living/carbon/xenomorph/runner/melter/death(gibbing, deathmessage, silent)
	for(var/turf/acid_tile AS in RANGE_TURFS(2, loc))
		if(!line_of_sight(loc, acid_tile))
			continue
		xenomorph_spray(acid_tile, 6 SECONDS, 16, src, TRUE, TRUE)
	return ..()

/// Deals a second instance of melee damage to damageable objects. Damage type and armor type may vary.
/mob/living/carbon/xenomorph/runner/melter/proc/on_attack_obj(mob/living/carbon/xenomorph/source, obj/target)
	SIGNAL_HANDLER
	if(target.resistance_flags & XENO_DAMAGEABLE)
		target.take_damage(xeno_caste.melee_damage * xeno_melee_damage_modifier, second_damage_type, second_damage_armor)

/// Deals a second instance of melee damage to living beings. Damage type and armor type may vary.
/mob/living/carbon/xenomorph/runner/melter/proc/on_postattack_living(mob/living/carbon/xenomorph/source, mob/living/target, damage)
	SIGNAL_HANDLER
	target.apply_damage(xeno_caste.melee_damage * xeno_melee_damage_modifier, second_damage_type, null, second_damage_armor, attacker = src)
	var/datum/status_effect/stacking/melting_acid/debuff = target.has_status_effect(STATUS_EFFECT_MELTING_ACID)
	if(!debuff)
		target.apply_status_effect(STATUS_EFFECT_MELTING_ACID, applied_acid_stacks)
		return
	debuff.add_stacks(applied_acid_stacks)
