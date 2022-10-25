/obj/item/proc/melee_attack_chain(mob/user, atom/target, params, rightclick)
	if(preattack(target, user, params))
		return
	if(rightclick)
		return melee_attack_chain_alternate(user, target, params)
	if(tool_behaviour && tool_attack_chain(user, target))
		return
	// Return TRUE in attackby() to prevent afterattack() effects (when safely moving items for example)
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
	SIGNAL_HANDLER_DOES_SLEEP
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
	user.visible_message(span_warning("[user] hits [src] with [I]!"),
		span_warning("You hit [src] with [I]!"), visible_message_flags = COMBAT_MESSAGE)
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
			apply_damage(modify_by_armor(power, MELEE, I.penetration, user.zone_selected), BRUTE, user.zone_selected)
		if(BURN)
			if(apply_damage(modify_by_armor(power, FIRE, I.penetration, user.zone_selected), BURN, user.zone_selected))
				attack_message_local = "[attack_message_local] It burns!"
		if(STAMINA)
			apply_damage(modify_by_armor(power, MELEE, I.penetration, user.zone_selected), STAMINA, user.zone_selected)

	visible_message(span_danger("[attack_message]"),
		span_userdanger("[attack_message_local]"), null, COMBAT_MESSAGE_RANGE)

	UPDATEHEALTH(src)

	log_combat(user, src, "attacked", I, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)]) (RAW DMG: [power])")
	if(power && !user.mind?.bypass_ff && !mind?.bypass_ff && user.faction == faction)
		var/turf/T = get_turf(src)
		user.ff_check(power, src)
		log_ffattack("[key_name(user)] attacked [key_name(src)] with \the [I] in [AREACOORD(T)] (RAW DMG: [power]).")
		msg_admin_ff("[ADMIN_TPMONTY(user)] attacked [ADMIN_TPMONTY(src)] with \the [I] in [ADMIN_VERBOSEJMP(T)] (RAW DMG: [power]).")

	return TRUE


/mob/living/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(.)
		return TRUE
	user.changeNext_move(I.attack_speed)
	return I.attack(src, user)


// has_proximity is TRUE if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, has_proximity, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK, target, user, has_proximity, click_parameters)
	return


/obj/item/proc/attack(mob/living/M, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user) & COMPONENT_ITEM_NO_ATTACK)
		return FALSE
	if(SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, src) & COMPONENT_ITEM_NO_ATTACK)
		return FALSE

	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //Can't attack the incorporeal
		return FALSE

	if(flags_item & NOBLUDGEON)
		return FALSE

	if(M.can_be_operated_on() && do_surgery(M,user,src)) //Checks if mob is lying down on table for surgery
		return FALSE

	if(!force)
		return FALSE

	. = M.attacked_by(src, user)
	if(. && hitsound)
		playsound(loc, hitsound, 25, TRUE)

/turf/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return TRUE

	return I.attack_turf(src, user)

/obj/item/proc/attack_turf(turf/T, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_TURF, T, user) & COMPONENT_NO_ATTACK_TURF)
		return FALSE
	return FALSE




///////////////
///RIGHT CLICK CODE FROM HERE
///
/// Most of this is basically whats above for left click but broken down, add more as needed
///////////////

/**
 * A less complex version of melee_attack_chain, called when rightclicking with an item on something
 * Arguments:
 * user: mob attacking with this item
 * target: atom being clicked on
 * params: passed down params from Click()
 */
/obj/item/proc/melee_attack_chain_alternate(mob/user, atom/target, params)
	// Return TRUE in attackby_alternate() to prevent afterattack() effects (when safely moving items for example)
	var/resolved = target.attackby_alternate(src, user, params)
	if(resolved || QDELETED(target) || QDELETED(src))
		return
	afterattack_alternate(target, user, TRUE, params) // TRUE: clicking something Adjacent

/atom/proc/attackby_alternate(obj/item/I, mob/user, params)
	add_fingerprint(user, "attackby_alternate", I)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY_ALTERNATE, I, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/mob/living/attackby_alternate(obj/item/I, mob/living/user, params)
	. = ..()
	if(.)
		return TRUE
	user.changeNext_move(I.attack_speed_alternate)
	return I.attack_alternate(src, user)

// has_proximity is TRUE if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack_alternate(atom/target, mob/user, has_proximity, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK_ALTERNATE, target, user, has_proximity, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK_ALTERNATE, target, user, has_proximity, click_parameters)
	return


/**
 * attack_alternate
 *
 * called when the a mob right click attacks on another mob with an item
 * Arguments:
 * M: the target being attacked
 * user: the person clicking
 */
/obj/item/proc/attack_alternate(mob/living/M, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_ALTERNATE, M, user) & COMPONENT_ITEM_NO_ATTACK)
		return FALSE
	if(SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK_ALTERNATE, M, src) & COMPONENT_ITEM_NO_ATTACK)
		return FALSE

	if(flags_item & NOBLUDGEON)
		return FALSE

	if(!force)
		return FALSE

	. = M.attacked_by_alternate(src, user)
	if(. && hitsound)
		playsound(loc, hitsound, 25, TRUE)

/**
 * /mob/living attacked_by_alternate //TODO!! MAKE THIS UNIQUE FROM NORMAL ATTACKED_BY AS A FEATURE
 *
 * Called when a mob is attacked by an item
 * while the user clicked on them with left click
 * Arguments:
 * I: item this mob is being attacked by
 * user: the attacker
 * def_zone: targetted area that will be attacked
 */
/mob/living/proc/attacked_by_alternate(obj/item/I, mob/living/user, def_zone)
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

	visible_message(span_danger("[attack_message]"),
		span_userdanger("[attack_message_local]"), null, COMBAT_MESSAGE_RANGE)

	UPDATEHEALTH(src)

	log_combat(user, src, "attacked", I, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)]) (RAW DMG: [power])")
	if(power && !user.mind?.bypass_ff && !mind?.bypass_ff && user.faction == faction)
		var/turf/T = get_turf(src)
		user.ff_check(power, src)
		log_ffattack("[key_name(user)] attacked [key_name(src)] with \the [I] in [AREACOORD(T)] (RAW DMG: [power]).")
		msg_admin_ff("[ADMIN_TPMONTY(user)] attacked [ADMIN_TPMONTY(src)] with \the [I] in [ADMIN_VERBOSEJMP(T)] (RAW DMG: [power]).")

	return TRUE
