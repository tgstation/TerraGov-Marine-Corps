#define SIPHONING 0
#define SCRUBBING 1

/obj/machinery/atmospherics/components/unary/vent_scrubber
	icon_state = "scrub_map-2"

	name = "air scrubber"
	desc = "Has a valve and pump attached to it."
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 60
	can_unwrench = FALSE
	welded = FALSE
	level = 1
	layer = ATMOS_DEVICE_LAYER
	flags_atom = SHUTTLE_IMMUNE
	var/scrubbing = SCRUBBING //0 = siphoning, 1 = scrubbing

	var/filter_types = list()///datum/gas/carbon_dioxide)
	var/volume_rate = 200
	var/widenet = 0 //is this scrubber acting on the 3x3 area around it.
	var/list/turf/adjacent_turfs = list()

	pipe_state = "scrubber"

/obj/machinery/atmospherics/components/unary/vent_scrubber/auto_use_power()
	if(!on || welded || !is_operational() || !powered(power_channel))
		return FALSE

	var/amount = idle_power_usage

	if(scrubbing & SCRUBBING)
		amount += idle_power_usage * length(filter_types)
	else //scrubbing == SIPHONING
		amount = active_power_usage

	if(widenet)
		amount += amount * (length(adjacent_turfs) * (length(adjacent_turfs) / 2))
	use_power(amount, power_channel)
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = getpipeimage(icon, "scrub_cap", initialize_directions, piping_layer = piping_layer)
		add_overlay(cap)

	if(welded)
		icon_state = "scrub_welded"
		return

	if(!nodes[1] || !on || !is_operational())
		icon_state = "scrub_off"
		return

	if(scrubbing & SCRUBBING)
		if(widenet)
			icon_state = "scrub_wide"
		else
			icon_state = "scrub_on"
	else //scrubbing == SIPHONING
		icon_state = "scrub_purge"

/obj/machinery/atmospherics/components/unary/vent_scrubber/power_change()
	..()
	update_icon_nopipes()

/obj/machinery/atmospherics/components/unary/vent_scrubber/weld_cut_act(mob/living/user, obj/item/W)
	if(istype(W, /obj/item/tool/pickaxe/plasmacutter))
		var/obj/item/tool/pickaxe/plasmacutter/P = W

		if(!welded)
			to_chat(user, span_warning("\The [P] can only cut open welds!"))
			return FALSE
		if(!(P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)))
			return FALSE
		if(do_after(user, P.calc_delay(user) * PLASMACUTTER_VLOW_MOD, NONE, src, BUSY_ICON_BUILD))
			P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Vents require much less charge
			welded = FALSE
			update_icon()
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/unary/vent_scrubber/welder_act(mob/living/user, obj/item/W)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn())
			user.visible_message(span_notice("[user] starts welding [src] with [WT]."), \
			span_notice("You start welding [src] with [WT]."))
			add_overlay(GLOB.welding_sparks)
			playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
			if(do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, TYPE_PROC_REF(/obj/item/tool/weldingtool, isOn))) && WT.remove_fuel(1, user))
				playsound(get_turf(src), 'sound/items/welder2.ogg', 25, 1)
				if(!welded)
					user.visible_message(span_notice("[user] welds [src] shut."), \
					span_notice("You weld [src] shut."))
					cut_overlay(GLOB.welding_sparks)
					welded = TRUE
				else
					user.visible_message(span_notice("[user] welds [src] open."), \
					span_notice("You weld [src] open."))
					cut_overlay(GLOB.welding_sparks)
					welded = FALSE
				update_icon()
				pipe_vision_img = image(src, loc, layer = ABOVE_HUD_LAYER, dir = dir)
				pipe_vision_img.plane = ABOVE_HUD_PLANE
				cut_overlay(GLOB.welding_sparks)
				return TRUE
			else
				cut_overlay(GLOB.welding_sparks)
		else
			to_chat(user, span_warning("[WT] needs to be on to start this task."))
			cut_overlay(GLOB.welding_sparks)
	return FALSE

/obj/machinery/atmospherics/components/unary/vent_scrubber/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

/obj/machinery/atmospherics/components/unary/vent_scrubber/examine(mob/user)
	. = ..()
	if(welded)
		. += "It seems welded shut."

/obj/machinery/atmospherics/components/unary/vent_scrubber/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/components/unary/vent_scrubber/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return
	if(!welded || !(do_after(X, 2 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_HOSTILE)))
		return
	X.visible_message("[X] furiously claws at [src]!", "We manage to clear away the stuff blocking the scrubber.", "You hear loud scraping noises.")
	welded = FALSE
	update_icon()
	pipe_vision_img = image(src, loc, layer = ABOVE_HUD_LAYER, dir = dir)
	pipe_vision_img.plane = ABOVE_HUD_PLANE
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, 1)


/obj/machinery/atmospherics/components/unary/vent_scrubber/AltClick(mob/user)
	if(!isliving(user))
		return
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/xeno_user = user
		xeno_user.handle_ventcrawl(src, xeno_user.xeno_caste.vent_enter_speed, xeno_user.xeno_caste.silent_vent_crawl)
		return
	var/mob/living/living_user = user
	living_user.handle_ventcrawl(src)


/obj/machinery/atmospherics/components/unary/vent_scrubber/on
	on = TRUE
	icon_state = "scrub_map_on-2"

/obj/machinery/atmospherics/components/unary/vent_scrubber/on/Initialize(mapload)
	. = ..()
	GLOB.atmospumps += src

/obj/machinery/atmospherics/components/unary/vent_scrubber/on/Destroy()
	. = ..()
	GLOB.atmospumps -= src

#undef SIPHONING
#undef SCRUBBING
