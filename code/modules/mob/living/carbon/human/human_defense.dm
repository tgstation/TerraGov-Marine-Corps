/mob/living/carbon/human/getarmor(def_zone, type, damage, armor_penetration, blade_dulling)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		return checkarmor(def_zone, type, damage, armor_penetration, blade_dulling)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL my bodyparts for protection, and averages out the values
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		armorval += checkarmor(BP, type, damage, armor_penetration)
		organnum++
	return (armorval/max(organnum, 1))


/mob/living/carbon/human/proc/checkarmor(def_zone, d_type, damage, armor_penetration, blade_dulling)
	if(!d_type)
		return 0
	if(isbodypart(def_zone))
		var/obj/item/bodypart/CBP = def_zone
		def_zone = CBP.body_zone
	var/protection = 0
	var/obj/item/clothing/used
	var/list/body_parts = list(skin_armor, head, wear_mask, wear_wrists, wear_shirt, wear_neck, cloak, wear_armor, wear_pants, backr, backl, gloves, shoes, belt, s_store, glasses, ears, wear_ring) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(zone2covered(def_zone, C.body_parts_covered))
				if(C.max_integrity)
					if(C.obj_integrity <= 0)
						continue
				var/val = C.armor.getRating(d_type)
				if(val > 0)
					if(val > protection)
						protection = val
						used = C
	if(used)
		if(!blade_dulling)
			blade_dulling = BCLASS_BLUNT
		if(used.blocksound)
			playsound(loc, get_armor_sound(used.blocksound, blade_dulling), 100)
		used.take_damage(damage, damage_flag = d_type, sound_effect = FALSE, armor_penetration = 100)
	if(physiology)
		protection += physiology.armor.getRating(d_type)
	return protection

/mob/living/carbon/human/proc/checkcritarmor(def_zone, d_type)
	if(!d_type)
		return 0
	if(isbodypart(def_zone))
		var/obj/item/bodypart/CBP = def_zone
		def_zone = CBP.body_zone
	var/list/body_parts = list(head, wear_mask, wear_wrists, wear_shirt, wear_neck, cloak, wear_armor, wear_pants, backr, backl, gloves, shoes, belt, s_store, glasses, ears, wear_ring) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(zone2covered(def_zone, C.body_parts_covered))
				if(C.obj_integrity > 1)
					if(d_type in C.prevent_crits)
						return TRUE
/*
/mob/proc/checkwornweight()
	return 0

/mob/living/carbon/human/checkwornweight()
	var/weight = 0
	var/list/body_parts = list(head, wear_mask, wear_wrists, wear_shirt, wear_neck, wear_armor, wear_pants, back, gloves, shoes, belt, s_store, glasses, ears, wear_ring) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.eweight)
				weight +=  C.eweight
	return max(weight, 0)
*/
/mob/living/carbon/human/on_hit(obj/projectile/P)
	if(dna && dna.species)
		dna.species.on_hit(P, src)


/mob/living/carbon/human/bullet_act(obj/projectile/P, def_zone)

	if(istype(P, /obj/projectile/beam)||istype(P, /obj/projectile/bullet))
		if((P.damage_type == BURN) || (P.damage_type == BRUTE))
			if(!P.nodamage && P.damage < src.health && isliving(P.firer))
				retaliate(P.firer)

	if(dna && dna.species)
		var/spec_return = dna.species.bullet_act(P, src, def_zone)
		if(spec_return)
			return spec_return

	//MARTIAL ART STUFF
	if(mind)
		if(mind.martial_art && mind.martial_art.can_use(src)) //Some martial arts users can deflect projectiles!
			var/martial_art_result = mind.martial_art.on_projectile_hit(src, P, def_zone)
			if(!(martial_art_result == BULLET_ACT_HIT))
				return martial_art_result

	if(!(P.original == src && P.firer == src)) //can't block or reflect when shooting yourself
		retaliate(P.firer)
		if(P.reflectable & REFLECT_NORMAL)
			if(check_reflect(def_zone)) // Checks if you've passed a reflection% check
				visible_message("<span class='danger'>The [P.name] gets reflected by [src]!</span>", \
								"<span class='danger'>The [P.name] gets reflected by [src]!</span>")
				// Find a turf near or on the original location to bounce to
				if(!isturf(loc)) //Open canopy mech (ripley) check. if we're inside something and still got hit
					P.force_hit = TRUE //The thing we're in passed the bullet to us. Pass it back, and tell it to take the damage.
					loc.bullet_act(P)
					return BULLET_ACT_HIT
				if(P.starting)
					var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/turf/curloc = get_turf(src)

					// redirect the projectile
					P.original = locate(new_x, new_y, P.z)
					P.starting = curloc
					P.firer = src
					P.yo = new_y - curloc.y
					P.xo = new_x - curloc.x
					var/new_angle_s = P.Angle + rand(120,240)
					while(new_angle_s > 180)	// Translate to regular projectile degrees
						new_angle_s -= 360
					P.setAngle(new_angle_s)

				return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

		if(check_shields(P, P.damage, "the [P.name]", PROJECTILE_ATTACK, P.armor_penetration))
			P.on_hit(src, 100, def_zone)
			return BULLET_ACT_HIT
	return ..(P, def_zone)

