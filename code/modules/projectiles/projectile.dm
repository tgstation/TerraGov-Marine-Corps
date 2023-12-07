//Some debug variables. Toggle them to 1 in order to see the related debug messages. Helpful when testing out formulas.
#define DEBUG_HIT_CHANCE 0
#define DEBUG_HUMAN_DEFENSE 0
#define DEBUG_XENO_DEFENSE 0
#define DEBUG_CREST_DEFENSE 0

#if DEBUG_HIT_CHANCE
#define BULLET_DEBUG(msg) to_chat(world, span_debuginfo("[msg]"))
#else
#define BULLET_DEBUG(msg)
#endif

#define BULLET_FEEDBACK_PEN (1<<0)
#define BULLET_FEEDBACK_SOAK (1<<1)
#define BULLET_FEEDBACK_FIRE (1<<2)
#define BULLET_FEEDBACK_SCREAM (1<<3)
#define BULLET_FEEDBACK_SHRAPNEL (1<<4)
#define BULLET_FEEDBACK_IMMUNE (1<<5)

#define DAMAGE_REDUCTION_COEFFICIENT(armor) (0.1/((armor*armor*0.0001)+0.1)) //Armor offers diminishing returns.

#define PROJECTILE_HIT_CHECK(thing_to_hit, projectile, cardinal_move, uncrossing, hit_atoms) (!(thing_to_hit.resistance_flags & PROJECTILE_IMMUNE) && thing_to_hit.projectile_hit(projectile, cardinal_move, uncrossing) && !(thing_to_hit in hit_atoms))

//The actual bullet objects.
/obj/projectile
	name = "projectile"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "bullet"
	density = FALSE
	resistance_flags = RESIST_ALL
	anchored = TRUE //You will not have me, space wind!
	move_resist = INFINITY
	flags_atom = NOINTERACT //No real need for this, but whatever. Maybe this flag will do something useful in the future.
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_MAXIMUM // We want this thing to be invisible when it drops on a turf because it will be on the user's turf. We then want to make it visible as it travels.
	layer = FLY_LAYER
	animate_movement = NO_STEPS
	light_system = MOVABLE_LIGHT
	light_range = 1.5
	light_power = 2
	light_color = COLOR_VERY_SOFT_YELLOW

	///greyscale support
	greyscale_config = null
	greyscale_colors = null

	///Any special effects applied to this projectile
	var/flags_projectile_behavior = NONE

	var/hitsound = null
	var/datum/ammo/ammo //The ammo data which holds most of the actual info.

	var/def_zone = BODY_ZONE_CHEST	//So we're not getting empty strings.

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center
	var/apx //Pixel location in absolute coordinates. This is (((x - 1) * 32) + 16 + pixel_x)
	var/apy //These values are floats, not integers. They need to be converted through CEILING or such when translated to relative pixel coordinates.

	var/atom/shot_from 	 = null // the object which shot us
	var/turf/starting_turf = null // the projectile's starting turf
	var/atom/original_target = null // the original target clicked
	var/turf/original_target_turf = null // the original target's starting turf
	var/atom/firer 		 = null // Who shot it

	var/list/atom/movable/uncross_scheduled = list() // List of border movable atoms to check for when exiting a turf.

	var/damage = 0
	///ammo sundering value
	var/sundering = 0
	var/accuracy = 90 //Base projectile accuracy. Can maybe be later taken from the mob if desired.

	///how many damage points the projectile loses per tiles travelled
	var/damage_falloff = 0
	///Modifies projectile damage by a % when a marine gets passed, but not hit
	var/damage_marine_falloff = 0

	var/scatter = 0 //Chance of scattering, also maximum amount scattered. High variance.
	///damage airburst inflicts, as a multiplier of proj.damage
	var/airburst_multiplier = 0

	/// The iff signal that will be compared to the target's one, to apply iff if needed
	var/iff_signal = NONE

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
	///A damage multiplier applied when a mob from the same faction as the projectile firer is hit
	var/friendly_fire_multiplier = 0.5
	///The "point blank" range of the projectile. Inside this range the projectile gets a bonus to hit
	var/point_blank_range = 0
	/// List of atoms already hit by that projectile. Will only matter for projectiles capable of passing through multiple atoms
	var/list/atom/hit_atoms = list()

/obj/projectile/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)


/obj/projectile/Destroy()
	STOP_PROCESSING(SSprojectiles, src)
	ammo = null
	shot_from = null
	original_target = null
	uncross_scheduled = null
	original_target_turf = null
	starting_turf = null
	hit_atoms = list()
	return ..()


/obj/projectile/proc/on_cross(datum/source, atom/movable/AM, oldloc, oldlocs) //A mob moving on a tile with a projectile is hit by it.
	SIGNAL_HANDLER
	if(!PROJECTILE_HIT_CHECK(AM, src, get_dir(loc, oldloc), FALSE, hit_atoms))
		return
	AM.do_projectile_hit(src)
	if((!(ammo.flags_ammo_behavior & AMMO_PASS_THROUGH_MOVABLE)) || (!(ismob(AM) && CHECK_BITFIELD(ammo.flags_ammo_behavior, AMMO_PASS_THROUGH_MOB))) )
		qdel(src)
		return
	hit_atoms += AM

/obj/projectile/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_NERF_BEAM) && ammo.flags_ammo_behavior & AMMO_ENERGY)
		damage -= max(damage - ammo.damage * 0.5, 0)

/obj/projectile/proc/generate_bullet(ammo_datum, bonus_damage = 0, reagent_multiplier = 0)
	ammo = ispath(ammo_datum) ? GLOB.ammo_list[ammo_datum] : ammo_datum
	name = ammo.name
	point_blank_range = ammo.point_blank_range

	///sets greyscale for the projectile if it has been specified by the ammo datum
	if (ammo.projectile_greyscale_config && ammo.projectile_greyscale_colors)
		set_greyscale_config(ammo.projectile_greyscale_config)
		set_greyscale_colors(ammo.projectile_greyscale_colors)

	icon_state = ammo.icon_state
	damage = ammo.damage + bonus_damage //Mainly for emitters.
	penetration = ammo.penetration
	sundering = ammo.sundering
	scatter = ammo.scatter
	airburst_multiplier = ammo.airburst_multiplier
	accuracy   += ammo.accuracy
	accuracy   *= rand(95 - ammo.accuracy_var_low, 105 + ammo.accuracy_var_high) * 0.01 //Rand only works with integers.
	damage_falloff = ammo.damage_falloff
	armor_type = ammo.armor_type

