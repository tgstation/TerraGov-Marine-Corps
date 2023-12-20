/obj/item/squad_transfer_tablet
	name = "squad transfer tablet"
	desc = "A tablet for quickly transfering the squaddies from under one incompetent squad leader to another."
	icon = 'icons/Marine/marine-navigation.dmi'
	icon_state = "req_tablet_off"
	flags_equip_slot = ITEM_SLOT_POCKET
	w_class = WEIGHT_CLASS_SMALL
	interaction_flags = INTERACT_MACHINE_TGUI
	/// REF()s for all currently active transfering marines
	var/list/active_requests = list()

/obj/item/squad_transfer_tablet/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadTransfer", name)
		ui.open()

/obj/item/squad_transfer_tablet/ui_data(mob/user)
	var/list/data = list()
	data["active_squads"] = list()
	for(var/datum/squad/squad AS in SSjob.active_squads[user.faction])
		var/list/mob/living/carbon/human/members = list()
		for(var/mob/living/carbon/human/member AS in squad.get_all_members())
			members[member.real_name] = REF(member)

		data["active_squads"] += list(list("name" = squad.name, "id" = squad.id, "color" = squad.color, "members" = members))
	data["active_requests"] = active_requests
	return data

/obj/item/squad_transfer_tablet/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/human_user = usr
	if(!ismarineleaderjob(human_user.job) && !issommarineleaderjob(human_user.job) && !ismarinecommandjob(human_user.job) && !issommarinecommandjob(human_user.job))
		to_chat(human_user, span_notice("Only command roles my request squad changes!"))
		return FALSE
	if(action != "transfer")
		return FALSE
	if(params["transfer_target"] in active_requests)
		to_chat(human_user, span_info("Target cannot be transfered: Transfer request already active."))
		return FALSE
	var/mob/living/carbon/human/target = locate(params["transfer_target"])
	if(!istype(target))
		to_chat(human_user, span_info("Target cannot be transfered: Target error."))
		return FALSE
	var/new_squad_id = params["squad_id"]
	var/datum/squad/new_squad = SSjob.squads[new_squad_id]
	if(!new_squad)
		to_chat(human_user, span_info("Target cannot be transfered: Squad error."))
		return FALSE
	to_chat(human_user, span_info("Transfer request sent."))
	active_requests += params["transfer_target"]
	INVOKE_ASYNC(src, PROC_REF(process_transfer), target, new_squad, human_user)
	return TRUE

///handles actual transfering of squaddies, async so ui act doesnt sleep
/obj/item/squad_transfer_tablet/proc/process_transfer(mob/living/carbon/human/target, datum/squad/new_squad, mob/living/carbon/human/user)
	if(tgui_alert(target, "Would you like to transfer to [new_squad.name]? [new_squad.desc ? "Description: [new_squad.desc]" : ""]", "Requested squad Transfer to [new_squad.name]", list("Yes", "No"), 10 SECONDS) != "Yes")
		active_requests -= REF(target)
		log_game("[key_name(target)] has rejected a squad transfer request to [new_squad.name] from [key_name(user)].")
		to_chat(user, span_notice("[target.real_name] has rejected your transfer request"))
		return
	log_game("[key_name(target)] has accepted a squad transfer request to [new_squad.name] from [key_name(user)].")
	to_chat(user, span_notice("[target.real_name] has accepted your transfer request"))
	target.change_squad(new_squad.id)
	active_requests -= REF(target)
