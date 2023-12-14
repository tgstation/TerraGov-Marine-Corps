// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet
/obj/machinery/power/monitor
	name = "power monitoring computer"
	desc = "It monitors power levels across the station."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	//computer stuff
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/computer/powermonitor
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_EMISSIVE_YELLOW
	///screen overlay icon
	var/screen_overlay = "power"

/obj/machinery/power/monitor/core
	name = "Core Power Monitoring"

/obj/machinery/power/monitor/grid
	name = "Main Power Grid Monitoring"

/obj/machinery/power/monitor/Initialize(mapload)
	. = ..()
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		powernet = attached.powernet
	update_icon()


/obj/machinery/power/monitor/interact(mob/user)
	. = ..()
	if(.)
		return

	var/t
	t += "<BR><HR><A href='?src=[text_ref(src)];update=1'>Refresh</A>"
	t += "<BR><HR><A href='?src=[text_ref(src)];close=1'>Close</A>"

	if(!powernet)
		t += span_warning(" No connection")
	else

		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		t += "<PRE>Total power: [powernet.avail] W<BR>Total load:  [num2text(powernet.viewload,10)] W<BR>"

		t += "<FONT SIZE=-1>"

		if(length(L) > 0)
			var/total_demand = 0
			t += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

			var/list/S = list(" Off","AOff","  On", " AOn")
			var/list/chg = list("N","C","F")

			for(var/obj/machinery/power/apc/A in L)

				t += copytext(add_trailing("\The [A.area]", 30, " "), 1, 30)
				t += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_leading(num2text(A.lastused_total), 6, " ")]  [A.cell ? "[add_leading(num2text(round(A.cell.percent())), 3, " ")]% [chg[A.charging+1]]" : "  N/C"]<BR>"
				total_demand += A.lastused_total

			t += "<HR>Total demand: [total_demand] W</FONT>"
		t += "</PRE>"

	var/datum/browser/popup = new(user, "powcomp", "<div align='center'>Power Monitoring</div>", 420, 900)
	popup.set_content(t)
	popup.open(FALSE)
	onclose(user, "powcomp")

/obj/machinery/power/monitor/update_icon()
	. = ..()
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		set_light(0)
	else
		set_light(initial(light_range))

/obj/machinery/power/monitor/update_icon_state()
	if(machine_stat & (BROKEN|DISABLED))
		icon_state = "[initial(icon_state)]_broken"
	else
		icon_state = initial(icon_state)


/obj/machinery/power/monitor/update_overlays()
	. = ..()
	if(!screen_overlay)
		return
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		return
	. += emissive_appearance(icon, screen_overlay, alpha = src.alpha)
	. += mutable_appearance(icon, screen_overlay, alpha = src.alpha)

//copied from computer.dm
/obj/machinery/power/monitor/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I) && circuit)
		playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
		if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD))
			return

		var/obj/structure/computerframe/A = new(loc)
		var/obj/item/circuitboard/computer/M = new circuit(A)
		A.circuit = M
		A.anchored = TRUE
		for(var/obj/C in src)
			C.forceMove(loc)
		if(machine_stat & BROKEN)
			to_chat(user, span_notice("The broken glass falls out."))
			new /obj/item/shard(loc)
			A.state = 3
			A.icon_state = "3"
		else
			to_chat(user, span_notice("You disconnect the monitor."))
			A.state = 4
			A.icon_state = "4"
		M.deconstruct(src)
		qdel(src)
	else
		attack_hand(user)