//Target, firer, shot from. Ie the gun
/obj/projectile/proc/fire_at(atom/target, atom/shooter, atom/source, range, speed, angle, recursivity, suppress_light = FALSE, atom/loc_override = shooter)
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
	if(shooter && !firer)
		firer = shooter
	if(source)
		shot_from = source
	loc = loc_override
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

	if(ismob(firer) && !recursivity)
		var/mob/mob_firer = firer
		record_projectile_fire(mob_firer)
		GLOB.round_statistics.total_projectiles_fired[mob_firer.faction]++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "total_projectiles_fired[mob_firer.faction]")
		if(ammo.bonus_projectiles_amount)
			GLOB.round_statistics.total_projectiles_fired[mob_firer.faction] += ammo.bonus_projectiles_amount
			SSblackbox.record_feedback("tally", "round_statistics", ammo.bonus_projectiles_amount, "total_projectiles_fired[mob_firer.faction]")


	//If we have the the right kind of ammo, we can fire several projectiles at once.
	if(ammo.bonus_projectiles_amount && !recursivity) //Recursivity check in case the bonus projectiles have bonus projectiles of their own. Let's not loop infinitely.
		ammo.fire_bonus_projectiles(src, shooter, source, range, speed, dir_angle, target)

	if(shooter.Adjacent(target) && PROJECTILE_HIT_CHECK(target, src, null, FALSE, null)) //todo: doesn't take into account piercing projectiles
		target.do_projectile_hit(src)
		qdel(src)
		return

	var/matrix/rotate = matrix() //Change the bullet angle.
	rotate.Turn(dir_angle)
	transform = rotate

	var/first_move = min(projectile_speed, 1)
	var/first_moves = projectile_speed
	switch(projectile_batch_move(first_move))
		if(PROJECTILE_HIT) //Hit on first movement.
			if(!(flags_projectile_behavior & PROJECTILE_FROZEN))
				qdel(src)
			return
		if(PROJECTILE_FROZEN)
			invisibility = 0
			return
	invisibility = 0 //Let there be light (visibility).
	first_moves -= first_move
	switch(first_moves && projectile_batch_move(first_moves))
		if(PROJECTILE_HIT) //First movement batch happens on the same tick.
			if(!(flags_projectile_behavior & PROJECTILE_FROZEN))
				qdel(src)
			return
		if(PROJECTILE_FROZEN)
			return

	if(QDELETED(src))
		return

	if(!suppress_light && ammo.bullet_color)
		set_light_color(ammo.bullet_color)
		set_light_on(TRUE)

	START_PROCESSING(SSprojectiles, src) //If no hits on the first moves, enter the processing queue for next.


/obj/projectile/process()
	if(QDELETED(src))
		return PROCESS_KILL

	var/required_moves = required_moves_calc()
	if(!required_moves)
		return //Slowpoke. Maybe next tick.

	switch(projectile_batch_move(required_moves))
		if(PROJECTILE_HIT) //Hit on first movement.
			if(!(flags_projectile_behavior & PROJECTILE_FROZEN))
				qdel(src)
			return PROCESS_KILL
		if(PROJECTILE_FROZEN)
			return PROCESS_KILL

	if(QDELETED(src))
		return PROCESS_KILL

	if(ammo.flags_ammo_behavior & AMMO_SPECIAL_PROCESS)
		ammo.ammo_process(src, damage)

/obj/projectile/proc/required_moves_calc()
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

