
/// Those structures need time to grow and are supposed to be extremely weak health-wise.

/obj/structure/xeno/plant
	name = "xeno plant"
	icon = 'icons/Xeno/plants.dmi'
	interaction_flags = INTERACT_CHECK_INCAPACITATED
	max_integrity = 5
	/// The plant's icon once it's fully grown?
	var/mature_icon_state
	/// Is the plant ready to be used?
	var/mature = FALSE
	/// How long does it take for the plant to be usable?
	var/maturation_time = 2 MINUTES
	/// The timer ID associated with maturity.
	var/maturation_timer
	/// Can this plant be picked up by a xenomorph? If so, what is the item typepath to be spawned?
	var/obj/item/xenomorph_plant/itemized_typepath = null

/obj/structure/xeno/plant/Initialize(mapload, _hivenumber, _mature)
	. = ..()
	mature = _mature
	if(!mature)
		maturation_timer = addtimer(CALLBACK(src, PROC_REF(on_mature)), maturation_time)

/obj/structure/xeno/plant/Destroy()
	. = ..()
	if(maturation_timer)
		deltimer(maturation_timer)
		maturation_timer = null

/obj/structure/xeno/plant/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if((user.status_flags & INCORPOREAL))
		return FALSE
	if(!mature && isxeno(user))
		balloon_alert(user, "not fully grown!")
		return FALSE

/obj/structure/xeno/plant/update_icon_state()
	. = ..()
	icon_state = mature ? mature_icon_state : initial(icon_state)

/obj/structure/xeno/plant/attack_hand(mob/living/user)
	if(!can_interact(user))
		return ..()
	try_use(user)
	return TRUE

/obj/structure/xeno/plant/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!can_interact(xeno_attacker))
		return ..()
	if(xeno_attacker.a_intent == INTENT_HARM && (xeno_attacker.xeno_caste.caste_flags & CASTE_IS_BUILDER))
		balloon_alert(xeno_attacker, "uprooted the plant!")
		xeno_attacker.do_attack_animation(src)
		deconstruct(TRUE)
		return TRUE
	try_use(xeno_attacker)
	return TRUE

/obj/structure/xeno/plant/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(usr != over || !itemized_typepath || !isxeno(over) || !can_interact(over))
		return ..()
	var/mob/living/carbon/xenomorph/xenomorph_user = over
	if(!(xenomorph_user.xeno_caste.caste_flags & CASTE_IS_BUILDER))
		return ..() // Their claws aren't delicate enough for these plants.

	balloon_alert(xenomorph_user, "gently uprooting...")
	if(!do_after(xenomorph_user, 2 SECONDS, NONE, src))
		return TRUE

	var/obj/item/itemized_item = new itemized_typepath(drop_location())
	xenomorph_user.put_in_active_hand(itemized_item)
	deconstruct(TRUE)
	return TRUE

/// Called when someone is trying to interact with the plant, xenomorph or not.
/// Returns TRUE if something happened.
/obj/structure/xeno/plant/proc/try_use(mob/user)
	balloon_alert(user, isxeno(user) ? "consuming..." : "touching...")
	if(!do_after(user, 2 SECONDS, IGNORE_HELD_ITEM, src))
		return FALSE
	return on_use(user)

/// Called whenever someone successfully interacts with the plant, xenomorph or not.
/// Returns TRUE if something happened.
/obj/structure/xeno/plant/proc/on_use(mob/user)
	mature = FALSE
	update_icon()
	maturation_timer = addtimer(CALLBACK(src, PROC_REF(on_mature)), maturation_time)
	return TRUE

/// Called when the plant reaches maturity.
/obj/structure/xeno/plant/proc/on_mature(mob/user)
	mature = TRUE
	update_icon()
	if(maturation_timer)
		deltimer(maturation_timer)
		maturation_timer = null
	playsound(src, SFX_ALIEN_RESIN_BUILD, 25, FALSE, MEDIUM_SOUND_RANGE)

/obj/structure/xeno/plant/heal_fruit
	name = "life fruit"
	desc = "It would almost be appetizing wasn't it for the green colour and the shifting fluids inside..."
	icon_state = "heal_fruit_immature"
	mature_icon_state = "heal_fruit"
	itemized_typepath = /obj/item/xenomorph_plant/healing
	/// Minimum amount of health recovered.
	var/healing_amount_min = 125
	/// Maximum amount of health recovered, depends on the xeno's max health.
	var/healing_amount_max_health_scaling = 0.5

