/turf/open/floor/noslip/tram
	name = "high-traction tram platform"
	icon = 'icons/turf/tram.dmi'
	icon_state = "noslip_tram"
	base_icon_state = "noslip_tram"

/turf/open/floor/tram
	name = "tram guideway"
	icon = 'icons/turf/tram.dmi'
	icon_state = "tram_platform"
	base_icon_state = "tram_platform"
	shoefootstep = FOOTSTEP_CATWALK
	barefootstep = FOOTSTEP_CATWALK
	mediumxenofootstep = FOOTSTEP_CATWALK
	heavyxenofootstep = FOOTSTEP_CATWALK

/turf/open/floor/tram/examine(mob/user)
	. += ..()
	. += span_notice("The reinforcement bolts are [EXAMINE_HINT("wrenched")] firmly in place. Use a [EXAMINE_HINT("wrench")] to remove the plate.")

/turf/open/floor/tram/make_plating(force = FALSE)
	if(force)
		return ..()
	return //unplateable

/turf/open/floor/tram/try_replace_tile(obj/item/stack/tile/replacement_tile, mob/user, params)
	return

/turf/open/floor/tram/crowbar_act(mob/living/user, obj/item/item)
	return

/turf/open/floor/tram/wrench_act(mob/living/user, obj/item/item)
	..()
	to_chat(user, span_notice("You begin removing the plate..."))
	if(item.use_tool(src, user, 30, volume=80))
		if(!istype(src, /turf/open/floor/tram))
			return TRUE
		if(floor_tile)
			new floor_tile(src, 2)
		ScrapeAway()
	return TRUE

/turf/open/floor/tram/ex_act(severity, target)
	return
/*
	if(target == src)
		ScrapeAway()
		return TRUE
	if(severity < EXPLODE_DEVASTATE && is_shielded())
		return FALSE

	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(prob(80))
				if(!ispath(baseturf_at_depth(2), /turf/open/floor))
					attempt_lattice_replacement()
				else
					ScrapeAway(2)
			else
				break_tile()
		if(EXPLODE_HEAVY)
			if(prob(30))
				if(!ispath(baseturf_at_depth(2), /turf/open/floor))
					attempt_lattice_replacement()
				else
					ScrapeAway(2)
			else
				break_tile()
		if(EXPLODE_LIGHT)
			if(prob(50))
				break_tile()

	return TRUE
*/
/turf/open/floor/tram/broken_states()
	return list("tram_platform-damaged1","tram_platform-damaged2")

/turf/open/floor/tram/tram_platform/burnt_states()
	return list("tram_platform-scorched1","tram_platform-scorched2")

/turf/open/floor/tram/plate
	name = "linear induction plate"
	desc = "The linear induction plate that powers the tram."
	icon = 'icons/turf/tram.dmi'
	icon_state = "tram_plate"
	base_icon_state = "tram_plate"
	atom_flags = NONE

/turf/open/floor/tram/plate/broken_states()
	return list("tram_plate-damaged1","tram_plate-damaged2")

/turf/open/floor/tram/plate/burnt_states()
	return list("tram_plate-scorched1","tram_plate-scorched2")

/turf/open/floor/tram/plate/energized
	desc = "The linear induction plate that powers the tram. It is currently energized."
	/// Inbound station
	var/inbound
	/// Outbound station
	var/outbound
	/// Transport ID of the tram
	var/specific_transport_id = TRAMSTATION_LINE_1

/turf/open/floor/tram/plate/energized/Initialize(mapload)
	. = ..()
//	AddComponent(/datum/component/energized, inbound, outbound, specific_transport_id)

/turf/open/floor/tram/plate/energized/examine(mob/user)
	. = ..()
	if(broken || burnt)
		. += span_danger("It looks damaged and the electrical components exposed!")
		. += span_notice("The plate can be repaired using a [EXAMINE_HINT("titanium sheet")].")

/turf/open/floor/tram/plate/energized/broken_states()
	return list("energized_plate_damaged")

/turf/open/floor/tram/plate/energized/burnt_states()
	return list("energized_plate_damaged")

/*
/turf/open/floor/tram/plate/energized/attackby(obj/item/attacking_item, mob/living/user, params)
	if((broken || burnt) && istype(attacking_item, /obj/item/stack/sheet/mineral/titanium))
		if(attacking_item.use(1))
			broken = FALSE
			update_appearance()
			balloon_alert(user, "plate replaced")
			return
	return ..()
*/
/turf/open/floor/tram/plate/energized/broken
	broken = TRUE

// Resetting the tram contents to its original state needs the turf to be there
/turf/open/indestructible/tram
	name = "tram guideway"
	icon = 'icons/turf/tram.dmi'
	icon_state = "tram_platform"
	base_icon_state = "tram_platform"
	shoefootstep = FOOTSTEP_CATWALK
	barefootstep = FOOTSTEP_CATWALK
	mediumxenofootstep = FOOTSTEP_CATWALK
	heavyxenofootstep = FOOTSTEP_CATWALK

/turf/open/indestructible/tram/plate
	name = "linear induction plate"
	desc = "The linear induction plate that powers the tram."
	icon_state = "tram_plate"
	base_icon_state = "tram_plate"
	atom_flags = NONE

/turf/open/floor/glass/reinforced/tram
	name = "tram bridge"
	desc = "It shakes a bit when you step, but lets you cross between sides quickly!"

/obj/structure/thermoplastic
	name = "tram floor"
	desc = "A lightweight thermoplastic flooring."
	icon = 'icons/turf/tram.dmi'
	icon_state = "tram_dark"
	base_icon_state = "tram_dark"
	density = FALSE
	anchored = TRUE
	max_integrity = 150
	integrity_failure = 0.75

	layer = TRAM_FLOOR_LAYER
	plane = GAME_PLANE
	obj_flags = BLOCK_Z_OUT_DOWN | BLOCK_Z_OUT_UP
	appearance_flags = PIXEL_SCALE|KEEP_TOGETHER
	var/secured = TRUE
	var/floor_tile = /obj/item/stack/sheet/metal
	var/mutable_appearance/damage_overlay

/datum/armor/tram_floor
	melee = 40
	bullet = 10
	laser = 10
	bomb = 45
	fire = 90
	acid = 100

/obj/structure/thermoplastic/light
	icon_state = "tram_light"
	base_icon_state = "tram_light"
	floor_tile =  /obj/item/stack/sheet/plasteel

/obj/structure/thermoplastic/examine(mob/user)
	. = ..()

	if(secured)
		. += span_notice("It is secured with a set of [EXAMINE_HINT("screws.")] To remove tile use a [EXAMINE_HINT("screwdriver.")]")
	else
		. += span_notice("You can [EXAMINE_HINT("crowbar")] to remove the tile.")
		. += span_notice("It can be re-secured using a [EXAMINE_HINT("screwdriver.")]")

/obj/structure/thermoplastic/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	. = ..()
	if(.) //received damage
		update_appearance()

/obj/structure/thermoplastic/update_icon_state()
	. = ..()
	var/ratio = obj_integrity / max_integrity
	ratio = CEILING(ratio * 4, 1) * 25
	if(ratio > 75)
		icon_state = base_icon_state
		return

	icon_state = "[base_icon_state]_damage[ratio]"