/obj/projectile/proc/projectile_batch_move(required_moves)
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
		if(dir != movement_dir)
			setDir(movement_dir)

		if(ISDIAGONALDIR(movement_dir)) //Diagonal case. We need to check the turf to cross to get there.
			if(!x_offset || !y_offset) //Unless a coder screws up this won't happen. Buf if they do it will cause an infinite processing loop due to division by zero, so better safe than sorry.
				stack_trace("projectile_batch_move called with diagonal movement_dir and offset-lacking. x_offset: [x_offset], y_offset: [y_offset].")
				return PROJECTILE_HIT
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
				if(!PROJECTILE_HIT_CHECK(thing_to_uncross, src, REVERSE_DIR(border_escaped_through), TRUE, hit_atoms))
					continue
				thing_to_uncross.do_projectile_hit(src)
				if((ammo.flags_ammo_behavior & AMMO_PASS_THROUGH_MOVABLE) || (ismob(thing_to_uncross) && CHECK_BITFIELD(ammo.flags_ammo_behavior, AMMO_PASS_THROUGH_MOB)) )
					hit_atoms += thing_to_uncross
					continue
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
			if(HAS_TRAIT(turf_crossed_by, TRAIT_TURF_BULLET_MANIPULATION))
				SEND_SIGNAL(turf_crossed_by, COMSIG_TURF_PROJECTILE_MANIPULATED, src)
				if(HAS_TRAIT_FROM(turf_crossed_by, TRAIT_TURF_BULLET_MANIPULATION, PORTAL_TRAIT))
					return
				RegisterSignal(turf_crossed_by, COMSIG_TURF_RESUME_PROJECTILE_MOVE, PROC_REF(resume_move))
				return PROJECTILE_FROZEN
			if(turf_crossed_by == original_target_turf && ammo.flags_ammo_behavior & AMMO_EXPLOSIVE)
				last_processed_turf = turf_crossed_by
				ammo.do_at_max_range(turf_crossed_by, src)
				if(border_escaped_through & (NORTH|SOUTH))
					x_pixel_dist_travelled += pixel_moves_until_crossing_x_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_x_border * y_offset
				else
					x_pixel_dist_travelled += pixel_moves_until_crossing_y_border * x_offset
					y_pixel_dist_travelled += pixel_moves_until_crossing_y_border * y_offset
				end_of_movement = i
				break
			movement_dir -= border_escaped_through //Next scan should come from the other component cardinal direction.
			for(var/j in uncross_scheduled) //We are leaving turf_crossed_by now.
				var/atom/movable/thing_to_uncross = j
				if(QDELETED(thing_to_uncross))
					continue
				if(!PROJECTILE_HIT_CHECK(thing_to_uncross, src, REVERSE_DIR(movement_dir), TRUE, hit_atoms))
					continue
				thing_to_uncross.do_projectile_hit(src)
				if( (ammo.flags_ammo_behavior & AMMO_PASS_THROUGH_MOVABLE) || (ismob(thing_to_uncross) && CHECK_BITFIELD(ammo.flags_ammo_behavior, AMMO_PASS_THROUGH_MOB)) )
					hit_atoms += thing_to_uncross
					continue
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
			if(ammo.flags_ammo_behavior & AMMO_LEAVE_TURF)
				ammo.on_leave_turf(turf_crossed_by, firer, src)
		if(length(uncross_scheduled)) //Time to exit the last turf entered, if the diagonal movement didn't handle it already.
			for(var/j in uncross_scheduled)
				var/atom/movable/thing_to_uncross = j
				if(QDELETED(thing_to_uncross))
					continue

				if(!PROJECTILE_HIT_CHECK(thing_to_uncross, src, REVERSE_DIR(movement_dir), TRUE, hit_atoms))
					continue //We act as if we were entering the tile through the opposite direction, to check for barricade blockage.
				thing_to_uncross.do_projectile_hit(src)
				if( (ammo.flags_ammo_behavior & AMMO_PASS_THROUGH_MOVABLE) || (ismob(thing_to_uncross) && CHECK_BITFIELD(ammo.flags_ammo_behavior, AMMO_PASS_THROUGH_MOB)) )
					hit_atoms += thing_to_uncross
					continue
				end_of_movement = i
				break
			uncross_scheduled.len = 0
			if(end_of_movement)
				break
		if(ammo.flags_ammo_behavior & AMMO_LEAVE_TURF)
			ammo.on_leave_turf(last_processed_turf, firer, src)
		x_pixel_dist_travelled += 32 * x_offset
		y_pixel_dist_travelled += 32 * y_offset
		last_processed_turf = next_turf
		if(scan_a_turf(next_turf, movement_dir))
			end_of_movement = i
			break
		if(HAS_TRAIT(next_turf, TRAIT_TURF_BULLET_MANIPULATION))
			SEND_SIGNAL(next_turf, COMSIG_TURF_PROJECTILE_MANIPULATED, src)
			if(HAS_TRAIT_FROM(next_turf, TRAIT_TURF_BULLET_MANIPULATION, PORTAL_TRAIT))
				return
			RegisterSignal(next_turf, COMSIG_TURF_RESUME_PROJECTILE_MOVE, PROC_REF(resume_move))
			return PROJECTILE_FROZEN
		if(next_turf == original_target_turf && ammo.flags_ammo_behavior & AMMO_EXPLOSIVE)
			ammo.do_at_max_range(next_turf, src)
			end_of_movement = i
			break
		if(distance_travelled >= proj_max_range)
			ammo.do_at_max_range(next_turf, src)
			end_of_movement = i
			break

	if(end_of_movement && last_processed_turf == loc)
		last_projectile_move = world.time
		return PROJECTILE_HIT

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
		return PROJECTILE_HIT
	return FALSE //No hits ...yet!

/obj/projectile/proc/scan_a_turf(turf/turf_to_scan, cardinal_move)
	if(turf_to_scan.density) //Handle wall hit.
		ammo.on_hit_turf(turf_to_scan, src)
		turf_to_scan.bullet_act(src)
		return !(ammo.flags_ammo_behavior & AMMO_PASS_THROUGH_TURF)

	if(shot_from)
		switch(SEND_SIGNAL(shot_from, COMSIG_PROJ_SCANTURF, turf_to_scan))
			if(COMPONENT_PROJ_SCANTURF_TURFCLEAR)
				return FALSE
			if(COMPONENT_PROJ_SCANTURF_TARGETFOUND)
				original_target.do_projectile_hit(src)
				return TRUE

	for(var/atom/movable/thing_to_hit in turf_to_scan)

		if(!PROJECTILE_HIT_CHECK(thing_to_hit, src, cardinal_move, FALSE, hit_atoms))
			continue

		thing_to_hit.do_projectile_hit(src)

		if((ismob(thing_to_hit) && CHECK_BITFIELD(ammo.flags_ammo_behavior, AMMO_PASS_THROUGH_MOB)) || CHECK_BITFIELD(ammo.flags_ammo_behavior, AMMO_PASS_THROUGH_MOVABLE))
			hit_atoms += thing_to_hit
			return FALSE

		return TRUE

	return FALSE

///Tells the projectile to move again
/obj/projectile/proc/resume_move(datum/source)
	SIGNAL_HANDLER
	if(source)
		UnregisterSignal(source, COMSIG_TURF_RESUME_PROJECTILE_MOVE)
	START_PROCESSING(SSprojectiles, src)


//----------------------------------------------------------
			//				    	\\
			//  HITTING THE TARGET  \\
			//						\\
			//						\\
//----------------------------------------------------------


//returns probability for the projectile to hit us.
/atom/proc/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	return FALSE

/atom/proc/do_projectile_hit(obj/projectile/proj)
	return


/obj/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(!density && !(obj_flags & PROJ_IGNORE_DENSITY)) //structure is passable
		return FALSE
	if(src == proj.original_target) //clicking on the structure itself hits the structure
		return TRUE
	if((allow_pass_flags & PASS_GLASS) && (proj.ammo.flags_ammo_behavior & AMMO_ENERGY))
		return FALSE
	if(!(allow_pass_flags & PASS_PROJECTILE))
		return TRUE
	if(proj.distance_travelled <= proj.ammo.barricade_clear_distance)
		return FALSE
	var/hit_chance = coverage //base chance for the projectile to hit the object instead of bypassing it
	if(flags_atom & ON_BORDER)
		if(!(cardinal_move & REVERSE_DIR(dir))) //The bullet will only hit if the barricade and its movement are facing opposite directions.
			if(!uncrossing)
				proj.uncross_scheduled += src
			return FALSE //No effect now, but we save the reference to check on exiting the tile.
		if (uncrossing)
			return FALSE //you don't hit the cade from behind.
	if(proj.ammo.flags_ammo_behavior & AMMO_SNIPER || proj.iff_signal || proj.ammo.flags_ammo_behavior & AMMO_ROCKET) //sniper, rockets and IFF rounds are better at getting past cover
		hit_chance *= 0.8
	///50% better protection when shooting from outside accurate range.
	if(proj.distance_travelled > proj.ammo.accurate_range)
		hit_chance *= 1.5
///Accuracy over 100 increases the chance of squeezing the bullet past the structure's uncovered areas.
	hit_chance = min(hit_chance , hit_chance + 100 - proj.accuracy)
	return prob(hit_chance)

