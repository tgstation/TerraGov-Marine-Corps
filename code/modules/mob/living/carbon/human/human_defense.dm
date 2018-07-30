/*
Contains most of the procs that are called when a mob is attacked by something
*/

/mob/living/carbon/human/stun_effect_act(var/stun_amount, var/agony_amount, var/def_zone)
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
				msg_admin_attack("[src.name] ([src.ckey]) was disarmed by a stun effect")

				drop_inv_item_on_ground(c_hand)
				if (affected.status & LIMB_ROBOT)
					emote("me", 1, "drops what they were holding, their [affected.display_name] malfunctioning!")
				else
					var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
					emote("me", 1, "[(species && species.flags & NO_PAIN) ? "" : emote_scream ] drops what they were holding in their [affected.display_name]!")

	..(stun_amount, agony_amount, def_zone)

/mob/living/carbon/human/getarmor(var/def_zone, var/type)
	var/armorval = 0
	var/total = 0

	if(def_zone)
		if(isorgan(def_zone))
			return getarmor_organ(def_zone, type)
		var/datum/limb/affecting = get_limb(def_zone)
		return getarmor_organ(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
		for(var/X in limbs)
			var/datum/limb/E = X
			var/weight = organ_rel_size[E.name]
			armorval += getarmor_organ(E, type) * weight
			total += weight
	return (armorval/max(total, 1))

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(var/datum/limb/def_zone)
	if (!def_zone)
		return 1.0

	var/siemens_coefficient = 1.0

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(istype(C) && (C.flags_armor_protection & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

//this proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(var/datum/limb/def_zone, var/type)
	if(!type)	return 0
	var/protection = 0
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/gear in protective_gear)
		if(gear && istype(gear ,/obj/item/clothing))
			var/obj/item/clothing/C = gear
			if(C.flags_armor_protection & def_zone.body_part)
				protection += C.armor[type]
	return protection

/mob/living/carbon/human/proc/check_head_coverage()

	var/list/body_parts = list(head, wear_mask, wear_suit ) /* w_uniform, gloves, shoes*/ //We don't need to check these for heads.
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.flags_armor_protection & HEAD)
				return 1
	return 0

/mob/living/carbon/human/proc/check_shields(var/damage = 0, var/attack_text = "the attack", var/combistick=0)
	if(l_hand && istype(l_hand, /obj/item/weapon))//Current base is the prob(50-d/3)
		if(combistick && istype(l_hand,/obj/item/weapon/combistick))
			var/obj/item/weapon/combistick/C = l_hand
			if(C.on)
				return 1
		var/obj/item/weapon/I = l_hand
		if(I.IsShield() && (prob(50 - round(damage / 3))))
			visible_message("\red <B>[src] blocks [attack_text] with the [l_hand.name]!</B>", null, null, 5)
			return 1
	if(r_hand && istype(r_hand, /obj/item/weapon))
		if(combistick && istype(r_hand,/obj/item/weapon/combistick))
			var/obj/item/weapon/combistick/C = r_hand
			if(C.on)
				return 1
		var/obj/item/weapon/I = r_hand
		if(I.IsShield() && (prob(50 - round(damage / 3))))
			visible_message("\red <B>[src] blocks [attack_text] with the [r_hand.name]!</B>", null, null, 5)
			return 1
	return 0

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	for(var/datum/limb/O in limbs)
		if(O.status & LIMB_DESTROYED)	continue
		O.emp_act(severity)
		for(var/datum/internal_organ/I in O.internal_organs)
			if(I.robotic == 0)	continue
			I.emp_act(severity)
	..()


//Returns 1 if the attack hit, 0 if it missed.
/mob/living/carbon/human/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone)
	if(!I || !user)	return 0

	var/target_zone = def_zone? check_zone(def_zone) : get_zone_with_miss_chance(user.zone_selected, src)

	user.animation_attack_on(src)
	if(user == src) // Attacking yourself can't miss
		target_zone = user.zone_selected
	if(!target_zone)
		visible_message("\red <B>[user] misses [src] with \the [I]!", null, null, 5)
		return 0

	var/datum/limb/affecting = get_limb(target_zone)
	if (!affecting)
		return 0
	if(affecting.status & LIMB_DESTROYED)
		user << "What [affecting.display_name]?"
		return 0
	var/hit_area = affecting.display_name

	if((user != src) && check_shields(I.force, "the [I.name]"))
		return 0

	if(I.attack_verb && I.attack_verb.len)
		visible_message("\red <B>[src] has been [pick(I.attack_verb)] in the [hit_area] with [I.name] by [user]!</B>", null, null, 5)
	else
		visible_message("\red <B>[src] has been attacked in the [hit_area] with [I.name] by [user]!</B>", null, null, 5)

	var/armor = run_armor_check(affecting, "melee", "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].")
	var/weapon_sharp = is_sharp(I)
	var/weapon_edge = has_edge(I)
	if ((weapon_sharp || weapon_edge) && prob(getarmor(target_zone, "melee")))
		weapon_sharp = 0
		weapon_edge = 0

	if(armor >= 2)	return 0
	if(!I.force)	return 0
	if(weapon_sharp)
		user.flick_attack_overlay(src, "punch")
	else
		user.flick_attack_overlay(src, "punch")

	apply_damage(I.force, I.damtype, affecting, armor, sharp=weapon_sharp, edge=weapon_edge, used_weapon=I)

	var/bloody = 0
	if((I.damtype == BRUTE || I.damtype == HALLOSS) && prob(I.force*2 + 25))
		if(!(affecting.status & LIMB_ROBOT))
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
				if(prob(I.force))
					apply_effect(20, PARALYZE, armor)
					visible_message("<span class='danger'>[src] has been knocked unconscious!</span>",
					"<span class='danger'>You have been knocked unconscious!</span>", null, 5)

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
				if(prob((I.force + 10)))
					apply_effect(6, WEAKEN, armor)
					visible_message("\red <B>[src] has been knocked down!</B>", null, null, 5)

				if(bloody)
					bloody_body(src)

	//Melee weapon embedded object code.
	if (I.damtype == BRUTE && !I.is_robot_module() && !(I.flags_item & (NODROP|DELONDROP)))
		var/damage = I.force
		if(damage > 40) damage = 40  //Some sanity, mostly for yautja weapons. CONSTANT STICKY ICKY
		if (!armor && weapon_sharp && prob(3) && !isYautja(user)) // make yautja less likely to get their weapon stuck
			affecting.embed(I)

	return 1

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM,var/speed = 5)
	if(istype(AM,/obj/))
		var/obj/O = AM

		if(in_throw_mode && !get_active_hand() && speed <= 5)	//empty active hand and we're in throw mode
			if(!is_mob_incapacitated())
				if(isturf(O.loc))
					if(put_in_active_hand(O))
						visible_message("<span class='warning'>[src] catches [O]!</span>", null, null, 5)
						throw_mode_off()
						return

		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
		var/throw_damage = O.throwforce*(speed/5)

		var/zone
		if (istype(O.thrower, /mob/living))
			var/mob/living/L = O.thrower
			zone = check_zone(L.zone_selected)
		else
			zone = ran_zone("chest",75)	//Hits a random part of the body, geared towards the chest

		//check if we hit
		if (O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			zone = get_zone_with_miss_chance(zone, src, min(15*(distance-2), 0))
		else
			zone = get_zone_with_miss_chance(zone, src, 15)

		if(!zone)
			visible_message("\blue \The [O] misses [src] narrowly!", null, null, 5)
			return

		O.throwing = 0		//it hit, so stop moving

		if ((O.thrower != src) && check_shields(throw_damage, "[O]"))
			return

		var/datum/limb/affecting = get_limb(zone)
		var/hit_area = affecting.display_name

		src.visible_message("\red [src] has been hit in the [hit_area] by [O].", null, null, 5)
		var/armor = run_armor_check(affecting, "melee", "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].") //I guess "melee" is the best fit here

		if(armor < 2)
			apply_damage(throw_damage, dtype, zone, armor, is_sharp(O), has_edge(O), O)

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a [O], thrown by [M.name] ([assailant.ckey])</font>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O]</font>")
				if(!istype(src,/mob/living/simple_animal/mouse))
					msg_admin_attack("[src.name] ([src.ckey]) was hit by a [O], thrown by [M.name] ([assailant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

		//thrown weapon embedded object code.
		if(dtype == BRUTE && istype(O,/obj/item))
			var/obj/item/I = O
			if (!I.is_robot_module())
				var/sharp = is_sharp(I)
				var/damage = throw_damage
				if (armor)
					damage /= armor+1

				//blunt objects should really not be embedding in things unless a huge amount of force is involved
				var/embed_chance = sharp? damage/I.w_class : damage/(I.w_class*3)
				var/embed_threshold = sharp? 5*I.w_class : 15*I.w_class

				//Sharp objects will always embed if they do enough damage.
				//Thrown sharp objects have some momentum already and have a small chance to embed even if the damage is below the threshold
				if((sharp && prob(damage/(10*I.w_class)*100)) || (damage > embed_threshold && prob(embed_chance)))
					affecting.embed(I)

		// Begin BS12 momentum-transfer code.
		if(O.throw_source && speed >= 15)
			var/momentum = speed/2
			var/dir = get_dir(O.throw_source, src)

			visible_message("\red [src] staggers under the impact!","\red You stagger under the impact!", null, null, 5)
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)


