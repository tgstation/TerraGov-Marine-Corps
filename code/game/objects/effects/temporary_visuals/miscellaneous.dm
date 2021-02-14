/obj/effect/temp_visual/telekinesis
	name = "telekinetic force"
	icon_state = "empdisable"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/explosion
	name = "explosion"
	icon = 'icons/effects/explosion.dmi'
	icon_state = "grenade"
	duration = 0.8 SECONDS

//unsorted miscellaneous temporary visuals
/obj/effect/temp_visual/dir_setting/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	duration = 0.5 SECONDS
	randomdir = FALSE
	layer = BELOW_MOB_LAYER
	var/splatter_type = "splatter"

/obj/effect/temp_visual/dir_setting/bloodsplatter/Initialize(mapload, set_dir, blood_color)
	if(!blood_color)
		CRASH("Tried to create a blood splatter without a blood_color")

	color = blood_color
	if(ISDIAGONALDIR(set_dir))
		icon_state = "[splatter_type][pick(1, 2, 6)]"
	else
		icon_state = "[splatter_type][pick(3, 4, 5)]"
	. = ..()
	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(set_dir)
		if(NORTH)
			target_pixel_y = 16
		if(SOUTH)
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(EAST)
			target_pixel_x = 16
		if(WEST)
			target_pixel_x = -16
		if(NORTHEAST)
			target_pixel_x = 16
			target_pixel_y = 16
		if(NORTHWEST)
			target_pixel_x = -16
			target_pixel_y = 16
		if(SOUTHEAST)
			target_pixel_x = 16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(SOUTHWEST)
			target_pixel_x = -16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
	animate(src, pixel_x = target_pixel_x, pixel_y = target_pixel_y, alpha = 0, time = duration)

/obj/effect/temp_visual/transfer_plasma
	name = "transfer plasma"
	icon_state = "transfer_plasma"
	duration = 0.5 SECONDS


/obj/effect/temp_visual/xenomorph/runner_afterimage
	name = "runner afterimage"
	desc = "It has become speed.."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	layer = MOB_LAYER
	alpha = 64 //Translucent
	duration = 0.5 SECONDS
	density = FALSE
	opacity = FALSE
	anchored = FALSE
	animate_movement = SLIDE_STEPS

/obj/effect/temp_visual/xenomorph/roony_afterimage
	name = "roony afterimage"
	desc = "It has become speed.."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x1 or something
	icon_state = "Roony Walking"
	layer = MOB_LAYER
	alpha = 64 //Translucent
	duration = 0.5 SECONDS
	density = FALSE
	opacity = FALSE
	anchored = FALSE
	animate_movement = SLIDE_STEPS

/obj/effect/temp_visual/heavyimpact
	name = "heavy impact"
	icon = 'icons/effects/heavyimpact.dmi'
	icon_state = "heavyimpact"
	duration = 13

/obj/effect/temp_visual/order
	icon = 'icons/Marine/marine-items.dmi'
	var/icon_state_on
	hud_possible = list(SQUAD_HUD)
	duration = ORDER_DURATION
	layer = TURF_LAYER

/obj/effect/temp_visual/order/Initialize(mapload)
	. = ..()
	prepare_huds()
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD]
	squad_hud.add_to_hud(src)
	set_visuals()

/obj/effect/temp_visual/order/attack_order
	name = "attack order"
	icon_state_on = "attack"

/obj/effect/temp_visual/order/defend_order
	name = "defend order"
	icon_state_on = "defend"

/obj/effect/temp_visual/order/retreat_order
	name = "retreat order"
	icon_state_on = "retreat"

///Set visuals for the hud
/obj/effect/temp_visual/order/proc/set_visuals()
	var/image/holder = hud_list[SQUAD_HUD]
	if(!holder)
		return
	holder.icon = 'icons/Marine/marine-items.dmi'
	holder.icon_state = icon_state_on
	hud_list[SQUAD_HUD] = holder

/obj/effect/temp_visual/healing
	name = "healing"
	icon = 'icons/effects/progressicons.dmi'
	icon_state = "busy_medical"
	duration = 0.8 SECONDS
