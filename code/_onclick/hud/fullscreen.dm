#define SHOULD_SHOW_TO(mymob, myscreen) (!(mymob.stat == DEAD && !myscreen.show_when_dead))


/mob/proc/overlay_fullscreen_timer(duration, animated, category, type, severity)
	overlay_fullscreen(category, type, severity)
	addtimer(CALLBACK(src, PROC_REF(clear_fullscreen), category, animated), duration)


///Applies a fullscreen overlay
/mob/proc/overlay_fullscreen(category, type, severity)
	var/atom/movable/screen/fullscreen/screen = fullscreens[category]
	if(!screen || screen.type != type)
		// needs to be recreated
		clear_fullscreen(category, 0)
		fullscreens[category] = screen = new type()
	else
		animate(screen)
		deltimer(screen.removal_timer)
		screen.removal_timer = null
		screen.alpha = initial(screen.alpha)
		if((!severity || severity == screen.severity) && (!client || screen.screen_loc != "CENTER-7,CENTER-7" || screen.fs_view == client.view))
			return screen

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity
	if(client && SHOULD_SHOW_TO(src, screen))
		screen.update_for_view(client.view)
		client.screen += screen

	if(screen.needs_offsetting)
		SET_PLANE_EXPLICIT(screen, PLANE_TO_TRUE(screen.plane), src)

	return screen

///Removes a fullscreen overlay
/mob/proc/clear_fullscreen(category, animated = 1 SECONDS)
	var/atom/movable/screen/fullscreen/screen = fullscreens[category]
	if(!screen)
		return
	if(!animated)
		finish_clear_fullscreen(screen, category)
		return
	deltimer(screen.removal_timer)
	screen.removal_timer = null
	animate(screen, alpha = 0, time = animated)
	screen.removal_timer = addtimer(CALLBACK(src, PROC_REF(finish_clear_fullscreen), screen, category), animated, TIMER_CLIENT_TIME|TIMER_STOPPABLE)

///Actually removes the fullscreen overlay when ready
/mob/proc/finish_clear_fullscreen(atom/movable/screen/fullscreen/screen, category)
	if(client)
		client.screen -= screen
	fullscreens -= category
	qdel(screen)


/mob/proc/clear_fullscreens()
	for(var/category in fullscreens)
		clear_fullscreen(category)


/mob/proc/hide_fullscreens()
	if(client)
		for(var/category in fullscreens)
			client.screen -= fullscreens[category]


/mob/proc/reload_fullscreens()
	if(client)
		var/atom/movable/screen/fullscreen/screen
		for(var/category in fullscreens)
			screen = fullscreens[category]
			if(SHOULD_SHOW_TO(src, screen))
				screen.update_for_view(client.view)
				client.screen |= screen
			else
				client.screen -= screen

/mob/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(!same_z_layer)
		relayer_fullscreens()

/mob/proc/relayer_fullscreens()
	var/turf/our_lad = get_turf(src)
	var/offset = GET_TURF_PLANE_OFFSET(our_lad)
	for(var/category in fullscreens)
		var/atom/movable/screen/fullscreen/screen = fullscreens[category]
		if(screen.needs_offsetting)
			screen.plane = GET_NEW_PLANE(initial(screen.plane), offset)

INITIALIZE_IMMEDIATE(/atom/movable/screen/fullscreen)
/atom/movable/screen/fullscreen
	icon = 'icons/mob/screen/full/misc.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/severity = 0
	// todo tf is the point of this
	var/fs_view = WORLD_VIEW
	var/show_when_dead = FALSE
	///Holder for deletion timer
	var/removal_timer
	var/needs_offsetting = TRUE


/atom/movable/screen/fullscreen/Destroy()
	deltimer(removal_timer)
	removal_timer = null
	return ..()


/atom/movable/screen/fullscreen/proc/update_for_view(client_view)
	if (screen_loc == "CENTER-7,CENTER-7" && fs_view != client_view)
		var/list/actualview = getviewsize(client_view)
		fs_view = client_view
		transform = matrix(actualview[1]/FULLSCREEN_OVERLAY_RESOLUTION_X, 0, 0, 0, actualview[2]/FULLSCREEN_OVERLAY_RESOLUTION_Y, 0)

/atom/movable/screen/fullscreen/black
	icon_state = "black" //just a black square, you can change this if you get better ideas
	layer = INTRO_LAYER

/atom/movable/screen/fullscreen/spawning_in
	icon_state = "blackimageoverlay" //mostly just a black square, you can change this if you get better ideas
	layer = INTRO_LAYER

/atom/movable/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER

/atom/movable/screen/fullscreen/damage
	icon = 'icons/mob/screen/full/damage.dmi'
	layer = UI_DAMAGE_LAYER

