//Procs specific to the interaction designation mode

///filter to show selected/interact targets
#define DESIGNATED_TARGET_FILTER "designated_target_filter"
///Designator order alt appearance key
#define ORDER_DESIGNATION_ALT_APPEARANCE "order_designation_alt_appearance"
///Designator order alt appearance key
#define ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE "order_designation_indicate_alt_appearance"
///Designator order target alt appearance key
#define ORDER_DESIGNATION_TARGET_ALT_APPEARANCE "order_designation_target_alt_appearance"

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
/datum/action/ability/activable/build_designator/proc/get_alt_image(atom/image_target)
	var/image/alt_image = image(loc = image_target)
	alt_image.appearance = image_target.appearance
	alt_image.pixel_w = 0
	alt_image.pixel_x = 0
	alt_image.pixel_y = 0
	alt_image.pixel_z = 0
	alt_image.dir = image_target.dir
	alt_image.add_filter(DESIGNATED_TARGET_FILTER, 2, outline_filter(1, COLOR_PULSE_BLUE))
	alt_image.override = TRUE
	alt_image.RegisterSignal(image_target, COMSIG_ATOM_DIR_CHANGE, TYPE_PROC_REF(/image, on_owner_dir_change))
	return alt_image

///Designates an atom to generally request that people interact with it in some way
/datum/action/ability/activable/build_designator/proc/designate_target(obj/new_target)//i.e. repair, kill, move to, etc
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DESIGNATED_TARGET_SET, new_target)

	var/image/highlight = get_alt_image(new_target)
	new_target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/faction, ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE, highlight, owner.faction)


	owner.say("Interact with [new_target.name].") //shitty placeholder line
	new_target.balloon_alert_to_viewers("Interact", vision_distance = 9) //ignored_mobs non faction people??

	addtimer(CALLBACK(src, PROC_REF(unindicate_target), new_target), 4 SECONDS)

///Visually selects a friendly mob for later ordering
/datum/action/ability/activable/build_designator/proc/select_mob_to_interact(mob/living/carbon/human/new_target)
	selected_mob = new_target

	var/image/highlight = get_alt_image(new_target)
	new_target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, ORDER_DESIGNATION_ALT_APPEARANCE, highlight, owner)

///Orders a friendly mob to interact with an atom
/datum/action/ability/activable/build_designator/proc/call_interaction(atom/target)
	SEND_SIGNAL(selected_mob, COMSIG_MOB_INTERACTION_DESIGNATED, target) //add contextual info on desired interaction type?

	var/image/target_highlight = get_alt_image(target)
	target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/group, ORDER_DESIGNATION_TARGET_ALT_APPEARANCE, target_highlight, list(selected_mob, owner))
	//beam between them if possible??

	if(isturf(target))
		owner.say("[selected_mob.name], move to [target.name].")
	else
		owner.say("[selected_mob.name], interact with [target.name].") //shitty placeholder line
	target.balloon_alert(selected_mob, "Interact")

	addtimer(CALLBACK(src, PROC_REF(unindicate_target), target), 4 SECONDS)

///Removes any visual indicators on this atom
/datum/action/ability/activable/build_designator/proc/unindicate_target(atom/old_target)
	old_target.remove_alt_appearance(ORDER_DESIGNATION_ALT_APPEARANCE)
	old_target.remove_alt_appearance(ORDER_DESIGNATION_INDICATE_ALT_APPEARANCE)
	old_target.remove_alt_appearance(ORDER_DESIGNATION_TARGET_ALT_APPEARANCE)
	//send cancel sig?