/mob/living/carbon/human/proc/check_reflect(def_zone) //Reflection checks for anything in my l_hand, r_hand, or wear_armor based on the reflection chance of the object
	if(wear_armor)
		if(wear_armor.IsReflect(def_zone) == 1)
			return 1
	for(var/obj/item/I in held_items)
		if(I.IsReflect(def_zone) == 1)
			return 1
	return 0

/mob/living/carbon/human/proc/check_shields(atom/AM, damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armor_penetration = 0)
	var/block_chance_modifier = round(damage / -3)

	for(var/obj/item/I in held_items)
		if(!istype(I, /obj/item/clothing))
			var/final_block_chance = I.block_chance - (CLAMP((armor_penetration-I.armor_penetration)/2,0,100)) + block_chance_modifier //So armour piercing blades can still be parried by other blades, for example
			if(I.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
				return TRUE
	if(head)
		var/final_block_chance = head.block_chance - (CLAMP((armor_penetration-head.armor_penetration)/2,0,100)) + block_chance_modifier
		if(head.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(wear_armor)
		var/final_block_chance = wear_armor.block_chance - (CLAMP((armor_penetration-wear_armor.armor_penetration)/2,0,100)) + block_chance_modifier
		if(wear_armor.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(wear_pants)
		var/final_block_chance = wear_pants.block_chance - (CLAMP((armor_penetration-wear_pants.armor_penetration)/2,0,100)) + block_chance_modifier
		if(wear_pants.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(wear_neck)
		var/final_block_chance = wear_neck.block_chance - (CLAMP((armor_penetration-wear_neck.armor_penetration)/2,0,100)) + block_chance_modifier
		if(wear_neck.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
  return FALSE

/mob/living/carbon/human/proc/check_block()
	if(mind)
		if(mind.martial_art && prob(mind.martial_art.block_chance) && mind.martial_art.can_use(src) && in_throw_mode && !incapacitated(FALSE, TRUE))
			return TRUE
	return FALSE

/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(dna && dna.species)
		var/spec_return = dna.species.spec_hitby(AM, src)
		if(spec_return)
			return spec_return
	var/obj/item/I
	var/throwpower = 30
	if(istype(AM, /obj/item))
		I = AM
		throwpower = I.throwforce
		if(I.thrownby == src) //No throwing stuff at myself to trigger hit reactions
			return ..()
		else
			if(ismob(I.thrownby))
				retaliate(I.thrownby)
	if(check_shields(AM, throwpower, "\the [AM.name]", THROWN_PROJECTILE_ATTACK))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE
	else if(I)
		if(((throwingdatum ? throwingdatum.speed : I.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || I.embedding.embedded_ignore_throwspeed_threshold)
			if(can_embed(I))
				if(prob(I.embedding.embed_chance) && !HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
					//throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
					var/obj/item/bodypart/L = pick(bodyparts)
					L.embedded_objects |= I
					I.add_mob_blood(src)//it embedded itself in you, of course it's bloody!
					I.forceMove(src)
					emote("embed", forced = TRUE)
					L.receive_damage(I.w_class*I.embedding.embedded_impact_pain_multiplier)
					next_attack_msg += " <span class='danger'>[I] embeds itself in [src]'s [L.name]!</span>"
//					visible_message("<span class='danger'>[I] embeds itself in [src]'s [L.name]!</span>","<span class='danger'>[I] embeds itself in my [L.name]!</span>")
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "embedded", /datum/mood_event/embedded)
					hitpush = FALSE
					skipcatch = TRUE //can't catch the now embedded item

	return ..()

/mob/living/carbon/human/grippedby(mob/living/user, instant = FALSE)
	if(wear_pants)
		wear_pants.add_fingerprint(user)
	retaliate(user)
	..()


/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user)
	if(!I || !user)
		return 0

	var/obj/item/bodypart/affecting
	var/useder = user.zone_selected
	if(!lying_attack_check(user,I))
		return 0
	if(user.tempatarget)
		useder = user.tempatarget
		user.tempatarget = null
	affecting = get_bodypart(check_zone(useder)) //precise attacks, on yourself or someone you are grabbing
//	else
//		affecting = get_bodypart_complex(user.used_intent.height2limb(user.aimheight)) //this proc picks a bodypart at random as long as it's in the height list
	if(!affecting) //missing limb
		to_chat(user, "<span class='warning'>Unfortunately, there's nothing there.</span>")
		return 0

	SEND_SIGNAL(I, COMSIG_ITEM_ATTACK_ZONE, src, user, affecting)

	SSblackbox.record_feedback("nested tally", "item_used_for_combat", 1, list("[I.force]", "[I.type]"))
	SSblackbox.record_feedback("tally", "zone_targeted", 1, useder)

	if(I.force)
		retaliate(user)

	// the attacked_by code varies among species
	return dna.species.spec_attacked_by(I, user, affecting, used_intent, src, useder)


/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	var/hulk_verb = pick("smash","pummel")
	if(check_shields(user, 15, "the [hulk_verb]ing"))
		return
	..()
	playsound(loc, user.dna.species.attack_sound, 25, TRUE, -1)
	visible_message("<span class='danger'>[user] [hulk_verb]ed [src]!</span>", \
					"<span class='danger'>[user] [hulk_verb]ed [src]!</span>", "<span class='hear'>I hear a sickening sound of flesh hitting flesh!</span>", null, user)
	to_chat(user, "<span class='danger'>I [hulk_verb] [src]!</span>")
	adjustBruteLoss(15)

/mob/living/carbon/human/attack_hand(mob/user)
	if(..())	//to allow surgery to return properly.
		return
	retaliate(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		dna.species.spec_attack_hand(H, src)

/mob/living/carbon/human/attack_paw(mob/living/carbon/monkey/M)
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)
	if(M.used_intent.type == INTENT_HELP)
		..() //shaking
		return 0

	retaliate(M)

	if(M.used_intent.type == INTENT_DISARM) //Always drop item in hand, if no item, get stunned instead.
		var/obj/item/I = get_active_held_item()
		if(I && dropItemToGround(I, silent = FALSE))
			playsound(loc, 'sound/blank.ogg', 25, TRUE, -1)
			visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
							"<span class='danger'>[M] disarmed you!</span>", "<span class='hear'>I hear aggressive shuffling!</span>", null, M)
			to_chat(M, "<span class='danger'>I disarm [src]!</span>")
		else if(!M.client || prob(5)) // only natural monkeys get to stun reliably, (they only do it occasionaly)
			playsound(loc, 'sound/blank.ogg', 25, TRUE, -1)
			if (src.IsKnockdown() && !src.IsParalyzed())
				Paralyze(40)
				log_combat(M, src, "pinned")
				visible_message("<span class='danger'>[M] pins [src] down!</span>", \
								"<span class='danger'>[M] pins you down!</span>", "<span class='hear'>I hear shuffling and a muffled groan!</span>", null, M)
				to_chat(M, "<span class='danger'>I pin [src] down!</span>")
			else
				Knockdown(30)
				log_combat(M, src, "tackled")
				visible_message("<span class='danger'>[M] tackles [src] down!</span>", \
								"<span class='danger'>[M] tackles you down!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", null, M)
				to_chat(M, "<span class='danger'>I tackle [src] down!</span>")

	if(M.limb_destroyer)
		dismembering_strike(M, affecting.body_zone)

	if(can_inject(M, 1, affecting))//Thick suits can stop monkey bites.
		if(..()) //successful monkey bite, this handles disease contraction.
			var/damage = rand(1, 3)
			if(check_shields(M, damage, "the [M.name]"))
				return 0
			if(stat != DEAD)
				apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, "melee", damage = damage))
		return 1

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(M, 0, "the M.name"))
		visible_message("<span class='danger'>[M] attempts to touch [src]!</span>", \
						"<span class='danger'>[M] attempts to touch you!</span>", "<span class='hear'>I hear a swoosh!</span>", null, M)
		to_chat(M, "<span class='warning'>I attempt to touch [src]!</span>")
		return 0

	if(..())
		if(M.used_intent.type == INTENT_HARM)
			if (wear_pants)
				wear_pants.add_fingerprint(M)
			var/damage = prob(90) ? 20 : 0
			if(!damage)
				playsound(loc, 'sound/blank.ogg', 50, TRUE, -1)
				visible_message("<span class='danger'>[M] lunges at [src]!</span>", \
								"<span class='danger'>[M] lunges at you!</span>", "<span class='hear'>I hear a swoosh!</span>", null, M)
				to_chat(M, "<span class='danger'>I lunge at [src]!</span>")
				return 0
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			var/armor_block = run_armor_check(affecting, "melee","","",10)

			playsound(loc, 'sound/blank.ogg', 25, TRUE, -1)
			visible_message("<span class='danger'>[M] slashes at [src]!</span>", \
							"<span class='danger'>[M] slashes at you!</span>", "<span class='hear'>I hear a sickening sound of a slice!</span>", null, M)
			to_chat(M, "<span class='danger'>I slash at [src]!</span>")
			log_combat(M, src, "attacked")
			if(!dismembering_strike(M, M.zone_selected)) //Dismemberment successful
				return 1
			apply_damage(damage, BRUTE, affecting, armor_block)

		if(M.used_intent.type == INTENT_DISARM) //Always drop item in hand, if no item, get stun instead.
			var/obj/item/I = get_active_held_item()
			if(I && dropItemToGround(I))
				playsound(loc, 'sound/blank.ogg', 25, TRUE, -1)
				visible_message("<span class='danger'>[M] disarms [src]!</span>", \
								"<span class='danger'>[M] disarms you!</span>", "<span class='hear'>I hear aggressive shuffling!</span>", null, M)
				to_chat(M, "<span class='danger'>I disarm [src]!</span>")
			else
				playsound(loc, 'sound/blank.ogg', 25, TRUE, -1)
				Paralyze(100)
				log_combat(M, src, "tackled")
				visible_message("<span class='danger'>[M] tackles [src] down!</span>", \
								"<span class='danger'>[M] tackles you down!</span>", "<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", null, M)
				to_chat(M, "<span class='danger'>I tackle [src] down!</span>")


/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L)

	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(check_shields(L, damage, "the [L.name]"))
			return 0
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(L.zone_selected))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			var/armor_block = run_armor_check(affecting, "melee")
			apply_damage(damage, BRUTE, affecting, armor_block)


