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



/proc/rotate_shuttle_turfs(var/list/L, var/deg = 0)
--------------------------------
L: The shuttle turfs to rotate. MUST be coord datums indexed by turf, a la get_shuttle_turfs()
deg: In degrees, how much to rotate the shuttle (clockwise).

Return: the new list on success, null on failure

Notes:
If deg % 90 != 0 then this will return 0
When using this in-game, this will rotate treating the reference turf as the origin,
so keep in mind that a 180 degree turn will reflect the shuttle through the turf,
e.g. Something up to the right relative to its landmark will end up down to the left
ONLY called when moving to either the trg landmark or a crs landmark


/proc/move_shuttle_to(var/turf/trg, var/turftoleave = null, var/list/source, var/iselevator = 0, datum/shuttle/ferry/marine/shuttle)
--------------------------------
trg: The target reference turf, see var/turf/ref from the previous proc
turftoleave: Allows leaving other turfs behind as needed. Note: must be a path
source: A list of coordinate datums indexed by turfs. See Return from the previous proc
iselevator: Used as a simple boolean. Dictates whether or not the shuttle is in fact an elevator

The shuttle variable should always be present to reference back the existing shuttle.
Should be reworked in the future. Right now it references evac pods only, and only matters for them,
but it should be brought up to all marine ferries.

Notes:
iselevator is admittedly a hair "hacky"
TODO: Create /datum/shuttle/ferry/marine/elevator and depreciate this

*/

var/global/list/s_info = null

