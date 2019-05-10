/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = 1
	anchored = 1
	use_power = 1
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/opened = 0
	var/obj/machinery/computer/rdconsole/linked_console