/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(check_shields(M, damage, "the [M.name]", MELEE_ATTACK, M.armor_penetration))
			return FALSE
		var/zones = M.zone_selected
		if(!ckey)
			zones = pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_NECK, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/dam_zone = dismembering_strike(M, zones)
		if(!dam_zone) //Dismemberment successful
			return TRUE

		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor = run_armor_check(affecting, "melee", armor_penetration = M.a_intent.penfactor, damage = damage)
		next_attack_msg.Cut()

		var/nodmg = FALSE
		if(!apply_damage(damage, M.melee_damage_type, affecting, armor))
			nodmg = TRUE
			next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
		else
			affecting.attacked_by(M.a_intent.blade_class, damage - armor, M, dam_zone)
		visible_message("<span class='danger'>\The [M] [pick(M.a_intent.attack_verb)] [src]![next_attack_msg.Join()]</span>", \
					"<span class='danger'>\The [M] [pick(M.a_intent.attack_verb)] me![next_attack_msg.Join()]</span>", null, COMBAT_MESSAGE_RANGE)
		next_attack_msg.Cut()
		if(nodmg)
			return FALSE
		else
			retaliate(M)

/mob/living/carbon/human/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 25)
		if(M.is_adult)
			damage = rand(10, 35)

		if(check_shields(M, damage, "the [M.name]"))
			return 0

		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return 1

		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, "melee")
		apply_damage(damage, BRUTE, affecting, armor_block)