/obj/do_projectile_hit(obj/projectile/proj)
	proj.ammo.on_hit_obj(src, proj)
	if(QDELETED(src)) //on_hit_obj could delete the object
		return
	bullet_act(proj)

/obj/machinery/deployable/mounted/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(operator?.wear_id.iff_signal & proj.iff_signal)
		return FALSE
	if(src == proj.original_target)
		return TRUE
	if(density)
		return ..()

	var/hit_chance = coverage
	hit_chance = min(hit_chance , hit_chance + 100 - proj.accuracy)
	return prob(hit_chance)

/obj/machinery/deployable/mounted/sentry/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(proj.iff_signal & iff_signal)
		return FALSE
	return ..()

/obj/machinery/door/poddoor/railing/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	return src == proj.original_target

/obj/alien/egg/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	return src == proj.original_target

/obj/structure/xeno/trap/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	return src == proj.original_target

/obj/item/clothing/mask/facehugger/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	return src == proj.original_target

/obj/vehicle/unmanned/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(proj.firer == src)
		return FALSE
	if(iff_signal & proj.iff_signal)
		proj.damage -= proj.damage*proj.damage_marine_falloff
		return FALSE
	return TRUE

/obj/vehicle/ridden/motorbike/projectile_hit(obj/projectile/P)
	if(!buckled_mobs)
		return ..()
	var/mob/buckled_mob = pick(buckled_mobs)
	return src == buckled_mob

/mob/living/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(status_flags & INCORPOREAL)
		return FALSE
	if(proj.firer == src)
		return FALSE
	if(lying_angle && src != proj.original_target)
		return FALSE
	if((proj.ammo.flags_ammo_behavior & AMMO_XENO) && (isnestedhost(src) || stat == DEAD))
		return FALSE
	if(pass_flags & PASS_PROJECTILE) //he's beginning to believe
		return FALSE

	//We want a temporary variable so accuracy doesn't change every time the bullet misses.
	var/hit_chance = proj.accuracy
	BULLET_DEBUG("Base accuracy is <b>[hit_chance]; scatter:[proj.scatter]; distance:[proj.distance_travelled]</b>")

	hit_chance += (mob_size - 1) * 20 //You're easy to hit when you're swoll, hard to hit when you're a manlet

	///Is the shooter a living mob. Defined before the check as used later as well
	var/mob/living/shooter_living
	if(isliving(proj.firer))
		shooter_living = proj.firer
		if(shooter_living.faction == faction)
			hit_chance = round(hit_chance*0.85) //You (presumably) aren't trying to shoot your friends
		var/obj/item/shot_source = proj.shot_from
		if(!line_of_sight(shooter_living, src, 9) && (!istype(shot_source) || !shot_source.zoom)) //if you can't draw LOS within 9 tiles (to accomodate wide screen), AND the source was either not zoomed or not an item(like a xeno)
			BULLET_DEBUG("Can't see target ([round(hit_chance*0.8)]).")
			hit_chance = round(hit_chance*0.8) //Can't see the target (Opaque thing between shooter and target), or out of view range

	if(proj.distance_travelled <= proj.ammo.accurate_range) //If bullet stays within max accurate range.
		if(proj.distance_travelled <= proj.point_blank_range) //If bullet within point blank range, big accuracy buff.
			BULLET_DEBUG("Point blank range (+30)")
			hit_chance += 30
		else if(proj.distance_travelled <= proj.ammo.accurate_range_min) //Snipers have accuracy falloff at closer range UNLESS in point blank range
			BULLET_DEBUG("Sniper ammo, too close (-[min(100, hit_chance) - (proj.ammo.accurate_range_min - proj.distance_travelled) * 10])")
			hit_chance = min(100, hit_chance) //excess accuracy doesn't help within minimum accurate range
			hit_chance -= (proj.ammo.accurate_range_min - proj.distance_travelled) * 10 //The further inside minimum accurate range, the greater the penalty
	else
		BULLET_DEBUG("Too far (+[((proj.distance_travelled - proj.ammo.accurate_range )* 5)])")
		hit_chance -= ((proj.distance_travelled - proj.ammo.accurate_range )* 5) //Every tile travelled past accurate_range reduces accuracy

	BULLET_DEBUG("Hit zone penalty (-[GLOB.base_miss_chance[proj.def_zone]]) ([proj.def_zone])")
	hit_chance -= GLOB.base_miss_chance[proj.def_zone] //Reduce accuracy based on body part targeted.

	if(last_move_intent > world.time - 2 SECONDS) //You're harder to hit if you're moving
		///accumulated movement related evasion bonus
		var/evasion_bonus
		if(ishuman(src))
			var/mob/living/carbon/human/target_human = src
			if(target_human.mobility_aura)
				evasion_bonus += max(5, (target_human.mobility_aura * 5)) //you get a bonus if you've got an active mobility order effecting you
		evasion_bonus += (25 - (min(25, cached_multiplicative_slowdown * 5))) //The lower your slowdown, the better your chance to dodge, but it won't make you easier to hit if you have huge slowdown
		evasion_bonus = (100 - evasion_bonus) / 100 //turn it into a multiplier
		BULLET_DEBUG("Moving (*[evasion_bonus]).")
		hit_chance = round(hit_chance * evasion_bonus)

	if(proj.ammo.flags_ammo_behavior & AMMO_UNWIELDY)
		hit_chance *= 0.5

	hit_chance = max(5, hit_chance) //It's never impossible to hit

	BULLET_DEBUG("Final accuracy is <b>[hit_chance]</b>")

	var/hit_roll = rand(0, 99) //Our randomly generated roll

	if(hit_chance > hit_roll) //Hit
		//friendly fire reduces the damage of the projectile, so only applies the multiplier if a hit is confirmed
		if(shooter_living?.faction == faction)
			proj.damage *= proj.friendly_fire_multiplier
		if(hit_roll > (hit_chance-25)) //if you hit by a small margin, you hit a random bodypart instead of what you were aiming for
			proj.def_zone = pick(GLOB.base_miss_chance)
		return TRUE

	if(!lying_angle) //Narrow miss!
		animatation_displace_reset(src)
		if(proj.ammo.sound_miss)
			var/pitch = 0
			if(proj.ammo.flags_ammo_behavior & AMMO_SOUND_PITCH)
				pitch = 55000
			playsound_local(get_turf(src), proj.ammo.sound_miss, 75, 1, frequency = pitch)

	return FALSE


