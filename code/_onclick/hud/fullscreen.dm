
#define FULLSCREEN_LAYER 18
#define DAMAGE_LAYER FULLSCREEN_LAYER + 0.1
#define BLIND_LAYER DAMAGE_LAYER + 0.1
#define CRIT_LAYER BLIND_LAYER + 0.1

/mob
	var/list/fullscreens = list()

/mob/proc/overlay_fullscreen(category, type, severity)
	var/obj/screen/fullscreen/FS
	if(fullscreens[category])
		FS = fullscreens[category]
		if(FS.type != type)
			clear_fullscreen(category, FALSE)
			return .()
		else if(!severity || severity == FS.severity)
			return null
	else
		FS = rnew(type)

	FS.icon_state = "[initial(FS.icon_state)][severity]"
	FS.severity = severity

	fullscreens[category] = FS
	if(client)
		client.screen += FS
	return FS

/mob/proc/clear_fullscreen(category, animated = 10)
	set waitfor = 0
	var/obj/screen/fullscreen/FS = fullscreens[category]
	if(!FS)
		return

	fullscreens -= category

	if(animated)
		spawn(0)
			animate(FS, alpha = 0, time = animated)
			sleep(animated)
			if(client)
				client.screen -= FS
			cdel(FS)
	else
		if(client)
			client.screen -= FS
		cdel(FS)


/mob/proc/clear_fullscreens()
	for(var/category in fullscreens)
		clear_fullscreen(category)


/mob/proc/hide_fullscreens()
	if(client)
		for(var/category in fullscreens)
			client.screen -= fullscreens[category]

/mob/proc/reload_fullscreens()
	if(client && stat != DEAD) //dead mob do not see any of the fullscreen overlays that he has.
		for(var/category in fullscreens)
			client.screen |= fullscreens[category]



/obj/screen/fullscreen
	icon = 'icons/mob/screen1_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	mouse_opacity = 0
	var/severity = 0

/obj/screen/fullscreen/Dispose()
	..()
	severity = 0
	return TA_REVIVE_ME


/obj/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = FULLSCREEN_DAMAGE_LAYER

/obj/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = FULLSCREEN_DAMAGE_LAYER

/obj/screen/fullscreen/crit
	icon_state = "passage"
	layer = FULLSCREEN_CRIT_LAYER

/obj/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = FULLSCREEN_BLIND_LAYER

/obj/screen/fullscreen/impaired
	icon_state = "impairedoverlay"

/obj/screen/fullscreen/blurry
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blurry"

/obj/screen/fullscreen/flash
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"
	layer = FULLSCREEN_FLASH_LAYER

/obj/screen/fullscreen/flash/noise
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/obj/screen/fullscreen/high
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"

/obj/screen/fullscreen/nvg
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "nvg_hud"

/obj/screen/fullscreen/thermal
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "thermal_hud"

/obj/screen/fullscreen/meson
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "meson_hud"


/obj/screen/fullscreen/pain
	icon_state = "painoverlay"
	layer = FULLSCREEN_PAIN_LAYER




#undef FULLSCREEN_LAYER
#undef BLIND_LAYER
#undef DAMAGE_LAYER
#undef CRIT_LAYER