/mob/living/carbon/human/mech_melee_attack(obj/mecha/M)

	if(M.occupant.used_intent.type == INTENT_HARM)
		if(HAS_TRAIT(M.occupant, TRAIT_PACIFISM))
			to_chat(M.occupant, "<span class='warning'>I don't want to harm other living beings!</span>")
			return
		M.do_attack_animation(src)
		if(M.damtype == "brute")
			step_away(src,M,15)
		var/obj/item/bodypart/temp = get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_HEAD))
		if(temp)
			var/update = 0
			var/dmg = rand(M.force/2, M.force)
			switch(M.damtype)
				if("brute")
					if(M.force > 35) // durand and other heavy mechas
						Unconscious(20)
					else if(M.force > 20 && !IsKnockdown()) // lightweight mechas like gygax
						Knockdown(40)
					update |= temp.receive_damage(dmg, 0)
					playsound(src, 'sound/blank.ogg', 50, TRUE)
				if("fire")
					update |= temp.receive_damage(0, dmg)
					playsound(src, 'sound/blank.ogg', 50, TRUE)
				if("tox")
					M.mech_toxin_damage(src)
				else
					return
			if(update)
				update_damage_overlays()
			updatehealth()

		visible_message("<span class='danger'>[M.name] hits [src]!</span>", \
						"<span class='danger'>[M.name] hits you!</span>", "<span class='hear'>I hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, M)
		to_chat(M, "<span class='danger'>I hit [src]!</span>")
		log_combat(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.used_intent)]) (DAMTYPE: [uppertext(M.damtype)])")

	else
		..()


/mob/living/carbon/human/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if (!severity)
		return
	var/brute_loss = 0
	var/burn_loss = 0
	var/bomb_armor = getarmor(null, "bomb")

