#define TRAITOR_HUMAN "human"

/datum/antagonist/corporate_liason
	name = "Corporate Liason"
	roundend_category = "traitors"
	var/employer = "Nanotrasen"
	var/give_objectives = TRUE
	var/traitor_kind = TRAITOR_HUMAN //Set on initial assignment
	//list of players that have signed our recruiting contracts
	var/list/recruitedplayers

/datum/antagonist/corporate_liason/on_gain()
	if(give_objectives)
		forge_traitor_objectives()
	return ..()

/datum/antagonist/corporate_liason/on_removal()
	return ..()

/datum/antagonist/corporate_liason/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/corporate_liason/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/corporate_liason/proc/forge_traitor_objectives()
	forge_human_objectives()

/datum/antagonist/corporate_liason/proc/forge_human_objectives()
	var/objective_count
	var/toa = 3
	for(var/i = objective_count, i < toa, i++)
		forge_single_human_objective()

	if(!(locate(/datum/objective/survive) in objectives))
		var/list/objectivelist
		objectivelist = list(
			/datum/objective/loseoperation = 1,
			/datum/objective/winoperation = 2,
			/datum/objective/survive = 7,
			/datum/objective/escape = 2,
		)

		var/datum/objective/selectedobjective = pick_weight_recursive(objectivelist)
		selectedobjective = pick_weight_recursive(objectivelist)
		if(selectedobjective == /datum/objective/winoperation)
			var/datum/objective/winoperation/winoperation_objective = new
			selectedobjective =	winoperation_objective
		if(selectedobjective == /datum/objective/loseoperation)
			var/datum/objective/loseoperation/loseoperation_objective = new
			selectedobjective =	loseoperation_objective
		if(selectedobjective == /datum/objective/survive)
			var/datum/objective/survive/survive_objective = new
			selectedobjective =	survive_objective
		if(selectedobjective == /datum/objective/escape)
			var/datum/objective/escape/escape_objective = new
			selectedobjective =	escape_objective

		selectedobjective.owner = owner
		add_objective(selectedobjective)
		return

/datum/antagonist/corporate_liason/proc/forge_single_human_objective() //Returns how many objectives are added
	.=1
	var/list/objectivelist
	objectivelist = list(
		/datum/objective/maroon = 1,
		/datum/objective/assassinate = 4,
		/datum/objective/steal = 3,
		/datum/objective/protect = 3,
		/datum/objective/kidnap = 3,
		/datum/objective/gather_cash = 3,
	)
	var/datum/objective/selectedobjective
	selectedobjective = pick_weight_recursive(objectivelist)

	if(selectedobjective == /datum/objective/steal)
		var/datum/objective/steal/steal_objective = new
		selectedobjective =	steal_objective
	if(selectedobjective == /datum/objective/maroon)
		var/datum/objective/maroon/maroon_objective = new
		selectedobjective =	maroon_objective
	if(selectedobjective == /datum/objective/assassinate)
		var/datum/objective/assassinate/assassinate_objective = new
		selectedobjective =	assassinate_objective
	if(selectedobjective == /datum/objective/protect)
		var/datum/objective/protect/protect_objective = new
		selectedobjective =	protect_objective
	if(selectedobjective == /datum/objective/kidnap)
		var/datum/objective/kidnap/kidnap_objective = new
		selectedobjective =	kidnap_objective
	if(selectedobjective == /datum/objective/gather_cash)
		var/datum/objective/gather_cash/gather_cash_objective = new
		selectedobjective =	gather_cash_objective
		selectedobjective.update_explanation_text()

	selectedobjective.find_target()
	if(!selectedobjective.target) //find target returned null, set target to self for sanity
		selectedobjective.target = owner
		selectedobjective.update_explanation_text()
	selectedobjective.owner = owner
	add_objective(selectedobjective)

/datum/antagonist/corporate_liason/greet()
	owner.announce_objectives()

//TODO Collate
/datum/antagonist/corporate_liason/roundend_report()
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

/datum/antagonist/corporate_liason/roundend_report_footer()
	return
