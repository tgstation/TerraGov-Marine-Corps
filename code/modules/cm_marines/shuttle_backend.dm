/*************************************
shuttle_backend.dm
by MadSnailDisease, 12/29/16
**************************************

/datum/shuttle_area_info :
--------------------------------
This is just a datum that holds the hard-coded coordinate datums.
An instance of it named s_info is found in the shuttle controller
--------------------------------

/datum/coords :
--------------------------------
An object that just hold x, y, and z positions coordinates



/obj/effect/landmark/shuttle_loc and its 3 sub-types :
--------------------------------
These are simple landmarks that exist to serve as locations for finding the reference turfs
Make sure each source, interim, and target landmarks have the same unique name
Otherwise there is a 50% chance it will fail horribly and spectacularly



/proc/get_shuttle_turfs(var/turf/ref, var/shuttle) :
--------------------------------
ref: the reference turf, gotten from its respective landmark
shuttle: The name of the shuttle in question. Synonymous with the name of the ref landmark.

Return: A list of coordinate datums indexed by turfs.

Notes:
The list size will vary dependind on which shuttle you used.
See the documentation of /datum/shuttle_area_info for more.



/proc/move_shuttle_to(var/turf/trg, var/turftoleave = null, var/list/source, var/iselevator = 0)
--------------------------------
trg: The target reference turf, see var/turf/ref from the previous proc
turftoleave: Allows leaving other turfs behind as needed. Note: must be a path
source: A list of coordinate datums indexed by turfs. See Return from the previous proc
iselevator: Used as a simple boolean. Dictates whether or not the shuttle is in fact an elevator

Notes:
iselevator is admittedly a hair "hacky"
TODO: Create /datum/shuttle/ferry/marine/elevator and depreciate this

*/

/datum/shuttle_area_info
	var/list/Rasputin
	var/list/Droppod
	var/list/Unknown

/datum/shuttle_controller/var/datum/shuttle_area_info/s_info = new

