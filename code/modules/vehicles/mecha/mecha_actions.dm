/***************** MECHA ACTIONS *****************/

/obj/vehicle/sealed/mecha/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/mecha))
		var/datum/action/vehicle/sealed/mecha/mecha = .
		mecha.chassis = src

/datum/action/vehicle/sealed/mecha
	action_icon = 'icons/mob/actions/actions_mecha.dmi'
	///mech owner of this action
	var/obj/vehicle/sealed/mecha/chassis

/datum/action/vehicle/sealed/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/vehicle/sealed/mecha/mech_eject
	name = "Eject From Mech"
	action_icon_state = "mech_eject"

/datum/action/vehicle/sealed/mecha/mech_eject/action_activate(trigger_flags)
	if(!owner)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.resisted_against(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	action_icon_state = "mech_internals_off"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_TOGGLE_INTERNALS,
	)

/datum/action/vehicle/sealed/mecha/mech_toggle_internals/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	if(!chassis.internal_tank) //Just in case.
		chassis.use_internal_tank = FALSE
		chassis.balloon_alert(owner, "no tank available!")
		chassis.log_message("Switch to internal tank failed. No tank available.", LOG_MECHA)
		return

	chassis.use_internal_tank = !chassis.use_internal_tank
	action_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]"
	chassis.balloon_alert(owner, "taking air from [chassis.use_internal_tank ? "internal airtank" : "environment"]")
	chassis.log_message("Now taking air from [chassis.use_internal_tank?"internal airtank":"environment"].", LOG_MECHA)
	update_button_icon()

/datum/action/vehicle/sealed/mecha/mech_toggle_lights
	name = "Toggle Lights"
	action_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_lights/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	if(!(chassis.mecha_flags & HAS_HEADLIGHTS))
		chassis.balloon_alert(owner, "the mech lights are broken!")
		return
	chassis.mecha_flags ^= LIGHTS_ON
	if(chassis.mecha_flags & LIGHTS_ON)
		action_icon_state = "mech_lights_on"
	else
		action_icon_state = "mech_lights_off"
	chassis.set_light_on(chassis.mecha_flags & LIGHTS_ON)
	chassis.balloon_alert(owner, "toggled lights [chassis.mecha_flags & LIGHTS_ON ? "on":"off"]")
	playsound(chassis,'sound/mecha/brass_skewer.ogg', 40, TRUE)
	chassis.log_message("Toggled lights [(chassis.mecha_flags & LIGHTS_ON)?"on":"off"].", LOG_MECHA)
	update_button_icon()

/datum/action/vehicle/sealed/mecha/mech_view_stats
	name = "View Stats"
	action_icon_state = "mech_view_stats"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_VIEW_STATS,
	)
/datum/action/vehicle/sealed/mecha/mech_view_stats/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.ui_interact(owner)


/datum/action/vehicle/sealed/mecha/strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	action_icon_state = "strafe"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_TOGGLE_STRAFE,
	)
/datum/action/vehicle/sealed/mecha/strafe/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.toggle_strafe()

/obj/vehicle/sealed/mecha/AltClick(mob/living/user)
	if(!(user in occupants))
		return
	if(!(user in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)))
		to_chat(user, span_warning("You're in the wrong seat to control movement."))
		return

	toggle_strafe()

/obj/vehicle/sealed/mecha/proc/toggle_strafe()
	if(!(mecha_flags & CANSTRAFE))
		to_chat(occupants, "this mecha doesn't support strafing!")
		return

	strafe = !strafe

	to_chat(occupants, "strafing mode [strafe?"on":"off"].")
	log_message("Toggled strafing mode [strafe?"on":"off"].", LOG_MECHA)

	for(var/occupant in occupants)
		var/datum/action/action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/strafe)
		action?.update_button_icon()

///swap seats, for two person mecha
/datum/action/vehicle/sealed/mecha/swap_seat
	name = "Switch Seats"
	action_icon_state = "mech_seat_swap"

