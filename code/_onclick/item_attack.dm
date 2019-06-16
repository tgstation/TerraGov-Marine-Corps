
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
	user.changeNext_move(I.attack_speed)


/obj/item/storage/attackby(obj/item/I, mob/user, params)
	. = ..()
	user.changeNext_move(CLICK_CD_FASTEST)


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
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user)

	if(flags_item & NOBLUDGEON)
		return

	if (!istype(M)) // not sure if this is the right thing...
		return 0

	if (M.can_be_operated_on())        //Checks if mob is lying down on table for surgery
		if (do_surgery(M,user,src))
			return 0

	/////////////////////////

	log_combat(user, M, "attacked", src, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])")
	msg_admin_attack("[key_name(user)] attacked [key_name(M)] with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])" )

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
		if(attack_verb && attack_verb.len)
			used_verb = pick(attack_verb)
		user.visible_message("<span class='danger'>[M] has been [used_verb] with [src][showname].</span>",\
						"<span class='danger'>You attack [M] with [src].</span>", null, 5)

		user.animation_attack_on(M)
		user.flick_attack_overlay(M, "punch")

		if(hitsound)
			playsound(loc, hitsound, 25, 1)
		switch(damtype)
			if("brute")
				M.apply_damage(power,BRUTE)
			if("fire")
				M.apply_damage(power,BURN)
				to_chat(M, "<span class='warning'>It burns!</span>")
		M.updatehealth()
	else
		var/mob/living/carbon/human/H = M
		var/hit = H.attacked_by(src, user)
		if (hit && hitsound)
			playsound(loc, hitsound, 25, 1)
		H.camo_off_process(SCOUT_CLOAK_OFF_ATTACK)
		return hit
	return 1
