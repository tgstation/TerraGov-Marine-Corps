#define HIDE_NONE 0
#define HIDE_ON_GROUND 1
#define HIDE_ON_SHIP 2

#define SPOTLIGHT_COOLDOWN_DURATION 6 MINUTES
#define SPOTLIGHT_DURATION 2 MINUTES

#define MESSAGE_SINGLE "Message this marine"
#define ASL "Set or un-set as aSL"
#define SWITCH_SQUAD "Switch this marine's squad"

#define MARK_LASE "Mark this lase on minimap"
#define FIRE_LASE "!!FIRE OB!!"

#define ORBITAL_SPOTLIGHT "Shine orbital spotlight"
#define MESSAGE_NEAR "Message all nearby marines"
#define SQUAD_ACTIONS "Open squad actions menu"

#define MESSAGE_SQUAD "Message all marines in a squad"
#define SWITCH_SQUAD_NEAR "Move all nearby marines to a squad"

/// The maximum length we should use for sending messages with stuff like `message_member`,
/// `message_squad` etc.
#define MAX_COMMAND_MESSAGE_LENGTH 200

///Overwatch is on monitor mode
#define OVERWATCH_ON_MONITOR (1<<0)
///Sort squad list by health status
#define OVERWATCH_SORT_BY_HEALTH (1<<1)
///whether or not we show the dead marines in the squad
#define OVERWATCH_HIDE_DEAD (1<<2)
///The overwatch computer is busy doing something
#define OVERWATCH_BUSY (1<<3)

GLOBAL_LIST_EMPTY(active_orbital_beacons)
GLOBAL_LIST_EMPTY(active_laser_targets)
GLOBAL_LIST_EMPTY(active_cas_targets)

/obj/machinery/computer/camera_advanced/overwatch
	name = "Overwatch Console"
	desc = "State of the art machinery for giving orders to a squad. <b>Shift click</b> to send order when watching squads."
	density = FALSE
	icon_state = "overwatch"
	screen_overlay = "overwatch_screen"
	req_access = list(ACCESS_MARINE_BRIDGE)
	networks = list("marine")
	open_prompt = FALSE
	interaction_flags = INTERACT_MACHINE_DEFAULT
	faction = FACTION_TERRAGOV
	///behavior flags for overwatch
	var/overwatch_flags
	///which z level is ignored when showing marines.
	var/z_hidden = HIDE_NONE
	/// The list of all squads that can be watched
	var/list/watchable_squads
	///Squad being currently overseen
	var/datum/squad/current_squad = null
	///Groundside minimap for overwatch
	var/datum/action/minimap/marine/external/cic_mini
	///Overrides the minimap action minimap and marker flags
	var/map_flags = MINIMAP_FLAG_MARINE
	///overwatch name override
	var/overwatch_title

/obj/machinery/computer/camera_advanced/overwatch/Initialize(mapload)
	. = ..()
	cic_mini = new(null, map_flags, map_flags)
	GLOB.main_overwatch_consoles += src

/obj/machinery/computer/camera_advanced/overwatch/Destroy()
	QDEL_NULL(cic_mini)
	GLOB.main_overwatch_consoles -= src
	current_squad = null
	return ..()

/obj/machinery/computer/camera_advanced/overwatch/give_actions(mob/living/user)
	. = ..()
	if(cic_mini)
		cic_mini.target = user
		cic_mini.give_action(user)
		actions += cic_mini

/obj/machinery/computer/camera_advanced/overwatch/CreateEye()
	eyeobj = new(null, parent_cameranet, faction)
	eyeobj.origin = src
	RegisterSignal(eyeobj, COMSIG_QDELETING, PROC_REF(clear_eye_ref))
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/cameramob.dmi'
	eyeobj.icon_state = "generic_camera"
	cic_mini.override_locator(eyeobj)

/obj/machinery/computer/camera_advanced/overwatch/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(!allowed(user))
		return FALSE
	return TRUE

/obj/machinery/computer/camera_advanced/overwatch/interact(mob/user)
	. = ..()
	if(.)
		return
	watchable_squads = SSjob.active_squads[faction]
	var/datum/browser/popup = new(user, "overwatch", "<div align='center'>[overwatch_title ? overwatch_title : current_squad ? current_squad.name : ""] Overwatch Console</div>", 550, 820)
	popup.set_content(get_dat())
	popup.open()

