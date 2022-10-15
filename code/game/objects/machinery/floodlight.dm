/obj/machinery/floodlight
	name = "Emergency Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	anchored = TRUE
	density = TRUE
	coverage = 25
	light_system = STATIC_LIGHT
	light_power = SQRTWO
	///The brightness of the floodlight
	var/brightness_on = 8

/obj/machinery/floodlight/Initialize()
	. = ..()
	GLOB.nightfall_toggleable_lights += src

/obj/machinery/floodlight/Destroy()
	GLOB.nightfall_toggleable_lights -= src
	return ..()

/obj/machinery/floodlight/attack_hand(mob/living/user)
	return

/obj/machinery/floodlight/attackby()
	return

/obj/machinery/floodlight/turn_light(mob/user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	if(toggle_on)
		if(user)
			to_chat(user, span_notice("You turn on the light."))
		set_light(brightness_on)
		DISABLE_BITFIELD(resistance_flags, UNACIDABLE)
		return
	if(user)
		to_chat(user, span_notice("You turn off the light."))
	set_light(0)
	ENABLE_BITFIELD(resistance_flags, UNACIDABLE)

/obj/machinery/floodlight/landing
	name = "Landing Light"
	desc = "A powerful light stationed near landing zones to provide better visibility."
	icon_state = "flood01"
	use_power = 0
	brightness_on = 6

/obj/machinery/floodlight/landing/Initialize()
	. = ..()
	set_light(brightness_on)

/obj/machinery/floodlight/outpost
	name = "Outpost Light"
	icon_state = "flood01"
	use_power = FALSE
	brightness_on = 10

/obj/machinery/floodlight/outpost/Initialize()
	. = ..()
	set_light(brightness_on)

/obj/machinery/floodlight/landing/hq
	name = "Installation Light"
	desc = "A powerful light stationed on the base to provide better visibility."

/obj/machinery/floodlight/landing/Initialize()
	. = ..()
	set_light(brightness_on)

/obj/machinery/floodlight/landing/testroom
	name = "Ambience Light"
	desc = "A powerful light placed concealed on the base to provide better visibility."
	density = 0
	alpha = 0
	resistance_flags = RESIST_ALL
	brightness_on = 25

/obj/machinery/floodlight/landing/testroom/Initialize()
	. = ..()
	set_light(brightness_on)

/obj/machinery/floodlightcombat
	name = "Armoured Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "floodlightcombat_off"
	anchored = FALSE
	density = TRUE
	light_power = SQRTWO
	light_system = STATIC_LIGHT
	///the cell powering this floodlight
	var/obj/item/cell/cell
	/// The charge consumption every 2 seconds
	var/energy_consummed = 6
	/// The lighting power of the floodlight
	var/floodlight_light_range = 15

/obj/machinery/floodlightcombat/Initialize()
	. = ..()
	cell = new()
	GLOB.nightfall_toggleable_lights += src

/obj/machinery/floodlightcombat/Destroy()
	QDEL_NULL(cell)
	GLOB.nightfall_toggleable_lights -= src
	return ..()


/obj/machinery/floodlightcombat/examine(mob/user)
	. = ..()
	if(!cell)
		. += span_notice("It has no cell installed")
		return
	. += span_notice("[cell] has [CEILING(cell.charge / cell.maxcharge * 100, 1)]% charge left")

/// Handles the wrench act .
/obj/machinery/floodlightcombat/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user , span_notice("You begin wrenching \the [src]'s bolts."))
	playsound(loc, 'sound/items/ratchet.ogg', 60, FALSE)
	if(!do_after(user, 2 SECONDS, TRUE, src))
		return FALSE
	if(anchored)
		to_chat(user , span_notice("You unwrench \the [src]'s bolts."))
		anchored = FALSE
		if(light_on)
			turn_light(user, FALSE, forced = TRUE)
	else
		to_chat(user , span_notice("You wrench down \the [src]'s bolts."))
		anchored = TRUE

/obj/machinery/floodlightcombat/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(!user)
		return
	if(!cell)
		to_chat(user, span_warning("There is no cell to remove!"))
		return
	if(!do_after(user, 2 SECONDS, TRUE, src))
		return FALSE
	playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
	to_chat(user , span_notice("You remove [cell] from \the [src]."))
	user.put_in_hands(cell)
	cell = null
	turn_light(user, FALSE, forced = TRUE)

/obj/machinery/floodlightcombat/process()
	cell.charge -= energy_consummed
	if(cell.charge > 0)
		return
	cell.charge = 0
	turn_light(null, FALSE, forced = TRUE)

