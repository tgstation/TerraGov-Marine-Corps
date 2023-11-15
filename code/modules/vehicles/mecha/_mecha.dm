/***************** WELCOME TO MECHA.DM, ENJOY YOUR STAY *****************/

/**
 * Mechs are now (finally) vehicles, this means you can make them multicrew
 * They can also grant select ability buttons based on occupant bitflags
 *
 * Movement is handled through vehicle_move() which is called by relaymove
 * Clicking is done by way of signals registering to the entering mob
 * NOTE: MMIS are NOT mobs but instead contain a brain that is, so you need special checks
 * AI also has special checks becaus it gets in and out of the mech differently
 * Always call remove_occupant(mob) when leaving the mech so the mob is removed properly
 *
 * For multi-crew, you need to set how the occupants recieve ability bitflags corresponding to their status on the vehicle(i.e: driver, gunner etc)
 * Abilities can then be set to only apply for certain bitflags and are assigned as such automatically
 *
 * Clicks are wither translated into mech_melee_attack (see mech_melee_attack.dm)
 * Or are used to call action() on equipped gear
 * Cooldown for gear is on the mech because exploits
 */
/obj/vehicle/sealed/mecha
	name = "mecha"
	desc = "Exosuit"
	icon = 'icons/mecha/mecha.dmi'
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_OVERPOWERING
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE|PORTAL_IMMUNE|PLASMACUTTER_IMMUNE
	flags_atom = BUMP_ATTACKABLE|PREVENT_CONTENTS_EXPLOSION
	max_integrity = 300
	soft_armor = list(MELEE = 20, BULLET = 10, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 100, ACID = 100)
	force = 5
	move_delay = 1 SECONDS
	COOLDOWN_DECLARE(mecha_bump_smash)
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	light_range = 8
	generic_canpass = FALSE
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD, ORDER_HUD)
	mouse_pointer = 'icons/mecha/mecha_mouse.dmi'
	///What direction will the mech face when entered/powered on? Defaults to South.
	var/dir_in = SOUTH
	///How much energy the mech will consume each time it moves. This variable is a backup for when leg actuators affect the energy drain.
	var/normal_step_energy_drain = 10
	///How much energy the mech will consume each time it moves. this is the current active energy consumed
	var/step_energy_drain = 10
	///How much energy we drain each time we mechpunch someone
	var/melee_energy_drain = 15
	///The minimum amount of energy charge consumed by leg overload
	var/overload_step_energy_drain_min = 50
	///Modifiers for directional damage reduction
	var/list/facing_modifiers = list(MECHA_FRONT_ARMOUR = 0.5, MECHA_SIDE_ARMOUR = 1, MECHA_BACK_ARMOUR = 1.5)
	///if we cant use our equipment(such as due to EMP)
	var/equipment_disabled = FALSE
	/// Keeps track of the mech's cell
	var/obj/item/cell/cell
	/// Keeps track of the mech's scanning module
	var/obj/item/stock_parts/scanning_module/scanmod
	/// Keeps track of the mech's capacitor
	var/obj/item/stock_parts/capacitor/capacitor
	///Whether the mechs maintenance protocols are on or off
	var/construction_state = MECHA_LOCKED
	///Contains flags for the mecha
	var/mecha_flags = ADDING_ACCESS_POSSIBLE | CANSTRAFE | IS_ENCLOSED | HAS_HEADLIGHTS
	///Stores the DNA enzymes of a carbon so tht only they can access the mech
	var/dna_lock
	///Spark effects are handled by this datum
	var/datum/effect_system/spark_spread/spark_system = new
	///How powerful our lights are
	var/lights_power = 6
	///Just stop the mech from doing anything
	var/completely_disabled = FALSE
	///Whether this mech is allowed to move diagonally
	var/allow_diagonal_movement = FALSE
	///Whether or not the mech destroys walls by running into it.
	var/bumpsmash = FALSE

	///////////ATMOS
	///Whether we are currrently drawing from the internal tank
	var/use_internal_tank = FALSE
	///The setting of the valve on the internal tank
	var/internal_tank_valve = ONE_ATMOSPHERE
	///The internal air tank obj of the mech
	var/obj/machinery/portable_atmospherics/canister/air/internal_tank
	///The connected air port, if we have one
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port

	///Special version of the radio, which is unsellable
	var/obj/item/radio/mech/radio
	var/list/trackers = list()

	var/max_temperature = 25000

	///Bitflags for internal damage
	var/internal_damage = NONE
	/// damage amount above which we can take internal damages
	var/internal_damage_threshold = 15
	/// % chance for internal damage to occur
	var/internal_damage_probability = 20
	/// list of possibly dealt internal damage for this mech type
	var/possible_int_damage = MECHA_INT_FIRE|MECHA_INT_TEMP_CONTROL|MECHA_INT_TANK_BREACH|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	/// damage threshold above which we take component damage
	var/component_damage_threshold = 10

	///required access level for mecha operation
	var/list/operation_req_access = list()
	///required access to change internal components
	var/list/internals_req_access = list()

	///Typepath for the wreckage it spawns when destroyed
	var/wreckage
	///single flag for the type of this mech, determines what kind of equipment can be attached to it
	var/mech_type

	///assoc list: key-typepathlist before init, key-equipmentlist after
	var/list/equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	///assoc list: max equips for non-arm modules key-count
	var/list/max_equip_by_category = list(
		MECHA_UTILITY = 0,
		MECHA_POWER = 1,
		MECHA_ARMOR = 0,
	)
	///flat equipment for iteration
	var/list/flat_equipment

	///Whether our steps are silent due to no gravity
	var/step_silent = FALSE
	///Sound played when the mech moves
	var/stepsound = 'sound/mecha/mechstep.ogg'
	///Sound played when the mech walks
	var/turnsound = 'sound/mecha/mechturn.ogg'

	///Cooldown duration between melee punches
	var/melee_cooldown = 10

	///TIme taken to leave the mech
	var/exit_delay = 2 SECONDS
	///Time you get slept for if you get forcible ejected by the mech exploding
	var/destruction_sleep_duration = 2 SECONDS
	///Whether outside viewers can see the pilot inside
	var/enclosed = TRUE
	///In case theres a different iconstate for AI/MMI pilot(currently only used for ripley)
	var/silicon_icon_state = null
	///Currently ejecting, and unable to do things
	var/is_currently_ejecting = FALSE
	///Safety for weapons. Won't fire if enabled, and toggled by middle click.
	var/weapons_safety = FALSE

	var/datum/effect_system/smoke_spread/bad/smoke_system = new

	////Action vars
	///Bool for energy shield on/off
	var/defense_mode = FALSE

	///Bool for leg overload on/off
	var/leg_overload_mode = FALSE
	///Energy use modifier for leg overload
	var/leg_overload_coeff = 5
	///stores value that we will add and remove from the mecha when toggling leg overload
	var/speed_mod = 0

	//Bool for zoom on/off
	var/zoom_mode = FALSE

	///Remaining smoke charges
	var/smoke_charges = 5
	///Cooldown between using smoke
	var/smoke_cooldown = 10 SECONDS

	///check for phasing, if it is set to text (to describe how it is phasing: "flying", "phasing") it will let the mech walk through walls.
	var/phasing = ""
	///Power we use every time we phaze through something
	var/phasing_energy_drain = 200
	///icon_state for flick() when phazing
	var/phase_state = ""

	///Wether we are strafing
	var/strafe = FALSE

	///Cooldown length between bumpsmashes
	var/smashcooldown = 3

	/// Ui size, so you can make the UI bigger if you let it load a lot of stuff
	var/ui_x = 1100
	/// Ui size, so you can make the UI bigger if you let it load a lot of stuff
	var/ui_y = 600
	/// ref to screen object that displays in the middle of the UI
	var/atom/movable/screen/mech_view/ui_view

