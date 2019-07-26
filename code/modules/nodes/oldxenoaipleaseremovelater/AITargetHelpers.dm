#define BREAK_LIGHT 1
#define OPEN_DOOR 2
#define GET_HEALED 3
#define MOVE_SUCCESS 1
#define MOVE_BLOCKED 0

/mob/living/carbon/Xenomorph/AI/proc/ListTargets(var/dist)
	var/list/L = range(dist, src)
	return L

/mob/living/carbon/Xenomorph/AI/proc/FindTarget(range)
	var/atom/T = null
	for(var/atom/A in ListTargets(range))

		if(istype(A, /obj/machinery/marine_turret))
			T = A
			break
		if(A == src)
			continue

		if(isliving(A))
			var/mob/living/L = A
			if(L.faction == src.faction)
				continue
			else if (istype(src, /mob/living/simple_animal/hostile/alien) && (isxeno(L)))
				continue
			else
				if(L.stat != DEAD)
					if(L.stat == 1) //In critical condition, it's already down on the ground don't have to care much
						if(prob(25) && prob(100 * (L.alpha / 255))) //If it has less than 255 alpha, it will have a reduced chance of being targeted
							T = L
							break
					else
						if(prob(100 * (L.alpha / 255)))
							T = L
							break
		if(istype(A, /obj/machinery/marine_turret))
			T = A
			break
	return T

/mob/living/carbon/Xenomorph/AI/proc/RemoveTarget() //Removes all of the target_mob and things associated with it
	if(target_mob)
		target_mob = null
		stance = HOSTILE_STANCE_IDLE

/mob/living/carbon/Xenomorph/AI/proc/GetAndSetTarget(range) //Attempts to get and set the target
	for(var/mob/living/carbon/human/human in GLOB.player_list)
		if(human && (get_dist(src, human) < 14))
			if(target_mob && (target_mob != human) && (get_dist(src, human) < get_dist(src, target_mob)))
				SetTarget(human)
			else
				if(!target_mob)
					SetTarget(human)
				else
					continue
	if(target_mob && target_mob.stat >= DEAD) //It ded and no nearby targets found, it's idle time
		RemoveTarget()

/mob/living/carbon/Xenomorph/AI/proc/SetTarget(mob/living/carbon/human/target) //Gives the mob this specific target
	if(target)
		target_mob = target
		stance = HOSTILE_STANCE_ATTACK

/mob/living/carbon/Xenomorph/AI/proc/FindClosedDoors()
	if(thedoor)
		if(!thedoor.density || thedoor.welded || thedoor.locked) //Door is already opened or welded
			thedoor = null
			doingaction = null
	for(var/obj/machinery/door/airlock/door in view(2, src))
		if(door && door.density && !door.welded && !door.locked) //Ripping up time
			thedoor = door
			doingaction = OPEN_DOOR

/mob/living/carbon/Xenomorph/AI/proc/FindLights()
	if(lightfixture)
		if(lightfixture.status != 0) //Light isn't on, ignore it
			lightfixture = null
			doingaction = 0
	for(var/obj/machinery/light/l in range(2, src))
		if(l && l.status == 1) //Break light time
			lightfixture = l
			doingaction = BREAK_LIGHT