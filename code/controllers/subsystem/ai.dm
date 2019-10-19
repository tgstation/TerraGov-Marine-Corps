//A subsystem that determines what the AI mobs do; currently handles movement

SUBSYSTEM_DEF(ai)
	name = "AI Controller"
	wait = 5
	var/list/aidatums = list()
	var/list/current_run

	//Settings for the AI to obey
	var/is_pacifist = FALSE //Will also ignore zones with any level of danger alongside no slashing

	var/prob_sidestep_melee = 50 //Probability of a xeno side stepping while in melee every time its suppose to move

	var/prob_melee_slash_multiplier = 1 //Default makes attacks that require prob() succeed 1/2th as often, good for stuff

	var/prioritize_nodes_with_enemies = FALSE //If xenos will beeline to nodes with seen enemies

	var/is_suicidal = FALSE //If the AI will retreat or not when low on health

	var/retreat_health_threshold = 0.50 //What percentage of health the xeno must be to do a retreat

	//var/stop_retreat_health_threshold = 0.75 //What health percentage we should be at to stop retreating

	var/init_pheromones = FALSE //If pheromone emitting xenos will emit a random pheromone

	var/randomized_xeno_tiers = FALSE //If we want random xeno tiers, here we go, otherwise start off all young

/datum/controller/subsystem/ai/fire(resume = FALSE)
	if(!resume)
		current_run = aidatums.Copy()
	while(length(current_run))
		var/datum/component/ai_behavior/aidatum = current_run[length(current_run)]
		if(QDELETED(aidatum))
			current_run.len--
			continue
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