//200 max knockdown for EXPLODE_HEAVY
//160 max knockdown for EXPLODE_LIGHT


	switch (severity)
		if (EXPLODE_DEVASTATE)
			if(bomb_armor < EXPLODE_GIB_THRESHOLD) //gibs the mob if their bomb armor is lower than EXPLODE_GIB_THRESHOLD
				for(var/I in contents)
					var/atom/A = I
					A.ex_act(severity)
				gib()
				return
			else
				brute_loss = 500
				var/atom/throw_target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(throw_target, 200, 4)
				damage_clothes(400 - bomb_armor, BRUTE, "bomb")

		if (EXPLODE_HEAVY)
			brute_loss = 60
			burn_loss = 60
			if(bomb_armor)
				brute_loss = 30*(2 - round(bomb_armor*0.01, 0.05))
				burn_loss = brute_loss				//damage gets reduced from 120 to up to 60 combined brute+burn
			damage_clothes(100 - bomb_armor, BRUTE, "bomb")
//			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
//				adjustEarDamage(30, 120)
			Unconscious(20)							//short amount of time for follow up attacks against elusive enemies like wizards
			Knockdown(200 - (bomb_armor * 1.6)) 	//between ~4 and ~20 seconds of knockdown depending on bomb armor

		if(EXPLODE_LIGHT)
			brute_loss = 5
			if(bomb_armor)
				brute_loss = 5*(2 - round(bomb_armor*0.01, 0.05))
//			damage_clothes(max(50 - bomb_armor, 0), BRUTE, "bomb")
//			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
//				adjustEarDamage(15,60)
			Knockdown(160 - (bomb_armor * 1.6))		//100 bomb armor will prevent knockdown altogether

	take_overall_damage(brute_loss,burn_loss)

	//attempt to dismember bodyparts
	if(severity <= 2)
		var/max_limb_loss = round(4/severity) //so you don't lose four limbs at severity 3.
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(50/severity) && !prob(getarmor(BP, "bomb")) && BP.body_zone != BODY_ZONE_HEAD && BP.body_zone != BODY_ZONE_CHEST)
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break


/mob/living/carbon/human/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	show_message("<span class='danger'>The blob attacks you!</span>")
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, "melee"))


///Calculates the siemens coeff based on clothing and species, can also restart hearts.
/mob/living/carbon/human/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	//Calculates the siemens coeff based on clothing. Completely ignores the arguments
	if(flags & SHOCK_TESLA) //I hate this entire block. This gets the siemens_coeff for tesla shocks
		if(gloves && gloves.siemens_coefficient <= 0)
			siemens_coeff -= 0.5
		if(wear_armor)
			if(wear_armor.siemens_coefficient == -1)
				siemens_coeff -= 1
			else if(wear_armor.siemens_coefficient <= 0)
				siemens_coeff -= 0.95
		siemens_coeff = max(siemens_coeff, 0)
	else if(!(flags & SHOCK_NOGLOVES)) //This gets the siemens_coeff for all non tesla shocks
		if(gloves)
			siemens_coeff *= gloves.siemens_coefficient
	siemens_coeff *= physiology.siemens_coeff
	siemens_coeff *= dna.species.siemens_coeff
	. = ..()
	//Don't go further if the shock was blocked/too weak.
	if(!.)
		return
	//Note we both check that the user is in cardiac arrest and can actually heartattack
	//If they can't, they're missing their heart and this would runtime
///	if(undergoing_cardiac_arrest() && can_heartattack() && !(flags & SHOCK_ILLUSION))
//		if(shock_damage * siemens_coeff >= 1 && prob(25))
//			var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
//			if(heart.Restart() && stat == CONSCIOUS)
//				to_chat(src, "<span class='notice'>I feel my heart beating again!</span>")
	electrocution_animation(40)

/mob/living/carbon/human/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	var/informed = FALSE
	for(var/obj/item/bodypart/L in src.bodyparts)
		if(L.status == BODYPART_ROBOTIC)
			if(!informed)
				to_chat(src, "<span class='danger'>I feel a sharp pain as my robotic limbs overload.</span>")
				informed = TRUE
			switch(severity)
				if(1)
					L.receive_damage(0,10)
					Paralyze(200)
				if(2)
					L.receive_damage(0,5)
					Paralyze(100)