/obj/machinery/computer/camera_advanced/overwatch/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!href_list["operation"])
		return

	switch(href_list["operation"])
		if("back")
			overwatch_flags &= ~OVERWATCH_ON_MONITOR
		if("monitor")
			overwatch_flags |= OVERWATCH_ON_MONITOR
			if(href_list["squad_id"])
				var/new_squad_id = href_list["squad_id"]
				current_squad = null
				for(var/datum/squad/squad AS in watchable_squads)
					if(squad.id == new_squad_id)
						current_squad = squad
						break
		if("change_operator")
			if(operator != usr)
				if(current_squad)
					current_squad.overwatch_officer = usr
				operator = usr
				var/mob/living/carbon/human/H = operator
				var/obj/item/card/id/ID = H.get_idcard()
				if(issilicon(operator))
					to_chat(operator, span_boldnotice("Basic overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]. Please select a squad."))
				visible_message(span_boldnotice("Basic overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]. Please select a squad."))
		if("change_main_operator")
			if(operator != usr)
				operator = usr
				var/mob/living/carbon/human/H = operator
				var/obj/item/card/id/ID = H.get_idcard()
				if(issilicon(operator))
					to_chat(operator, span_boldnotice("Main overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]."))
				visible_message(span_boldnotice("Main overwatch systems initialized. Welcome, [ID ? "[ID.rank] ":""][operator.name]."))
		if("logout")
			if(!current_squad)
				return
			var/obj/item/card/id/ID = operator.get_idcard()
			current_squad.overwatch_officer = null //Reset the squad's officer.
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			visible_message(span_boldnotice("Overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			operator = null
			current_squad = null
			overwatch_flags &= ~OVERWATCH_ON_MONITOR
		if("logout_main")
			var/obj/item/card/id/ID = operator.get_idcard()
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Main overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			visible_message(span_boldnotice("Main overwatch systems deactivated. Goodbye, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"]."))
			operator = null
			current_squad = null
			overwatch_flags &= ~OVERWATCH_ON_MONITOR
		if("pick_squad")
			if(operator != usr)
				return
			if(current_squad)
				to_chat(operator, span_warning("[icon2html(src, operator)] You are already selecting a squad."))
				return
			var/datum/squad/selected = tgui_input_list(operator, "Which squad would you like to claim for Overwatch?", null, watchable_squads)
			if(!selected || operator != usr)
				return
			selected.overwatch_officer = operator //Link everything together, squad, console, and officer
			current_squad = selected
			if(issilicon(operator))
				to_chat(operator, span_boldnotice("Tactical data for squad '[current_squad]' loaded. All tactical functions initialized."))
			visible_message(span_boldnotice("Tactical data for squad '[current_squad]' loaded. All tactical functions initialized."))
			attack_hand(operator)
		if("refresh")
			attack_hand(operator)
		if("change_sort")
			overwatch_flags ^= OVERWATCH_SORT_BY_HEALTH
			if(overwatch_flags & OVERWATCH_SORT_BY_HEALTH)
				to_chat(operator, "[icon2html(src, operator)] [span_notice("Marines are now sorted by health status.")]")
			else
				to_chat(operator, "[icon2html(src, operator)] [span_notice("Marines are now sorted by rank.")]")
		if("hide_dead")
			overwatch_flags ^= OVERWATCH_HIDE_DEAD
			if(overwatch_flags & OVERWATCH_HIDE_DEAD)
				to_chat(operator, "[icon2html(src, operator)] [span_notice("Dead marines are no longer shown.")]")
			else
				to_chat(operator, "[icon2html(src, operator)] [span_notice("Dead marines are now shown.")]")
		if("choose_z")
			switch(z_hidden)
				if(HIDE_NONE)
					z_hidden = HIDE_ON_SHIP
					to_chat(operator, "[icon2html(src, operator)] [span_notice("Marines on the [SSmapping.configs[SHIP_MAP].map_name] are now hidden.")]")
				if(HIDE_ON_SHIP)
					z_hidden = HIDE_ON_GROUND
					to_chat(operator, "[icon2html(src, operator)] [span_notice("Marines on the ground are now hidden.")]")
				if(HIDE_ON_GROUND)
					z_hidden = HIDE_NONE
					to_chat(operator, "[icon2html(src, operator)] [span_notice("No location is ignored anymore.")]")
		if("use_cam")
			var/atom/cam_target = locate(href_list["cam_target"])
			if(!cam_target)
				return
			var/turf/cam_target_turf = get_turf(cam_target)
			if(!cam_target_turf)
				return
			if(!isAI(operator))
				open_prompt(operator)
				eyeobj.setLoc(cam_target_turf)
				if(isliving(cam_target))
					var/mob/living/L = cam_target
					track(L)
				else
					to_chat(operator, "[icon2html(src, operator)] [span_notice("Jumping to the latest available location of [cam_target].")]")
			else
				// If we are an AI
				to_chat(operator, "[icon2html(src, operator)] [span_notice("Jumping to the latest available location of [cam_target].")]")
				var/turf/T = get_turf(cam_target)
				if(T)
					var/mob/living/silicon/ai/recipientai = operator
					recipientai.eyeobj.setLoc(T)
	updateUsrDialog()

///Provided data for interact(). Overridable
/obj/machinery/computer/camera_advanced/overwatch/proc/get_dat()
	var/dat
	if(!operator)
		dat += "<BR><B>Operator:</b> <A href='byond://?src=[text_ref(src)];operation=change_operator'>----------</A><BR>"
		return dat
	dat += "<BR><B>Operator:</b> <A href='byond://?src=[text_ref(src)];operation=change_operator'>[operator.name]</A><BR>"
	dat += "   <A href='byond://?src=[text_ref(src)];operation=logout'>{Stop Overwatch}</A><BR>"
	dat += "----------------------<br>"
	if(overwatch_flags & OVERWATCH_ON_MONITOR)
		dat += get_squad_info()
		return dat

	if(!current_squad)
		dat += "<br>Current Squad: <A href='byond://?src=[text_ref(src)];operation=pick_squad'>----------</A><BR>"
		return dat

	dat += "<br><b>[current_squad.name] Squad</A></b>   <br><br>"
	dat += "----------------------<BR><BR>"
	if(current_squad.squad_leader)
		dat += "<B>Squad Leader:</B> <A href='byond://?src=[text_ref(src)];operation=use_cam;cam_target=\ref[current_squad.squad_leader]'>[current_squad.squad_leader.name]</a> "

	dat += "<a href='byond://?src=[text_ref(src)];operation=monitor'>Squad Monitor</a><br><br>"
	dat += "----------------------<br>"
	dat += "<br><br><a href='byond://?src=[text_ref(src)];operation=refresh'>{Refresh}</a>"
	return dat

///Provides info on the currently selected squad
/obj/machinery/computer/camera_advanced/overwatch/proc/get_squad_info()
	var/dat = ""
	if(!current_squad)
		dat += "No Squad selected!<BR>"
		dat += get_squad_info_ending()
		return dat
	var/leader_text = ""
	var/leader_count = 0
	var/medic_text = ""
	var/medic_count = 0
	var/engi_text = ""
	var/engi_count = 0
	var/smart_text = ""
	var/smart_count = 0
	var/marine_text = ""
	var/marine_count = 0
	var/misc_text = ""
	var/living_count = 0
	var/conscious_text = ""
	var/unconscious_text = ""
	var/dead_text = ""
	var/gibbed_text = ""
	var/SL_z //z level of the Squad Leader
	if(current_squad.squad_leader)
		var/turf/SL_turf = get_turf(current_squad.squad_leader)
		SL_z = SL_turf?.z
	for(var/mob/living/carbon/human/H in current_squad.get_all_members())
		var/mob_name = "unknown"
		var/mob_state = ""
		var/role = "unknown"
		var/act_sl = ""
		var/fteam = ""
		var/dist = "<b>???</b>"
		var/area_name = "<b>???</b>"
		mob_name = H.real_name
		var/area/A = get_area(H)
		var/turf/M_turf = get_turf(H)
		if(A)
			area_name = sanitize(A.name)
		switch(z_hidden)
			if(HIDE_ON_GROUND)
				if(is_ground_level(M_turf?.z))
					continue
			if(HIDE_ON_SHIP)
				if(is_mainship_level(M_turf?.z))
					continue

		if(H.job)
			role = H.job.title
		else if(istype(H.wear_id, /obj/item/card/id))
			var/obj/item/card/id/ID = H.wear_id //we use their ID to get their role.
			role = ID.rank
		if(current_squad.squad_leader)
			if(H == current_squad.squad_leader)
				dist = "<b>N/A</b>"
				if(!ismarineleaderjob(H.job) && !issommarineleaderjob(H.job))
					act_sl = " (acting SL)"
			else if(M_turf && SL_z && M_turf.z == SL_z)
				dist = "[get_dist(H, current_squad.squad_leader)] ([dir2text_short(get_dir(current_squad.squad_leader, H))])"
		switch(H.stat)
			if(CONSCIOUS)
				mob_state = "Conscious"
				living_count++
				conscious_text += "<tr><td><A href='byond://?src=[text_ref(src)];operation=use_cam;cam_target=[text_ref(H)]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
			if(UNCONSCIOUS)
				mob_state = "<b>Unconscious</b>"
				living_count++
				unconscious_text += "<tr><td><A href='byond://?src=[text_ref(src)];operation=use_cam;cam_target=[text_ref(H)]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
			if(DEAD)
				if(overwatch_flags & OVERWATCH_HIDE_DEAD)
					continue
				mob_state = "<font color='red'>DEAD</font>"
				dead_text += "<tr><td><A href='byond://?src=[text_ref(src)];operation=use_cam;cam_target=[text_ref(H)]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
		if((!H.key || !H.client) && H.stat != DEAD)
			mob_state += " (SSD)"
		var/obj/item/card/id/ID = H.wear_id
		if(ID?.assigned_fireteam)
			fteam = " \[[ID.assigned_fireteam]\]"
		var/marine_infos = "<tr><td><A href='byond://?src=[text_ref(src)];operation=use_cam;cam_target=[text_ref(H)]'>[mob_name]</a></td><td>[role][act_sl][fteam]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"

		if(role in GLOB.jobs_squad_standard)
			marine_text += marine_infos
			marine_count++
		else if(role in GLOB.jobs_squad_corpsman)
			medic_text += marine_infos
			medic_count++
		else if(role in GLOB.jobs_squad_engineer)
			engi_text += marine_infos
			engi_count++
		else if(role in GLOB.jobs_squad_specialist)
			smart_text += marine_infos
			smart_count++
		else if(role in GLOB.jobs_squad_leader)
			leader_text += marine_infos
			leader_count++
		else
			misc_text += marine_infos

	if(current_squad.overwatch_officer)
		dat += "<b>Squad Overwatch:</b> [current_squad.overwatch_officer.name]<br>"
	else
		dat += "<b>Squad Overwatch:</b> <font color=red>NONE</font><br>"
	dat += "----------------------<br>"
	dat += "<b>[leader_count ? "Squad Leader Deployed":"<font color='red'>No Squad Leader Deployed!</font>"]</b><br>"
	dat += "<b>[faction == FACTION_SOM ? "Squad Veterans" : "Squad Smartgunners"]: [smart_count] Deployed</b><br>" //this is kinda snowflake but sue me
	dat += "<b>Squad Corpsmen: [medic_count] Deployed | Squad Engineers: [engi_count] Deployed</b><br>"
	dat += "<b>Squad Marines: [marine_count] Deployed</b><br>"
	dat += "<b>Total: [current_squad.get_total_members()] Deployed</b><br>"
	dat += "<b>Marines alive: [living_count]</b><br><br>"
	dat += "<table border='1' style='width:100%' align='center'><tr>"
	dat += "<th>Name</th><th>Role</th><th>State</th><th>Location</th><th>SL Distance</th></tr>"
	if(overwatch_flags & OVERWATCH_SORT_BY_HEALTH)
		dat += conscious_text + unconscious_text + dead_text + gibbed_text
	else
		dat += leader_text + medic_text + engi_text + smart_text + marine_text + misc_text
	dat += "</table>"
	dat += "<br>----------------------<br>"
	dat += "<b>Primary Objective:</b> "
	if(current_squad.primary_objective)
		dat += "[current_squad.primary_objective]<br>"
	else
		dat += "<b><font color=red>NONE!</font></b><br>"
	dat += "<b>Secondary Objective:</b> "
	if(current_squad.secondary_objective)
		dat += "[current_squad.secondary_objective]<br>"
	else
		dat += "<b><font color=red>NONE!</font></b><br>"
	dat += get_squad_info_ending()
	return dat

///Provides config options for squad info
/obj/machinery/computer/camera_advanced/overwatch/proc/get_squad_info_ending()
	var/dat = ""
	dat += "----------------------<br>"
	dat += "<A href='byond://?src=[text_ref(src)];operation=refresh'>{Refresh}</a><br>"
	dat += "<A href='byond://?src=[text_ref(src)];operation=hide_dead'>{[(overwatch_flags & OVERWATCH_SORT_BY_HEALTH) ? "Sort by rank" : "Sort by health" ]}</a><br>"
	dat += "<A href='byond://?src=[text_ref(src)];operation=hide_dead'>{[(overwatch_flags & OVERWATCH_HIDE_DEAD) ? "Show Dead Marines" : "Hide Dead Marines" ]}</a><br>"
	dat += "<A href='byond://?src=[text_ref(src)];operation=choose_z'>{Change Locations Ignored}</a><br>"
	dat += "<br><A href='byond://?src=[text_ref(src)];operation=back'>{Back}</a>"
	return dat

//This is an effect to be sure it is properly deleted and it does not interfer with existing lights too much.
/obj/effect/overwatch_light
	name = "overwatch beam of light"
	desc = "You are not supposed to see this. Please report it."
	icon_state = "" //No sprite
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = RESIST_ALL
	light_system = STATIC_LIGHT
	light_color = COLOR_TESLA_BLUE
	light_range = 15	//This is a HUGE light.
	light_power = SQRTWO

/obj/effect/overwatch_light/Initialize(mapload)
	. = ..()
	set_light(light_range, light_power)
	playsound(src,'sound/mecha/heavylightswitch.ogg', 25, 1, 20)
	visible_message(span_warning("You see a twinkle in the sky before your surroundings are hit with a beam of light!"))
	QDEL_IN(src, SPOTLIGHT_DURATION)
