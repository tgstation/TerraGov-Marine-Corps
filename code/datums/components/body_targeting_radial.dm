/datum/component/body_targeting_radial
	var/active = FALSE
	var/datum/action/toggle_action/toggle_action


/datum/component/body_targeting_radial/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	toggle_action = new(null, "Toggle Body-Targeting Radial", "body_targeting")
	toggle_action.update_button_icon(active)
	toggle_action.give_action(parent)
	RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, .proc/toggle_ability)


/datum/component/body_targeting_radial/Destroy(force, silent)
	QDEL_NULL(toggle_action)
	return ..()


/datum/component/body_targeting_radial/proc/toggle_ability(datum/source)
	active = !active
	if(active)
		RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, .proc/body_targeting_item_attack)
	else
		UnregisterSignal(parent, COMSIG_MOB_ITEM_ATTACK)
	to_chat(parent, "<span class='notice'>Body-Targeting Radial [active ? "A" : "Dea"]ctivated.</span>")
	toggle_action.update_button_icon(active)


/datum/component/body_targeting_radial/proc/body_targeting_item_attack(datum/source, mob/living/target, mob/living/user)
	if(!ishuman(target))
		return
	var/target_zone = radial_medical(target, user)
	if(!target_zone)
		return COMPONENT_ITEM_NO_ATTACK
	user.change_selected_zone(target_zone)


/datum/component/proc/radial_medical(mob/living/carbon/human/target, mob/living/user)
	var/radial_state = ""
	var/datum/limb/part

	var/list/radial_options = list()

	for(var/bodypart in GLOB.target_body_parts)
		part = target.get_limb(bodypart)
		if(!part.burn_dam)
			if(!part.brute_dam)
				radial_state = "radial_[bodypart]_un"
			else
				radial_state = "radial_[bodypart]_brute"
		else
			if(part.brute_dam)
				radial_state = "radial_[bodypart]_both"
			else
				radial_state = "radial_[bodypart]_burn"
		if(part.surgery_open_stage)
			radial_state = "radial_[bodypart]_surgery"

		radial_options += list(bodypart = list(image(icon = 'icons/mob/radial.dmi'), icon_state = radial_state))

	var/choice = show_radial_menu(user, target, radial_options, null, 48, null, TRUE)
	if(!choice)
		return FALSE
	return target.get_limb(choice)