/mob/living/carbon/human/acid_act(acidpwr, acid_volume, bodyzone_hit) //todo: update this to utilize check_obscured_slots() //and make sure it's check_obscured_slots(TRUE) to stop aciding through visors etc
	var/list/damaged = list()
	var/list/inventory_items_to_kill = list()
	var/acidity = acidpwr * min(acid_volume*0.005, 0.1)
	//HEAD//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD) //only if we didn't specify a zone or if that zone is the head.
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			if(!(head_clothes.resistance_flags & UNACIDABLE))
				head_clothes.acid_act(acidpwr, acid_volume)
				update_inv_glasses()
				update_inv_wear_mask()
				update_inv_neck()
				update_inv_head()
			else
				to_chat(src, "<span class='notice'>My [head_clothes.name] protects my head and face from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_HEAD)
			if(.)
				damaged += .
			if(ears)
				inventory_items_to_kill += ears

	//CHEST//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(wear_pants)
			chest_clothes = wear_pants
		if(wear_armor)
			chest_clothes = wear_armor
		if(chest_clothes)
			if(!(chest_clothes.resistance_flags & UNACIDABLE))
				chest_clothes.acid_act(acidpwr, acid_volume)
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>My [chest_clothes.name] protects my body from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_CHEST)
			if(.)
				damaged += .
			if(wear_ring)
				inventory_items_to_kill += wear_ring
			if(r_store)
				inventory_items_to_kill += r_store
			if(l_store)
				inventory_items_to_kill += l_store
			if(s_store)
				inventory_items_to_kill += s_store


	//ARMS & HANDS//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_ARM || bodyzone_hit == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(wear_pants && ((wear_pants.body_parts_covered & HANDS) || (wear_pants.body_parts_covered & ARMS)))
			arm_clothes = wear_pants
		if(wear_armor && ((wear_armor.body_parts_covered & HANDS) || (wear_armor.body_parts_covered & ARMS)))
			arm_clothes = wear_armor

		if(arm_clothes)
			if(!(arm_clothes.resistance_flags & UNACIDABLE))
				arm_clothes.acid_act(acidpwr, acid_volume)
				update_inv_gloves()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>My [arm_clothes.name] protects my arms and hands from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_R_ARM)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_ARM)
			if(.)
				damaged += .


	//LEGS & FEET//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_LEG || bodyzone_hit == BODY_ZONE_R_LEG || bodyzone_hit == "feet")
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(wear_pants && ((wear_pants.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (wear_pants.body_parts_covered & LEGS))))
			leg_clothes = wear_pants
		if(wear_armor && ((wear_armor.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (wear_armor.body_parts_covered & LEGS))))
			leg_clothes = wear_armor
		if(leg_clothes)
			if(!(leg_clothes.resistance_flags & UNACIDABLE))
				leg_clothes.acid_act(acidpwr, acid_volume)
				update_inv_shoes()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>My [leg_clothes.name] protects my legs and feet from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_R_LEG)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_LEG)
			if(.)
				damaged += .


	//DAMAGE//
	for(var/obj/item/bodypart/affecting in damaged)
		affecting.receive_damage(acidity, 2*acidity)

		if(affecting.name == BODY_ZONE_HEAD)
			if(prob(min(acidpwr*acid_volume/10, 90))) //Applies disfigurement
				affecting.receive_damage(acidity, 2*acidity)
				emote("scream")
				facial_hairstyle = "Shaved"
				hairstyle = "Bald"
				update_hair()
				ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)

		update_damage_overlays()

	//MELTING INVENTORY ITEMS//
	//these items are all outside of armour visually, so melt regardless.
	if(!bodyzone_hit)
		if(back)
			inventory_items_to_kill += back
		if(belt)
			inventory_items_to_kill += belt

		inventory_items_to_kill += held_items

	for(var/obj/item/I in inventory_items_to_kill)
		I.acid_act(acidpwr, acid_volume)
	return 1

///Overrides the point value that the mob is worth
/mob/living/carbon/human/singularity_act()
	. = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer") )
			. = 100
		if(mind.assigned_role == "Clown")
			. = rand(-1000, 1000)
	..() //Called afterwards because getting the mind after getting gibbed is sketchy

/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(!istype(M))
		return

	if(src == M)
		if(has_status_effect(STATUS_EFFECT_CHOKINGSTRAND))
			to_chat(src, "<span class='notice'>I attempt to remove the durathread strand from around my neck.</span>")
			if(do_after(src, 35, null, src))
				to_chat(src, "<span class='notice'>I succesfuly remove the durathread strand.</span>")
				remove_status_effect(STATUS_EFFECT_CHOKINGSTRAND)
			return
		check_self_for_injuries()


	else
		if(wear_armor)
			wear_armor.add_fingerprint(M)
		else if(wear_pants)
			wear_pants.add_fingerprint(M)

		..()