/obj/item/radio/mech //this has to go somewhere
	subspace_transmission = TRUE

/obj/vehicle/sealed/mecha/Initialize(mapload)
	. = ..()
	ui_view = new(null, src)
	if(enclosed)
		internal_tank = new (src)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(play_stepsound))

	spark_system.set_up(2, 0, src)
	spark_system.attach(src)

	smoke_system.set_up(3, loca = src)
	smoke_system.attach(src)

	radio = new(src)
	radio.name = "[src] radio"

	GLOB.nightfall_toggleable_lights += src
	add_cell()
	add_scanmod()
	add_capacitor()
	START_PROCESSING(SSobj, src)
	log_message("[src.name] created.", LOG_MECHA)
	GLOB.mechas_list += src //global mech list
	prepare_huds()
	for(var/datum/atom_hud/squad/mech_status_hud in GLOB.huds) //Add to the squad HUD
		mech_status_hud.add_to_hud(src)
	hud_set_mecha_health()
	hud_set_mecha_battery()
	update_icon()

	become_hearing_sensitive(trait_source = ROUNDSTART_TRAIT)
	for(var/key in equip_by_category)
		if(key == MECHA_L_ARM || key == MECHA_R_ARM)
			var/path = equip_by_category[key]
			if(!path)
				continue
			var/obj/item/mecha_parts/mecha_equipment/thing = new path
			thing.attach(src, key == MECHA_R_ARM)
			continue
		for(var/path in equip_by_category[key])
			var/obj/item/mecha_parts/mecha_equipment/thing = new path
			thing.attach(src, FALSE)
			equip_by_category[key] -= path

