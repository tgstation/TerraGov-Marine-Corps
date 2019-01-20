var/global/list/targeted_mobs = list() //All mobs targeted by xeno AI; useful for swarming
var/global/list/AIXenos = list() //List of all AI xenos; used for assigning xenos to squads and home turf defense
var/global/list/AIXenosWithoutSquad = list() //List of all AI xenos without squads

#define BREAK_LIGHT 1
#define OPEN_DOOR 2
#define GET_HEALED 3
#define MOVE_SUCCESS 1
#define MOVE_BLOCKED 0


/mob/living/carbon/Xenomorph/AI //It's like simple_animals but hella better
	faction = "hostile"
	var/stance = HOSTILE_STANCE_IDLE	//Used to determine behavior
	var/mob/living/carbon/human/target_mob
	var/attack_same = 0
	var/ranged = 0
	var/rapid = 0
	var/projectiletype
	var/projectilesound
	var/casingtype
	var/list/friends = list()
	var/move_to_delay = 2
	var/break_stuff_probability = 100
	var/destroy_surroundings = 1
	var/lastattack = 0
	a_intent = "hurt" //All shall die
	var/trueidle = 0 //If the mob should actually idle; for the hunter stealth
	var/rangetomaintain = 1 //1 means its a front line xeno, 0 is like a crusher trying to stomp, anything above is a ranged caste that utilizes spit
	var/doingaction = 0 //If it's doing an action that has a delay IE dousing an object in acid, certain abilities
	var/considerabilityhash = 0 //Used in the ConsiderMovement; every movement tile moved is ability check for attack stances and otherwise 3 movement when idle
	var/obj/machinery/door/airlock/thedoor = null //Doors to target and open up
	var/obj/machinery/light/lightfixture = null //Lights to break
	var/list/randomintent = list() //Any proper intent strings put into here means attacking a target_mob will randomly pick the intents in here
	var/queuedmovement //The direction you want the AI to go on next, if it wanted to go NW the CustomMove() will go North then West
	evolution_speed = 1 //Evolves hella fast
	upgrade_speed = 1 //But will upgrade even faster, so it's mature/elite by the time it evolves
	var/turf/turfdefense //The turf to be up to 14 tiles around in range; target enemies must be inside of this if melee but can otherwise use abilities on the enemies
	var/mob/living/carbon/Xenomorph/AI/LeaderToFollow //A mob that leaders gotta follow, not typecasted to xenos so admin ghosts can lure them
	var/list/SquadMembers = list() //If this mob is a leader, this is all of it's squad members

/mob/living/carbon/Xenomorph/AI/proc/ConsiderAbilities(isattacking) //isattacking means this is called when attacking; can be used for combos like headbutt or crest fling
	return

/datum/admins/proc/xeno_lure()
	set category = "Fun"
	set name = "Xeno AI Lure "
	set desc = "Make xeno AI mobs in a range of 14 tiles follow you forever. Xenos will prioritize targets over following you. This will not work if you move more than 14 tiles away from AI xenos."

	if(!check_rights(0))	return

	for(var/mob/living/carbon/Xenomorph/AI/H in range(14)) //Hella screens away
		if(!H.stat || H.canmove)
			H.LeaderToFollow = usr //Follow the leader time
			AIXenosWithoutSquad -= H
			H.turfdefense = null
	for(var/mob/living/carbon/human/AI/hum in range(14))
		if(!hum.stat || hum.canmove)
			hum.LeaderToFollow = usr

/datum.admins/proc/remove_xeno_lure()
	set category = "Fun"
	set name = "Remove all xeno leader to follow"
	set desc = "Ditto name"

	if(!check_rights(0))	return

	for(var/mob/living/carbon/Xenomorph/AI/H in range(14)) //Hella screens away
		if((!H.stat || H.canmove) && H.LeaderToFollow)
			H.LeaderToFollow = null
			AIXenosWithoutSquad += H

/mob/living/carbon/Xenomorph/AI/New()
	..()
	update_progression() //Evolves it if possible so the correct things can be set
<<<<<<< HEAD
	move_to_delay = initial(move_to_delay) + 1
=======
	move_to_delay = initial(move_to_delay) + config.run_speed
>>>>>>> parent of fa8f5121f... Revert "good bye master"
	ConsiderMovement()
	AIXenos += src
	AIXenosWithoutSquad += src

/mob/living/carbon/Xenomorph/AI/update_progression() //Overridden because parent proc uses client as a check, AIs don't have clients by default
	if(upgrade_stored >= xeno_caste.upgrade_threshold)
		upgrade_xeno(upgrade+1)
		upgrade_stored = 0
	else
		upgrade_stored = min(upgrade_stored + upgrade_speed, xeno_caste.upgrade_threshold)

/mob/living/carbon/Xenomorph/AI/update_evolving()
	if(src)
		evolution_stored += evolution_speed
		if(evolution_stored >= xeno_caste.evolution_threshold && xeno_caste.caste_name != "Queen")
			DoEvolve()
			evolution_stored = 0

