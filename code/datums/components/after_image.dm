/datum/component/after_image
	dupe_mode =	 COMPONENT_DUPE_UNIQUE_PASSARGS
	var/rest_time = 10
	var/duration = 150

	var/loop_timer = null
	COOLDOWN_DECLARE(imagecooldown)

	//used for estimating the pixel_x and pixel_y of the target
	var/turf/previous_loc
	var/last_movement = 0
	var/last_direction = NORTH
	var/glide_size = 8
	var/tile_size = 32

	var/mob/owner

	//cycles colors
	var/last_colour = 0
	var/color_cycle = FALSE
	var/list/hsv

/datum/component/after_image/Initialize(duration = 15, rest_time = 1, color_cycle = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent
	src.rest_time = rest_time
	src.duration = duration
	src.color_cycle = color_cycle
	last_colour = world.time

/datum/component/after_image/RegisterWithParent()
	loop_timer = addtimer(CALLBACK(src, PROC_REF(spawn_image)), rest_time, TIMER_LOOP|TIMER_UNIQUE|TIMER_STOPPABLE)//start loop
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(update_step))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_glide))
	owner = parent

/datum/component/after_image/UnregisterFromParent()
	deltimer(loop_timer)
	UnregisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/after_image/proc/update_step(mob/living/mover, dir) //when did the step start
	previous_loc = get_turf(mover)
	last_movement = world.time

/datum/component/after_image/proc/update_glide(mob/living/mover) //what's the glide animation duration
	last_direction = get_dir(previous_loc, get_turf(mover))
	glide_size = owner.glide_size

/datum/component/after_image/proc/spawn_image()
	if(!previous_loc || get_turf(owner) == previous_loc)
		return

	var/obj/effect/temp_visual/after_image/after_image = new(previous_loc, owner, duration)

	//need to recalculate position based on glide_size since it's not possible to get otherwise
	var/per_step = glide_size * 2 //i don't know why i need to multiply by 2, but that's what seems to make it line up properly
	var/since_last = world.time - last_movement

	var/x_modifier = 0
	if(last_direction & EAST)
		x_modifier = 1
	else if(last_direction & WEST)
		x_modifier = -1
	var/y_modifier = 0
	if(last_direction & NORTH)
		y_modifier = 1
	else if(last_direction & SOUTH)
		y_modifier = -1

	var/traveled = per_step * since_last
	if(traveled > 32) //don't spawn it if the player is stationary
		qdel(after_image)
		return
	after_imageF.pixel_x = (traveled * x_modifier) + owner.pixel_x
	after_image.pixel_y = (traveled * y_modifier) + owner.pixel_y

	//give them a random colours
	if(!color_cycle)
		return
	if(!hsv)
		hsv = RGBtoHSV(rgb(255, 0, 0))
	hsv = RotateHue(hsv, (world.time - last_colour) * 15)
	last_colour = world.time
	after_image.color = HSVtoRGB(hsv)	//gotta add the flair


//object used
/obj/effect/temp_visual/decoy/after_image
	layer = BELOW_MOB_LAYER //so they don't appear ontop of the user
	blocks_emissive = 0

/obj/effect/temp_visual/decoy/after_image/Initialize(mapload, atom/mimiced_atom, decay)
	duration = decay
	. = ..()
	animate(src, alpha = 0, time = duration)