/obj/structure/xeno/plant/heal_fruit/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	if(!disassembled && mature)
		var/datum/effect_system/smoke_spread/xeno/acid/light/plant_explosion = new(get_turf(src))
		plant_explosion.set_up(1, src)
		plant_explosion.start()
		visible_message(span_danger("[src] bursts, releasing toxic gas!"))
	return ..()

/obj/structure/xeno/plant/heal_fruit/on_use(mob/user)
	if(!isxeno(user))
		deconstruct(FALSE)
		return TRUE

	var/mob/living/carbon/xenomorph/xenomorph_user = user
	var/heal_amount = max(healing_amount_min, healing_amount_max_health_scaling * xenomorph_user.xeno_caste.max_health)
	HEAL_XENO_DAMAGE(xenomorph_user, heal_amount, FALSE)
	playsound(xenomorph_user, SFX_ALIEN_DROOL, 25, FALSE, MEDIUM_SOUND_RANGE)
	balloon_alert(xenomorph_user, "health restored!")
	to_chat(xenomorph_user, span_xenowarning("We feel a sudden soothing chill as [src] tends to our wounds."))
	return ..()

/obj/structure/xeno/plant/armor_fruit
	name = "hard fruit"
	desc = "The contents of this fruit are protected by a tough outer shell."
	icon_state = "armor_fruit_immature"
	mature_icon_state = "armor_fruit"
	itemized_typepath = /obj/item/xenomorph_plant/armor
	/// How much total sunder should we remove?
	var/sunder_removal = 30

/obj/structure/xeno/plant/armor_fruit/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	if(!disassembled && mature)
		for(var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, 1))
			var/turf/far_away_lands = get_turf(nearby_human)
			var/direction = get_dir(src, nearby_human) == NONE ? REVERSE_DIR(nearby_human.dir) : get_dir(src, nearby_human)
			for(var/x in 1 to 20)
				var/turf/next_turf = get_step(far_away_lands, direction)
				if(!next_turf)
					break
				far_away_lands = next_turf

			to_chat(nearby_human, span_warning("[src] bursts, releasing a strong gust of pressurised gas!"))
			nearby_human.throw_at(far_away_lands, 7, spin = TRUE)
			nearby_human.adjust_stagger(1.5 SECONDS)
			nearby_human.apply_damage(15, BRUTE, "chest", BOMB, attacker = blame_mob)
	return ..()

/obj/structure/xeno/plant/armor_fruit/on_use(mob/user)
	if(!isxeno(user))
		deconstruct(FALSE)
		return TRUE

	var/mob/living/carbon/xenomorph/xenomorph_user = user
	xenomorph_user.adjust_sunder(-sunder_removal)
	playsound(xenomorph_user, SFX_ALIEN_DROOL, 25, FALSE, MEDIUM_SOUND_RANGE)
	balloon_alert(xenomorph_user, "armor restored!")
	to_chat(xenomorph_user, span_xenowarning("We shed our shattered scales as new ones grow to replace them!"))
	return ..()

/obj/structure/xeno/plant/plasma_fruit
	name = "power fruit"
	desc = "A cyan fruit, beating like a creature's heart"
	icon_state = "plasma_fruit_immature"
	mature_icon_state = "plasma_fruit"
	itemized_typepath = /obj/item/xenomorph_plant/plasma
	/// How much bonus plasma should we restore during the duration? 1 being 100% from base regen
	var/bonus_regen = 1
	///How long should the buff last
	var/duration = 1 MINUTES

/obj/structure/xeno/plant/plasma_fruit/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	if(!disassembled && mature)
		var/datum/effect_system/smoke_spread/xeno/pyrogen_fire/light/plant_explosion = new(get_turf(src))
		plant_explosion.set_up(1, src)
		plant_explosion.start()
		visible_message(span_warning("[src] bursts, releasing blue hot gas!"))
	return ..()

/obj/structure/xeno/plant/plasma_fruit/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(!isxeno(user))
		return
	var/mob/living/carbon/xenomorph/xenomorph_user = user
	if(xenomorph_user.has_status_effect(STATUS_EFFECT_PLASMA_SURGE))
		balloon_alert(xenomorph_user, "already increased plasma regen!")
		return FALSE

