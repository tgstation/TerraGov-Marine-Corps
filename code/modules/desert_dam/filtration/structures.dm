/turf/open/floor/filtrationside
	name = "filtration"
	icon = 'icons/turf/floors/filtration.dmi'
	icon_state = "filtrationside"

/turf/open/floor/plating/catwalk/rusted
	icon = 'icons/turf/floors/filtration.dmi'
	icon_state = "grate"

/turf/open/floor/coagulation
	name = "coagulation"
	icon = 'icons/obj/filtration/coagulation.dmi'

/obj/structure/filtration
	icon = 'icons/obj/filtration/96x96.dmi'
	bound_x = 96
	bound_y = 96
	density = 1

/obj/structure/filtration/coagulation_arm
	name = "coagulation arm"
	desc = "An axel with four sides, made to spin to help filter the water."
	icon = 'icons/obj/filtration/coagulation_arm.dmi'
	icon_state = "arm"

/obj/structure/filtration/collector_pipes
	name = "collection pipes"
	desc = "A series of pipes collecting water from the river to take it to the plant for filtration."
	icon = 'icons/obj/filtration/pipes.dmi'
	icon_state = "upper_1" //use instances to set the types.
	bound_y = 32
	bound_x = 64

/obj/structure/filtration/distribution
	name = "distribution"
	icon_state = "distribution"

/obj/structure/filtration/sedementation
	name = "sedementation"
	icon_state = "sedementation"

/obj/structure/filtration/filtrator
	name = "filtrator"
	icon_state = "filtration"

/obj/structure/filtration/disinfection
	name = "disinfection"
	icon_state = "disinfection"