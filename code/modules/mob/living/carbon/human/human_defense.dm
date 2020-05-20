/*
Contains most of the procs that are called when a mob is attacked by something
*/

//#define DEBUG_HUMAN_EXPLOSIONS

/mob/living/carbon/human/stun_effect_act(stun_amount, agony_amount, def_zone)
	var/datum/limb/affected = get_limb(check_zone(def_zone))
	var/siemens_coeff = get_siemens_coefficient_organ(affected)
	stun_amount *= siemens_coeff
	agony_amount *= siemens_coeff

	switch (def_zone)
		if("head")
			agony_amount *= 1.50
		if("l_hand", "r_hand")
			var/c_hand
			if (def_zone == "l_hand")
				c_hand = l_hand
			else
				c_hand = r_hand

			if(c_hand && (stun_amount || agony_amount > 10))

				dropItemToGround(c_hand)
				if (affected.limb_status & LIMB_ROBOT)
					emote("me", 1, "drops what they were holding, their [affected.display_name] malfunctioning!")
				else
					var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
					emote("me", 1, "[(species && species.species_flags & NO_PAIN) ? "" : emote_scream ] drops what they were holding in their [affected.display_name]!")

	return ..()


/mob/living/carbon/human/getarmor(def_zone, type)
	var/armorval = 0
	var/total = 0

	if(def_zone)
		if(isorgan(def_zone))
			return getarmor_organ(def_zone, type)
		var/datum/limb/affecting = get_limb(def_zone)
		return getarmor_organ(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	else
		for(var/X in limbs)
			var/datum/limb/E = X
			var/weight = GLOB.organ_rel_size[E.name]
			armorval += getarmor_organ(E, type) * weight
			total += weight
			#ifdef DEBUG_HUMAN_EXPLOSIONS
			to_chat(src, "DEBUG getarmor: total: [total], armorval: [armorval], weight: [weight], name: [E.name]")
			#endif
	return round(armorval / max(total, 1), 1)

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(datum/limb/def_zone)
	if (!def_zone)
		return 1.0

	var/siemens_coefficient = 1.0

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


///This proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(datum/limb/affected_limb, type)
	return affected_limb.soft_armor.getRating(type)


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
		target_zone = def_zone? check_zone(def_zone) : get_zone_with_miss_chance(user.zone_selected, src)

	var/datum/limb/affecting = get_limb(target_zone)
	if(affecting.limb_status & LIMB_DESTROYED)
		to_chat(user, "What [affecting.display_name]?")
		log_combat(user, src, "attacked", I, "(FAILED: target limb missing) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")
		return FALSE
	var/hit_area = affecting.display_name

	var/damage = I.force + round(I.force * 0.3 * user.skills.getRating("melee_weapons")) //30% bonus per melee level
	if(user != src)
		damage = check_shields(COMBAT_MELEE_ATTACK, damage, "melee")
		if(!damage)
			log_combat(user, src, "attacked", I, "(FAILED: shield blocked) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")
			return TRUE

	var/armor = run_armor_check(affecting, "melee")
	var/attack_verb = LAZYLEN(I.attack_verb) ? pick(I.attack_verb) : "attacked"
	var/armor_verb
	switch(armor)
		if(100 to INFINITY)
			visible_message("<span class='danger'>[src] has been [attack_verb] in the [hit_area] with [I.name] by [user], but the attack is deflected by [p_their()] armor!</span>", null, null, COMBAT_MESSAGE_RANGE)
			user.do_attack_animation(src, used_item = I)
			log_combat(user, src, "attacked", I, "(FAILED: armor blocked) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")
			return TRUE
		if(-INFINITY to 25)//Nothing
		if(25 to 50)
			armor_verb = " [p_their(TRUE)] armor has softened the hit!"
		if(50 to 75)
			armor_verb = " [p_their(TRUE)] armor has absorbed part of the impact!"
		if(75 to 100)
			armor_verb = " [p_their(TRUE)] armor has deflected most of the blow!"
	
	visible_message("<span class='danger'>[src] has been [attack_verb] in the [hit_area] with [I.name] by [user]![armor_verb]</span>", null, null, 5)

	var/weapon_sharp = is_sharp(I)
	var/weapon_edge = has_edge(I)
	if((weapon_sharp || weapon_edge) && prob(getarmor(target_zone, "melee")))
		weapon_sharp = FALSE
		weapon_edge = FALSE

	user.do_attack_animation(src, used_item = I)

	apply_damage(damage, I.damtype, affecting, armor, weapon_sharp, weapon_edge)
	UPDATEHEALTH(src)

	var/list/hit_report = list("(RAW DMG: [damage])")

	var/bloody = 0
	if((I.damtype == BRUTE || I.damtype == HALLOSS) && prob(damage * 2 + 25))
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
				if(prob(damage) && stat == CONSCIOUS)
					apply_effect(20, PARALYZE, armor)
					visible_message("<span class='danger'>[src] has been knocked unconscious!</span>",
									"<span class='danger'>You have been knocked unconscious!</span>", null, 5)
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
				if(prob((damage + 10)) && !incapacitated())
					apply_effect(6, WEAKEN, armor)
					visible_message("<span class='danger'>[src] has been knocked down!</span>",
									"<span class='danger'>You have been knocked down!</span>", null, 5)
					hit_report += "(KO)"

				if(bloody)
					bloody_body(src)

	//Melee weapon embedded object code.
	if(affecting.limb_status & LIMB_DESTROYED)
		hit_report += "(delimbed [affecting.display_name])"
	else if(I.damtype == BRUTE && !(I.flags_item & (NODROP|DELONDROP)))
		if (!armor && weapon_sharp && prob(I.embedding.embed_chance))
			I.embed_into(src, affecting)
			hit_report += "(embedded in [affecting.display_name])"

	log_combat(user, src, "attacked", I, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)]) [hit_report.Join(" ")]")
	if(damage && !user.mind?.bypass_ff && !mind?.bypass_ff && user.faction == faction)
		var/turf/T = get_turf(src)
		log_ffattack("[key_name(user)] attacked [key_name(src)] with \the [I] in [AREACOORD(T)] [hit_report.Join(" ")].")
		msg_admin_ff("[ADMIN_TPMONTY(user)] attacked [ADMIN_TPMONTY(src)] with \the [I] in [ADMIN_VERBOSEJMP(T)] [hit_report.Join(" ")].")

	return TRUE