/mob/living/carbon/Xenomorph/AI/proc/DoEvolve() //Randomly evolves to a higher caste
	if(xeno_caste.evolves_to && prob(100 - (xeno_caste.tier * 33)))
		var/mob/living/carbon/Xenomorph/castetoevolveto //Hardcode time unless I want to override every single datum
		switch(xeno_caste.caste_name)
			if("Bloody Larva")
				castetoevolveto = pick(/mob/living/carbon/Xenomorph/AI/Drone, /mob/living/carbon/Xenomorph/AI/Runner, /mob/living/carbon/Xenomorph/AI/Sentinel, /mob/living/carbon/Xenomorph/AI/Defender)
			if("Drone")
				castetoevolveto = pick(/mob/living/carbon/Xenomorph/AI/Hivelord)
			if("Runner")
				castetoevolveto = pick(/mob/living/carbon/Xenomorph/AI/Hunter)
			if("Hunter")
				castetoevolveto = pick(/mob/living/carbon/Xenomorph/AI/Ravager)
			if("Sentinel")
				castetoevolveto = pick(/mob/living/carbon/Xenomorph/AI/Spitter)
			if("Defender")
				castetoevolveto = pick(/mob/living/carbon/Xenomorph/AI/Warrior)
			if("Warrior")
				castetoevolveto = pick(/mob/living/carbon/Xenomorph/AI/Praetorian, /mob/living/carbon/Xenomorph/AI/Crusher)
		visible_message("<span class='xenonotice'>\The [src] begins to twist and contort.</span>", \
		"<span class='xenonotice'>You begin to twist and contort.</span>")
		var/mob/living/carbon/Xenomorph/AI/new_xeno = new castetoevolveto(get_turf(src))
		new_xeno.visible_message("<span class='xenodanger'>A [new_xeno.xeno_caste.caste_name] emerges from the husk of \the [src].</span>", \
		"<span class='xenodanger'>You emerge in a greater form from the husk of your old body. For the hive!</span>")
		if(SquadMembers)
			for(var/mob/living/carbon/Xenomorph/AI/members in SquadMembers)
				members.LeaderToFollow = new_xeno
		if(LeaderToFollow)
			LeaderToFollow.SquadMembers -= src
			LeaderToFollow.SquadMembers += new_xeno
		qdel(src)
		//for(var/mob/living/carbon/Xenomorph/AI/Queen/ovi/queen in range(14, new_xeno))
		//	if(queen)
		//		new_xeno.turfdefense = get_turf(queen) //Hug the queen early on until assigned to a squad or evolves later on
	else
		xeno_caste.evolution_threshold = -999999

/mob/living/carbon/Xenomorph/AI/proc/ListTargets(var/dist)
	var/list/L = range(dist, src)
	return L

/mob/living/carbon/Xenomorph/AI/bullet_act(obj/item/projectile/P) //Auto aggro when hit and alert others to come
	..()
	if(!target_mob)
		if(ishuman(P.firer) && get_dist(src, P.firer) < 14)
			SetTarget(P.firer)

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
			if(L.faction == src.faction && !attack_same)
				continue
			else if(L in friends)
				continue
			else if (istype(src, /mob/living/simple_animal/hostile/alien) && (isXeno(L) || (isrobot(L))))
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

//Note; this proc below has no adjacency checks, that's handled by ConsiderAttack()
/mob/living/carbon/Xenomorph/AI/proc/AttackingTarget()
	if(world.time < lastattack + 10 + attack_delay) //Attacking way to soon again
		return
	if(stat || !canmove)
		return
	if(target_mob.stat >= DEAD)
		RemoveTarget()
		GetAndSetTarget(12)
	if(isliving(target_mob))
		var/mob/living/L = target_mob
		L.attack_alien(src)
		lastattack = world.time
		ConsiderAbilities(TRUE)
		if(L.stat >= DEAD)
			RemoveTarget()
			GetAndSetTarget(12)
			spawn(10 + attack_delay)
				ConsiderAttack() //Try to attack again
	DestroySurroundings() //Prioritize hitting humans over barricades

/mob/living/carbon/Xenomorph/AI/proc/RemoveTarget() //Removes all of the target_mob and things associated with it
	if(target_mob)
		target_mob = null
		stance = HOSTILE_STANCE_IDLE
		target_mob.targeted_byAI -= src
		targeted_mobs -= target_mob

/mob/living/carbon/Xenomorph/AI/proc/GetAndSetTarget(range) //Attempts to get and set the target
	for(var/mob/living/carbon/human/human in mob_list)
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
	/*
	var/mob/living/carbon/human/thetarget = FindTarget(range)
	if(thetarget)
		if(target_mob && prob(25)) //Remove references to target *if* we find a new target while having a previous target
			RemoveTarget()
			SetTarget(thetarget) //It got a new target; lead the nearby idle xenos to combat
		if(!target_mob)
			SetTarget(thetarget)
	else
		if(target_mob && target_mob.stat >= DEAD) //It ded and no nearby targets found, it's idle time
			RemoveTarget()
	*/

/mob/living/carbon/Xenomorph/AI/proc/SetTarget(mob/living/carbon/human/target) //Gives the mob this specific target
	if(target)
		stance = HOSTILE_STANCE_ATTACK
		target_mob = target
		targeted_mobs += target
		target_mob.targeted_byAI += src
	ConsiderAttack() //Try seeing if it's actually nearby and attack

/mob/living/carbon/Xenomorph/AI/death(gibbed)
	if(SquadMembers)
		for(var/mob/living/carbon/Xenomorph/AI/xeno in SquadMembers)
			xeno.LeaderToFollow = null
	RemoveTarget()
	walk_to(src, src, 0, move_to_delay + movement_delay()) //Move instantly to self to stop movement
	AIXenos -= src
	if(!LeaderToFollow)
		AIXenosWithoutSquad -= src
	..()
	if(!gibbed)
		spawn(50) //Self cleanup
			if(src) //could've been gibbed somehow
				qdel(src)

