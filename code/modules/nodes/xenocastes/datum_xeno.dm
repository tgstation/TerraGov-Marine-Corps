#define ENEMY_PRESENCE 1
#define DANGER_SCALE 2
#define FINISHED_MOVE "finished moving to node"
#define ENEMY_CONTACT "enemy contact"
#define NO_ENEMIES_FOUND "no enemies found"
#define DISENGAGE "retreating"

//Basic datum AI for a xeno; ability to use acid on obstacles if valid as well as attack obstacles
/datum/ai_behavior/xeno
	var/last_health //For purposes of sensing overall danger at this node
	var/ability_tick_threshold = 0 //Want to do something every X Process()? here ya go

/datum/ai_behavior/xeno/Init()
	..()
	var/mob/living/carbon/xenomorph/parentmob2 = parentmob
	parentmob2.xeno_caste.caste_flags += CASTE_INNATE_HEALING //Sneeki breeki healing
	parentmob.a_intent = INTENT_HARM
	last_health = parentmob.health
	action_state = new/datum/action_state/random_move/scout(src)

/datum/ai_behavior/xeno/proc/AttemptGetTarget()
	for(var/mob/living/carbon/human/human in cheap_get_humans_near(parentmob, 10))
		if(human.stat != DEAD)
			return human
	return FALSE

//Below proc happens every 1/2 second
/datum/ai_behavior/xeno/Process()
	..()

	parentmob.away_time = 200 //No grabbing it now, haven't handled ckey transfer yet for ai behavior

	//If we aren't on a stack of fire and not already resting, we'll go and try to put out the fire, very effective fire!
	if(parentmob.fire_stacks >= 3 && parentmob.canmove && !locate(/obj/effect/particle_effect/fire) in get_turf(parentmob) && prob(100 - ((parentmob.health / parentmob.maxHealth) * 100)))
		parentmob.resist_fire()

	if(parentmob.resting)
		parentmob.set_resting(FALSE) //ARISE MY CHILDREN

	if(parentmob.health < last_health)
		if(get_dist(parentmob, current_node) > get_dist(parentmob, destination_node)) //See what's closer
			destination_node.datumnode.increment_weight(DANGER_SCALE, last_health - parentmob.health)
			current_node.color = "#ff0000" //Red, we got hurt
		else
			current_node.datumnode.increment_weight(DANGER_SCALE, last_health - parentmob.health)
			current_node.color = "#ff0000" //Red, we got hurt
		qdel(action_state)
		action_completed(ENEMY_CONTACT) //Look for enemies, we got hurt

	last_health = parentmob.health
	HandleAbility()

/datum/ai_behavior/xeno/proc/attack_target(atom/target) //Attempts a attack on a target with cooldown restrictions
	var/mob/living/carbon/xenomorph/parentmob2 = parentmob

	if(istype(target, /obj/structure) || istype(target, /obj/machinery)) //We don't miss these targets from prob_melee_slash
		target.attack_alien(parentmob2)
		parentmob.next_move = world.time + parentmob2.xeno_caste.attack_delay
		return

	if(istype(target, /mob/living/carbon) && parentmob.canmove)
		if(parentmob.next_move < world.time) //If we can attack again or not
			var/mob/living/carbon/target2 = target
			if(target2.stat) //Always hit laying down targets
				target2.attack_alien(parentmob2)
				parentmob.next_move = world.time + parentmob2.xeno_caste.attack_delay
			else //The less the target moves, the easier to hit. Every second of not moving increases chance to hit by 75%, 30% chance to hit base
				if(prob(((world.time - target2.last_move_intent) * 75) + 30) * SSai.prob_melee_slash)
					target.attack_alien(parentmob2)
					parentmob.next_move = world.time + parentmob2.xeno_caste.attack_delay
					return

