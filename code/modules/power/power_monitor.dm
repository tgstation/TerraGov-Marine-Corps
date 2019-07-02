// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet
/obj/machinery/power/monitor
	name = "power monitoring computer"
	desc = "It monitors power levels across the station."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "power"

	//computer stuff
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/computer/powermonitor
	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300

/obj/machinery/power/monitor/New()
	..()
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		powernet = attached.powernet

/obj/machinery/power/monitor/attack_ai(mob/user)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/power/monitor/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(machine_stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/power/monitor/interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (machine_stat & (BROKEN|NOPOWER)) )
		if (!issilicon(user))
			user.unset_interaction()
			user << browse(null, "window=powcomp")
			return


	user.set_interaction(src)
	var/t

	t += "<BR><HR><A href='?src=\ref[src];update=1'>Refresh</A>"
	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	if(!powernet)
		t += "<span class='warning'> No connection</span>"
	else

		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		t += "<PRE>Total power: [powernet.avail] W<BR>Total load:  [num2text(powernet.viewload,10)] W<BR>"

		t += "<FONT SIZE=-1>"

		if(L.len > 0)
			var/total_demand = 0
			t += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

			var/list/S = list(" Off","AOff","  On", " AOn")
			var/list/chg = list("N","C","F")

			for(var/obj/machinery/power/apc/A in L)

				t += copytext(add_tspace("\The [A.area]", 30), 1, 30)
				t += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"
				total_demand += A.lastused_total

			t += "<HR>Total demand: [total_demand] W</FONT>"
		t += "</PRE>"

	var/datum/browser/popup = new(user, "powcomp", "<div align='center'>Power Monitoring</div>", 420, 900)
	popup.set_content(t)
	popup.open(FALSE)
	onclose(user, "powcomp")


/obj/machinery/power/monitor/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if( href_list["close"] )
		usr << browse(null, "window=powcomp")
		usr.unset_interaction()
		return
	if( href_list["update"] )
		src.updateDialog()
		return


/obj/machinery/power/monitor/update_icon()
	if(machine_stat & BROKEN)
		icon_state = "broken"
	else
		if(machine_stat & NOPOWER)
			icon_state = "power0"
		else
			icon_state = initial(icon_state)


//copied from computer.dm
/obj/machinery/power/monitor/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I) && circuit)
		playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			return

		var/obj/structure/computerframe/A = new(loc)
		var/obj/item/circuitboard/computer/M = new circuit(A)
		A.circuit = M
		A.anchored = TRUE
		for(var/obj/C in src)
			C.forceMove(loc)
		if(machine_stat & BROKEN)
			to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
			new /obj/item/shard(loc)
			A.state = 3
			A.icon_state = "3"
		else
			to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
			A.state = 4
			A.icon_state = "4"
		M.deconstruct(src)
		qdel(src)
	else
		attack_hand(user)