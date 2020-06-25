#define SHOULD_SHOW_TO(mymob, myscreen) (!(mymob.stat == DEAD && !myscreen.show_when_dead))


/mob/proc/overlay_fullscreen_timer(duration, animated, category, type, severity)
	overlay_fullscreen(category, type, severity)
	addtimer(CALLBACK(src, .proc/clear_fullscreen, category, animated), duration)


/mob/proc/overlay_fullscreen(category, type, severity)
	var/obj/screen/fullscreen/screen = fullscreens[category]
	if (!screen || screen.type != type)
		// needs to be recreated
		clear_fullscreen(category, FALSE)
		fullscreens[category] = screen = new type()
	else if ((!severity || severity == screen.severity) && (!client || screen.screen_loc != "CENTER-7,CENTER-7" || screen.fs_view == client.view))
		// doesn't need to be updated
		return screen

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity
	if (client && SHOULD_SHOW_TO(src, screen))
		screen.update_for_view(client.view)
		client.screen += screen

	return screen


/mob/proc/clear_fullscreen(category, animated = 10)
	var/obj/screen/fullscreen/screen = fullscreens[category]
	if(!screen)
		return

	fullscreens -= category

	if(animated)
		animate(screen, alpha = 0, time = animated)
		addtimer(CALLBACK(src, .proc/clear_fullscreen_after_animate, screen), animated, TIMER_CLIENT_TIME)
	else
		if(client)
			client.screen -= screen
		qdel(screen)


/mob/proc/clear_fullscreen_after_animate(obj/screen/fullscreen/screen)
	if(client)
		client.screen -= screen
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
		var/obj/screen/fullscreen/screen
		for(var/category in fullscreens)
			screen = fullscreens[category]
			if(SHOULD_SHOW_TO(src, screen))
				screen.update_for_view(client.view)
				client.screen |= screen
			else
				client.screen -= screen


/obj/screen/fullscreen
	icon = 'icons/mob/screen/full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	mouse_opacity = 0
	var/severity = 0
	var/fs_view = WORLD_VIEW
	var/show_when_dead = FALSE


/obj/screen/fullscreen/Destroy()
	severity = 0
	return ..()


/obj/screen/fullscreen/proc/update_for_view(client_view)
	if (screen_loc == "CENTER-7,CENTER-7" && fs_view != client_view)
		var/list/actualview = getviewsize(client_view)
		fs_view = client_view
		transform = matrix(actualview[1]/FULLSCREEN_OVERLAY_RESOLUTION_X, 0, 0, 0, actualview[2]/FULLSCREEN_OVERLAY_RESOLUTION_Y, 0)


/obj/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = FULLSCREEN_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = FULLSCREEN_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/crit
	icon_state = "passage"
	layer = FULLSCREEN_CRIT_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = FULLSCREEN_BLIND_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/impaired
	icon_state = "impairedoverlay"
	layer = FULLSCREEN_IMPAIRED_LAYER

/obj/screen/fullscreen/flash
	icon = 'icons/mob/screen/generic.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"
	layer = FULLSCREEN_FLASH_LAYER

/obj/screen/fullscreen/flash/noise
	icon = 'icons/mob/screen/generic.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/obj/screen/fullscreen/high
	icon = 'icons/mob/screen/generic.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"
	layer = FULLSCREEN_DRUGGY_LAYER


/obj/screen/fullscreen/pain
	icon_state = "painoverlay"
	layer = FULLSCREEN_PAIN_LAYER


/obj/screen/fullscreen/lighting_backdrop
	icon = 'icons/mob/screen/generic.dmi'
	icon_state = "flash"
	transform = matrix(200, 0, 0, 0, 200, 0)
	plane = LIGHTING_PLANE
	blend_mode = BLEND_OVERLAY
	show_when_dead = TRUE


//Provides darkness to the back of the lighting plane
/obj/screen/fullscreen/lighting_backdrop/lit
	invisibility = INVISIBILITY_LIGHTING
	layer = BACKGROUND_LAYER + 21
	color = "#000"
	show_when_dead = TRUE


//Provides whiteness in case you don't see lights so everything is still visible
/obj/screen/fullscreen/lighting_backdrop/unlit
	layer = BACKGROUND_LAYER + 20
	show_when_dead = TRUE


/obj/screen/fullscreen/see_through_darkness
	icon_state = "nightvision"
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER
	blend_mode = BLEND_ADD
	show_when_dead = TRUE

//Helmet effects for spacesuits

/obj/screen/fullscreen/helmet
	icon_state = "helmet"
	plane = FULLSCREEN_PLANE
	show_when_dead = TRUE

#undef SHOULD_SHOW_TO
