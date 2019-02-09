//Some debug variables. Toggle them to 1 in order to see the related debug messages. Helpful when testing out formulas.
#define DEBUG_HIT_CHANCE	FALSE
#define DEBUG_HUMAN_DEFENSE	FALSE
#define DEBUG_XENO_DEFENSE	FALSE
#define DEBUG_CREST_DEFENSE	0

#define MOVES_HITSCAN -1		//Not actually hitscan but close as we get without actual hitscan.
#define MUZZLE_EFFECT_PIXEL_INCREMENT 17	//How many pixels to move the muzzle flash up so your character doesn't look like they're shitting out lasers.

/obj/item/projectile
	name = "projectile (contact coders if you see this)"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "bullet"
	density = FALSE
	anchored = TRUE
	unacidable = TRUE
	flags_atom = NOINTERACT
	flags_item = ITEM_ABSTRACT
	flags_pass = PASSTABLE
	mouse_opacity = 0
	hitsound = 'sound/weapons/pierce.ogg'
	var/hitsound_wall = ""
	layer = FLY_LAYER
	
	var/current = null // this is never used, but it was never used in the old code
	var/distance_travelled
	var/scatter
	var/datum/ammo/ammo
	var/projectile_speed
	
	var/def_zone = ""	//Aiming at
	var/atom/firer = null//Who shot it
	var/suppressed = FALSE	//Attack message
	var/yo = null
	var/xo = null
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/turf/target_turf = null
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again
	var/p_x = 16
	var/p_y = 16			// the pixel location of the tile that the player clicked. Default is the center
	
	//Fired processing vars
	var/fired = FALSE	//Have we been fired yet
	var/paused = FALSE	//for suspending the projectile midair
	var/last_projectile_move = 0
	var/last_process = 0
	var/time_offset = 0
	var/datum/point/vector/trajectory
	var/trajectory_ignore_forcemove = FALSE	//instructs forceMove to NOT reset our trajectory to the new location!

	var/speed = 100000			//Amount of deciseconds it takes for projectile to travel
	var/Angle = 0
	var/original_angle = 0		//Angle at firing
	var/nondirectional_sprite = FALSE //Set TRUE to prevent projectiles from having their sprites rotated based on firing angle
	var/spread = 0			//amount (in degrees) of projectile spread
	animate_movement = 0	//Use SLIDE_STEPS in conjunction with legacy
	var/ricochets = 0
	var/ricochets_max = 2
	var/ricochet_chance = 30

	//Hitscan
	var/hitscan = FALSE		//Whether this is hitscan. If it is, speed is basically ignored.
	var/list/beam_segments	//assoc list of datum/point or datum/point/vector, start = end. Used for hitscan effect generation.
	var/datum/point/beam_index
	var/turf/hitscan_last	//last turf touched during hitscanning.
	var/tracer_type
	var/muzzle_type
	var/impact_type

	//Fancy hitscan lighting effects!
	var/hitscan_light_intensity = 1.5
	var/hitscan_light_range = 0.75
	var/hitscan_light_color_override
	var/muzzle_flash_intensity = 3
	var/muzzle_flash_range = 1.5
	var/muzzle_flash_color_override
	var/impact_light_intensity = 3
	var/impact_light_range = 2
	var/impact_light_color_override

	//Homing
	var/homing = FALSE
	var/atom/homing_target
	var/homing_turn_speed = 10		//Angle per tick.
	var/homing_inaccuracy_min = 0		//in pixels for these. offsets are set once when setting target.
	var/homing_inaccuracy_max = 0
	var/homing_offset_x = 0
	var/homing_offset_y = 0

	var/ignore_source_check = FALSE

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb
	var/projectile_type = /obj/item/projectile
	var/range = 50 //This will de-increment every step. When 0, it will deletze the projectile.
	var/decayedRange
	var/is_reflectable = FALSE // Can it be reflected or not?
	var/damage_falloff = 0
	var/armor_type = null
	var/accuracy = 85
	
	//Effects
	var/stun = 0
	var/knockdown = 0
	var/paralyze = 0
	var/immobilize = 0
	var/unconscious = 0
	var/irradiate = 0
	var/stutter = 0
	var/slur = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/stamina = 0
	var/jitter = 0
	var/forcedodge = 0 //to pass through everything
	var/dismemberment = 0 //The higher the number, the greater the bonus to dismembering. 0 will not dismember at all.
	var/impact_effect_type //what type of impact effect to show when hitting something
	var/log_override = FALSE //is this type spammed enough to not log? (KAs)

/obj/item/projectile/Initialize()
	. = ..()
	message_admins("Init")
	permutated = list()
	decayedRange = range

/obj/item/projectile/Destroy()
	message_admins("Destroy")
	if(hitscan)
		finalize_hitscan_and_generate_tracers()
	STOP_PROCESSING(SSprojectiles, src)
	cleanup_beam_segments()
	qdel(trajectory)
	return ..()

