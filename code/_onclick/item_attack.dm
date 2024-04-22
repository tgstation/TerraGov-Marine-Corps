/**
  *This is the proc that handles the order of an item_attack.
  *The order of procs called is:
  *tool_act on the target. If it returns TRUE, the chain will be stopped.
  *pre_attack() on src. If this returns TRUE, the chain will be stopped.
  *attackby on the target. If it returns TRUE, the chain will be stopped.
  *and lastly
  *afterattack. The return value does not matter.
  */
/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	if(user.check_arm_grabbed(user.active_hand_index))
		to_chat(user, "<span class='notice'>I can't move my arm!</span>")
		return
	if(!user.has_hand_for_held_index(user.active_hand_index, TRUE)) //we obviously have a hadn, but we need to check for fingers/prosthetics
		to_chat(user, "<span class='warning'>I can't move the fingers.</span>")
		return
	if(!istype(src, /obj/item/grabbing))
		if(HAS_TRAIT(user, TRAIT_CHUNKYFINGERS))
			to_chat(user, "<span class='warning'>...What?</span>")
			return
	if(tool_behaviour && target.tool_act(user, src, tool_behaviour))
		return
	if(pre_attack(target, user, params))
		return
	if(target.attackby(src,user, params))
		return
	if(QDELETED(src) || QDELETED(target))
		attack_qdeleted(target, user, TRUE, params)
		return
	afterattack(target, user, TRUE, params)

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_NO_INTERACT)
		return
	interact(user)

/obj/item/proc/pre_attack(atom/A, mob/living/user, params) //do stuff before attackby!
	if(SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK, A, user, params) & COMPONENT_NO_ATTACK)
		return TRUE
	return FALSE //return TRUE to avoid calling attackby after this proc does stuff

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	if(user.used_intent.tranged)
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, W, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/obj/attackby(obj/item/I, mob/living/user, params)
	return ..() || ((obj_flags & CAN_BE_HIT) && I.attack_obj(src, user))

/turf/attackby(obj/item/I, mob/living/user, params)
	return ..() || (max_integrity && I.attack_turf(src, user))

/mob/living/attackby(obj/item/I, mob/living/user, params)
	if(..())
		return TRUE
	var/adf = user.used_intent.clickcd
	if(istype(user.rmb_intent, /datum/rmb_intent/aimed))
		adf = round(adf * 1.4)
	if(istype(user.rmb_intent, /datum/rmb_intent/swift))
		adf = round(adf * 0.6)
	user.changeNext_move(adf)
	return I.attack(src, user)

/mob/living
	var/tempatarget = null

