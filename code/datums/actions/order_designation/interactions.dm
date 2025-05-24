//Procs specific to the interaction designation mode

///filter to show selected/interact targets
#define DESIGNATED_TARGET_FILTER "designated_target_filter"
///Designator order alt appearance key
#define ORDER_DESIGNATION_ALT_APPEARANCE "order_designation_alt_appearance"
///Designator order alt appearance key
#define ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE "order_designation_indicate_alt_appearance"
///Designator order target alt appearance key
#define ORDER_DESIGNATION_TARGET_ALT_APPEARANCE "order_designation_target_alt_appearance"

#define ORDER_DESIGNATION_TYPE_MOVE "order_designation_type_move"
#define ORDER_DESIGNATION_TYPE_ATTACK "order_designation_type_attack"
#define ORDER_DESIGNATION_TYPE_REPAIR "order_designation_type_repair"
#define ORDER_DESIGNATION_TYPE_HEAL "order_designation_type_heal"
#define ORDER_DESIGNATION_TYPE_FOLLOW "order_designation_type_follow"
#define ORDER_DESIGNATION_TYPE_INTERACT "order_designation_type_interact"
#define ORDER_DESIGNATION_TYPE_OPEN "order_designation_type_open"
#define ORDER_DESIGNATION_TYPE_CLOSE "order_designation_type_close"
#define ORDER_DESIGNATION_TYPE_PICKUP "order_designation_type_pickup"

#define ORDER_DESIGNATION_BLUE "#06e2cc"
#define ORDER_DESIGNATION_RED "#9d0b0b"
#define ORDER_DESIGNATION_YELLOW "#fbff00"
#define ORDER_DESIGNATION_GREEN "#1bcc03"

///How often you can designate something
#define ORDER_DESIGNATION_CD 1 SECONDS

/datum/action/ability/activable/build_designator
	///Selected mob for interact mode
	var/mob/living/carbon/human/selected_mob
	///used for weapon cooldown after use
	COOLDOWN_DECLARE(order_cooldown)

///Interact designation side of use_ability
/datum/action/ability/activable/build_designator/proc/use_interact_ability(atom/target)
	if(selected_mob)
		if(selected_mob == target || !check_valid_friendly(selected_mob)) //deselect a mob if clicking again, or they are crit etc
			unindicate_target(target)
			selected_mob = null
			return FALSE
	else if(check_valid_friendly(target))
		select_mob_to_interact(target)
		return TRUE

	designate_target(target)
	return TRUE

///Checks if a mob is able to recieve your orders
/datum/action/ability/activable/build_designator/proc/check_valid_friendly(mob/living/carbon/human/candidate)
	if(!ishuman(candidate))
		return FALSE
	if(candidate.faction != owner.faction)
		return FALSE
	if(candidate.stat)
		return FALSE
	if(candidate == owner)
		return FALSE
	return TRUE

///Visually selects a friendly mob for later ordering
/datum/action/ability/activable/build_designator/proc/select_mob_to_interact(mob/living/carbon/human/new_target)
	selected_mob = new_target

	var/image/highlight = get_alt_image(new_target)
	new_target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, ORDER_DESIGNATION_ALT_APPEARANCE, highlight, owner)

///Designates an atom for interaction
/datum/action/ability/activable/build_designator/proc/designate_target(atom/target)
	if(!COOLDOWN_FINISHED(src, order_cooldown))
		return
	COOLDOWN_START(src, order_cooldown, ORDER_DESIGNATION_CD)

	var/order_action = target.get_order_designation_type(selected_mob ? selected_mob : owner)
	var/image/target_highlight = get_alt_image(target, TRUE, order_action)

	if(selected_mob) //ordering a specific mob to do something
		SEND_SIGNAL(selected_mob, COMSIG_MOB_INTERACTION_DESIGNATED, target) //todo: Maybe make the NPC behavior based on order_action?
		target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/group, ORDER_DESIGNATION_TARGET_ALT_APPEARANCE, target_highlight, list(selected_mob, owner))
	else //Ordering everyone/anyone to do something
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DESIGNATED_TARGET_SET, target)
		target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/faction, ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE, target_highlight, owner.faction)

	audible_command(target, order_action, selected_mob)
	addtimer(CALLBACK(src, PROC_REF(unindicate_target), target), 1 SECONDS)

///Removes any visual indicators on this atom
/datum/action/ability/activable/build_designator/proc/unindicate_target(atom/old_target)
	old_target.remove_alt_appearance(ORDER_DESIGNATION_ALT_APPEARANCE)
	old_target.remove_alt_appearance(ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE)
	old_target.remove_alt_appearance(ORDER_DESIGNATION_TARGET_ALT_APPEARANCE)

///Creates an image of an atom to be used for alternative appearance purposes
/datum/action/ability/activable/build_designator/proc/get_alt_image(atom/image_target, flash_image = FALSE, order_action)
	var/image/alt_image = image(loc = image_target) //todo: Better alternative?
	alt_image.appearance = image_target.appearance
	alt_image.pixel_w = 0
	alt_image.pixel_x = 0
	alt_image.pixel_y = 0
	alt_image.pixel_z = 0
	alt_image.dir = image_target.dir
	alt_image.add_filter(DESIGNATED_TARGET_FILTER, 2, outline_filter(1, COLOR_PULSE_BLUE))
	alt_image.override = TRUE
	alt_image.RegisterSignal(image_target, COMSIG_ATOM_DIR_CHANGE, TYPE_PROC_REF(/image, on_owner_dir_change))

	if(!flash_image)
		return alt_image

	var/oldcolor = alt_image.color
	var/flash_color = ORDER_DESIGNATION_BLUE
	switch(order_action)
		if(ORDER_DESIGNATION_TYPE_ATTACK)
			flash_color = ORDER_DESIGNATION_RED
		if(ORDER_DESIGNATION_TYPE_REPAIR)
			flash_color = ORDER_DESIGNATION_YELLOW
		if(ORDER_DESIGNATION_TYPE_HEAL)
			flash_color = ORDER_DESIGNATION_YELLOW
		if(ORDER_DESIGNATION_TYPE_FOLLOW)
			flash_color = ORDER_DESIGNATION_GREEN

	animate(alt_image, color = flash_color, time = 0.3 SECONDS, loop = 2)
	animate(color = oldcolor, time =  0.3 SECONDS)
	return alt_image

