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

	var/id_tag = null
	var/scrubbing = SCRUBBING //0 = siphoning, 1 = scrubbing

	var/filter_types = list()///datum/gas/carbon_dioxide)
	var/volume_rate = 200
	var/widenet = 0 //is this scrubber acting on the 3x3 area around it.
	var/list/turf/adjacent_turfs = list()

	pipe_state = "scrubber"

/obj/machinery/atmospherics/components/unary/vent_scrubber/New()
	. = ..()
	if(!id_tag)
		id_tag = assign_uid_vents()


/obj/machinery/atmospherics/components/unary/vent_scrubber/auto_use_power()
	if(!on || welded || !is_operational() || !powered(power_channel))
		return FALSE

	var/amount = idle_power_usage

	if(scrubbing & SCRUBBING)
		amount += idle_power_usage * length(filter_types)
	else //scrubbing == SIPHONING
		amount = active_power_usage

	if(widenet)
		amount += amount * (adjacent_turfs.len * (adjacent_turfs.len / 2))
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

/obj/machinery/atmospherics/components/unary/vent_scrubber/welder_act(mob/living/user, obj/item/W)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn())
			user.visible_message("<span class='notice'>[user] starts welding [src] with [WT].</span>", \
			"<span class='notice'>You start welding [src] with [WT].</span>")
			playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
			if(do_after(user, 50, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)) && WT.remove_fuel(1, user))
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

/obj/machinery/atmospherics/components/unary/vent_scrubber/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE

/obj/machinery/atmospherics/components/unary/vent_scrubber/examine(mob/user)
	..()
	if(welded)
		to_chat(user, "It seems welded shut.")

/obj/machinery/atmospherics/components/unary/vent_scrubber/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/components/unary/vent_scrubber/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return
	if(!welded || !(do_after(X, 2 SECONDS, FALSE, src, BUSY_ICON_HOSTILE)))
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
	var/mob/living/living_user = user
	living_user.handle_ventcrawl(src)


/obj/machinery/atmospherics/components/unary/vent_scrubber/on
	on = TRUE
	icon_state = "scrub_map_on-2"

#undef SIPHONING
#undef SCRUBBING