/datum/action/vehicle/sealed/mecha/swap_seat/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	if(chassis.occupants.len == chassis.max_occupants)
		chassis.balloon_alert(owner, "other seat occupied!")
		return
	var/list/drivers = chassis.return_drivers()
	chassis.balloon_alert(owner, "moving to other seat...")
	chassis.is_currently_ejecting = TRUE
	if(!do_after(owner, chassis.exit_delay, target = chassis))
		chassis.balloon_alert(owner, "interrupted!")
		chassis.is_currently_ejecting = FALSE
		return
	chassis.is_currently_ejecting = FALSE
	if(owner in drivers)
		chassis.balloon_alert(owner, "controlling gunner seat")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
	else
		chassis.balloon_alert(owner, "controlling pilot seat")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	chassis.update_icon_state()
/datum/action/vehicle/sealed/mecha/mech_overload_mode
	name = "Toggle leg actuators overload"
	action_icon_state = "mech_overload_off"

/datum/action/vehicle/sealed/mecha/mech_overload_mode/action_activate(trigger_flags, forced_state = null)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else
		chassis.leg_overload_mode = !chassis.leg_overload_mode
	action_icon_state = "mech_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled leg actuators overload.", LOG_MECHA)
	//tgmc add
	var/obj/item/mecha_parts/mecha_equipment/ability/dash/ability = locate() in chassis.equip_by_category[MECHA_UTILITY]
	if(ability)
		chassis.cut_overlay(ability.overlay)
		var/state = chassis.leg_overload_mode ? (initial(ability.icon_state) + "_active") : initial(ability.icon_state)
		ability.overlay = image('icons/mecha/mecha_ability_overlays.dmi', icon_state = state, layer=chassis.layer+0.001)
		chassis.add_overlay(ability.overlay)
		if(chassis.leg_overload_mode)
			ability.sound_loop.start(chassis)
		else
			ability.sound_loop.stop(chassis)
	//tgmc end
	if(chassis.leg_overload_mode)
		chassis.speed_mod = min(chassis.move_delay-1, round(chassis.move_delay * 0.5))
		chassis.move_delay -= chassis.speed_mod
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min,chassis.step_energy_drain*chassis.leg_overload_coeff)
		chassis.balloon_alert(owner,"leg actuators overloaded")
	else
		chassis.move_delay += chassis.speed_mod
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.balloon_alert(owner, "you disable the overload")
	update_button_icon()

/datum/action/vehicle/sealed/mecha/mech_smoke
	name = "Smoke"
	action_icon_state = "mech_smoke"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_SMOKE,
	)
/datum/action/vehicle/sealed/mecha/mech_smoke/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_SMOKE) && chassis.smoke_charges>0)
		chassis.smoke_system.start()
		chassis.smoke_charges--
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_SMOKE, chassis.smoke_cooldown)

/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	action_icon_state = "mech_zoom_off"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_TOGGLE_ZOOM,
	)
/datum/action/vehicle/sealed/mecha/mech_zoom/action_activate(trigger_flags)
	if(!owner?.client || !chassis || !(owner in chassis.occupants))
		return
	chassis.zoom_mode = !chassis.zoom_mode
	action_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
	chassis.log_message("Toggled zoom mode.", LOG_MECHA)
	to_chat(owner, "[icon2html(chassis, owner)]<font color='[chassis.zoom_mode?"blue":"red"]'>Zoom mode [chassis.zoom_mode?"en":"dis"]abled.</font>")
	if(chassis.zoom_mode)
		owner.client.view_size.set_view_radius_to(4.5)
		SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg', volume=50))
	else
		owner.client.view_size.reset_to_default()
	update_button_icon()

/datum/action/vehicle/sealed/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	action_icon_state = "mech_damtype_brute"

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/new_damtype
	switch(chassis.damtype)
		if(TOX)
			new_damtype = BRUTE
			chassis.balloon_alert(owner, "your punches will now deal brute damage")
		if(BRUTE)
			new_damtype = BURN
			chassis.balloon_alert(owner, "your punches will now deal burn damage")
		if(BURN)
			new_damtype = TOX
			chassis.balloon_alert(owner,"your punches will now deal toxin damage")
	chassis.damtype = new_damtype
	action_icon_state = "mech_damtype_[new_damtype]"
	playsound(chassis, 'sound/mecha/mechmove01.ogg', 50, TRUE)
	update_button_icon()

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	action_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.phasing = chassis.phasing ? "" : "phasing"
	action_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.balloon_alert(owner, "[chassis.phasing ? "enabled" : "disabled"] phasing")
	update_button_icon()

