#define CONNECT "Connect"
#define EXTRACT "Extract"
#define LOAD "Load up"
#define BOOST_CONFIG "Switch Boost"

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
	///Turns the suit on and off. Can be used while downed
	var/datum/action/chem_booster/power/power_action
	///Activates the chemsuit's analyzer
	var/datum/action/chem_booster/scan/scan_action
	///Instant analyzer for the chemsuit
	var/obj/item/healthanalyzer/integrated/analyzer
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
	///Internal reagent storage used to store and automatically inject reagents into the wearer
	var/obj/item/reagent_containers/glass/beaker/meds_beaker
	///Whether the contents on the meds_beaker will be injected into the wearer when the system is turned on
	var/automatic_meds_use = TRUE
	///Image that gets added to the wearer's overlays and gets changed based on resource_storage_current
	var/static/image/resource_overlay = image('icons/mob/hud.dmi', icon_state = "chemsuit_vis")
	COOLDOWN_DECLARE(chemboost_activation_cooldown)

/datum/component/chem_booster/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	update_boost(boost_tier1)
	analyzer = new
	meds_beaker = new

/datum/component/chem_booster/Destroy(force, silent)
	QDEL_NULL(configure_action)
	QDEL_NULL(power_action)
	QDEL_NULL(scan_action)
	QDEL_NULL(analyzer)
	QDEL_NULL(meds_beaker)
	wearer = null
	return ..()

/datum/component/chem_booster/RegisterWithParent()
	. = ..()
	configure_action = new(parent)
	power_action = new(parent)
	scan_action = new(parent)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/equipped)
	RegisterSignal(configure_action, COMSIG_ACTION_TRIGGER, .proc/configure)
	RegisterSignal(power_action, COMSIG_ACTION_TRIGGER, .proc/on_off)
	RegisterSignal(scan_action, COMSIG_ACTION_TRIGGER, .proc/scan_user)

/datum/component/chem_booster/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED_TO_SLOT))
	QDEL_NULL(configure_action)
	QDEL_NULL(power_action)
	QDEL_NULL(scan_action)

///Adds additional text for the component when examining the item it is attached to
/datum/component/chem_booster/proc/examine(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class='notice'>The chemical system currently holds [resource_storage_current]u of green blood. Its' enhancement level is set to [boost_amount+1].</span>")
	show_meds_beaker_contents(user)

///Disables active functions and cleans up actions when the suit is unequipped
/datum/component/chem_booster/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!iscarbon(user))
		return
	if(boost_on)
		on_off()
	manage_weapon_connection()

	if(!wearer)
		return
	configure_action.remove_action(wearer)
	power_action.remove_action(wearer)
	scan_action.remove_action(wearer)
	wearer.overlays -= resource_overlay

	wearer = null

///Sets up actions and vars when the suit is equipped
/datum/component/chem_booster/proc/equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!isliving(equipper))
		return
	wearer = equipper

	configure_action.give_action(wearer)
	power_action.give_action(wearer)
	scan_action.give_action(wearer)
	wearer.overlays += resource_overlay
	update_resource(0)

/datum/component/chem_booster/process()
	if(resource_storage_current < resource_drain_amount)
		to_chat(wearer, "<span class='warning'>Insufficient resources to maintain operation.</span>")
		on_off()
	update_resource(-resource_drain_amount)

	if(world.time - processing_start > 12 SECONDS && world.time - processing_start < 15 SECONDS)
		wearer.overlay_fullscreen("degeneration", /obj/screen/fullscreen/infection, 1)
		to_chat(wearer, "<span class='highdanger'>WARNING: You have [(200 - (world.time - processing_start))/10] seconds before necrotic tissue forms on your limbs.</span>")

/**
 *	Opens the radial menu with everything
 */
/datum/component/chem_booster/proc/configure(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/show_radial)

