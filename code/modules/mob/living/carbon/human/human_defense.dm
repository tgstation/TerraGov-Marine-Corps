/*
Contains most of the procs that are called when a mob is attacked by something
*/

//#define DEBUG_HUMAN_EXPLOSIONS

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(datum/limb/def_zone)
	if (!def_zone)
		return 1.0

	var/siemens_coefficient = 1

	if(species.species_flags & IS_INSULATED)
		siemens_coefficient = 0

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(istype(C) && (C.flags_armor_protection & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

/mob/living/carbon/human/proc/add_limb_armor(obj/item/armor_item)
	for(var/i in limbs)
		var/datum/limb/limb_to_check = i
		if(!(limb_to_check.body_part & armor_item.flags_armor_protection))
			continue
		limb_to_check.add_limb_soft_armor(armor_item.soft_armor)
		limb_to_check.add_limb_hard_armor(armor_item.hard_armor)


/mob/living/carbon/human/dummy/add_limb_armor(obj/item/armor_item)
	return


/mob/living/carbon/human/proc/remove_limb_armor(obj/item/armor_item)
	for(var/i in limbs)
		var/datum/limb/limb_to_check = i
		if(!(limb_to_check.body_part & armor_item.flags_armor_protection))
			continue
		limb_to_check.remove_limb_soft_armor(armor_item.soft_armor)
		limb_to_check.remove_limb_hard_armor(armor_item.hard_armor)


/mob/living/carbon/human/dummy/remove_limb_armor(obj/item/armor_item)
	return


/mob/living/carbon/human/proc/check_head_coverage()

	var/list/body_parts = list(head, wear_mask, wear_suit ) /* w_uniform, gloves, shoes*/ //We don't need to check these for heads.
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.flags_armor_protection & HEAD)
				return 1
	return 0


/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	for(var/datum/limb/O in limbs)
		if(O.limb_status & LIMB_DESTROYED)	continue
		O.emp_act(severity)
		for(var/datum/internal_organ/I in O.internal_organs)
			if(I.robotic == 0)	continue
			I.emp_act(severity)
	..()

/mob/living/carbon/human/has_smoke_protection()
	if(istype(wear_mask) && wear_mask.flags_inventory & BLOCKGASEFFECT)
		return TRUE
	if(istype(glasses) && glasses.flags_inventory & BLOCKGASEFFECT)
		return TRUE
	if(head && istype(head, /obj/item/clothing))
		var/obj/item/clothing/CH = head
		if(CH.flags_inventory & BLOCKGASEFFECT)
			return TRUE
	return ..()

/mob/living/carbon/human/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CAMO))
		smokecloak_on()

/mob/living/carbon/human/inhale_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING) && species.has_organ["lungs"])
		var/datum/internal_organ/lungs/L = internal_organs_by_name["lungs"]
		L?.take_damage(1, TRUE)