///Generates the applicable audible command for the specific command
/datum/action/ability/activable/build_designator/proc/audible_command(atom/target, order_action, mob/ordered)
	var/message
	if((target.z != owner.z) || (get_dist(target, owner) > 9))
		message = ";" //radio message
	switch(order_action)
		if(ORDER_DESIGNATION_TYPE_MOVE)
			message += "[ordered ? "[selected_mob], " : "everyone, "]move [dir2text(angle_to_dir(Get_Angle(get_turf(owner), get_turf(target))))]!"
		if(ORDER_DESIGNATION_TYPE_ATTACK)
			message += "[ordered ? "[selected_mob], " : "everyone, "][pick("attack", "destroy", "target")] [target]!"
		if(ORDER_DESIGNATION_TYPE_REPAIR)
			message += "[ordered ? "[selected_mob], " : null]repair [target]."
		if(ORDER_DESIGNATION_TYPE_HEAL)
			message += "[ordered ? "[selected_mob], " : "someone, "][pick("heal", "triage", "help")] [target]!"
		if(ORDER_DESIGNATION_TYPE_FOLLOW)
			message += "[ordered ? "[selected_mob], " : "everyone, "]follow [target == owner ? "me" : target]!"
		if(ORDER_DESIGNATION_TYPE_INTERACT)
			message += "[ordered ? "[selected_mob], " : "someone, "]use [target]."
		if(ORDER_DESIGNATION_TYPE_OPEN)
			message += "[ordered ? "[selected_mob], " : "someone "]open [target]."
		if(ORDER_DESIGNATION_TYPE_CLOSE)
			message += "[ordered ? "[selected_mob], " : "someone "]close [target]."
		if(ORDER_DESIGNATION_TYPE_PICKUP)
			message += "[ordered ? "[selected_mob], " : "someone "][pick("pickup", "grab")] [target]."

	owner.say(message)


///Returns the type of interaction a mob is expected to have with this atom
/atom/proc/get_order_designation_type(mob/ordered)
	return ORDER_DESIGNATION_TYPE_INTERACT

/turf/get_order_designation_type(mob/ordered)
	return ORDER_DESIGNATION_TYPE_MOVE

/turf/closed/interior/tank/door/get_order_designation_type(mob/ordered)
	return ORDER_DESIGNATION_TYPE_INTERACT

/atom/movable/get_order_designation_type(mob/ordered)
	if(!faction)
		return ORDER_DESIGNATION_TYPE_INTERACT
	if(ordered.faction == faction)
		return ORDER_DESIGNATION_TYPE_INTERACT
	return ORDER_DESIGNATION_TYPE_ATTACK

/mob/get_order_designation_type(mob/ordered)
	if(ordered.faction == faction)
		if(stat) //crit or dead, otherwise people can ask for their own medical help
			return ORDER_DESIGNATION_TYPE_HEAL
		return ORDER_DESIGNATION_TYPE_FOLLOW
	return ORDER_DESIGNATION_TYPE_ATTACK

/obj/get_order_designation_type(mob/ordered) //todo:doesnt actually allow repairs at this level, but other procs refer to this level anyway
	if(!faction || ordered.faction == faction)
		return ORDER_DESIGNATION_TYPE_REPAIR
	return ORDER_DESIGNATION_TYPE_ATTACK

/obj/effect/build_designator/get_order_designation_type(mob/ordered)
	return ORDER_DESIGNATION_TYPE_INTERACT

/obj/machinery/door/get_order_designation_type(mob/ordered)
	if(density)
		return ORDER_DESIGNATION_TYPE_OPEN
	return ORDER_DESIGNATION_TYPE_CLOSE

/obj/alien/get_order_designation_type(mob/ordered)
	return ORDER_DESIGNATION_TYPE_ATTACK

/obj/item/get_order_designation_type(mob/ordered)
	return ORDER_DESIGNATION_TYPE_PICKUP

/obj/item/storage/box/visual/magazine/get_order_designation_type(mob/ordered)
	return ORDER_DESIGNATION_TYPE_INTERACT


#undef DESIGNATED_TARGET_FILTER
#undef ORDER_DESIGNATION_ALT_APPEARANCE
#undef ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE
#undef ORDER_DESIGNATION_TARGET_ALT_APPEARANCE

#undef ORDER_DESIGNATION_TYPE_MOVE
#undef ORDER_DESIGNATION_TYPE_ATTACK
#undef ORDER_DESIGNATION_TYPE_REPAIR
#undef ORDER_DESIGNATION_TYPE_HEAL
#undef ORDER_DESIGNATION_TYPE_FOLLOW
#undef ORDER_DESIGNATION_TYPE_INTERACT
#undef ORDER_DESIGNATION_TYPE_OPEN
#undef ORDER_DESIGNATION_TYPE_CLOSE
#undef ORDER_DESIGNATION_TYPE_PICKUP

#undef ORDER_DESIGNATION_BLUE
#undef ORDER_DESIGNATION_RED
#undef ORDER_DESIGNATION_YELLOW
#undef ORDER_DESIGNATION_GREEN

#undef ORDER_DESIGNATION_CD