/hook/startup/proc/loadShuttleInfoDatums()
	s_info = list()

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

	/*
	s_info["ERROR"] = newlist(
		/datum/coords {x_pos = -1; y_pos = 1}, /datum/coords {x_pos = 0; y_pos = 1}, /datum/coords {x_pos = 1; y_pos = 1},
		/datum/coords {x_pos = -1; y_pos = 0}, /datum/coords {x_pos = 0; y_pos = 0}, /datum/coords {x_pos = 1; y_pos = 0},
		/datum/coords {x_pos = -1; y_pos = -1}, /datum/coords {x_pos = 0; y_pos = -1}, /datum/coords {x_pos = 1; y_pos = -1}
	)
	*/

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
	s_info["Dropship 1"] = newlist(
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
	s_info["Dropship 2"] = newlist(
		/datum/coords {x_pos = 1; y_pos = 7}, /datum/coords {x_pos = 2; y_pos = 7}, /datum/coords {x_pos = 3; y_pos = 7}, /datum/coords {x_pos = 4; y_pos = 7}, /datum/coords {x_pos = 5; y_pos = 7}, /datum/coords {x_pos = 6; y_pos = 7}, /datum/coords {x_pos = 7; y_pos = 7},

		/datum/coords {x_pos = 1; y_pos = 6}, /datum/coords {x_pos = 2; y_pos = 6}, /datum/coords {x_pos = 3; y_pos = 6}, /datum/coords {x_pos = 4; y_pos = 6}, /datum/coords {x_pos = 5; y_pos = 6}, /datum/coords {x_pos = 6; y_pos = 6}, /datum/coords {x_pos = 7; y_pos = 6},

		/datum/coords {x_pos = 1; y_pos = 5}, /datum/coords {x_pos = 2; y_pos = 5}, /datum/coords {x_pos = 3; y_pos = 5}, /datum/coords {x_pos = 4; y_pos = 5}, /datum/coords {x_pos = 5; y_pos = 5}, /datum/coords {x_pos = 6; y_pos = 5}, /datum/coords {x_pos = 7; y_pos = 5},

		/datum/coords {x_pos = 1; y_pos = 4}, /datum/coords {x_pos = 2; y_pos = 4}, /datum/coords {x_pos = 3; y_pos = 4}, /datum/coords {x_pos = 4; y_pos = 4}, /datum/coords {x_pos = 5; y_pos = 4}, /datum/coords {x_pos = 6; y_pos = 4}, /datum/coords {x_pos = 7; y_pos = 4},

		/datum/coords {x_pos = 1; y_pos = 3}, /datum/coords {x_pos = 2; y_pos = 3}, /datum/coords {x_pos = 3; y_pos = 3}, /datum/coords {x_pos = 4; y_pos = 3}, /datum/coords {x_pos = 5; y_pos = 3}, /datum/coords {x_pos = 6; y_pos = 3}, /datum/coords {x_pos = 7; y_pos = 3},

		/datum/coords {x_pos = 1; y_pos = 2}, /datum/coords {x_pos = 2; y_pos = 2}, /datum/coords {x_pos = 3; y_pos = 2}, /datum/coords {x_pos = 4; y_pos = 2}, /datum/coords {x_pos = 5; y_pos = 2}, /datum/coords {x_pos = 6; y_pos = 2}, /datum/coords {x_pos = 7; y_pos = 2},

		/datum/coords {x_pos = 1; y_pos = 1}, /datum/coords {x_pos = 2; y_pos = 1}, /datum/coords {x_pos = 3; y_pos = 1}, /datum/coords {x_pos = 4; y_pos = 1}, /datum/coords {x_pos = 5; y_pos = 1}, /datum/coords {x_pos = 6; y_pos = 1}, /datum/coords {x_pos = 7; y_pos = 1},
	)

	//Almayer Evac Pods
/*
x_pos = 0 1 2 3 4 5
		| | | | | |
		O O O O O O -- y_pos = 6
		O X X X X O -- y_pos = 5
		O X X X X O -- y_pos = 4
		O X X X X O -- y_pos = 3
		O X X X X O -- y_pos = 2
		O X X X X O -- y_pos = 1
		T O O O O O -- y_pos = 0
	*/
	s_info["Almayer Evac"] = newlist(
		/datum/coords {x_pos = 1; y_pos = 5}, /datum/coords {x_pos = 2; y_pos = 5}, /datum/coords {x_pos = 3; y_pos = 5}, /datum/coords {x_pos = 4; y_pos = 5},

		/datum/coords {x_pos = 1; y_pos = 4}, /datum/coords {x_pos = 2; y_pos = 4}, /datum/coords {x_pos = 3; y_pos = 4}, /datum/coords {x_pos = 4; y_pos = 4},

		/datum/coords {x_pos = 1; y_pos = 3}, /datum/coords {x_pos = 2; y_pos = 3}, /datum/coords {x_pos = 3; y_pos = 3}, /datum/coords {x_pos = 4; y_pos = 3},

		/datum/coords {x_pos = 1; y_pos = 2}, /datum/coords {x_pos = 2; y_pos = 2}, /datum/coords {x_pos = 3; y_pos = 2}, /datum/coords {x_pos = 4; y_pos = 2},

		/datum/coords {x_pos = 1; y_pos = 1}, /datum/coords {x_pos = 2; y_pos = 1}, /datum/coords {x_pos = 3; y_pos = 1}, /datum/coords {x_pos = 4; y_pos = 1}
	)

	//Alternate Almayer Evac Pods
/*
x_pos = 0 1 2 3 4 5 6
		| | | | | | |
		O O O O O O O -- y_pos = 5
		O X X X X X O -- y_pos = 4
		O X X X X X O -- y_pos = 3
		O X X X X X O -- y_pos = 2
		O X X X X X O -- y_pos = 1
		T O O O O O O -- y_pos = 0
	*/
	s_info["Alt Almayer Evac"] = newlist(
		/datum/coords {x_pos = 1; y_pos = 4}, /datum/coords {x_pos = 2; y_pos = 4}, /datum/coords {x_pos = 3; y_pos = 4}, /datum/coords {x_pos = 4; y_pos = 4}, /datum/coords {x_pos = 5; y_pos = 4},

		/datum/coords {x_pos = 1; y_pos = 3}, /datum/coords {x_pos = 2; y_pos = 3}, /datum/coords {x_pos = 3; y_pos = 3}, /datum/coords {x_pos = 4; y_pos = 3}, /datum/coords {x_pos = 5; y_pos = 3},

		/datum/coords {x_pos = 1; y_pos = 2}, /datum/coords {x_pos = 2; y_pos = 2}, /datum/coords {x_pos = 3; y_pos = 2}, /datum/coords {x_pos = 4; y_pos = 2}, /datum/coords {x_pos = 5; y_pos = 2},

		/datum/coords {x_pos = 1; y_pos = 1}, /datum/coords {x_pos = 2; y_pos = 1}, /datum/coords {x_pos = 3; y_pos = 1}, /datum/coords {x_pos = 4; y_pos = 1}, /datum/coords {x_pos = 5; y_pos = 1}
	)

	//Almayer Dropship

	s_info["Almayer Dropship"] = newlist(

	/datum/coords{x_pos=4;y_pos=20}, /datum/coords{x_pos=5;y_pos=20}, /datum/coords{x_pos=6;y_pos=20},

	/datum/coords{x_pos=4;y_pos=19}, /datum/coords{x_pos=5;y_pos=19}, /datum/coords{x_pos=6;y_pos=19},

	/datum/coords{x_pos=4;y_pos=18}, /datum/coords{x_pos=5;y_pos=18}, /datum/coords{x_pos=6;y_pos=18},

	/datum/coords{x_pos=1;y_pos=17}, /datum/coords{x_pos=2;y_pos=17}, /datum/coords{x_pos=3;y_pos=17}, /datum/coords{x_pos=4;y_pos=17}, /datum/coords{x_pos=5;y_pos=17}, /datum/coords{x_pos=6;y_pos=17}, /datum/coords{x_pos=7;y_pos=17}, /datum/coords{x_pos=8;y_pos=17}, /datum/coords{x_pos=9;y_pos=17},

	/datum/coords{x_pos=1;y_pos=16}, /datum/coords{x_pos=2;y_pos=16}, /datum/coords{x_pos=3;y_pos=16}, /datum/coords{x_pos=4;y_pos=16}, /datum/coords{x_pos=5;y_pos=16}, /datum/coords{x_pos=6;y_pos=16}, /datum/coords{x_pos=7;y_pos=16}, /datum/coords{x_pos=8;y_pos=16}, /datum/coords{x_pos=9;y_pos=16},

	/datum/coords{x_pos=0;y_pos=15}, /datum/coords{x_pos=1;y_pos=15}, /datum/coords{x_pos=2;y_pos=15}, /datum/coords{x_pos=3;y_pos=15}, /datum/coords{x_pos=4;y_pos=15}, /datum/coords{x_pos=5;y_pos=15}, /datum/coords{x_pos=6;y_pos=15}, /datum/coords{x_pos=7;y_pos=15}, /datum/coords{x_pos=8;y_pos=15}, /datum/coords{x_pos=9;y_pos=15}, /datum/coords{x_pos=10;y_pos=15},

	/datum/coords{x_pos=0;y_pos=14}, /datum/coords{x_pos=1;y_pos=14}, /datum/coords{x_pos=2;y_pos=14}, /datum/coords{x_pos=3;y_pos=14}, /datum/coords{x_pos=4;y_pos=14}, /datum/coords{x_pos=5;y_pos=14}, /datum/coords{x_pos=6;y_pos=14}, /datum/coords{x_pos=7;y_pos=14}, /datum/coords{x_pos=8;y_pos=14}, /datum/coords{x_pos=9;y_pos=14}, /datum/coords{x_pos=10;y_pos=14},

	/datum/coords{x_pos=0;y_pos=13}, /datum/coords{x_pos=1;y_pos=13}, /datum/coords{x_pos=2;y_pos=13}, /datum/coords{x_pos=3;y_pos=13}, /datum/coords{x_pos=4;y_pos=13}, /datum/coords{x_pos=5;y_pos=13}, /datum/coords{x_pos=6;y_pos=13}, /datum/coords{x_pos=7;y_pos=13}, /datum/coords{x_pos=8;y_pos=13}, /datum/coords{x_pos=9;y_pos=13}, /datum/coords{x_pos=10;y_pos=13},

	/datum/coords{x_pos=1;y_pos=12}, /datum/coords{x_pos=2;y_pos=12}, /datum/coords{x_pos=3;y_pos=12}, /datum/coords{x_pos=4;y_pos=12}, /datum/coords{x_pos=5;y_pos=12}, /datum/coords{x_pos=6;y_pos=12}, /datum/coords{x_pos=7;y_pos=12}, /datum/coords{x_pos=8;y_pos=12}, /datum/coords{x_pos=9;y_pos=12},

	/datum/coords{x_pos=1;y_pos=11}, /datum/coords{x_pos=2;y_pos=11}, /datum/coords{x_pos=3;y_pos=11}, /datum/coords{x_pos=4;y_pos=11}, /datum/coords{x_pos=5;y_pos=11}, /datum/coords{x_pos=6;y_pos=11}, /datum/coords{x_pos=7;y_pos=11}, /datum/coords{x_pos=8;y_pos=11}, /datum/coords{x_pos=9;y_pos=11},

	/datum/coords{x_pos=1;y_pos=10}, /datum/coords{x_pos=2;y_pos=10}, /datum/coords{x_pos=3;y_pos=10}, /datum/coords{x_pos=4;y_pos=10}, /datum/coords{x_pos=5;y_pos=10}, /datum/coords{x_pos=6;y_pos=10}, /datum/coords{x_pos=7;y_pos=10}, /datum/coords{x_pos=8;y_pos=10}, /datum/coords{x_pos=9;y_pos=10},

	/datum/coords{x_pos=1;y_pos=9}, /datum/coords{x_pos=2;y_pos=9}, /datum/coords{x_pos=3;y_pos=9}, /datum/coords{x_pos=4;y_pos=9}, /datum/coords{x_pos=5;y_pos=9}, /datum/coords{x_pos=6;y_pos=9}, /datum/coords{x_pos=7;y_pos=9}, /datum/coords{x_pos=8;y_pos=9}, /datum/coords{x_pos=9;y_pos=9},

	/datum/coords{x_pos=1;y_pos=8}, /datum/coords{x_pos=2;y_pos=8}, /datum/coords{x_pos=3;y_pos=8}, /datum/coords{x_pos=4;y_pos=8}, /datum/coords{x_pos=5;y_pos=8}, /datum/coords{x_pos=6;y_pos=8}, /datum/coords{x_pos=7;y_pos=8}, /datum/coords{x_pos=8;y_pos=8}, /datum/coords{x_pos=9;y_pos=8},

	/datum/coords{x_pos=0;y_pos=7}, /datum/coords{x_pos=1;y_pos=7}, /datum/coords{x_pos=2;y_pos=7}, /datum/coords{x_pos=3;y_pos=7}, /datum/coords{x_pos=4;y_pos=7}, /datum/coords{x_pos=5;y_pos=7}, /datum/coords{x_pos=6;y_pos=7}, /datum/coords{x_pos=7;y_pos=7}, /datum/coords{x_pos=8;y_pos=7}, /datum/coords{x_pos=9;y_pos=7}, /datum/coords{x_pos=10;y_pos=7},

	/datum/coords{x_pos=0;y_pos=6}, /datum/coords{x_pos=1;y_pos=6}, /datum/coords{x_pos=2;y_pos=6}, /datum/coords{x_pos=3;y_pos=6}, /datum/coords{x_pos=4;y_pos=6}, /datum/coords{x_pos=5;y_pos=6}, /datum/coords{x_pos=6;y_pos=6}, /datum/coords{x_pos=7;y_pos=6}, /datum/coords{x_pos=8;y_pos=6}, /datum/coords{x_pos=9;y_pos=6}, /datum/coords{x_pos=10;y_pos=6},

	/datum/coords{x_pos=0;y_pos=5}, /datum/coords{x_pos=1;y_pos=5}, /datum/coords{x_pos=2;y_pos=5}, /datum/coords{x_pos=3;y_pos=5}, /datum/coords{x_pos=4;y_pos=5}, /datum/coords{x_pos=5;y_pos=5}, /datum/coords{x_pos=6;y_pos=5}, /datum/coords{x_pos=7;y_pos=5}, /datum/coords{x_pos=8;y_pos=5}, /datum/coords{x_pos=9;y_pos=5}, /datum/coords{x_pos=10;y_pos=5},

	/datum/coords{x_pos=0;y_pos=4}, /datum/coords{x_pos=1;y_pos=4}, /datum/coords{x_pos=2;y_pos=4}, /datum/coords{x_pos=3;y_pos=4}, /datum/coords{x_pos=4;y_pos=4}, /datum/coords{x_pos=5;y_pos=4}, /datum/coords{x_pos=6;y_pos=4}, /datum/coords{x_pos=7;y_pos=4}, /datum/coords{x_pos=8;y_pos=4}, /datum/coords{x_pos=9;y_pos=4}, /datum/coords{x_pos=10;y_pos=4},

	/datum/coords{x_pos=0;y_pos=3}, /datum/coords{x_pos=1;y_pos=3}, /datum/coords{x_pos=2;y_pos=3}, /datum/coords{x_pos=3;y_pos=3}, /datum/coords{x_pos=4;y_pos=3}, /datum/coords{x_pos=5;y_pos=3}, /datum/coords{x_pos=6;y_pos=3}, /datum/coords{x_pos=7;y_pos=3}, /datum/coords{x_pos=8;y_pos=3}, /datum/coords{x_pos=9;y_pos=3}, /datum/coords{x_pos=10;y_pos=3},

	/datum/coords{x_pos=2;y_pos=2}, /datum/coords{x_pos=3;y_pos=2}, /datum/coords{x_pos=4;y_pos=2}, /datum/coords{x_pos=5;y_pos=2}, /datum/coords{x_pos=6;y_pos=2}, /datum/coords{x_pos=7;y_pos=2}, /datum/coords{x_pos=8;y_pos=2},

	/datum/coords{x_pos=3;y_pos=1}, /datum/coords{x_pos=7;y_pos=1},

	/datum/coords{x_pos=1;y_pos=0}, /datum/coords{x_pos=2;y_pos=0}, /datum/coords{x_pos=3;y_pos=0}, /datum/coords{x_pos=7;y_pos=0}, /datum/coords{x_pos=8;y_pos=0}, /datum/coords{x_pos=9;y_pos=0},

	)

	return 1

/obj/effect/landmark/shuttle_loc
	desc = "The reference landmark for shuttles"
	icon = 'icons/misc/mark.dmi'
	icon_state = "spawn_shuttle"
	var/rotation = 0 //When loading to this landmark, how much to rotate the turfs. See /proc/rotate_shuttle_turfs()

	New()
		set waitfor = 0
		..()

/obj/effect/landmark/shuttle_loc/marine_src
	icon_state = "spawn_shuttle_dock"
/obj/effect/landmark/shuttle_loc/marine_int
	icon_state = "spawn_shuttle_move"
/obj/effect/landmark/shuttle_loc/marine_trg
	icon_state = "spawn_shuttle_land"
/obj/effect/landmark/shuttle_loc/marine_crs
	icon_state = "spawn_shuttle_crash"

#define SHUTTLE_LINK_LOCATIONS(T, L) \
sleep(50); \
..(); \
var/datum/shuttle/ferry/marine/S = shuttle_controller.shuttles["[MAIN_SHIP_NAME] [T] [name]"]; \
if(!S) {log_debug("ERROR CODE SO1: unable to find shuttle with the tag of: ["[MAIN_SHIP_NAME] [T] [name]"]."); \
r_FAL}; \
L[get_turf(src)] = rotation; \
cdel(src)

/obj/effect/landmark/shuttle_loc/marine_src/dropship //Name these "1" or "2", etc.
	New()
		SHUTTLE_LINK_LOCATIONS("Dropship", S.locs_dock)

/obj/effect/landmark/shuttle_loc/marine_src/evacuation
	New()
		sleep(50)
		..()
		var/datum/shuttle/ferry/marine/evacuation_pod/S = shuttle_controller.shuttles["[MAIN_SHIP_NAME] Evac [name]"]
		if(!S)
			log_debug("ERROR CODE SO1: unable to find shuttle with the tag of: ["[MAIN_SHIP_NAME] Evac [name]"].")
			r_FAL
		S.locs_dock[get_turf(src)] = rotation
		S.link_support_units(get_turf(src)) //Process links.
		cdel(src)

/obj/effect/landmark/shuttle_loc/marine_int/dropship
	New()
		SHUTTLE_LINK_LOCATIONS("Dropship", S.locs_move)

/obj/effect/landmark/shuttle_loc/marine_trg/landing
	New()
		SHUTTLE_LINK_LOCATIONS("Dropship", S.locs_land)

/obj/effect/landmark/shuttle_loc/marine_trg/evacuation
	New()
		SHUTTLE_LINK_LOCATIONS("Evac", S.locs_land)

/obj/effect/landmark/shuttle_loc/marine_crs/dropship
	New()
		sleep(50)
		..()
		shuttle_controller.locs_crash[get_turf(src)] = rotation
		cdel(src)

#undef SHUTTLE_LINK_LOCATIONS

/proc/get_shuttle_turfs(var/turf/ref, var/list/L)

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

/proc/rotate_shuttle_turfs(var/list/L, var/deg = 0)

	if((deg % 90) != 0) return //Not a right or straight angle, don't do anything
	if(!istype(L) || !L.len) return null

	var/i //iterator
	var/x //Placeholder while we do math
	var/y //Placeholder while we do math
	var/datum/coords/C
	var/datum/coords/C1
	var/list/toReturn = list()
	for(i in L)
		C = L[i]
		if(!istype(C)) continue
		C1 = new
		x = C.x_pos
		y = C.y_pos
		C1.x_pos = x*cos(deg) + y*sin(deg)
		C1.y_pos = y*cos(deg) - x*sin(deg)
		C1.x_pos = roundNearest(C.x_pos) //Sometimes you get very close to the right number but off by around 1e-15 and I want integers dammit
		C1.y_pos = roundNearest(C.y_pos)
		toReturn += i
		toReturn[i] = C1

	return toReturn

/proc/move_shuttle_to(turf/trg, turftoleave = null, list/source, iselevator = 0, deg = 0, datum/shuttle/ferry/marine/shuttle)

	//var/list/turfsToUpdate = list()
	var/i //iterator

	if(shuttle.sound_misc) playsound(source[shuttle.sound_target], shuttle.sound_misc, 75, 1)

	source = rotate_shuttle_turfs(source, deg)

	for(var/turf/T_src in source)
		var/datum/coords/C = source[T_src]
		if(!istype(C)) continue
		var/turf/T_trg = locate(trg.x + C.x_pos, trg.y + C.y_pos, trg.z)

		for(var/obj/O in T_trg)
			if(istype(O, /obj/effect/particle_effect/smoke)) continue //We land on smoke a lot and it has weird TTL systems that will generate runtimes otherwise
			cdel(O)

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

		for(var/obj/O in T_src)
			if(!istype(O)) continue
			O.loc = T_trg

		for(var/mob/M in T_src)
			if(!istype(M)) continue
			M.loc = T_trg

			if(M.client)
				if(M.buckled && !iselevator)
					M << "<span class='warning'>Sudden acceleration presses you into [M.buckled]!</span>"
					shake_camera(M, 3, 1)
				else if (!M.buckled)
					M << "<span class='warning'>The floor lurches beneath you!</span>"
					shake_camera(M, iselevator? 2 : 10, 1)
			if(istype(M, /mob/living/carbon) && !iselevator)
				if(!M.buckled)
					M.KnockDown(3)

		if(turftoleave && ispath(turftoleave))
			T_src.ChangeTurf(turftoleave)
		else
			T_src.ChangeTurf(/turf/simulated/floor/plating)

	/*
	Commented out since it doesn't do anything with shuttle walls and the like yet.
	It will pending smoothwall.dm rewrite

	if(deg) //If we rotated, update the icons
		i = null //reset it, cuz why not
		var/j //iterator
		var/turf/updating
		for(i in turfsToUpdate)
			updating = i
			if(!istype(updating)) continue
			updating.relativewall()
	*/

/* Commented out since this functionality was moved to /datum/shuttle/ferry/marine/close_doors() and open_doors()
	if(air_master) //*sigh* if that crazy bug is gonna happen, it may as well happen on landing.
		var/turf/T
		for(i in update_air)
			T = i
			if(!istype(T)) continue
			air_master.mark_for_update(T)
*/
