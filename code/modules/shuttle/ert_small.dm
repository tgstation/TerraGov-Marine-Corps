// small ert shuttles
/obj/docking_port/stationary/ert_small
	name = "ert shuttle"
	id = "distress"
	dir = SOUTH
	dwidth = 3
	width = 7
	height = 13

/obj/docking_port/stationary/ert_small/centcomm
	roundstart_template = /datum/map_template/shuttle/small_ert

/obj/docking_port/stationary/ert_small/pmc/centcomm
	id = "distress_pmc"
	roundstart_template = /datum/map_template/shuttle/small_ert/pmc

/obj/docking_port/stationary/ert_small/upp/centcomm
	id = "distress_upp"
	roundstart_template = /datum/map_template/shuttle/small_ert/upp

/obj/docking_port/mobile/ert_small
	name = "ert shuttle"
	dir = SOUTH
	dwidth = 5
	width = 11
	height = 21