/mob/living/carbon/Xenomorph/AI/Life()
	..()
	if(knocked_down)
		knocked_down -= 1
	if(client)
		return
	if(!target_mob || target_mob.stat >= DEAD) //It's null or dead, remove references
		RemoveTarget()
	GetAndSetTarget(12)
	/*
    if(1) return "North"
    if(2) return "South"
    if(4) return "East"
    if(5) return "Northeast"
    if(6) return "Southeast"
    if(8) return "West"
    if(9) return "Northwest"
    if(10) return "Southwest"
*/

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

/mob/living/carbon/Xenomorph/AI/proc/ConsiderMovement() //A custom proc to be used with byond's built in pathfinding, this basically makes the xenos able to rudimentary dodge and do actions in between movement
	if((lying || resting)  && (stance != HOSTILE_STANCE_IDLE || !doingaction)) //Get up my sister its time for stuff
		lying = 0
		resting = 0
		doingaction = 0 //It's in combat, don't rest on the damm ground
	if(target_mob && get_dist(src, target_mob) > 14) //Byond pathfinding limitation is locked to view range x 2 or 14 tiles
		RemoveTarget()
	if(target_mob && !stat && canmove)
		ConsiderAttack() //See if it can fite enemies
	if(!LeaderToFollow && !(src in AIXenosWithoutSquad))
		AIXenosWithoutSquad += src
	if(!stat && canmove)									//This proc will also endlessly loop over and over and is first called in New()
		switch(stance)
			if(HOSTILE_STANCE_IDLE) //Thing is 'idle' and not engaged in combat, it will either be wandering mindlessly and scouting or will just be hanging around
				if(!stat && canmove)
					if(!trueidle && !doingaction && !queuedmovement)
						if(LeaderToFollow && get_dist(src, LeaderToFollow) < 14) //Follow the leader!
							var/turf/turftoleader = get_step_to(src, LeaderToFollow, rand(1, 2)) //Keep some distance
							CustomMove(src, turftoleader, get_dir(src, turftoleader))
						else
							if(turfdefense && get_dist(src, LeaderToFollow) < 14) //Defend the holy land!
								var/turf/turftoturf = get_step_to(src, turfdefense, rand(3, 7))
								CustomMove(src, turftoturf, get_dir(src, turftoturf))
							else
								var/turf/randomturf = get_step_rand(src) //Random movement
								CustomMove(src, randomturf, get_dir(src, randomturf))
					else
						CustomMove(src, get_step(src, queuedmovement), queuedmovement)
						queuedmovement = 0
					switch(doingaction)
						if(OPEN_DOOR)
							if(!Adjacent(thedoor))
								if(istype(thedoor, /obj/machinery/door/airlock/multi_tile) && get_dist(src, thedoor) <= 2)
									thedoor.open(1)
									thedoor = null
									doingaction = null
								else
									if(!queuedmovement)
										CustomMove(src, get_step_to(src, thedoor), get_dir(src, get_step_to(src, thedoor)))
									else
										CustomMove(src, get_step(src, queuedmovement), queuedmovement)
										queuedmovement = 0
							else
								thedoor.open(1)
								thedoor = null
								doingaction = null
						if(BREAK_LIGHT)
							if(!Adjacent(lightfixture))
								if(!queuedmovement)
									CustomMove(src, get_step_to(src, lightfixture), get_dir(src, get_step_to(src, lightfixture)))
								else
									CustomMove(src, get_step(src, queuedmovement), queuedmovement)
									queuedmovement = 0
							else
								lightfixture.attack_alien(src)
								lightfixture = null
								doingaction = null
						if(GET_HEALED) //Defender of a turf is injured; time to heal up
							if(health == maxHealth) //It's already healed up my dude
								doingaction = 0
				if(!(considerabilityhash >= 4)) //Only time this goes is when the idle is called
					considerabilityhash += 1
				else
					considerabilityhash = 0
					GetAndSetTarget(12)
					ConsiderAbilities()
				if(!(trueidle))
					FindClosedDoors()
					FindLights()

			if(HOSTILE_STANCE_ATTACK) //Found a target but not in range; this is for moving to and from targets and doesn't handle attacking targets
				if(target_mob && get_dist(src, target_mob) > 14) //Byond pathfinding limitation is locked to view range x 2 or 14 tiles
					RemoveTarget()
				if(target_mob.stat >= DEAD)
					RemoveTarget()
				ConsiderAbilities()
				if(get_dist(src, target_mob) > rangetomaintain) //It's closing time
					if(prob(75)) //Small chance to actually move towards the target_mob, otherwise go left or right
						CustomMove(src, get_step_to(src, target_mob), get_dir(src, get_step_to(src, target_mob)))

					else //Side step dodging on way to target
						var/list/leftrightdir = LeftAndRightOfDir(dir)
						if(!(CustomMove(src, get_step(src, leftrightdir[1]), leftrightdir[1]))) //Damm the left side is blocked
							CustomMove(src, get_step(src, leftrightdir[2]), leftrightdir[2]) //Try to right side anyway; chances are the right side could be blocked but don't care much about that
				else //We're too close, let's retreat
					CustomMove(src, get_step_away(src, target_mob, rangetomaintain), get_dir(src, get_step_away(src, target_mob, rangetomaintain)))
				for(var/obj/machinery/door/airlock/door in view(1, src))
					if(door && door.density && !door.welded)
						door.open(1)

			if(HOSTILE_STANCE_ATTACKING) //In melee range, if the xeno isn't meant to keep directly on top of the target it will keep on circling around it if possible
				if(target_mob.stat >= DEAD)
					RemoveTarget()
				var/failedcounter = 0 //How many directions would fail if the xeno moves and the target would be out of melee range: make stance back to ATTACK so it can chase
				ConsiderAbilities()										//Prob 25 because 100% of the time its overboard
				if(rangetomaintain == 1 && get_dist(src, target_mob) <= 1) //Specifically one, zero means it won't want to be able to circle around the mob when attacking
					var/list/dirs = list(NORTH, EAST, WEST, SOUTH)
					var/randomdir
					for(var/direction in dirs) //Why don't I do < i or whatever loop? cause im lazy thats why
						randomdir = pick(dirs)
						var/turf/turf = get_step(src, randomdir)
						if(target_mob in range(1, turf)) //If the target mob is in distance, it's good to move to the turf so it can keep on attacking
							CustomMove(src, turf, randomdir)
							break
						else
							failedcounter += 1
				else //Distance is greater than 1 but in melee stance, keep on chasing
					stance = HOSTILE_STANCE_ATTACK
				if(failedcounter > 3) //All four directions fail; cannot walk into range of target_mob
					stance = HOSTILE_STANCE_ATTACK
	spawn(move_to_delay + movement_delay() + 1)
		ConsiderMovement()