/obj/structure/xeno/plant/plasma_fruit/on_use(mob/user)
	if(!isxeno(user))
		deconstruct(FALSE)
		return TRUE
	var/mob/living/carbon/xenomorph/xenomorph_user = user
	if(!(xenomorph_user.xeno_caste.can_flags & CASTE_CAN_BE_GIVEN_PLASMA))
		to_chat(xenomorph_user, span_xenowarning("But our body rejects the fruit, we do not share the same plasma type!"))
		return FALSE

	xenomorph_user.apply_status_effect(STATUS_EFFECT_PLASMA_SURGE, xenomorph_user.xeno_caste.plasma_max, bonus_regen, duration)
	playsound(xenomorph_user, SFX_ALIEN_DROOL, 25, FALSE, MEDIUM_SOUND_RANGE)
	balloon_alert(xenomorph_user, "plasma restored!")
	to_chat(xenomorph_user, span_xenowarning("[src] restores our plasma reserves. Our organism is on overdrive!"))
	return ..()

/obj/structure/xeno/plant/stealth_plant
	name = "night shade"
	desc = "A beautiful flower, what purpose it could serve to the alien hive is beyond you however..."
	icon_state = "stealth_plant_immature"
	mature_icon_state = "stealth_plant"
	maturation_time = 4 MINUTES
	/// The radius of the passive structure camouflage. This requires line of sight.
	var/camouflage_range = 7
	/// The range of the active stealth ability. This does not require line of sight.
	var/active_camouflage_pulse_range = 10
	/// How long should veil last?
	var/active_camouflage_duration = 20 SECONDS
	/// How long until the plant can be activated again?
	var/cooldown = 2 MINUTES
	/// Is the active ability veil on cooldown?
	var/on_cooldown = FALSE
	/// The list of passively camouflaged structures.
	var/list/obj/structure/xeno/camouflaged_structures = list()
	/// The list of actively camouflaged xenos by veil.
	var/list/mob/living/carbon/xenomorph/camouflaged_xenos = list()

/obj/structure/xeno/plant/stealth_plant/Destroy()
	for(var/obj/structure/xeno/xeno_structure AS in camouflaged_structures)
		xeno_structure.remove_alpha_source(ALPHA_SOURCE_NIGHTSHADE)
	unveil()
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/plant/stealth_plant/process()
	for(var/turf/tile AS in RANGE_TURFS(camouflage_range, loc))
		for(var/obj/structure/xeno/xeno_structure in tile)
			if(istype(xeno_structure, /obj/structure/xeno/plant) || !line_of_sight(src, xeno_structure)) // We don't hide plants.
				continue
			xeno_structure.set_alpha_source(ALPHA_SOURCE_NIGHTSHADE, STEALTH_PLANT_PASSIVE_CAMOUFLAGE_ALPHA)
			camouflaged_structures.Add(xeno_structure)

/// Called when someone is trying to interact with the plant, xenomorph or not.
/obj/structure/xeno/plant/stealth_plant/try_use(mob/user)
	if(ishuman(user))
		balloon_alert(user, "nothing happens!")
		to_chat(user, span_notice("You caress [src]'s petals, nothing happens."))
		return FALSE
	if(on_cooldown)
		balloon_alert(user, "not ready yet!")
		to_chat(user, span_xenowarning("[src] soft light shimmers, we should give it more time to recover!"))
		return FALSE
	balloon_alert(user, "shaking...")
	if(!do_after(user, 2 SECONDS, IGNORE_HELD_ITEM, src))
		return FALSE
	on_use(user)
	return TRUE

/obj/structure/xeno/plant/stealth_plant/on_use(mob/user)
	visible_message(span_danger("[src] releases a burst of glowing pollen!"))
	veil()
	return TRUE

/obj/structure/xeno/plant/stealth_plant/on_mature(mob/user)
	. = ..()
	START_PROCESSING(SSslowprocess, src)

/// Cloaks all nearby xenomorphs.
/obj/structure/xeno/plant/stealth_plant/proc/veil()
	for(var/turf/tile in RANGE_TURFS(camouflage_range, loc))
		for(var/mob/living/carbon/xenomorph/nearby_xenomorph in tile)
			if(nearby_xenomorph.stat == DEAD || isxenohunter(nearby_xenomorph) || nearby_xenomorph.alpha != 255) //We don't mess with xenos capable of going stealth by themselves
				continue
			nearby_xenomorph.set_alpha_source(ALPHA_SOURCE_NIGHTSHADE, HUNTER_STEALTH_RUN_ALPHA)
			camouflaged_xenos.Add(nearby_xenomorph)
			new /obj/effect/temp_visual/alien_fruit_eaten(get_turf(nearby_xenomorph))
			balloon_alert(nearby_xenomorph, "blending in!")
			to_chat(nearby_xenomorph, span_xenowarning("The pollen from [src] reacts with our scales, we are blending with our surroundings!"))
	on_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(unveil)), active_camouflage_duration)
	addtimer(CALLBACK(src, PROC_REF(ready)), cooldown)

