#define EXTRACT "Extract"
#define LOAD "Load up"
#define BOOST_CONFIG "Switch Boost"
#define VALI_INFO "Information"

#define BRUTE_AMP "brute_amp"
#define BURN_AMP "burn_amp"
#define TOX_HEAL "tox_heal"
#define STAM_REG_AMP "stam_reg_amp"
#define SPEED_BOOST "speed_boost"
#define REQ "requirement"
#define NAME "name"

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
	///Actions that the component provides
	var/list/datum/action/component_actions = list(
		/datum/action/chem_booster/configure = PROC_REF(configure),
		/datum/action/chem_booster/connect_weapon = PROC_REF(connect_weapon),
		/datum/action/chem_booster/power = PROC_REF(on_off),
		/datum/action/suit_autodoc/scan = PROC_REF(scan_user)
	)
	///Instant analyzer for the chemsuit
	var/obj/item/healthanalyzer/integrated/analyzer
	///Determines whether the suit is on
	var/boost_on = FALSE
	///Stores the current effect strength
	var/boost_amount = 0
	///Normal boost
	var/boost_tier1 = 1
	///Overcharged boost
	var/boost_tier2 = 2
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
	///Information about how reagents boost the system's effects.
	var/reagent_info = ""
	///Vali brute healing is multiplied by this
	var/brute_heal_amp = 1
	///Vali burn healing is multiplied by this
	var/burn_heal_amp = 1
	///Vali toxin healing is multiplied by this
	var/tox_heal = 0
	///Vali stamina regen is multiplied by this
	var/stamina_regen_amp = 1
	///Vali movement speed buff is this value
	var/movement_boost = 0
	///How much time left on vali heal till necrosis occurs
	var/vali_necro_timer

	/**
	 * This list contains the vali stat increases that correspond to each reagent
	 * They go in the order:
	 * brute_heal_amp, burn_heal_amp, tox_heal, stamina_regen_amp, movement_boost, min required volume, entry name
	 */
	var/static/list/reagent_stats = list(
		/datum/reagent/medicine/bicaridine = list(NAME = "Bicaridine", REQ = 5, BRUTE_AMP = 0.1, BURN_AMP = 0, TOX_HEAL = 0, STAM_REG_AMP = 0, SPEED_BOOST = 0),
		/datum/reagent/medicine/kelotane = list(NAME = "Kelotane", REQ = 5, BRUTE_AMP = 0, BURN_AMP = 0.1, TOX_HEAL = 0, STAM_REG_AMP = 0, SPEED_BOOST = 0),
		/datum/reagent/medicine/paracetamol = list(NAME = "Paracetamol", REQ = 5, BRUTE_AMP = 0, BURN_AMP = 0, TOX_HEAL = 0, STAM_REG_AMP = 0.2, SPEED_BOOST = -0.1),
		/datum/reagent/medicine/meralyne = list(NAME = "Meralyne", REQ = 5, BRUTE_AMP = 0.2, BURN_AMP = 0, TOX_HEAL = 0, STAM_REG_AMP = 0, SPEED_BOOST = 0),
		/datum/reagent/medicine/dermaline = list(NAME = "Dermaline", REQ = 5, BRUTE_AMP = 0, BURN_AMP = 0.2, TOX_HEAL = 0, STAM_REG_AMP = 0, SPEED_BOOST = 0),
		/datum/reagent/medicine/dylovene = list(NAME = "Dylovene", REQ = 5, BRUTE_AMP = 0, BURN_AMP = 0, TOX_HEAL = 0.5, STAM_REG_AMP = 0, SPEED_BOOST = 0),
		/datum/reagent/medicine/synaptizine = list(NAME = "Synaptizine", REQ = 1, BRUTE_AMP = 0, BURN_AMP = 0, TOX_HEAL = 1, STAM_REG_AMP = 0.1, SPEED_BOOST = 0),
		/datum/reagent/medicine/neuraline = list(NAME = "Neuraline", REQ = 2, BRUTE_AMP = 1, BURN_AMP = 1, TOX_HEAL = -3, STAM_REG_AMP = 0, SPEED_BOOST = -0.3),
	)

