/*
	Atmos processes

	These procs generalize various processes used by atmos machinery, such as pumping, filtering, or scrubbing gas, allowing them to be reused elsewhere.
	If no gas was moved/pumped/filtered/whatever, they return a negative number.
	Otherwise they return the amount of energy needed to do whatever it is they do (equivalently power if done over 1 second).
	In the case of free-flowing gas you can do things with gas and still use 0 power, hence the distinction between negative and non-negative return values.
*/


/obj/machinery/atmospherics/var/last_flow_rate = 0
/obj/machinery/portable_atmospherics/var/last_flow_rate = 0


/obj/machinery/atmospherics/var/debug = 0

/client/proc/atmos_toggle_debug(var/obj/machinery/atmospherics/M in view())
	set name = "Toggle Debug Messages"
	set category = "Debug"
	M.debug = !M.debug
	to_chat(usr, "[M]: Debug messages toggled [M.debug? "on" : "off"].")


//This proc handles power usages.
//Calling update_use_power() or use_power() too often will result in lag since updating area power can be costly.
//This proc implements an approximation scheme that will cause area power updates to be triggered less often.
//By having atmos machinery use this proc it is easy to change the power usage approximation for all atmos machines
/obj/machinery/proc/handle_power_draw(var/usage_amount)
	//This code errs on the side of using more power. Using this will mean that sometimes atmos machines use more power than they need, but won't get power for free.
	if (usage_amount > idle_power_usage)
		update_use_power(2)
	else
		if (use_power >= 2)
			use_power = 1	//Don't update here. We will use more power than we are supposed to, but trigger less area power updates.
		else
			update_use_power(1)

	switch (use_power)
		if (0) return 0
		if (1) return idle_power_usage
		if (2 to INFINITY) return max(idle_power_usage, usage_amount)