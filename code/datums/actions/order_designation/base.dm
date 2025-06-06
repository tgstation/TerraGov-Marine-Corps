///Build designation mode
#define BUILD_DESIGNATOR_MODE "build_designator_mode"
///Interact designation mode
#define INTERACT_DESIGNATOR_MODE "interact_designator_mode"

GLOBAL_LIST_INIT(designator_mode_image_list, list(
	INTERACT_DESIGNATOR_MODE = image('icons/mob/actions.dmi', icon_state = "interact_designator"),
	BUILD_DESIGNATOR_MODE = image('icons/mob/actions.dmi', icon_state = "build_designator"),
))

/datum/action/ability/activable/build_designator
	name = "Interact Designator"
	desc = "Order your underlings around."
	action_icon_state = "interact_designator"
	action_icon = 'icons/mob/actions.dmi'
	use_state_flags = ABILITY_TARGET_SELF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_PLACE_HOLOGRAM,
		KEYBINDING_ALTERNATE = COMSIG_ABILITY_SELECT_BUILDTYPE,
	)
	///What function this action is currently on
	var/designator_mode = INTERACT_DESIGNATOR_MODE

/datum/action/ability/activable/build_designator/Destroy()
	QDEL_NULL(hologram)
	selected_mob = null
	return ..()

/datum/action/ability/activable/build_designator/should_show()
	. = ..()
	if(!.)
		return
	return owner.skills.getRating(SKILL_LEADERSHIP) >= SKILL_LEAD_TRAINED

/datum/action/ability/activable/build_designator/can_use_action()
	return owner.skills.getRating(SKILL_LEADERSHIP) >= SKILL_LEAD_TRAINED

/datum/action/ability/activable/build_designator/on_selection()
	activate_mode(designator_mode)

/datum/action/ability/activable/build_designator/on_deselection()
	deactivate_mode(designator_mode)

/datum/action/ability/activable/build_designator/action_activate()
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.selected_ability == src)
		deselect()
		return
	return ..()

/datum/action/ability/activable/build_designator/use_ability(atom/A)
	if(!can_use_action())
		return
	if(!A)
		return FALSE
	switch(designator_mode)
		if(BUILD_DESIGNATOR_MODE)
			return use_build_ability(A)

		if(INTERACT_DESIGNATOR_MODE)
			return use_interact_ability(A)

/datum/action/ability/activable/build_designator/alternate_action_activate()
	if(!can_use_action())
		return
	switch(designator_mode)
		if(BUILD_DESIGNATOR_MODE)
			INVOKE_ASYNC(src, PROC_REF(select_structure))
		if(INTERACT_DESIGNATOR_MODE)
			INVOKE_ASYNC(src, PROC_REF(select_mode))

///Tells overwatch we're overriding the radial selection
/datum/action/ability/activable/build_designator/proc/override_cic_radial(datum/source)
	SIGNAL_HANDLER
	return OVERWATCH_RADIAL_HIDE

///Selects a mode
/datum/action/ability/activable/build_designator/proc/select_mode()
	var/mode_choice = show_radial_menu(owner, owner?.client?.eye, GLOB.designator_mode_image_list)
	if(!mode_choice)
		return
	if(mode_choice == designator_mode)
		return
	swap_mode(mode_choice)

///Swaps our mode to a new one
/datum/action/ability/activable/build_designator/proc/swap_mode(new_mode)
	deactivate_mode(designator_mode)
	designator_mode = new_mode
	activate_mode(new_mode)

///Toggles off the current mode
/datum/action/ability/activable/build_designator/proc/deactivate_mode(old_mode)
	UnregisterSignal(owner, COMSIG_DO_OVERWATCH_RADIAL)
	switch(old_mode)
		if(BUILD_DESIGNATOR_MODE)
			cleanup_hologram()
			UnregisterSignal(owner, list(COMSIG_ATOM_MOUSE_ENTERED, COMSIG_ATOM_DIR_CHANGE))
		if(INTERACT_DESIGNATOR_MODE)
			if(selected_mob)
				unindicate_target(selected_mob)
				selected_mob = null

///Toggles on the new mode
/datum/action/ability/activable/build_designator/proc/activate_mode(new_mode)
	RegisterSignal(owner, COMSIG_DO_OVERWATCH_RADIAL, PROC_REF(override_cic_radial))
	switch(new_mode)
		if(BUILD_DESIGNATOR_MODE)
			RegisterSignal(owner, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(show_hologram_call))
			RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_owner_rotate))
			target_flags = ABILITY_TURF_TARGET
			use_state_flags = NONE
			action_icon_state = "build_designator"
			name = "Construction Designator"
			desc = "Place a designator for construction."
		if(INTERACT_DESIGNATOR_MODE)
			target_flags = NONE
			use_state_flags = ABILITY_TARGET_SELF
			action_icon_state = "interact_designator"
			name = "Interact Designator"
			desc = "Order your underlings around."
	update_button_icon()