/obj/machinery/floodlightcombat/attackby(obj/item/I, mob/user, params)
	if(!ishuman(user))
		return FALSE
	if(!istype(I, /obj/item/cell))
		return FALSE
	if(cell)
		to_chat(user , span_warning("There is already a cell inside, use a crowbar to remove it."))
		return
	if(!do_after(user, 2 SECONDS, TRUE, src))
		return FALSE
	I.forceMove(src)
	user.temporarilyRemoveItemFromInventory(I)
	cell = I
	playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

/obj/machinery/floodlightcombat/turn_light(user, toggle_on , cooldown, sparks, forced)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	if(toggle_on)
		set_light(floodlight_light_range, 5, COLOR_WHITE)
		start_processing()
	else
		set_light(0, 5, COLOR_WHITE)
		stop_processing()
	playsound(src,'sound/machines/click.ogg', 15, 1)
	update_icon()

/obj/machinery/floodlightcombat/attack_hand(mob/living/user)
	if(!ishuman(user))
		return FALSE
	if(!anchored)
		to_chat(user, span_warning("You need to anchor \the [src] with a wrench before you can turn it on!"))
		return
	if(!cell)
		to_chat(user, span_warning("There is no cell powering \the [src]!"))
		return
	if(cell.charge <= 0)
		to_chat(user, span_warning("The cell inside is out of juice!"))
		return
	turn_light(user, !light_on)
	return TRUE

/obj/machinery/floodlightcombat/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(!light_on)
		return ..()
	X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	X.visible_message(span_danger("[X] slashes \the [src]!"), \
	span_danger("We slash \the [src]!"), null, 5)
	playsound(loc, "alien_claw_metal", 25, 1)
	turn_light(X, FALSE, forced = TRUE)

/obj/machinery/floodlightcombat/update_icon_state()
	icon_state = "floodlightcombat" + (light_on ? "_on" : "_off")

#define FLOODLIGHT_TICK_CONSUMPTION 800

/obj/machinery/floodlight/colony
	name = "Colony Floodlight"
	icon_state = "floodoff"
	brightness_on = 7
	var/obj/machinery/colony_floodlight_switch/fswitch = null //Reverse lookup for power grabbing in area

/obj/machinery/floodlight/colony/Initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_FLOODLIGHT_SWITCH, .proc/floodswitch_powered)

/obj/machinery/floodlight/colony/Destroy()
	turn_light(null, FALSE)
	UnregisterSignal(SSdcs, COMSIG_GLOB_FLOODLIGHT_SWITCH)
	return ..()

///Make the link between the floodlight and the switch
/obj/machinery/floodlight/colony/proc/floodswitch_powered(datum/source, floodswitch, toggle_on)
	SIGNAL_HANDLER
	fswitch = floodswitch
	turn_light(null, toggle_on)

/obj/machinery/floodlight/colony/reset_light()
	if(fswitch?.turned_on)
		turn_light(null, TRUE)

/obj/machinery/floodlight/colony/turn_light(mob/user, toggle_on)
	. = ..()
	if(toggle_on)
		fswitch?.active_power_usage += FLOODLIGHT_TICK_CONSUMPTION
	else
		fswitch?.active_power_usage -= FLOODLIGHT_TICK_CONSUMPTION
	update_icon()


/obj/machinery/floodlight/colony/update_icon()
	. = ..()
	if(light_on)
		icon_state = "floodon"
	else
		icon_state = "floodoff"

#undef FLOODLIGHT_TICK_CONSUMPTION

/obj/machinery/colony_floodlight_switch
	name = "Colony Floodlight Switch"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "panelnopower"
	desc = "This switch controls the floodlights surrounding the archaeology complex. It only functions when there is power."
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 0
	resistance_flags = RESIST_ALL
	var/turned_on = FALSE //has to be toggled in engineering

/obj/machinery/colony_floodlight_switch/update_icon()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "panelnopower"
	else if(turned_on)
		icon_state = "panelon"
	else
		icon_state = "paneloff"

/obj/machinery/colony_floodlight_switch/power_change()
	. = ..()
	if(machine_stat && NOPOWER)
		if(turned_on)
			toggle_lights(FALSE)
			turned_on = FALSE
	update_icon()

/obj/machinery/colony_floodlight_switch/proc/toggle_lights(switch_on)
	turned_on = switch_on
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_FLOODLIGHT_SWITCH, src, switch_on)

/obj/machinery/colony_floodlight_switch/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		to_chat(user, span_notice("Nice try."))
		return FALSE
	if(machine_stat & NOPOWER)
		to_chat(user, span_notice("Nothing happens."))
		return FALSE
	playsound(src,'sound/machines/click.ogg', 15, 1)
	toggle_lights(turned_on ? FALSE : TRUE)
	update_icon()
	return TRUE