/datum/shuttle_area_info/New()

	//This is how we switch from using those damn areas into using relative positions
	//These hold the RELATIVE positions to the base turf of a shuttle
	//When making a new one, make the base turf something obvious or explicitly name it next to the instantiation.
	//As long as the list is just right, it'll be okay

	/*
	The way these conventions work:
		1. Use newlist to instantiate the coords datums
		2. All coord datums with the same value being set for y_pos go on the same line
		3. Each line will be sorted from left to right from lowest to highest value for x_pos
		4. A picture like the one below is preferred for bug testing and reference, but not required
	Here's the default set, which translates to this:
	O O O O O
	O X X X O
	O X T X O
	O X X X O
	O O O O O
	Where X is a turf it brings with it, O is a turf it doesn't, and T is the reference turf.
	Note how the code includes a datum for the reference turf, as the shuttle code will not automatically bring it

	Furthermore, there should be rar a file called ShuttleGenerator.rar on the repository
	which has a Java program that will generate the text for you.
	*/
	Unknown = newlist(
		/datum/coords {x_pos = -1; y_pos = 1}, /datum/coords {x_pos = 0; y_pos = 1}, /datum/coords {x_pos = 1; y_pos = 1},
		/datum/coords {x_pos = -1; y_pos = 0}, /datum/coords {x_pos = 0; y_pos = 0}, /datum/coords {x_pos = 1; y_pos = 0},
		/datum/coords {x_pos = -1; y_pos = -1}, /datum/coords {x_pos = 0; y_pos = -1}, /datum/coords {x_pos = 1; y_pos = -1}
	)

	//Rasputin
	/*
x_pos = 0 1 2 3 4 5 6 7 8
		| | | | | | | | |
		O O O X X X O O O -- y_pos = 17
		O O O X X X O O O -- y_pos = 16
		O X X X X X X X O -- y_pos = 15
		X X X X X X X X X -- y_pos = 14
		X X X X X X X X X -- y_pos = 13
		X X X X X X X X X -- y_pos = 12
		X X X X X X X X X -- y_pos = 11
		X X X X X X X X X -- y_pos = 10
		X X X X X X X X X -- y_pos = 9
		X X X X X X X X X -- y_pos = 8
		X X X X X X X X X -- y_pos = 7
		O O X X X X X O O -- y_pos = 6
		O O X X X X X O O -- y_pos = 5
		O X X X X X X X O -- y_pos = 4
		O X X X X X X X O -- y_pos = 3
		O O X X X X X O O -- y_pos = 2
		O O O X X X O O O -- y_pos = 1
		T O O X X X O O O -- y_pos = 0
	*/
	Rasputin = newlist(
		/datum/coords {x_pos = 3; y_pos = 17}, /datum/coords {x_pos = 4; y_pos = 17}, /datum/coords {x_pos = 5; y_pos = 17},

		/datum/coords {x_pos = 3; y_pos = 16}, /datum/coords {x_pos = 4; y_pos = 16}, /datum/coords {x_pos = 5; y_pos = 16},

		/datum/coords {x_pos = 1; y_pos = 15}, /datum/coords {x_pos = 2; y_pos = 15}, /datum/coords {x_pos = 3; y_pos = 15}, /datum/coords {x_pos = 4; y_pos = 15}, /datum/coords {x_pos = 5; y_pos = 15}, /datum/coords {x_pos = 6; y_pos = 15}, /datum/coords {x_pos = 7; y_pos = 15},

		/datum/coords {x_pos = 0; y_pos = 14}, /datum/coords {x_pos = 1; y_pos = 14}, /datum/coords {x_pos = 2; y_pos = 14}, /datum/coords {x_pos = 3; y_pos = 14}, /datum/coords {x_pos = 4; y_pos = 14}, /datum/coords {x_pos = 5; y_pos = 14}, /datum/coords {x_pos = 6; y_pos = 14}, /datum/coords {x_pos = 7; y_pos = 14}, /datum/coords {x_pos = 8; y_pos = 14},

		/datum/coords {x_pos = 0; y_pos = 13}, /datum/coords {x_pos = 1; y_pos = 13}, /datum/coords {x_pos = 2; y_pos = 13}, /datum/coords {x_pos = 3; y_pos = 13}, /datum/coords {x_pos = 4; y_pos = 13}, /datum/coords {x_pos = 5; y_pos = 13}, /datum/coords {x_pos = 6; y_pos = 13}, /datum/coords {x_pos = 7; y_pos = 13}, /datum/coords {x_pos = 8; y_pos = 13},

		/datum/coords {x_pos = 0; y_pos = 12}, /datum/coords {x_pos = 1; y_pos = 12}, /datum/coords {x_pos = 2; y_pos = 12}, /datum/coords {x_pos = 3; y_pos = 12}, /datum/coords {x_pos = 4; y_pos = 12}, /datum/coords {x_pos = 5; y_pos = 12}, /datum/coords {x_pos = 6; y_pos = 12}, /datum/coords {x_pos = 7; y_pos = 12}, /datum/coords {x_pos = 8; y_pos = 12},

		/datum/coords {x_pos = 0; y_pos = 11}, /datum/coords {x_pos = 1; y_pos = 11}, /datum/coords {x_pos = 2; y_pos = 11}, /datum/coords {x_pos = 3; y_pos = 11}, /datum/coords {x_pos = 4; y_pos = 11}, /datum/coords {x_pos = 5; y_pos = 11}, /datum/coords {x_pos = 6; y_pos = 11}, /datum/coords {x_pos = 7; y_pos = 11}, /datum/coords {x_pos = 8; y_pos = 11},

		/datum/coords {x_pos = 0; y_pos = 10}, /datum/coords {x_pos = 1; y_pos = 10}, /datum/coords {x_pos = 2; y_pos = 10}, /datum/coords {x_pos = 3; y_pos = 10}, /datum/coords {x_pos = 4; y_pos = 10}, /datum/coords {x_pos = 5; y_pos = 10}, /datum/coords {x_pos = 6; y_pos = 10}, /datum/coords {x_pos = 7; y_pos = 10}, /datum/coords {x_pos = 8; y_pos = 10},

		/datum/coords {x_pos = 0; y_pos = 9}, /datum/coords {x_pos = 1; y_pos = 9}, /datum/coords {x_pos = 2; y_pos = 9}, /datum/coords {x_pos = 3; y_pos = 9}, /datum/coords {x_pos = 4; y_pos = 9}, /datum/coords {x_pos = 5; y_pos = 9}, /datum/coords {x_pos = 6; y_pos = 9}, /datum/coords {x_pos = 7; y_pos = 9}, /datum/coords {x_pos = 8; y_pos = 9},

		/datum/coords {x_pos = 0; y_pos = 8}, /datum/coords {x_pos = 1; y_pos = 8}, /datum/coords {x_pos = 2; y_pos = 8}, /datum/coords {x_pos = 3; y_pos = 8}, /datum/coords {x_pos = 4; y_pos = 8}, /datum/coords {x_pos = 5; y_pos = 8}, /datum/coords {x_pos = 6; y_pos = 8}, /datum/coords {x_pos = 7; y_pos = 8}, /datum/coords {x_pos = 8; y_pos = 8},

		/datum/coords {x_pos = 0; y_pos = 7}, /datum/coords {x_pos = 1; y_pos = 7}, /datum/coords {x_pos = 2; y_pos = 7}, /datum/coords {x_pos = 3; y_pos = 7}, /datum/coords {x_pos = 4; y_pos = 7}, /datum/coords {x_pos = 5; y_pos = 7}, /datum/coords {x_pos = 6; y_pos = 7}, /datum/coords {x_pos = 7; y_pos = 7}, /datum/coords {x_pos = 8; y_pos = 7},

		/datum/coords {x_pos = 2; y_pos = 6}, /datum/coords {x_pos = 3; y_pos = 6}, /datum/coords {x_pos = 4; y_pos = 6}, /datum/coords {x_pos = 5; y_pos = 6}, /datum/coords {x_pos = 6; y_pos = 6},

		/datum/coords {x_pos = 2; y_pos = 5}, /datum/coords {x_pos = 3; y_pos = 5}, /datum/coords {x_pos = 4; y_pos = 5}, /datum/coords {x_pos = 5; y_pos = 5}, /datum/coords {x_pos = 6; y_pos = 5},

		/datum/coords {x_pos = 1; y_pos = 4}, /datum/coords {x_pos = 2; y_pos = 4}, /datum/coords {x_pos = 3; y_pos = 4}, /datum/coords {x_pos = 4; y_pos = 4}, /datum/coords {x_pos = 5; y_pos = 4}, /datum/coords {x_pos = 6; y_pos = 4}, /datum/coords {x_pos = 7; y_pos = 4},

		/datum/coords {x_pos = 1; y_pos = 3}, /datum/coords {x_pos = 2; y_pos = 3}, /datum/coords {x_pos = 3; y_pos = 3}, /datum/coords {x_pos = 4; y_pos = 3}, /datum/coords {x_pos = 5; y_pos = 3}, /datum/coords {x_pos = 6; y_pos = 3}, /datum/coords {x_pos = 7; y_pos = 3},

		/datum/coords {x_pos = 2; y_pos = 2}, /datum/coords {x_pos = 3; y_pos = 2}, /datum/coords {x_pos = 4; y_pos = 2}, /datum/coords {x_pos = 5; y_pos = 2}, /datum/coords {x_pos = 6; y_pos = 2},

		/datum/coords {x_pos = 3; y_pos = 1}, /datum/coords {x_pos = 4; y_pos = 1}, /datum/coords {x_pos = 5; y_pos = 1},

		/datum/coords {x_pos = 3; y_pos = 0}, /datum/coords {x_pos = 4; y_pos = 0}, /datum/coords {x_pos = 5; y_pos = 0},
	)

	//Droppod