/obj/item/projectile/Bump(atom/A)
	var/datum/point/pcache = trajectory.copy_to()
	if(check_ricochet(A) && check_ricochet_flag(A) && ricochets < ricochets_max)
		ricochets++
		if(A.handle_ricochet(src))
			on_ricochet(A)
			ignore_source_check = TRUE
			range = initial(range)
			if(hitscan)
				store_hitscan_collision(pcache)
			return TRUE
	if(firer && !ignore_source_check)
		if(A == firer || (A == firer.loc && ismecha(A))) //cannot shoot yourself or your mech
			message_admins("can't shoot yourself, dummy!")
			trajectory_ignore_forcemove = TRUE
			forceMove(get_turf(A))
			trajectory_ignore_forcemove = FALSE
			return FALSE

	var/distance = get_dist(get_turf(A), starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
	def_zone = ran_zone(def_zone, max(100-(7*distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.

	if(isturf(A) && hitsound_wall)
		var/volume = CLAMP(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, 1, -1)

	var/turf/target_turf = get_turf(A)

	if(!prehit(A))
		if(forcedodge)
			trajectory_ignore_forcemove = TRUE
			forceMove(target_turf)
			trajectory_ignore_forcemove = FALSE
		return FALSE

	var/permutation = A.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null
	if(permutation == -1 || forcedodge)// the bullet passes through a dense object!
		trajectory_ignore_forcemove = TRUE
		forceMove(target_turf)
		trajectory_ignore_forcemove = FALSE
		if(A)
			permutated.Add(A)
		return FALSE
	qdel(src)
	return TRUE

/obj/item/projectile/Crossed(atom/movable/AM) //A mob moving on a tile with a projectile is hit by it.
	. = ..()
	message_admins("Crossed [AM.name]")
	if(isliving(AM) && !(flags_pass & PASSMOB))
		var/mob/living/L = AM
		if(AM == original)		//specific aiming for
			Bump(AM)
		if(AM.density)			//blocks projectiles
			Bump(AM)
		//if((L.mobility_flags & MOBILITY_USE|MOBILITY_STAND|MOBILITY_MOVE) & (MOBILITY_USE|MOBILITY_MOVE))	//If they're either able to move or use items, while crawling, they're not stunned enough to avoid projectiles.
		//	Bump(AM)

// load bullet values
/obj/item/projectile/proc/generate_bullet(ammo_datum, bonus_damage = 0, reagent_multiplier = 0)
	ammo 		= ammo_datum
	name 		= ammo.name
	icon_state 	= ammo.icon_state
	damage 		= ammo.damage + bonus_damage //Mainly for emitters.
	scatter		= ammo.scatter
	accuracy   += ammo.accuracy
	accuracy   *= rand(CONFIG_GET(number/combat_define/proj_variance_low)-ammo.accuracy_var_low, CONFIG_GET(number/combat_define/proj_variance_high)+ammo.accuracy_var_high) * CONFIG_GET(number/combat_define/proj_base_accuracy_mult)//Rand only works with integers.
	damage     *= rand(CONFIG_GET(number/combat_define/proj_variance_low)-ammo.damage_var_low, CONFIG_GET(number/combat_define/proj_variance_high)+ammo.damage_var_high) * CONFIG_GET(number/combat_define/proj_base_damage_mult)
	damage_falloff = ammo.damage_falloff
	list_reagents = ammo.ammo_reagents
	armor_type = ammo.armor_type

// target, firer, shot from, range, speed
/obj/item/projectile/proc/fire_at(atom/target,atom/F, atom/S, range = 30,speed = 1)
	message_admins("fire_at [Get_Angle(F, target)]")
	fire(Get_Angle(F, target), null)
	
	round_statistics.total_projectiles_fired++
	if(ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		round_statistics.total_bullets_fired++
		if(ammo.bonus_projectiles_amount)
			round_statistics.total_bullets_fired += ammo.bonus_projectiles_amount

	if(ammo.bonus_projectiles_amount && ammo.bonus_projectiles_type) ammo.fire_bonus_projectiles(src)

/obj/item/projectile/proc/return_predicted_turf_after_moves(moves, forced_angle)		//I say predicted because there's no telling that the projectile won't change direction/location in flight.
	message_admins("return_predicted_turf_after_moves")
	if(!trajectory && isnull(forced_angle) && isnull(Angle))
		return FALSE
	var/datum/point/vector/current = trajectory
	if(!current)
		var/turf/T = get_turf(src)
		current = new(T.x, T.y, T.z, pixel_x, pixel_y, isnull(forced_angle)? Angle : forced_angle, SSprojectiles.global_pixel_speed)
	var/datum/point/vector/v = current.return_vector_after_increments(moves * SSprojectiles.global_iterations_per_move)
	return v.return_turf()



/obj/item/projectile/process()
	last_process = world.time
	if(!loc || !fired || !trajectory)
		fired = FALSE
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move += world.time - last_process		//Compensates for pausing, so it doesn't become a hitscan projectile when unpaused from charged up ticks.
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	time_offset = 0
	var/required_moves = speed > 0? FLOOR(elapsed_time_deciseconds / speed, 1) : MOVES_HITSCAN			//Would be better if a 0 speed made hitscan but everyone hates those so I can't make it a universal system :<
	if(required_moves == MOVES_HITSCAN)
		required_moves = SSprojectiles.global_max_tick_moves
	else
		if(required_moves > SSprojectiles.global_max_tick_moves)
			var/overrun = required_moves - SSprojectiles.global_max_tick_moves
			required_moves = SSprojectiles.global_max_tick_moves
			time_offset += overrun * speed
		time_offset += MODULUS(elapsed_time_deciseconds, speed)

	for(var/i in 1 to required_moves)
		pixel_move(1, FALSE)

/obj/item/projectile/proc/fire(angle, atom/direct_target)
	message_admins("fire [angle]")
	//If no angle needs to resolve it from xo/yo!
	if(!log_override && firer && original)
		log_combat(firer, original, "fired at", src, "from [get_area_name(src, TRUE)]")
	if(direct_target)
		if(prehit(direct_target))
			direct_target.bullet_act(src, def_zone)
			message_admins("prehit successful")
			qdel(src)
			return
	if(isnum(angle))
		setAngle(angle)
	if(spread)
		setAngle(Angle + ((rand() - 0.5) * spread))
	var/turf/starting = get_turf(src)
	if(isnull(Angle))	//Try to resolve through offsets if there's no angle set.
		if(isnull(xo) || isnull(yo))
			stack_trace("WARNING: Projectile [type] deleted due to being unable to resolve a target after angle was null!")
			message_admins("WARNING: Projectile [type] deleted due to being unable to resolve a target after angle was null!")
			qdel(src)
			return
		var/turf/target = locate(CLAMP(starting + xo, 1, world.maxx), CLAMP(starting + yo, 1, world.maxy), starting.z)
		setAngle(Get_Angle(src, target))
		message_admins("Angle was null, set to [Angle]")
	original_angle = Angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	trajectory_ignore_forcemove = TRUE
	forceMove(starting)
	trajectory_ignore_forcemove = FALSE
	trajectory = new(starting.x, starting.y, starting.z, pixel_x, pixel_y, Angle, SSprojectiles.global_pixel_speed)
	last_projectile_move = world.time
	fired = TRUE
	if(hitscan)
		process_hitscan()
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSprojectiles, src)
	pixel_move(1, FALSE)	//move it now!

/obj/item/projectile/proc/setAngle(new_angle)	//wrapper for overrides.
	message_admins("setAngle [new_angle]")
	Angle = new_angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	if(trajectory)
		trajectory.set_angle(new_angle)
	return TRUE

/obj/item/projectile/forceMove(atom/target)
	message_admins("forceMove")
	if(!isloc(target) || !isloc(loc) || !z)
		return ..()
	var/zc = target.z != z
	var/old = loc
	if(zc)
		before_z_change(old, target)
	. = ..()
	if(trajectory && !trajectory_ignore_forcemove && isturf(target))
		if(hitscan)
			finalize_hitscan_and_generate_tracers(FALSE)
		trajectory.initialize_location(target.x, target.y, target.z, 0, 0)
		if(hitscan)
			record_hitscan_start(RETURN_PRECISE_POINT(src))
	if(zc)
		after_z_change(old, target)



/obj/item/projectile/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, Angle))
			setAngle(var_value)
			return TRUE
		else
			return ..()

/obj/item/projectile/proc/set_pixel_speed(new_speed)
	message_admins("set_pixel_speed")
	if(trajectory)
		trajectory.set_speed(new_speed)
		return TRUE
	return FALSE

/obj/item/projectile/proc/record_hitscan_start(datum/point/pcache)
	if(pcache)
		beam_segments = list()
		beam_index = pcache
		beam_segments[beam_index] = null	//record start.

/obj/item/projectile/proc/process_hitscan()
	var/safety = range * 3
	record_hitscan_start(RETURN_POINT_VECTOR_INCREMENT(src, Angle, MUZZLE_EFFECT_PIXEL_INCREMENT, 1))
	while(loc && !QDELETED(src))
		if(paused)
			stoplag(1)
			continue
		if(safety-- <= 0)
			if(loc)
				Bump(loc)
			if(!QDELETED(src))
				qdel(src)
			return	//Kill!
		pixel_move(1, TRUE)

/obj/item/projectile/proc/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	message_admins("pixel_move")
	if(!loc || !trajectory)
		return
	last_projectile_move = world.time
	if(!nondirectional_sprite && !hitscanning)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	if(homing)
		process_homing()
	var/forcemoved = FALSE
	for(var/i in 1 to SSprojectiles.global_iterations_per_move)
		if(QDELETED(src))
			return
		trajectory.increment(trajectory_multiplier)
		var/turf/T = trajectory.return_turf()
		if(!istype(T))
			qdel(src)
			return
		if(T.z != loc.z)
			var/old = loc
			before_z_change(loc, T)
			trajectory_ignore_forcemove = TRUE
			forceMove(T)
			trajectory_ignore_forcemove = FALSE
			after_z_change(old, loc)
			if(!hitscanning)
				pixel_x = trajectory.return_px()
				pixel_y = trajectory.return_py()
			forcemoved = TRUE
			hitscan_last = loc
		else if(T != loc)
			step_towards(src, T)
			hitscan_last = loc
		if(can_hit_target(original, permutated))
			message_admins("can_hit_target 2")
			Bump(original)
	if(!hitscanning && !forcemoved)
		pixel_x = trajectory.return_px() - trajectory.mpx * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		pixel_y = trajectory.return_py() - trajectory.mpy * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		animate(src, pixel_x = trajectory.return_px(), pixel_y = trajectory.return_py(), time = 1, flags = ANIMATION_END_NOW)
	Range()

/obj/item/projectile/proc/process_homing()			//may need speeding up in the future performance wise.
	if(!homing_target)
		return FALSE
	var/datum/point/PT = RETURN_PRECISE_POINT(homing_target)
	PT.x += CLAMP(homing_offset_x, 1, world.maxx)
	PT.y += CLAMP(homing_offset_y, 1, world.maxy)
	var/angle = closer_angle_difference(Angle, angle_between_points(RETURN_PRECISE_POINT(src), PT))
	setAngle(Angle + CLAMP(angle, -homing_turn_speed, homing_turn_speed))

/obj/item/projectile/proc/set_homing_target(atom/A)
	if(!A || (!isturf(A) && !isturf(A.loc)))
		return FALSE
	homing = TRUE
	homing_target = A
	homing_offset_x = rand(homing_inaccuracy_min, homing_inaccuracy_max)
	homing_offset_y = rand(homing_inaccuracy_min, homing_inaccuracy_max)
	if(prob(50))
		homing_offset_x = -homing_offset_x
	if(prob(50))
		homing_offset_y = -homing_offset_y

//Returns true if the target atom is on our current turf and above the right layer
/obj/item/projectile/proc/can_hit_target(atom/target, var/list/passthrough)
	message_admins("[target ? "V" : "X"] [target.layer >= PROJECTILE_HIT_THRESHHOLD_LAYER ? "lay" : "X"] [ismob(target) ? "mob" : "X"] [loc == get_turf(target) ? "loc" : "X"] [!(target in passthrough) ? "pass" : "X"]")
	return (target && ((target.layer >= PROJECTILE_HIT_THRESHHOLD_LAYER) || ismob(target)) && (loc == get_turf(target)) && (!(target in passthrough)))

//Spread is FORCED!
/obj/item/projectile/proc/preparePixelProjectile(atom/target, atom/source, params, spread = 0)
	message_admins("preparePixelProjectile")
	var/turf/curloc = get_turf(source)
	var/turf/targloc = get_turf(target)
	trajectory_ignore_forcemove = TRUE
	forceMove(get_turf(source))
	trajectory_ignore_forcemove = FALSE
	starting = get_turf(source)
	original = target
	if(targloc || !params)
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		setAngle(Get_Angle(src, targloc) + spread)

	if(isliving(source) && params)
		var/list/calculated = calculate_projectile_angle_and_pixel_offsets(source, params)
		p_x = calculated[2]
		p_y = calculated[3]

		setAngle(calculated[1] + spread)
	else if(targloc)
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		setAngle(Get_Angle(src, targloc) + spread)
	else
		stack_trace("WARNING: Projectile [type] fired without either mouse parameters, or a target atom to aim at!")
		qdel(src)

/proc/calculate_projectile_angle_and_pixel_offsets(mob/user, params)
	message_admins("calculate_projectile_angle_and_pixel_offsets")
	var/list/mouse_control = params2list(params)
	var/p_x = 0
	var/p_y = 0
	var/angle = 0
	if(mouse_control["icon-x"])
		p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		p_y = text2num(mouse_control["icon-y"])
	if(mouse_control["screen-loc"])
		//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
		var/list/screen_loc_params = splittext(mouse_control["screen-loc"], ",")

		//Split X+Pixel_X up into list(X, Pixel_X)
		var/list/screen_loc_X = splittext(screen_loc_params[1],":")

		//Split Y+Pixel_Y up into list(Y, Pixel_Y)
		var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
		var/x = text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32
		var/y = text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32

		//Calculate the "resolution" of screen based on client's view and world's icon size. This will work if the user can view more tiles than average.
		var/list/screenview = getviewsize(user.client.view)
		var/screenviewX = screenview[1] * world.icon_size
		var/screenviewY = screenview[2] * world.icon_size

		var/ox = round(screenviewX/2) - user.client.pixel_x //"origin" x
		var/oy = round(screenviewY/2) - user.client.pixel_y //"origin" y
		angle = ATAN2(y - oy, x - ox)
	return list(angle, p_x, p_y)

/obj/item/projectile/proc/cleanup_beam_segments()
	QDEL_LIST_ASSOC(beam_segments)
	beam_segments = list()
	qdel(beam_index)

/obj/item/projectile/proc/finalize_hitscan_and_generate_tracers(impacting = TRUE)
	if(trajectory && beam_index)
		var/datum/point/pcache = trajectory.copy_to()
		beam_segments[beam_index] = pcache
	generate_hitscan_tracers(null, null, impacting)

/obj/item/projectile/proc/generate_hitscan_tracers(cleanup = TRUE, duration = 3, impacting = TRUE)
	if(!length(beam_segments))
		return
	//if(tracer_type)
		//var/tempref = REF(src)
		//for(var/datum/point/p in beam_segments)
			//generate_tracer_between_points(p, beam_segments[p], tracer_type, color, duration, hitscan_light_range, hitscan_light_color_override, hitscan_light_intensity, tempref)
	if(muzzle_type && duration > 0)
		var/datum/point/p = beam_segments[1]
		var/atom/movable/thing = new muzzle_type
		p.move_atom_to_src(thing)
		var/matrix/M = new
		M.Turn(original_angle)
		thing.transform = M
		thing.color = color
		//thing.set_light(muzzle_flash_range, muzzle_flash_intensity, muzzle_flash_color_override? muzzle_flash_color_override : color)
		QDEL_IN(thing, duration)
	if(impacting && impact_type && duration > 0)
		var/datum/point/p = beam_segments[beam_segments[beam_segments.len]]
		var/atom/movable/thing = new impact_type
		p.move_atom_to_src(thing)
		var/matrix/M = new
		M.Turn(Angle)
		thing.transform = M
		thing.color = color
		//thing.set_light(impact_light_range, impact_light_intensity, impact_light_color_override? impact_light_color_override : color)
		QDEL_IN(thing, duration)
	if(cleanup)
		cleanup_beam_segments()



/obj/item/projectile/proc/after_z_change(atom/olcloc, atom/newloc)

/obj/item/projectile/proc/before_z_change(atom/oldloc, atom/newloc)

/obj/item/projectile/proc/return_pathing_turfs_in_moves(moves, forced_angle)
	message_admins("return_pathing_turfs_in_moves")
	var/turf/current = get_turf(src)
	var/turf/ending = return_predicted_turf_after_moves(moves, forced_angle)
	return getline(current, ending)

/obj/item/projectile/proc/check_ricochet()
	// dont enable this, I beg you
	//if(prob(ricochet_chance))
	//	return TRUE
	return FALSE

/obj/item/projectile/proc/check_ricochet_flag(atom/A)
	return TRUE

/obj/item/projectile/proc/store_hitscan_collision(datum/point/pcache)
	beam_segments[beam_index] = pcache
	beam_index = pcache
	beam_segments[beam_index] = null

/obj/item/projectile/proc/vol_by_damage()
	if(src.damage)
		return CLAMP((src.damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then CLAMP the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume

/obj/item/projectile/proc/on_ricochet(atom/A)
	return

/obj/item/projectile/proc/prehit(atom/target)
	return TRUE

/obj/item/projectile/proc/Range()
	range--
	if(range <= 0 && loc)
		on_range()

/obj/item/projectile/proc/on_range() //if we want there to be effects when they reach the end of their range
	message_admins("on_range")
	qdel(src)

/mob/living/proc/check_limb_hit(hit_zone)
	return hit_zone

/mob/living/carbon/check_limb_hit(hit_zone)
	message_admins("[hit_zone] zone")
	//for(var/datum/limb/X in limbs)
	//	message_admins("limb [X.name]")
//TODO: make this actually do something
	return "chest"

/atom/proc/handle_ricochet(obj/item/projectile/P)
	return

/turf/closed/wall/handle_ricochet(obj/item/projectile/P)
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	if(abs(incidence_s) > 90 && abs(incidence_s) < 270)
		return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	return TRUE



// OLD PROCS, TRY TO REPLACE

/mob/proc/bullet_message(obj/item/projectile/P)
	if(!P) return

	if(P.ammo.flags_ammo_behavior & AMMO_IS_SILENCED)
		to_chat(src, "[isxeno(src) ? "<span class='xenodanger'>" : "<span class='highdanger'>" ]You've been shot in the [parse_zone(P.def_zone)] by [P.name]!</span>")
	else
		visible_message("<span class='danger'>[name] is hit by the [P.name] in the [parse_zone(P.def_zone)]!</span>", \
						"<span class='highdanger'>You are hit by the [P.name] in the [parse_zone(P.def_zone)]!</span>", null, 4)

	if(ismob(P.firer))
		var/mob/firingMob = P.firer
		var/turf/T = get_turf(firingMob)
		if(ishuman(firingMob) && ishuman(src) && firingMob.mind && !firingMob.mind.special_role && mind && !mind.special_role) //One human shot another, be worried about it but do everything basically the same //special_role should be null or an empty string if done correctly
			log_combat(firingMob, src, "shot", P)
			log_ffattack("[key_name(firingMob)] shot [key_name(src)] with [P] in [AREACOORD(T)].")
			msg_admin_ff("[ADMIN_TPMONTY(firingMob)] shot [ADMIN_TPMONTY(src)] with [P] in [ADMIN_VERBOSEJMP(T)].")
			round_statistics.total_bullet_hits_on_marines++
		else
			log_combat(firingMob, src, "shot", P)
			msg_admin_attack("[ADMIN_TPMONTY(firingMob)] shot [ADMIN_TPMONTY(src)] with [P] in [ADMIN_VERBOSEJMP(T)].")
		return

	if(P.firer)
		log_combat(P.firer, src, "shot", P)
		msg_admin_attack("[ADMIN_TPMONTY(P.firer)] shot [ADMIN_TPMONTY(src)] with a [P]")
	else
		log_message("SOMETHING?? shot [key_name(src)] with a [P]", LOG_ATTACK)
		msg_admin_attack("SOMETHING?? shot [ADMIN_TPMONTY(src)] with a [P])")


//This is where the bullet bounces off.
/atom/proc/bullet_ping(obj/item/projectile/P)
	if(!P || !P.ammo.ping) return
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

/atom/proc/bullet_act(obj/item/projectile/P)
	return density

/mob/dead/bullet_act(/obj/item/projectile/P)
	return

/mob/living/bullet_act(obj/item/projectile/P)
	if(!P) return

	var/damage = max(0, P.damage - round(P.distance_travelled * P.damage_falloff))
	if(P.ammo.debilitate && stat != DEAD && ( damage || (P.ammo.flags_ammo_behavior & AMMO_IGNORE_RESIST) ) )
		apply_effects(arglist(P.ammo.debilitate))

	if(P.list_reagents && stat != DEAD && (ishuman(src) || ismonkey(src)))
		reagents.add_reagent_list(P.list_reagents)

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
	if(!P) return

	flash_weak_pain()

	if(P.ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		round_statistics.total_bullet_hits_on_humans++

	var/damage = max(0, P.damage - round(P.distance_travelled * P.damage_falloff))
	#if DEBUG_HUMAN_DEFENSE
	to_chat(world, "<span class='debuginfo'>Initial damage is: <b>[damage]</b></span>")
	#endif

	//Any projectile can decloak a predator. It does defeat one free bullet though.
	if(gloves)
		var/obj/item/clothing/gloves/yautja/Y = gloves
		if(istype(Y) && Y.cloaked)
			if( P.ammo.flags_ammo_behavior & (AMMO_ROCKET|AMMO_ENERGY|AMMO_XENO_ACID) ) //<--- These will auto uncloak.
				Y.decloak(src) //Continue on to damage.
			else if(rand(0,100) < 20)
				Y.decloak(src)
				return //Absorb one free bullet.
			//Else we're moving on to damage.

	//Shields
	if( !(P.ammo.flags_ammo_behavior & AMMO_ROCKET) ) //No, you can't block rockets.
		if( P.dir == reverse_direction(dir) && check_shields(damage * 0.65, "[P]") && src != P.firer.sniper_target(src)) //Aimed sniper shots will ignore shields
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
		if(P.firer && src == P.firer.sniper_target(src)) //Runtimes bad
			damage *= SNIPER_LASER_DAMAGE_MULTIPLIER //+50% damage vs the aimed target
			penetration *= SNIPER_LASER_ARMOR_MULTIPLIER //+50% penetration vs the aimed target
		armor -= penetration//Minus armor penetration from the bullet. If the bullet has negative penetration, adding to their armor, but they don't have armor, they get nothing.
		#if DEBUG_HUMAN_DEFENSE
		to_chat(world, "<span class='debuginfo'>Adjusted armor after penetration is: <b>[armor]</b></span>")
		#endif

		if(armor > 0) //Armor check. We should have some to continue.
			 /*Automatic damage soak due to armor. Greater difference between armor and damage, the more damage
			 soaked. Small caliber firearms aren't really effective against combat armor.*/
			var/armor_soak	 = round( ( armor / damage ) * 10 )//Setting up for next action.
			var/critical_hit = rand(CONFIG_GET(number/combat_define/critical_chance_low),CONFIG_GET(number/combat_define/critical_chance_high))
			damage 			-= prob(critical_hit) ? 0 : armor_soak //Chance that you won't soak the initial amount.
			armor			-= round(armor_soak * CONFIG_GET(number/combat_define/base_armor_resist_low)) //If you still have armor left over, you generally should, we subtract the soak.
											  		   //This gives smaller calibers a chance to actually deal damage.
			#if DEBUG_HUMAN_DEFENSE
			to_chat(world, "<span class='debuginfo'>Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[armor]</b></span>")
			#endif
			var/i = 0
			if(damage)
				while(armor > 0 && i < 2) //Going twice. Armor has to exist to continue. Post increment.
					if(prob(armor))
						armor_soak 	 = round(damage * 0.5)  //Cut it in half.
						armor 		-= armor_soak * CONFIG_GET(number/combat_define/base_armor_resist_high)
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
		//Predators and synths are immune to these effects to cut down on the stun spam. This should later be moved to their apply_effects proc, but right now they're just humans.
		if(!isyautjastrict(src) && !(species.flags & IS_SYNTHETIC))
			apply_effects(arglist(P.ammo.debilitate))

	bullet_message(P) //We still want this, regardless of whether or not the bullet did damage. For griefers and such.

	if(P.list_reagents && stat != DEAD)
		reagents.add_reagent_list(P.list_reagents)

	if(damage)
		apply_damage(damage, P.ammo.damage_type, P.def_zone)
		P.play_damage_effect(src)
		if(P.ammo.shrapnel_chance > 0 && prob(P.ammo.shrapnel_chance + round(damage / 10) ) )
			var/obj/item/shard/shrapnel/shrap = new()
			shrap.name = "[P.name] shrapnel"
			shrap.desc = "[shrap.desc] It looks like it was fired from [P.firer ? P.firer : "something unknown"]."
			shrap.loc = organ
			organ.embed(shrap)
			if(!stat && !(species && species.flags & NO_PAIN))
				emote("scream")
				to_chat(src, "<span class='highdanger'>You scream in pain as the impact sends <B>shrapnel</b> into the wound!</span>")

		if(P.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
			adjust_fire_stacks(rand(6,11))
			IgniteMob()
			if(!stat && !(species.flags & NO_PAIN))
				emote("scream")
				to_chat(src, "<span class='highdanger'>You burst into flames!! Stop drop and roll!</span>")
		return 1

//Deal with xeno bullets.
/mob/living/carbon/Xenomorph/bullet_act(obj/item/projectile/P)
	if(!P || !istype(P)) return
	if(P.ammo.flags_ammo_behavior & (AMMO_XENO_ACID|AMMO_XENO_TOX) ) //Aliens won't be harming aliens.
		bullet_ping(P)
		return

	if(P.ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		round_statistics.total_bullet_hits_on_xenos++

	flash_weak_pain()

	var/damage = max(0, P.damage - round(P.distance_travelled * P.damage_falloff)) //Has to be at least zero, no negatives.
	#if DEBUG_XENO_DEFENSE
	to_chat(world, "<span class='debuginfo'>Initial damage is: <b>[damage]</b></span>")
	#endif

	if(warding_aura) //Damage reduction. Every half point of warding decreases damage by 2.5 %. Maximum is 25 % at 5 pheromone strength.
		damage = round(damage * (1 - (warding_aura * 0.05) ) )
		#if DEBUG_XENO_DEFENSE
		to_chat(world, "<span class='debuginfo'>Damage migated by a warding aura level of [warding_aura], damage is now <b>[damage]</b></span>")
		#endif

	if(damage > 0 && !(P.ammo.flags_ammo_behavior & AMMO_IGNORE_ARMOR))
		var/armor = xeno_caste.armor_deflection + armor_bonus + armor_pheromone_bonus
		#if DEBUG_XENO_DEFENSE
		world << "<span class='debuginfo'>Initial armor is: <b>[armor]</b></span>"
		#endif
		if(isxenoqueen(src) || isxenocrusher(src)) //Charging and crest resistances. Charging Xenos get a lot of extra armor, currently Crushers and Queens
			var/mob/living/carbon/Xenomorph/charger = src
			armor += round(charger.charge_speed * 5) //Some armor deflection when charging.
			#if DEBUG_CREST_DEFENSE
			world << "<span class='debuginfo'>Projectile direction is: <b>[P.dir]</b> and crest direction is: <b>[charger.dir]</b></span>"
			#endif
			if(P.dir == charger.dir)
				if(isxenoqueen(src))
					armor = max(0, armor - (xeno_caste.armor_deflection * CONFIG_GET(number/combat_define/xeno_armor_resist_low))) //Both facing same way -- ie. shooting from behind; armour reduced by 50% of base.
				else
					armor = max(0, armor - (xeno_caste.armor_deflection * CONFIG_GET(number/combat_define/xeno_armor_resist_lmed))) //Both facing same way -- ie. shooting from behind; armour reduced by 75% of base.
			else if(P.dir == reverse_direction(charger.dir))
				armor += round(xeno_caste.armor_deflection * CONFIG_GET(number/combat_define/xeno_armor_resist_low)) //We are facing the bullet.
			else if(isxenocrusher(src))
				armor = max(0, armor - (xeno_caste.armor_deflection * CONFIG_GET(number/combat_define/xeno_armor_resist_vlow))) //side armour eats a bit of shit if we're a Crusher
			//Otherwise use the standard armor deflection for crushers.
			#if DEBUG_XENO_DEFENSE
			to_chat(world, "<span class='debuginfo'>Adjusted crest armor is: <b>[armor]</b></span>")
			#endif

		var/penetration = P.ammo.penetration > 0 || armor > 0 ? P.ammo.penetration : 0
		if(P.firer && src == P.firer.sniper_target(src))
			damage *= SNIPER_LASER_DAMAGE_MULTIPLIER //+50% damage vs the aimed target
			penetration *= SNIPER_LASER_ARMOR_MULTIPLIER //+50% penetration vs the aimed target

		armor -= penetration

		#if DEBUG_XENO_DEFENSE
		world << "<span class='debuginfo'>Adjusted armor after penetration is: <b>[armor]</b></span>"
		#endif
		if(armor > 0) //Armor check. We should have some to continue.
			 /*Automatic damage soak due to armor. Greater difference between armor and damage, the more damage
			 soaked. Small caliber firearms aren't really effective against combat armor.*/
			var/armor_soak	 = round( ( armor / damage ) * 10 )//Setting up for next action.
			var/critical_hit = rand(CONFIG_GET(number/combat_define/critical_chance_low),CONFIG_GET(number/combat_define/critical_chance_high))
			damage 			-= prob(critical_hit) ? 0 : armor_soak //Chance that you won't soak the initial amount.
			armor			-= round(armor_soak * CONFIG_GET(number/combat_define/base_armor_resist_low)) //If you still have armor left over, you generally should, we subtract the soak.
											  		   //This gives smaller calibers a chance to actually deal damage.
			#if DEBUG_XENO_DEFENSE
			to_chat(world, "<span class='debuginfo'>Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[armor]</b></span>")
			#endif
			var/i = 0
			if(damage)
				while(armor > 0 && i < 2) //Going twice. Armor has to exist to continue. Post increment.
					if(prob(armor))
						armor_soak 	 = round(damage * 0.5)
						armor 		-= armor_soak * CONFIG_GET(number/combat_define/base_armor_resist_high)
						damage 		-= armor_soak
						#if DEBUG_XENO_DEFENSE
						to_chat(world, "<span class='debuginfo'>Currently soaked: <b>[armor_soak]</b>. Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[armor]</b></span>")
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

/turf/bullet_act(obj/item/projectile/P)
	if(!P || !density) return //It's just an empty turf

	bullet_ping(P)

	var/turf/target_turf = P.loc
	if(!istype(target_turf)) return //The bullet's not on a turf somehow.

	var/list/mobs_list = list() //Let's built a list of mobs on the bullet turf and grab one.
	for(var/mob/living/L in target_turf)
		if(L in P.permutated) continue
		mobs_list += L

	if(mobs_list.len)
		var/mob/living/picked_mob = pick(mobs_list) //Hit a mob, if there is one.
		if(istype(picked_mob) && P.firer && prob(P.get_projectile_hit_chance(P.firer,picked_mob)))
			picked_mob.bullet_act(P)
			return 1
	return 1

// walls can get shot and damaged, but bullets (vs energy guns) do much less.
/turf/closed/wall/bullet_act(obj/item/projectile/P)
	if(!..())
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


/turf/closed/wall/almayer/research/containment/bullet_act(obj/item/projectile/P)
	if(P && P.ammo.flags_ammo_behavior & AMMO_XENO_ACID)
		return //immune to acid spit
	. = ..()




//Hitting an object. These are too numerous so they're staying in their files.
//Why are there special cases listed here? Oh well, whatever. ~N
/obj/bullet_act(obj/item/projectile/P)
	if(!CanPass(P, get_turf(src)) && density)
		bullet_ping(P)
		return 1

/obj/structure/table/bullet_act(obj/item/projectile/P)
	src.bullet_ping(P)
	health -= round(P.damage/2)
	if (health < 0)
		visible_message("<span class='warning'>[src] breaks down!</span>")
		destroy_structure()
	return 1

//returns probability for the projectile to hit us.
/atom/movable/proc/get_projectile_hit_chance(obj/item/projectile/P)
	return 0

//obj version just returns true or false.
/obj/get_projectile_hit_chance(obj/item/projectile/P)
	if(!density)
		return FALSE

	if(layer >= OBJ_LAYER || src == P.original)
		return TRUE

/obj/structure/get_projectile_hit_chance(obj/item/projectile/P)
	if(!density) //structure is passable
		return FALSE

	if(src == P.original) //clicking on the structure itself hits the structure
		return TRUE

	if(!anchored) //unanchored structure offers no protection.
		return FALSE

	if(!throwpass)
		return TRUE

	if(P.ammo.flags_ammo_behavior & AMMO_SNIPER || P.ammo.flags_ammo_behavior & AMMO_SKIPS_HUMANS || P.ammo.flags_ammo_behavior & AMMO_ROCKET) //sniper, rockets and IFF rounds bypass cover
		return FALSE

	if(!(flags_atom & ON_BORDER))
		return FALSE //window frames, unflipped tables

	if(!( P.dir & reverse_direction(dir) || P.dir & dir))
		return FALSE //no effect if bullet direction is perpendicular to barricade

	var/distance = P.distance_travelled - 1
	if(distance < P.ammo.barricade_clear_distance)
		return FALSE

	var/coverage = 90 //maximum probability of blocking projectile
	var/distance_limit = 6 //number of tiles needed to max out block probability
	var/accuracy_factor = 50 //degree to which accuracy affects probability   (if accuracy is 100, probability is unaffected. Lower accuracies will increase block chance)

	var/hitchance = min(coverage, (coverage * distance/distance_limit) + accuracy_factor * (1 - P.accuracy/100))
	//to_chat(world, "Distance travelled: [distance]  |  Accuracy: [P.accuracy]  |  Hit chance: [hitchance]")
	return prob(hitchance)

/obj/structure/window/get_projectile_hit_chance(obj/item/projectile/P)
	if(P.ammo.flags_ammo_behavior & AMMO_ENERGY || ( (flags_atom & ON_BORDER) && P.dir != dir && P.dir != reverse_direction(dir) ) )
		return FALSE
	else
		return TRUE

/obj/machinery/door/poddoor/railing/get_projectile_hit_chance(obj/item/projectile/P)
	return src == P.original

/obj/effect/alien/egg/get_projectile_hit_chance(obj/item/projectile/P)
	return src == P.original

/obj/effect/alien/resin/trap/get_projectile_hit_chance(obj/item/projectile/P)
	return src == P.original

/obj/item/clothing/mask/facehugger/get_projectile_hit_chance(obj/item/projectile/P)
	return src == P.original

/mob/living/get_projectile_hit_chance(obj/item/projectile/P)

	if(lying && src != P.original)
		return 0

	if(P.ammo.flags_ammo_behavior & (AMMO_XENO_ACID|AMMO_XENO_TOX))
		if((status_flags & XENO_HOST) && istype(buckled, /obj/structure/bed/nest))
			return 0

	. = P.accuracy //We want a temporary variable so accuracy doesn't change every time the bullet misses.
	#if DEBUG_HIT_CHANCE
	to_chat(world, "<span class='debuginfo'>Base accuracy is <b>[P.accuracy]; scatter:[P.scatter]; distance:[P.distance_travelled]</b></span>")
	#endif

	if (P.distance_travelled <= P.ammo.accurate_range + rand(0, 2))
	// If bullet stays within max accurate range + random variance
		if (P.distance_travelled <= P.ammo.point_blank_range)
			//If bullet within point blank range, big accuracy buff
			. += 25
		else if ((P.ammo.flags_ammo_behavior & AMMO_SNIPER) && P.distance_travelled <= P.ammo.accurate_range_min)
			// Snipers have accuracy falloff at closer range before point blank
			. -= (P.ammo.accurate_range_min - P.distance_travelled) * 5
	else
		. -= (P.ammo.flags_ammo_behavior & AMMO_SNIPER) ? (P.distance_travelled * 3) : (P.distance_travelled * 5)
		// Snipers have a smaller falloff constant due to longer max range


	#if DEBUG_HIT_CHANCE
	to_chat(world, "<span class='debuginfo'>Final accuracy is <b>[.]</b></span>")
	#endif

	. = max(5, .) //default hit chance is at least 5%.
	if(lying && stat) . += 15 //Bonus hit against unconscious people.

	if(isliving(P.firer))
		var/mob/living/shooter_living = P.firer
		if( !can_see(shooter_living,src) )
			. -= 15 //Can't see the target (Opaque thing between shooter and target)
		if(shooter_living.last_move_intent < world.time - 20) //We get a nice accuracy bonus for standing still.
			. += 15
		else if(shooter_living.m_intent == MOVE_INTENT_WALK) //We get a decent accuracy bonus for walking
			. += 10

	if(ishuman(P.firer))
		var/mob/living/carbon/human/shooter_human = P.firer
		. -= round(max(30,(shooter_human.traumatic_shock) * 0.2)) //Chance to hit declines with pain, being reduced by 0.2% per point of pain.
		if(shooter_human.stagger)
			. -= 30 //Being staggered fucks your aim.
		if(shooter_human.marskman_aura)
			. += shooter_human.marskman_aura * 1.5 //Flat buff of 3 % accuracy per aura level
			. += P.distance_travelled * 0.35 * shooter_human.marskman_aura //Flat buff to accuracy per tile travelled


/mob/living/carbon/human/get_projectile_hit_chance(obj/item/projectile/P)
	. = ..()
	if(.)
		if(P.ammo.flags_ammo_behavior & AMMO_SKIPS_HUMANS && get_target_lock(P.ammo.iff_signal))
			return 0
		if(mobility_aura)
			. -= mobility_aura * 5
		var/mob/living/carbon/human/shooter_human = P.firer
		if(istype(shooter_human))
			if(shooter_human.faction == faction || m_intent == MOVE_INTENT_WALK)
				. -= 15


/mob/living/carbon/Xenomorph/get_projectile_hit_chance(obj/item/projectile/P)
	. = ..()
	if(.)
		if(P.ammo.flags_ammo_behavior & AMMO_SKIPS_ALIENS)
			return 0
		if(mob_size == MOB_SIZE_BIG)	. += 10
		else							. -= 10


/mob/living/silicon/robot/drone/get_projectile_hit_chance(obj/item/projectile/P)
	return 0 // just stop them getting hit by projectiles completely


/obj/item/projectile/proc/play_damage_effect(mob/M)
	if(ammo.sound_hit) playsound(M, ammo.sound_hit, 50, 1)
	if(M.stat != DEAD) animation_flash_color(M)

#undef DEBUG_HIT_CHANCE
#undef DEBUG_HUMAN_DEFENSE
#undef DEBUG_XENO_DEFENSE
