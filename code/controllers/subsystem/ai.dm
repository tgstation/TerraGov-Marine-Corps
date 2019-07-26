//A subsystem that determines what the AI mobs do; currently handles movement

SUBSYSTEM_DEF(ai)
	name = "AI Controller"
	wait = 5
	var/list/aidatums = list()
	var/list/current_run

	//Settings for the AI to obey
	var/is_pacifist = FALSE //Will also ignore zones with any level of danger alongside no slashing

	var/prob_sidestep_melee = 25 //Probability of a xeno side stepping while in melee every time its suppose to move

	var/prioritize_nodes_with_enemies = FALSE //If xenos will beeline to nodes with seen enemies

	var/is_suicidal = FALSE //If the AI will retreat or not when low on health

	var/retreat_health_threshold = 0.50 //What percentage of health the xeno must be to do a retreat

/datum/controller/subsystem/ai/fire(resume = FALSE)
	if(!resume)
		current_run = aidatums.Copy()
	while(current_run.len)
		var/datum/ai_behavior/aidatum = current_run[current_run.len]
		aidatum.Process()
		current_run.len--
		if(TICK_CHECK)
			return

		/*
		var/mob/living/carbon/Xenomorph/Drone/node/ai = current_run[current_run.len]
		if(M.loc != last_turf[M])
			last_turf[M] = M.loc
			M.DoMove()
			if(TICK_CHECK)
				return
			continue
		M.DealWithObstruct()
		M.DoMove()
		if(TICK_CHECK)
			return
		*/