/*

x_pos = 0 1 2 3 4 5 6 7 8
		| | | | | | | | |
		O O O O O O O O O -- y_pos = 9
		O X X X X X X X O -- y_pos = 8
		O X X X X X X X O -- y_pos = 7
		O X X X X X X X O -- y_pos = 6
		O X X X X X X X O -- y_pos = 5
		O X X X X X X X O -- y_pos = 4
		O X X X X X X X O -- y_pos = 3
		O X X X X X X X O -- y_pos = 2
		O X X X X X X X O -- y_pos = 1
		T O O O O O O O O -- y_pos = 0
	*/
	Droppod = newlist(
		/datum/coords {x_pos = 1; y_pos = 7}, /datum/coords {x_pos = 2; y_pos = 7}, /datum/coords {x_pos = 3; y_pos = 7}, /datum/coords {x_pos = 4; y_pos = 7}, /datum/coords {x_pos = 5; y_pos = 7}, /datum/coords {x_pos = 6; y_pos = 7}, /datum/coords {x_pos = 7; y_pos = 7},

		/datum/coords {x_pos = 1; y_pos = 6}, /datum/coords {x_pos = 2; y_pos = 6}, /datum/coords {x_pos = 3; y_pos = 6}, /datum/coords {x_pos = 4; y_pos = 6}, /datum/coords {x_pos = 5; y_pos = 6}, /datum/coords {x_pos = 6; y_pos = 6}, /datum/coords {x_pos = 7; y_pos = 6},

		/datum/coords {x_pos = 1; y_pos = 5}, /datum/coords {x_pos = 2; y_pos = 5}, /datum/coords {x_pos = 3; y_pos = 5}, /datum/coords {x_pos = 4; y_pos = 5}, /datum/coords {x_pos = 5; y_pos = 5}, /datum/coords {x_pos = 6; y_pos = 5}, /datum/coords {x_pos = 7; y_pos = 5},

		/datum/coords {x_pos = 1; y_pos = 4}, /datum/coords {x_pos = 2; y_pos = 4}, /datum/coords {x_pos = 3; y_pos = 4}, /datum/coords {x_pos = 4; y_pos = 4}, /datum/coords {x_pos = 5; y_pos = 4}, /datum/coords {x_pos = 6; y_pos = 4}, /datum/coords {x_pos = 7; y_pos = 4},

		/datum/coords {x_pos = 1; y_pos = 3}, /datum/coords {x_pos = 2; y_pos = 3}, /datum/coords {x_pos = 3; y_pos = 3}, /datum/coords {x_pos = 4; y_pos = 3}, /datum/coords {x_pos = 5; y_pos = 3}, /datum/coords {x_pos = 6; y_pos = 3}, /datum/coords {x_pos = 7; y_pos = 3},

		/datum/coords {x_pos = 1; y_pos = 2}, /datum/coords {x_pos = 2; y_pos = 2}, /datum/coords {x_pos = 3; y_pos = 2}, /datum/coords {x_pos = 4; y_pos = 2}, /datum/coords {x_pos = 5; y_pos = 2}, /datum/coords {x_pos = 6; y_pos = 2}, /datum/coords {x_pos = 7; y_pos = 2},

		/datum/coords {x_pos = 1; y_pos = 1}, /datum/coords {x_pos = 2; y_pos = 1}, /datum/coords {x_pos = 3; y_pos = 1}, /datum/coords {x_pos = 4; y_pos = 1}, /datum/coords {x_pos = 5; y_pos = 1}, /datum/coords {x_pos = 6; y_pos = 1}, /datum/coords {x_pos = 7; y_pos = 1},
	)