///Shows the radial menu with suit options. It is separate from configure() due to linters
/datum/component/chem_booster/proc/show_radial()
	var/list/radial_options = list(
		CONNECT = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_connect"),
		BOOST_CONFIG = image(icon = 'icons/mob/radial.dmi', icon_state = "[boost_icon]"),
		EXTRACT = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_extract"),
		LOAD = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_load"),
		)

	var/choice = show_radial_menu(wearer, wearer, radial_options, null, 48, null, TRUE, TRUE)
	switch(choice)
		if(CONNECT)
			connect_weapon()

		if(BOOST_CONFIG)
			if(boost_amount == boost_tier2)
				update_boost(boost_tier1)
				boost_icon = "cboost_t1"
				return
			update_boost(boost_tier2)
			boost_icon = "cboost_t2"

		if(EXTRACT)
			extract(10)

		if(LOAD)
			load_up()

///Handles turning on/off the chem effect modufying function, along with the negative effects related to this
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
		power_action.action_icon_state = "cboost_off"
		power_action.update_button_icon()
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
	power_action.action_icon_state = "cboost_on"
	power_action.update_button_icon()
	playsound(get_turf(wearer), 'sound/effects/bubbles.ogg', 30, 1)
	to_chat(wearer, "<span class='notice'>Commensing reagent injection.<b>[(automatic_meds_use && meds_beaker.reagents.total_volume) ? " Adding additional reagents." : ""]</b></span>")
	if(automatic_meds_use)
		show_meds_beaker_contents(wearer)
		meds_beaker.reagents.trans_to(wearer, 60)

///Updates the boost amount of the suit and effect_str of reagents if component is on. "amount" is the final level you want to set the boost to.
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

///Updates the effect_str of chems that enter the body while the component is on
/datum/component/chem_booster/proc/late_add_chem(datum/source, datum/reagent/added_chem, amount)
	SIGNAL_HANDLER
	for(var/X in wearer.reagents.reagent_list)
		if(!istype(X, added_chem))
			continue
		var/datum/reagent/R = X
		R.effect_str += boost_amount
		break

///Used to scan the person
/datum/component/chem_booster/proc/scan_user(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(analyzer, /obj/item/healthanalyzer/.proc/attack, wearer, wearer, TRUE)

///Links the held item, if compatible, to the chem booster and registers attacking with it
/datum/component/chem_booster/proc/connect_weapon()
	if(manage_weapon_connection())
		return

	if(wearer.do_actions)
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
	if(!do_after(wearer, 2 SECONDS, TRUE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS, ignore_turf_checks = TRUE))
		wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT)
		to_chat(wearer, "<span class='warning'>You are interrupted.</span>")
		return

	to_chat(wearer, "<span class='notice'>You finish connecting the [held_item].</span>")
	wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT)
	manage_weapon_connection(held_item)

///Handles the setting up and removal of signals and vars related to connecting an item to the suit
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

