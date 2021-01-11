/**
	Chem booster component

	This component stores virilyth and uses it to increase REM of chems in body.

	Parameters
	*

*/

/datum/component/chem_booster
	var/mob/living/carbon/wearer

	///Amount of substance that the component can store
	var/resource_storage_max
	///Ammount of sunstance stored currently
	var/resource_storage_current
	///Amount required for operation
	var/resource_drain_amount
	///Opens radial menu with settings
	var/datum/action/chem_booster/configure/configure_action
	///Determines whether the suit is on
	var/boost_on = FALSE
	///Stores the value with which effect_mult has been modified
	var/boost_amount

/datum/component/chem_booster/Initialize(reagent_storage_amount)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	if(!isnull(reagent_storage_amount))
		resource_storage_max = resource_storage_amount
	boost_amount = 0

/datum/component/chem_booster/Destroy(force, silent)
	QDEL_NULL(configure_action)
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
	configure_action.give_action(wearer)

/datum/component/chem_booster/process()
	if(resource_storage_current < resource_drain_amount)
		to_chat(wearer, "<span class='warning'>Insufficient resources to maintain operation.</span>")
		on_off()
	resource_storage_current -= resource_drain_amount

/**
	Opens the radial menu with everything
*/
/datum/component/chem_booster/proc/configure(datum/source)
	SIGNAL_HANDLER_DOES_SLEEP
	var/mob/living/carbon/human/H = wearer

	var/list/radial_options = list(
		"on_off" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_on_off"),
		"drain" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_drain"),
		"boost_1" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_t1"),
		"boost_2" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_t2"),
		)

	var/choice = show_radial_menu(wearer, wearer, radial_options_show, null, 48, null, TRUE)
	switch(choice)
		if("on_off")
			on_off()
		if("drain")
			drain_resource()
		if("boost_1")
			update_rem(1-boost_amount)
		if("boost_2")
			update_rem(3-boost_amount)

/datum/component/chem_booster/proc/on_off(datum/source)
	if(boost_on)
		STOP_PROCESSING(SSobj, src)
		UnegisterSignal(wearer, COMSIG_REAGENT_ADD)
		update_rem(-boost_amount)
		boost_on = FALSE
		to_chat(wearer, "<span class='warning'>Halting reagent injection.</span>")
		return

	START_PROCESSING(SSobj, src)
	RegisterSignal(wearer, COMSIG_REAGENT_ADD, .proc/late_add_rem)
	update_rem(boost_amount)
	boost_on = TRUE
	to_chat(wearer, "Commensing reagent injection.")

/datum/component/chem_booster/proc/refill_storage()
	if(wearer.action_busy)
		to_chat(wearer, "<span class='warning'>You are already occupied with something.</span>")
		return

	if(resource_storage_current >= resource_storage_max)
		to_chat(wearer, "<span class='warning'>The system's nternal storage is full. Aborting transfer.</span>")
		return

	var/obj/item/held_item = wearer.get_held_item()
	if(!istype(held_item, /obj/item/weapon/claymore/harvester))
		to_chat(wearer, "<span class='warning'>You need to be holding an applicable weapon to extract resources.</span>")
		return

	var/obj/item/weapon/claymore/harvester = held_item
	if(harvester.current_storage <= 0)
		to_chat(wearer, "<span class='warning'>The weapon's virilyth tank is empty.</span>")
		return

	wearer.add_movespeed_modifier(MOVESPEED_ID_CHEM_BOOSTER_REFILL, TRUE, 0, NONE, TRUE, 4)
	to_chat(wearer, "You slow down and beging refilling your suit's internal tank.")
	if(!do_after(wearer, 10 SECONDS, TRUE, harvester, BUSY_ICON_MEDICAL, null, PROGRESS_BRASS, ignore_turf_checks = TRUE))
		wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_BOOSTER_REFILL)
		to_chat(wearer, "<span class='warning'>Disturbance detected. Aborting transfer.</span>")
		return
	wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_BOOSTER_REFILL)

	var/virilyth_transfer_amount = min(resource_storage_max - resource_storage_current, harvester.current_storage)
	resource_storage_current += virilyth_transfer_amount
	harvester.current_storage -= virilyth_transfer_amount

/datum/component/chem_booster/proc/late_add_chem(datum/source, datum/reagent/added_chem, amount)
	added_chem.rem += boost_amount

/datum/component/chem_booster/proc/update_boost(amount)
	boost_amount += amount
	for(var/datum/reagent/R in wearer.reagents.reagents_list)
		R.rem += amount
	resource_drain_amount = boost_amount^2

/datum/action/chem_booster/configure
	name = "Configure Vali CHemical Enhancement"
	action_icon_state = "suit_configure"
