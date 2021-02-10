/obj/machinery/computer/droppod_control
	name = "Droppod launch computer"
	desc = "A computer managing the ships drop pods."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "terminal1"
	interaction_flags = INTERACT_MACHINE_TGUI
	var/list/linked_pods

/obj/machinery/computer/droppod_control/Destroy()
	LAZYCLEARLIST(linked_pods)
	return ..()

/obj/machinery/computer/droppod_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..() 
	if(.)
		return
	switch(action)
		if("relink")
			LAZYCLEARLIST(linked_pods)
			for(var/i in GLOB.droppod_list)
				var/obj/structure/droppod/pod = i
				if(pod.z == z)
					LAZYADD(linked_pods, pod)
		if("launchall")
			if(world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
				to_chat(usr, "<span class='notice'>Unable to launch drop pods, the ship has not yet reached the combat area.</span>")
				return
			log_game("[usr] has dropped all currently linked droppods, total:[LAZYLEN(linked_pods)]")
			for(var/p in linked_pods)
				var/obj/structure/droppod/pod = p
				if(!pod?.occupant)
					continue
				var/predroptime = rand(5, 1 SECONDS)	//Randomize it a bit so its staggered
				addtimer(CALLBACK(pod, /obj/structure/droppod/.proc/launchpod, pod.occupant), predroptime)
			LAZYCLEARLIST(linked_pods)//Clear references for the next drop

/obj/machinery/computer/droppod_control/ui_data(mob/user)

	var/list/data = list()
	data["pods"] = LAZYLEN(linked_pods)
	return data

/obj/machinery/computer/droppod_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "DroppodControl", "[name]")
		ui.open()