/mob/living/carbon/human/proc/check_self_for_injuries()
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

	visible_message("<span class='notice'>[src] examines [p_them()]self.</span>", \
		"<span class='notice'>I check myself for injuries.</span>")

	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

	for(var/X in bodyparts)
		var/obj/item/bodypart/LB = X
		missing -= LB.body_zone
		if(LB.is_pseudopart) //don't show injury text for fake bodyparts; ie chainsaw arms or synthetic armblades
			continue
		var/self_aware = FALSE
		if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
			self_aware = TRUE
		var/limb_max_damage = LB.max_damage
		var/status = ""
		var/brutedamage = LB.brute_dam
		var/burndamage = LB.burn_dam
		if(hallucination)
			if(prob(30))
				brutedamage += rand(30,40)
			if(prob(30))
				burndamage += rand(30,40)

		if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
			status = "[brutedamage] brute damage and [burndamage] burn damage"
			if(!brutedamage && !burndamage)
				status = "no damage"

		else
			if(brutedamage > 0)
				status = LB.light_brute_msg
			if(brutedamage > (limb_max_damage*0.4))
				status = LB.medium_brute_msg
			if(brutedamage > (limb_max_damage*0.8))
				status = LB.heavy_brute_msg
			if(brutedamage > 0 && burndamage > 0)
				status += " and "

			if(burndamage > (limb_max_damage*0.8))
				status += LB.heavy_burn_msg
			else if(burndamage > (limb_max_damage*0.2))
				status += LB.medium_burn_msg
			else if(burndamage > 0)
				status += LB.light_burn_msg

			if(status == "")
				status = "OK"
		var/no_damage
		if(status == "OK" || status == "no damage")
			no_damage = TRUE
		var/isdisabled = " "
		if(LB.is_disabled())
			isdisabled = " is disabled "
			if(no_damage)
				isdisabled += " but otherwise "
			else
				isdisabled += " and "
		to_chat(src, "\t <span class='[no_damage ? "notice" : "warning"]'>My [LB.name][isdisabled][self_aware ? " has " : " is "][status].</span>")

		for(var/obj/item/I in LB.embedded_objects)
			to_chat(src, "\t <a href='?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(LB)]' class='warning'>There is \a [I] in my [LB.name]!</a>")

	for(var/t in missing)
		to_chat(src, "<span class='boldannounce'>My [parse_zone(t)] is missing!</span>")

	if(bleed_rate)
		to_chat(src, "<span class='danger'>I am bleeding!</span>")
	if(getStaminaLoss())
		if(getStaminaLoss() > 30)
			to_chat(src, "<span class='info'>You're completely exhausted.</span>")
		else
			to_chat(src, "<span class='info'>I feel fatigued.</span>")
	if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
		if(toxloss)
			if(toxloss > 10)
				to_chat(src, "<span class='danger'>I feel sick.</span>")
			else if(toxloss > 20)
				to_chat(src, "<span class='danger'>I feel nauseated.</span>")
			else if(toxloss > 40)
				to_chat(src, "<span class='danger'>I feel very unwell!</span>")
		if(oxyloss)
			if(oxyloss > 10)
				to_chat(src, "<span class='danger'>I feel lightheaded.</span>")
			else if(oxyloss > 20)
				to_chat(src, "<span class='danger'>My thinking is clouded and distant.</span>")
			else if(oxyloss > 30)
				to_chat(src, "<span class='danger'>You're choking!</span>")

	if(!HAS_TRAIT(src, TRAIT_NOHUNGER))
		switch(nutrition)
			if(NUTRITION_LEVEL_FULL to INFINITY)
				to_chat(src, "<span class='info'>You're completely stuffed!</span>")
			if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
				to_chat(src, "<span class='info'>You're well fed!</span>")
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
				to_chat(src, "<span class='info'>You're not hungry.</span>")
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				to_chat(src, "<span class='info'>I could use a bite to eat.</span>")
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				to_chat(src, "<span class='info'>I feel quite hungry.</span>")
			if(0 to NUTRITION_LEVEL_STARVING)
				to_chat(src, "<span class='danger'>You're starving!</span>")

	//Compiles then shows the list of damaged organs and broken organs
	var/list/broken = list()
	var/list/damaged = list()
	var/broken_message
	var/damaged_message
	var/broken_plural
	var/damaged_plural
	//Sets organs into their proper list
	for(var/O in internal_organs)
		var/obj/item/organ/organ = O
		if(organ.organ_flags & ORGAN_FAILING)
			if(broken.len)
				broken += ", "
			broken += organ.name
		else if(organ.damage > organ.low_threshold)
			if(damaged.len)
				damaged += ", "
			damaged += organ.name
	//Checks to enforce proper grammar, inserts words as necessary into the list
	if(broken.len)
		if(broken.len > 1)
			broken.Insert(broken.len, "and ")
			broken_plural = TRUE
		else
			var/holder = broken[1]	//our one and only element
			if(holder[length(holder)] == "s")
				broken_plural = TRUE
		//Put the items in that list into a string of text
		for(var/B in broken)
			broken_message += B
		to_chat(src, "<span class='warning'>My [broken_message] [broken_plural ? "are" : "is"] non-functional!</span>")
	if(damaged.len)
		if(damaged.len > 1)
			damaged.Insert(damaged.len, "and ")
			damaged_plural = TRUE
		else
			var/holder = damaged[1]
			if(holder[length(holder)] == "s")
				damaged_plural = TRUE
		for(var/D in damaged)
			damaged_message += D
		to_chat(src, "<span class='info'>My [damaged_message] [damaged_plural ? "are" : "is"] hurt.</span>")

	if(roundstart_quirks.len)
		to_chat(src, "<span class='notice'>I have these quirks: [get_trait_string()].</span>")


