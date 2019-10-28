// prison monorail
/obj/docking_port/stationary/monorail_west
	name = "monorail west port"
	id = "monorailwest"
	dir = SOUTH
	width = 5
	height = 15
	dwidth = 2
	dheight = 7

/obj/docking_port/stationary/monorail_east
	name = "monorail east port"
	id = "monoraileast"
	dir = SOUTH
	width = 5
	height = 15
	dwidth = 2
	dheight = 7
	roundstart_template = /datum/map_template/shuttle/monorail

/obj/docking_port/mobile/monorail
	name = "monorail"
	id = "monorail"
	dir = SOUTH
	width = 5
	height = 15
	dwidth = 2
	dheight = 7

/obj/machinery/computer/shuttle/monorail
	name = "monorail control console"
	desc = "You find yourself at a console. A runaway monorail approaches five people who are tied to a set of tracks. There is a button on the console that will divert the monorail to a different set of tracks, where only one person is tied down. Do you press the button?"
	possible_destinations = "monoraileast;monorailwest"