///Savannah Skyfall
/datum/action/vehicle/sealed/mecha/skyfall
	name = "Savannah Skyfall"
	action_icon_state = "mech_savannah"
	///cooldown time between skyfall uses
	var/skyfall_cooldown_time = 1 MINUTES
	///skyfall builds up in charges every 2 seconds, when it reaches 5 charges the ability actually starts
	var/skyfall_charge_level = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_SKYFALL,
	)
/datum/action/vehicle/sealed/mecha/skyfall/action_activate()
	. = ..()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(chassis.phasing)
		to_chat(owner, span_warning("You're already airborne!"))
		return
	if(TIMER_COOLDOWN_CHECK(chassis, COOLDOWN_MECHA_SKYFALL))
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(chassis, COOLDOWN_MECHA_SKYFALL)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before attempting to Skyfall."))
		return
	if(skyfall_charge_level)
		abort_skyfall()
		return
	chassis.balloon_alert(owner, "charging skyfall...")
	INVOKE_ASYNC(src, .proc/skyfall_charge_loop)

/**
 * ## skyfall_charge_loop
 *
 * The actual skyfall loop itself. Repeatedly calls itself after a do_after, so any interruptions will call abort_skyfall and end the loop
 * the other way the loop ends is if charge level (var it's ticking up) gets to SKYFALL_CHARGELEVEL_LAUNCH, in which case it ends the loop and does the ability.
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/skyfall_charge_loop()
	if(!do_after(owner, SKYFALL_SINGLE_CHARGE_TIME, target = chassis))
		abort_skyfall()
		return
	skyfall_charge_level++
	switch(skyfall_charge_level)
		if(1)
			chassis.visible_message(span_warning("[chassis] clicks and whirrs for a moment, with a low hum emerging from the legs."))
			playsound(chassis, 'sound/items/rped.ogg', 50, TRUE)
		if(2)
			chassis.visible_message(span_warning("[chassis] begins to shake, the sounds of electricity growing louder."))
			chassis.Shake(5, 5, SKYFALL_SINGLE_CHARGE_TIME-1) // -1 gives space between the animates, so they don't interrupt eachother
		if(3)
			chassis.visible_message(span_warning("[chassis] assumes a pose as it rattles violently."))
			chassis.Shake(7, 7, SKYFALL_SINGLE_CHARGE_TIME-1) // -1 gives space between the animates, so they don't interrupt eachother
			chassis.spark_system.start()
			chassis.update_icon()
		if(4)
			chassis.visible_message(span_warning("[chassis] sparks and shutters as it finalizes preparation."))
			playsound(chassis, 'sound/mecha/skyfall_power_up.ogg', 50, TRUE)
			chassis.Shake(10, 10, SKYFALL_SINGLE_CHARGE_TIME-1) // -1 gives space between the animates, so they don't interrupt eachother
			chassis.spark_system.start()
		if(SKYFALL_CHARGELEVEL_LAUNCH)
			chassis.visible_message(span_danger("[chassis] leaps into the air!"))
			playsound(chassis, 'sound/weapons/guns/fire/tank_smokelauncher.ogg', 50, TRUE)
	if(skyfall_charge_level != SKYFALL_CHARGELEVEL_LAUNCH)
		skyfall_charge_loop()
		return
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_SKYFALL, skyfall_cooldown_time)
	action_icon_state = "mech_savannah_cooldown"
	update_button_icon()
	addtimer(CALLBACK(src, .proc/reset_button_icon), skyfall_cooldown_time)
	for(var/mob/living/shaken in range(7, chassis))
		shake_camera(shaken, 3, 3)

	new /obj/effect/skyfall_landingzone(get_turf(chassis), chassis)
	chassis.resistance_flags |= INDESTRUCTIBLE //not while jumping at least
	chassis.mecha_flags |= QUIET_STEPS|QUIET_TURNS|CANNOT_INTERACT
	chassis.phasing = "flying"
	chassis.move_delay = 1
	chassis.density = FALSE
	chassis.layer = ABOVE_ALL_MOB_LAYER
	animate(chassis, alpha = 0, time = 8, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(chassis, pixel_z = 400, time = 10, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL) //Animate our rising mech (just like pods hehe)
	addtimer(CALLBACK(src, .proc/begin_landing), 2 SECONDS)

/**
 * ## begin_landing
 *
 * Called by skyfall_charge_loop after some time if it reaches full charge level.
 * it's just the animations of the mecha coming down + another timer for the final landing effect
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/begin_landing()
	animate(chassis, pixel_z = 0, time = 10, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(chassis, alpha = 255, time = 8, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, .proc/land), 1 SECONDS)

/**
 * ## land
 *
 * Called by skyfall_charge_loop after some time if it reaches full charge level.
 * it's just the animations of the mecha coming down + another timer for the final landing effect
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/land()
	chassis.visible_message(span_danger("[chassis] lands from above!"))
	playsound(chassis, 'sound/effects/explosion_large1.ogg', 50, 1)
	chassis.resistance_flags &= ~INDESTRUCTIBLE
	chassis.mecha_flags &= ~(QUIET_STEPS|QUIET_TURNS|CANNOT_INTERACT)
	chassis.phasing = initial(chassis.phasing)
	chassis.move_delay = initial(chassis.move_delay)
	chassis.density = TRUE
	chassis.layer = initial(chassis.layer)
	chassis.plane = initial(chassis.plane)
	skyfall_charge_level = 0
	chassis.update_icon()
	for(var/mob/living/shaken in range(7, chassis))
		shake_camera(shaken, 5, 5)
	var/turf/landed_on = get_turf(chassis)
	for(var/thing in range(1, chassis))
		if(isopenturf(thing))
			var/turf/open/floor/crushed_tile = thing
			crushed_tile.break_tile()
			continue
		if(isclosedturf(thing) && thing == landed_on)
			var/turf/closed/crushed_wall = thing
			crushed_wall.ScrapeAway()
			continue
		if(isobj(thing))
			var/obj/crushed_object = thing
			if(crushed_object == chassis || crushed_object.loc == chassis)
				continue
			crushed_object.take_damage(150) //same as a hulk punch, makes sense to me
			continue
		if(isliving(thing))
			var/mob/living/crushed_victim = thing
			if(crushed_victim in chassis.occupants)
				continue
			if(!(crushed_victim in landed_on))
				to_chat(crushed_victim, span_userdanger("The tremors from [chassis] landing sends you flying!"))
				var/fly_away_direction = get_dir(chassis, crushed_victim)
				crushed_victim.throw_at(get_edge_target_turf(crushed_victim, fly_away_direction), 4, 3)
				crushed_victim.adjustBruteLoss(15)
				continue
			to_chat(crushed_victim, span_userdanger("[chassis] crashes down on you from above!"))
			if(crushed_victim.stat != CONSCIOUS)
				crushed_victim.gib(FALSE, FALSE, FALSE)
				continue
			crushed_victim.adjustBruteLoss(80)

/**
 * ## abort_skyfall
 *
 * Called by skyfall_charge_loop if the charging is interrupted.
 * Applies cooldown and resets charge level
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/abort_skyfall()
	chassis.balloon_alert(owner, "skyfall aborted")
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_MISSILE_STRIKE, skyfall_charge_level * 10 SECONDS) //so aborting skyfall later in the process imposes a longer cooldown
	skyfall_charge_level = 0
	chassis.update_icon()

/**
 * ## reset_button_icon
 *
 * called after an addtimer when the cooldown is finished with the skyfall, resets the icon
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/reset_button_icon()
	action_icon_state = "mech_savannah"
	update_button_icon()

/datum/action/vehicle/sealed/mecha/ivanov_strike
	name = "Ivanov Strike"
	action_icon_state = "mech_ivanov"
	///cooldown time between strike uses
	var/strike_cooldown_time = 40 SECONDS
	///how many rockets can we send with ivanov strike
	var/rockets_left = 0
	var/aiming_missile = FALSE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_MECHABILITY_STRIKE,
	)
/datum/action/vehicle/sealed/mecha/ivanov_strike/Destroy()
	if(aiming_missile)
		end_missile_targeting()
	return ..()

/datum/action/vehicle/sealed/mecha/ivanov_strike/action_activate(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(TIMER_COOLDOWN_CHECK(chassis, COOLDOWN_MECHA_MISSILE_STRIKE))
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(chassis, COOLDOWN_MECHA_MISSILE_STRIKE)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before firing another Ivanov Strike."))
		return
	if(aiming_missile)
		end_missile_targeting()
	else
		start_missile_targeting()

/**
 * ## reset_button_icon
 *
 * called after an addtimer when the cooldown is finished with the ivanov strike, resets the icon
 */
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/reset_button_icon()
	action_icon_state = "mech_ivanov"
	update_button_icon()

