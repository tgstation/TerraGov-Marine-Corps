/obj/machinery/computer/squad_selector
	name = "squad selection console"
	desc = "A console for squad management. Allows users to join a squad."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	screen_overlay = "syndishuttle"
	broken_icon = "computer_red_broken"
	interaction_flags = INTERACT_OBJ_UI

/obj/machinery/computer/squad_selector/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadSelector", name)
		ui.open()

/obj/machinery/computer/squad_selector/ui_data(mob/user)
	var/list/data = list()
	if(!SSjob.active_squads[user.faction])
		return data
	var/list/squad_data = list()
	for(var/datum/squad/squad AS in SSjob.active_squads[user.faction])
		var/leader_name = squad.squad_leader?.real_name ? squad.squad_leader.real_name : "ERROR: No Squad Leader"
		squad_data += list(list("name" = squad.name, "id" = squad.id, "desc" = squad.desc, "color" = squad.color, "leader" = leader_name))
	data["active_squads"] = squad_data
	return data

/obj/machinery/computer/squad_selector/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/user = usr
	if(action == "join")
		var/new_squad_id = params["squad_id"]
		var/datum/squad/new_squad = SSjob.squads[new_squad_id]
		if(!new_squad)
			return
		if(new_squad == user.assigned_squad)
			return
		user.change_squad(new_squad_id)