/obj/vehicle/sealed/mecha/Destroy()
	for(var/ejectee in occupants)
		mob_exit(ejectee, TRUE, TRUE)

	GLOB.nightfall_toggleable_lights -= src

	if(LAZYLEN(flat_equipment))
		for(var/obj/item/mecha_parts/mecha_equipment/equip AS in flat_equipment)
			equip.detach(loc)
			qdel(equip)
	radio = null

	STOP_PROCESSING(SSobj, src)
	LAZYCLEARLIST(flat_equipment)

	QDEL_NULL(cell)
	QDEL_NULL(scanmod)
	QDEL_NULL(capacitor)
	QDEL_NULL(internal_tank)
	QDEL_NULL(spark_system)
	QDEL_NULL(smoke_system)
	QDEL_NULL(ui_view)

	GLOB.mechas_list -= src //global mech list
	for(var/datum/atom_hud/squad/mech_status_hud in GLOB.huds) //Add to the squad HUD
		mech_status_hud.remove_from_hud(src)
	return ..()

/obj/vehicle/sealed/mecha/obj_destruction(damage_amount, damage_type, damage_flag)
	spark_system?.start()

	var/mob/living/silicon/ai/unlucky_ais
	for(var/mob/living/occupant AS in occupants)
		if(isAI(occupant))
			unlucky_ais = occupant
			occupant.gib() //No wreck, no AI to recover
			continue
		mob_exit(occupant, FALSE, TRUE)
		occupant.SetSleeping(destruction_sleep_duration)

	if(wreckage)
		var/obj/structure/mecha_wreckage/WR = new wreckage(loc, unlucky_ais)
		for(var/obj/item/mecha_parts/mecha_equipment/E in flat_equipment)
			if(E.detachable && prob(30))
				WR.crowbar_salvage += E
				E.detach(WR) //detaches from src into WR
				E.activated = TRUE
			else
				E.detach(loc)
				qdel(E)
		if(cell)
			WR.crowbar_salvage += cell
			cell.forceMove(WR)
			cell.use(rand(0, cell.charge), TRUE)
			cell = null
	return ..()


/obj/vehicle/sealed/mecha/update_icon_state()
	icon_state = get_mecha_occupancy_state()
	return ..()

/obj/vehicle/sealed/mecha/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	for(var/mob/living/future_pancake in loc)
		if(future_pancake.mob_size > MOB_SIZE_HUMAN)
			return
		if(!future_pancake.lying_angle && future_pancake.mob_size == MOB_SIZE_HUMAN)
			continue
		run_over(future_pancake)