/**
 * ## start_missile_targeting
 *
 * Called by the ivanov strike datum action, hooks signals into clicking to call drop_missile
 * Plus other flavor like the overlay
 */
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/start_missile_targeting()
	chassis.balloon_alert(owner, "missile mode on (click to target)")
	aiming_missile = TRUE
	rockets_left = 3
	RegisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK, .proc/on_melee_click)
	RegisterSignal(chassis, COMSIG_MECHA_EQUIPMENT_CLICK, .proc/on_equipment_click)
	owner.client.mouse_pointer_icon = 'icons/effects/supplypod_down_target.dmi'
	owner.update_mouse_pointer()
	owner.overlay_fullscreen("ivanov", /atom/movable/screen/fullscreen/ivanov_display, 1)
	SEND_SOUND(owner, 'sound/machines/terminal_on.ogg') //spammable so I don't want to make it audible to anyone else

/**
 * ## end_missile_targeting
 *
 * Called by the ivanov strike datum action or other actions that would end targetting
 * Unhooks signals into clicking to call drop_missile plus other flavor like the overlay
 */
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/end_missile_targeting()
	aiming_missile = FALSE
	rockets_left = 0
	UnregisterSignal(chassis, list(COMSIG_MECHA_MELEE_CLICK, COMSIG_MECHA_EQUIPMENT_CLICK))
	owner.client.mouse_pointer_icon = null
	owner.update_mouse_pointer()
	owner.clear_fullscreen("ivanov")