///Handles resource collection and is ativated when attacking with a weapon.
/datum/component/chem_booster/proc/drain_resource(datum/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER
	if(!isxeno(M))
		return
	if(M.stat == DEAD)
		return
	if(resource_storage_current >= resource_storage_max)
		return
	update_resource(20)

///Adds or removes resource from the suit. Signal gets sent at every 25% of stored resource
/datum/component/chem_booster/proc/update_resource(amount)
	var/amount_added = min(resource_storage_max - resource_storage_current, amount)
	resource_storage_current = max(resource_storage_current + amount_added, 0)
	wearer.overlays -= resource_overlay
	resource_overlay.alpha = resource_storage_current/resource_storage_max*255
	wearer.overlays += resource_overlay

///Extracts resource from the suit to fill a beaker
/datum/component/chem_booster/proc/extract(volume)
	if(wearer.do_actions)
		return

	if(resource_storage_current < volume)
		to_chat(wearer, "<span class='warning'>Not enough resource to extract.</span>")
		return

	var/obj/item/held_item = wearer.get_held_item()
	if(!held_item)
		to_chat(wearer, "<span class='warning'>You need to be holding a chemical liquid container.</span>")
		return

	if(!istype(held_item, /obj/item/reagent_containers/glass))
		to_chat(wearer, "<span class='warning'>You need to be holding a specialized chemical liquid container.</span>")
		return

	var/amount = min(held_item.reagents.maximum_volume-held_item.reagents.total_volume, volume)
	if(!amount)
		return

	to_chat(wearer, "<span class='notice'>You begin filling [held_item].</span>")
	if(!do_after(wearer, 1 SECONDS, TRUE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS))
		return

	if(resource_storage_current < volume)
		to_chat(wearer, "<span class='warning'>Not enough resource to extract.</span>")
		return

	update_resource(-amount)
	held_item.reagents.add_reagent(/datum/reagent/virilyth, amount)
	extract(volume)

///Fills an internal beaker that gets injected into the wearer on suit activation
/datum/component/chem_booster/proc/load_up()
	if(wearer.do_actions)
		return

	var/obj/item/held_item = wearer.get_held_item()
	if((!istype(held_item, /obj/item/reagent_containers) && !meds_beaker.reagents.total_volume) || istype(held_item, /obj/item/reagent_containers/pill))
		to_chat(wearer, "<span class='warning'>You need to be holding a liquid container to fill up the system's reagent storage.</span>")
		return

	if(!istype(held_item, /obj/item/reagent_containers) && meds_beaker.reagents.total_volume)
		var/pick = tgui_input_list(wearer, "Automatic reagent injection on system activate:", "Vali system", list("Yes", "No"))
		if(pick == "Yes")
			automatic_meds_use = TRUE
		else if(pick == "No")
			automatic_meds_use = FALSE
		to_chat(wearer, "<span class='notice'>The chemical system will <b>[automatic_meds_use ? "inject" : "not inject"]</b> loaded reagets on activation.</span>")
		return

	var/obj/item/reagent_containers/held_beaker = held_item
	if(!held_beaker.reagents.total_volume && !meds_beaker.reagents.total_volume)
		to_chat(wearer, "<span class='notice'>Both the held reagent container and the system's reagent storage are empty.</span>")
		return

	if(!held_beaker.reagents.total_volume && meds_beaker.reagents.total_volume)
		var/pick = tgui_input_list(wearer, "Unload internal reagent storage into held container:", "Vali system", list("Yes", "No"))
		if(pick == "Yes")
			if(!do_after(wearer, 0.5 SECONDS, TRUE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS, ignore_turf_checks = TRUE))
				return
			meds_beaker.reagents.trans_to(held_beaker, 60)
			show_meds_beaker_contents(wearer)
		return

	if(meds_beaker.reagents.total_volume >= meds_beaker.volume)
		to_chat(wearer, "<span class='notice'>The system's reagent storage is full. You may consider unloading it if you want to load a different mix.</span>")
		return

	if(!do_after(wearer, 0.5 SECONDS, TRUE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS, ignore_turf_checks = TRUE))
		return

	var/trans = held_beaker.reagents.trans_to(meds_beaker, held_beaker.amount_per_transfer_from_this)
	to_chat(wearer, "<span class='notice'>You load [trans] units into the system's reagent storage.</span>")
	show_meds_beaker_contents(wearer)

///Shows the loaded reagents to the person examining the parent/wearer
/datum/component/chem_booster/proc/show_meds_beaker_contents(mob/user)
	if(!meds_beaker.reagents.total_volume)
		to_chat(user, "<span class='notice'>The system's reagent storage is empty.</span>")
		return
	to_chat(user, "<span class='notice'>The system's reagent storage contains:</span>")
	for(var/datum/reagent/R AS in meds_beaker.reagents.reagent_list)
		to_chat(user, "<span class='rose'>[R.name] - [R.volume]u</span>")

/datum/action/chem_booster/configure
	name = "Configure Vali Chemical Enhancement"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "cboost_configure"

/datum/action/chem_booster/power
	name = "Power Vali Chemical Enhancement"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "cboost_off"

/datum/action/chem_booster/scan
	name = "Activate Analyzer"
	action_icon = 'icons/mob/screen_alert.dmi'
	action_icon_state = "suit_scan"

#undef CONNECT
#undef EXTRACT
#undef LOAD
#undef BOOST_CONFIG