///Crushing the mob underfoot
/obj/vehicle/sealed/mecha/proc/run_over(mob/living/crushed)
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	add_mob_blood(crushed)
	var/turf/below_us = get_turf(src)
	below_us.add_mob_blood(crushed)

	if(crushed.stat == DEAD)
		return
	log_combat(src, crushed, "stomped on", addition = "(DAMTYPE: [uppertext(BRUTE)])")
	crushed.visible_message(
		span_danger("[src] crushes [crushed]!"),
		span_userdanger("[src] steps on you!"),
	)
	crushed.emote(pick("scream", "pain"))
	crushed.take_overall_damage(rand(10, 30) * move_delay, BRUTE, MELEE, FALSE, FALSE, TRUE, 0, 2)

/**
 * Toggles Weapons Safety
 *
 * Handles enabling or disabling the safety function.
 */
/obj/vehicle/sealed/mecha/proc/set_safety(mob/user)
	weapons_safety = !weapons_safety
	SEND_SOUND(user, sound('sound/machines/beep.ogg', volume = 25))
	balloon_alert(user, "equipment [weapons_safety ? "safe" : "ready"]")
	set_mouse_pointer()

/**
 * Updates the pilot's mouse cursor override.
 *
 * If the mech's weapons safety is enabled, there should be no override, and the user gets their regular mouse cursor. If safety
 * is off but the mech's equipment is disabled (such as by EMP), the cursor should be the red disabled version. Otherwise, if
 * safety is off and the equipment is functional, the cursor should be the regular green cursor. This proc sets the cursor.
 * correct and then updates it for each mob in the occupants list.
 */
/obj/vehicle/sealed/mecha/proc/set_mouse_pointer()
	if(weapons_safety)
		mouse_pointer = ""
	else
		if(equipment_disabled)
			mouse_pointer = 'icons/mecha/mecha_mouse-disable.dmi'
		else
			mouse_pointer = 'icons/mecha/mecha_mouse.dmi'

	for(var/mob/mob_occupant AS in occupants)
		mob_occupant.client.mouse_pointer_icon = mouse_pointer // note this is update_mouse_pointer() on tg

//override this proc if you need to split up mecha control between multiple people (see savannah_ivanov.dm)
/obj/vehicle/sealed/mecha/auto_assign_occupant_flags(mob/M)
	if(driver_amount() < max_drivers)
		add_control_flags(M, FULL_MECHA_CONTROL)

/obj/vehicle/sealed/mecha/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_internals, VEHICLE_CONTROL_SETTINGS)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights, VEHICLE_CONTROL_SETTINGS)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats, VEHICLE_CONTROL_SETTINGS)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/strafe, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/mecha/proc/get_mecha_occupancy_state()
	if((mecha_flags & SILICON_PILOT) && silicon_icon_state)
		return silicon_icon_state
	if(LAZYLEN(occupants))
		return base_icon_state
	return "[base_icon_state]-open"

/obj/vehicle/sealed/mecha/CanPassThrough(atom/blocker, movement_dir, blocker_opinion)
	if(!phasing || get_charge() <= phasing_energy_drain || throwing)
		return ..()
	if(phase_state)
		flick(phase_state, src)
	return TRUE

/obj/vehicle/sealed/mecha/proc/restore_equipment()
	equipment_disabled = FALSE
	for(var/mob/mob_occupant AS in occupants)
		SEND_SOUND(mob_occupant, sound('sound/items/timer.ogg', volume=50))
		to_chat(mob_occupant, span_notice("Equipment control unit has been rebooted successfully."))
	set_mouse_pointer()

///Updates the values given by scanning module and capacitor tier, called when a part is removed or inserted.
/obj/vehicle/sealed/mecha/proc/update_part_values()
	if(scanmod)
		normal_step_energy_drain = 20 - (5 * scanmod.rating) //10 is normal, so on lowest part its worse, on second its ok and on higher its real good up to 0 on best
		step_energy_drain = normal_step_energy_drain
	else
		normal_step_energy_drain = 500
		step_energy_drain = normal_step_energy_drain
	if(capacitor)
		soft_armor = soft_armor.modifyRating(energy = (capacitor.rating * 5)) //Each level of capacitor protects the mech against emp by 5%
	else //because we can still be hit without a cap, even if we can't move
		soft_armor = soft_armor.setRating(energy = 0)