/obj/item/proc/attack(mob/living/M, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user) & COMPONENT_ITEM_NO_ATTACK)
		return FALSE
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, user)
	if(item_flags & NOBLUDGEON)
		return FALSE

	if(force && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>I don't want to harm other living beings!</span>")
		return

	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey
	if(M.mind)
		M.mind.attackedme[user.real_name] = world.time
	if(force)
		if(user.used_intent)
			if(!user.used_intent.noaa)
				playsound(get_turf(src), pick(swingsound), 100, FALSE, -1)
			if(user.used_intent.no_attack) //BYE!!!
				return
	else
		return

//	if(force)
//		user.emote("attackgrunt")
	var/datum/intent/cached_intent = user.used_intent
	if(user.used_intent.swingdelay)
		if(!user.used_intent.noaa)
			user.do_attack_animation(M, visual_effect_icon = user.used_intent.animname)
		sleep(user.used_intent.swingdelay)
	if(user.a_intent != cached_intent)
		return
	if(QDELETED(src) || QDELETED(M))
		return
	if(!user.CanReach(M,src))
		return
	if(user.get_active_held_item() != src)
		return
	if(user.incapacitated())
		return
	if((M.mobility_flags & MOBILITY_STAND))
		if(M.checkmiss(user))
			if(!user.used_intent.swingdelay)
				user.do_attack_animation(M, visual_effect_icon = user.used_intent.animname)
			return
	if(istype(user.rmb_intent, /datum/rmb_intent/strong))
		user.rogfat_add(10)
	if(istype(user.rmb_intent, /datum/rmb_intent/swift))
		user.rogfat_add(10)
	if(M.checkdefense(user.used_intent, user))
		if(M.d_intent == INTENT_PARRY)
			if(!M.get_active_held_item()) //we parried with a bracer, redirect damage
				if(M.active_hand_index == 1)
					user.tempatarget = "l_arm"
				else
					user.tempatarget = "r_arm"
				if(M.attacked_by(src, user)) //we change intents when attacking sometimes so don't play if we do (embedding items)
					if(user.used_intent == cached_intent)
						var/tempsound = user.used_intent.hitsound
						if(tempsound)
							playsound(M.loc,  tempsound, 100, FALSE, -1)
						else
							playsound(M.loc,  "nodmg", 100, FALSE, -1)
				log_combat(user, M, "attacked", src.name, "(INTENT: [uppertext(user.used_intent.name)]) (DAMTYPE: [uppertext(damtype)])")
				add_fingerprint(user)
		if(M.d_intent == INTENT_DODGE)
			if(!user.used_intent.swingdelay)
				user.do_attack_animation(M, visual_effect_icon = user.used_intent.animname)
		return

	if(user.zone_selected == BODY_ZONE_R_INHAND)
		var/offh = 0
		var/obj/item/W = M.held_items[1]
		if(W)
			if(!(M.mobility_flags & MOBILITY_STAND))
				M.throw_item(get_step(M,turn(M.dir, 90)), offhand = offh)
			else
				M.dropItemToGround(W)
			M.visible_message("<span class='notice'>[user] disarms [M]!</span>", \
							"<span class='boldwarning'>I'm disarmed by [user]!</span>")
			return

	if(user.zone_selected == BODY_ZONE_L_INHAND)
		var/offh = 0
		var/obj/item/W = M.held_items[2]
		if(W)
			if(!(M.mobility_flags & MOBILITY_STAND))
				M.throw_item(get_step(M,turn(M.dir, 270)), offhand = offh)
			else
				M.dropItemToGround(W)
			M.visible_message("<span class='notice'>[user] disarms [M]!</span>", \
							"<span class='boldwarning'>I'm disarmed by [user]!</span>")
			return

	if(M.attacked_by(src, user))
		if(user.used_intent == cached_intent)
			var/tempsound = user.used_intent.hitsound
			if(tempsound)
				playsound(M.loc,  tempsound, 100, FALSE, -1)
			else
				playsound(M.loc,  "nodmg", 100, FALSE, -1)

	log_combat(user, M, "attacked", src.name, "(INTENT: [uppertext(user.used_intent.name)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)


//the equivalent of the standard version of attack() but for object targets.
/obj/item/proc/attack_obj(obj/O, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_OBJ, O, user) & COMPONENT_NO_ATTACK_OBJ)
		return
	if(item_flags & NOBLUDGEON)
		return
	if(O.attacked_by(src, user))
		user.do_attack_animation(O)
		return TRUE

/obj/item/proc/attack_turf(turf/T, mob/living/user)
	if(T.max_integrity)
		if(T.attacked_by(src, user))
			user.do_attack_animation(T)
			return TRUE

/atom/movable/proc/attacked_by()
	return FALSE

/proc/get_complex_damage(obj/item/I, mob/living/user, blade_dulling)
	var/dullfactor = 1
	if(!I.force)
		return 0
	var/newforce = I.force
	testing("startforce [newforce]")
	var/cont = FALSE
	var/used_str = user.STASTR
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.domhand)
			used_str = C.get_str_arms(C.used_hand)
	if(istype(user.rmb_intent, /datum/rmb_intent/strong))
		used_str++
	if(istype(user.rmb_intent, /datum/rmb_intent/weak))
		used_str--
	used_str = CLAMP(used_str, 1, 20)
	if(used_str >= 11)
		newforce = newforce + (newforce * ((used_str - 10) * 0.3))
	else if(used_str <= 9)
		newforce = newforce - (newforce * ((10 - used_str) * 0.1))

	if(I.minstr)
		var/effective = I.minstr
		if(I.wielded)
			effective = max(I.minstr / 2, 1)
		if(effective > user.STASTR)
			newforce = max(newforce*0.3, 1)

	switch(blade_dulling)
		if(DULLING_CUT) //wooden that can't be attacked by clubs (trees, bushes, grass)
			switch(user.used_intent.blade_class)
				if(BCLASS_CUT)
					if(!I.remove_bintegrity(1))
						dullfactor = 0.2
					else
						dullfactor = 0.75
					cont = TRUE
				if(BCLASS_CHOP)
					if(!I.remove_bintegrity(1))
						dullfactor = 0.2
					else
						dullfactor = 1.5
					cont = TRUE
			if(!cont)
				return 0
		if(DULLING_BASH) //stone/metal, can't be attacked by cutting
			switch(user.used_intent.blade_class)
				if(BCLASS_BLUNT)
					cont = TRUE
				if(BCLASS_SMASH)
					dullfactor = 1.5
					cont = TRUE
				if(BCLASS_PICK)
					dullfactor = 1.5
					cont = TRUE
			if(!cont)
				return 0
		if(DULLING_BASHCHOP) //structures that can be attacked by clubs also (doors fences etc)
			switch(user.used_intent.blade_class)
				if(BCLASS_CUT)
					if(!I.remove_bintegrity(1))
						dullfactor = 0.8
					cont = TRUE
				if(BCLASS_CHOP)
					if(!I.remove_bintegrity(1))
						dullfactor = 0.8
					else
						dullfactor = 1.5
					cont = TRUE
				if(BCLASS_SMASH)
					dullfactor = 1.5
					cont = TRUE
				if(BCLASS_BLUNT)
					cont = TRUE
				if(BCLASS_PICK)
					dullfactor = 1.5
					cont = TRUE
			if(!cont)
				return 0
		if(DULLING_PICK) //cannot deal damage if not a pick item. aka rock walls
			if(user.used_intent.blade_class != BCLASS_PICK)
				return 0
			newforce = newforce * 10
			shake_camera(user, 1, 1)
	newforce = (newforce * user.used_intent.damfactor) * dullfactor
	if(user.used_intent.get_chargetime() && user.client?.chargedprog < 100)
		newforce = newforce * 0.5
	newforce = round(newforce,1)
	newforce = max(newforce, 1)
	testing("endforce [newforce]")
	return newforce

