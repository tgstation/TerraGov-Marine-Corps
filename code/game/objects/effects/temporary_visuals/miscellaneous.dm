/obj/effect/temp_visual/telekinesis
	name = "telekinetic force"
	icon_state = "empdisable"
	duration = 0.5 SECONDS

/// Used for globadiers heal grenades
/obj/effect/temp_visual/heal
	name = "healing splatter"
	icon_state = "mech_toxin"

/particles/splatter
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke5"
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.5 SECONDS
	fade = 0.2 SECONDS
	drift = generator(GEN_CIRCLE, 3, 3)
	scale = 0.25
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.3, 0.6)
	position = generator(GEN_CIRCLE, 4, 4)

//unsorted miscellaneous temporary visuals
/obj/effect/temp_visual/dir_setting/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	duration = 0.5 SECONDS
	randomdir = FALSE
	layer = ABOVE_ALL_MOB_LAYER
	alpha = 200
	var/splatter_type = "splatter"

/obj/effect/temp_visual/dir_setting/bloodsplatter/Initialize(mapload, angle, blood_color)
	if(!blood_color)
		CRASH("Tried to create a blood splatter without a blood_color")
	var/x_component = sin(angle) * -20
	var/y_component = cos(angle) * -20
	var/obj/effect/abstract/particle_holder/reset_transform/splatter_visuals
	splatter_visuals = new(src, /particles/splatter)
	splatter_visuals.particles.velocity = list(x_component, y_component)
	splatter_visuals.particles.color = blood_color
	color = blood_color
	icon_state = "[splatter_type][pick(1, 2, 3, 4, 5, 6)]"
	. = ..()
	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(angle)
		if(0, 360)
			target_pixel_x = 0
			target_pixel_y = -8
		if(1 to 44)
			target_pixel_x = round(-4 * ((angle) / 45))
			target_pixel_y = -8
		if(45)
			target_pixel_x = -8
			target_pixel_y = -8
		if(46 to 89)
			target_pixel_x = -8
			target_pixel_y = round(-4 * ((90 - angle) / 45))
		if(90)
			target_pixel_x = -8
			target_pixel_y = 0
		if(91 to 134)
			target_pixel_x = -8
			target_pixel_y = round(3 * ((angle - 90) / 45))
		if(135)
			target_pixel_x = -8
			target_pixel_y = 6
		if(136 to 179)
			target_pixel_x = round(-4 * ((180 - angle) / 45))
			target_pixel_y = 6
		if(180)
			target_pixel_x = 0
			target_pixel_y = 6
		if(181 to 224)
			target_pixel_x = round(6 * ((angle - 180) / 45))
			target_pixel_y = 6
		if(225)
			target_pixel_x = 6
			target_pixel_y = 6
		if(226 to 269)
			target_pixel_x = 6
			target_pixel_y = round(6 * ((270 - angle) / 45))
		if(270)
			target_pixel_x = 6
			target_pixel_y = 0
		if(271 to 314)
			target_pixel_x = 6
			target_pixel_y = round(-8 * ((angle - 270) / 45))
		if(315)
			target_pixel_x = 6
			target_pixel_y = -8
		if(316 to 359)
			target_pixel_x = round(6 * ((360 - angle) / 45))
			target_pixel_y = -8
	transform = matrix().Turn(angle)
	animate(src, pixel_x = target_pixel_x, pixel_y = target_pixel_y, time = 0.25 SECONDS)
	animate(src, alpha = 0, time = duration)

/obj/effect/temp_visual/transfer_plasma
	name = "transfer plasma"
	icon_state = "transfer_plasma"
	duration = 0.5 SECONDS


/obj/effect/temp_visual/after_image
	name = "afterimage"
	layer = BELOW_MOB_LAYER
	alpha = 64 //Translucent
	density = FALSE
	opacity = FALSE
	anchored = FALSE
	animate_movement = SLIDE_STEPS
	randomdir = FALSE
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/after_image/Initialize(mapload, atom/owner, _duration = 0.5 SECONDS)
	. = ..()
	var/mutable_appearance/after_image = new()
	after_image.appearance = owner.appearance
	after_image.render_target = null
	after_image.density = initial(density)
	after_image.alpha = initial(alpha)
	after_image.appearance_flags = RESET_COLOR|RESET_ALPHA|PASS_MOUSE
	after_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	after_image.layer = BELOW_MOB_LAYER
	after_image.setDir(owner.dir)
	after_image.pixel_x = owner.pixel_x
	after_image.pixel_y = owner.pixel_y
	appearance = after_image
	duration = _duration
	animate(src, alpha = 0, time = duration)

/obj/effect/temp_visual/ob_impact
	name = "ob impact animation"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 0.7 SECONDS
	density = FALSE
	opacity = FALSE

/obj/effect/temp_visual/ob_impact/Initialize(mapload, atom/owner)
	. = ..()
	appearance = owner.appearance
	transform = matrix().Turn(-90)
	layer = initial(layer)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 600
	animate(src, pixel_y = -5, time=5)
	animate(icon_state=null, icon=null, time=2) // to vanish it immediately

/obj/effect/temp_visual/heavyimpact
	name = "heavy impact"
	icon = 'icons/effects/heavyimpact.dmi'
	icon_state = ""
	duration = 13