/datum/component/chem_booster/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	update_boost(boost_tier1)
	analyzer = new
	meds_beaker = new
	setup_reagent_info()
	var/list/new_actions = list()
	for(var/action_type in component_actions)
		var/new_action = new action_type(src, FALSE)
		new_actions += new_action
		RegisterSignal(new_action, COMSIG_ACTION_TRIGGER, component_actions[action_type])
	component_actions = new_actions

/datum/component/chem_booster/Destroy(force, silent)
	for(var/action in component_actions)
		QDEL_NULL(action)
	QDEL_NULL(analyzer)
	QDEL_NULL(meds_beaker)
	wearer = null
	return ..()

/datum/component/chem_booster/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignals(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), PROC_REF(dropped))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, PROC_REF(equipped))

/datum/component/chem_booster/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED_TO_SLOT))

///Shows info on what stats each reagent boosts and how much units they require
/datum/component/chem_booster/proc/setup_reagent_info()
	reagent_info = "<b>Vali Reagent Information:</b><br>"
	for(var/datum/reagent/entry AS in reagent_stats)
		reagent_info += "<span style= 'color:[initial(entry.color)]'><b>[reagent_stats[entry][NAME]]: </b></span>"
		if(reagent_stats[entry][REQ])
			reagent_info += "required [reagent_stats[entry][REQ]]u<br>"
		if(reagent_stats[entry][BRUTE_AMP])
			reagent_info += "- brute heal " + (reagent_stats[entry][BRUTE_AMP] > 0 ? "+" : "") + "[reagent_stats[entry][BRUTE_AMP]*100]%<br>"
		if(reagent_stats[entry][BURN_AMP])
			reagent_info += "- burn heal " + (reagent_stats[entry][BURN_AMP] > 0 ? "+" : "") + "[reagent_stats[entry][BURN_AMP]*100]%<br>"
		if(reagent_stats[entry][TOX_HEAL])
			reagent_info += "- toxin heal " + (reagent_stats[entry][TOX_HEAL] > 0 ? "+" : "") + "[reagent_stats[entry][TOX_HEAL]]<br>"
		if(reagent_stats[entry][STAM_REG_AMP])
			reagent_info += "- stamina regen " + (reagent_stats[entry][STAM_REG_AMP] > 0 ? "+" : "") + "[reagent_stats[entry][STAM_REG_AMP]*100]%<br>"
		if(reagent_stats[entry][SPEED_BOOST])
			reagent_info += "- slowdown " + (reagent_stats[entry][SPEED_BOOST] > 0 ? "+" : "") + "[reagent_stats[entry][SPEED_BOOST]]<br>"
		reagent_info += "<br>"

///Adds additional text for the component when examining the item it is attached to
/datum/component/chem_booster/proc/examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("The chemical system currently holds [resource_storage_current]u of green blood. Its' enhancement level is set to [boost_amount].")
	examine_text += get_meds_beaker_contents()

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

	for(var/datum/action/current_action AS in component_actions)
		current_action.remove_action(wearer)

	wearer.overlays -= resource_overlay
	wearer = null

///Sets up actions and vars when the suit is equipped
/datum/component/chem_booster/proc/equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!isliving(equipper))
		return
	wearer = equipper

	for(var/datum/action/current_action AS in component_actions)
		current_action.give_action(wearer)

	wearer.overlays += resource_overlay
	update_resource(0)

/datum/component/chem_booster/process()
	if(resource_storage_current < resource_drain_amount)
		to_chat(wearer, span_warning("Insufficient green blood to maintain operation."))
		on_off()
		var/datum/action/chem_booster/power/power_action = wearer.actions_by_path[/datum/action/chem_booster/power]
		power_action.update_onoff_icon()
		return
	update_resource(-resource_drain_amount)

	wearer.adjustToxLoss(-tox_heal*boost_amount)
	wearer.heal_overall_damage(6*boost_amount*brute_heal_amp, 6*boost_amount*burn_heal_amp)
	vali_necro_timer = world.time - processing_start
	if(vali_necro_timer > 20 SECONDS)
		return
	if(connected_weapon)
		wearer.adjustStaminaLoss(-7*stamina_regen_amp*((20 - (vali_necro_timer)/10)/20)) //stamina gain scales inversely with passed time, up to 20 seconds
	if(vali_necro_timer > 10 SECONDS)
		to_chat(wearer, span_bold("WARNING: You have [(200 - (vali_necro_timer))/10] seconds before necrotic tissue forms on your limbs."))
	if(vali_necro_timer > 15 SECONDS)
		wearer.overlay_fullscreen("degeneration", /atom/movable/screen/fullscreen/infection, 1)
		to_chat(wearer, span_highdanger("The process of necrosis begins to set in. Turn it off before it's too late!"))

