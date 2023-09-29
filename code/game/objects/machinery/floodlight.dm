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

/obj/machinery/floodlight/Initialize(mapload)
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

/obj/machinery/floodlight/landing/Initialize(mapload)
	. = ..()
	set_light(brightness_on)

/obj/machinery/floodlight/outpost
	name = "Outpost Light"
	icon_state = "flood01"
	use_power = FALSE
	brightness_on = 10

/obj/machinery/floodlight/outpost/oscar
	brightness_on = 30

/obj/machinery/floodlight/outpost/Initialize(mapload)
	. = ..()
	set_light(brightness_on)

/obj/machinery/floodlight/landing/hq
	name = "Installation Light"
	desc = "A powerful light stationed on the base to provide better visibility."


/obj/machinery/floodlight/landing/testroom
	name = "Ambience Light"
	desc = "A powerful light placed concealed on the base to provide better visibility."
	density = 0
	alpha = 0
	resistance_flags = RESIST_ALL
	brightness_on = 25

/obj/machinery/floodlight/landing/testroom/Initialize(mapload)
	. = ..()
	set_light(brightness_on)

/obj/machinery/deployable/floodlight
	use_power = NO_POWER_USE
	anchored = TRUE
	density = TRUE
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	allow_pass_flags = PASSABLE
	/// The lighting power of the floodlight
	var/floodlight_light_range = 15
	/// The amount of integrity repaired with every welder act.
	var/repair_amount = 100

/obj/machinery/deployable/floodlight/Initialize(mapload)
	. = ..()
	GLOB.nightfall_toggleable_lights += src

/obj/machinery/deployable/floodlight/Destroy()
	GLOB.nightfall_toggleable_lights -= src
	return ..()

/obj/machinery/deployable/floodlight/examine(mob/user)
	. = ..()
	. += span_notice("It has [obj_integrity]/[max_integrity] integrity left.")

/obj/machinery/deployable/floodlight/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, repair_amount, 4 SECONDS)

/obj/machinery/deployable/floodlight/turn_light(user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	if(toggle_on)
		if(user)
			to_chat(user, span_notice("You turn on the light."))
		set_light(floodlight_light_range, 5, COLOR_WHITE)
	else
		if(user)
			to_chat(user, span_notice("You turn off the light."))
		set_light(0)
	playsound(src,'sound/machines/click.ogg', 15, 1)
	update_icon()

/obj/machinery/deployable/floodlight/attack_hand(mob/living/user)
	turn_light(user, !light_on)

/obj/machinery/deployable/floodlight/update_icon_state()
	icon_state = "floodlightcombat_deployed" + (light_on ? "_on" : "_off")

/obj/item/deployable_floodlight
	name = "\improper deployable floodlight"
	desc = "A powerful light able to be transported and deployed easily for a very long lasting light."
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "floodlightcombat"
	max_integrity = 200
	flags_item = IS_DEPLOYABLE
	w_class = WEIGHT_CLASS_NORMAL
	var/deployable_item = /obj/machinery/deployable/floodlight

/obj/item/deployable_floodlight/Initialize()
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, 5 SECONDS, 3 SECONDS)

#define FLOODLIGHT_TICK_CONSUMPTION 800

/obj/machinery/floodlight/colony
	name = "Colony Floodlight"
	icon_state = "floodoff"
	brightness_on = 7
	var/obj/machinery/colony_floodlight_switch/fswitch = null //Reverse lookup for power grabbing in area

/obj/machinery/floodlight/colony/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_FLOODLIGHT_SWITCH, PROC_REF(floodswitch_powered))

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