/// Makes us ready to be used again.
/obj/structure/xeno/plant/stealth_plant/proc/ready()
	visible_message(span_danger("[src] petals shift in hue, it is ready to release more pollen."))
	on_cooldown = FALSE

/// Uncloaks all the xenomorphs that we previously cloaked.
/obj/structure/xeno/plant/stealth_plant/proc/unveil()
	for(var/mob/living/carbon/xenomorph/cloaked_xenomorph AS in camouflaged_xenos)
		cloaked_xenomorph.remove_alpha_source(ALPHA_SOURCE_NIGHTSHADE)
		balloon_alert(cloaked_xenomorph, "effect wears off!")
		to_chat(cloaked_xenomorph, span_xenowarning("The effect of [src] wears off!"))
	camouflaged_xenos.Cut()

/obj/item/xenomorph_plant
	name = "xenomorph plant"
	desc = "A strange fruit that you could eat... if you REALLY wanted to. Its roots seem to twitch every so often."
	icon = 'icons/Xeno/plants.dmi'
	icon_state = "fruit_greater_item"
	/// The type of the plant that we're based on.
	var/obj/structure/xeno/plant/plant_type = /obj/structure/xeno/plant

/obj/item/xenomorph_plant/Initialize(mapload)
	. = ..()
	name = plant_type::name
	desc = plant_type::desc

/obj/item/xenomorph_plant/attack_self(mob/user)
	if(user.status_flags & INCORPOREAL)
		return FALSE
	balloon_alert(user, isxeno(user) ? "consuming..." : "crushing...")
	if(!do_after(user, 2 SECONDS, NONE, src))
		return TRUE
	use_plant_on(user)
	qdel(src)
	return TRUE

/obj/item/xenomorph_plant/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE
	// Builders can pick it up.
	if(xeno_attacker.xeno_caste.caste_flags & CASTE_IS_BUILDER)
		return attack_hand(xeno_attacker)
	// Everyone else will eat it off the floor.
	balloon_alert(xeno_attacker, "consuming...")
	if(!do_after(xeno_attacker, 2 SECONDS, NONE, src))
		return TRUE
	use_plant_on(xeno_attacker)
	qdel(src)
	return TRUE

/obj/item/xenomorph_plant/preattack(atom/target, mob/user, params)
	if(target == user)
		return attack_self(user)
	if(user.status_flags & INCORPOREAL)
		return FALSE

	if(isxeno(user) && istype(target, /obj/alien/weeds))
		var/turf/target_turf = get_turf(target)
		if(!target_turf.check_alien_construction(user, TRUE, plant_type)) // Will give a message if it failed.
			return TRUE
		balloon_alert(user, "planting...")
		if(!do_after(user, 2 SECONDS, IGNORE_HELD_ITEM, src))
			return TRUE
		playsound(src, SFX_ALIEN_RESIN_BUILD, 25, FALSE, MEDIUM_SOUND_RANGE)
		new plant_type(target_turf) // Cost of being moved is having to go through maturity again.
		qdel(src)
		return TRUE

	if(isxeno(target))
		balloon_alert_to_viewers("feeding...")
		if(!do_after(user, 2 SECONDS, NONE, target))
			return TRUE
		use_plant_on(target)
		qdel(src)
		return TRUE

	return FALSE

/obj/item/xenomorph_plant/deconstruct(disassembled, mob/living/blame_mob)
	if(!disassembled)
		var/obj/structure/xeno/plant/exploding_plant = new plant_type(get_turf(src), null, TRUE)
		exploding_plant.deconstruct(FALSE)
	return ..()

/obj/item/xenomorph_plant/stop_throw(flying, original_layer)
	. = ..()
	if(isturf(loc)) // Someone caught us.
		deconstruct(FALSE)

/// Creates and then immediately uses the plant on a mob.
/obj/item/xenomorph_plant/proc/use_plant_on(mob/user)
	var/obj/structure/xeno/plant/used_plant = new plant_type(get_turf(src), null, TRUE)
	used_plant.on_use(user)
	if(!QDELETED(used_plant)) // Xenomorph use won't automatically delete it, so we have to delete it here.
		used_plant.deconstruct(TRUE)

/obj/item/xenomorph_plant/healing
	plant_type = /obj/structure/xeno/plant/heal_fruit

/obj/item/xenomorph_plant/armor
	icon_state = "fruit_armor_item"
	plant_type = /obj/structure/xeno/plant/armor_fruit

/obj/item/xenomorph_plant/plasma
	icon_state = "fruit_plasma_item"
	plant_type = /obj/structure/xeno/plant/plasma_fruit
