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


/atom/movable/screen/fullscreen
	icon = 'icons/mob/screen/full/misc.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/severity = 0
	var/fs_view = WORLD_VIEW
	var/show_when_dead = FALSE
	///Holder for deletion timer
	var/removal_timer


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
	layer = FULLSCREEN_INTRO_LAYER

/atom/movable/screen/fullscreen/spawning_in
	icon_state = "blackimageoverlay" //mostly just a black square, you can change this if you get better ideas
	layer = FULLSCREEN_INTRO_LAYER

/atom/movable/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = FULLSCREEN_BLIND_LAYER

/atom/movable/screen/fullscreen/damage
	icon = 'icons/mob/screen/full/damage.dmi'

/atom/movable/screen/fullscreen/damage/brute
	icon_state = "brutedamageoverlay"
	layer = FULLSCREEN_DAMAGE_LAYER

/atom/movable/screen/fullscreen/damage/oxy
	icon_state = "oxydamageoverlay"
	layer = FULLSCREEN_DAMAGE_LAYER

/atom/movable/screen/fullscreen/impaired
	icon = 'icons/mob/screen/full/impaired.dmi'
	icon_state = "impairedoverlay"
	layer = FULLSCREEN_IMPAIRED_LAYER

/atom/movable/screen/fullscreen/impaired/crit
	icon_state = "critical"
	layer = FULLSCREEN_CRIT_LAYER

/atom/movable/screen/fullscreen/flash
	icon = 'icons/mob/screen/generic.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"
	layer = FULLSCREEN_FLASH_LAYER

/atom/movable/screen/fullscreen/flash/noise
	icon = 'icons/mob/screen/generic.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/atom/movable/screen/fullscreen/high
	icon = 'icons/mob/screen/generic.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"
	layer = FULLSCREEN_DRUGGY_LAYER

/atom/movable/screen/fullscreen/pain
	icon = 'icons/mob/screen/full/pain.dmi'
	icon_state = "painoverlay"
	layer = FULLSCREEN_PAIN_LAYER

/atom/movable/screen/fullscreen/particle_flash
	icon = 'icons/mob/screen/full/particle_flash.dmi'
	icon_state = "particle_flash"
	layer = FULLSCREEN_FLASH_LAYER

/atom/movable/screen/fullscreen/animated
	icon = 'icons/mob/screen/full/animated.dmi'

/atom/movable/screen/fullscreen/animated/bloodlust
	icon_state = "bloodlust"
	layer = FULLSCREEN_NERVES_LAYER

/atom/movable/screen/fullscreen/animated/infection
	icon_state = "curseoverlay"
	layer = FULLSCREEN_INFECTION_LAYER

/atom/movable/screen/fullscreen/machine
	icon = 'icons/mob/screen/full/machine.dmi'
	icon_state = "machine"
	alpha = 120
	layer = FULLSCREEN_DRUGGY_LAYER
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
	blend_mode = BLEND_OVERLAY
	show_when_dead = TRUE

/atom/movable/screen/fullscreen/lighting_backdrop/update_for_view(client_view)
	return

//Provides darkness to the back of the lighting plane
/atom/movable/screen/fullscreen/lighting_backdrop/lit_secondary
	invisibility = INVISIBILITY_LIGHTING
	layer = BACKGROUND_LAYER + LIGHTING_PRIMARY_DIMMER_LAYER
	color = "#000"
	alpha = 60

/atom/movable/screen/fullscreen/lighting_backdrop/backplane
	invisibility = INVISIBILITY_LIGHTING
	layer = LIGHTING_BACKPLANE_LAYER
	color = "#000"
	blend_mode = BLEND_ADD

/atom/movable/screen/fullscreen/see_through_darkness
	icon_state = "nightvision"
	plane = LIGHTING_PLANE
	layer = LIGHTING_PRIMARY_LAYER
	blend_mode = BLEND_ADD
	show_when_dead = TRUE

#undef SHOULD_SHOW_TO
