GLOBAL_LIST_EMPTY(antagonists)

/datum/antagonist
	var/name = "Antagonist"
	var/roundend_category = "other antagonists"				//Section of roundend report, datums with same category will be displayed together, also default header for the section
	var/show_in_roundend = TRUE								//Set to false to hide the antagonists from roundend report
	var/prevent_roundtype_conversion = TRUE		//If false, the roundtype will still convert with this antag active
	var/datum/mind/owner						//Mind that owns this datum
	var/silent = FALSE							//Silent will prevent the gain/lose texts to show
	var/can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	var/list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with
	var/job_rank
	var/replace_banned = TRUE //Should replace jobbanned player with ghosts if granted.
	var/list/objectives = list()
	var/antag_memory = ""//These will be removed with antag datum
	var/antag_moodlet //typepath of moodlet that the mob will gain with their status
	var/antag_hud_type
	var/antag_hud_name

	//Antag panel properties
	var/show_in_antagpanel = TRUE	//This will hide adding this antag type in antag panel, use only for internal subtypes that shouldn't be added directly but still show if possessed by mind
	var/antagpanel_category = "Uncategorized"	//Antagpanel will display these together, REQUIRED
	var/show_name_in_check_antagonists = FALSE //Will append antagonist name in admin listings - use for categories that share more than one antag type
	var/show_to_ghosts = FALSE // Should this antagonist be shown as antag to ghosts? Shouldn't be used for stealthy antagonists like traitors

/datum/antagonist/New()
	GLOB.antagonists += src
	typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)

/datum/antagonist/Destroy()
	GLOB.antagonists -= src
	if(!owner)
		stack_trace("Destroy()ing antagonist datum when it has no owner.")
	else
		LAZYREMOVE(owner.antag_datums, src)
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(datum/mind/new_owner)
	. = TRUE
	var/datum/mind/tested = new_owner || owner
	if(tested.has_antag_datum(type))
		return FALSE
	for(var/i in tested.antag_datums)
		var/datum/antagonist/A = i
		if(is_type_in_typecache(src, A.typecache_datum_blacklist))
			return FALSE

//This will be called in add_antag_datum before owner assignment.
//Should return antag datum without owner.
/datum/antagonist/proc/specialization(datum/mind/new_owner)
	return src

///Called by the transfer_to() mind proc after the mind (mind.current and new_character.mind) has moved but before the player (key and client) is transfered.
/datum/antagonist/proc/on_body_transfer(mob/living/old_body, mob/living/new_body)
	SHOULD_CALL_PARENT(TRUE)
	remove_innate_effects(old_body)
	apply_innate_effects(new_body)

//This handles the application of antag huds/special abilities
/datum/antagonist/proc/apply_innate_effects(mob/living/mob_override)
	return

//This handles the removal of antag huds/special abilities
/datum/antagonist/proc/remove_innate_effects(mob/living/mob_override)
	return

///Called by the add_antag_datum() mind proc after the instanced datum is added to the mind's antag_datums list.
/datum/antagonist/proc/on_gain()
	SHOULD_CALL_PARENT(TRUE)
	if(!owner)
		CRASH("[src] ran on_gain() without a mind")
	if(!owner.current)
		CRASH("[src] ran on_gain() on a mind without a mob")
	if(!silent)
		greet()
	apply_innate_effects()

///Called by the remove_antag_datum() and remove_all_antag_datums() mind procs for the antag datum to handle its own removal and deletion.
/datum/antagonist/proc/on_removal()
	SHOULD_CALL_PARENT(TRUE)
	if(!owner)
		CRASH("Antag datum with no owner.")

	for(var/datum/action/A AS in usr.actions) //remove all objective buttons
		if(istype(A, /datum/action/objectives))
			A.remove_action(usr)

	remove_innate_effects()
	LAZYREMOVE(owner.antag_datums, src)
	if(!silent && owner.current)
		farewell()
	qdel(src)

/datum/antagonist/proc/greet()
	return

/datum/antagonist/proc/farewell()
	return

//Returns the team antagonist belongs to if any.
/datum/antagonist/proc/get_team()
	return

//Individual roundend report
/datum/antagonist/proc/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("Antagonist datum without owner")

	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(length(objectives))
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(length(objectives) == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//Displayed at the start of roundend_category section, default to roundend_category header
/datum/antagonist/proc/roundend_report_header()
	return 	"<span class='header'>the players with objectives were:</span><br>"

//Displayed at the end of roundend_category section
/datum/antagonist/proc/roundend_report_footer()
	return


//ADMIN TOOLS

//Called when using admin tools to give antag status
/datum/antagonist/proc/admin_add(datum/mind/new_owner,mob/admin)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	new_owner.add_antag_datum(src)

//Called when removing antagonist using admin tools
/datum/antagonist/proc/admin_remove(mob/user)
	if(!user)
		return
	message_admins("[key_name_admin(user)] has removed [name] antagonist status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed [name] antagonist status from [key_name(owner)].")
	on_removal()

//gamemode/proc/is_mode_antag(antagonist/A) => TRUE/FALSE

//Additional data to display in antagonist panel section
//nuke disk code, genome count, etc
/datum/antagonist/proc/antag_panel_data()
	return ""

/datum/antagonist/proc/enabled_in_preferences(datum/mind/M)
	if(job_rank)
		if(M.current && M.current.client && (job_rank in M.current.client.prefs.be_special))
			return TRUE
		else
			return FALSE
	return TRUE

// List if ["Command"] = CALLBACK(), user will be appeneded to callback arguments on execution
/datum/antagonist/proc/get_admin_commands()
	. = list()

/datum/antagonist/Topic(href,href_list)
	if(!check_rights(R_ADMIN))
		return
	//Antag memory edit
	if(href_list["memory_edit"])
		edit_memory(usr)
		//owner.traitor_panel()
		return

	var/commands = get_admin_commands()
	for(var/admin_command in commands)
		if(href_list["command"] == admin_command)
			var/datum/callback/C = commands[admin_command]
			C.Invoke(usr)
			//persistent_owner.traitor_panel()
			return

/datum/antagonist/proc/edit_memory(mob/user)
	var/new_memo = stripped_multiline_input(user, "Write new memory", "Memory", antag_memory, MAX_MESSAGE_LEN)
	if (isnull(new_memo))
		return
	antag_memory = new_memo

//This one is created by admin tools for custom objectives
/datum/antagonist/custom
	antagpanel_category = "Custom"
	show_name_in_check_antagonists = TRUE //They're all different

/datum/antagonist/custom/admin_add(datum/mind/new_owner, mob/admin)
	var/custom_name = stripped_input(admin, "Custom antagonist name:", "Custom antag", "Antagonist")
	if(custom_name)
		name = custom_name
	else
		return
	return ..()

//Returns MINDS of the assigned antags of given type/subtypes
/proc/get_antag_minds(antag_type,specific = FALSE)
	RETURN_TYPE(/list/datum/mind)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type)
			. += A.owner

/datum/action/objectives
	name = "Generic Objective Button"
	action_icon_state = "62"