/datum/ai_behavior/xeno/action_completed(reason) //Action state was completed, let's replace it with something else
	switch(reason)
		if(FINISHED_MOVE)
			if(SSai.prioritize_nodes_with_enemies && GLOB.nodes_with_enemies.len && !(current_node in GLOB.nodes_with_enemies)) //There's no enemies at this node but if they're somewhere else we moving to that
				action_state = new/datum/action_state/move_to_node(src)
				var/datum/action_state/move_to_node/the_state = action_state
				the_state.destination_node = pick(shuffle(GLOB.nodes_with_enemies))
			else
				var/list/humans_nearby = cheap_get_humans_near(parentmob, 10)
				if(!humans_nearby.len)
					current_node.remove_from_notable_nodes(ENEMY_PRESENCE)
					action_state = new/datum/action_state/random_move/scout(src)

				else //Enemies found kill em if not pacifist
					current_node.add_to_notable_nodes(ENEMY_PRESENCE)
					current_node.datumnode.set_weight(ENEMY_PRESENCE, humans_nearby.len)
					if(SSai.is_pacifist)
						action_state = new/datum/action_state/random_move/scout(src)
					else
						action_state = new/datum/action_state/hunt_and_destroy(src)

		if(ENEMY_CONTACT)
			action_state = new/datum/action_state/hunt_and_destroy(src)

		if(NO_ENEMIES_FOUND)
			current_node.remove_from_notable_nodes(ENEMY_PRESENCE)
			action_state = new/datum/action_state/random_move/scout(src)

		if(DISENGAGE) //We were on hunt and destroy but now low health, let's get moving and avoid enemies
			action_state = new/datum/action_state/random_move/scout(src)

	action_state.Process()

/datum/ai_behavior/xeno/proc/HandleAbility()
	var/mob/living/carbon/xenomorph/parentmob2 = parentmob
	ability_tick_threshold++
	if(!parentmob || !parentmob2)
		qdel(src)
		return FALSE
	if(parentmob2.stat || !parentmob2.canmove) //Crit or dead
		return FALSE
	return TRUE

/datum/ai_behavior/xeno/HandleObstruction()

	for(var/obj/machinery/door/airlock/door in range(1, parentmob))
		if(door.density && !door.welded)
			door.open()

	for(var/turf/closed/probawall in range(1, parentmob))
		if(!probawall.can_be_dissolved())
			return
		if(probawall.current_acid)
			return
		if(!probawall.acid_check(/obj/effect/xenomorph/acid/strong))
			var/obj/effect/xenomorph/acid/strong/newacid = new /obj/effect/xenomorph/acid/strong(get_turf(probawall), probawall)
			newacid.icon_state += "_wall"
			newacid.acid_strength = 0.1 //Very fast acid
			probawall.current_acid = newacid

	for(var/obj/machinery/machin in range(1, parentmob))
		attack_target(machin)
		return

	for(var/obj/structure/struct in range(1, parentmob))
		attack_target(struct)
		return

//Like the old one but now will do left and right movements upon being in melee range
/datum/ai_behavior/xeno/ProcessMove()
	if(!parentmob.canmove)
		return 4
	var/totalmovedelay = 0
	switch(parentmob.m_intent)
		if(MOVE_INTENT_RUN)
			totalmovedelay += 2 + CONFIG_GET(number/movedelay/run_delay)
		if(MOVE_INTENT_WALK)
			totalmovedelay += 7 + CONFIG_GET(number/movedelay/walk_delay)
	totalmovedelay += parentmob.movement_delay()

	var/doubledelay = FALSE //If we add on additional delay due to it being a diagonal move
	//var/turf/directiontomove = get_dir(parentmob, get_step_towards(parentmob, atomtowalkto)) //We cache the direction so we can adjust move delay on things like diagonal move alongside other things

	var/smarterdirection = action_state.GetTargetDir(TRUE)

	if(!step(parentmob, smarterdirection)) //If this doesn't work, we're stuck
		HandleObstruction()
		return 2

	if(smarterdirection in GLOB.diagonals)
		doubledelay = TRUE

	if(doubledelay)
		move_delay = world.time + (totalmovedelay * SQRTWO)
		return totalmovedelay * SQRTWO
	else
		move_delay = world.time + totalmovedelay
		return totalmovedelay