/*
/proc/TryMakeSquad() //Trys to make a squad out of xenos in the list, assumes xenos are close
	if(AIXenosWithoutSquad.len > 4) //At least four xenos
		var/squadmembers = 1 //Includes leader down
		var/mob/living/carbon/Xenomorph/AI/xenolead = pick(AIXenosWithoutSquad) //Congrats you the random leader
		while(xenolead.xeno_caste.caste_name != "Larva" || xenolead.xeno_caste.caste_name != "Queen")
			xenolead = pick(AIXenosWithoutSquad)
		xenolead.queen_chosen_lead = TRUE //Pheromones baby
		AIXenosWithoutSquad -= xenolead
		for(var/mob/living/carbon/Xenomorph/AI/xeno in AIXenosWithoutSquad)
			if(squadmembers < 5)
				if(xeno.LeaderToFollow)
					continue
				if(xeno.SquadMembers)
					continue
				if(xeno == xenolead)
					continue
				if(xeno.xeno_caste.caste_name == "Larva" || xeno.xeno_caste.caste_name == "Queen")
					continue
				if(get_dist(get_turf(xenolead), get_turf(xeno)) < 10) //Be in range for pathfinding
					squadmembers += 1
					xeno.LeaderToFollow = xenolead
					xenolead.SquadMembers += xeno
					AIXenosWithoutSquad -= xeno
		world << "Xeno squad made with [squadmembers] and a [xenolead.name]."
*/
/*
A custom Move() for the AI xenomorphs
Main feature about this is that if Move() is null for whatever reason, we can try again in different dirs or other things
Depending on what had gone wrong instead of putting all of that into the main loop and copy paste it everywhere, it's here.
*/
/proc/CustomMove(atom/movable/A, turf, direction)
	if(IsDiagonal(direction))
		var/list/sanitydir = DirectionToCardinal(direction) //Try one of the two possible movements then queue up the next
		if(!(A.Move(get_step(A, sanitydir[1]), sanitydir[1]))) //If first Move() fails, try the other cardinal dir in case the direction is diagonal
			if(!(A.Move(get_step(A, sanitydir[2]), sanitydir[2]))) //If this fails, the thing has probably become trapped, loose the target and idle move for a bit
				if(istype(A, /mob/living/carbon/Xenomorph/AI))
					var/mob/living/carbon/Xenomorph/AI/xeno = A
					xeno.RemoveTarget()
				return MOVE_BLOCKED
			else
				var/mob/living/carbon/Xenomorph/AI/xeno = A
				xeno.queuedmovement = sanitydir[1]
				var/mob/living/carbon/human/AI/hum = A
				hum.queuedmovement = sanitydir[1]
				return MOVE_SUCCESS
		else
			var/mob/living/carbon/Xenomorph/AI/xeno = A
			xeno.queuedmovement = sanitydir[2]
			var/mob/living/carbon/human/AI/hum = A
			hum.queuedmovement = sanitydir[2]
			return MOVE_SUCCESS //Otherwise yay it worked
	else
		if(!(A.Move(turf, direction))) //It failed, return bad stuff
			return MOVE_BLOCKED
		return MOVE_SUCCESS

