/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	if(preattack(target, user, params))
		return
	if(tool_behaviour && tool_attack_chain(user, target))
		return
	// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
	var/resolved = target.attackby(src, user, params)
	if(resolved || QDELETED(target) || QDELETED(src))
		return
	afterattack(target, user, TRUE, params) // TRUE: clicking something Adjacent

//Called before any other attack proc.
/obj/item/proc/preattack(atom/target, mob/user, params)
	return FALSE

//Checks if the item can work as a tool, calling the appropriate tool behavior on the target
/obj/item/proc/tool_attack_chain(mob/user, atom/target)
	switch(tool_behaviour)
		if(TOOL_CROWBAR)
			return target.crowbar_act(user, src)
		if(TOOL_MULTITOOL)
			return target.multitool_act(user, src)
		if(TOOL_SCREWDRIVER)
			return target.screwdriver_act(user, src)
		if(TOOL_WRENCH)
			return target.wrench_act(user, src)
		if(TOOL_WIRECUTTER)
			return target.wirecutter_act(user, src)
		if(TOOL_WELDER)
			return target.welder_act(user, src)
		if(TOOL_WELD_CUTTER)
			return target.weld_cut_act(user, src)
		if(TOOL_ANALYZER)
			return target.analyzer_act(user, src)
		if(TOOL_FULTON)
			return target.fulton_act(user, src)


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


/atom/movable/proc/attacked_by(obj/item/I, mob/living/user, def_zone)
	return FALSE


/obj/attacked_by(obj/item/I, mob/living/user, def_zone)
	user.visible_message("<span class='warning'>[user] hits [src] with [I]!</span>",
		"<span class='warning'>You hit [src] with [I]!</span>")
	log_combat(user, src, "attacked", I)
	var/power = I.force + round(I.force * 0.3 * user.skills.getRating("melee_weapons")) //30% bonus per melee level
	take_damage(power, I.damtype, "melee")
	return TRUE


/mob/living/attacked_by(obj/item/I, mob/living/user, def_zone)
	var/message_verb = "attacked"
	if(LAZYLEN(I.attack_verb))
		message_verb = pick(I.attack_verb)
	var/message_hit_area
	if(def_zone)
		message_hit_area = " in the [def_zone]"
	var/attack_message = "[src] is [message_verb][message_hit_area] with [I]!"
	var/attack_message_local = "You're [message_verb][message_hit_area] with [I]!"
	if(user in viewers(src, null))
		attack_message = "[user] [message_verb] [src][message_hit_area] with [I]!"
		attack_message_local = "[user] [message_verb] you[message_hit_area] with [I]!"

	user.do_attack_animation(src, used_item = I)

	var/power = I.force + round(I.force * 0.3 * user.skills.getRating("melee_weapons")) //30% bonus per melee level

	switch(I.damtype)
		if(BRUTE)
			apply_damage(power, BRUTE, user.zone_selected, get_soft_armor("melee", user.zone_selected))
		if(BURN)
			if(apply_damage(power, BURN, user.zone_selected, get_soft_armor("fire", user.zone_selected)))
				attack_message_local = "[attack_message_local] It burns!"

	visible_message("<span class='danger'>[attack_message]</span>",
		"<span class='userdanger'>[attack_message_local]</span>", null, COMBAT_MESSAGE_RANGE)

	UPDATEHEALTH(src)

	log_combat(user, src, "attacked", I, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)]) (RAW DMG: [power])")
	if(power && !user.mind?.bypass_ff && !mind?.bypass_ff && user.faction == faction)
		var/turf/T = get_turf(src)
		log_ffattack("[key_name(user)] attacked [key_name(src)] with \the [I] in [AREACOORD(T)] (RAW DMG: [power]).")
		msg_admin_ff("[ADMIN_TPMONTY(user)] attacked [ADMIN_TPMONTY(src)] with \the [I] in [ADMIN_VERBOSEJMP(T)] (RAW DMG: [power]).")

	return TRUE


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
		return FALSE
	if(SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, src) & COMPONENT_ITEM_NO_ATTACK)
		return FALSE

	if(flags_item & NOBLUDGEON)
		return FALSE

	if(M.can_be_operated_on() && do_surgery(M,user,src)) //Checks if mob is lying down on table for surgery
		return FALSE

	if(!force)
		return FALSE

	if(M != user && !prob(user.melee_accuracy)) // Attacking yourself can't miss
		user.do_attack_animation(M)
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE)
		if(user in viewers(COMBAT_MESSAGE_RANGE, M))
			M.visible_message("<span class='danger'>[user] misses [M] with \the [src]!</span>",
				"<span class='userdanger'>[user] missed us with \the [src]!</span>", null, COMBAT_MESSAGE_RANGE)
		else
			M.visible_message("<span class='avoidharm'>\The [src] misses [M]!</span>",
				"<span class='avoidharm'>\The [src] narrowly misses you!</span>", null, COMBAT_MESSAGE_RANGE)
		log_combat(user, M, "attacked", src, "(missed) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])")
		if(force && !user.mind?.bypass_ff && !M.mind?.bypass_ff && user.faction == M.faction)
			var/turf/T = get_turf(M)
			log_ffattack("[key_name(user)] missed [key_name(M)] with \the [src] in [AREACOORD(T)].")
			msg_admin_ff("[ADMIN_TPMONTY(user)] missed [ADMIN_TPMONTY(M)] with \the [src] in [ADMIN_VERBOSEJMP(T)].")
		return FALSE

	. = M.attacked_by(src, user)
	if(. && hitsound)
		playsound(loc, hitsound, 25, TRUE)
