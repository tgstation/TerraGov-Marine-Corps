/obj/machinery/the_singularitygen/tesla
	name = "energy ball generator"
	desc = ""
	icon = 'icons/obj/tesla_engine/tesla_generator.dmi'
	icon_state = "TheSingGen"
	creation_type = /obj/singularity/energy_ball

/obj/machinery/the_singularitygen/tesla/tesla_act(power, tesla_flags)
	if(tesla_flags & TESLA_MACHINE_EXPLOSIVE)
		energy += power