/*
A custom proc that looks at everything in the path of a object going from srcturf to destturf, additional parameters if you want to check for certain things
usehitchance when set to true ultilizes get_projectile_hit_chance(), meaning it will return FALSE if it cannot path through the target
It will also check for density as well as IFF built into the projectiles, don't want friendly fire happening
*/
/proc/IsClearPath(turf/srcturf, mob/living/target, usehitchance, obj/item/projectile/p)
	if(!(target in hearers(7, src))) //Target not in sight, can't shoot it
		return FALSE
	var/turf/tempturf = srcturf //We ignore the src turf as we cannot shoot it if we're on it, in addition we're doing a pah right to the target, no intelligent pathfinding around walls
	while(tempturf != get_turf(target)) //Gotta be same turf as target
		tempturf = get_step(src, get_dir(tempturf, get_turf(target)))
		for(var/mob/living/L in tempturf)
			if(L && (L != target) && (L.get_projectile_hit_chance(p))) //If it returns true there's a **chance** we could hit it, don't want to risk it
				tempturf = get_turf(target)
				return FALSE
	return TRUE

/proc/LeftAndRightOfDir(direction) //Returns the left and right dir of the input dir, used for AI stutter step and cade movement, must be sanitized to not have diagonals
	var/list/somedirs = list()
	switch(direction)
		if(NORTH)
			somedirs = list(WEST, EAST)
		if(SOUTH)
			somedirs = list(EAST, WEST)
		if(WEST)
			somedirs = list(SOUTH, NORTH)
		if(EAST)
			somedirs = list(NORTH, SOUTH)
	return(somedirs)

/proc/IsDiagonal(d) //For seeing if a direction is diagonal
	if(d == 1 || d == 2 || d == 4 || d == 8) //Pretty horrible, could be definitely better
		return 0 //It's cardinal
	return 1 //It's diagonal

/proc/DirectionToCardinal(d, index) //Sanitizes the input by converting it from a diagonal to cardinal if it's a diagonal, index is if you want first or second result
	var/list/possibledir = list(d, d)
	if(!(IsDiagonal(d)))
		return(possibledir)
	else
		switch(d)
			if(NORTHEAST)
				possibledir = list(NORTH, EAST)
			if(NORTHWEST)
				possibledir = list(NORTH, WEST)
			if(SOUTHEAST)
				possibledir = list(SOUTH, EAST)
			if(SOUTHWEST)
				possibledir = list(SOUTH, WEST)
		if(index)
			return(possibledir[index])
		return(possibledir)

/mob/living/carbon/Xenomorph/AI/proc/ConsiderAttack() //Target acquiration is handled by Life()
	if(stat || !canmove)
		return
	if(target_mob && get_dist(src, target_mob) <= 1)	//Attacking
		stance = HOSTILE_STANCE_ATTACKING
		AttackingTarget()
		return 1
	else
		DestroySurroundings() //Target isn't nearby, hit a structure while you're at it

/mob/living/carbon/Xenomorph/AI/proc/DestroySurroundings()
	if(world.time < lastattack + 10 - attack_delay) //Attacking way to soon again
		return
	if(prob(break_stuff_probability))
		for(var/dir in cardinal) // North, South, East, West
			for(var/obj/structure/window/obstacle in get_step(src, dir))
				if(obstacle.dir == reverse_dir[dir]) // So that windows get smashed in the right order
					obstacle.attack_alien(src)
					lastattack = world.time
					spawn(10 + attack_delay)
						ConsiderAttack()
					return
			var/obj/structure/obstacle = locate(/obj, get_step(src, dir))
			if(istype(obstacle, /obj/machinery/door/window) || istype(obstacle, /obj/structure/window) || istype(obstacle, /obj/structure/closet) || istype(obstacle, /obj/structure/table) || istype(obstacle, /obj/structure/grille) || istype(obstacle, /obj/structure/barricade) || istype(obstacle, /obj/structure/razorwire) || istype(obstacle, /obj/machinery/marine_turret))
				obstacle.attack_alien(src)
				lastattack = world.time
				/*
				var/list/leftright = LeftAndRightOfDir(dir) //Move to left or right if possible; opens up space
				if(!CustomMove(src, get_step(src, leftright[1]), leftright[1]))
					CustomMove(src, get_step(src, leftright[2]), leftright[2])
				*/
				spawn(10 + attack_delay)
					ConsiderAttack()

/mob/living/carbon/Xenomorph/AI/Larva
	caste_base_type = /mob/living/carbon/Xenomorph/Larva
	speak_emote = list("hisses")
	icon_state = "Bloody Larva"
	amount_grown = 0
	max_grown = 100
	maxHealth = 35
	health = 35
	see_in_dark = 8
	flags_pass = PASSTABLE | PASSMOB
	away_timer = 300
	tier = 0  //Larva's don't count towards Pop limits
	upgrade = -1
	gib_chance = 25
	wound_type = "alien" //used to match appropriate wound overlays
	trueidle = TRUE //Just stand still and wait to evolve
	rangetomaintain = 10 //If it does aggro stay really far away
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/xenohide,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl
		)

/mob/living/carbon/Xenomorph/AI/Larva/update_progression()
	amount_grown += upgrade_speed
	if(locate(/obj/effect/alien/weeds) in loc)
		amount_grown += upgrade_speed
	if(amount_grown > max_grown)
		DoEvolve()

/mob/living/carbon/Xenomorph/AI/Larva/random //Evolves to a random alien

/mob/living/carbon/Xenomorph/AI/Larva/random/New()
	..()
	xeno_caste.caste_name = pick("Bloody Larva", "Drone", "Runner", "Hunter", "Sentinel", "Defender", "Warrior")
	DoEvolve()