/mob/living/do_projectile_hit(obj/projectile/proj)
	proj.ammo.on_hit_mob(src, proj)
	bullet_act(proj)

/mob/living/carbon/do_projectile_hit(obj/projectile/proj)
	. = ..()
	if(!(species?.species_flags & NO_BLOOD) && proj.ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		var/angle = !isnull(proj.dir_angle) ? proj.dir_angle : round(Get_Angle(proj.starting_turf, src), 1)
		new /obj/effect/temp_visual/dir_setting/bloodsplatter(loc, angle, get_blood_color())


/mob/living/carbon/human/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(wear_id?.iff_signal & proj.iff_signal)
		proj.damage -= proj.damage*proj.damage_marine_falloff
		return FALSE
	return ..()


/mob/living/carbon/xenomorph/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(CHECK_BITFIELD(xeno_iff_check(), proj.iff_signal))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_XENO_PROJECTILE_HIT, proj, cardinal_move, uncrossing) & COMPONENT_PROJECTILE_DODGE)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_BURROWED))
		return FALSE
	if(proj.ammo.flags_ammo_behavior & AMMO_SKIPS_ALIENS)
		return FALSE
	return ..()


/obj/projectile/proc/play_damage_effect(mob/M)
	if(ammo.sound_hit) playsound(M, ammo.sound_hit, 50, 1)
	if(M.stat != DEAD) animation_flash_color(M)

//----------------------------------------------------------
				//				    \\
				//    OTHER PROCS	\\
				//					\\
				//					\\
//----------------------------------------------------------

/atom/proc/bullet_act(obj/projectile/proj)
	SHOULD_CALL_PARENT(TRUE)
	if(HAS_TRAIT(proj, TRAIT_PROJ_HIT_SOMETHING))
		proj.damage *= proj.ammo.on_pierce_multiplier
		proj.penetration *= proj.ammo.on_pierce_multiplier
		proj.sundering *= proj.ammo.on_pierce_multiplier
	ADD_TRAIT(proj, TRAIT_PROJ_HIT_SOMETHING, BULLET_ACT_TRAIT)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, proj)


