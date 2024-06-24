
/** # Beam Datum and Effect
 * **IF YOU ARE LAZY AND DO NOT WANT TO READ, GO TO THE BOTTOM OF THE FILE AND USE THAT PROC!**
 *
 * This is the beam datum! It's a really neat effect for the game in drawing a line from one atom to another.
 * It has two parts:
 * The datum itself which manages redrawing the beam to constantly keep it pointing from the origin to the target.
 * The effect which is what the beams are made out of. They're placed in a line from the origin to target, rotated towards the target and snipped off at the end.
 * These effects are kept in a list and constantly created and destroyed (hence the proc names draw and reset, reset destroying all effects and draw creating more.)
 *
 * You can add more special effects to the beam itself by changing what the drawn beam effects do. For example you can make a vine that pricks people by making the beam_type
 * include a crossed proc that damages the crosser. Examples in venus_human_trap.dm
*/
/datum/beam
	///where the beam goes from
	var/atom/origin = null
	///where the beam goes to
	var/atom/target = null
	///list of beam objects. These have their visuals set by the visuals var which is created on starting
	var/list/elements = list()
	///icon used by the beam.
	var/icon
	///icon state of the main segments of the beam
	var/icon_state = ""
	///The beam will qdel if it's longer than this many tiles.
	var/max_distance = 1
	///the objects placed in the elements list
	var/beam_type = /obj/effect/ebeam
	///This is used as the visual_contents of beams, so you can apply one effect to this and the whole beam will look like that. never gets deleted on redrawing.
	var/obj/effect/ebeam/visuals

/datum/beam/New(beam_origin,beam_target,beam_icon='icons/effects/beam.dmi',beam_icon_state="b_beam",time=INFINITY,maxdistance=INFINITY,btype = /obj/effect/ebeam)
	origin = beam_origin
	target = beam_target
	if(maxdistance < 1)
		stack_trace("An attempt was made to make a beam with a max distance of 0 or negative.")
	else
		max_distance = maxdistance
	icon = beam_icon
	icon_state = beam_icon_state
	beam_type = btype
	if(time < INFINITY)
		QDEL_IN(src, time)

/**
 * Proc called by the atom Beam() proc. Sets up signals, and draws the beam for the first time.
 */
/datum/beam/proc/Start()
	visuals = new beam_type()
	visuals.icon = icon
	visuals.icon_state = icon_state
	Draw()
	register_signals()

///Handle setting up signals for the beam
/datum/beam/proc/register_signals()
	RegisterSignal(origin, COMSIG_MOVABLE_MOVED, PROC_REF(redrawing))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(redrawing))

/**
 * Triggered by signals set up when the beam is set up. If it's still sane to create a beam, it removes the old beam, creates a new one. Otherwise it kills the beam.
 *
 * Arguments:
 * mover: either the origin of the beam or the target of the beam that moved.
 * oldloc: from where mover moved.
 * direction: in what direction mover moved from.
 */