/obj/vehicle/sealed/mecha/examine(mob/user)
	. = ..()
	var/integrity = obj_integrity * 100/ max_integrity
	switch(integrity)
		if(85 to 100)
			. += "It's fully intact."
		if(65 to 85)
			. += "It's slightly damaged."
		if(45 to 65)
			. += "It's badly damaged."
		if(25 to 45)
			. += "It's heavily damaged."
		else
			. += "It's falling apart."
	if(LAZYLEN(flat_equipment))
		. += "It's equipped with:"
		for(var/obj/item/mecha_parts/mecha_equipment/ME AS in flat_equipment)
			. += "[icon2html(ME, user)] \A [ME]."
	if(enclosed)
		return
	if(mecha_flags & SILICON_PILOT)
		. += "[src] appears to be piloting itself..."
	else
		for(var/occupante in occupants)
			. += "You can see [occupante] inside."

//processing internal damage, temperature, air regulation, alert updates, lights power use.
/obj/vehicle/sealed/mecha/process(delta_time)
	if(internal_damage)
		if(internal_damage & MECHA_INT_FIRE)
			take_damage(10, BURN, FIRE)

		if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
			if(get_charge())
				spark_system.start()
				cell.charge -= min(10 * delta_time, cell.charge)
				cell.maxcharge -= min(10 * delta_time, cell.maxcharge)

	for(var/mob/living/occupant AS in occupants)
		if(!enclosed && occupant?.incapacitated()) //no sides mean it's easy to just sorta fall out if you're incapacitated.
			visible_message(span_warning("[occupant] tumbles out of the cockpit!"))
			mob_exit(occupant) //bye bye
			continue
		if(cell)
			var/cellcharge = cell.charge/cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					occupant.clear_alert(ALERT_CHARGE)
				if(0.5 to 0.75)
					occupant.throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/lowcell, 1)
				if(0.25 to 0.5)
					occupant.throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/lowcell, 2)
				if(0.01 to 0.25)
					occupant.throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/lowcell, 3)
				else
					occupant.throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/emptycell)

		var/integrity = obj_integrity/max_integrity*100
		switch(integrity)
			if(30 to 45)
				occupant.throw_alert(ALERT_MECH_DAMAGE, /atom/movable/screen/alert/low_mech_integrity, 1)
			if(15 to 35)
				occupant.throw_alert(ALERT_MECH_DAMAGE, /atom/movable/screen/alert/low_mech_integrity, 2)
			if(-INFINITY to 15)
				occupant.throw_alert(ALERT_MECH_DAMAGE, /atom/movable/screen/alert/low_mech_integrity, 3)
			else
				occupant.clear_alert(ALERT_MECH_DAMAGE)
		var/atom/checking = occupant.loc
		// recursive check to handle all cases regarding very nested occupants,
		// such as brainmob inside brainitem inside MMI inside mecha
		while(!isnull(checking))
			if(isturf(checking))
				// hit a turf before hitting the mecha, seems like they have been moved out
				occupant.clear_alert(ALERT_CHARGE)
				occupant.clear_alert(ALERT_MECH_DAMAGE)
				occupant = null
				break
			else if (checking == src)
				break  // all good
			checking = checking.loc

	if(mecha_flags & LIGHTS_ON)
		use_power(2*delta_time)

//Diagnostic HUD updates
	hud_set_mecha_health()
	hud_set_mecha_battery()