/mob/living/carbon/Xenomorph/AI/Drone
	caste_base_type = /mob/living/carbon/Xenomorph/Drone
	name = "Drone"
	desc = "An Alien Drone"
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Drone Walking"
	health = 120
	maxHealth = 120
	plasma_stored = 350
	tier = 1
	upgrade = 0
	speed = -0.8
	pixel_x = 0
	old_x = 0
	pull_speed = -2
	wound_type = "alien" //used to match appropriate wound overlays

/mob/living/carbon/Xenomorph/AI/Drone/ConsiderAbilities()
	var/hasweeds = 0
	for(var/obj/effect/alien/weeds/node/node in range(2))
		if(node)
			hasweeds = 1
	if(!hasweeds)
		new /obj/effect/alien/weeds/node(src.loc)
		playsound(loc, "alien_resin_build", 25)

/mob/living/carbon/Xenomorph/AI/Drone/New()
	..()
	current_aura = pick("frenzy", "warding", "recovery")

/mob/living/carbon/Xenomorph/AI/Drone/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Drone/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Drone/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Runner
	caste_base_type = /mob/living/carbon/Xenomorph/Runner
	name = "Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	health = 100
	maxHealth = 100
	plasma_stored = 50
	speed = -1.8
	flags_pass = PASSTABLE
	tier = 1
	upgrade = 0
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	wound_type = "runner" //used to match appropriate wound overlays

/mob/living/carbon/Xenomorph/AI/Runner/New()
	..()
	zone_selected = pick("r_leg", "l_leg", "r_foot", "l_foot", "r_arm", "l_arm", "r_hand", "l_hand") //Welcome to hell

/mob/living/carbon/Xenomorph/AI/Runner/ConsiderAbilities(isattacking)
	..()
	if(stance == HOSTILE_STANCE_ATTACK)
		if(get_dist(src, target_mob) <= 4 && !usedPounce && !target_mob.lying) //Pounce the target if in range; blind pounce as well, don't care about barricades.
			Pounce(target_mob)

/mob/living/carbon/Xenomorph/AI/Runner/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Runner/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Runner/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Queen
	caste_base_type = /mob/living/carbon/Xenomorph/Queen
	name = "Queen"
	desc = "A huge, looming alien creature. The biggest and the baddest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Queen Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	health = 300
	maxHealth = 300
	amount_grown = 0
	max_grown = 10
	plasma_stored = 300
	speed = 0.6
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = 0 //Queen doesn't count towards population limit.
	upgrade = 0
	xeno_explosion_resistance = 3 //some resistance against explosion stuns.

	var/breathing_counter = 0
	var/ovipositor = FALSE //whether the Queen is attached to an ovipositor
	var/ovipositor_cooldown = 0
	var/queen_ability_cooldown = 0
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph the queen is currently overwatching
	var/egg_amount = 0 //amount of eggs inside the queen
	var/last_larva_time = 0

/mob/living/carbon/Xenomorph/AI/Queen/New()
	..()
	current_aura = pick("frenzy", "warding", "recovery")

/mob/living/carbon/Xenomorph/AI/Queen/ConsiderAbilities(isattacking)
	if(!has_screeched)
		if(health < maxHealth / 2) //It has low health, screech while you're at it
			queen_screech()
		else //Else it's currently killing some fools
			for(var/mob/living/carbon/human/H in view(2, src))
				if(H && !H.stat)
					queen_screech()

/mob/living/carbon/Xenomorph/AI/Queen/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Queen/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Queen/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Queen/ovi //It's like regular queen but now ovipositers
	var/larvacooldown = 600 //One minute per larva
	var/lastlarva

/mob/living/carbon/Xenomorph/AI/Queen/ovi/New()
	..()
	mount_ovipositor()
	ovipositor = TRUE
	trueidle = TRUE
	lying = TRUE
	resting = FALSE
	m_intent = 7
	icon = 'icons/Xeno/Ovipositor.dmi'
	icon_state = "Queen Ovipositor"
	xeno_caste.evolution_threshold = 999999

/mob/living/carbon/Xenomorph/AI/Queen/ovi/ConsiderAbilities(isattacking)
	egg_amount = 0
	if(lastlarva < world.time)
		new /mob/living/carbon/Xenomorph/AI/Larva(get_turf(src))
		lastlarva = world.time + larvacooldown
		//TryMakeSquad() //Attempts to make a squad out of all of the xenos not in a squad

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H && !H.stat)
			queen_screech() // ; halp there's tallhosts here
			for(var/mob/living/carbon/Xenomorph/AI/X in range(14)) //Here comes the horde
				if(!X.stat)
					X.SetTarget(H)
			break



/mob/living/carbon/Xenomorph/AI/Queen/ovi/ConsiderMovement()
	ConsiderAbilities()
	spawn(10)
		if(stat != DEAD)
			ConsiderMovement()

/mob/living/carbon/Xenomorph/AI/Queen/ovi/update_icons()
	icon = initial(icon)
	if(stat >= DEAD)
		icon_state = "Queen Dead"
	else if(ovipositor)
		icon = 'icons/Xeno/Ovipositor.dmi'
		icon_state = "Queen Ovipositor"
	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()

/mob/living/carbon/Xenomorph/AI/Queen/ovi/FindTarget()
	return

/mob/living/carbon/Xenomorph/AI/Queen/ovi/SetTarget()
	return

/mob/living/carbon/Xenomorph/AI/Queen/ovi/GetAndSetTarget(range)
	return

/mob/living/carbon/Xenomorph/AI/Queen/ovi/random //A queen ovi that spawns random tiered xenos, good for wave defense
	larvacooldown = 100