/datum/beam/proc/redrawing(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER_DOES_SLEEP
	if(origin && target && get_dist(origin,target)<max_distance && origin.z == target.z)
		QDEL_LIST(elements)
		Draw()
	else
		qdel(src)

/datum/beam/Destroy()
	QDEL_LIST(elements)
	qdel(visuals)
	unregister_signals()
	target = null
	origin = null
	return ..()

///Handle removing signals when the beam is destroyed
/datum/beam/proc/unregister_signals()
	UnregisterSignal(origin, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/**
 * Creates the beam effects and places them in a line from the origin to the target. Sets their rotation to make the beams face the target, too.
 */
/datum/beam/proc/Draw()
	var/Angle = round(Get_Angle(origin,target))
	var/matrix/rot_matrix = matrix()
	var/turf/origin_turf = get_turf(origin)
	rot_matrix.Turn(Angle)

	//Translation vector for origin and target
	var/DX = (32*target.x+target.pixel_x)-(32*origin.x+origin.pixel_x)
	var/DY = (32*target.y+target.pixel_y)-(32*origin.y+origin.pixel_y)
	var/N = 0
	var/length = round(sqrt((DX)**2+(DY)**2)) //hypotenuse of the triangle formed by target and origin's displacement

	for(N in 0 to length-1 step 32)//-1 as we want < not <=, but we want the speed of X in Y to Z and step X
		if(QDELETED(src))
			break
		var/obj/effect/ebeam/X = new beam_type(origin_turf)
		X.owner = src
		elements += X

		//Assign our single visual ebeam to each ebeam's vis_contents
		//ends are cropped by a transparent box icon of length-N pixel size laid over the visuals obj
		if(N+32>length) //went past the target, we draw a box of space to cut away from the beam sprite so the icon actually ends at the center of the target sprite
			var/icon/II = new(icon, icon_state)//this means we exclude the overshooting object from the visual contents which does mean those visuals don't show up for the final bit of the beam...
			II.DrawBox(null,1,(length-N),32,32)//in the future if you want to improve this, remove the drawbox and instead use a 513 filter to cut away at the final object's icon
			X.icon = II
		else
			X.vis_contents += visuals
		X.transform = rot_matrix

		//Calculate pixel offsets (If necessary)
		var/Pixel_x
		var/Pixel_y
		if(DX == 0)
			Pixel_x = 0
		else
			Pixel_x = round(sin(Angle)+32*sin(Angle)*(N+16)/32)
		if(DY == 0)
			Pixel_y = 0
		else
			Pixel_y = round(cos(Angle)+32*cos(Angle)*(N+16)/32)

		//Position the effect so the beam is one continous line
		var/a
		if(abs(Pixel_x)>32)
			a = Pixel_x > 0 ? round(Pixel_x/32) : CEILING(Pixel_x/32, 1)
			X.x += a
			Pixel_x %= 32
		if(abs(Pixel_y)>32)
			a = Pixel_y > 0 ? round(Pixel_y/32) : CEILING(Pixel_y/32, 1)
			X.y += a
			Pixel_y %= 32

		X.pixel_x = Pixel_x
		X.pixel_y = Pixel_y
		CHECK_TICK

/datum/beam/laser
	///Is TRUE when the beam is not from a player (like a sentry); if TRUE, will track targets
	var/automated
	///How far the beam can turn from the facing direction of the atom the beam originates from
	var/max_angle = 0
	///The angle the beam was previously at
	var/previous_angle = -1

/datum/beam/laser/New(beam_origin, beam_target, beam_icon, beam_icon_state, time, maxdistance, btype, automated)
	. = ..()
	src.automated = automated
	set_target(beam_target)

///Handles setting the target of the beam
/datum/beam/laser/proc/set_target(new_target)
	if(!visuals)	//Visuals is null if the beam has not been Start()ed yet, in which case don't un/register signals yet
		target = new_target
		return

	if(automated)	//Only track targets if the beam is from a non-player source
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
		RegisterSignal(new_target, COMSIG_MOVABLE_MOVED, PROC_REF(redrawing))

	target = new_target

//This beam type does not go past dense and opaque turfs and will not delete itself if past the max range
/datum/beam/laser/register_signals()
	if(automated)
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(redrawing))
	RegisterSignal(origin, COMSIG_MOVABLE_MOVED, PROC_REF(redrawing))

/datum/beam/laser/unregister_signals()
	if(automated)
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(origin, COMSIG_MOVABLE_MOVED)

/datum/beam/laser/redrawing(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER_DOES_SLEEP
	if(origin && target && origin.z == target.z)
		QDEL_LIST(elements)
		Draw()
	else
		qdel(src)

/datum/beam/laser/Draw()
	//The beam will skew itself trying to aim for mobs that are offset, so aim for the turf
	//If there is a max_angle value, aim the beam as far as it can turn
	var/angle
	if(max_angle)
		//The direction the origin is facing, but in degrees
		var/angle_of_direction = dir2angle(origin.dir)
		//Get the angle between the target and the origin, calculate the difference, and normalize it
		var/difference_in_degrees = ((round(Get_Angle(origin, get_turf(target))) - angle_of_direction + 180) % 360 + 360) % 360 - 180
		//Add (or subtract) the difference to the angle the origin is facing to determine the beam's angle within the bounds of the max_angle
		angle = angle_of_direction + clamp(difference_in_degrees, -max_angle/2, max_angle/2)
	else
		angle = round(Get_Angle(origin, get_turf(target)))

	//If the beam's angle is unchanged, don't redraw the beam
	if(angle == previous_angle)
		return

	QDEL_LIST(elements)	//Get rid of the previous beam objects
	var/matrix/rotation = matrix()
	var/turf/origin_turf = get_turf(origin)
	rotation.Turn(angle)

	//Translation vector for origin and target
	var/max_pixel_distance = 32 * max_distance
	var/length = round(sqrt((max_pixel_distance) ** 2 + (max_pixel_distance) ** 2), 1)

	for(var/i = 0; length > i; i += 32)	//Don't use fucking "step 32" in place of i += 32
		if(QDELETED(src) || i / 32 >= max_distance)
			break

		var/obj/effect/ebeam/created_beam = new beam_type(origin_turf)
		created_beam.owner = src
		created_beam.vis_contents += visuals	//Every beam object has the same visual properties (including particles!) of the object assigned to visuals var
		created_beam.transform = rotation
		elements += created_beam

		//Calculations for how to arrange the beam objects in a straight line
		var/new_pixel_x = round(sin(angle) + 32 * sin(angle) * (i + 16) / 32, 1)
		var/absolute_pixel_x = abs(new_pixel_x)
		var/new_pixel_y = round(cos(angle) + 32 * cos(angle) * (i + 16) / 32, 1)
		var/absolute_pixel_y = abs(new_pixel_y)

		//This portion places the beam object on a tile to continue the beam line
		if(absolute_pixel_x > 32)
			created_beam.x += new_pixel_x > 0 ? round(new_pixel_x / 32) : CEILING(new_pixel_x / 32, 1)
			new_pixel_x %= 32
		if(absolute_pixel_y > 32)
			created_beam.y += new_pixel_y > 0 ? round(new_pixel_y / 32) : CEILING(new_pixel_y / 32, 1)
			new_pixel_y %= 32

		created_beam.pixel_x = new_pixel_x
		created_beam.pixel_y = new_pixel_y

		//Trim the beam if it has reached the end or the max distance
		if((i + 32 > length) || (i / 32 >= max_distance))
			created_beam.add_filter("trim_beam", 1, alpha_mask_filter(0, length - i))
			return

		//It's not perfect but no idea how projectiles manage to do it precisely
		var/turf/turf = get_turf_in_angle(angle, get_turf(created_beam), 1)
		//Check if the beam hit a wall
		if(turf.density)
			created_beam.add_filter("trim_beam", 1, alpha_mask_filter(0, length - i))
			return

		//Check if the beam hit something lasers can't go through
		for(var/obj/object in turf)
			if(object.density && !CHECK_BITFIELD(object.allow_pass_flags, PASS_GLASS) && !CHECK_BITFIELD(object.allow_pass_flags, PASS_PROJECTILE))
				created_beam.add_filter("trim_beam", 1, alpha_mask_filter(0, length - i))
				return

		CHECK_TICK

/obj/effect/ebeam
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	var/datum/beam/owner
	///Used for referencing spawned particles
	var/obj/effect/abstract/particle_holder/particle_holder

/obj/effect/ebeam/Destroy()
	owner = null
	QDEL_NULL(particle_holder)
	return ..()

/**
 * This is what you use to start a beam. Example: origin.Beam(target, args). **Store the return of this proc if you don't set maxdist or time, you need it to delete the beam.**
 *
 * Unless you're making a custom beam effect (see the beam_type argument), you won't actually have to mess with any other procs. Make sure you store the return of this Proc, you'll need it
 * to kill the beam.
 * **Arguments:**
 * BeamTarget: Where you're beaming from. Where do you get origin? You didn't read the docs, fuck you.
 * icon_state: What the beam's icon_state is. The datum effect isn't the ebeam object, it doesn't hold any icon and isn't type dependent.
 * icon: What the beam's icon file is. Don't change this, man. All beam icons should be in beam.dmi anyways.
 * maxdistance: how far the beam will go before stopping itself. Used mainly for two things: preventing lag if the beam may go in that direction and setting a range to abilities that use beams.
 * beam_type: The type of your custom beam. This is for adding other wacky stuff for your beam only. Most likely, you won't (and shouldn't) change it.
 */
/atom/proc/beam(atom/BeamTarget,icon_state="b_beam",icon='icons/effects/beam.dmi',time = INFINITY,maxdistance = INFINITY,beam_type=/obj/effect/ebeam)
	var/datum/beam/newbeam = new(src,BeamTarget,icon,icon_state,time,maxdistance,beam_type)
	INVOKE_ASYNC(newbeam, TYPE_PROC_REF(/datum/beam, Start))
	return newbeam

/proc/zap_beam(atom/source, zap_range, damage, list/blacklistmobs)
	. = list()
	for(var/mob/living/carbon/xenomorph/beno in oview(zap_range, source))
		. += beno
	for(var/xeno in .)
		var/mob/living/carbon/xenomorph/living = xeno
		if(!living)
			return
		if(living.stat == DEAD)
			continue
		if(living in blacklistmobs)
			continue
		source.beam(living, icon_state="lightning[rand(1,12)]", time = 3, maxdistance = zap_range + 2)
		if(living.xeno_caste.can_flags & CASTE_CAN_BE_GIVEN_PLASMA) //need 1 second more than the actual effect time
			living.apply_status_effect(/datum/status_effect/noplasmaregen, 3 SECONDS)
			living.apply_status_effect(/datum/status_effect/plasmadrain, 3 SECONDS)
		living.add_slowdown(2)
		log_attack("[living] was zapped by [source]")
