//Some debug variables. Toggle them to 1 in order to see the related debug messages. Helpful when testing out formulas.
#define DEBUG_HIT_CHANCE	0
#define DEBUG_HUMAN_DEFENSE	0
#define DEBUG_XENO_DEFENSE	0
#define DEBUG_CREST_DEFENSE	0


//The actual bullet objects.
/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "bullet"
	density = FALSE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	anchored = TRUE //You will not have me, space wind!
	flags_atom = NOINTERACT //No real need for this, but whatever. Maybe this flag will do something useful in the future.
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_MAXIMUM // We want this thing to be invisible when it drops on a turf because it will be on the user's turf. We then want to make it visible as it travels.
	layer = FLY_LAYER
	animate_movement = NO_STEPS

	var/datum/ammo/ammo //The ammo data which holds most of the actual info.

	var/def_zone = "chest"	//So we're not getting empty strings.

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center
	var/apx //Pixel location in absolute coordinates. This is (((x - 1) * 32) + 16 + pixel_x)
	var/apy //These values are floats, not integers. They need to be converted through CEILING or such when translated to relative pixel coordinates.

	var/atom/shot_from 	 = null // the object which shot us
	var/turf/starting_turf = null // the projectile's starting turf
	var/atom/original_target = null // the original target clicked
	var/turf/original_target_turf = null // the original target's starting turf
	var/atom/firer 		 = null // Who shot it

	var/list/atom/permutated = list() // we've passed through these atoms, don't try to hit them again
	var/list/atom/movable/uncross_scheduled = list() // List of border movable atoms to check for when exiting a turf.

	var/damage = 0
	var/accuracy = 85 //Base projectile accuracy. Can maybe be later taken from the mob if desired.

	var/damage_falloff = 0 //how many damage point the projectile loses per tiles travelled

	var/scatter = 0 //Chance of scattering, also maximum amount scattered. High variance.

	var/distance_travelled = 0

	var/projectile_speed = 1 //Tiles travelled per full tick.
	var/armor_type = null

	//Fired processing vars
	var/last_projectile_move = 0
	var/stored_moves = 0
	var/dir_angle //0 is north, 90 is east, 180 is south, 270 is west. BYOND angles and all.
	var/x_offset //Float, not integer.
	var/y_offset

	var/proj_max_range = 30


/obj/item/projectile/Destroy()
	STOP_PROCESSING(SSprojectiles, src)
	ammo = null
	shot_from = null
	original_target = null
	permutated = null
	uncross_scheduled = null
	original_target_turf = null
	starting_turf = null
	return ..()


/obj/item/projectile/Crossed(atom/movable/AM) //A mob moving on a tile with a projectile is hit by it.
	. = ..()
	if(AM in permutated) //If we've already handled this atom, don't do it again.
		return
	if(AM.projectile_hit(src))
		AM.do_projectile_hit(src)
		return
	permutated += AM //Don't want to hit them again.


/obj/item/projectile/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_NERF_BEAM) && ammo.flags_ammo_behavior & AMMO_ENERGY)
		damage -= max(damage - ammo.damage * 0.5, 0)

/obj/item/projectile/proc/generate_bullet(ammo_datum, bonus_damage = 0, reagent_multiplier = 0)
	ammo 		= ammo_datum
	name 		= ammo.name
	icon_state 	= ammo.icon_state
	damage 		= ammo.damage + bonus_damage //Mainly for emitters.
	scatter		= ammo.scatter
	accuracy   += ammo.accuracy
	accuracy   *= rand(95 - ammo.accuracy_var_low, 105 + ammo.accuracy_var_high) * 0.01 //Rand only works with integers.
	damage     *= rand(95 - ammo.damage_var_low, 105 + ammo.damage_var_high) * 0.01
	damage_falloff = ammo.damage_falloff
	armor_type = ammo.armor_type