/obj/attacked_by(obj/item/I, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	var/newforce = get_complex_damage(I, user, blade_dulling)
	if(!newforce)
		testing("dam33")
		return 0
	if(newforce < damage_deflection)
		testing("dam44")
		return 0
	if(user.used_intent.no_attack)
		return 0
	log_combat(user, src, "attacked", I)
	var/verbu = "hits"
	verbu = pick(user.used_intent.attack_verb)
	if(newforce > 1)
		if(user.rogfat_add(5))
			user.visible_message("<span class='danger'>[user] [verbu] [src] with [I]!</span>")
		else
			user.visible_message("<span class='warning'>[user] [verbu] [src] with [I]!</span>")
			newforce = 1
	else
		user.visible_message("<span class='warning'>[user] [verbu] [src] with [I]!</span>")
	take_damage(newforce, I.damtype, "melee", 1)
	if(newforce > 1)
		I.take_damage(1, BRUTE, "melee")
	return TRUE

/turf/proc/attacked_by(obj/item/I, mob/living/user)
	var/newforce = get_complex_damage(I, user, blade_dulling)
	if(!newforce)
		testing("attack6")
		return 0
	if(newforce < damage_deflection)
		testing("attack7")
		return 0
	if(user.used_intent.no_attack)
		return 0
	user.changeNext_move(CLICK_CD_MELEE)
	log_combat(user, src, "attacked", I)
	var/verbu = "hits"
	verbu = pick(user.used_intent.attack_verb)
	if(newforce > 1)
		if(user.rogfat_add(5))
			user.visible_message("<span class='danger'>[user] [verbu] [src] with [I]!</span>")
		else
			user.visible_message("<span class='warning'>[user] [verbu] [src] with [I]!</span>")
			newforce = 1
	else
		user.visible_message("<span class='warning'>[user] [verbu] [src] with [I]!</span>")

	take_damage(newforce, I.damtype, "melee", 1)
	if(newforce > 1)
		I.take_damage(1, BRUTE, "melee")
	return TRUE

/mob/living/proc/simple_limb_hit(zone)
	if(!zone)
		return ""
	switch(zone)
		if(BODY_ZONE_HEAD)
			return "body"
		if(BODY_ZONE_CHEST)
			return "body"
		if(BODY_ZONE_R_LEG)
			return "body"
		if(BODY_ZONE_L_LEG)
			return "body"
		if(BODY_ZONE_R_ARM)
			return "body"
		if(BODY_ZONE_L_ARM)
			return "body"
		if(BODY_ZONE_PRECISE_R_EYE)
			return "body"
		if(BODY_ZONE_PRECISE_L_EYE)
			return "body"
		if(BODY_ZONE_PRECISE_NOSE)
			return "body"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "body"
		if(BODY_ZONE_PRECISE_HAIR)
			return "body"
		if(BODY_ZONE_PRECISE_EARS)
			return "body"
		if(BODY_ZONE_PRECISE_NECK)
			return "body"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "body"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "body"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "body"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "body"
		if(BODY_ZONE_PRECISE_STOMACH)
			return "body"
		if(BODY_ZONE_PRECISE_GROIN)
			return "body"
		if(BODY_ZONE_R_INHAND)
			return "body"
		if(BODY_ZONE_L_INHAND)
			return "body"
	return "body"

/obj/item/proc/funny_attack_effects(mob/living/target, mob/living/user, nodmg)
	return

/mob/living/attacked_by(obj/item/I, mob/living/user)
	var/hitlim = simple_limb_hit(user.zone_selected)
	testing("[src] attacked_by")
	I.funny_attack_effects(src, user)
	if(I.force)
		var/newforce = get_complex_damage(I, user)
		apply_damage(newforce, I.damtype, def_zone = hitlim)
		if(I.damtype == BRUTE)
			next_attack_msg.Cut()
			if(woundcritroll(user.used_intent.blade_class, newforce, user, hitlim) && HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
//				throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
				simple_embedded_objects |= I
				I.add_mob_blood(src)
				I.forceMove(src)
				src.grabbedby(user, 1, item_override = I)
				next_attack_msg += " <span class='userdanger'>[I] is stuck in [src]!</span>"
			var/haha = user.used_intent.blade_class
			if(newforce > 5)
				if(haha != BCLASS_BLUNT)
					I.add_mob_blood(src)
					var/turf/location = get_turf(src)
					add_splatter_floor(location)
					if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
						user.add_mob_blood(src)
			if(newforce > 15)
				if(haha == BCLASS_BLUNT)
					I.add_mob_blood(src)
					var/turf/location = get_turf(src)
					add_splatter_floor(location)
					if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
						user.add_mob_blood(src)
	send_item_attack_message(I, user, hitlim)
	if(I.force)
		return TRUE

/mob/living/simple_animal/attacked_by(obj/item/I, mob/living/user)
	if(I.force < force_threshold || I.damtype == STAMINA)
		playsound(loc, 'sound/blank.ogg', I.get_clamped_volume(), TRUE, -1)
	else
		return ..()

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)
	if(force && !user.used_intent.tranged && !user.used_intent.tshield)
		if(proximity_flag && isopenturf(target) && !user.used_intent?.noaa)
			var/adf = user.used_intent.clickcd
			if(istype(user.rmb_intent, /datum/rmb_intent/aimed))
				adf = round(adf * 1.4)
			if(istype(user.rmb_intent, /datum/rmb_intent/swift))
				adf = round(adf * 0.6)
			user.changeNext_move(adf)
			user.do_attack_animation(target, visual_effect_icon = user.used_intent.animname)
			playsound(get_turf(src), pick(swingsound), 100, FALSE, -1)
			user.aftermiss()
		if(!proximity_flag && ismob(target) && !user.used_intent?.noaa) //this block invokes miss cost clicking on seomone who isn't adjacent to you
			var/adf = user.used_intent.clickcd
			if(istype(user.rmb_intent, /datum/rmb_intent/aimed))
				adf = round(adf * 1.4)
			if(istype(user.rmb_intent, /datum/rmb_intent/swift))
				adf = round(adf * 0.6)
			user.changeNext_move(adf)
			user.do_attack_animation(target, visual_effect_icon = user.used_intent.animname)
			playsound(get_turf(src), pick(swingsound), 100, FALSE, -1)
			user.aftermiss()

// Called if the target gets deleted by our attack
/obj/item/proc/attack_qdeleted(atom/target, mob/user, proximity_flag, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_QDELETED, target, user, proximity_flag, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK_QDELETED, target, user, proximity_flag, click_parameters)

/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return CLAMP((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return CLAMP(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	var/message_verb = "attacked"
	if(user.used_intent)
		message_verb = "[pick(user.used_intent.attack_verb)]"
	else if(!I.force)
		return
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"
	var/attack_message = "[src] is [message_verb][message_hit_area] with [I]!"
	var/attack_message_local = "I'm [message_verb][message_hit_area] with [I]!"
	if(user in viewers(src, null))
		attack_message = "[user] [message_verb] [src][message_hit_area] with [I]!"
		attack_message_local = "[user] [message_verb] me[message_hit_area] with [I]!"
	visible_message("<span class='danger'>[attack_message][next_attack_msg.Join()]</span>",\
		"<span class='danger'>[attack_message_local][next_attack_msg.Join()]</span>", null, COMBAT_MESSAGE_RANGE)
	next_attack_msg.Cut()
	return 1
