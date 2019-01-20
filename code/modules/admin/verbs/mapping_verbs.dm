//- Are all the floors with or without air, as they should be? (regular or airless)
//- Does the area have an APC?
//- Does the area have an Air Alarm?
//- Does the area have a Request Console?
//- Does the area have lights?
//- Does the area have a light switch?
//- Does the area have enough intercoms?
//- Does the area have enough security cameras? (Use the 'Camera Range Display' verb under Debug)
//- Is the area connected to the scrubbers air loop?
//- Is the area connected to the vent air loop? (vent pumps)
//- Is everything wired properly?
//- Does the area have a fire alarm and firedoors?
//- Do all pod doors work properly?
//- Are accesses set properly on doors, pod buttons, etc.
//- Are all items placed properly? (not below vents, scrubbers, tables)
//- Does the disposal system work properly from all the disposal units in this room and all the units, the pipes of which pass through this room?
//- Check for any misplaced or stacked piece of pipe (air and disposal)
//- Check for any misplaced or stacked piece of wire
//- Identify how hard it is to break into the area and where the weak points are
//- Check if the area has too much empty space. If so, make it smaller and replace the rest with maintenance tunnels.

var/camera_range_display_status = 0
var/intercom_range_display_status = 0

/obj/effect/debugging/camera_range
	icon = 'icons/480x480.dmi'
	icon_state = "25percent"

	New()
		src.pixel_x = -224
		src.pixel_y = -224

/obj/effect/debugging/marker
	icon = 'icons/turf/areas.dmi'
	icon_state = "yellow"

/obj/effect/debugging/marker/Move()
	return 0

/client/proc/do_not_use_these()
	set category = "Mapping"
	set name = "-None of these are for ingame use!!"

	..()