/mob/living/carbon/human/proc/check_limb_for_injuries(choice)
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

	var/obj/item/bodypart/FB

	for(var/X in bodyparts)
		var/obj/item/bodypart/LB = X
		if(LB.body_zone == choice)
			FB = LB

	if(!FB) //selected limb is missing
		to_chat(src, "<span class='warning'>My [parse_zone(choice)] is missing!</span>")
		return

	var/limb_max_damage = FB.max_damage
	var/status = ""
	var/brutedamage = FB.brute_dam
	var/burndamage = FB.burn_dam
	var/wounddamage = 0
	if(FB.wounds.len)
		for(var/datum/wound/W in FB.wounds)
			wounddamage = wounddamage + W.woundpain
	if(hallucination)
		if(prob(30))
			brutedamage += rand(30,40)
		if(prob(30))
			burndamage += rand(30,40)

	if(brutedamage > 0)
		status = FB.light_brute_msg
	if(brutedamage > (limb_max_damage*0.4))
		status = FB.medium_brute_msg
	if(brutedamage > (limb_max_damage*0.8))
		status = FB.heavy_brute_msg
	if(brutedamage > 0)
		if(burndamage > 0 && wounddamage > 0)
			status += ", "
		else if(burndamage > 0 || wounddamage > 0)
			status += " and "

	if(burndamage > (limb_max_damage*0.8))
		status += FB.heavy_burn_msg
	else if(burndamage > (limb_max_damage*0.2))
		status += FB.medium_burn_msg
	else if(burndamage > 0)
		status += FB.light_burn_msg
	if(burndamage > 0)
		if(brutedamage > 0 && wounddamage > 0)
			status += ", and "
		else if(wounddamage > 0)
			status += " and "

	if(wounddamage > 0)
		if(wounddamage > 80)
			status += "has incredibly painful wounds."
		else if(wounddamage > 40)
			status += "has painful wounds."
		else
			status += "has light wounds."

	if(status == "")
		status = "is OK."
	var/no_damage
	if(status == "is OK." || status == "no damage")
		no_damage = TRUE
	var/isdisabled = ""
	if(FB.is_disabled() == BODYPART_DISABLED_CRIT)
		isdisabled = "shattered "
	if(FB.is_disabled() == BODYPART_DISABLED_DAMAGE)
		isdisabled = "cracked "
	if(FB.is_disabled() == BODYPART_DISABLED_PARALYSIS || FB.is_disabled() == BODYPART_DISABLED_FALL)
		isdisabled = "limp "
	to_chat(src, "\t <span class='[no_damage ? "notice" : "warning"]'>My [isdisabled][FB.name] [status].</span>")

	for(var/obj/item/I in FB.embedded_objects)
		to_chat(src, "\t <a href='?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(FB)]' class='warning'>There is \a [I] in my [FB.name]!</a>")


/mob/living/carbon/human/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5 //0.5 multiplier for balance reason, we don't want clothes to be too easily destroyed
	var/list/torn_items = list()

	//HEAD//
	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			torn_items += head_clothes
		else if(ears)
			torn_items += ears

	//CHEST//
	if(!def_zone || def_zone == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(wear_pants)
			chest_clothes = wear_pants
		if(wear_armor)
			chest_clothes = wear_armor
		if(chest_clothes)
			torn_items += chest_clothes

	//ARMS & HANDS//
	if(!def_zone || def_zone == BODY_ZONE_L_ARM || def_zone == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(wear_pants && ((wear_pants.body_parts_covered & HANDS) || (wear_pants.body_parts_covered & ARMS)))
			arm_clothes = wear_pants
		if(wear_armor && ((wear_armor.body_parts_covered & HANDS) || (wear_armor.body_parts_covered & ARMS)))
			arm_clothes = wear_armor
		if(arm_clothes)
			torn_items |= arm_clothes

	//LEGS & FEET//
	if(!def_zone || def_zone == BODY_ZONE_L_LEG || def_zone == BODY_ZONE_R_LEG)
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(wear_pants && ((wear_pants.body_parts_covered & FEET) || (wear_pants.body_parts_covered & LEGS)))
			leg_clothes = wear_pants
		if(wear_armor && ((wear_armor.body_parts_covered & FEET) || (wear_armor.body_parts_covered & LEGS)))
			leg_clothes = wear_armor
		if(leg_clothes)
			torn_items |= leg_clothes

	for(var/obj/item/I in torn_items)
		I.take_damage(damage_amount, damage_type, damage_flag, 0)