/obj/effect/landmark/shuttle_loc
	desc = "The reference landmark for shuttles"
	icon = null

/obj/effect/landmark/shuttle_loc/marine_src

/obj/effect/landmark/shuttle_loc/marine_int

/obj/effect/landmark/shuttle_loc/marine_trg

/obj/effect/landmark/shuttle_loc/marine_crs

/obj/effect/landmark/shuttle_loc/New()
	shuttlemarks += src

/proc/get_shuttle_turfs(var/turf/ref, var/shuttle)
	var/list/L

	switch(shuttle) //Figure out which shuttle we've got here
		if("Dropship 1") L = shuttle_controller.s_info.Rasputin
		if("Dropship 2") L = shuttle_controller.s_info.Droppod
		else L = shuttle_controller.s_info.Unknown //youdonefuckedupnow.gif

	var/list/source = list()

	var/i
	var/datum/coords/C
	for(i in L)
		C = i
		if(!istype(C)) continue
		var/turf/T = locate(ref.x + C.x_pos, ref.y + C.y_pos, ref.z) //Who is in the designated area?
		source += T //We're taking you with us
		source[T] = C //Remember which exact /datum/coords that you used though

	return source

/proc/move_shuttle_to(var/turf/trg, var/turftoleave = null, var/list/source, var/iselevator = 0)

	var/list/update_air = list()
	var/i //iterator

	for(var/turf/T_src in source)
		var/datum/coords/C = source[T_src]
		if(!istype(C)) continue
		var/turf/T_trg = locate(trg.x + C.x_pos, trg.y + C.y_pos, trg.z)

		for(var/obj/O in T_trg)
			if(istype(O, /obj/structure/engine_landing_sound)) continue
			if(istype(O, /obj/effect/effect/smoke)) continue //We land on smoke a lot and it has weird TTL systems that will generate runtimes otherwise
			del(O)

		var/mob/living/carbon/MLC
		for(i in T_trg)
			MLC = i
			if(!istype(MLC)) continue
			MLC.gib()

		var/mob/living/simple_animal/S
		for(i in T_trg)
			S = i
			if(!istype(S)) continue
			S.gib()


		var/old_dir = T_src.dir
		var/old_icon_state = T_src.icon_state
		var/old_icon = T_src.icon

		T_trg.ChangeTurf(T_src.type)
		T_trg.dir = old_dir
		T_trg.icon_state = old_icon_state
		T_trg.icon = old_icon

		//This is weird and oddly neccessary.
		var/turf/simulated/S_src = T_src
		var/turf/simulated/S_trg = T_trg
		if(istype(S_src) && S_src.zone && istype(S_trg) && S_trg.zone)
			if(!S_trg.air)
				S_trg.make_air()
			S_trg.air.copy_from(S_src.air) //TODO: FIX THE BUG INVOLVING THIS PROC
			S_src.zone.remove(S_src)
			update_air += S_src
			update_air += S_trg

		for(var/obj/O in T_src)
			if(!istype(O)) continue
			if(istype(O, /obj/structure/engine_landing_sound)) continue
			O.loc = T_trg

		for(var/mob/M in T_src)
			if(!istype(M)) continue
			M.loc = T_trg

			if(M.client)
				if(M.buckled && !iselevator)
					M << "\red Sudden acceleration presses you into your chair!"
					shake_camera(M, 3, 1)
				else if (!M.buckled)
					M << "\red The floor lurches beneath you!"
					shake_camera(M, iselevator? 2 : 10, 1)
			if(istype(M, /mob/living/carbon) && !iselevator)
				if(!M.buckled)
					M.Weaken(3)

		if(turftoleave && ispath(turftoleave))
			T_src.ChangeTurf(turftoleave)
		else
			T_src.ChangeTurf(/turf/simulated/floor/plating)
/* Commented out since this functionality was moved to /datum/shuttle/ferry/marine/close_doors() and open_doors()
	if(air_master) //*sigh* if that crazy bug is gonna happen, it may as well happen on landing.
		var/turf/T
		for(i in update_air)
			T = i
			if(!istype(T)) continue
			air_master.mark_for_update(T)
*/