/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 2)
	if (gloves)
		gloves.add_mob_blood(source)
		gloves:transfer_blood = amount
	else
		var/list/blood_dna = source.get_blood_dna_list()
		if(!blood_dna)
			return
		var/b_color = source.get_blood_color()

		transfer_blood_dna(blood_dna)
		if(b_color)
			blood_color = b_color
		bloody_hands = amount

	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves


/mob/living/carbon/human/proc/bloody_body(var/mob/living/source)
	if(wear_suit)
		wear_suit.add_mob_blood(source)
		update_inv_wear_suit()
	if(w_uniform)
		w_uniform.add_mob_blood(source)
		update_inv_w_uniform()


/mob/living/carbon/human/proc/handle_suit_punctures(var/damtype, var/damage)
	if(!wear_suit) return
	if(!istype(wear_suit,/obj/item/clothing/suit/space)) return
	if(damtype != BURN && damtype != BRUTE) return

	var/obj/item/clothing/suit/space/SS = wear_suit
	var/penetrated_dam = max(0,(damage - SS.breach_threshold)) // - SS.damage)) - Consider uncommenting this if suits seem too hardy on dev.

	if(penetrated_dam) SS.create_breaches(damtype, penetrated_dam)

//This looks for a "marine", ie. non-civilian ID on a person. Used with the m56 Smartgun code.
//Does not actually check for station jobs or access yet, cuz I'm mad lazy.
//Updated and renamed a bit. Will probably updated properly once we have a new ID system in place, as this is just a workaround ~N.
/mob/living/carbon/human/proc/get_target_lock(unique_access)
	//Streamlined for faster processing. Needs a unique access, otherwise it will just hit everything.
	var/obj/item/card/id/C = wear_id
	if(!istype(C)) C = get_active_hand()
	if(!istype(C)) return
	if(!(unique_access in C.access)) return
	return 1