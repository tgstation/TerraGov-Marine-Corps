/**
 *	Chem booster component
 *
 *	This component stores "green blood" and uses it to increase effect_str of chems in the user's body.
 *
 */
/datum/component/chem_booster
	var/mob/living/carbon/human/wearer

	///Amount of substance that the component can store
	var/resource_storage_max = 200
	///Amount of substance stored currently
	var/resource_storage_current = 0
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
	var/boost_tier2 = 3
	///Boost icon, image cycles between 2 states
	var/boost_icon = "cboost_t1"
	///Item connected to the system
	var/obj/item/connected_weapon
	///When was the effect activated. Used to activate negative effects after a certain amount of use
	var/processing_start = 0
	COOLDOWN_DECLARE(chemboost_activation_cooldown)

/datum/component/chem_booster/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	update_boost(boost_tier1)

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
	to_chat(user, "<span class='notice'>The chemical system currently holds [resource_storage_current]u of green blood. Its' enhancement level is set to [boost_amount+1].</span>")

/datum/component/chem_booster/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!iscarbon(user))
		return
	if(boost_on)
		on_off()
	manage_weapon_connection()

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
	resource_storage_current = max(resource_storage_current - resource_drain_amount, 0)

	if(world.time - processing_start > 12 SECONDS)
		wearer.overlay_fullscreen("degeneration", /obj/screen/fullscreen/infection, 1)

/**
 *	Opens the radial menu with everything
 */
/datum/component/chem_booster/proc/configure(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/show_radial)

///Shows the radial menu with suit options. It is separate from configure() due to linters
/datum/component/chem_booster/proc/show_radial()
	var/list/radial_options = list(
		"on_off" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_on_off"),
		"connect" = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_connect"),
		"boost" = image(icon = 'icons/mob/radial.dmi', icon_state = "[boost_icon]"),
		)

	var/choice = show_radial_menu(wearer, wearer, radial_options, null, 48, null, TRUE)
	switch(choice)
		if("on_off")
			on_off()

		if("connect")
			connect_weapon()

		if("boost")
			if(boost_amount == boost_tier2)
				update_boost(boost_tier1)
				boost_icon = "cboost_t1"
				return
			update_boost(boost_tier2)
			boost_icon = "cboost_t2"

/datum/component/chem_booster/proc/on_off(datum/source)
	if(boost_on)
		STOP_PROCESSING(SSobj, src)

		wearer.clear_fullscreen("degeneration")
		var/necrotized_counter = FLOOR(min(world.time-processing_start, 20 SECONDS)/200 + (world.time-processing_start-20 SECONDS)/100, 1)
		if(necrotized_counter >= 1)
			for(var/X in shuffle(wearer.limbs))
				var/datum/limb/L = X
				if(L.limb_status & LIMB_NECROTIZED)
					continue
				to_chat(wearer, "<span class='warning'>You can feel the life force in your [L.display_name] draining away...</span>")
				L.germ_level += INFECTION_LEVEL_THREE + 50
				necrotized_counter -= 1
				if(necrotized_counter < 1)
					break

		UnregisterSignal(wearer.reagents, COMSIG_NEW_REAGENT_ADD)
		UnregisterSignal(wearer, COMSIG_MOB_DEATH, .proc/on_off)
		update_boost(0, FALSE)
		boost_on = FALSE
		to_chat(wearer, "<span class='warning'>Halting reagent injection.</span>")
		COOLDOWN_START(src, chemboost_activation_cooldown, 10 SECONDS)
		return

	if(!COOLDOWN_CHECK(src, chemboost_activation_cooldown))
		to_chat(wearer, "<span class='warning'>Your body is still strained after the last exposure. You need to wait a bit... unless you want to burst from excessive use.</span>")
		return

	if(resource_storage_current < resource_drain_amount)
		to_chat(wearer, "<span class='warning'>Not enough resource to sustain operation.</span>")
		return

	boost_on = TRUE
	processing_start = world.time
	START_PROCESSING(SSobj, src)
	RegisterSignal(wearer.reagents, COMSIG_NEW_REAGENT_ADD, .proc/late_add_chem)
	RegisterSignal(wearer, COMSIG_MOB_DEATH, .proc/on_off)
	update_boost(boost_amount*2, FALSE)
	to_chat(wearer, "<span class='notice'>Commensing reagent injection.</span>")

//Updates the boost amount of the suit and effect_str of reagents if component is on. "amount" is the final level you want to set the boost to.
/datum/component/chem_booster/proc/update_boost(amount, update_boost_amount = TRUE)
	amount -= boost_amount
	if(update_boost_amount)
		boost_amount += amount
		to_chat(wearer, "<span class='notice'>Reagent effectiveness set to [boost_amount+1].</span>")
	resource_drain_amount = boost_amount*4
	if(boost_on)
		for(var/X in wearer.reagents.reagent_list)
			var/datum/reagent/R = X
			R.effect_str += amount

//Updates the effect_str of chems that enter the body while the component is on
/datum/component/chem_booster/proc/late_add_chem(datum/source, datum/reagent/added_chem, amount)
	SIGNAL_HANDLER
	for(var/X in wearer.reagents.reagent_list)
		if(!istype(X, added_chem))
			continue
		var/datum/reagent/R = X
		R.effect_str += boost_amount
		break

///Links the held item, if compatible, to the chem booster and registers attacking with it
/datum/component/chem_booster/proc/connect_weapon()
	if(manage_weapon_connection())
		return

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

	wearer.add_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT, TRUE, 0, NONE, TRUE, 4)
	to_chat(wearer, "<span class='notice'>You begin connecting the [held_item] to the storage tank.</span>")
	if(!do_after(wearer, 4 SECONDS, TRUE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS, ignore_turf_checks = TRUE))
		wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT)
		to_chat(wearer, "<span class='warning'>You are interrupted.</span>")
		return

	to_chat(wearer, "<span class='notice'>You finish connecting the [held_item].</span>")
	wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT)
	manage_weapon_connection(held_item)

/datum/component/chem_booster/proc/manage_weapon_connection(obj/item/weapon_to_connect)
	if(connected_weapon)
		to_chat(wearer, "<span class='warning'>You disconnect the [connected_weapon].</span>")
		DISABLE_BITFIELD(connected_weapon.flags_item, NODROP)
		UnregisterSignal(connected_weapon, COMSIG_ITEM_ATTACK)
		UnregisterSignal(connected_weapon, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED))
		connected_weapon = null
		return TRUE

	if(!weapon_to_connect)
		return FALSE

	connected_weapon = weapon_to_connect
	ENABLE_BITFIELD(connected_weapon.flags_item, NODROP)
	RegisterSignal(connected_weapon, COMSIG_ITEM_ATTACK, .proc/drain_resource)
	RegisterSignal(connected_weapon, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), .proc/connect_weapon)
	return TRUE

//Handles resource collection and is ativated when attacking with a weapon.
/datum/component/chem_booster/proc/drain_resource(datum/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER
	if(!isxeno(M))
		return
	if(M.stat == DEAD)
		return
	if(resource_storage_current >= resource_storage_max)
		return
	resource_storage_current += min(resource_storage_max - resource_storage_current, 20)

/datum/action/chem_booster/configure
	name = "Configure Vali Chemical Enhancement"
	action_icon_state = "suit_configure"
