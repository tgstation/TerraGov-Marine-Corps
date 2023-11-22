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


///Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)
	add_fingerprint(user, "attack_self")
	if(!can_interact(user))
		return
	interact(user)

/atom/proc/attackby(obj/item/I, mob/user, params)
	SIGNAL_HANDLER_DOES_SLEEP
	add_fingerprint(user, "attackby", I)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACKBY, I, user, params) & COMPONENT_NO_AFTERATTACK)
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
	var/power = I.force + round(I.force * MELEE_SKILL_DAM_BUFF * user.skills.getRating(SKILL_MELEE_WEAPONS))
	take_damage(power, I.damtype, MELEE)
	return TRUE


/obj/attack_powerloader(mob/living/user, obj/item/powerloader_clamp/attached_clamp)
	. = ..()
	if(.)
		return

	if(attached_clamp.loaded)
		return

	if(!CHECK_BITFIELD(interaction_flags, INTERACT_POWERLOADER_PICKUP_ALLOWED) && !CHECK_BITFIELD(interaction_flags, INTERACT_POWERLOADER_PICKUP_ALLOWED_BYPASS_ANCHOR))
		to_chat(user, span_notice("[attached_clamp.linked_powerloader] cannot pick up [src]!"))
		return

	if(anchored && !CHECK_BITFIELD(interaction_flags, INTERACT_POWERLOADER_PICKUP_ALLOWED_BYPASS_ANCHOR))
		to_chat(user, span_notice("[src] is bolted to the ground."))
		return

	forceMove(attached_clamp.linked_powerloader)
	attached_clamp.loaded = src
	playsound(attached_clamp.linked_powerloader, 'sound/machines/hydraulics_2.ogg', 40, 1)
	attached_clamp.update_icon()
	user.visible_message(span_notice("[user] grabs [attached_clamp.loaded] with [attached_clamp]."),
	span_notice("You grab [attached_clamp.loaded] with [attached_clamp]."))

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

	var/power = I.force + round(I.force * MELEE_SKILL_DAM_BUFF * user.skills.getRating(SKILL_MELEE_WEAPONS))

	switch(I.damtype)
		if(BRUTE)
			apply_damage(power, BRUTE, user.zone_selected, MELEE, I.sharp, I.edge, FALSE, I.penetration)
		if(BURN)
			if(apply_damage(power, BURN, user.zone_selected, FIRE, I.sharp, I.edge, FALSE, I.penetration))
				attack_message_local = "[attack_message_local] It burns!"
		if(STAMINA)
			apply_damage(power, STAMINA, user.zone_selected, MELEE, I.sharp, I.edge, FALSE, I.penetration)

	visible_message(span_danger("[attack_message]"),
		span_userdanger("[attack_message_local]"), null, COMBAT_MESSAGE_RANGE)

	UPDATEHEALTH(src)

	record_melee_damage(user, power)
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

	// TODO terrible placement move this up the stack or something
	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL)
		return FALSE

	if(M.can_be_operated_on() && do_surgery(M, user, src)) //Checks if mob is lying down on table for surgery
		return TRUE

	if(flags_item & NOBLUDGEON)
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

	if(can_lay_cable() && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = I
		coil.place_turf(src, user)
		return TRUE
	else if(can_have_cabling() && istype(I, /obj/item/stack/pipe_cleaner_coil))
		var/obj/item/stack/pipe_cleaner_coil/coil = I
		for(var/obj/structure/pipe_cleaner/LC in src)
			if(!LC.d1 || !LC.d2)
				LC.attackby(I, user)
				return
		coil.place_turf(src, user)
		return TRUE

	return I.attack_turf(src, user)

/turf/attack_powerloader(mob/living/user, obj/item/powerloader_clamp/attached_clamp)
	. = ..()
	if(.)
		return

	if(!attached_clamp.loaded || density) //no picking up turfs
		return

	for(var/i in contents)
		var/atom/movable/blocky_stuff = i
		if(!blocky_stuff.density)
			continue
		to_chat(user, span_warning("You can't drop [attached_clamp.loaded] here, [blocky_stuff] blocks the way."))
		return
	if(attached_clamp.loaded.bound_height > 32)
		var/turf/next_turf = get_step(src, NORTH)
		if(next_turf.density)
			to_chat(user, span_warning("You can't drop [attached_clamp.loaded] here, something blocks the way."))
			return
		for(var/i in next_turf.contents)
			var/atom/movable/blocky_stuff = i
			if(!blocky_stuff.density)
				continue
			to_chat(user, span_warning("You can't drop [attached_clamp.loaded] here, [blocky_stuff] blocks the way."))
			return
	if(attached_clamp.loaded.bound_width > 32)
		var/turf/next_turf = get_step(src, EAST)
		if(next_turf.density)
			to_chat(user, span_warning("You can't drop [attached_clamp.loaded] here, something blocks the way."))
			return
		for(var/i in next_turf.contents)
			var/atom/movable/blocky_stuff = i
			if(!blocky_stuff.density)
				continue
			to_chat(user, span_warning("You can't drop [attached_clamp.loaded] here, [blocky_stuff] blocks the way."))
			return

	user.visible_message(span_notice("[user] drops [attached_clamp.loaded] onto [src]."),
	span_notice("You drop [attached_clamp.loaded] onto [src]."))
	attached_clamp.loaded.forceMove(src)
	attached_clamp.loaded = null
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	attached_clamp.update_icon()

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
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACKBY_ALTERNATE, I, user, params) & COMPONENT_NO_AFTERATTACK)
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

	var/power = I.force + round(I.force * MELEE_SKILL_DAM_BUFF * user.skills.getRating(SKILL_MELEE_WEAPONS))

	switch(I.damtype)
		if(BRUTE)
			apply_damage(power, BRUTE, user.zone_selected, MELEE, I.sharp, I.edge, FALSE, I.penetration)
		if(BURN)
			if(apply_damage(power, BURN, user.zone_selected, FIRE, I.sharp, I.edge, FALSE, I.penetration))
				attack_message_local = "[attack_message_local] It burns!"

	visible_message(span_danger("[attack_message]"),
		span_userdanger("[attack_message_local]"), null, COMBAT_MESSAGE_RANGE)

	UPDATEHEALTH(src)

	record_melee_damage(user, power)
	log_combat(user, src, "attacked", I, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)]) (RAW DMG: [power])")
	if(power && !user.mind?.bypass_ff && !mind?.bypass_ff && user.faction == faction)
		var/turf/T = get_turf(src)
		user.ff_check(power, src)
		log_ffattack("[key_name(user)] attacked [key_name(src)] with \the [I] in [AREACOORD(T)] (RAW DMG: [power]).")
		msg_admin_ff("[ADMIN_TPMONTY(user)] attacked [ADMIN_TPMONTY(src)] with \the [I] in [ADMIN_VERBOSEJMP(T)] (RAW DMG: [power]).")

	return TRUE
