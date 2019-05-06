/obj/machinery/compressor
	name = "compressor"
	desc = "The compressor stage of a gas turbine generator."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "compressor"
	anchored = 1
	density = 1

/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "turbine"
	anchored = 1
	density = 1

/obj/machinery/computer/turbine_computer
	name = "Gas turbine control computer"
	desc = "A computer to remotely control a gas turbine"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "turbinecomp"
	//circuit = /obj/item/circuitboard/computer/turbine_control
	anchored = 1
	density = 1

/obj/machinery/power/turbinemotor
	name = "motor"
	desc = "Electrogenerator. Converts rotation into power."
	icon = 'icons/obj/pipeturbine.dmi'
	icon_state = "motor"
	anchored = 0
	density = 1