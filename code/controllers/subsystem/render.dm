///The minimum amount of identical appearances we need to allow caching of an appearance for reuse
#define MINIMUM_RENDER_AMOUNT 40

/**
  * Rendering SS
  *
  * add flags_atom = SMART_RENDERING to an atom to register with the rendering ss on initialize
  * do not add for items with an overlay
  */
SUBSYSTEM_DEF(render)
	name = "Render"
	init_order = INIT_ORDER_RENDER
	flags = SS_NO_FIRE
	var/atom/movable/render_target/render_target = new()

/datum/controller/subsystem/render/Recover()
	render_target = SSrender.render_target

/datum/controller/subsystem/render/Initialize(start_timeofday)
	//Clean the cache of rarely used images, it can happen that theres a lot but its unused
	for(var/i in GLOB.cached_images)
		if(length(GLOB.cached_images[i]) >= MINIMUM_RENDER_AMOUNT)
			continue
		for(var/atom/o as() in GLOB.cached_images[i])
			SEND_SIGNAL(o, COMSIG_ATOM_RENDER_CACHE_EMPTIED)
		GLOB.cached_images -= i
		qdel(i)

	//Now that we've cleaned the cache lets send the images
	for(var/user in GLOB.clients)
		for(var/cachedimage in GLOB.cached_images)
			user << cachedimage
	return ..()

////debug
/datum/controller/subsystem/render/proc/clear()
	to_chat(world, "<span class='warning'>Clearing cache in 5 seconds.</span>")
	sleep(5 SECONDS)
	for(var/i in GLOB.cached_images)
		for(var/atom/b as() in GLOB.cached_images[i])
			SEND_SIGNAL(b, COMSIG_ATOM_RENDER_CACHE_EMPTIED)
		GLOB.cached_images -= i
		qdel(i)
	to_chat(world, "<span class='warning'>Cache clear.</span>")
///debug end

/atom/movable/render_target
	name = ""
	icon = null
	icon_state = null
	appearance_flags = KEEP_APART|TILE_BOUND|RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM
	layer = AREA_LAYER
	plane = RENDER_CACHE_PLANE

/atom/movable/render_target/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()

/atom/movable/render_target/ex_act(severity)
	return

/atom/movable/lighting_object/onTransitZ()
	return