/obj/effect/temp_visual/heavyimpact/Initialize(mapload)
	. = ..()
	flick("heavyimpact", src)

/obj/effect/temp_visual/order
	icon = 'icons/effects/orders.dmi'
	var/icon_state_on
	hud_possible = list(SQUAD_HUD_TERRAGOV, SQUAD_HUD_SOM)
	duration = CIC_ORDER_DURATION

/obj/effect/temp_visual/order/Initialize(mapload, faction)
	. = ..()
	prepare_huds()

	var/datum/atom_hud/squad_hud = GLOB.huds[GLOB.faction_to_data_hud[faction]]
	if(squad_hud)
		squad_hud.add_to_hud(src)

	var/marker_flags = GLOB.faction_to_minimap_flag[faction]
	if(marker_flags)
		SSminimaps.add_marker(src, marker_flags, image('icons/UI_icons/map_blips_large.dmi', null, icon_state_on, MINIMAP_BLIPS_LAYER))
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
	duration = CIC_ORDER_DURATION

///Set visuals for the hud
/obj/effect/temp_visual/order/proc/set_visuals(faction)
	var/hud_type = GLOB.faction_to_squad_hud[faction]
	if(!hud_type)
		return
	var/image/holder = hud_list[hud_type]
	if(!holder)
		return
	holder.icon = 'icons/effects/orders.dmi'
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

/obj/effect/temp_visual/acid_splatter
	name = "acid_splatter"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "splatter"
	duration = 0.8 SECONDS

/obj/effect/temp_visual/xadar_blast
	name = "acid cascade"
	icon = 'icons/Xeno/96x96.dmi'
	icon_state = "xadar_splash"
	duration = 0.4 SECONDS

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

/obj/effect/temp_visual/wraith_warp/Initialize(mapload)
	. = ..()
	animate(src, time=duration, transform=matrix().Scale(0.1,0.1))

/obj/effect/temp_visual/blink_drive
	icon = 'icons/effects/light_overlays/light_128.dmi'
	icon_state = "light"
	plane = GRAVITY_PULSE_PLANE
	duration = 8

/obj/effect/temp_visual/blink_drive/Initialize(mapload)
	. = ..()
	var/image/I = image(icon, src, icon_state, 10, pixel_x = -48, pixel_y = -48)
	overlays += I //we use an overlay so the icon and light source are both in the correct location
	icon_state = null
	animate(src, time=duration, transform=matrix().Scale(0.1,0.1))
	set_light(2, 2, LIGHT_COLOR_DARK_BLUE)

/obj/effect/temp_visual/teleporter_array
	icon = 'icons/effects/light_overlays/light_320.dmi'
	icon_state = "light"
	plane = GRAVITY_PULSE_PLANE
	duration = 15

/obj/effect/temp_visual/teleporter_array/Initialize(mapload)
	. = ..()
	var/image/I = image(icon, src, icon_state, 10, pixel_x = -144, pixel_y = -144)
	overlays += I //we use an overlay so the icon and light source are both in the correct location
	icon_state = null
	animate(src, time=duration, transform=matrix().Scale(0.1,0.1))
	set_light(9, 9, LIGHT_COLOR_DARK_BLUE)


/**
 * Visual shockwave effect using a displacement filter applied to the game world plate
 * Args:
 * * radius: visual max radius of the effect
 * * speed_rate: propagation rate of the effect as a ratio (0.5 is twice as fast)
 * * easing_type: easing type to use in the anim
 * * y_offset: additional pixel_y offsets
 * * x_offset: additional pixel_x offsets
 */
/obj/effect/temp_visual/shockwave
	icon = 'icons/effects/light_overlays/shockwave.dmi'
	icon_state = "shockwave"
	plane = GRAVITY_PULSE_PLANE
	pixel_x = -496
	pixel_y = -496

/obj/effect/temp_visual/shockwave/Initialize(mapload, radius, direction, speed_rate=1, easing_type = LINEAR_EASING, y_offset=0, x_offset=0)
	. = ..()
	pixel_x += x_offset
	pixel_y += y_offset
	deltimer(timerid)
	timerid = QDEL_IN_STOPPABLE(src, 0.5 * radius * speed_rate)
	transform = matrix().Scale(32 / 1024, 32 / 1024)
	animate(src, time = 1/2 * radius * speed_rate, transform=matrix().Scale((32 / 1024) * radius * 1.5, (32 / 1024) * radius * 1.5), easing=easing_type)

/obj/effect/temp_visual/dir_setting/water_splash
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	duration = 0.5 SECONDS

/// looping lightning effect useful for showing chargeup of [/obj/effect/temp_visual/lightning_discharge]
/obj/effect/overlay/lightning_charge
	icon = 'icons/effects/96x96.dmi'
	icon_state = "lightning_charge"
	layer = ABOVE_TREE_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_ID
	color = COLOR_RED_LIGHT
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/lightning_discharge
	icon = 'icons/effects/96x96.dmi'
	icon_state = "lightning_discharge"
	layer = ABOVE_TREE_LAYER
	color = COLOR_RED_LIGHT
	duration = 3
	pixel_x = -32
	pixel_y = -32
