/obj/effect/temp_visual/telekinesis
	name = "telekinetic force"
	icon_state = "empdisable"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/explosion
	name = "explosion"
	icon = 'icons/effects/explosion.dmi'
	icon_state = "grenade"
	duration = 0.8 SECONDS
	pixel_x = -16

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


/obj/effect/temp_visual/xenomorph/afterimage
	name = "afterimage"
	layer = MOB_LAYER
	alpha = 64 //Translucent
	duration = 0.5 SECONDS
	density = FALSE
	opacity = FALSE
	anchored = FALSE
	animate_movement = SLIDE_STEPS

/obj/effect/temp_visual/xenomorph/afterimage/Initialize(mapload, atom/owner)
	. = ..()
	appearance = owner.appearance
	setDir(owner.dir)
	alpha = initial(alpha)
	layer = initial(layer)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/heavyimpact
	name = "heavy impact"
	icon = 'icons/effects/heavyimpact.dmi'
	icon_state = "heavyimpact"
	duration = 13

/obj/effect/temp_visual/order
	icon = 'icons/Marine/marine-items.dmi'
	var/icon_state_on
	hud_possible = list(SQUAD_HUD_TERRAGOV, SQUAD_HUD_REBEL, SQUAD_HUD_SOM)
	duration = ORDER_DURATION
	layer = TURF_LAYER

/obj/effect/temp_visual/order/Initialize(mapload, faction)
	. = ..()
	prepare_huds()
	var/marker_flags
	var/hud_type
	if(faction == FACTION_TERRAGOV)
		hud_type = DATA_HUD_SQUAD_TERRAGOV
	else if(faction == FACTION_TERRAGOV_REBEL)
		hud_type = DATA_HUD_SQUAD_REBEL
	else if(faction == FACTION_SOM)
		hud_type = DATA_HUD_SQUAD_SOM
	else if(faction == FACTION_IMP)
		marker_flags = DATA_HUD_SQUAD_IMP
	else
		return
	if(hud_type == DATA_HUD_SQUAD_TERRAGOV)
		marker_flags = MINIMAP_FLAG_MARINE
	else if(hud_type == DATA_HUD_SQUAD_REBEL)
		marker_flags = MINIMAP_FLAG_MARINE_REBEL
	else if(hud_type == DATA_HUD_SQUAD_SOM)
		marker_flags = MINIMAP_FLAG_MARINE_SOM
	else if(hud_type == DATA_HUD_SQUAD_IMP)
		marker_flags = MINIMAP_FLAG_MARINE_IMP
	else
		return
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[hud_type]
	squad_hud.add_to_hud(src)
	SSminimaps.add_marker(src, src.z, marker_flags, icon_state_on, 'icons/UI_icons/map_blips_large.dmi')
	set_visuals(faction)

/obj/effect/temp_visual/order/attack_order
	name = "attack order"
	icon_state_on = "attack"

/obj/effect/temp_visual/order/defend_order
	name = "defend order"
	icon_state_on = "defend"

/obj/effect/temp_visual/order/retreat_order
	name = "retreat order"
	icon_state_on = "retreat"

/obj/effect/temp_visual/order/rally_order
	name = "rally order"
	icon_state_on = "rally"
	duration = RALLY_ORDER_DURATION

///Set visuals for the hud
/obj/effect/temp_visual/order/proc/set_visuals(faction)
	var/hud_type
	if(faction == FACTION_TERRAGOV)
		hud_type = SQUAD_HUD_TERRAGOV
	else if(faction == FACTION_TERRAGOV_REBEL)
		hud_type = SQUAD_HUD_REBEL
	else if(faction == FACTION_SOM)
		hud_type = SQUAD_HUD_SOM
	else
		return
	var/image/holder = hud_list[hud_type]
	if(!holder)
		return
	holder.icon = 'icons/Marine/marine-items.dmi'
	holder.icon_state = icon_state_on
	hud_list[hud_type] = holder

/obj/effect/temp_visual/healing
	name = "healing"
	icon = 'icons/effects/progressicons.dmi'
	icon_state = "busy_medical"
	duration = 0.8 SECONDS


/obj/effect/temp_visual/alien_fruit_eaten
	name = "glitters"
	icon_state = "shieldsparkles"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/smoke
	name = "smoke"
	icon = 'icons/obj/items/jetpack.dmi'
	icon_state = "smoke"
	duration = 1.2 SECONDS

/obj/effect/temp_visual/blink_portal
	name = "blink portal"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	layer = ABOVE_LYING_MOB_LAYER
	duration = 0.5 SECONDS

/obj/effect/temp_visual/banishment_portal
	name = "banishment portal"
	icon = 'icons/obj/objects.dmi'
	icon_state = "bhole3"
	layer = ABOVE_LYING_MOB_LAYER
	duration = WRAITH_BANISH_BASE_DURATION+1 //So we don't delete our contents early

/obj/effect/temp_visual/acid_splatter
	name = "acid_splatter"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "splatter"
	duration = 0.8 SECONDS

/obj/effect/temp_visual/acid_bath
	name = "acid bath"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "boiler_gas"
	duration = 0.8 SECONDS

/obj/effect/temp_visual/wraith_warp
	icon = 'icons/effects/light_overlays/light_128.dmi'
	icon_state = "light"
	plane = GRAVITY_PULSE_PLANE
	pixel_x = -48
	pixel_y = -48
	duration = 8

/obj/effect/temp_visual/wraith_warp/Initialize()
	. = ..()
	animate(src, time=duration, transform=matrix().Scale(0.1,0.1))

/obj/effect/temp_visual/shockwave
	icon = 'icons/effects/light_overlays/shockwave.dmi'
	icon_state = "shockwave"
	plane = GRAVITY_PULSE_PLANE
	pixel_x = -496
	pixel_y = -496

/obj/effect/temp_visual/shockwave/Initialize(mapload, radius)
	. = ..()
	deltimer(timerid)
	timerid = QDEL_IN(src, 0.5 * radius)
	transform = matrix().Scale(32 / 1024, 32 / 1024)
	animate(src, time = 1/2 * radius, transform=matrix().Scale((32 / 1024) * radius * 1.5, (32 / 1024) * radius * 1.5))
