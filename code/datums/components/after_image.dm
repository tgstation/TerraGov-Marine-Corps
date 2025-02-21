/datum/component/after_image
	//dupe_mode =	 COMPONENT_DUPE_UNIQUE_PASSARGS
	dupe_mode = COMPONENT_DUPE_SOURCES
	///How frequently an image is made
	var/loop_delay = 0.1 SECONDS
	///How long an image lasts
	var/image_duration = 1.5 SECONDS
	///Holds the loop timer
	var/loop_timer = null
	///Last loc of owner. Used for estimating the pixel_x and pixel_y of the target
	var/turf/previous_loc
	///Last move time of owner
	var/last_movement = 0
	///Last dir faced by owner
	var/last_direction = NORTH
	///Current glide_size of the owner
	var/glide_size = 8
	///Mob we are making images of
	var/mob/owner
	var/jump_height = 0
	var/jump_duration = 0
	var/jump_start_time = 0

	///Whether we make a rainbow colour cycle
	var/color_cycle = FALSE
	///Last world time we cycled a colour
	var/last_colour_time = 0
	///Current colour of the after image
	var/list/hsv
	COOLDOWN_DECLARE(imagecooldown)

/datum/component/after_image/Initialize(image_duration = 1.5 SECONDS, loop_delay = 0.1 SECONDS, color_cycle = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent
	src.loop_delay = loop_delay
	src.image_duration = image_duration
	src.color_cycle = color_cycle
	last_colour_time = world.time

/datum/component/after_image/RegisterWithParent()
	loop_timer = addtimer(CALLBACK(src, PROC_REF(spawn_image)), loop_delay, TIMER_LOOP|TIMER_UNIQUE|TIMER_STOPPABLE)
	START_PROCESSING(SSobj, src)
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(update_step))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_glide))
	RegisterSignal(parent, COMSIG_ELEMENT_JUMP_STARTED, PROC_REF(handle_jump))
	owner = parent

/datum/component/after_image/UnregisterFromParent()
	deltimer(loop_timer)
	UnregisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_ELEMENT_JUMP_STARTED))

///Updates prev loc and move time when starting a step
/datum/component/after_image/proc/update_step(mob/living/mover, dir)
	SIGNAL_HANDLER
	previous_loc = get_turf(mover)
	last_movement = world.time

///Updates last dir and glidesize after making a step
/datum/component/after_image/proc/update_glide(mob/living/mover)
	SIGNAL_HANDLER
	last_direction = get_dir(previous_loc, get_turf(mover))
	glide_size = owner.glide_size

///Records jump details
/datum/component/after_image/proc/handle_jump(mob/living/mover, jump_height, jump_duration)
	SIGNAL_HANDLER
	jump_start_time = world.time
	src.jump_height = jump_height
	src.jump_duration = jump_duration

///Creates the after image
/datum/component/after_image/proc/spawn_image()
	if(!previous_loc || get_turf(owner) == previous_loc)
		return
	var/obj/effect/temp_visual/after_image/after_image = new(previous_loc, owner, image_duration)

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
	after_image.pixel_x = (traveled * x_modifier) + owner.pixel_x
	after_image.pixel_y = (traveled * y_modifier) + owner.pixel_y
	if((jump_start_time < world.time) && (jump_start_time + jump_duration) > world.time)
		after_image.pixel_y += jump_height * sin(TODEGREES((PI * (world.time - jump_start_time)) / jump_duration))

	if(!color_cycle)
		return
	if(!hsv)
		hsv = RGBtoHSV(rgb(255, 0, 0))
	hsv = RotateHue(hsv, (world.time - last_colour_time) * 15)
	last_colour_time = world.time
	after_image.color = HSVtoRGB(hsv)