/client/proc/camera_view()
	set category = "Mapping"
	set name = "Camera Range Display"

	if(camera_range_display_status)
		camera_range_display_status = 0
	else
		camera_range_display_status = 1



	for(var/obj/effect/debugging/camera_range/C in effect_list)
		qdel(C)

	if(camera_range_display_status)
		for(var/obj/machinery/camera/C in cameranet.cameras)
			new/obj/effect/debugging/camera_range(C.loc)
	feedback_add_details("admin_verb","mCRD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/client/proc/sec_camera_report()
	set category = "Mapping"
	set name = "Camera Report"

	var/list/obj/machinery/camera/CL = list()

	for(var/obj/machinery/camera/C in cameranet.cameras)
		CL += C

	var/output = {"<B>CAMERA ANNOMALITIES REPORT</B><HR>
<B>The following annomalities have been detected. The ones in red need immediate attention: Some of those in black may be intentional.</B><BR><ul>"}

	for(var/obj/machinery/camera/C1 in CL)
		for(var/obj/machinery/camera/C2 in CL)
			if(C1 != C2)
				if(C1.c_tag == C2.c_tag)
					output += "<li><font color='red'>c_tag match for sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) and \[[C2.x], [C2.y], [C2.z]\] ([C2.loc.loc]) - c_tag is [C1.c_tag]</font></li>"
				if(C1.loc == C2.loc && C1.dir == C2.dir && C1.pixel_x == C2.pixel_x && C1.pixel_y == C2.pixel_y)
					output += "<li><font color='red'>FULLY overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Networks: [C1.network] and [C2.network]</font></li>"
				if(C1.loc == C2.loc)
					output += "<li>overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Networks: [C1.network] and [C2.network]</font></li>"
		var/turf/T = get_step(C1,turn(C1.dir,180))
		if(!T || !isturf(T) || !T.density )
			if(!(locate(/obj/structure/grille,T)))
				var/window_check = 0
				for(var/obj/structure/window/W in T)
					if (W.dir == turn(C1.dir,180) || W.dir in list(5,6,9,10) )
						window_check = 1
						break
				if(!window_check)
					output += "<li><font color='red'>Camera not connected to wall at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Network: [C1.network]</color></li>"

	output += "</ul>"
	usr << browse(output,"window=airreport;size=1000x500")
	feedback_add_details("admin_verb","mCRP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/intercom_view()
	set category = "Mapping"
	set name = "Intercom Range Display"

	if(intercom_range_display_status)
		intercom_range_display_status = 0
	else
		intercom_range_display_status = 1

	for(var/obj/effect/debugging/marker/M in effect_list)
		qdel(M)

	if(intercom_range_display_status)
		for(var/obj/item/device/radio/intercom/I in item_list)
			for(var/turf/T in orange(7,I))
				var/obj/effect/debugging/marker/F = new/obj/effect/debugging/marker(T)
				if (!(F in view(7,I.loc)))
					qdel(F)
	feedback_add_details("admin_verb","mIRD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_on_z_level()
	set category = "Mapping"
	set name = "Count Objects On Level"
	var/level = input("Which z-level?","Level?") as text
	if(!level) return
	var/num_level = text2num(level)
	if(!num_level) return
	if(!isnum(num_level)) return

	var/type_text = input("Which type path?","Path?") as text
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 1

	var/list/atom/atom_list = list()

	for(var/atom/A in world)
		if(istype(A,type_path))
			var/atom/B = A
			while(!(isturf(B.loc)))
				if(B && B.loc)
					B = B.loc
				else
					break
			if(B)
				if(B.z == num_level)
					count++
					atom_list += A
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		to_chat(world, line)*/

	to_chat(world, "There are [count] objects of type [type_path] on z-level [num_level]")
	feedback_add_details("admin_verb","mOBJZ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_all()
	set category = "Mapping"
	set name = "Count Objects All"

	var/type_text = input("Which type path?","") as text
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 0

	for(var/atom/A in world)
		if(istype(A,type_path))
			count++
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		to_chat(world, line)*/

	to_chat(world, "There are [count] objects of type [type_path] in the game world")
	feedback_add_details("admin_verb","mOBJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


var/global/prevent_airgroup_regroup = 0

/client/proc/break_all_air_groups()
	set category = "Mapping"
	set name = "Break All Airgroups"

	/*prevent_airgroup_regroup = 1
	for(var/datum/air_group/AG in air_master.air_groups)
		AG.suspend_group_processing()
	message_admins("[src.ckey] used 'Break All Airgroups'")*/

/client/proc/regroup_all_air_groups()
	set category = "Mapping"
	set name = "Regroup All Airgroups Attempt"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*prevent_airgroup_regroup = 0
	for(var/datum/air_group/AG in air_master.air_groups)
		AG.check_regroup()
	message_admins("[src.ckey] used 'Regroup All Airgroups Attempt'")*/

/client/proc/kill_pipe_processing()
	set category = "Mapping"
	set name = "Kill pipe processing"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*pipe_processing_killed = !pipe_processing_killed
	if(pipe_processing_killed)
		message_admins("[src.ckey] used 'kill pipe processing', stopping all pipe processing.")
	else
		message_admins("[src.ckey] used 'kill pipe processing', restoring all pipe processing.")*/

/client/proc/kill_air_processing()
	set category = "Mapping"
	set name = "Kill air processing"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*air_processing_killed = !air_processing_killed
	if(air_processing_killed)
		message_admins("[src.ckey] used 'kill air processing', stopping all air processing.")
	else
		message_admins("[src.ckey] used 'kill air processing', restoring all air processing.")*/

//This proc is intended to detect lag problems relating to communication procs
var/global/say_disabled = 0
/client/proc/disable_communication()
	set category = "Mapping"
	set name = "Disable all communication verbs"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*say_disabled = !say_disabled
	if(say_disabled)
		message_admins("[src.ckey] used 'Disable all communication verbs', killing all communication methods.")
	else
		message_admins("[src.ckey] used 'Disable all communication verbs', restoring all communication methods.")*/

//This proc is intended to detect lag problems relating to movement
var/global/movement_disabled = 0
var/global/movement_disabled_exception //This is the client that calls the proc, so he can continue to run around to gauge any change to lag.
/client/proc/disable_movement()
	set category = "Mapping"
	set name = "Disable all movement"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*movement_disabled = !movement_disabled
	if(movement_disabled)
		message_admins("[src.ckey] used 'Disable all movement', killing all movement.")
		movement_disabled_exception = usr.ckey
	else
		message_admins("[src.ckey] used 'Disable all movement', restoring all movement.")*/

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


/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	for(var/area/A in all_areas)
		if(!(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in machines)
		var/area/A = get_area(APC)
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in machines)
		var/area/A = get_area(alarm)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in machines)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in machines)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in machines)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/device/radio/intercom/I in item_list)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in machines)
		var/area/A = get_area(C)
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	to_chat(world, "<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		to_chat(world, "* [areatype]")


/client/proc/nanomapgen_DumpImage()
	set name = "Generate NanoUI Map"
	set category = "Mapping"

	if(holder)
		nanomapgen_DumpTile(1, 1, text2num(input(usr,"Enter the Z level to generate")))



datum

var/global/enable_power_update_profiling = 0

var/global/power_profiled_time = 0
var/global/power_last_profile_time = 0
var/global/list/power_update_requests_by_machine = list()
var/global/list/power_update_requests_by_area = list()

/proc/log_power_update_request(area/A, obj/machinery/M)
	if (!enable_power_update_profiling)
		return

	var/machine_type = "[M.type]"
	if (machine_type in power_update_requests_by_machine)
		power_update_requests_by_machine[machine_type] += 1
	else
		power_update_requests_by_machine[machine_type] = 1

	if (A.name in power_update_requests_by_area)
		power_update_requests_by_area[A.name] += 1
	else
		power_update_requests_by_area[A.name] = 1

	power_profiled_time += (world.time - power_last_profile_time)
	power_last_profile_time = world.time

/client/proc/toggle_power_update_profiling()
	set name = "Toggle Area Power Update Profiling"
	set desc = "Toggles the recording of area power update requests."
	set category = "Mapping"
	if(!check_rights(R_DEBUG))	return

	if(enable_power_update_profiling)
		enable_power_update_profiling = 0

		to_chat(usr, "Area power update profiling disabled.")
		message_admins("[key_name(src)] toggled area power update profiling off.")
		log_admin("[key_name(src)] toggled area power update profiling off.")
	else
		enable_power_update_profiling = 1
		power_last_profile_time = world.time

		to_chat(usr, "Area power update profiling enabled.")
		message_admins("[key_name(src)] toggled area power update profiling on.")
		log_admin("[key_name(src)] toggled area power update profiling on.")

	feedback_add_details("admin_verb","APUP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/view_power_update_stats_machines()
	set name = "View Area Power Update Statistics By Machines"
	set desc = "See which types of machines are triggering area power updates."
	set category = "Mapping"

	if(!check_rights(R_DEBUG))	return

	to_chat(usr, "Total profiling time: [power_profiled_time] ticks")
	for (var/M in power_update_requests_by_machine)
		to_chat(usr, "[M] = [power_update_requests_by_machine[M]]")

/client/proc/view_power_update_stats_area()
	set name = "View Area Power Update Statistics By Area"
	set desc = "See which areas are having area power updates."
	set category = "Mapping"

	if(!check_rights(R_DEBUG))	return

	to_chat(usr, "Total profiling time: [power_profiled_time] ticks")
	to_chat(usr, "Total profiling time: [power_profiled_time] ticks")
	for (var/A in power_update_requests_by_area)
		to_chat(usr, "[A] = [power_update_requests_by_area[A]]")


/client/proc/atmos_toggle_debug(var/obj/machinery/atmospherics/M in view())
	set name = "Toggle Debug Messages"
	set category = "Mapping"
	M.debug = !M.debug
	to_chat(usr, "[M]: Debug messages toggled [M.debug? "on" : "off"].")