//Returns 1 if the attack hit, 0 if it missed.
/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user, def_zone)

	var/target_zone

	if(user == src) // Attacking yourself can't miss
		target_zone = user.zone_selected
	else
		target_zone = def_zone ? check_zone(def_zone) : get_zone_with_miss_chance(user.zone_selected, src)

	var/datum/limb/affecting = get_limb(target_zone)
	if(affecting.limb_status & LIMB_DESTROYED)
		to_chat(user, "What [affecting.display_name]?")
		log_combat(user, src, "attacked", I, "(FAILED: target limb missing) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")
		return FALSE
	var/hit_area = affecting.display_name

	var/damage = I.force + round(I.force * MELEE_SKILL_DAM_BUFF * user.skills.getRating(SKILL_MELEE_WEAPONS))
	if(user != src)
		damage = check_shields(COMBAT_MELEE_ATTACK, damage, "melee")
		if(!damage)
			log_combat(user, src, "attacked", I, "(FAILED: shield blocked) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")
			return TRUE

	var/applied_damage = modify_by_armor(damage, MELEE, I.penetration, target_zone)
	var/percentage_penetration = applied_damage / damage * 100
	var/attack_verb = LAZYLEN(I.attack_verb) ? pick(I.attack_verb) : "attacked"
	var/armor_verb
	switch(percentage_penetration)
		if(-INFINITY to 0)
			visible_message(span_danger("[src] has been [attack_verb] in the [hit_area] with [I.name] by [user], but the attack is deflected by [p_their()] armor!"),\
			null, null, COMBAT_MESSAGE_RANGE, visible_message_flags = COMBAT_MESSAGE)
			user.do_attack_animation(src, used_item = I)
			log_combat(user, src, "attacked", I, "(FAILED: armor blocked) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")
			return TRUE
		if(1 to 25)
			armor_verb = " [p_their(TRUE)] armor has deflected most of the blow!"
		if(26 to 50)
			armor_verb = " [p_their(TRUE)] armor has absorbed part of the impact!"
		if(51 to 75)
			armor_verb = " [p_their(TRUE)] armor has softened the hit!"

	visible_message(span_danger("[src] has been [attack_verb] in the [hit_area] with [I.name] by [user]![armor_verb]"),\
	null, null, 5, visible_message_flags = COMBAT_MESSAGE)

	var/weapon_sharp = is_sharp(I)
	var/weapon_edge = has_edge(I)
	if((weapon_sharp || weapon_edge) && !prob(modify_by_armor(100, MELEE, def_zone = target_zone)))
		weapon_sharp = FALSE
		weapon_edge = FALSE

	user.do_attack_animation(src, used_item = I)

	apply_damage(applied_damage, I.damtype, target_zone, 0, weapon_sharp, weapon_edge, updating_health = TRUE)

	var/list/hit_report = list("(RAW DMG: [damage])")

	var/bloody = 0
	if((I.damtype == BRUTE || I.damtype == STAMINA) && prob(damage * 2 + 25))
		if(!(affecting.limb_status & LIMB_ROBOT))
			I.add_mob_blood(src)	//Make the weapon bloody, not the person.
			if(prob(33))
				bloody = 1
				var/turf/location = loc
				if(istype(location, /turf))
					location.add_mob_blood(src)
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
						H.bloody_body(src)
						H.bloody_hands(src)


		switch(hit_area)
			if("head")//Harder to score a stun but if you do it lasts a bit longer
				if(prob(applied_damage - 5) && stat == CONSCIOUS)
					apply_effect(modify_by_armor(10 SECONDS, MELEE, def_zone = target_zone), WEAKEN)
					visible_message(span_danger("[src] has been knocked unconscious!"),
									span_danger("You have been knocked unconscious!"), null, 5)
					hit_report += "(KO)"

				if(bloody)//Apply blood
					if(wear_mask)
						wear_mask.add_mob_blood(src)
						update_inv_wear_mask(0)
					if(head)
						head.add_mob_blood(src)
						update_inv_head(0)
					if(glasses && prob(33))
						glasses.add_mob_blood(src)
						update_inv_glasses(0)

			if("chest")//Easier to score a stun but lasts less time
				if(prob((applied_damage + 5)) && !incapacitated())
					apply_effect(modify_by_armor(6 SECONDS, MELEE, def_zone = target_zone), WEAKEN)
					visible_message(span_danger("[src] has been knocked down!"),
									span_danger("You have been knocked down!"), null, 5)
					hit_report += "(KO)"

				if(bloody)
					bloody_body(src)

	//Melee weapon embedded object code.
	if(affecting.limb_status & LIMB_DESTROYED)
		hit_report += "(delimbed [affecting.display_name])"
	else if(I.damtype == BRUTE && !(HAS_TRAIT(I, TRAIT_NODROP) || (I.flags_item & DELONDROP)))
		if (percentage_penetration && weapon_sharp && prob(I.embedding.embed_chance))
			user.dropItemToGround(I, TRUE)
			I.embed_into(src, affecting)
			hit_report += "(embedded in [affecting.display_name])"

	record_melee_damage(user, applied_damage, affecting.limb_status & LIMB_DESTROYED)
	log_combat(user, src, "attacked", I, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)]) [hit_report.Join(" ")]")
	if(damage && !user.mind?.bypass_ff && !mind?.bypass_ff && user.faction == faction)
		var/turf/T = get_turf(src)
		user.ff_check(damage, src)
		log_ffattack("[key_name(user)] attacked [key_name(src)] with \the [I] in [AREACOORD(T)] [hit_report.Join(" ")].")
		msg_admin_ff("[ADMIN_TPMONTY(user)] attacked [ADMIN_TPMONTY(src)] with \the [I] in [ADMIN_VERBOSEJMP(T)] [hit_report.Join(" ")].")

	return TRUE

