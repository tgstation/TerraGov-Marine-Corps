/obj/effect/spawner/modularmap
	name = "Modular map marker"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_map"
	dir = NORTH
	///The ID of the types we would like to be choosing from
	var/mapid
	///How high our spawner area is, used to catch mistakes in mapping
	var/spawner_height = 0
	///How wide our spawner area is, used to catch mistakes in mapping
	var/spawner_width = 0

/obj/effect/spawner/modularmap/Initialize(mapload)
	. = ..()
	SSmodularmapping.markers += src

///Actually loads the modularmap: called by SSmodularmapping
/obj/effect/spawner/modularmap/proc/load_modularmap()
	var/datum/map_template/modular/template
	template = pick(SSmapping.modular_templates[mapid])
	var/errored = FALSE
	if(!istype(template, /datum/map_template/modular))
		stack_trace("A spawner has an invalid template")
		errored = TRUE
	if(spawner_height != template.template_height)
		stack_trace("A spawner has an invalid height")
		errored = TRUE
	if(spawner_width != template.template_width)
		stack_trace("A spawner has an invalid width")
		errored = TRUE
	if(errored)
		return
	if(!template)
		stack_trace("Mapping error: room loaded with no template")
		message_admins("Warning, modular mapping error, please report this to coders and get it fixed ASAP")
		qdel(src)
		return
	var/turf/loadloc = get_turf(src)
	qdel(src)
	template.load(loadloc, template.keepcentered)

/*********Types********/

/*****Prison / Fiona penitentiary****/
/obj/effect/spawner/modularmap/prison/civressouth
	mapid = "southcivres"
	spawner_width = 9
	spawner_height = 11

/************LV 624**********/
/obj/effect/spawner/modularmap/lv624/hydroroad
	mapid = "hydroroad"
	spawner_height = 20
	spawner_width = 20

/obj/effect/spawner/modularmap/lv624/domes
	mapid = "lvdome"
	spawner_height = 15
	spawner_width = 15

/obj/effect/spawner/modularmap/lv624/medicaldome
	mapid = "lvmedicaldome"
	spawner_height = 15
	spawner_width = 15

/obj/effect/spawner/modularmap/lv624/largecentralcave
	mapid = "lvcaveslakearea"
	spawner_height = 33
	spawner_width = 80

/obj/effect/spawner/modularmap/lv624/hydrobridge
	mapid = "lvhydrobridge"
	spawner_height = 10
	spawner_width = 8

/obj/effect/spawner/modularmap/lv624/southsandtemple
	mapid = "lvsouthsandtemple"
	spawner_height = 24
	spawner_width = 22

/************BIG RED******/
/obj/effect/spawner/modularmap/bigred/operations
	mapid = "broperations"
	spawner_width = 29
	spawner_height = 24

/obj/effect/spawner/modularmap/bigred/fence
	mapid = "brfence"
	spawner_width = 24
	spawner_height = 8

/obj/effect/spawner/modularmap/bigred/medbay
	mapid = "brmedbay"
	spawner_width = 33
	spawner_height = 26

/obj/effect/spawner/modularmap/bigred/medbaypassage
	mapid = "brmedbaypassage"
	spawner_width = 6
	spawner_height = 3

/obj/effect/spawner/modularmap/bigred/generalstore
	mapid = "brgeneral"
	spawner_width = 31
	spawner_height = 14

/obj/effect/spawner/modularmap/bigred/chapel
	mapid = "brchapel"
	spawner_width = 18
	spawner_height = 9

/obj/effect/spawner/modularmap/bigred/eta
	mapid = "breta"
	spawner_width = 26
	spawner_height = 24

/obj/effect/spawner/modularmap/bigred/lambdatunnel
	mapid = "brlambdatunnel"
	spawner_width = 25
	spawner_height = 6

/obj/effect/spawner/modularmap/bigred/lambdacave
	mapid = "brlambdacave"
	spawner_width = 15
	spawner_height = 15

/obj/effect/spawner/modularmap/bigred/dorms
	mapid = "brdorms"
	spawner_width = 19
	spawner_height = 7

/obj/effect/spawner/modularmap/bigred/cargo
	mapid = "brcargo"
	spawner_width = 19
	spawner_height = 19

/obj/effect/spawner/modularmap/bigred/engineering
	mapid = "brengineering"
	spawner_width = 30
	spawner_height = 27

/obj/effect/spawner/modularmap/bigred/atmos
	mapid = "bratmos"
	spawner_width = 24
	spawner_height = 25

/obj/effect/spawner/modularmap/bigred/cargoentry
	mapid = "brcargoentry"
	spawner_width = 3
	spawner_height = 5

/obj/effect/spawner/modularmap/bigred/northlambda
	mapid = "brlambdatunnelnorth"
	spawner_width = 65
	spawner_height = 32

/obj/effect/spawner/modularmap/bigred/westeta
	mapid = "brsouthwesteta"
	spawner_width = 61
	spawner_height = 38

/obj/effect/spawner/modularmap/bigred/southeta
	mapid = "brsoutheta"
	spawner_width = 23
	spawner_height = 10

/obj/effect/spawner/modularmap/bigred/checkpointsouth
	mapid = "brcheckpointsouth"
	spawner_width = 12
	spawner_height = 10

/obj/effect/spawner/modularmap/bigred/checkpoint
	mapid = "brcheckpoint"
	spawner_width = 4
	spawner_height = 4

/obj/effect/spawner/modularmap/bigred/southwesteast
	mapid = "brsweast"
	spawner_width = 44
	spawner_height = 22

/obj/effect/spawner/modularmap/bigred/toolshed
	mapid = "brtoolshed"
	spawner_width = 16
	spawner_height = 9

/obj/effect/spawner/modularmap/bigred/secorner
	mapid = "brsecorner"
	spawner_width = 71
	spawner_height = 67

/obj/effect/spawner/modularmap/bigred/swcorner
	mapid = "brswcorner"
	spawner_width = 41
	spawner_height = 43

/obj/effect/spawner/modularmap/bigred/lambdalock
	mapid = "brlambdalock"
	spawner_width = 1
	spawner_height = 2

/obj/effect/spawner/modularmap/bigred/lambdatunnelsouth
	mapid = "brlambdatunnelsouth"
	spawner_width = 22
	spawner_height = 11

/obj/effect/spawner/modularmap/bigred/library
	mapid = "brlibrary"
	spawner_width = 11
	spawner_height = 18

/obj/effect/spawner/modularmap/bigred/office
	mapid = "broffice"
	spawner_width = 28
	spawner_height = 23

/obj/effect/spawner/modularmap/bigred/east
	mapid = "breastcaves"
	spawner_width = 66
	spawner_height = 42

/obj/effect/spawner/modularmap/bigred/cargoarea
	mapid = "brcargoarea"
	spawner_width = 54
	spawner_height = 22

/************OSCAR OUTPOST**********/
/obj/effect/spawner/modularmap/oscaroutposttophalf
	mapid = "oscartop"
	spawner_width = 150
	spawner_height = 153

/obj/effect/spawner/modularmap/oscaroutpostbase
	mapid = "oscarbase"
	spawner_width = 79
	spawner_height = 29

/************EORG**********/
/obj/effect/spawner/modularmap/admin/eorg
	mapid = "EORG"
	spawner_height = 46
	spawner_width = 46