/mob/living/carbon/Xenomorph/AI/Queen/ovi/random/ConsiderAbilities(isattacking)
	egg_amount = 0
	if(lastlarva < world.time)
		new /mob/living/carbon/Xenomorph/AI/Larva/random(get_turf(src))
		lastlarva = world.time + larvacooldown

/mob/living/carbon/Xenomorph/AI/Crusher
	caste_base_type = /mob/living/carbon/Xenomorph/Crusher
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Crusher Walking"
	health = 300
	maxHealth = 300
	plasma_stored = 200
	speed = 0.1
	tier = 3
	upgrade = 0
	drag_delay = 6 //pulling a big dead xeno is hard
	xeno_explosion_resistance = 3 //no stuns from explosions, ignore damages except devastation range.
	mob_size = MOB_SIZE_BIG
	wound_type = "crusher" //used to match appropriate wound overlays
	is_charging = 1 //Crushers start with charging enabled
	a_intent = "disarm" //It wants to stun people
	pixel_x = -16
	pixel_y = -3
	old_x = -16
	old_y = -3
	randomintent = list("harm", "disarm")

/mob/living/carbon/Xenomorph/AI/Crusher/ConsiderAbilities(isattacking = 0)
	if(isattacking && !has_screeched && target_mob && target_mob.lying && (get_dist(src, target_mob) <= 1)) //The target mob is lying down, move to it and stomp
		stomp()
	if(target_mob && (get_dist(src, target_mob) <= 1) && !lying && !cresttoss_used) //Chances are if it's not lying down it's standing up and/or hugging a cade, fling em over
		cresttoss(target_mob) //Automatically throw them backwards because of disarm intent

/mob/living/carbon/Xenomorph/AI/Crusher/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Crusher/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Crusher/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Ravager
	caste_base_type = /mob/living/carbon/Xenomorph/Ravager
	name = "Ravager"
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Ravager Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	xeno_explosion_resistance = 1 //can't be gibbed from explosions
	tier = 3
	upgrade = 0
	pixel_x = -16
	old_x = -16
	//Ravager vars
	var/rage = 0
	var/rage_resist = 1.00
	var/ravage_used = FALSE
	var/ravage_delay = null
	var/charge_delay = null
	var/second_wind_used = FALSE
	var/second_wind_delay = null
	var/last_rage = null
	var/last_damage = null
	var/usedcharge = FALSE

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/charge,
		/datum/action/xeno_action/activable/ravage,
		/datum/action/xeno_action/second_wind,
		)

/mob/living/carbon/Xenomorph/AI/Ravager/New()
	..()
	zone_selected = pick("r_leg", "l_leg", "r_foot", "l_foot", "r_arm", "l_arm", "r_hand", "l_hand") //Welcome to hell

/mob/living/carbon/Xenomorph/AI/Ravager/ConsiderAbilities(isattacking)
	if(rage > 30 && get_dist(src, target_mob) <= 3 && !usedPounce && !target_mob.lying) //Pounce the target if in range; blind pounce as well, don't care about barricades.
		charge(target_mob)
	if(isattacking && target_mob && !ravage_used)
		Ravage(target_mob)

/mob/living/carbon/Xenomorph/AI/Ravager/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Ravager/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Ravager/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Hunter
	caste_base_type = /mob/living/carbon/Xenomorph/Hunter
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Hunter Running"
	health = 150
	maxHealth = 150
	plasma_stored = 50
	tier = 2
	upgrade = 0
	var/stealth_delay = null
	var/last_stealth = null
	var/used_stealth = FALSE
	var/stealth = FALSE
	var/can_sneak_attack = FALSE
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/pounce,
		/datum/action/xeno_action/activable/stealth,
		)

/mob/living/carbon/Xenomorph/AI/Hunter/New()
	..()
	zone_selected = pick("r_leg", "l_leg", "r_foot", "l_foot", "r_arm", "l_arm", "r_hand", "l_hand") //Welcome to hell


/mob/living/carbon/Xenomorph/AI/Hunter/ConsiderAbilities(isattacking)
	if(!used_stealth && prob(6)) //Chance to stay put and stealth
		trueidle = 1
		doingaction = 1
		Stealth()

	if(get_dist(src, target_mob) <= 4 && !usedPounce && !target_mob.lying) //Pounce the target if in range; blind pounce as well, don't care about barricades.
		Pounce(target_mob)

/mob/living/carbon/Xenomorph/AI/Hunter/bullet_act(obj/item/projectile/P) //If it breaks our stealth stop the idle
	..()
	if(P.damage > 10)
		trueidle = 0 //Chances are we were stealth, stop the idle so we can fight manly
		doingaction = 0

/mob/living/carbon/Xenomorph/AI/Hunter/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Hunter/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Hunter/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Spitter
	caste_base_type = /mob/living/carbon/Xenomorph/Spitter
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Spitter Walking"
	health = 180
	maxHealth = 180
	plasma_stored = 150
	speed = -0.5
	pixel_x = 0
	old_x = 0
	tier = 2
	upgrade = 0
	acid_cooldown = 0
	wound_type = "alien" //used to match appropriate wound overlays
	rangetomaintain = 7

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

/mob/living/carbon/Xenomorph/AI/Spitter/ConsiderAbilities(isattacking)
	if(has_spat < world.time && target_mob && get_dist(src, target_mob) < 8)
		xeno_spit(target_mob)

