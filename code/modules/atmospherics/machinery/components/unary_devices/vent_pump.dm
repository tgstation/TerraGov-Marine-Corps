#define EXT_BOUND	1
#define INT_BOUND	2
#define NO_BOUND	3

#define SIPHONING	0
#define RELEASING	1

/obj/machinery/atmospherics/components/unary/vent_pump
	icon_state = "vent_map-2"

	name = "air vent"
	desc = "Has a valve and pump attached to it."

	use_power = IDLE_POWER_USE
	can_unwrench = TRUE
	welded = FALSE
	level = 1
	layer = GAS_SCRUBBER_LAYER

	var/id_tag = null
	var/pump_direction = RELEASING

	var/pressure_checks = EXT_BOUND
	var/external_pressure_bound = ONE_ATMOSPHERE
	var/internal_pressure_bound = 0
	// EXT_BOUND: Do not pass external_pressure_bound
	// INT_BOUND: Do not pass internal_pressure_bound
	// NO_BOUND: Do not pass either

	var/radio_filter_out
	var/radio_filter_in

	pipe_state = "uvent"

/obj/machinery/atmospherics/components/unary/vent_pump/New()
	..()
	if(!id_tag)
		id_tag = assign_uid_vents()

/obj/machinery/atmospherics/components/unary/vent_pump/Destroy()
	var/area/A = get_area(src)
	if (A)
		A.air_vent_names -= id_tag
		A.air_vent_info -= id_tag
	return ..()

/obj/machinery/atmospherics/components/unary/vent_pump/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = getpipeimage(icon, "vent_cap", initialize_directions, piping_layer = piping_layer)
		add_overlay(cap)

	if(welded)
		icon_state = "vent_welded"
		return

	if(!nodes[1] || !on || !is_operational())
		if(icon_state == "vent_welded")
			icon_state = "vent_off"
			return

		if(pump_direction & RELEASING)
			icon_state = "vent_out-off"
		else // pump_direction == SIPHONING
			icon_state = "vent_in-off"
		return

	if(icon_state == ("vent_out-off" || "vent_in-off" || "vent_off"))
		if(pump_direction & RELEASING)
			icon_state = "vent_out"
			flick("vent_out-starting", src)
		else // pump_direction == SIPHONING
			icon_state = "vent_in"
			flick("vent_in-starting", src)
		return

	if(pump_direction & RELEASING)
		icon_state = "vent_out"
	else // pump_direction == SIPHONING
		icon_state = "vent_in"


/obj/machinery/atmospherics/components/unary/vent_pump/weld_cut_act(mob/living/user, obj/item/W)
	if(istype(W, /obj/item/tool/pickaxe/plasmacutter))
		var/obj/item/tool/pickaxe/plasmacutter/P = W
		if(!welded)
			to_chat(user, "<span class='warning'>\The [P] can only cut open welds!</span>")
			return FALSE
		if(!(P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)))
			return FALSE
		if(do_after(user, P.calc_delay(user) * PLASMACUTTER_VLOW_MOD, TRUE, src, BUSY_ICON_BUILD))
			P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Vents require much less charge
			welded = FALSE
			update_icon()
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/unary/vent_pump/welder_act(mob/living/user, obj/item/I)
	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(WT.remove_fuel(1, user))
			user.visible_message("<span class='notice'>[user] starts welding [src] with [WT].</span>", \
			"<span class='notice'>You start welding [src] with [WT].</span>")
			playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
			if(do_after(user, 50, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
				playsound(get_turf(src), 'sound/items/welder2.ogg', 25, 1)
				if(!welded)
					user.visible_message("<span class='notice'>[user] welds [src] shut.</span>", \
					"<span class='notice'>You weld [src] shut.</span>")
					welded = TRUE
				else
					user.visible_message("<span class='notice'>[user] welds [src] open.</span>", \
					"<span class='notice'>You weld [src] open.</span>")
					welded = FALSE
				update_icon()
				pipe_vision_img = image(src, loc, layer = ABOVE_HUD_LAYER, dir = dir)
				pipe_vision_img.plane = ABOVE_HUD_PLANE
				return TRUE
			else
				to_chat(user, "<span class='warning'>[WT] needs to be on to start this task.</span>")
				return FALSE
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/unary/vent_pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE

/obj/machinery/atmospherics/components/unary/vent_pump/examine(mob/user)
	..()
	if(welded)
		to_chat(user, "It seems welded shut.")

/obj/machinery/atmospherics/components/unary/vent_pump/power_change()
	..()
	update_icon_nopipes()

/obj/machinery/atmospherics/components/unary/vent_pump/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/components/unary/vent_pump/attack_alien(mob/user)
	if(!welded || !(do_after(user, 20, FALSE, src, BUSY_ICON_HOSTILE)))
		return
	user.visible_message("[user] furiously claws at [src]!", "We manage to clear away the stuff blocking the vent", "You hear loud scraping noises.")
	welded = FALSE
	update_icon()
	pipe_vision_img = image(src, loc, layer = ABOVE_HUD_LAYER, dir = dir)
	pipe_vision_img.plane = ABOVE_HUD_PLANE
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, 1)


/obj/machinery/atmospherics/components/unary/vent_pump/AltClick(mob/user)
	user.handle_ventcrawl(src)



/obj/machinery/atmospherics/components/unary/vent_pump/high_volume
	name = "large air vent"
	power_channel = EQUIP

// mapping

/obj/machinery/atmospherics/components/unary/vent_pump/layer1
	piping_layer = 1
	icon_state = "vent_map-1"

/obj/machinery/atmospherics/components/unary/vent_pump/layer3
	piping_layer = 3
	icon_state = "vent_map-3"

/obj/machinery/atmospherics/components/unary/vent_pump/on
	on = TRUE
	icon_state = "vent_map_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/on/layer1
	piping_layer = 1
	icon_state = "vent_map_on-1"

/obj/machinery/atmospherics/components/unary/vent_pump/on/layer3
	piping_layer = 3
	icon_state = "vent_map_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon
	pump_direction = SIPHONING
	pressure_checks = INT_BOUND
	internal_pressure_bound = 4000
	external_pressure_bound = 0

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on
	on = TRUE
	icon_state = "vent_map_siphon_on-2"

#undef INT_BOUND
#undef EXT_BOUND
#undef NO_BOUND

#undef SIPHONING
#undef RELEASING
