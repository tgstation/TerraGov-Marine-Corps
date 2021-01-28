/**
	Chem booster component

	This component stores "green blood" and uses it to increase effect_str of chems in the user's body.

*/

/datum/component/chem_booster
	var/mob/living/carbon/wearer

	///Amount of substance that the component can store
	var/resource_storage_max = 200
	///Ammount of sunstance stored currently
	var/resource_storage_current
	///Amount required for operation
	var/resource_drain_amount = 10
	///Opens radial menu with settings
	var/datum/action/chem_booster/configure/configure_action
	///Determines whether the suit is on
	var/boost_on = FALSE
	///Stores the value with which effect_mult is modified
	var/boost_amount = 0
	///Normal boost
	var/boost_tier1 = 1
	///Overcharged boost
	var/boost_tier2 = 4
	///Item connected to the system
	var/obj/item/connected_item
	///When was the effect activated. Used to activate negative effects after a certain amount of use
	var/processing_start
	COOLDOWN_DECLARE(chemboost_activation_cooldown)

/datum/component/chem_booster/Initialize()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	boost_amount = 0

/datum/component/chem_booster/Destroy(force, silent)
	QDEL_NULL(configure_action)
	wearer = null
	return ..()

/datum/component/chem_booster/RegisterWithParent()
	. = ..()
	configure_action = new(parent)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/equipped)
	RegisterSignal(configure_action, COMSIG_ACTION_TRIGGER, .proc/configure)

/datum/component/suit_autodoc/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED_TO_SLOT))
	QDEL_NULL(configure_action)

/datum/component/chem_booster/proc/examine(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class='notice'>The chemical system currently holds [resource_storage_current]u of green blood. Its' enhancement level is set to [boost_amount].</span>")

/datum/component/chem_booster/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!iscarbon(user))
		return
	if(boost_on)
		on_off()
	if(connected_item)
		to_chat(wearer, "<span class='warning'>You disconnect the [connected_item].</span>")
		DISABLE_BITFIELD(connected_item.flags_item, NODROP)
		UnregisterSignal(connected_item, COMSIG_ITEM_ATTACK)
		connected_item = null
	configure_action.remove_action(wearer)
	wearer = null

/datum/component/chem_booster/proc/equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!isliving(equipper))
		return
	wearer = equipper
	configure_action.give_action(wearer)

/datum/component/chem_booster/process()
	if(resource_storage_current < resource_drain_amount)
		to_chat(wearer, "<span class='warning'>Insufficient resources to maintain operation.</span>")
		on_off()
	resource_storage_current -= resource_drain_amount

/**
 *	Opens the radial menu with everything
 */
/datum/component/chem_booster/proc/configure(datum/source)
	SIGNAL_HANDLER_DOES_SLEEP
	var/mob/living/carbon/human/H = wearer

	var/list/radial_options = list(
		"on_off" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_on_off"),
		"connect" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_drain"),
		"boost_1" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_t1"),
		"boost_2" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_t2"),
		)

	var/choice = show_radial_menu(H, H, radial_options, null, 48, null, TRUE)
	switch(choice)
		if("on_off")
			on_off()
		if("connect")
			connect_weapon()
		if("boost_1")
			update_boost(boost_tier1)
		if("boost_2")
			update_boost(boost_tier2)

/datum/component/chem_booster/proc/on_off(datum/source)
	if(boost_on)
		STOP_PROCESSING(SSobj, src)
		UnregisterSignal(wearer.reagents, COMSIG_REAGENT_ADD)
		UnregisterSignal(wearer, COMSIG_MOB_DEATH, .proc/on_off)
		update_boost(0, FALSE)
		boost_on = FALSE
		to_chat(wearer, "<span class='warning'>Halting reagent injection.</span>")
		COOLDOWN_START(wearer, chemboost_activation_cooldown, 10 SECONDS)
		return

	if(COOLDOWN_CHECK(chemboost_activation_cooldown))
		to_chat(wearer, "<span class='warning'>Your body is still strained after the last exposure. You need to wait a bit... unless you want to burst for excessing use.</span>")

		return

	if(resource_storage_current < resource_drain_amount)
		to_chat(wearer, "<span class='warning'>Not enough resource to sustain operation.</span>")
		return
	boost_on = TRUE
	processing_start = world.time
	START_PROCESSING(SSobj, src)
	RegisterSignal(wearer.reagents, COMSIG_REAGENT_ADD, .proc/late_add_chem)
	RegisterSignal(wearer, COMSIG_MOB_DEATH, .proc/on_off)
	update_boost(boost_amount*2, FALSE)
	to_chat(wearer, "Commensing reagent injection.")

//Updates the boost amount of the suit and effect_str of reagents if component is on. "amount" is the final level you want to set the boost to.
/datum/component/chem_booster/proc/update_boost(amount, update_boost_amount = TRUE)
	amount -= boost_amount
	if(update_boost_amount)
		boost_amount += amount
	message_admins("effect_str modification amount > [amount]")
	resource_drain_amount = 1
	if(boost_on)
		for(var/datum/reagent/R in wearer.reagents.reagent_list)
			R.effect_str += amount

//Updates the effect_str of chems that enter the body while the component is on
/datum/component/chem_booster/proc/late_add_chem(datum/source, datum/reagent/added_chem, amount)
	SIGNAL_HANDLER
	for(var/datum/reagent/R in wearer.reagents.reagent_list)
		if(!istype(R, added_chem))
			continue
		message_admins("added chem boosted by > [boost_amount]")
		R.effect_str += boost_amount
		break

/datum/component/chem_booster/proc/connect_weapon()
	if(wearer.action_busy)
		to_chat(wearer, "<span class='warning'>You are already occupied with something.</span>")
		return

	var/obj/item/held_item = wearer.get_held_item()
	if(!held_item)
		to_chat(wearer, "<span class='warning'>You need to be holding an item compatible with the system.</span>")
		return

	if(!CHECK_BITFIELD(held_item.flags_item, DRAINS_XENO))
		to_chat(wearer, "<span class='warning'>You need to be holding an item compatible with the system.</span>")
		return

	if(connected_item)
		to_chat(wearer, "<span class='warning'>You disconnect the [held_item].</span>")
		DISABLE_BITFIELD(connected_item.flags_item, NODROP)
		UnregisterSignal(connected_item, COMSIG_ITEM_ATTACK)
		connected_item = null
		return

	wearer.add_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT, TRUE, 0, NONE, TRUE, 4)
	to_chat(wearer, "<span class='notice'>You begin connecting the [held_item] to the storage tank.</span>")
	if(!do_after(wearer, 4 SECONDS, TRUE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS, ignore_turf_checks = TRUE))
		wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT)
		to_chat(wearer, "<span class='warning'>You are interrupted.</span>")
		return

	to_chat(wearer, "<span class='notice'>You finish connecting the [held_item].</span>")
	wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT)
	connected_item = held_item
	ENABLE_BITFIELD(connected_item.flags_item, NODROP)
	RegisterSignal(connected_item, COMSIG_ITEM_ATTACK, .proc/drain_resource)

//Handles resource collection and is ativated when attacking with a weapon.
/datum/component/chem_booster/proc/drain_resource(datum/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER
	if(!isxeno(M))
		return
	if(isdead(M))
		return
	if(resource_storage_current >= resource_storage_max)
		return
	resource_storage_current += min(resource_storage_max - resource_storage_current, 20)

/datum/action/chem_booster/configure
	name = "Configure Vali CHemical Enhancement"
	action_icon_state = "suit_configure"
