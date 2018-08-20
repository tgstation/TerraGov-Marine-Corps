/proc/isscrubberpipe(atom/A)
	if(istype(A, /obj/machinery/atmospherics/pipe/simple/visible/scrubbers)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/simple/hidden/scrubbers)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/manifold/visible/scrubbers)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers)) return 1
	return 0

/proc/issupplypipe(atom/A)
	if(istype(A, /obj/machinery/atmospherics/pipe/simple/visible/supply)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/simple/hidden/supply)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/manifold/visible/supply)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/manifold/hidden/supply)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/manifold4w/visible/supply)) return 1
	if(istype(A, /obj/machinery/atmospherics/pipe/manifold4w/hidden/supply)) return 1
	return 0


/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Piping"
	set background = 1
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","CP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(alert("WARNING: This command should not be run on a live server. Do you want to continue?", "Check Piping", "No", "Yes") == "No")
		return

	to_chat(usr, "Checking for disconnected pipes...")
	//all plumbing - yes, some things might get stated twice, doesn't matter.
	for (var/obj/machinery/atmospherics/plumbing in machines)
		if (plumbing.nodealert)
			to_chat(usr, "Unconnected [plumbing.name] located at [plumbing.x],[plumbing.y],[plumbing.z] ([get_area(plumbing.loc)])")

	//Manifolds
	for (var/obj/machinery/atmospherics/pipe/manifold/pipe in machines)
		if (!pipe.node1 || !pipe.node2 || !pipe.node3)
			to_chat(usr, "Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")

	//Pipes
	for (var/obj/machinery/atmospherics/pipe/simple/pipe in machines)
		if (!pipe.node1 || !pipe.node2)
			to_chat(usr, "Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")

	to_chat(usr, "Checking for overlapping pipes...")
	next_turf:
		for(var/turf/T in turfs)
			for(var/dir in cardinal)
				var/check = 0
				var/scrubber = 0
				var/supply = 0
				for(var/obj/machinery/atmospherics/pipe in T)
					if(dir & pipe.initialize_directions)
						if(isscrubberpipe(pipe))
							scrubber++
						else if(issupplypipe(pipe))
							supply++
						else
							check++
						if(check > 1 || supply > 1 || scrubber > 1)
							to_chat(usr, "Overlapping pipe ([pipe.name]) located at [T.x],[T.y],[T.z] ([get_area(T)])")
							continue next_turf
	to_chat(usr, "Done")

/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","CPOW") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for (var/datum/powernet/PN in powernets)
		if (!PN.nodes || !PN.nodes.len)
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with no nodes! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]")

		if (!PN.cables || (PN.cables.len < 10))
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]")