///Called when a driver clicks somewhere. Handles everything like equipment, punches, etc.
/obj/vehicle/sealed/mecha/proc/on_mouseclick(mob/user, atom/target, turf/location, control, list/modifiers)
	SIGNAL_HANDLER
	//tgmc add start
	modifiers = params2list(modifiers)
	if(isnull(location) && target.plane == CLICKCATCHER_PLANE) //Checks if the intended target is in deep darkness and adjusts target based on params.
		target = params2turf(modifiers["screen-loc"], get_turf(user), user.client)
		modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
		modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
	//tgmc add end
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		set_safety(user)
		return COMSIG_MOB_CLICK_CANCELED
	if(modifiers[SHIFT_CLICK]) //Allows things to be examined.
		return target.mech_shift_click(src, user)
	if(weapons_safety)
		return
	if(isAI(user)) //For AIs: If safeties are off, use mech functions. If safeties are on, use AI functions.
		. = COMSIG_MOB_CLICK_CANCELED
	if(!isturf(target) && !isturf(target.loc)) // Prevents inventory from being drilled
		return
	if(completely_disabled || is_currently_ejecting || (mecha_flags & CANNOT_INTERACT))
		return
	if(phasing)
		balloon_alert(user, "not while [phasing]!")
		return
	if(HAS_TRAIT(src, TRAIT_INCAPACITATED))
		return
	if(construction_state)
		balloon_alert(user, "end maintenance first!")
		return
	if(!get_charge())
		return
	if(src == target)
		return
	var/dir_to_target = get_dir(src,target)
	if(!(mecha_flags & OMNIDIRECTIONAL_ATTACKS) && dir_to_target && !(dir_to_target & dir))//wrong direction
		return
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		target = pick(view(3,target))
	var/mob/living/livinguser = user
	if(!(livinguser in return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)))
		balloon_alert(user, "wrong seat for equipment!")
		return
	var/obj/item/mecha_parts/mecha_equipment/selected
	if(modifiers[BUTTON] == RIGHT_CLICK)
		selected = equip_by_category[MECHA_R_ARM]
	else
		selected = equip_by_category[MECHA_L_ARM]
	if(!selected)
		return
	if(!Adjacent(target) && (selected.range & MECHA_RANGED))
		if(SEND_SIGNAL(src, COMSIG_MECHA_EQUIPMENT_CLICK, livinguser, target) & COMPONENT_CANCEL_EQUIPMENT_CLICK)
			return
		INVOKE_ASYNC(selected, TYPE_PROC_REF(/obj/item/mecha_parts/mecha_equipment, action), user, target, modifiers)
		return
	if((selected.range & MECHA_MELEE) && Adjacent(target))
		if(SEND_SIGNAL(src, COMSIG_MECHA_EQUIPMENT_CLICK, livinguser, target) & COMPONENT_CANCEL_EQUIPMENT_CLICK)
			return
		INVOKE_ASYNC(selected, TYPE_PROC_REF(/obj/item/mecha_parts/mecha_equipment, action), user, target, modifiers)
		return
	if(!(livinguser in return_controllers_with_flag(VEHICLE_CONTROL_MELEE)))
		to_chat(livinguser, span_warning("You're in the wrong seat to interact with your hands."))
		return
	var/on_cooldown = TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MELEE_ATTACK)
	var/adjacent = Adjacent(target)
	if(SEND_SIGNAL(src, COMSIG_MECHA_MELEE_CLICK, livinguser, target, on_cooldown, adjacent) & COMPONENT_CANCEL_MELEE_CLICK)
		return
	if(on_cooldown || !adjacent)
		return
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		target = pick(oview(1,src))

	if(!has_charge(melee_energy_drain))
		return
	use_power(melee_energy_drain)

	if(force)
		target.mech_melee_attack(src, user)
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MELEE_ATTACK, melee_cooldown)

/// middle mouse click signal wrapper for AI users
/obj/vehicle/sealed/mecha/proc/on_middlemouseclick(mob/user, atom/target, params)
	SIGNAL_HANDLER
	if(isAI(user))
		on_mouseclick(user, target, params)

///Displays a special speech bubble when someone inside the mecha speaks
/obj/vehicle/sealed/mecha/proc/display_speech_bubble(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in get_hearers_in_view(7,src))
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay), image('icons/mob/talk.dmi', src, "machine[say_test(speech_args[SPEECH_MESSAGE])]",MOB_LAYER+1), speech_bubble_recipients, 30)


/////////////////////////
////// Access stuff /////
/////////////////////////

/obj/vehicle/sealed/mecha/proc/operation_allowed(mob/M)
	req_access = operation_req_access
	req_one_access = list()
	return allowed(M)

/obj/vehicle/sealed/mecha/proc/internals_access_allowed(mob/M)
	req_one_access = internals_req_access
	req_access = list()
	return allowed(M)
