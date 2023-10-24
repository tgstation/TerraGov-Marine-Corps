/obj/machinery/computer/gravity_control_computer
	name = "Gravity Generator Control"
	desc = "A computer to control a local gravity generator.  Qualified personnel only."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	screen_overlay = "airtunnel0e"
	broken_icon = "computer_blue_broken"
	anchored = TRUE
	density = TRUE


/obj/machinery/gravity_generator
	name = "Gravitational Generator"
	desc = "A device which produces a gravaton field when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = TRUE
	density = TRUE
	use_power = TRUE
