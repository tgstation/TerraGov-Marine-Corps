///Build designation mode
#define BUILD_DESIGNATOR_MODE "build_designator_mode"
///Interact designation mode
#define INTERACT_DESIGNATOR_MODE "interact_designator_mode"

GLOBAL_LIST_INIT(designator_mode_image_list, list(
	INTERACT_DESIGNATOR_MODE = image('icons/Xeno/actions/construction.dmi', icon_state = RESIN_WALL),
	BUILD_DESIGNATOR_MODE = image('icons/Xeno/actions/construction.dmi', icon_state = BULLETPROOF_WALL),
))

/datum/action/ability/activable/build_designator
	name = "Construction Designator"
	desc = "Place a designator for construction."
	action_icon_state = "build_designator"
	action_icon = 'icons/mob/actions.dmi'
	target_flags = ABILITY_TURF_TARGET
	use_state_flags = ABILITY_TARGET_SELF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_PLACE_HOLOGRAM,
		KEYBINDING_ALTERNATE = COMSIG_ABILITY_SELECT_BUILDTYPE,
	)
	///What function this action is currently on
	var/designator_mode = BUILD_DESIGNATOR_MODE

/datum/action/ability/activable/build_designator/Destroy()
	QDEL_NULL(hologram)
	selected_mob = null
	return ..()

/datum/action/ability/activable/build_designator/Destroy()
	QDEL_NULL(hologram)
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
	if(!A)
		return FALSE
	switch(designator_mode)
		if(BUILD_DESIGNATOR_MODE)
			return use_build_ability(A)

		if(INTERACT_DESIGNATOR_MODE) ///TODO: COOLDOWN TO STOP SPAM
			return use_interact_ability(A)

/datum/action/ability/activable/build_designator/alternate_action_activate()
	switch(designator_mode)
		if(BUILD_DESIGNATOR_MODE)
			INVOKE_ASYNC(src, PROC_REF(select_structure))
		if(INTERACT_DESIGNATOR_MODE) //maybe just direct swap to build designator mode?
			INVOKE_ASYNC(src, PROC_REF(select_mode)) //todo:better to rework these into 1 proc, will do later

///Tells overwatch we're overriding the radial selection
/datum/action/ability/activable/build_designator/proc/override_cic_radial(datum/source)
	SIGNAL_HANDLER
	switch(designator_mode)
		if(BUILD_DESIGNATOR_MODE)
			return OVERWATCH_RADIAL_HIDE
		if(INTERACT_DESIGNATOR_MODE) //todo: delete this if unneeded
			return OVERWATCH_RADIAL_HIDE

///Selects a mode
/datum/action/ability/activable/build_designator/proc/select_mode()
	var/mode_choice = show_radial_menu(owner, owner?.client?.eye, GLOB.designator_mode_image_list)
	if(!mode_choice)
		return
	if(mode_choice == designator_mode)
		return
	swap_mode(mode_choice)

//todo:Below ones might not need an arg. revisit before merge.
///Swaps our mode to a new one
/datum/action/ability/activable/build_designator/proc/swap_mode(new_mode)
	deactivate_mode(designator_mode)
	designator_mode = new_mode
	activate_mode(new_mode)

///Toggles off the current mode
/datum/action/ability/activable/build_designator/proc/deactivate_mode(old_mode)
	switch(old_mode)
		if(BUILD_DESIGNATOR_MODE)
			UnregisterSignal(owner, list(COMSIG_ATOM_MOUSE_ENTERED, COMSIG_ATOM_DIR_CHANGE, COMSIG_DO_OVERWATCH_RADIAL))
			cleanup_hologram()
		if(INTERACT_DESIGNATOR_MODE)
			selected_mob = null

///Toggles on the new mode
/datum/action/ability/activable/build_designator/proc/activate_mode(new_mode)
	switch(new_mode)
		if(BUILD_DESIGNATOR_MODE)
			RegisterSignal(owner, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(show_hologram_call))
			RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_owner_rotate))
			RegisterSignal(owner, COMSIG_DO_OVERWATCH_RADIAL, PROC_REF(override_cic_radial)) //todo: this may not be build mode specific, depending on functionality
			target_flags = ABILITY_TURF_TARGET
		if(INTERACT_DESIGNATOR_MODE)
			target_flags = NONE