//this proc handles being hit by a thrown item
/mob/living/carbon/human/hitby(atom/movable/AM, speed = 5)
	if(!isitem(AM))
		return
	
	var/obj/item/thrown_item = AM

	var/mob/living/living_thrower
	if(isliving(thrown_item.thrower))
		living_thrower = thrown_item.thrower

	if(in_throw_mode && speed <= 5 && put_in_active_hand(thrown_item))
		thrown_item.throwing = FALSE //Caught in hand.
		visible_message("<span class='warning'>[src] catches [thrown_item]!</span>", null, null, 5)
		throw_mode_off()
		if(living_thrower)
			log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: caught)")
		return

	var/dtype = thrown_item.damtype
	var/throw_damage = thrown_item.throwforce * speed * 0.2

	var/zone
	if(living_thrower)
		zone = check_zone(living_thrower.zone_selected)
	else
		zone = ran_zone("chest", 75)	//Hits a random part of the body, geared towards the chest

	//check if we hit
	if(thrown_item.throw_source)
		var/distance = get_dist(thrown_item.throw_source, loc)
		zone = get_zone_with_miss_chance(zone, src, min(15*(distance-2), 0))
	else
		zone = get_zone_with_miss_chance(zone, src, 15)

	if(!zone)
		visible_message("<span class='notice'> \The [thrown_item] misses [src] narrowly!</span>", null, null, 5)
		if(living_thrower)
			log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: missed)")
		return

	if(thrown_item.thrower != src)
		throw_damage = check_shields(COMBAT_MELEE_ATTACK, throw_damage, "melee")
		if(!throw_damage)
			thrown_item.throwing = FALSE // Hit the shield.
			visible_message("<span class='danger'>[src] deflects \the [thrown_item]!</span>")
			if(living_thrower)
				log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: shield blocked)")
			return

	var/datum/limb/affecting = get_limb(zone)

	if(affecting.limb_status & LIMB_DESTROYED)
		log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: target limb missing)")
		return

	thrown_item.set_throwing(FALSE) // Hit the limb.

	var/armor = run_armor_check(affecting, "melee") //I guess "melee" is the best fit here

	if(armor >= 100)
		visible_message("<span class='notice'>\The [thrown_item] bounces on [src]'s armor!</span>", null, null, 5)
		log_combat(living_thrower, src, "thrown at", thrown_item, "(FAILED: armor blocked)")
		return

	visible_message("<span class='warning'>[src] has been hit in the [affecting.display_name] by \the [thrown_item].</span>", null, null, 5)

	apply_damage(throw_damage, dtype, zone, armor, is_sharp(thrown_item), has_edge(thrown_item))

	UPDATEHEALTH(src)

	var/list/hit_report = list("(RAW DMG: [throw_damage])")

	if(thrown_item.item_fire_stacks)
		fire_stacks += thrown_item.item_fire_stacks
	if(CHECK_BITFIELD(thrown_item.resistance_flags, ON_FIRE))
		IgniteMob()
		hit_report += "(set ablaze)"

	//thrown weapon embedded object code.
	if(affecting.limb_status & LIMB_DESTROYED)
		hit_report += "(delimbed [affecting.display_name])"
	else if(dtype == BRUTE && is_sharp(thrown_item) && prob(thrown_item.embedding.embed_chance))
		thrown_item.embed_into(src, affecting)
		hit_report += "(embedded in [affecting.display_name])"

	// Begin BS12 momentum-transfer code.
	if(thrown_item.throw_source && speed >= 15)
		var/momentum = speed * 0.5
		var/dir = get_dir(thrown_item.throw_source, src)
		visible_message("<span class='warning'> [src] staggers under the impact!</span>","<span class='warning'> You stagger under the impact!</span>", null, null, 5)
		throw_at(get_edge_target_turf(src, dir), 1, momentum)
		hit_report += "(thrown away)"

	if(living_thrower)
		log_combat(living_thrower, src, "thrown at", thrown_item, "[hit_report.Join(" ")]")
		if(throw_damage && !living_thrower.mind?.bypass_ff && !mind?.bypass_ff && living_thrower.faction == faction)
			var/turf/T = get_turf(src)
			log_ffattack("[key_name(living_thrower)] hit [key_name(src)] with \the [thrown_item] (thrown) in [AREACOORD(T)] [hit_report.Join(" ")].")
			msg_admin_ff("[ADMIN_TPMONTY(living_thrower)] hit [ADMIN_TPMONTY(src)] with \the [thrown_item] (thrown) in [ADMIN_VERBOSEJMP(T)] [hit_report.Join(" ")].")


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