/**
 *	Opens the radial menu with everything
 */
/datum/component/chem_booster/proc/configure(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(show_radial))

///Shows the radial menu with suit options. It is separate from configure() due to linters
/datum/component/chem_booster/proc/show_radial()
	var/list/radial_options = list(
		BOOST_CONFIG = image(icon = 'icons/mob/radial.dmi', icon_state = "[boost_icon]"),
		EXTRACT = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_extract"),
		LOAD = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_load"),
		VALI_INFO = image(icon = 'icons/mob/radial.dmi', icon_state = "cboost_info"),
		)

	var/choice = show_radial_menu(wearer, wearer, radial_options, null, 48, null, TRUE, TRUE)
	switch(choice)
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

		if(VALI_INFO)
			to_chat(wearer, span_notice("[reagent_info]"))

///Handles turning on/off the processing part of the component, along with the negative effects related to this
/datum/component/chem_booster/proc/on_off(datum/source)
	SIGNAL_HANDLER
	if(!boost_on)
		if(!COOLDOWN_CHECK(src, chemboost_activation_cooldown))
			wearer.balloon_alert(wearer, "You need to wait another [COOLDOWN_TIMELEFT(src, chemboost_activation_cooldown)/10] seconds")
			return
		if(resource_storage_current < resource_drain_amount)
			wearer.balloon_alert(wearer, "Insufficient green blood to begin operation")
			return
		if(wearer.stat)
			wearer.balloon_alert(wearer, "Not conscious")
			return
	boost_on = !boost_on
	SEND_SIGNAL(src, COMSIG_CHEMSYSTEM_TOGGLED, boost_on)
	if(!boost_on)
		STOP_PROCESSING(SSobj, src)
		wearer.clear_fullscreen("degeneration")
		vali_necro_timer = world.time - processing_start
		var/necrotized_counter = FLOOR(min(vali_necro_timer, 20 SECONDS)/200 + (vali_necro_timer-20 SECONDS)/100, 1)
		if(necrotized_counter >= 1)
			for(var/datum/limb/limb_to_ruin AS in shuffle(wearer.limbs))
				if(limb_to_ruin.limb_status & LIMB_NECROTIZED)
					continue
				limb_to_ruin.add_limb_flags(LIMB_NECROTIZED)
				necrotized_counter--
				if(necrotized_counter < 1)
					break
		UnregisterSignal(wearer, COMSIG_MOB_DEATH, PROC_REF(on_off))
		wearer.balloon_alert(wearer, "Halting green blood injection")
		COOLDOWN_START(src, chemboost_activation_cooldown, 10 SECONDS)
		setup_bonus_effects()
		return

	processing_start = world.time
	START_PROCESSING(SSobj, src)
	RegisterSignal(wearer, COMSIG_MOB_DEATH, PROC_REF(on_off))
	playsound(get_turf(wearer), 'sound/effects/bubbles.ogg', 30, 1)
	to_chat(wearer, span_notice("Commensing green blood injection.<b>[(automatic_meds_use && meds_beaker.reagents.total_volume) ? " Adding additional reagents." : ""]</b>"))
	if(automatic_meds_use)
		to_chat(wearer, get_meds_beaker_contents())
		meds_beaker.reagents.trans_to(wearer, 30)
	setup_bonus_effects()

///Updates the boost amount of the suit and effect_str of reagents if component is on. "amount" is the final level you want to set the boost to.
/datum/component/chem_booster/proc/update_boost(amount)
	boost_amount = amount
	wearer?.balloon_alert(wearer, "Enhancement level set to [boost_amount]")
	resource_drain_amount = boost_amount*(3 + boost_amount)