/mob/living/carbon/human/hitby(atom/movable/AM, speed = 5)
	var/mob/living/living_thrower
	if(isliving(AM.thrower))
		living_thrower = AM.thrower

	var/throw_damage
	var/list/hit_report = list()

	if(isliving(AM))
		var/mob/living/thrown_mob = AM
		if(thrown_mob.mob_size >= mob_size)
			throw_damage = (thrown_mob.mob_size + 1 - mob_size) * speed
			apply_damage(throw_damage, BRUTE, BODY_ZONE_CHEST, MELEE, updating_health = TRUE)
		if(thrown_mob.mob_size <= mob_size)
			thrown_mob.apply_damage(speed, BRUTE, BODY_ZONE_CHEST, MELEE, updating_health = TRUE)
		thrown_mob.stop_throw()

	else if(isitem(AM))
		var/obj/item/thrown_item = AM

		if(in_throw_mode && speed <= 5 && put_in_active_hand(thrown_item))
			thrown_item.throwing = FALSE //Caught in hand.
			visible_message(span_warning("[src] catches [thrown_item]!"), null, null, 5)
			throw_mode_off()
			if(living_thrower)
				log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: caught)")
			return TRUE

		throw_damage = thrown_item.throwforce * speed * 0.2

		var/zone
		if(living_thrower)
			zone = check_zone(living_thrower.zone_selected)
		else
			zone = ran_zone("chest", 75)	//Hits a random part of the body, geared towards the chest

		//check if we hit
		zone = get_zone_with_miss_chance(zone, src)

		if(!zone)
			visible_message(span_notice(" \The [thrown_item] misses [src] narrowly!"), null, null, 5)
			if(living_thrower)
				log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: missed)")
			return FALSE

		if(thrown_item.thrower != src)
			throw_damage = check_shields(COMBAT_MELEE_ATTACK, throw_damage, MELEE)
			if(!throw_damage)
				thrown_item.stop_throw()
				visible_message(span_danger("[src] deflects \the [thrown_item]!"))
				if(living_thrower)
					log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: shield blocked)")
				return TRUE

		var/datum/limb/affecting = get_limb(zone)

		if(affecting.limb_status & LIMB_DESTROYED)
			log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: target limb missing)")
			return FALSE

		thrown_item.stop_throw() // Hit the limb.
		var/applied_damage = modify_by_armor(throw_damage, MELEE, thrown_item.penetration, zone)

		if(applied_damage <= 0)
			visible_message(span_notice("\The [thrown_item] bounces on [src]'s armor!"), null, null, 5)
			log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: armor blocked)")
			return TRUE

		visible_message(span_warning("[src] has been hit in the [affecting.display_name] by \the [thrown_item]."), null, null, 5)

		apply_damage(applied_damage, thrown_item.damtype, zone, 0, is_sharp(thrown_item), has_edge(thrown_item), updating_health = TRUE)

		hit_report += "(RAW DMG: [throw_damage])"

		if(thrown_item.item_fire_stacks)
			fire_stacks += thrown_item.item_fire_stacks
			IgniteMob()
			hit_report += "(set ablaze)"

		//thrown weapon embedded object code.
		if(affecting.limb_status & LIMB_DESTROYED)
			hit_report += "(delimbed [affecting.display_name])"
		else if(thrown_item.damtype == BRUTE && is_sharp(thrown_item) && prob(thrown_item.embedding.embed_chance))
			thrown_item.embed_into(src, affecting)
			hit_report += "(embedded in [affecting.display_name])"

	if(AM.throw_source && speed >= 15)
		visible_message(span_warning(" [src] staggers under the impact!"),span_warning(" You stagger under the impact!"), null, null, 5)
		throw_at(get_edge_target_turf(src, get_dir(AM.throw_source, src)), 1, speed * 0.5)
		hit_report += "(thrown away)"

	if(living_thrower)
		log_combat(living_thrower, src, "thrown at", AM, "[hit_report.Join(" ")]")
		if(throw_damage && !living_thrower.mind?.bypass_ff && !mind?.bypass_ff && living_thrower.faction == faction)
			var/turf/T = get_turf(src)
			living_thrower.ff_check(throw_damage, src)
			log_ffattack("[key_name(living_thrower)] hit [key_name(src)] with \the [AM] (thrown) in [AREACOORD(T)] [hit_report.Join(" ")].")
			msg_admin_ff("[ADMIN_TPMONTY(living_thrower)] hit [ADMIN_TPMONTY(src)] with \the [AM] (thrown) in [ADMIN_VERBOSEJMP(T)] [hit_report.Join(" ")].")

	return TRUE


