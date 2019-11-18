/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	if(tool_attack_chain(user, target))
		return
	// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
	var/resolved = target.attackby(src, user, params)
	if(resolved || QDELETED(target) || QDELETED(src))
		return
	afterattack(target, user, TRUE, params) // TRUE: clicking something Adjacent



//Checks if the item can work as a tool, calling the appropriate tool behavior on the target
/obj/item/proc/tool_attack_chain(mob/user, atom/target)
	if(!tool_behaviour)
		return FALSE

	return target.tool_act(user, src, tool_behaviour)


// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	add_fingerprint(user, "attack_self")
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_NO_INTERACT)
		return
	return


/atom/proc/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user, "attackby", I)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, I, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE


/obj/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return TRUE

	if(user.a_intent != INTENT_HARM)
		return

	if(obj_flags & CAN_BE_HIT)
		return I.attack_obj(src, user)


/obj/item/proc/attack_obj(obj/O, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_OBJ, O, user) & COMPONENT_NO_ATTACK_OBJ)
		return
	if(flags_item & NOBLUDGEON)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(O, used_item = src)
	return O.attacked_by(src, user)


/atom/movable/proc/attacked_by()
	return


/obj/attacked_by(obj/item/I, mob/living/user)
	if(I.force)
		user.visible_message("<span class='warning'>[user] hits [src] with [I]!</span>", \
					"<span class='warning'>You hit [src] with [I]!</span>")
		log_combat(user, src, "attacked", I)
		. = TRUE
	take_damage(I.force, I.damtype, "melee")

/mob/living/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(.)
		return TRUE
	user.changeNext_move(I.attack_speed)
	return I.attack(src, user)


// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)
	return


/obj/item/proc/attack(mob/living/M, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user) & COMPONENT_ITEM_NO_ATTACK)
		return
	if(SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, src) & COMPONENT_ITEM_NO_ATTACK)
		return

	if(flags_item & NOBLUDGEON)
		return FALSE

	if(M.can_be_operated_on() && do_surgery(M,user,src)) //Checks if mob is lying down on table for surgery
		return FALSE

	/////////////////////////

	log_combat(user, M, "attacked", src, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])")

	/////////////////////////

	var/power = force

	if(user.mind && user.mind.cm_skills)
		power = round(power * (1 + 0.3*user.mind.cm_skills.melee_weapons)) //30% bonus per melee level

	if(!ishuman(M))
		var/showname = "."
		if(user)
			showname = " by [user]."
		if(!(user in viewers(M, null)))
			showname = "."

		var/used_verb = "attacked"
		if(LAZYLEN(attack_verb))
			used_verb = pick(attack_verb)
		user.visible_message("<span class='danger'>[M] has been [used_verb] with [src][showname].</span>",
			"<span class='danger'>You attack [M] with [src].</span>", null, 5)

		if(!prob(user.melee_accuracy))
			user.do_attack_animation(M)
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE)
			user.visible_message("<span class='danger'>[user] misses [M] with \the [src]!</span>", null, null, 5)
			return FALSE

		user.do_attack_animation(M, used_item = src)

		if(hitsound)
			playsound(loc, hitsound, 25, TRUE)
		switch(damtype)
			if("brute")
				M.apply_damage(power, BRUTE, user.zone_selected, M.get_living_armor("melee", user.zone_selected))
			if("fire")
				if(M.apply_damage(power, BURN, user.zone_selected, M.get_living_armor(damtype, user.zone_selected)))
					to_chat(M, "<span class='warning'>It burns!</span>")
		UPDATEHEALTH(M)
	else
		var/mob/living/carbon/human/H = M
		var/hit = H.attacked_by(src, user)
		if (hit && hitsound)
			playsound(loc, hitsound, 25, TRUE)
		return hit
	return TRUE
