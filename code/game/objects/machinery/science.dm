//Random science machines that don't do anything
/obj/machinery/science
	icon = 'icons/obj/machines/virology.dmi'
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000

/obj/machinery/science/isolator
	name = "Isolator"
	icon_state = "isolator_off"

/obj/machinery/science/isolator/on
	icon_state = "isolator"

/obj/machinery/science/isolator/inserted
	icon_state = "isolator_in"

/obj/machinery/science/isolator/processing
	icon_state = "isolator_processing"


/obj/machinery/science/analyser
	name = "Analyser"
	icon_state = "analyser"

/obj/machinery/science/analyser/processing
	icon_state = "analyser_processing"


/obj/machinery/science/incubator
	name = "Incubator"
	icon_state = "incubator"

/obj/machinery/science/incubator/on
	icon_state = "incubator_on"


/obj/machinery/science/centrifuge
	name = "Centrifuge"
	icon_state = "centrifuge0"

/obj/machinery/science/centrifuge/moving
	icon_state = "centrifuge_moving"

/obj/machinery/science/centrifuge/on
	icon_state = "centrifuge"

/obj/machinery/science/centrifuge/broken
	icon_state = "centrifugeb"


/obj/machinery/science/isolation_centerfuge
	name = "Isolation Centerfuge"
	icon_state = "isolation_centerfuge_closed_off"

/obj/machinery/science/isolation_centerfuge/open
	icon_state = "isolation_centerfuge_off_open"

/obj/machinery/science/isolation_centerfuge/open/broken
	icon_state = "isolation_centerfuge_broken_open"

/obj/machinery/science/isolation_centerfuge/on/closed
	icon_state = "isolation_centerfuge_closed_on"

/obj/machinery/science/isolation_centerfuge/on/open
	icon_state = "isolation_centerfuge_on_open"

/obj/machinery/science/isolation_centerfuge/on/closed/spin
	icon_state = "isolation_centerfuge_closed_on_spin"


/obj/machinery/science/pathogenic_incubator
	name = "Pathogenic Incubator"
	icon_state = "pathogenic_incubator_closed_off"

/obj/machinery/science/pathogenic_incubator/open
	icon_state = "pathogenic_incubator_open"

/obj/machinery/science/pathogenic_incubator/opening
	icon_state = "pathogenic_incubator_opening_animation"

/obj/machinery/science/pathogenic_incubator/on
	icon_state = "pathogenic_incubator_on"


/obj/machinery/science/pathogenic_Isolator
	name = "Pathogenic Isolator"
	icon_state = "Pathogenic_Isolator_empty_off"

/obj/machinery/science/pathogenic_Isolator/inserted
	icon_state = "Pathogenic_Isolator_syringein_off"

/obj/machinery/science/athogenic_Isolator/on
	icon_state = "Pathogenic_Isolator_on_empty"

/obj/machinery/science/athogenic_Isolator/on/inserted
	icon_state = "Pathogenic_Isolator_syringein_on"

/obj/machinery/science/microscope
	name = "Microscope"
	icon_state = "microscope"

/obj/machinery/science/microscope/slide
	icon_state = "microscopeslide"