/mob/living/carbon/Xenomorph/AI/Spitter/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Spitter/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Spitter/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Defender
	caste_base_type = /mob/living/carbon/Xenomorph/Defender
	name = "Defender"
	desc = "A alien with an armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Defender Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	speed = -0.2
	pixel_x = -16
	old_x = -16
	tier = 1
	upgrade = 0
	pull_speed = -2
	wound_type = "defender" //used to match appropriate wound overlays
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/toggle_crest_defense,
		/datum/action/xeno_action/activable/fortify,
		/datum/action/xeno_action/activable/headbutt,
		/datum/action/xeno_action/activable/tail_sweep
		)

/mob/living/carbon/Xenomorph/AI/Defender/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Defender/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Defender/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Defender/ConsiderAbilities(isattacking)
	if(isattacking && !used_headbutt && !fortify)
		headbutt(target_mob)
	if(isattacking && !used_tail_sweep && !fortify)
		tail_sweep()
	if(!used_crest_defense && !crest_defense && health < maxHealth / 2) //Low health, time to crest defense
		toggle_crest_defense() //Become somewhat unstoppable
	else
		toggle_crest_defense() //Raise up chest
	if(!used_fortify && !fortify && health < maxHealth / 4) //We are in deep crap, fortify time
		fortify()
	else
		fortify = FALSE
		fortify_off()

/mob/living/carbon/Xenomorph/AI/Warrior
	caste_base_type = /mob/living/carbon/Xenomorph/Warrior
	name = "Warrior"
	desc = "A beefy, alien with an armored carapace."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Warrior Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	speed = -0.3
	pixel_x = -16
	old_x = -16
	tier = 2
	upgrade = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/toggle_agility,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/punch
		)

/mob/living/carbon/Xenomorph/AI/Defender/ConsiderAbilities(isattacking)
	if(!used_lunge && !isattacking && target_mob && get_dist(src, target_mob) < 5)
		lunge(target_mob)
	if(!used_punch && !isattacking && target_mob && get_dist(src, target_mob) < 2)
		punch(target_mob)
	if(!used_fling && isattacking)
		fling(target_mob)

/mob/living/carbon/Xenomorph/AI/Warrior/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Warrior/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Warrior/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Praetorian
	caste_base_type = /mob/living/carbon/Xenomorph/Praetorian
	name = "Praetorian"
	desc = "A huge, looming beast of an alien."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Praetorian Walking"
	health = 210
	maxHealth = 210
	plasma_stored = 200
	speed = -0.1
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = 3
	upgrade = 0
	var/sticky_cooldown = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid
		)

/mob/living/carbon/Xenomorph/AI/Praetorian/New()
	..()
	current_aura = pick("frenzy", "warding", "recovery")

/mob/living/carbon/Xenomorph/AI/Praetorian/ConsiderAbilities(isattacking)
	if(has_spat < world.time && target_mob)
		xeno_spit(target_mob)

/mob/living/carbon/Xenomorph/AI/Praetorian/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Praetorian/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Praetorian/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/AI/Sentinel
	caste_base_type = /mob/living/carbon/Xenomorph/Sentinel
	name = "Sentinel"
	desc = "A slithery, spitting kind of alien."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Sentinel Walking"
	health = 150
	maxHealth = 150
	plasma_stored = 75
	pixel_x = 0
	old_x = 0
	tier = 1
	upgrade = 0
	speed = -0.8
	pull_speed = -2
	wound_type = "alien" //used to match appropriate wound overlays
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/xeno_spit,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

/mob/living/carbon/Xenomorph/AI/Sentinel/ConsiderAbilities(isattacking)
	if(has_spat < world.time && target_mob && get_dist(src, target_mob) < 8)
		xeno_spit(target_mob)

/mob/living/carbon/Xenomorph/AI/Hivelord
	caste_base_type = /mob/living/carbon/Xenomorph/Hivelord
	name = "Hivelord"
	desc = "A huge ass xeno covered in weeds! Oh shit!"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Hivelord Walking"
	health = 250
	maxHealth = 250
	plasma_stored = 200
	pixel_x = -16
	old_x = -16
	speed = 0.4
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	var/speed_activated = 0
	tier = 2
	upgrade = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin/hivelord,
		//datum/action/xeno_action/activable/transfer_plasma/hivelord,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/build_tunnel,
		/datum/action/xeno_action/toggle_speed,
		)

/mob/living/carbon/Xenomorph/AI/Hivelord/New()
	..()
	current_aura = pick("frenzy", "warding", "recovery")
	speed_activated = 1 //Gotta go fast

/mob/living/carbon/Xenomorph/AI/Hivelord/movement_delay()
	. = ..()

	if(speed_activated)
		if(locate(/obj/effect/alien/weeds) in loc)
			. -= 1.5

/mob/living/carbon/Xenomorph/AI/Hivelord/ConsiderAbilities(isattacking)
	var/hasweeds = 0
	for(var/obj/effect/alien/weeds/node/node in range(2))
		if(node)
			hasweeds = 1
	if(!hasweeds)
		new /obj/effect/alien/weeds/node(src.loc)
		playsound(loc, "alien_resin_build", 25)

/mob/living/carbon/Xenomorph/AI/Hivelord/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/AI/Hivelord/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/AI/Hivelord/ancient
	upgrade = 3
