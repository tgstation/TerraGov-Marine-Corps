//Procs specific to the interaction designation mode

///filter to show selected/interact targets
#define DESIGNATED_TARGET_FILTER "designated_target_filter"
///Designator order alt appearance key
#define ORDER_DESIGNATION_ALT_APPEARANCE "order_designation_alt_appearance"
///Designator order alt appearance key
#define ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE "order_designation_indicate_alt_appearance"
///Designator order target alt appearance key
#define ORDER_DESIGNATION_TARGET_ALT_APPEARANCE "order_designation_target_alt_appearance"
///How long a target stays visually designated for
#define ORDER_DESIGNATION_DURATION 2 SECONDS

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

/datum/action/ability/activable/build_designator
	///Selected mob for interact mode
	var/mob/living/carbon/human/selected_mob

///Interact designation side of use_ability
/datum/action/ability/activable/build_designator/proc/use_interact_ability(atom/target)
	if(selected_mob) //only allow mob to atom interaction, not atom to mob
		if(selected_mob == target || !check_valid_friendly(selected_mob)) //deselect a mob if clicking again, or they are crit etc
			unindicate_target(target)
			selected_mob = null
			return FALSE
		call_interaction(target)
		return TRUE

	//no selected atom
	if(isturf(target))
		designate_target(target) //rally here
		return TRUE
	if(isobj(target))
		designate_target(target) //Interact with/repair this thing
		return TRUE

	if(!ismob(target))
		return FALSE

	if(target == owner)
		designate_target(target) //everyone rally to me
		return TRUE
	if(check_valid_friendly(target))
		select_mob_to_interact(target) //select mob for interacting with something else
		return TRUE
	var/mob/mob_target = target
	if(mob_target.faction != owner.faction)
		designate_target(target) //Put the boots to them, medium style
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

///Creates an image of an atom to be used for alternative appearance purposes
/datum/action/ability/activable/build_designator/proc/get_alt_image(atom/image_target, flash_image = FALSE, order_verb)
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
	switch(order_verb)
		if(ORDER_DESIGNATION_TYPE_ATTACK)
			flash_color = ORDER_DESIGNATION_RED
		if(ORDER_DESIGNATION_TYPE_REPAIR)
			flash_color = ORDER_DESIGNATION_YELLOW
		if(ORDER_DESIGNATION_TYPE_HEAL)
			flash_color = ORDER_DESIGNATION_YELLOW
		if(ORDER_DESIGNATION_TYPE_FOLLOW)
			flash_color = ORDER_DESIGNATION_GREEN

	animate(alt_image, color = flash_color, time = 3, loop = 2)
	animate(color = oldcolor, time = 3)
	return alt_image

///Designates an atom to generally request that people interact with it in some way
/datum/action/ability/activable/build_designator/proc/designate_target(obj/new_target)//i.e. repair, kill, move to, etc
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DESIGNATED_TARGET_SET, new_target)
	var/order_verb = new_target.order_designation_verb(owner)

	var/image/highlight = get_alt_image(new_target, TRUE, order_verb)
	new_target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/faction, ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE, highlight, owner.faction)

	audible_command(new_target, order_verb)

	addtimer(CALLBACK(src, PROC_REF(unindicate_target), new_target), ORDER_DESIGNATION_DURATION)

///Visually selects a friendly mob for later ordering
/datum/action/ability/activable/build_designator/proc/select_mob_to_interact(mob/living/carbon/human/new_target)
	selected_mob = new_target

	var/image/highlight = get_alt_image(new_target)
	new_target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, ORDER_DESIGNATION_ALT_APPEARANCE, highlight, owner)

///Orders a friendly mob to interact with an atom
/datum/action/ability/activable/build_designator/proc/call_interaction(atom/target)
	SEND_SIGNAL(selected_mob, COMSIG_MOB_INTERACTION_DESIGNATED, target) //add contextual info on desired interaction type?

	var/order_verb = target.order_designation_verb(selected_mob)

	var/image/target_highlight = get_alt_image(target, TRUE, order_verb)
	target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/group, ORDER_DESIGNATION_TARGET_ALT_APPEARANCE, target_highlight, list(selected_mob, owner))

	audible_command(target, order_verb, selected_mob)

	addtimer(CALLBACK(src, PROC_REF(unindicate_target), target), ORDER_DESIGNATION_DURATION)

///Generates the applicable audible command for the specific command
/datum/action/ability/activable/build_designator/proc/audible_command(atom/target, order_verb, mob/ordered)
	var/message
	if((target.z != owner.z) || (get_dist(target, owner) > 9))
		message = ";" //radio message
	if(ordered)
		message += "[selected_mob], "
	switch(order_verb)
		if(ORDER_DESIGNATION_TYPE_MOVE)
			message += "move [dir2text(angle_to_dir(Get_Angle(get_turf(owner), get_turf(target))))]!"
		if(ORDER_DESIGNATION_TYPE_ATTACK)
			message += "[pick("attack", "destroy", "target")] [target]!"
		if(ORDER_DESIGNATION_TYPE_REPAIR)
			message += "repair [target]."
		if(ORDER_DESIGNATION_TYPE_HEAL)
			message += "[pick("heal", "triage", "help")] [target]."
		if(ORDER_DESIGNATION_TYPE_FOLLOW)
			message += "follow [target == owner ? "me" : target]."
		if(ORDER_DESIGNATION_TYPE_INTERACT)
			message += "use [target]."
		if(ORDER_DESIGNATION_TYPE_OPEN)
			message += "open [target]."
		if(ORDER_DESIGNATION_TYPE_CLOSE)
			message += "close [target]."
		if(ORDER_DESIGNATION_TYPE_PICKUP)
			message += "[pick("pickup", "grab")] [target]."
	owner.say(message)

///Removes any visual indicators on this atom
/datum/action/ability/activable/build_designator/proc/unindicate_target(atom/old_target)
	old_target.remove_alt_appearance(ORDER_DESIGNATION_ALT_APPEARANCE)
	old_target.remove_alt_appearance(ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE)
	old_target.remove_alt_appearance(ORDER_DESIGNATION_TARGET_ALT_APPEARANCE)
	//send cancel sig?

//////////////////
/atom/proc/order_designation_verb(mob/ordered)
	return ORDER_DESIGNATION_TYPE_INTERACT

/turf/order_designation_verb(mob/ordered)
	return ORDER_DESIGNATION_TYPE_MOVE

/atom/movable/order_designation_verb(mob/ordered)
	if(!faction)
		return ORDER_DESIGNATION_TYPE_INTERACT
	if(ordered.faction == faction)
		return ORDER_DESIGNATION_TYPE_INTERACT
	return ORDER_DESIGNATION_TYPE_ATTACK

/mob/order_designation_verb(mob/ordered)
	if(ordered.faction == faction)
		if(stat) //crit or dead, otherwise people can ask for their own medical help
			return ORDER_DESIGNATION_TYPE_HEAL
		return ORDER_DESIGNATION_TYPE_FOLLOW
	return ORDER_DESIGNATION_TYPE_ATTACK

/obj/order_designation_verb(mob/ordered) //todo:doesnt actually allow repairs at this level, but other procs refer to this level anyway
	if(!faction || ordered.faction == faction)
		return ORDER_DESIGNATION_TYPE_REPAIR
	return ORDER_DESIGNATION_TYPE_ATTACK

/obj/item/order_designation_verb(mob/ordered)
	return ORDER_DESIGNATION_TYPE_PICKUP