//This looks for a "marine", ie. non-civilian ID on a person. Used with the m56 Smartgun code.
//Does not actually check for station jobs or access yet, cuz I'm mad lazy.
//Updated and renamed a bit. Will probably updated properly once we have a new ID system in place, as this is just a workaround ~N.
/mob/living/carbon/human/proc/get_target_lock(unique_access)
	//Streamlined for faster processing. Needs a unique access, otherwise it will just hit everything.
	var/obj/item/card/id/C = wear_id
	if(!istype(C)) C = get_active_held_item()
	if(!istype(C)) return
	if(!(unique_access in C.access)) return
	return 1


/mob/living/carbon/human/screech_act(mob/living/carbon/xenomorph/queen/Q, screech_range = WORLD_VIEW, within_sight = TRUE)
	var/dist_pct = get_dist(src, Q) / screech_range

	// Intensity is reduced by a 30% if you can't see the queen. Hold orders will reduce by an extra 10% per rank.
	var/reduce_within_sight = within_sight ? 1 : 0.7
	var/reduce_prot_aura = protection_aura * 0.1

	var/reduction = max(min(1, reduce_within_sight - reduce_prot_aura), 0.1) // Capped at 90% reduction
	var/halloss_damage = LERP(40, 80, dist_pct) * reduction //Max 80 beside Queen, 40 at the edge
	var/stun_duration = (LERP(0.4, 1, dist_pct) * reduction) * 20 //Max 1 beside Queen, 0.4 at the edge.

	to_chat(src, "<span class='danger'>An ear-splitting guttural roar tears through your mind and makes your world convulse!</span>")
	Stun(stun_duration)
	Paralyze(stun_duration)
	apply_damage(halloss_damage, HALLOSS)
	UPDATEHEALTH(src)
	if(!ear_deaf)
		adjust_ear_damage(deaf = stun_duration)  //Deafens them temporarily
	//Perception distorting effects of the psychic scream