//Target, firer, shot from. Ie the gun
/obj/item/projectile/proc/fire_at(atom/target, atom/shooter, atom/source, range, speed, angle, recursivity)
	if(!isnull(speed))
		projectile_speed = speed

	//Safety checks.
	if(QDELETED(target) && !isnum(angle)) //We can work with either a target or an angle, or both, but not without any.
		stack_trace("fire_at called on a QDELETED target ([target]) with no original_target_turf and a null angle.")
		qdel(src)
		return
	if(projectile_speed <= 0) //Shouldn't happen without a coder oofing, but if they do, it risks breaking a lot, so better safe than sorry.
		stack_trace("[src] achieved [projectile_speed] velocity somehow at fire_at. Type: [type]. From: [target]. Shot by: [shooter].")
		qdel(src)
		return

	if(!isnull(range))
		proj_max_range = range
	if(shooter)
		firer = shooter
		permutated += firer //Don't hit the shooter
	if(source)
		shot_from = source
	permutated += src //Don't try to hit self.
	if(!isturf(loc))
		forceMove(get_turf(src))
	starting_turf = loc

	if(target)
		original_target = target
		original_target_turf = get_turf(target)
		if(original_target_turf == loc) //Shooting from and towards the same tile. Why not?
			distance_travelled++
			scan_a_turf(loc)
			qdel(src)
			return

	apx = ABS_COOR(x) //Set the absolute coordinates. Center of a tile is assumed to be (16,16)
	apy = ABS_COOR(y)

	if(isnum(angle))
		dir_angle = angle
	else
		if(isliving(target)) //If we clicked on a living mob, use the clicked atom tile's center for maximum accuracy. Else aim for the clicked pixel. 
			dir_angle = round(Get_Pixel_Angle((ABS_COOR(target.x) - apx), (ABS_COOR(target.y) - apy))) //Using absolute pixel coordinates.
		else
			dir_angle = round(Get_Pixel_Angle((ABS_COOR_OFFSET(target.x, p_x) - apx), (ABS_COOR_OFFSET(target.y, p_y) - apy)))

	x_offset = round(sin(dir_angle), 0.01)
	y_offset = round(cos(dir_angle), 0.01)

	var/proj_dir
	switch(dir_angle) //The projectile starts at the edge of the firer's tile (still inside it).
		if(0, 360)
			proj_dir = NORTH
			pixel_x = 0
			pixel_y = 16
		if(1 to 44)
			proj_dir = NORTHEAST
			pixel_x = round(16 * ((dir_angle) / 45))
			pixel_y = 16
		if(45)
			proj_dir = NORTHEAST
			pixel_x = 16
			pixel_y = 16
		if(46 to 89)
			proj_dir = NORTHEAST
			pixel_x = 16
			pixel_y = round(16 * ((90 - dir_angle) / 45))
		if(90)
			proj_dir = EAST
			pixel_x = 16
			pixel_y = 0
		if(91 to 134)
			proj_dir = SOUTHEAST
			pixel_x = 16
			pixel_y = round(-15 * ((dir_angle - 90) / 45))
		if(135)
			proj_dir = SOUTHEAST
			pixel_x = 16
			pixel_y = -15
		if(136 to 179)
			proj_dir = SOUTHEAST
			pixel_x = round(16 * ((180 - dir_angle) / 45))
			pixel_y = -15
		if(180)
			proj_dir = SOUTH
			pixel_x = 0
			pixel_y = -15
		if(181 to 224)
			proj_dir = SOUTHWEST
			pixel_x = round(-15 * ((dir_angle - 180) / 45))
			pixel_y = -15
		if(225)
			proj_dir = SOUTHWEST
			pixel_x = -15
			pixel_y = -15
		if(226 to 269)
			proj_dir = SOUTHWEST
			pixel_x = -15
			pixel_y = round(-15 * ((270 - dir_angle) / 45))
		if(270)
			proj_dir = WEST
			pixel_x = -15
			pixel_y = 0
		if(271 to 314)
			proj_dir = NORTHWEST
			pixel_x = -15
			pixel_y = round(16 * ((dir_angle - 270) / 45))
		if(315)
			proj_dir = NORTHWEST
			pixel_x = -15
			pixel_y = 16
		if(316 to 359)
			proj_dir = NORTHWEST
			pixel_x = round(-15 * ((360 - dir_angle) / 45))
			pixel_y = 16
	setDir(proj_dir)

	apx += pixel_x //Update the absolute pixels with the offset.
	apy += pixel_y

	GLOB.round_statistics.total_projectiles_fired++
	if(ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		GLOB.round_statistics.total_bullets_fired++
		if(ammo.bonus_projectiles_amount)
			GLOB.round_statistics.total_bullets_fired += ammo.bonus_projectiles_amount

	//If we have the the right kind of ammo, we can fire several projectiles at once.
	if(ammo.bonus_projectiles_amount && !recursivity) //Recursivity check in case the bonus projectiles have bonus projectiles of their own. Let's not loop infinitely.
		ammo.fire_bonus_projectiles(src, shooter, source, range, speed, dir_angle)

	var/matrix/rotate = matrix() //Change the bullet angle.
	rotate.Turn(dir_angle)
	transform = rotate

	var/first_move = min(projectile_speed, 1)
	var/first_moves = projectile_speed
	if(projectile_batch_move(first_move)) //Hit on first movement.
		qdel(src)
		return
	invisibility = 0 //Let there be light (visibility).
	first_moves -= first_move
	if(first_moves && projectile_batch_move(first_moves)) //First movement batch happens on the same tick.
		qdel(src)
		return

	START_PROCESSING(SSprojectiles, src) //If no hits on the first moves, enter the processing queue for next.


/obj/item/projectile/process()
	if(QDELETED(src))
		return PROCESS_KILL

	var/required_moves = required_moves_calc()
	if(!required_moves)
		return //Slowpoke. Maybe next tick.

	if(projectile_batch_move(required_moves))
		qdel(src)
		return PROCESS_KILL


/obj/item/projectile/proc/required_moves_calc()
	var/elapsed_time_deciseconds = world.time - last_projectile_move
	if(!elapsed_time_deciseconds)
		return 0 //No moves needed if not a tick has passed.
	var/required_moves = (elapsed_time_deciseconds * projectile_speed) + stored_moves
	stored_moves = 0
	var/modulus_excess = MODULUS(required_moves, 1) //Fractions of a move.
	if(modulus_excess)
		required_moves -= modulus_excess
		stored_moves += modulus_excess
	
	if(required_moves > SSprojectiles.global_max_tick_moves)
		stored_moves += required_moves - SSprojectiles.global_max_tick_moves
		required_moves = SSprojectiles.global_max_tick_moves

	return required_moves

/*
CEILING() is used on some contexts:
1) For absolute pixel locations to tile conversions, as the coordinates are read from left-to-right (from low to high numbers) and each tile occupies 32 pixels. 
So if we are on the 32th absolute pixel coordinate we are on tile 1, but if we are on the 33th (to 64th) we are then on the second tile.
2) For number of pixel moves, as it is counting number of full (pixel) moves required.
*/
#define PROJ_ABS_PIXEL_TO_TURF(abspx, abspy, zlevel) (locate(CEILING((abspx / 32), 1), CEILING((abspy / 32), 1), zlevel))
#define PROJ_ANIMATION_SPEED ((end_of_movement/projectile_speed) || (required_moves/projectile_speed)) //Movements made times deciseconds per movement.

/obj/item/projectile/proc/projectile_batch_move(required_moves)
	var/end_of_movement = 0 //In batch moves this loop, only if the projectile stopped.
	var/turf/last_processed_turf = loc
	var/x_pixel_dist_travelled = 0
	var/y_pixel_dist_travelled = 0
	for(var/i in 1 to required_moves)
		distance_travelled++
		//Here we take the projectile's absolute pixel coordinate + the travelled distance and use PROJ_ABS_PIXEL_TO_TURF to first convert it into tile coordinates, and then use those to locate the turf.
		var/turf/next_turf = PROJ_ABS_PIXEL_TO_TURF((apx + x_pixel_dist_travelled + (32 * x_offset)), (apy + y_pixel_dist_travelled + (32 * y_offset)), z)
		if(!next_turf) //Map limit.
			end_of_movement = (i-- || 1)
			break
		if(next_turf == last_processed_turf)
			x_pixel_dist_travelled += 32 * x_offset
			y_pixel_dist_travelled += 32 * y_offset
			continue //Pixel movement only, didn't manage to change turf.
		var/movement_dir = get_dir(last_processed_turf, next_turf)
		
		if(ISDIAGONALDIR(movement_dir)) //Diagonal case. We need to check the turf to cross to get there.
			if(!x_offset || !y_offset) //Unless a coder screws up this won't happen. Buf if they do it will cause an infinite processing loop due to division by zero, so better safe than sorry.
				stack_trace("projectile_batch_move called with diagonal movement_dir and offset-lacking. x_offset: [x_offset], y_offset: [y_offset].")
				return TRUE
			var/turf/turf_crossed_by
			var/pixel_moves_until_crossing_x_border
			var/pixel_moves_until_crossing_y_border
			var/border_escaped_through
			switch(movement_dir)
				if(NORTHEAST)
					pixel_moves_until_crossing_x_border = CEILING(((33 - ABS_PIXEL_TO_REL(apx + x_pixel_dist_travelled)) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((33 - ABS_PIXEL_TO_REL(apy + y_pixel_dist_travelled)) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border) //Escapes vertically.
						border_escaped_through = NORTH
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border) //Escapes horizontally.
						border_escaped_through = EAST
					else //Escapes both borders at the same time, perfectly diagonal.
						border_escaped_through = pick(NORTH, EAST) //So choose at random to preserve behavior of no purely diagonal movements allowed.
				if(SOUTHEAST)
					pixel_moves_until_crossing_x_border = CEILING(((33 - ABS_PIXEL_TO_REL(apx + x_pixel_dist_travelled)) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((0 - ABS_PIXEL_TO_REL(apy + y_pixel_dist_travelled)) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border)
						border_escaped_through = SOUTH
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border)
						border_escaped_through = EAST
					else
						border_escaped_through = pick(SOUTH, EAST)
				if(SOUTHWEST)
					pixel_moves_until_crossing_x_border = CEILING(((0 - ABS_PIXEL_TO_REL(apx + x_pixel_dist_travelled)) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((0 - ABS_PIXEL_TO_REL(apy + y_pixel_dist_travelled)) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border)
						border_escaped_through = SOUTH
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border)
						border_escaped_through = WEST
					else
						border_escaped_through = pick(SOUTH, WEST)
				if(NORTHWEST)
					pixel_moves_until_crossing_x_border = CEILING(((0 - ABS_PIXEL_TO_REL(apx + x_pixel_dist_travelled)) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((33 - ABS_PIXEL_TO_REL(apy + y_pixel_dist_travelled)) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border)
						border_escaped_through = NORTH
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border)
						border_escaped_through = WEST
					else
						border_escaped_through = pick(NORTH, WEST)
			turf_crossed_by = get_step(last_processed_turf, border_escaped_through)
			for(var/j in uncross_scheduled)
				var/atom/movable/thing_to_uncross = j
				if(QDELETED(thing_to_uncross))
					continue
				if(!thing_to_uncross.projectile_hit(src, REVERSE_DIR(border_escaped_through), TRUE))
					continue
				thing_to_uncross.do_projectile_hit(src)
				end_of_movement = i
				break
			uncross_scheduled.len = 0
			if(end_of_movement)
				if(border_escaped_through & (NORTH|SOUTH))
					x_pixel_dist_travelled += --pixel_moves_until_crossing_x_border * x_offset
					y_pixel_dist_travelled += --pixel_moves_until_crossing_x_border * y_offset
				else
					x_pixel_dist_travelled += pixel_moves_until_crossing_y_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_y_border * y_offset
				break
			if(turf_crossed_by == original_target_turf && ammo.flags_ammo_behavior & AMMO_EXPLOSIVE)
				last_processed_turf = turf_crossed_by
				ammo.on_hit_turf(turf_crossed_by, src)
				turf_crossed_by.bullet_act(src)
				if(border_escaped_through & (NORTH|SOUTH))
					x_pixel_dist_travelled += pixel_moves_until_crossing_x_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_x_border * y_offset
				else
					x_pixel_dist_travelled += pixel_moves_until_crossing_y_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_y_border * y_offset
				end_of_movement = i
				break
			if(scan_a_turf(turf_crossed_by, border_escaped_through))
				last_processed_turf = turf_crossed_by
				if(border_escaped_through & (NORTH|SOUTH)) //Escapes through X.
					x_pixel_dist_travelled += pixel_moves_until_crossing_x_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_x_border * y_offset
				else //Escapes through Y.
					x_pixel_dist_travelled += pixel_moves_until_crossing_y_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_y_border * y_offset
				end_of_movement = i
				break
			movement_dir -= border_escaped_through //Next scan should come from the other component cardinal direction.
			for(var/j in uncross_scheduled) //We are leaving turf_crossed_by now.
				var/atom/movable/thing_to_uncross = j
				if(QDELETED(thing_to_uncross))
					continue
				if(!thing_to_uncross.projectile_hit(src, REVERSE_DIR(movement_dir), TRUE))
					continue
				thing_to_uncross.do_projectile_hit(src)
				end_of_movement = i
				break
			uncross_scheduled.len = 0
			if(end_of_movement)	//This is a bit overkill to deliver the right animation, but oh well.
				if(border_escaped_through & (NORTH|SOUTH)) //Inverse logic than before. We now want to run the longer distance now.
					x_pixel_dist_travelled += pixel_moves_until_crossing_y_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_y_border * y_offset
				else
					x_pixel_dist_travelled += pixel_moves_until_crossing_x_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_x_border * y_offset
				break
		if(length(uncross_scheduled)) //Time to exit the last turf entered, if the diagonal movement didn't handle it already.
			for(var/j in uncross_scheduled)
				var/atom/movable/thing_to_uncross = j
				if(QDELETED(thing_to_uncross))
					continue
				if(!thing_to_uncross.projectile_hit(src, REVERSE_DIR(movement_dir), TRUE))
					continue //We act as if we were entering the tile through the opposite direction, to check for barricade blockage.
				thing_to_uncross.do_projectile_hit(src)
				end_of_movement = i
				break
			uncross_scheduled.len = 0
			if(end_of_movement)
				break
		x_pixel_dist_travelled += 32 * x_offset
		y_pixel_dist_travelled += 32 * y_offset
		last_processed_turf = next_turf
		if(next_turf == original_target_turf && ammo.flags_ammo_behavior & AMMO_EXPLOSIVE)
			ammo.on_hit_turf(next_turf, src)
			next_turf.bullet_act(src)
			end_of_movement = i
			break
		if(scan_a_turf(next_turf, movement_dir))
			end_of_movement = i
			break
		if(distance_travelled >= proj_max_range)
			ammo.do_at_max_range(src)
			end_of_movement = i
			break

	if(end_of_movement && last_processed_turf == loc)
		last_projectile_move = world.time
		return TRUE

	apx += x_pixel_dist_travelled
	apy += y_pixel_dist_travelled

	var/new_pixel_x = ABS_PIXEL_TO_REL(apx) //The final pixel offset after this movement. Float value.
	var/new_pixel_y = ABS_PIXEL_TO_REL(apy)
	if(projectile_speed > 5) //At this speed the animation barely shows. Changing the vars through animation alone takes almost 5 times the CPU than setting them directly. No need for that if there's nothing to show for it.
		pixel_x = round(new_pixel_x, 1) - 16
		pixel_y = round(new_pixel_y, 1) - 16
		forceMove(last_processed_turf)
	else //Pixel shifts during the animation, which happens after the fact has happened. Light travels slowly here...
		var/old_pixel_x = new_pixel_x - x_pixel_dist_travelled //The pixel offset relative to the new position of where we came from. Float value.
		var/old_pixel_y = new_pixel_y - y_pixel_dist_travelled
		pixel_x = round(old_pixel_x, 1) - 16 //Projectile's sprite is displaced back to where it came from through relative pixel offset. Integer value.
		pixel_y = round(old_pixel_y, 1) - 16 //We substract 16 because this value should range from 1 to 32, but pixel offset usually ranges within the same tile from -15 to 16 (depending on the sprite).
		if(last_processed_turf != loc)
			forceMove(last_processed_turf)
		animate(src, pixel_x = (round(new_pixel_x, 1) - 16), pixel_y = (round(new_pixel_y, 1) - 16), time = PROJ_ANIMATION_SPEED, flags = ANIMATION_END_NOW) //Then we represent the movement through the animation, which updates the position to the new and correct one.

	last_projectile_move = world.time
	if(end_of_movement) //We hit something ...probably!
		return TRUE
	return FALSE //No hits ...yet!

#undef PROJ_ABS_PIXEL_TO_TURF
#undef PROJ_ANIMATION_SPEED


/obj/item/projectile/proc/scan_a_turf(turf/turf_to_scan, cardinal_move)
	if(turf_to_scan.density) //Handle wall hit.
		ammo.on_hit_turf(turf_to_scan, src)
		turf_to_scan.bullet_act(src)
		return TRUE

	if(shot_from)
		switch(SEND_SIGNAL(shot_from, COMSIG_PROJ_SCANTURF, turf_to_scan))
			if(COMPONENT_PROJ_SCANTURF_TURFCLEAR)
				return FALSE
			if(COMPONENT_PROJ_SCANTURF_TARGETFOUND)
				original_target.do_projectile_hit(src)
				return TRUE

	for(var/i in turf_to_scan)
		if(i in permutated) //If we've already handled this atom, don't do it again.
			continue
		permutated += i //Don't want to hit them again, no matter what the outcome.

		var/atom/movable/thing_to_hit = i

		if(!thing_to_hit.projectile_hit(src, cardinal_move)) //Calculated from combination of both ammo accuracy and gun accuracy.
			continue

		thing_to_hit.do_projectile_hit(src)
		return TRUE

	return FALSE


//----------------------------------------------------------
			//				    	\\
			//  HITTING THE TARGET  \\
			//						\\
			//						\\
//----------------------------------------------------------


//returns probability for the projectile to hit us.
/atom/proc/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	return FALSE

/atom/proc/do_projectile_hit(obj/item/projectile/proj)
	return


/obj/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	if(!density)
		return FALSE
	if(layer >= OBJ_LAYER || src == proj.original_target)
		return TRUE
	return FALSE

/obj/do_projectile_hit(obj/item/projectile/proj)
	proj.ammo.on_hit_obj(src, proj)
	bullet_act(proj)


/obj/structure/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	if(!density) //structure is passable
		return FALSE
	if(src == proj.original_target) //clicking on the structure itself hits the structure
		return TRUE
	if(proj.ammo.flags_ammo_behavior & AMMO_SNIPER || proj.ammo.flags_ammo_behavior & AMMO_SKIPS_HUMANS || proj.ammo.flags_ammo_behavior & AMMO_ROCKET) //sniper, rockets and IFF rounds bypass cover
		return FALSE
	if(proj.distance_travelled <= proj.ammo.barricade_clear_distance)
		return FALSE
	. = coverage //Hitchance.
	if(flags_atom & ON_BORDER)
		if(!(cardinal_move & REVERSE_DIR(dir))) //The bullet will only hit if the barricade and its movement are facing opposite directions.
			if(!uncrossing)
				proj.uncross_scheduled += src
			return FALSE //No effect now, but we save the reference to check on exiting the tile.
		. *= uncrossing ? 0.5 : 1.5 //Higher hitchance when shooting in the barricade's direction.
	if(!throwpass)
		return TRUE
	//Bypass chance calculation. Accuracy over 100 increases the chance of squeezing the bullet past the structure's uncovered areas.
	. -= (proj.accuracy - (proj.accuracy * ( (proj.distance_travelled/proj.ammo.accurate_range)*(proj.distance_travelled/proj.ammo.accurate_range) ) ))
	if(!anchored)
		. *= 0.5 //Half the protection from unaffixed structures.
	return prob(.)


/obj/structure/window/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	if(proj.ammo.flags_ammo_behavior & AMMO_ENERGY && !opacity)
		return FALSE
	if(flags_atom & ON_BORDER && !(cardinal_move & REVERSE_DIR(dir)))
		if(!uncrossing)
			proj.uncross_scheduled += src
		return FALSE
	return TRUE

/obj/machinery/door/window/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	if(proj.ammo.flags_ammo_behavior & AMMO_ENERGY && !opacity)
		return FALSE
	if(flags_atom & ON_BORDER && !(cardinal_move & REVERSE_DIR(dir)))
		if(!uncrossing)
			proj.uncross_scheduled += src
		return FALSE
	return TRUE


/obj/machinery/door/poddoor/railing/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	return src == proj.original_target

/obj/effect/alien/egg/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	return src == proj.original_target

/obj/effect/alien/resin/trap/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	return src == proj.original_target

/obj/item/clothing/mask/facehugger/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	return src == proj.original_target


/mob/living/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	if(lying && src != proj.original_target)
		return FALSE
	if(proj.ammo.flags_ammo_behavior & (AMMO_XENO_ACID|AMMO_XENO_TOX) && (isnestedhost(src) || stat == DEAD))
		return FALSE
	. += proj.accuracy //We want a temporary variable so accuracy doesn't change every time the bullet misses.
	#if DEBUG_HIT_CHANCE
	to_chat(world, "<span class='debuginfo'>Base accuracy is <b>[P.accuracy]; scatter:[P.scatter]; distance:[P.distance_travelled]</b></span>")
	#endif

	if(proj.distance_travelled <= proj.ammo.accurate_range) //If bullet stays within max accurate range + random variance.
		if(proj.distance_travelled <= proj.ammo.point_blank_range) //If bullet within point blank range, big accuracy buff.
			. += 25
		else if((proj.ammo.flags_ammo_behavior & AMMO_SNIPER) && proj.distance_travelled <= proj.ammo.accurate_range_min) //Snipers have accuracy falloff at closer range before point blank
			. -= (proj.ammo.accurate_range_min - proj.distance_travelled) * 5
	else
		. -= (proj.ammo.flags_ammo_behavior & AMMO_SNIPER) ? (proj.distance_travelled * 3) : (proj.distance_travelled * 5) //Snipers have a smaller falloff constant due to longer max range

	#if DEBUG_HIT_CHANCE
	to_chat(world, "<span class='debuginfo'>Final accuracy is <b>[.]</b></span>")
	#endif

	. = max(5, .) //default hit chance is at least 5%.
	if(lying && stat != CONSCIOUS)
		. += 15 //Bonus hit against unconscious people.

	if(isliving(proj.firer))
		var/mob/living/shooter_living = proj.firer
		if(!can_see(shooter_living, src, world.view))
			. -= 15 //Can't see the target (Opaque thing between shooter and target)
		if(shooter_living.last_move_intent < world.time - 2 SECONDS) //We get a nice accuracy bonus for standing still.
			. += 15
		else if(shooter_living.m_intent == MOVE_INTENT_WALK) //We get a decent accuracy bonus for walking
			. += 10
		if(ishuman(proj.firer))
			var/mob/living/carbon/human/shooter_human = shooter_living
			. -= round(max(30,(shooter_human.traumatic_shock) * 0.2)) //Chance to hit declines with pain, being reduced by 0.2% per point of pain.
			if(shooter_human.stagger)
				. -= 30 //Being staggered fucks your aim.
			if(shooter_human.marksman_aura) //Accuracy bonus from active focus order: flat bonus + bonus per tile traveled
				. += shooter_human.marksman_aura * 3
				. += proj.distance_travelled * shooter_human.marksman_aura * 0.35

	. -= GLOB.base_miss_chance[proj.def_zone] //Reduce accuracy based on spot.

	if(. <= 0) //If by now the sum is zero or negative, we won't be hitting at all.
		return FALSE

	var/hit_roll = rand(0, 99) //Our randomly generated roll

	if(. > hit_roll) //Hit
		return TRUE
	
	if((hit_roll - .) < 25) //Small difference, one more chance on a random bodypart, with penalties.
		var/new_def_zone = pick(GLOB.base_miss_chance)
		. -= GLOB.base_miss_chance[new_def_zone]
		if(prob(.))
			proj.def_zone = new_def_zone
			return TRUE 

	if(!lying) //Narrow miss!
		animatation_displace_reset(src)
		if(proj.ammo.sound_miss)
			playsound_local(get_turf(src), proj.ammo.sound_miss, 75, 1)
		on_dodged_bullet(proj)

	return FALSE


/mob/living/proc/on_dodged_bullet(obj/item/projectile/proj)
		visible_message("<span class='avoidharm'>[proj] misses [src]!</span>", 
		"<span class='avoidharm'>[src] narrowly misses you!</span>", null, 4)

/mob/living/carbon/xenomorph/on_dodged_bullet(obj/item/projectile/proj)
		visible_message("<span class='avoidharm'>[proj] misses [src]!</span>", 
		"<span class='avoidharm'>[src] narrowly misses us!</span>", null, 4)


/mob/living/do_projectile_hit(obj/item/projectile/proj)
	proj.ammo.on_hit_mob(src, proj)
	bullet_act(proj)


/mob/living/carbon/human/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	if(proj.ammo.flags_ammo_behavior & AMMO_SKIPS_HUMANS && get_target_lock(proj.ammo.iff_signal))
		return FALSE
	if(mobility_aura)
		. -= mobility_aura * 5
	if(ishuman(proj.firer))
		var/mob/living/carbon/human/shooter_human = proj.firer
		if(shooter_human.faction == faction || m_intent == MOVE_INTENT_WALK)
			. -= 15
	return ..()


/mob/living/carbon/xenomorph/projectile_hit(obj/item/projectile/proj, cardinal_move, uncrossing)
	if(proj.ammo.flags_ammo_behavior & AMMO_SKIPS_ALIENS)
		return FALSE
	if(mob_size == MOB_SIZE_BIG)
		. += 10
	else
		. -= 10
	return ..()


/obj/item/projectile/proc/play_damage_effect(mob/M)
	if(ammo.sound_hit) playsound(M, ammo.sound_hit, 50, 1)
	if(M.stat != DEAD) animation_flash_color(M)

//----------------------------------------------------------
				//				    \\
				//    OTHER PROCS	\\
				//					\\
				//					\\
//----------------------------------------------------------

/atom/proc/bullet_act(obj/item/projectile/P)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P)

/mob/living/bullet_act(obj/item/projectile/P)
	var/damage = max(0, P.damage - round(P.distance_travelled * P.damage_falloff))
	if(P.ammo.debilitate && stat != DEAD && ( damage || (P.ammo.flags_ammo_behavior & AMMO_IGNORE_RESIST) ) )
		apply_effects(arglist(P.ammo.debilitate))

	if(damage)
		bullet_message(P)
		apply_damage(damage, P.ammo.damage_type, P.def_zone, 0, 0, 0, P)
		P.play_damage_effect(src)

		if(P.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
			adjust_fire_stacks(rand(6,10))
			IgniteMob()
			emote("scream")
			to_chat(src, "<span class='highdanger'>You burst into flames!! Stop drop and roll!</span>")
	return 1

/*
Fixed and rewritten. For best results, the defender's combined armor for an area should not exceed 100.
If it does, it's going to be really hard to damage them with anything less than an armor penetrating
sniper rifle or something similar. I suppose that's to be expected though.
Normal range for a defender's bullet resist should be something around 30-50. ~N
*/
/mob/living/carbon/human/bullet_act(obj/item/projectile/P)
	flash_weak_pain()

	if(P.ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		GLOB.round_statistics.total_bullet_hits_on_humans++

	var/damage = max(0, P.damage - round(P.distance_travelled * P.damage_falloff))
	#if DEBUG_HUMAN_DEFENSE
	to_chat(world, "<span class='debuginfo'>Initial damage is: <b>[damage]</b></span>")
	#endif

	//Shields
	if( !(P.ammo.flags_ammo_behavior & AMMO_ROCKET) ) //No, you can't block rockets.
		if( P.dir == reverse_direction(dir) && check_shields(damage * 0.65, "[P]") && src != P.shot_from.sniper_target(src)) //Aimed sniper shots will ignore shields
			P.ammo.on_shield_block(src)
			bullet_ping(P)
			return

	var/datum/limb/organ = get_limb(check_zone(P.def_zone)) //Let's finally get what organ we actually hit.
	if(!organ) return//Nope. Gotta shoot something!

	//Run armor check. We won't bother if there is no damage being done.
	if( damage > 0 && !(P.ammo.flags_ammo_behavior & AMMO_IGNORE_ARMOR) )
		var/armor //Damage types don't correspond to armor types. We are thus merging them.
		armor = getarmor_organ(organ, P.armor_type) //Should always have a type; this defaults to bullet if nothing else.

		#if DEBUG_HUMAN_DEFENSE
		to_chat(world, "<span class='debuginfo'>Initial armor is: <b>[armor]</b></span>")
		#endif
		var/penetration = P.ammo.penetration > 0 || armor > 0 ? P.ammo.penetration : 0
		if(P.shot_from && src == P.shot_from.sniper_target(src)) //Runtimes bad
			damage *= SNIPER_LASER_DAMAGE_MULTIPLIER
			penetration *= SNIPER_LASER_ARMOR_MULTIPLIER
			add_slowdown(SNIPER_LASER_SLOWDOWN_STACKS)

		armor -= penetration//Minus armor penetration from the bullet. If the bullet has negative penetration, adding to their armor, but they don't have armor, they get nothing.
		#if DEBUG_HUMAN_DEFENSE
		to_chat(world, "<span class='debuginfo'>Adjusted armor after penetration is: <b>[armor]</b></span>")
		#endif

		if(armor > 0) //Armor check. We should have some to continue.
			/*Automatic damage soak due to armor. Greater difference between armor and damage, the more damage
			soaked. Small caliber firearms aren't really effective against combat armor.*/
			var/armor_soak	 = round( ( armor / damage ) * 10 )//Setting up for next action.
			var/critical_hit = rand(5,10)
			damage 			-= prob(critical_hit) ? 0 : armor_soak //Chance that you won't soak the initial amount.
			armor			-= round(armor_soak * 1) //If you still have armor left over, you generally should, we subtract the soak.
													//This gives smaller calibers a chance to actually deal damage.
			#if DEBUG_HUMAN_DEFENSE
			to_chat(world, "<span class='debuginfo'>Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[armor]</b></span>")
			#endif
			var/i = 0
			if(damage)
				while(armor > 0 && i < 2) //Going twice. Armor has to exist to continue. Post increment.
					if(prob(armor))
						armor_soak 	 = round(damage * 0.5)  //Cut it in half.
						armor 		-= armor_soak * 2
						damage 		-= armor_soak
						#if DEBUG_HUMAN_DEFENSE
						to_chat(world, "<span class='debuginfo'>Currently soaked: <b>[armor_soak]</b>. Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[armor]</b></span>")
						#endif
					else break //If we failed to block the damage, it's time to get out of the loop.
					i++
			if(i || damage <= 5) to_chat(src, "<span class='notice'>Your armor [ i == 2 ? "absorbs the force of [P]!" : "softens the impact of [P]!" ]</span>")
			if(damage <= 0)
				damage = 0
				if(P.ammo.sound_armor) playsound(src, P.ammo.sound_armor, 50, 1)

	if(P.ammo.debilitate && stat != DEAD && ( damage || (P.ammo.flags_ammo_behavior & AMMO_IGNORE_RESIST) ) )  //They can't be dead and damage must be inflicted (or it's a xeno toxin).
		//Synths are immune to these effects to cut down on the stun spam. This should later be moved to their apply_effects proc, but right now they're just humans.
		if(!(species.species_flags & IS_SYNTHETIC))
			apply_effects(arglist(P.ammo.debilitate))

	bullet_message(P) //We still want this, regardless of whether or not the bullet did damage. For griefers and such.

	if(damage)
		apply_damage(damage, P.ammo.damage_type, P.def_zone)
		P.play_damage_effect(src)
		if(P.ammo.shrapnel_chance > 0 && prob(P.ammo.shrapnel_chance + round(damage / 10) ) )
			var/obj/item/shard/shrapnel/shrap = new()
			shrap.name = "[P.name] shrapnel"
			shrap.desc = "[shrap.desc] It looks like it was fired from [P.shot_from ? P.shot_from : "something unknown"]."
			shrap.loc = organ
			organ.embed(shrap)
			if(!stat && !(species && species.species_flags & NO_PAIN))
				emote("scream")
				to_chat(src, "<span class='highdanger'>You scream in pain as the impact sends <B>shrapnel</b> into the wound!</span>")

		if(P.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
			adjust_fire_stacks(rand(6,11))
			IgniteMob()
			if(!stat && !(species.species_flags & NO_PAIN))
				emote("scream")
				to_chat(src, "<span class='highdanger'>You burst into flames!! Stop drop and roll!</span>")
		return 1

//Deal with xeno bullets.
/mob/living/carbon/xenomorph/bullet_act(obj/item/projectile/P)
	if(issamexenohive(P.firer)) //Aliens won't be harming allied aliens.
		bullet_ping(P)
		return

	if(P.ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		GLOB.round_statistics.total_bullet_hits_on_xenos++

	flash_weak_pain()

	var/damage = max(0, P.damage - round(P.distance_travelled * P.damage_falloff)) //Has to be at least zero, no negatives.
	#if DEBUG_XENO_DEFENSE
	to_chat(world, "<span class='debuginfo'>Initial damage is: <b>[damage]</b></span>")
	#endif

	if(warding_aura) //Damage reduction. Every point of warding decreases damage by 1%. Maximum is 5% at 5 pheromone strength.
		damage = round(damage * (1 - (warding_aura * 0.01) ) )
		#if DEBUG_XENO_DEFENSE
		to_chat(world, "<span class='debuginfo'>Damage migated by a warding aura level of [warding_aura], damage is now <b>[damage]</b></span>")
		#endif

	if(damage > 0 && !(P.ammo.flags_ammo_behavior & AMMO_IGNORE_ARMOR))
		var/initial_armor = armor.getRating(P.ammo.armor_type)
		var/affecting_armor = initial_armor + armor_bonus + armor_pheromone_bonus
		#if DEBUG_XENO_DEFENSE
		world << "<span class='debuginfo'>Initial armor is: <b>[affecting_armor]</b></span>"
		#endif
		if(isxenoqueen(src) || isxenocrusher(src)) //Charging and crest resistances. Charging Xenos get a lot of extra armor, currently Crushers and Queens
			var/mob/living/carbon/xenomorph/charger = src
			if(is_charging >= CHARGE_ON)
				affecting_armor += round(charger.get_movespeed_modifier(MOVESPEED_ID_XENO_CHARGE) * 5) //Some armor deflection when charging.
			#if DEBUG_CREST_DEFENSE
			world << "<span class='debuginfo'>Projectile direction is: <b>[P.dir]</b> and crest direction is: <b>[charger.dir]</b></span>"
			#endif
			if(P.dir == charger.dir)
				if(isxenoqueen(src))
					affecting_armor = max(0, affecting_armor - (initial_armor * 0.5)) //Both facing same way -- ie. shooting from behind; armour reduced by 50% of base.
				else
					affecting_armor = max(0, affecting_armor - (initial_armor * 0.75)) //Both facing same way -- ie. shooting from behind; armour reduced by 75% of base.
			else if(P.dir == reverse_direction(charger.dir))
				affecting_armor += round(initial_armor * 0.5) //We are facing the bullet.
			else if(isxenocrusher(src))
				affecting_armor = max(0, affecting_armor - (initial_armor * 0.25)) //side armour eats a bit of shit if we're a Crusher
			//Otherwise use the standard armor deflection for crushers.
			#if DEBUG_XENO_DEFENSE
			to_chat(world, "<span class='debuginfo'>Adjusted crest armor is: <b>[affecting_armor]</b></span>")
			#endif

		var/penetration = P.ammo.penetration > 0 || affecting_armor > 0 ? P.ammo.penetration : 0
		if(P.shot_from && src == P.shot_from.sniper_target(src))
			damage *= SNIPER_LASER_DAMAGE_MULTIPLIER
			penetration *= SNIPER_LASER_ARMOR_MULTIPLIER
			add_slowdown(SNIPER_LASER_SLOWDOWN_STACKS)

		affecting_armor -= penetration

		#if DEBUG_XENO_DEFENSE
		world << "<span class='debuginfo'>Adjusted armor after penetration is: <b>[affecting_armor]</b></span>"
		#endif
		if(affecting_armor > 0) //Armor check. We should have some to continue.
			/*Automatic damage soak due to armor. Greater difference between armor and damage, the more damage
			soaked. Small caliber firearms aren't really effective against combat armor.*/
			var/armor_soak	 = round( ( affecting_armor / damage ) * 10 )//Setting up for next action.
			var/critical_hit = rand(5,10)
			damage 			-= prob(critical_hit) ? 0 : armor_soak //Chance that you won't soak the initial amount.
			affecting_armor			-= round(armor_soak * 1) //If you still have armor left over, you generally should, we subtract the soak.
													//This gives smaller calibers a chance to actually deal damage.
			#if DEBUG_XENO_DEFENSE
			to_chat(world, "<span class='debuginfo'>Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[affecting_armor]</b></span>")
			#endif
			var/i = 0
			if(damage)
				while(affecting_armor > 0 && i < 2) //Going twice. Armor has to exist to continue. Post increment.
					if(prob(affecting_armor))
						armor_soak 	 = round(damage * 0.5)
						affecting_armor 		-= armor_soak * 2
						damage 		-= armor_soak
						#if DEBUG_XENO_DEFENSE
						to_chat(world, "<span class='debuginfo'>Currently soaked: <b>[armor_soak]</b>. Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[affecting_armor]</b></span>")
						#endif
					else break //If we failed to block the damage, it's time to get out of the loop.
					i++
			if(i || damage <= 5) to_chat(src, "<span class='xenonotice'>Your exoskeleton [ i == 2 ? "absorbs the force of [P]!" : "softens the impact of [P]!" ]</span>")
			if(damage <= 3)
				damage = 0
				bullet_ping(P)
				visible_message("<span class='avoidharm'>[src]'s thick exoskeleton deflects [P]!</span>")

	bullet_message(P) //Message us about the bullet, since damage was inflicted.

	if(damage)
		apply_damage(damage,P.ammo.damage_type, P.def_zone)	//Deal the damage.
		P.play_damage_effect(src)
		if(!stat && prob(5 + round(damage / 4)))
			var/pain_emote = prob(70) ? "hiss" : "roar"
			emote(pain_emote)
		if(P.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
			if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
				if(!stat) to_chat(src, "<span class='avoidharm'>You shrug off some persistent flames.</span>")
			else
				adjust_fire_stacks(rand(2,6) + round(damage / 8))
				IgniteMob()
				visible_message("<span class='danger'>[src] bursts into flames!</span>", \
				"<span class='xenodanger'>You burst into flames!! Auuugh! Resist to put out the flames!</span>")
		updatehealth()

	return 1

/turf/bullet_act(obj/item/projectile/proj)
	bullet_ping(proj)

	var/list/livings_list = list() //Let's built a list of mobs on the bullet turf and grab one.
	for(var/mob/living/L in src)
		if(L in proj.permutated)
			continue
		livings_list += L

	if(!length(livings_list))
		return TRUE

	var/mob/living/picked_mob = pick(livings_list)
	if(proj.projectile_hit(picked_mob))
		picked_mob.bullet_act(proj)
	return TRUE


// walls can get shot and damaged, but bullets (vs energy guns) do much less.
/turf/closed/wall/bullet_act(obj/item/projectile/P)
	. = ..()
	if(!.)
		return
	var/damage = P.damage
	if(damage < 1) return

	switch(P.ammo.damage_type)
		if(BRUTE) 	damage = P.ammo.flags_ammo_behavior & AMMO_ROCKET ? round(damage * 10) : damage //Bullets do much less to walls and such.
		if(BURN)	damage = P.ammo.flags_ammo_behavior & (AMMO_ENERGY) ? round(damage * 1.5) : damage
		else return
	if(P.ammo.flags_ammo_behavior & AMMO_BALLISTIC) current_bulletholes++
	take_damage(damage)
	if(prob(30 + damage)) P.visible_message("<span class='warning'>[src] is damaged by [P]!</span>")
	return 1


//----------------------------------------------------------
					//				    \\
					//    OTHER PROCS	\\
					//					\\
					//					\\
//----------------------------------------------------------


//This is where the bullet bounces off.
/atom/proc/bullet_ping(obj/item/projectile/P)
	if(!P.ammo.ping)
		return
	if(prob(65))
		if(P.ammo.sound_bounce) playsound(src, P.ammo.sound_bounce, 50, 1)
		var/image/I = image('icons/obj/items/projectiles.dmi',src,P.ammo.ping,10)
		var/angle = (P.firer && prob(60)) ? round(Get_Angle(P.firer,src)) : round(rand(1,359))
		I.pixel_x += rand(-6,6)
		I.pixel_y += rand(-6,6)

		var/matrix/rotate = matrix()
		rotate.Turn(angle)
		I.transform = rotate
		flick_overlay_view(I, src, 3)


#define BULLET_MESSAGE_NO_SHOOTER 0
#define BULLET_MESSAGE_HUMAN_SHOOTER 1
#define BULLET_MESSAGE_OTHER_SHOOTER 2

/mob/living/proc/bullet_message(obj/item/projectile/P)
	if(!P.firer)
		log_message("SOMETHING?? shot [key_name(src)] with a [P]", LOG_ATTACK)
		msg_admin_attack("SOMETHING?? shot [ADMIN_TPMONTY(src)] with a [P])")
		return BULLET_MESSAGE_NO_SHOOTER
	var/turf/T = get_turf(P.firer)
	log_combat(P.firer, src, "shot", P)
	msg_admin_attack("[ADMIN_TPMONTY(P.firer)] shot [ADMIN_TPMONTY(src)] with [P] in [ADMIN_VERBOSEJMP(T)].")
	if(ishuman(P.firer))
		SEND_SOUND(P.firer, get_sfx("ballistic hitmarker"))
		return BULLET_MESSAGE_HUMAN_SHOOTER
	return BULLET_MESSAGE_OTHER_SHOOTER

/mob/living/carbon/xenomorph/bullet_message(obj/item/projectile/P)
	. = ..()
	if(P.ammo.flags_ammo_behavior & AMMO_IS_SILENCED)
		to_chat(src, "<span class='xenodanger'>We've been shot in the [parse_zone(P.def_zone)] by [P.name]!</span>")
	else
		visible_message("<span class='danger'>[name] is hit by the [P.name] in the [parse_zone(P.def_zone)]!</span>",
		"<span class='xenodanger'>We are hit by the [P.name] in the [parse_zone(P.def_zone)]!</span>", null, 4)

/mob/living/carbon/human/bullet_message(obj/item/projectile/P)
	. = ..()
	if(P.ammo.flags_ammo_behavior & AMMO_IS_SILENCED)
		to_chat(src, "<span class='highdanger'>You've been shot in the [parse_zone(P.def_zone)] by [P.name]!</span>")
	else
		visible_message("<span class='danger'>[name] is hit by the [P.name] in the [parse_zone(P.def_zone)]!</span>",
		"<span class='highdanger'>You are hit by the [P.name] in the [parse_zone(P.def_zone)]!</span>", null, 4)
	if(. != BULLET_MESSAGE_HUMAN_SHOOTER)
		return
	var/mob/living/carbon/human/firingMob = P.firer
	if(!firingMob.mind?.bypass_ff && !mind?.bypass_ff && firingMob.faction == faction)
		var/turf/T = get_turf(firingMob)
		log_ffattack("[key_name(firingMob)] shot [key_name(src)] with [P] in [AREACOORD(T)].")
		msg_admin_ff("[ADMIN_TPMONTY(firingMob)] shot [ADMIN_TPMONTY(src)] with [P] in [ADMIN_VERBOSEJMP(T)].")
		GLOB.round_statistics.total_bullet_hits_on_marines++

#undef BULLET_MESSAGE_NO_SHOOTER
#undef BULLET_MESSAGE_HUMAN_SHOOTER
#undef BULLET_MESSAGE_OTHER_SHOOTER



#undef DEBUG_HIT_CHANCE
#undef DEBUG_HUMAN_DEFENSE
#undef DEBUG_XENO_DEFENSE