/atom/movable/screen/fullscreen/damage/brute
	icon_state = "brutedamageoverlay"

/atom/movable/screen/fullscreen/damage/oxy
	icon_state = "oxydamageoverlay"

/atom/movable/screen/fullscreen/impaired
	icon = 'icons/mob/screen/full/impaired.dmi'
	icon_state = "impairedoverlay"
	layer = CRIT_LAYER

/atom/movable/screen/fullscreen/impaired/crit
	icon_state = "critical"

/atom/movable/screen/fullscreen/flash
	icon = 'icons/mob/screen/generic.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"
	layer = FLASH_LAYER

/atom/movable/screen/fullscreen/flash/noise
	icon = 'icons/mob/screen/generic.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/atom/movable/screen/fullscreen/high
	icon_state = "druggy"
	alpha = 255
	plane = LIGHTING_PLANE
	layer = LIGHTING_ABOVE_ALL + 1
	blend_mode = BLEND_MULTIPLY

/atom/movable/screen/fullscreen/high/update_for_view(client_view)

	animate(src, flags = ANIMATION_END_NOW) //Stop all animations.

	. = ..()

	color = COLOR_MATRIX_IDENTITY //We convert it early to avoid a sudden weird jitter.
	alpha = 0

	animate(src, alpha = 255, time = 5 SECONDS) //Fade in.

	addtimer(CALLBACK(src, PROC_REF(start_hue_rotation)), 5 SECONDS)

/atom/movable/screen/fullscreen/high/proc/start_hue_rotation()
	animate(src, color = color_matrix_rotate_hue(1), loop = -1, time = 2 SECONDS) //Start the loop.
	var/step_precision = 18 //Larger is more precise rotations.
	for(var/current_step in 1 to step_precision - 1) //We do the -1 here because 360 == 0 when it comes to angles.
		animate(
			color = color_matrix_rotate_hue(current_step * 360/step_precision),
			time = 2 SECONDS,
		)


/atom/movable/screen/fullscreen/pain
	icon = 'icons/mob/screen/full/pain.dmi'
	icon_state = "painoverlay"
	layer = PAIN_LAYER

/atom/movable/screen/fullscreen/particle_flash
	icon = 'icons/mob/screen/full/particle_flash.dmi'
	icon_state = "particle_flash"
	layer = FLASH_LAYER

/atom/movable/screen/fullscreen/animated
	icon = 'icons/mob/screen/full/animated.dmi'

/atom/movable/screen/fullscreen/animated/bloodlust
	icon_state = "bloodlust"
	layer = CURSE_LAYER

/atom/movable/screen/fullscreen/animated/infection
	icon_state = "curseoverlay"
	layer = CURSE_LAYER

/atom/movable/screen/fullscreen/machine
	icon = 'icons/mob/screen/full/machine.dmi'
	icon_state = "machine"
	alpha = 120
	layer = FULLSCREEN_LAYER
	blend_mode = BLEND_MULTIPLY

/atom/movable/screen/fullscreen/machine/update_for_view(client_view)
	. = ..()
	animate(src, alpha = initial(alpha)-30, time = 50, loop = -1)
	animate(alpha = initial(alpha), time = 20, loop = -1)

/atom/movable/screen/fullscreen/machine/robothalf
	icon_state = "robothalf"
	alpha = 60

/atom/movable/screen/fullscreen/machine/robotlow
	icon_state = "robotlow"

/atom/movable/screen/fullscreen/ivanov_display
	icon_state = "ivanov"
	alpha = 180

/atom/movable/screen/fullscreen/lighting_backdrop
	icon = 'icons/mob/screen/generic.dmi'
	icon_state = "flash"
	transform = matrix(200, 0, 0, 0, 200, 0)
	plane = LIGHTING_PLANE
	layer = LIGHTING_ABOVE_ALL
	blend_mode = BLEND_OVERLAY
	show_when_dead = TRUE
	needs_offsetting = FALSE

//Provides darkness to the back of the lighting plane
/atom/movable/screen/fullscreen/lighting_backdrop/lit_secondary
	invisibility = INVISIBILITY_LIGHTING
	layer = BACKGROUND_LAYER+21
	color = "#000"

/atom/movable/screen/fullscreen/lighting_backdrop/backplane
	layer = BACKGROUND_LAYER+20

/atom/movable/screen/fullscreen/see_through_darkness
	icon_state = "nightvision"
	plane = LIGHTING_PLANE
	layer = LIGHTING_ABOVE_ALL
	blend_mode = BLEND_ADD
	show_when_dead = TRUE

#undef SHOULD_SHOW_TO