///signal called from clicking with no equipment
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(get_turf(target))

///signal called from clicking with equipment
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(get_turf(target))

/**
 * ## drop_missile
 *
 * Called via intercepted clicks when the missile ability is active
 * Spawns a droppod and starts the cooldown of the missile strike ability
 * arguments:
 * * target_turf: turf of the atom that was clicked on
 */
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/drop_missile(turf/target_turf)
	rockets_left--
	if(rockets_left <= 0)
		end_missile_targeting()
	SEND_SOUND(owner, 'sound/machines/triple_beep.ogg')
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_MISSILE_STRIKE, strike_cooldown_time)
	/** podspawn(list(
		"target" = target_turf,
		"style" = STYLE_MISSILE,
		"effectMissile" = TRUE,
		"explosionSize" = list(0,0,1,2)
	)) */
	action_icon_state = "mech_ivanov_cooldown"
	update_button_icon()
	addtimer(CALLBACK(src, /datum/action/vehicle/sealed/mecha/ivanov_strike.proc/reset_button_icon), strike_cooldown_time)

//misc effects

///a simple indicator of where the skyfall is going to land.
/obj/effect/skyfall_landingzone
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/effects/telegraph_96x96.dmi'
	icon_state = "target_largebox"
	layer = BELOW_MOB_LAYER
	pixel_x = -32
	pixel_y = -32
	alpha = 0
	///reference to mecha following
	var/obj/vehicle/sealed/mecha/combat/mecha

/obj/effect/skyfall_landingzone/Initialize(mapload, obj/vehicle/sealed/mecha/combat/mecha)
	. = ..()
	if(!mecha)
		stack_trace("Skyfall landing zone created without mecha")
		return INITIALIZE_HINT_QDEL
	src.mecha = mecha
	animate(src, alpha = 255, TOTAL_SKYFALL_LEAP_TIME/2, easing = CIRCULAR_EASING|EASE_OUT)
	RegisterSignal(mecha, COMSIG_MOVABLE_MOVED, .proc/follow)
	QDEL_IN(src, TOTAL_SKYFALL_LEAP_TIME) //when the animations land

/obj/effect/skyfall_landingzone/Destroy(force)
	mecha = null
	return ..()

///called when the mecha moves
/obj/effect/skyfall_landingzone/proc/follow(datum/source_mecha)
	SIGNAL_HANDLER
	forceMove(get_turf(source_mecha))

#undef SKYFALL_SINGLE_CHARGE_TIME
#undef SKYFALL_CHARGELEVEL_LAUNCH

#undef TOTAL_SKYFALL_LEAP_TIME
