/datum/antagonist/event_santa
	name = "Santa Claus"
	roundend_category = "traitors"
	var/employer = "Santa's workshop"
	var/give_objectives = TRUE

/datum/antagonist/event_santa/on_gain()
	if(give_objectives)
		forge_traitor_objectives()
	return ..()

/datum/antagonist/event_santa/on_removal()
	return ..()

/datum/antagonist/event_santa/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/event_santa/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/event_santa/proc/forge_traitor_objectives()
	forge_human_objectives()

/datum/antagonist/event_santa/proc/forge_human_objectives()
	var/objective_count
	var/toa = 2
	for(var/i = objective_count, i < toa, i++)
		forge_single_human_objective()

	if(!(locate(/datum/objective/survive) in objectives))
		var/list/objectivelist
		objectivelist = list(
			/datum/objective/winoperation = 2,
			/datum/objective/survive = 7,
		)

		///these are boilerplate objectives meant to be tacked on to the end of persons list
		var/datum/objective/selectedobjective = pick_weight_recursive(objectivelist)
		selectedobjective = pick_weight_recursive(objectivelist)
		if(selectedobjective == /datum/objective/winoperation)
			var/datum/objective/winoperation/winoperation_objective = new
			selectedobjective =	winoperation_objective
		if(selectedobjective == /datum/objective/survive)
			var/datum/objective/survive/survive_objective = new
			selectedobjective =	survive_objective

		selectedobjective.owner = owner
		add_objective(selectedobjective)
		return

/datum/antagonist/event_santa/proc/duplicate_objective_check(datum/objective/checkedobjective)
	for(var/datum/objective/i in objectives)
		if(locate(checkedobjective) in objectives) //duplicate objective check
			return FALSE
	return TRUE

/datum/antagonist/event_santa/proc/forge_single_human_objective() //Returns how many objectives are added
	.=1
	var/list/objectivelist = list()
	objectivelist = list(
		/datum/objective/kill_xenos = 3,
		/datum/objective/deliver_gifts = 4,
		/datum/objective/gather_cash = 1, ///santa needs cash for his operations, ho ho ho
		/datum/objective/recruit_elves = 3,
	)
	var/datum/objective/selectedobjective
	selectedobjective = pick_weight_recursive(objectivelist)
	for(var/i, i < 100, i++)
		if(!duplicate_objective_check(selectedobjective))
			selectedobjective = pick_weight_recursive(objectivelist)
		else
			break

	if(selectedobjective == /datum/objective/survive)
		var/datum/objective/survive/survive_objective = new
		selectedobjective =	survive_objective
	if(selectedobjective == /datum/objective/winoperation)
		var/datum/objective/winoperation/winoperation_objective = new
		selectedobjective =	winoperation_objective
	if(selectedobjective == /datum/objective/kill_xenos)
		var/datum/objective/kill_xenos/killxeno_objective = new
		selectedobjective =	killxeno_objective
	if(selectedobjective == /datum/objective/gather_cash)
		var/datum/objective/gather_cash/cash_objective = new
		selectedobjective =	cash_objective
	if(selectedobjective == /datum/objective/deliver_gifts)
		var/datum/objective/deliver_gifts/gifts_objective = new
		selectedobjective =	gifts_objective
	if(selectedobjective == /datum/objective/recruit_elves)
		var/datum/objective/recruit_elves/elves_objective = new
		selectedobjective =	elves_objective

	selectedobjective.find_target()
	if(!selectedobjective.target) //find target returned null, set target to self for sanity
		selectedobjective.target = owner
		selectedobjective.update_explanation_text()
	selectedobjective.owner = owner
	add_objective(selectedobjective)

/datum/antagonist/event_santa/greet()
	playsound(owner, 'sound/effects/hohoho.ogg', 25, 1)
	to_chat(owner, span_boldnotice("<br><B>You are Santa Claus!</B>"))
	to_chat(owner, span_boldnotice("<br><B>You are not an antagonist, so don't act like one!</B>"))
	to_chat(owner, span_boldnotice("Cooperate with the marines while you complete your objectives and avoid collateral damage or harm to anyone who is not a grinch!"))
	to_chat(owner, span_boldnotice("<br><B>You can view your objectives at any time in the IC tab at the top right.</B>"))
	owner.announce_objectives()

//TODO Collate
/datum/antagonist/event_santa/roundend_report()
	var/list/result = list()

	var/traitorwin = TRUE

	result += printplayer(owner)

	var/objectives_text = ""
	if(objectives.len)//If the traitor had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				traitorwin = FALSE
			count++

	result += objectives_text

	var/special_role_text = lowertext(name)

	if(traitorwin)
		result += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		result += "<span class='redtext'>The [special_role_text] has failed!</span>"

	return result.Join("<br>")

/datum/antagonist/event_santa/roundend_report_footer()
	return

/datum/antagonist/event_santa/farewell()
	. = ..()
	to_chat(owner, span_boldnotice("You no longer have any objectives."))

/datum/antagonist/event_santa/on_removal()
	. = ..()
	for(var/datum/action/A AS in usr.actions)
		if(istype(A, /datum/action/objectives))
			A.remove_action(usr)
