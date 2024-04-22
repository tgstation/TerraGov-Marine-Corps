
/datum/antagonist/skeleton
	name = "Skeleton"
	increase_votepwr = FALSE

/datum/antagonist/zombie/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/vampirelord))
		var/datum/antagonist/vampirelord/V = examined_datum
		if(!V.disguised)
			return "<span class='boldnotice'>Another deadite.</span>"
	if(istype(examined_datum, /datum/antagonist/zombie))
		return "<span class='boldnotice'>Another deadite.</span>"
	if(istype(examined_datum, /datum/antagonist/skeleton))
		return "<span class='boldnotice'>Another deadite. My ally.</span>"

/datum/antagonist/skeleton/on_gain()
//	if(!(locate(/datum/objective/escape) in objectives))
//		var/datum/objective/escape/boat/escape_objective = new
//		escape_objective.owner = owner
//		objectives += escape_objective
//		return
	return ..()

/datum/antagonist/skeleton/on_removal()
	return ..()


/datum/antagonist/skeleton/greet()
	owner.announce_objectives()
	..()

/datum/antagonist/skeleton/roundend_report()
	return
	var/traitorwin = TRUE

	if(objectives.len)//If the traitor had no objectives, don't need to process this.
		for(var/datum/objective/objective in objectives)
			objective.update_explanation_text()
			if(!objective.check_completion())
				traitorwin = FALSE

	if(traitorwin)
		//arriving gives them a tri anyway, all good
//		owner.adjust_triumphs(1)
		to_chat(owner.current, "<span class='greentext'>I've TRIUMPHED! Arcadia belongs to death!</span>")
		if(owner.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/triumph.ogg', 100, FALSE, pressure_affected = FALSE)
	else
		to_chat(owner.current, "<span class='redtext'>I've FAILED to invade Arcadia!</span>")
		if(owner.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/fail.ogg', 100, FALSE, pressure_affected = FALSE)

