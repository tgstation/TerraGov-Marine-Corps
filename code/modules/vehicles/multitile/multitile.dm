
/*
A multitile vehicle is made up of 2 types of objects, root and hitbox
relaymove() only does something for root
You can inherit and do special stuff for either, but only one will let you move
Rotations treat root as x = 0, y = 0
All of the backend for movement will be under root

Vehicles are placed on the map by a spawner or admin verb
*/

//This was part of an old plan to have a dynamic number of vehicle interiors
//Turns out that's incredibly fucking dificult, so a fixed number is gonna be the ideal choice
/*
/obj/effect/landmark/multitile_starter
	name = "Landmark"
	desc = "Where the interiors for multitiles start spawning"
*/

/obj/effect/multitile_spawner

	var/width = 2
	var/height = 3
	var/spawn_dir = SOUTH

//A hidden marker for where you mount and dismount the vehicle
//You could have multiple if you wanted
/obj/effect/multitile_entrance
	name = "Entrance marker"
	desc = "Marker for the entrance of a multitile vehicle."

	var/obj/vehicle/multitile/root/master
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/multitile_entrance/Destroy(force = FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()

//Always moves where you want it to, no matter what
/obj/effect/multitile_entrance/Move(atom/A)
	loc = get_turf(A)
	return TRUE

//A basic handoff to the root object to actually deal with attempted player entrance
/obj/effect/multitile_entrance/verb/enter_multitile()
	set category = "Vehicle"
	set name = "Enter Vehicle"
	set src in view(0)

	master.handle_player_entrance(usr)

//Remnant of vehicle interiors
/*
/obj/effect/landmark/multitile_exit
	name = "Landmark"
	desc = "Marker for the exit of the interior"

	invisibility = INVISIBILITY_MAXIMUM

	var/obj/vehicle/multitile/root/master
*/

/*
/obj/effect/landmark/multitile_exit/verb/exit_multitile(mob/M)
	set category = "Vehicle"
	set name = "Exit Vehicle"
	set src in master

	master.handle_player_exit(M)
*/

//Super super generic, doesn't really need to exist
/obj/vehicle/multitile
	name = "multitile vehicle"
	desc = "You shouldn't see this"

/obj/vehicle/multitile/relaymove(mob/user, direction)
	return

//Hitboxes, do notthing but move with the root object and take up space
//All interactions like bullets or whatever should be passed up to the root object
/obj/vehicle/multitile/hitbox
	name = "hitbox"
	desc = "Generic multitile vehicle hitbox"

	var/obj/vehicle/multitile/root/root
	invisibility = INVISIBILITY_MAXIMUM

/obj/vehicle/multitile/root
	name = "root"
	desc = "Root tile for multitile vehicles"

	var/old_dir

	var/obj/effect/multitile_entrance/entrance
	//var/obj/effect/landmark/multitile_exit/exit

	//Objects that move in accordance with this one
	//Objects indexed by /datum/coords
	//Does not include the root obj
	var/list/linked_objs = list()

	//list of turfs that the vehicle was in before
	var/list/old_locs = list()

	//list of idle passengers in the vehicle
	//used for any type of APC
	var/list/idle_passengers = list()
	var/max_idle_passengers = 0

	//Another remnant of vehicle interiors
	//var/list/interior_data = list()

	var/base_icon_type = "" //e.g. "tank" or "apc", used to assign icons to the hitboxes

	var/hitbox_type = /obj/vehicle/multitile/hitbox

//How to get out, via verb
/obj/vehicle/multitile/root/verb/exit_multitile()
	set category = "Vehicle"
	set name = "Exit Vehicle"
	set src in view(0)

	if(!usr.incapacitated(TRUE))
		handle_player_exit(usr)

/obj/vehicle/multitile/root/proc/handle_player_exit(mob/M)
	return

/obj/vehicle/multitile/root/proc/handle_player_entrance(mob/living/M)
	if(M.resting || M.buckled || M.incapacitated())
		return FALSE
	return TRUE

/obj/vehicle/multitile/root/proc/handle_harm_attack(mob/living/M)
	if(M.resting || M.buckled || M.incapacitated())
		return FALSE
	return TRUE

//Vebrs for rotations, set up a macro and get turnin
/obj/vehicle/multitile/root/verb/clockwise_rotate_multitile()
	set category = "Vehicle"
	set name = "Rotate Vehicle Clockwise"
	set src in view(0)

	var/mob/M = usr
	try_rotate(-90, M)

/obj/vehicle/multitile/root/verb/counterclockwise_rotate_multitile()
	set category = "Vehicle"
	set name = "Rotate Vehicle Counterclockwise"
	set src in view(0)

	var/mob/M = usr
	try_rotate(90, M)

//A wrapper for try_move() that rotates
/obj/vehicle/multitile/root/proc/try_rotate(deg, mob/user, force = FALSE)
	save_locs()
	rotate_coords(deg)
	if(!try_move(linked_objs, null, TRUE))
		rotate_coords(-1*deg)
		revert_locs()
		return FALSE

	update_icon()
	return TRUE

//Called when players try to move from inside the vehicle
//Another wrapper for try_move()
/obj/vehicle/multitile/root/relaymove(mob/user, direction)
	if(dir in list(EAST, WEST))
		if(direction == SOUTH)
			return try_rotate( (dir == WEST ? 90 : -90), user, 1)
		else if(direction == NORTH)
			return try_rotate( (dir == EAST ? 90 : -90), user, 1)

	else if(dir in list(SOUTH, NORTH))
		if(direction == EAST)
			return try_rotate( (dir == SOUTH ? 90 : -90), user, 1)
		else if(direction == WEST)
			return try_rotate( (dir == NORTH ? 90 : -90), user, 1)

	old_dir = dir
	save_locs()
	if(!try_move(linked_objs, direction))
		revert_locs()
		setDir(old_dir)
		return FALSE //Failed movement

	setDir(old_dir) //Preserve the direction you're facing when moving backwards
	return TRUE

/obj/vehicle/multitile/root/Initialize()
	. = ..()
	var/datum/coords/C = new
	C.x_pos = 0
	C.y_pos = 0
	C.y_pos = 0
	linked_objs[C] = src

/obj/vehicle/multitile/root/proc/load_hitboxes(datum/coords/dimensions, datum/coords/root_pos)
	return

/obj/vehicle/multitile/root/proc/load_entrance_marker(datum/coords/rel_pos)
	return

//Saves where everything is so we can revert
/obj/vehicle/multitile/root/proc/save_locs()

	for(var/datum/coords/C in linked_objs)
		var/atom/movable/A = linked_objs[C]
		//Shit, something killed it, now we hope it was a hitbox and redraw it
		//Check for turfs since cdel changes the loc but doesn't make it null
		if(!istype(A.loc, /turf))
			var/turf/T = locate(x + C.x_pos, y + C.y_pos, z + C.z_pos)
			A = new hitbox_type(T)
			linked_objs[C] = A
		old_locs[A] = A.loc

//We were unable to move, so revert everything we may have done so far
/obj/vehicle/multitile/root/proc/revert_locs()

	for(var/datum/coords/C in linked_objs)
		var/atom/movable/A = linked_objs[C]
		A.loc = old_locs[A]
		if(istype(A, /obj))
			var/obj/O = A
			O.buckled_mob?.loc = old_locs[A]

//Forces the root object to move so everything can update relative to it
/obj/vehicle/multitile/root/proc/move_root(direction)

	var/turf/T = get_step(loc, direction)
	loc = T

//The REAL guts of multitile movement
//Here's how this shit works:

//Step 1: Iterate over every associated object and move what can be moved in the right dir
//Step 2: Save everything that couldn't move in a list
//Step 3: Recursively try to move those after everything else that can move has done so
//			This is so if one hitbox is blocking another, eventually they will both move
//Step 4: If on this level of recursion, we couldn't move any more things, we've failed
//Step 5: Continue steps 1 through 4 until we fail or succeed
/obj/vehicle/multitile/root/proc/try_move(list/objs, direction, is_rotation = FALSE)

	var/list/blocked = list() //What couldn't move this time
	for(var/datum/coords/C in objs) //objs is an associative list like linked_objs
		var/atom/movable/A = objs[C]
		var/turf/T = locate(x + C.x_pos, y + C.y_pos, z + C.z_pos)
		if(is_rotation) //Special case for rotations where two hitboxes need to swap locations
			//Fun fact, there's actually a bug in this part of the algorithm
			//Not all hitboxes want to switch locations, so sometimes a hitbox can end up in vastly the wrong location
			//BUT, then the hitbox that ends of up in the wrong place tries to move later on
			//The only instance where this can cause problems is if you have two hitboxes tryign to move to the same tile
			//If you do, you're probably doing something wrong
			var/obj/vehicle/multitile/M
			for(var/i in T) //Get the one to swap with
				if(istype(i, /obj/vehicle/multitile))
					M = i
					break
			if(istype(M))
				var/turf/interim = M.loc
				A.forceMove(M.loc) //Swap that shit
				M.forceMove(interim)
				M.buckled_mob?.loc = M.loc
				if(istype(A, /obj))
					var/obj/O = A
					O.buckled_mob?.loc = O.loc

			else if(!A.Move(T))
				blocked[C] = A //We couldn't move, so remember that and try again next time
		else
			if(!step(A, direction))
				blocked[C] = A //We couldn't move, so remember that and try again next time

	if(length(blocked) == length(objs))
		return FALSE //No more things can move, return false

	else if(length(blocked))
		return try_move(blocked, direction, is_rotation) //Some things moved, retry the others

	else if(!length(blocked))
		return TRUE //Everything finished moving, return true

	else
		return FALSE //Shouldn't even be possible, so say we failed anyways

//Applies the 2D transformation matrix to the saved coords
/obj/vehicle/multitile/root/proc/rotate_coords(deg)

	for(var/datum/coords/C in linked_objs)

		var/atom/movable/A = linked_objs[C]
		A.setDir(turn(A.dir, deg)) //Turn the thing at that tile

		//Update coords
		var/new_x = C.x_pos*cos(deg) - C.y_pos*sin(deg)
		var/new_y = C.x_pos*sin(deg) + C.y_pos*cos(deg)
		new_x = round(new_x, 1)
		new_y = round(new_y, 1) //Sometimes using the rotation matrix gets you off by 1e-5 or so
		C.x_pos = new_x
		C.y_pos = new_y