/mob/living/carbon/human/resist_fire(datum/source)
	spin(30, 1.5)
	return ..()


/mob/living/carbon/human/proc/bloody_hands(mob/living/source, amount = 2)
	if (istype(gloves))
		gloves.add_mob_blood(source)
		gloves.transfer_blood = amount
	else
		var/b_color = source.get_blood_color()

		if(b_color)
			blood_color = b_color
		bloody_hands = amount

	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves


/mob/living/carbon/human/proc/bloody_body(mob/living/source)
	if(wear_suit)
		wear_suit.add_mob_blood(source)
		update_inv_wear_suit()
	if(w_uniform)
		w_uniform.add_mob_blood(source)
		update_inv_w_uniform()


/**
 * This looks for a an ID on a person and checkes if an access tag from their ID matches the provided access tag. Used with the gun, claymore, sentry and possibly other IFF code.
 * Does not actually check for station jobs.
 */
/mob/living/carbon/human/proc/get_target_lock(list/unique_access)
	var/obj/item/card/id/C = wear_id
	if(!istype(C)) C = get_active_held_item()
	if(!istype(C)) return
	for(var/access_tag in unique_access)
		if(access_tag in C.access)
			return TRUE

/mob/living/carbon/human/screech_act(mob/living/carbon/xenomorph/queen/Q, screech_range = WORLD_VIEW, within_sight = TRUE)
	var/dist_pct = get_dist(src, Q) / screech_range

	// Intensity is reduced by a 80% if you can't see the queen. Hold orders will reduce by an extra 10% per rank.
	var/reduce_within_sight = within_sight ? 1 : 0.2
	var/reduce_prot_aura = protection_aura * 0.1

	var/reduction = max(min(1, reduce_within_sight - reduce_prot_aura), 0.1) // Capped at 90% reduction
	var/stun_duration = (LERP(1, 0.4, dist_pct) * reduction) * 20 //Max 1.5 beside Queen, 0.4 at the edge.

	to_chat(src, span_danger("An ear-splitting guttural roar tears through your mind and makes your world convulse!"))
	Stun(stun_duration)
	Paralyze(stun_duration)
	//15 Next to queen , 3 at max distance.
	adjust_stagger(LERP(7, 3, dist_pct) * reduction SECONDS)
	//Max 140 under Queen, 130 beside Queen, 70 at the edge. Reduction of 10 per tile distance from Queen.
	apply_damage(LERP(140, 70, dist_pct) * reduction, STAMINA, updating_health = TRUE)
	if(!ear_deaf)
		adjust_ear_damage(deaf = stun_duration)  //Deafens them temporarily
	//Perception distorting effects of the psychic scream*