///Handles Vali stat boosts and any other potential buffs on activation/deactivation
/datum/component/chem_booster/proc/setup_bonus_effects()
	if(!boost_on)
		brute_heal_amp = initial(brute_heal_amp)
		burn_heal_amp = initial(burn_heal_amp)
		tox_heal = initial(tox_heal)
		stamina_regen_amp = initial(stamina_regen_amp)
		wearer.remove_movespeed_modifier(MOVESPEED_ID_VALI_BOOST)
		movement_boost = initial(movement_boost)
		return

	for(var/datum/reagent/R AS in wearer.reagents.reagent_list)
		if(!LAZYACCESS(reagent_stats, R.type))
			continue
		if(R.volume < reagent_stats[R.type][REQ])
			continue

		brute_heal_amp += reagent_stats[R.type][BRUTE_AMP]
		burn_heal_amp += reagent_stats[R.type][BURN_AMP]
		tox_heal += reagent_stats[R.type][TOX_HEAL]
		stamina_regen_amp += reagent_stats[R.type][STAM_REG_AMP]
		movement_boost += reagent_stats[R.type][SPEED_BOOST]

	if(movement_boost)
		wearer.add_movespeed_modifier(MOVESPEED_ID_VALI_BOOST, TRUE, 0, NONE, TRUE, movement_boost)

///Used to scan the person
/datum/component/chem_booster/proc/scan_user(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(analyzer, TYPE_PROC_REF(/obj/item/healthanalyzer, attack), wearer, wearer, TRUE)

/datum/component/chem_booster/proc/vali_connect(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(connect_weapon), wearer)

///Links the held item, if compatible, to the chem booster and registers attacking with it
/datum/component/chem_booster/proc/connect_weapon()
	if(manage_weapon_connection())
		return

	if(wearer.do_actions)
		wearer.balloon_alert(wearer, "You're already occupied with something")
		return

	var/obj/item/held_item = wearer.get_held_item()
	if(!held_item)
		wearer.balloon_alert(wearer, "You need to be holding a harvester")
		return

	if(!held_item.GetComponent(/datum/component/harvester))
		wearer.balloon_alert(wearer, "You need to be holding a harvester")
		return

	wearer.add_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT, TRUE, 0, NONE, TRUE, 4)
	wearer.balloon_alert(wearer, "You begin connecting [held_item]")
	if(!do_after(wearer, 1 SECONDS, IGNORE_USER_LOC_CHANGE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS))
		wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT)
		wearer.balloon_alert(wearer, "You were interrupted")
		return

	wearer.balloon_alert(wearer, "Finished connecting [held_item]")
	wearer.remove_movespeed_modifier(MOVESPEED_ID_CHEM_CONNECT)
	manage_weapon_connection(held_item)

///Handles the setting up and removal of signals and vars related to connecting an item to the suit
/datum/component/chem_booster/proc/manage_weapon_connection(obj/item/weapon_to_connect)
	if(connected_weapon)
		wearer.balloon_alert(wearer, "Disconnected [connected_weapon]")
		REMOVE_TRAIT(connected_weapon, TRAIT_NODROP, VALI_TRAIT)
		UnregisterSignal(connected_weapon, COMSIG_ITEM_ATTACK)
		UnregisterSignal(connected_weapon, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED))
		connected_weapon = null
		return TRUE

	if(!weapon_to_connect)
		return FALSE

	connected_weapon = weapon_to_connect
	ADD_TRAIT(connected_weapon, TRAIT_NODROP, VALI_TRAIT)
	RegisterSignal(connected_weapon, COMSIG_ITEM_ATTACK, PROC_REF(drain_resource))
	RegisterSignals(connected_weapon, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), PROC_REF(vali_connect))
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
	update_resource(round(20*connected_weapon.attack_speed/11))

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
		wearer.balloon_alert(wearer, "Insufficient green blood for extraction")
		return

	var/obj/item/held_item = wearer.get_held_item()
	if(!held_item)
		wearer.balloon_alert(wearer, "You must be holding a glass reagent container")
		return

	if(!istype(held_item, /obj/item/reagent_containers/glass))
		wearer.balloon_alert(wearer, "You must be holding a glass reagent container")
		return

	if((held_item.reagents.maximum_volume-held_item.reagents.total_volume) < volume)
		wearer.balloon_alert(wearer, "Held container lacks required space for extraction")
		return

	wearer.balloon_alert(wearer, "You begin filling [held_item]")
	if(!do_after(wearer, 1 SECONDS, IGNORE_USER_LOC_CHANGE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS))
		return

	update_resource(-volume)
	held_item.reagents.add_reagent(/datum/reagent/virilyth, volume)
	extract(volume)