/mob/living/bullet_act(obj/projectile/proj)
	. = ..()

	if(stat == DEAD)
		return

	var/damage = max(0, proj.damage - round(proj.distance_travelled * proj.damage_falloff))
	if(!damage)
		return

	damage = check_shields(COMBAT_PROJ_ATTACK, damage, proj.ammo.armor_type, FALSE, proj.penetration)
	if(!damage)
		proj.ammo.on_shield_block(src, proj)
		return

	if(!damage)
		return

	flash_weak_pain()

	var/feedback_flags = NONE

	if(proj.shot_from && src == proj.shot_from.sniper_target(src))
		damage *= SNIPER_LASER_DAMAGE_MULTIPLIER

	if(iscarbon(proj.firer))
		var/mob/living/carbon/shooter_carbon = proj.firer
		if(shooter_carbon.IsStaggered())
			damage *= STAGGER_DAMAGE_MULTIPLIER //Since we hate RNG, stagger reduces damage by a % instead of reducing accuracy; consider it a 'glancing' hit due to being disoriented.
	var/original_damage = damage
	damage = modify_by_armor(damage, proj.armor_type, proj.penetration, proj.def_zone)
	if(damage == original_damage)
		feedback_flags |= BULLET_FEEDBACK_PEN
	else if(!damage)
		feedback_flags |= BULLET_FEEDBACK_SOAK
		bullet_soak_effect(proj)

	if(proj.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
		adjust_fire_stacks(proj.ammo.incendiary_strength)
		if(IgniteMob())
			feedback_flags |= (BULLET_FEEDBACK_FIRE)

	if(proj.ammo.flags_ammo_behavior & AMMO_SUNDERING)
		adjust_sunder(proj.sundering)

	if(stat != DEAD && ismob(proj.firer))
		record_projectile_damage(proj.firer, damage)	//Tally up whoever the shooter was

	if(damage)
		if(do_shrapnel_roll(proj, damage))
			feedback_flags |= (BULLET_FEEDBACK_SHRAPNEL|BULLET_FEEDBACK_SCREAM)
			embed_projectile_shrapnel(proj)
		else if(prob(damage * 0.25))
			feedback_flags |= BULLET_FEEDBACK_SCREAM
		bullet_message(proj, feedback_flags, damage)
		proj.play_damage_effect(src)
		apply_damage(damage, proj.ammo.damage_type, proj.def_zone, updating_health = TRUE) //This could potentially delete the source.
	else
		bullet_message(proj, feedback_flags)

	GLOB.round_statistics.total_projectile_hits[faction]++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_projectile_hits[faction]")

	return TRUE

/mob/living/carbon/xenomorph/bullet_act(obj/projectile/proj)
	if(issamexenohive(proj.firer)) //Aliens won't be harming allied aliens.
		return

	return ..()

/obj/projectile/hitscan
	///The icon of the laser beam that will be created
	var/effect_icon = "beam"

/obj/projectile/hitscan/Initialize(mapload, effect_icon)
	. = ..()
	if(effect_icon)
		src.effect_icon = effect_icon

/obj/projectile/hitscan/fire_at(atom/target, atom/shooter, atom/source, range, speed, angle, recursivity, suppress_light, atom/loc_override = shooter)
	if(!isnull(range))
		proj_max_range = range
	if(shooter)
		firer = shooter
	if(source)
		shot_from = source
	loc = loc_override
	if(!isturf(loc))
		forceMove(get_turf(src))
	starting_turf = loc

	if(target)
		original_target = target
		original_target_turf = get_turf(target)

	apx = ABS_COOR(x) //Set the absolute coordinates. Center of a tile is assumed to be (16,16)
	apy = ABS_COOR(y)
	if(!angle && target)
		dir_angle = round(Get_Pixel_Angle((ABS_COOR(target.x) - apx), (ABS_COOR(target.y) - apy))) //Using absolute pixel coordinates.
	else
		dir_angle = angle

	if(!recursivity)	//Recursivity check in case the bonus projectiles have bonus projectiles of their own. Let's not loop infinitely.
		record_projectile_fire(shooter)

		//If we have the the right kind of ammo, we can fire several projectiles at once.
		if(ammo.bonus_projectiles_amount)
			ammo.fire_bonus_projectiles(src, shooter, source, range, speed, dir_angle, target)

	if(shooter.Adjacent(target) && ismob(target))
		var/mob/mob_to_hit = target
		ammo.on_hit_mob(mob_to_hit, src)
		mob_to_hit.bullet_act(src)
		qdel(src)
		return

	x_offset = round(sin(dir_angle), 0.01)
	y_offset = round(cos(dir_angle), 0.01)
	if(projectile_batch_move(!recursivity) == PROJECTILE_FROZEN || (flags_projectile_behavior & PROJECTILE_FROZEN))
		var/atom/movable/hitscan_projectile_effect/laser_effect = new /atom/movable/hitscan_projectile_effect(PROJ_ABS_PIXEL_TO_TURF(apx, apy, z), dir_angle, apx % 32 - 16, apy % 32 - 16, 1.01, effect_icon, ammo.bullet_color)
		RegisterSignal(loc, COMSIG_TURF_RESUME_PROJECTILE_MOVE, PROC_REF(resume_move))
		laser_effect.RegisterSignal(loc, COMSIG_TURF_RESUME_PROJECTILE_MOVE, TYPE_PROC_REF(/atom/movable/hitscan_projectile_effect, remove_effect))
		laser_effect.RegisterSignal(src, COMSIG_QDELETING, TYPE_PROC_REF(/atom/movable/hitscan_projectile_effect, remove_effect))
		return
	qdel(src)

/obj/projectile/hitscan/projectile_batch_move(first_projectile = TRUE)
	var/end_of_movement = FALSE //In batch moves this loop, only if the projectile stopped.
	var/turf/last_processed_turf = loc
	var/list/atom/movable/hitscan_projectile_effect/laser_effects = list()
	while(!end_of_movement)
		distance_travelled++
		//Here we take the projectile's absolute pixel coordinate + the travelled distance and use PROJ_ABS_PIXEL_TO_TURF to first convert it into tile coordinates, and then use those to locate the turf.
		var/turf/next_turf = PROJ_ABS_PIXEL_TO_TURF((apx + (32 * x_offset)), (apy + (32 * y_offset)), z)
		if(!next_turf) //Map limit.
			end_of_movement = TRUE
			break
		apx += 32 * x_offset
		apy += 32 * y_offset

		if(apx % 32 == 0) // This is god damn right awfull, but PROJ_ABS_PIXEL_TO_TURF panic when this happens
			apx += 0.1
		if(apy % 32 == 0)
			apy += 0.1

		if(next_turf == last_processed_turf)
			laser_effects += new /atom/movable/hitscan_projectile_effect(PROJ_ABS_PIXEL_TO_TURF(apx, apy, z), dir_angle, apx % 32 - 16, apy % 32 - 16, 1.1, effect_icon, ammo.bullet_color)
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
					pixel_moves_until_crossing_x_border = CEILING(((33 - ABS_PIXEL_TO_REL(apx)) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((33 - ABS_PIXEL_TO_REL(apy)) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border) //Escapes vertically.
						border_escaped_through = NORTH
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border) //Escapes horizontally.
						border_escaped_through = EAST
					else //Escapes both borders at the same time, perfectly diagonal.
						border_escaped_through = pick(NORTH, EAST) //So choose at random to preserve behavior of no purely diagonal movements allowed.
				if(SOUTHEAST)
					pixel_moves_until_crossing_x_border = CEILING(((33 - ABS_PIXEL_TO_REL(apx)) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((0 - ABS_PIXEL_TO_REL(apy)) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border)
						border_escaped_through = SOUTH
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border)
						border_escaped_through = EAST
					else
						border_escaped_through = pick(SOUTH, EAST)
				if(SOUTHWEST)
					pixel_moves_until_crossing_x_border = CEILING(((0 - ABS_PIXEL_TO_REL(apx)) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((0 - ABS_PIXEL_TO_REL(apy)) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border)
						border_escaped_through = SOUTH
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border)
						border_escaped_through = WEST
					else
						border_escaped_through = pick(SOUTH, WEST)
				if(NORTHWEST)
					pixel_moves_until_crossing_x_border = CEILING(((0 - ABS_PIXEL_TO_REL(apx)) / x_offset), 1)
					pixel_moves_until_crossing_y_border = CEILING(((33 - ABS_PIXEL_TO_REL(apy)) / y_offset), 1)
					if(pixel_moves_until_crossing_y_border < pixel_moves_until_crossing_x_border)
						border_escaped_through = NORTH
					else if(pixel_moves_until_crossing_x_border < pixel_moves_until_crossing_y_border)
						border_escaped_through = WEST
					else
						border_escaped_through = pick(NORTH, WEST)
			turf_crossed_by = get_step(last_processed_turf, border_escaped_through)
			for(var/atom/movable/thing_to_uncross AS in uncross_scheduled)
				if(QDELETED(thing_to_uncross))
					continue
				if(!PROJECTILE_HIT_CHECK(thing_to_uncross, src, REVERSE_DIR(border_escaped_through), TRUE, hit_atoms))
					continue
				thing_to_uncross.do_projectile_hit(src)
				if( (ammo.flags_ammo_behavior & AMMO_PASS_THROUGH_MOVABLE) || (ismob(thing_to_uncross) && CHECK_BITFIELD(ammo.flags_ammo_behavior, AMMO_PASS_THROUGH_MOB)) )
					hit_atoms += thing_to_uncross
					continue
				end_of_movement = TRUE
				break
			uncross_scheduled.Cut()
			if(end_of_movement)
				break
			if(scan_a_turf(turf_crossed_by, border_escaped_through))
				break
			if(turf_crossed_by == original_target_turf && ammo.flags_ammo_behavior & AMMO_EXPLOSIVE)
				last_processed_turf = turf_crossed_by
				ammo.do_at_max_range(turf_crossed_by, src)
				end_of_movement = TRUE
				break
			if(HAS_TRAIT(turf_crossed_by, TRAIT_TURF_BULLET_MANIPULATION))
				SEND_SIGNAL(turf_crossed_by, COMSIG_TURF_PROJECTILE_MANIPULATED, src)
				QDEL_LIST_IN(laser_effects, 2)
				if(HAS_TRAIT_FROM(turf_crossed_by, TRAIT_TURF_BULLET_MANIPULATION, PORTAL_TRAIT))
					return
				forceMove(turf_crossed_by)
				return PROJECTILE_FROZEN
			for(var/atom/movable/thing_to_uncross AS in uncross_scheduled) //We are leaving turf_crossed_by now.
				if(QDELETED(thing_to_uncross))
					continue
				if(!PROJECTILE_HIT_CHECK(thing_to_uncross, src, REVERSE_DIR(movement_dir), TRUE, hit_atoms))
					continue
				thing_to_uncross.do_projectile_hit(src)
				if( (ammo.flags_ammo_behavior & AMMO_PASS_THROUGH_MOVABLE) || (ismob(thing_to_uncross) && CHECK_BITFIELD(ammo.flags_ammo_behavior, AMMO_PASS_THROUGH_MOB)) )
					hit_atoms += thing_to_uncross
					continue
				end_of_movement = TRUE
				break
			uncross_scheduled.Cut()
			if(end_of_movement)
				break
			if(ammo.flags_ammo_behavior & AMMO_LEAVE_TURF)
				ammo.on_leave_turf(turf_crossed_by, firer, src)
		if(length(uncross_scheduled)) //Time to exit the last turf entered, if the diagonal movement didn't handle it already.
			for(var/atom/movable/thing_to_uncross AS in uncross_scheduled)
				if(QDELETED(thing_to_uncross))
					continue
				if(!PROJECTILE_HIT_CHECK(thing_to_uncross, src, REVERSE_DIR(movement_dir), TRUE, hit_atoms))
					continue //We act as if we were entering the tile through the opposite direction, to check for barricade blockage.
				thing_to_uncross.do_projectile_hit(src)
				if( (ammo.flags_ammo_behavior & AMMO_PASS_THROUGH_MOVABLE) || (ismob(thing_to_uncross) && CHECK_BITFIELD(ammo.flags_ammo_behavior, AMMO_PASS_THROUGH_MOB)) )
					hit_atoms += thing_to_uncross
					continue
				end_of_movement = TRUE
				break
			uncross_scheduled.len = 0
			if(end_of_movement)
				break
		if(ammo.flags_ammo_behavior & AMMO_LEAVE_TURF)
			ammo.on_leave_turf(last_processed_turf, firer, src)
		last_processed_turf = next_turf
		if(scan_a_turf(next_turf, movement_dir))
			end_of_movement = TRUE
			break
		if(next_turf == original_target_turf && ammo.flags_ammo_behavior & AMMO_EXPLOSIVE)
			ammo.do_at_max_range(next_turf, src)
			end_of_movement = TRUE
			break
		if(distance_travelled >= proj_max_range)
			ammo.do_at_max_range(next_turf, src)
			end_of_movement = TRUE
			break
		if(HAS_TRAIT(next_turf, TRAIT_TURF_BULLET_MANIPULATION))
			SEND_SIGNAL(next_turf, COMSIG_TURF_PROJECTILE_MANIPULATED, src)
			QDEL_LIST_IN(laser_effects, 2)
			if(HAS_TRAIT_FROM(next_turf, TRAIT_TURF_BULLET_MANIPULATION, PORTAL_TRAIT))
				return
			forceMove(next_turf)
			return PROJECTILE_FROZEN
		if(first_projectile)
			laser_effects += new /atom/movable/hitscan_projectile_effect(PROJ_ABS_PIXEL_TO_TURF(apx, apy, z), dir_angle, apx % 32 - 16, apy % 32 - 16, 1.01, "muzzle_"+effect_icon, ammo.bullet_color)
			first_projectile = FALSE
		else
			laser_effects += new /atom/movable/hitscan_projectile_effect(PROJ_ABS_PIXEL_TO_TURF(apx, apy, z), dir_angle, apx % 32 - 16, apy % 32 - 16, 1.01, effect_icon, ammo.bullet_color)
	apx -= 8 * x_offset
	apy -= 8 * y_offset

	if(apx % 32 == 0)
		apx += 0.1
	if(apy % 32 == 0)
		apy += 0.1
	if(first_projectile)
		laser_effects += new /atom/movable/hitscan_projectile_effect(PROJ_ABS_PIXEL_TO_TURF(apx, apy, z), dir_angle, apx % 32 - 16, apy % 32 - 16, 1.01, "muzzle_"+effect_icon, ammo.bullet_color)
	laser_effects += new /atom/movable/hitscan_projectile_effect(PROJ_ABS_PIXEL_TO_TURF(apx, apy, z), dir_angle, apx % 32 - 16, apy % 32 - 16, 1.01, "impact_"+effect_icon, ammo.bullet_color)
	QDEL_LIST_IN(laser_effects, 2)

/obj/projectile/hitscan/resume_move(datum/source)
	UnregisterSignal(source, COMSIG_TURF_RESUME_PROJECTILE_MOVE)
	projectile_batch_move(FALSE)
	qdel(src)

/mob/living/proc/embed_projectile_shrapnel(obj/projectile/proj)
	var/obj/item/shard/shrapnel/shrap = new(get_turf(src), "[proj] shrapnel", " It looks like it was fired from [proj.shot_from ? proj.shot_from : "something unknown"].")
	if(!shrap.embed_into(src, proj.def_zone, TRUE))
		qdel(shrap)


/mob/living/carbon/human/embed_projectile_shrapnel(obj/projectile/proj)
	var/datum/limb/affected_limb = get_limb(check_zone(proj.def_zone))
	if(affected_limb.limb_status & (LIMB_DESTROYED|LIMB_ROBOT))
		return
	return ..()

/mob/living/proc/bullet_soak_effect(obj/projectile/proj)
	return

/mob/living/carbon/human/bullet_soak_effect(obj/projectile/proj)
	if(!proj.ammo.sound_armor)
		return ..()
	playsound(src, proj.ammo.sound_armor, 50, TRUE)


/mob/living/proc/do_shrapnel_roll(obj/projectile/proj, damage)
	return FALSE


/mob/living/carbon/human/do_shrapnel_roll(obj/projectile/proj, damage)
	return (!(SSticker.mode?.flags_round_type & MODE_NO_PERMANENT_WOUNDS) && proj.ammo.shrapnel_chance && prob(proj.ammo.shrapnel_chance + damage * 0.1))


//Turf handling.
/turf/bullet_act(obj/projectile/proj)
	. = ..()

	var/list/mob_list = list() //Let's built a list of mobs on the bullet turf and grab one.
	for(var/mob/possible_target in src)
		mob_list += possible_target

	if(!length(mob_list))
		return FALSE

	var/mob/picked_mob = pick(mob_list)
	if(proj.projectile_hit(picked_mob))
		picked_mob.bullet_act(proj)
		return TRUE
	return FALSE

// walls can get shot and damaged, but bullets do much less.
/turf/closed/wall/bullet_act(obj/projectile/proj)
	. = ..()
	if(.)
		return

	var/damage

	switch(proj.ammo.damage_type)
		if(BRUTE, BURN)
			damage = max(0, proj.damage - round(proj.distance_travelled * proj.damage_falloff))
			damage = round(modify_by_armor(damage, proj.armor_type, proj.penetration), 1)
		else
			return FALSE

	if(damage < 1)
		return FALSE

	if(proj.ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		current_bulletholes++

	if(prob(30))
		visible_message(span_warning("[src] is damaged by [proj]!"), visible_message_flags = COMBAT_MESSAGE)
	take_damage(damage)
	return TRUE


//----------------------------------------------------------
					//				    \\
					//    OTHER PROCS	\\
					//					\\
					//					\\
//----------------------------------------------------------

#define BULLET_MESSAGE_NO_SHOOTER 0
#define BULLET_MESSAGE_HUMAN_SHOOTER 1
#define BULLET_MESSAGE_OTHER_SHOOTER 2

/mob/living/proc/bullet_message(obj/projectile/proj, feedback_flags, damage)
	if(!proj.firer)
		log_message("SOMETHING?? shot [key_name(src)] with a [proj]", LOG_ATTACK)
		return BULLET_MESSAGE_NO_SHOOTER
	var/turf/T = get_turf(proj.firer)
	log_combat(proj.firer, src, "shot", proj, "in [AREACOORD(T)]")
	if(ishuman(proj.firer))
		return BULLET_MESSAGE_HUMAN_SHOOTER
	return BULLET_MESSAGE_OTHER_SHOOTER


/mob/living/carbon/human/bullet_message(obj/projectile/proj, feedback_flags, damage)
	. = ..()
	var/list/victim_feedback = list()
	if(proj.ammo.flags_ammo_behavior & AMMO_IS_SILENCED)
		victim_feedback += "You've been shot in the [parse_zone(proj.def_zone)] by [proj]!"
	else
		victim_feedback += "You are hit by [proj] in the [parse_zone(proj.def_zone)]!"

	if(feedback_flags & BULLET_FEEDBACK_IMMUNE)
		victim_feedback += "Your armor deflects the impact!"
	else if(feedback_flags & BULLET_FEEDBACK_SOAK)
		victim_feedback += "Your armor absorbs the impact!"
	else
		if(feedback_flags & BULLET_FEEDBACK_PEN)
			victim_feedback += "Your armor was penetrated!"
		if(feedback_flags & BULLET_FEEDBACK_SHRAPNEL)
			victim_feedback += "The impact sends <b>shrapnel</b> into the wound!"

	if(feedback_flags & BULLET_FEEDBACK_FIRE)
		victim_feedback += "You burst into <b>flames!!</b> Stop drop and roll!"

	if(!client?.prefs.mute_self_combat_messages)
		to_chat(src, span_highdanger("[victim_feedback.Join(" ")]"))

	if(feedback_flags & BULLET_FEEDBACK_SCREAM && stat == CONSCIOUS && !(species.species_flags & NO_PAIN))
		emote("scream")

	if(. != BULLET_MESSAGE_HUMAN_SHOOTER)
		return
	var/mob/living/carbon/human/firingMob = proj.firer
	if(!firingMob.mind?.bypass_ff && !mind?.bypass_ff && firingMob.faction == faction && proj.ammo.damage_type != STAMINA)
		var/turf/T = get_turf(firingMob)
		firingMob.ff_check(damage, src)
		log_ffattack("[key_name(firingMob)] shot [key_name(src)] with [proj] in [AREACOORD(T)].")
		msg_admin_ff("[ADMIN_TPMONTY(firingMob)] shot [ADMIN_TPMONTY(src)] with [proj] in [ADMIN_VERBOSEJMP(T)].")


/mob/living/carbon/xenomorph/bullet_message(obj/projectile/proj, feedback_flags, damage)
	. = ..()
	var/list/victim_feedback
	if(proj.ammo.flags_ammo_behavior & AMMO_IS_SILENCED)
		victim_feedback = list("We've been shot in the [parse_zone(proj.def_zone)] by [proj]!")
	else
		victim_feedback = list("We are hit by the [proj] in the [parse_zone(proj.def_zone)]!")

	if(feedback_flags & BULLET_FEEDBACK_IMMUNE)
		victim_feedback += "Our exoskeleton deflects it!"
	else if(feedback_flags & BULLET_FEEDBACK_SOAK)
		victim_feedback += "Our exoskeleton absorbs it!"
	else if(feedback_flags & BULLET_FEEDBACK_PEN)
		victim_feedback += "Our exoskeleton was penetrated!"

	if(feedback_flags & BULLET_FEEDBACK_FIRE)
		victim_feedback += "We burst into flames!! Auuugh! Resist to put out the flames!"

	if(feedback_flags & BULLET_FEEDBACK_SCREAM && stat == CONSCIOUS)
		emote(prob(70) ? "hiss" : "roar")

	if(!client?.prefs.mute_self_combat_messages)
		to_chat(src, span_highdanger("[victim_feedback.Join(" ")]"))

// Sundering procs
/mob/living/proc/adjust_sunder(adjustment)
	return 0

/mob/living/proc/set_sunder(new_sunder)
	return FALSE

/mob/living/proc/get_sunder()
	return 0

#undef BULLET_FEEDBACK_PEN
#undef BULLET_FEEDBACK_SOAK
#undef BULLET_FEEDBACK_FIRE
#undef BULLET_FEEDBACK_SCREAM
#undef BULLET_FEEDBACK_SHRAPNEL
#undef BULLET_FEEDBACK_IMMUNE

#undef BULLET_MESSAGE_NO_SHOOTER
#undef BULLET_MESSAGE_HUMAN_SHOOTER
#undef BULLET_MESSAGE_OTHER_SHOOTER

#undef DEBUG_HIT_CHANCE
#undef DEBUG_HUMAN_DEFENSE
#undef DEBUG_XENO_DEFENSE

#undef PROJ_ABS_PIXEL_TO_TURF
#undef PROJ_ANIMATION_SPEED