/mob/living/carbon/human/attackby(obj/item/I, mob/living/user, params)
	if(stat != DEAD || I.sharp < IS_SHARP_ITEM_ACCURATE || user.a_intent != INTENT_HARM)
		return ..()
	if(!internal_organs_by_name["heart"])
		to_chat(user, span_notice("[src] no longer has a heart."))
		return
	if(!HAS_TRAIT(src, TRAIT_UNDEFIBBABLE))
		to_chat(user, span_warning("You cannot resolve yourself to destroy [src]'s heart, as [p_they()] can still be saved!"))
		return
	to_chat(user, span_notice("You start to remove [src]'s heart, preventing [p_them()] from rising again!"))
	if(!do_after(user, 2 SECONDS, NONE, src))
		return
	if(!internal_organs_by_name["heart"])
		to_chat(user, span_notice("The heart is no longer here!"))
		return
	log_combat(user, src, "ripped [src]'s heart", I)
	visible_message(span_notice("[user] ripped off [src]'s heart!"), span_notice("You ripped off [src]'s heart!"))
	internal_organs_by_name -= "heart"
	var/obj/item/organ/heart/heart = new
	heart.die()
	user.put_in_hands(heart)
	chestburst = 2
	update_burst()

/mob/living/carbon/human/welder_act(mob/living/user, obj/item/I)
	. = ..()

	if(user.a_intent != INTENT_HELP)
		return ..()

	var/datum/limb/affecting = user.client.prefs.toggles_gameplay & RADIAL_MEDICAL ? radial_medical(src, user) : get_limb(user.zone_selected)

	if(!affecting)
		return TRUE

	if(!(affecting.limb_status & LIMB_ROBOT))
		balloon_alert(user, "Limb not robotic")
		return TRUE

	if(!affecting.brute_dam)
		balloon_alert(user, "Nothing to fix!")
		return TRUE

	if(user.do_actions)
		balloon_alert(user, "Already busy!")
		return TRUE

	if(!I.tool_use_check(user, 2))
		return TRUE

	var/repair_time = 1 SECONDS
	if(src == user)
		repair_time *= 3


	user.visible_message(span_notice("[user] starts to fix some of the dents on [src]'s [affecting.display_name]."),\
		span_notice("You start fixing some of the dents on [src == user ? "your" : "[src]'s"] [affecting.display_name]."))

	add_overlay(GLOB.welding_sparks)
	while(do_after(user, repair_time, NONE, src, BUSY_ICON_BUILD) && I.use_tool(src, user, volume = 50, amount = 2))
		user.visible_message(span_warning("\The [user] patches some dents on [src]'s [affecting.display_name]."), \
			span_warning("You patch some dents on \the [src]'s [affecting.display_name]."))
		if(affecting.heal_limb_damage(15, robo_repair = TRUE, updating_health = TRUE))
			UpdateDamageIcon()
		if(!I.tool_use_check(user, 2))
			break
		if(!affecting.brute_dam)
			var/previous_limb = affecting
			for(var/datum/limb/checked_limb AS in limbs)
				if(!(checked_limb.limb_status & LIMB_ROBOT))
					continue
				if(!checked_limb.brute_dam)
					continue
				affecting = checked_limb
				break
			if(previous_limb == affecting)
				balloon_alert(user, "Dents fully repaired.")
				break
	cut_overlay(GLOB.welding_sparks)
	return TRUE