///Fills an internal beaker that gets injected into the wearer on suit activation
/datum/component/chem_booster/proc/load_up()
	if(wearer.do_actions)
		return

	var/obj/item/held_item = wearer.get_held_item()
	if((!istype(held_item, /obj/item/reagent_containers) && !meds_beaker.reagents.total_volume))
		wearer.balloon_alert(wearer, "You must be holding a suitable reagent container")
		return

	if(!istype(held_item, /obj/item/reagent_containers) && meds_beaker.reagents.total_volume)
		var/pick = tgui_input_list(wearer, "Automatic reagent injection on system activate:", "Vali system", list("Yes", "No"))
		if(pick == "Yes")
			automatic_meds_use = TRUE
		else if(pick == "No")
			automatic_meds_use = FALSE
		wearer.balloon_alert(wearer, "The chemical system [automatic_meds_use ? "will" : "won't"] inject loaded reagents on activation")
		return

	var/obj/item/reagent_containers/held_beaker = held_item
	if(!held_beaker.reagents.total_volume && !meds_beaker.reagents.total_volume)
		wearer.balloon_alert(wearer, "Both the held reagent container and the system's reagent storage are empty")
		return

	if(!held_beaker.reagents.total_volume && meds_beaker.reagents.total_volume) //Pills should never be empty so we don't worry about loading into them
		var/pick = tgui_input_list(wearer, "Unload internal reagent storage into held container:", "Vali system", list("Yes", "No"))
		if(pick == "Yes")
			if(!do_after(wearer, 0.5 SECONDS, IGNORE_USER_LOC_CHANGE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS))
				return
			meds_beaker.reagents.trans_to(held_beaker, 30)
			to_chat(wearer, get_meds_beaker_contents())
		return

	if(meds_beaker.reagents.total_volume >= meds_beaker.volume)
		wearer.balloon_alert(wearer, "The system's reagent storage is full")
		return

	if(!do_after(wearer, 0.5 SECONDS, IGNORE_USER_LOC_CHANGE, held_item, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS))
		return

	var/trans = held_beaker.reagents.trans_to(meds_beaker, held_beaker.amount_per_transfer_from_this)
	wearer.balloon_alert(wearer, "Loaded [trans] units")
	to_chat(wearer, get_meds_beaker_contents())
	if(istype(held_beaker, /obj/item/reagent_containers/pill))
		qdel(held_beaker)

///Shows the loaded reagents to the person examining the parent/wearer
/datum/component/chem_booster/proc/get_meds_beaker_contents()
	if(!meds_beaker.reagents.total_volume)
		return span_notice("The system's reagent storage is empty.")
	. = span_notice("The system's reagent storage contains:\n")
	for(var/datum/reagent/R AS in meds_beaker.reagents.reagent_list)
		. += span_rose("[R.name] - [R.volume]u\n")

/datum/action/chem_booster/configure
	name = "Configure Vali Chemical Enhancement"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "cboost_configure"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_VALI_CONFIGURE,
	)

/datum/action/chem_booster/power
	name = "Power Vali Chemical Enhancement"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "cboost_off"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_VALI_HEAL,
	)
	///Records the last time the action was used to avoid accidentally cancelling the effect when spamming the button in-combat
	var/last_activated_time

/datum/action/chem_booster/power/action_activate()
	if(world.time < last_activated_time + 2 SECONDS)
		return
	last_activated_time = world.time

	. = ..()
	if(!.)
		return

	update_onoff_icon()

///Update icon based on the suit
/datum/action/chem_booster/power/proc/update_onoff_icon()
	var/datum/component/chem_booster/target_component = target
	if(target_component.boost_on)
		action_icon_state = "cboost_on"
	else
		action_icon_state = "cboost_off"
	update_button_icon()

/datum/action/chem_booster/connect_weapon
	name = "Connect Weapon"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "vali_weapon_connect"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_VALI_CONNECT,
	)

#undef EXTRACT
#undef LOAD
#undef BOOST_CONFIG
#undef VALI_INFO

#undef BRUTE_AMP
#undef BURN_AMP
#undef TOX_HEAL
#undef STAM_REG_AMP
#undef SPEED_BOOST
#undef REQ
#undef NAME
