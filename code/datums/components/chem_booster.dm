/**
	Chem booster component

	This component stores virilyth and uses it to increase REM of chems in body.

	Parameters
	*

*/

/datum/component/chem_booster
	///Amount of substance that the component can store
	var/reagent_storage
	var/mob/living/carbon/wearer
	var/datum/action/chem_booster/configure_action
	var/boost_on = FALSE

/datum/component/chem_booster/Initialize(reagent_storage_amount)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	if(!isnull(reagent_storage_amount))
		reagent_storage = reagent_storage_amount

/datum/component/chem_booster/Destroy(force, silent)
	wearer = null
	return ..()

/datum/component/chem_booster/RegisterWithParent()
	. = ..()
	configure_action = new(parent)
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/equipped)
	RegisterSignal(configure_action, COMSIG_ACTION_TRIGGER, .proc/configure)

/datum/component/chem_booster/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!iscarbon(user))
		return
	configure_action.remove_action(wearer)
	wearer = null

/datum/component/chem_booster/proc/equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!iscarbon(equipper)) // living can equip stuff but only carbon has traumatic shock
		return
	wearer = equipper
	configure_action.remove_action(wearer)

/**
	Opens the radial menu with everything
*/
/datum/component/chem_booster/proc/configure(datum/source)
	SIGNAL_HANDLER_DOES_SLEEP
	var/mob/living/carbon/human/H = wearer
	var/radial_state = ""

	var/list/radial_options = list(
		"on_off" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_on_off"),
		"drain" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_drain"),
		"boost_1" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_t1"),
		"boost_2" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_t2"),
		)

	var/choice = show_radial_menu(doctor, H, radial_options_show, null, 48, null, TRUE)
	switch(choice)
		if("on_off")
			affecting = H.get_limb(BODY_ZONE_HEAD)
		if("drain")
			affecting = H.get_limb(BODY_ZONE_CHEST)
		if("boost_1")
			affecting = H.get_limb(BODY_ZONE_PRECISE_GROIN)
		if("boost_2")
			affecting = H.get_limb(BODY_ZONE_L_ARM)
