#define TRAITOR_HUMAN "human"
#define TRAITOR_AI	  "AI"

/datum/antagonist/corporate_liason
	name = "Traitor"
	roundend_category = "traitors"
	var/employer = "The Syndicate"
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/should_equip = TRUE
	var/traitor_kind = TRAITOR_HUMAN //Set on initial assignment
	var/datum/contractor_hub/contractor_hub

/datum/antagonist/corporate_liason/on_gain()
	if(owner.current && isAI(owner.current))
		traitor_kind = TRAITOR_AI

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
			/datum/objective/winoperation = 1,
			/datum/objective/loseoperation = 2,
			/datum/objective/survive = 7,
		)
		var/datum/objective/selectedobjective
		selectedobjective = pick_weight_recursive(objectivelist)
		if(selectedobjective == /datum/objective/winoperation)
			var/datum/objective/winoperation/winoperation_objective = new
			selectedobjective =	winoperation_objective
		if(selectedobjective == /datum/objective/loseoperation)
			var/datum/objective/maroon/loseoperation_objective = new
			selectedobjective =	loseoperation_objective
		if(selectedobjective == /datum/objective/survive)
			var/datum/objective/assassinate/survive_objective = new
			selectedobjective =	survive_objective
		selectedobjective.owner = owner
		add_objective(selectedobjective)
		return


/*	if(!(locate(/datum/objective/survive) in objectives))
		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = owner
		add_objective(survive_objective)
		return
*/
/datum/antagonist/corporate_liason/proc/forge_single_human_objective() //Returns how many objectives are added
	.=1
	var/list/objectivelist
	objectivelist = list(
		/datum/objective/maroon = 7,
		/datum/objective/assassinate = 2,
		/datum/objective/steal = 2,
	)
	var/datum/objective/selectedobjective
	selectedobjective = pick_weight_recursive(objectivelist)

	if(selectedobjective == /datum/objective/steal)
		var/datum/objective/steal/steal_objective = new
		selectedobjective =	steal_objective
	if(selectedobjective == /datum/objective/maroon)
		var/datum/objective/maroon/maroon_objective = new
		selectedobjective =	maroon_objective
	if(selectedobjective == /datum/objective/maroon)
		var/datum/objective/assassinate/assassinate_objective = new
		selectedobjective =	assassinate_objective

	selectedobjective.find_target()
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
