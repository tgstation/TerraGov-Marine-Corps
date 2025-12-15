/obj/machinery/light/emp_act(severity)
	. = ..()
	if(has_power())
		set_flicker(severity SECONDS, 1.5, 2.5, rand(1,2))
