var/global/list/targeted_mobs = list() //All mobs targeted by xeno AI; useful for swarming
var/global/list/AIXenos = list() //List of all AI xenos; used for assigning xenos to squads and home turf defense
var/global/list/AIXenosWithoutSquad = list() //List of all AI xenos without squads

#define BREAK_LIGHT 1
#define OPEN_DOOR 2
#define GET_HEALED 3
#define MOVE_SUCCESS 1
#define MOVE_BLOCKED 0
#define RANDOM_MOVE 1

/mob/living/carbon/Xenomorph/AI //It's like simple_animals but hella better
	faction = "hostile"
	var/stance = HOSTILE_STANCE_IDLE	//Used to determine behavior
	var/mob/living/carbon/human/target_mob
	var/destroy_surroundings = 1
	var/lastattack = 0
	a_intent = "harm" //All shall die
	var/trueidle = 0 //If the mob should actually idle; for the hunter stealth
	var/rangetomaintain = 1 //1 means its a front line xeno, 0 is like a crusher trying to stomp, anything above is a ranged caste that utilizes spit
	var/doingaction = 0 //If it's doing an action that has a delay IE dousing an object in acid, certain abilities
	var/considerabilityhash = 0 //Used in the ConsiderMovement; every movement tile moved is ability check for attack stances and otherwise 3 movement when idle
	var/obj/machinery/door/airlock/thedoor = null //Doors to target and open up
	var/obj/machinery/light/lightfixture = null //Lights to break
	var/list/randomintent = list() //Any proper intent strings put into here means attacking a target_mob will randomly pick the intents in here
	var/queuedmovement //The direction you want the AI to go on next, if it wanted to go NW the CustomMove() will go North then West
	//evolution_speed = 2 //Evolves hella fast
	//upgrade_speed = 2 //But will upgrade even faster, so it's mature/elite by the time it evolves
	var/turf/turfdefense //The turf to be up to 14 tiles around in range; target enemies must be inside of this if melee but can otherwise use abilities on the enemies
	var/mob/living/carbon/Xenomorph/AI/LeaderToFollow //A mob that leaders gotta follow, not typecasted to xenos so admin ghosts can lure them
	var/list/SquadMembers = list() //If this mob is a leader, this is all of it's squad members
/*
	trueidle = TRUE
	var/list/nodepathing = list() //Lists of nodes to travel to
	var/obj/effect/landmark/AINode/currentnode //Current node at
	var/obj/effect/landmark/AINode/destinationnode //Node it wants to go to
	move_to_delay = 4
	var/list/currentpath //Current path this should take; isn't refreshed sadly
*/

/mob/living/carbon/Xenomorph/AI/update_progression()
	if(upgrade_possible() && upgrade != -1 && upgrade != 3) //upgrade possible
		if(upgrade_stored >= xeno_caste.upgrade_threshold)
			if(health == maxHealth && !incapacitated() && !handcuffed && !legcuffed)
				upgrade_xeno(upgrade+1)
			else
				upgrade_stored = min(upgrade_stored + 1, xeno_caste.upgrade_threshold)

/mob/living/carbon/Xenomorph/AI/update_evolving()
	if(src)
		evolution_stored += 1
		if(evolution_stored >= xeno_caste.evolution_threshold && xeno_caste.caste_name != "Queen" && CASTE_EVOLUTION_ALLOWED)
			DoEvolve()
			evolution_stored = 0

/mob/living/carbon/Xenomorph/AI/bullet_act(var/obj/item/projectile/Proj)
	..()
	if(!Proj)
		return

	//if((health < (maxHealth / 2)) && (rangetomaintain == initial(rangetomaintain)) //50 or less percent health remaining, go back and heal
	//	rangetomaintain = 14 //retreat time
	//else
	//	if(rangetomaintain != initial(rangetomaintain)) //More than fifty percent health but modified rangetomaintain, set to normal
	//		rangetomaintain = initial(rangetomaintain)

	if(get_dist(src, Proj.firer) < 14)
		SetTarget(Proj.firer)



/mob/living/carbon/Xenomorph/AI/proc/DoEvolve() //Randomly evolves to a higher caste
	if(xeno_caste.evolves_to && prob(100 - (xeno_caste.tier * 34)))
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
		qdel(src)
		//for(var/mob/living/carbon/Xenomorph/AI/Queen/ovi/queen in range(14, new_xeno))
		//	if(queen)
		//		new_xeno.turfdefense = get_turf(queen) //Hug the queen
	else
		xeno_caste.evolution_threshold = -999999

/mob/living/carbon/Xenomorph/AI/death(gibbed)
	..()
	if(src)
		qdel()

/mob/living/carbon/Xenomorph/AI/Initialize() //Start off it's movement loop
	..()
	addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)

/mob/living/carbon/Xenomorph/AI/Life()
	. = ..()
	GetAndSetTarget(12)

/mob/living/carbon/Xenomorph/AI/proc/ConsiderAbilities()
	return

/mob/living/carbon/Xenomorph/AI/proc/ConsiderAttack()
	if(world.time < lastattack + 10 + attack_delay) //Attacking way too soon again
		return
	if(target_mob)
		if(get_dist(src, target_mob) <= 1)
			if(target_mob.stat != 1) //It's in crit, much easier to hit
				target_mob.attack_alien(src)
				lastattack = world.time
				stance = HOSTILE_STANCE_ATTACKING
			else
				if(prob(50)) //50 percent chance of actually hitting the target if it's standing up
					target_mob.attack_alien(src)
					lastattack = world.time
					stance = HOSTILE_STANCE_ATTACKING
				else
					return
		else //Target exists but is some distance away
			HitNearbyObstacles()
			stance = HOSTILE_STANCE_ATTACK
	return

/mob/living/carbon/Xenomorph/AI/proc/HitNearbyObstacles()
	if(world.time < lastattack + 10 + attack_delay) //Attacking way too soon again
		return
	for(var/obj/obstacle in range(1, src))
		if(istype(obstacle, /obj/machinery/door/window) || istype(obstacle, /obj/structure/window) || istype(obstacle, /obj/structure/closet) || istype(obstacle, /obj/structure/table) || istype(obstacle, /obj/structure/grille) || istype(obstacle, /obj/structure/barricade) || istype(obstacle, /obj/structure/razorwire) || istype(obstacle, /obj/machinery/marine_turret))
			obstacle.attack_alien(src)
			lastattack = world.time
			break
	return

/mob/living/carbon/Xenomorph/AI/proc/OpenDoor()
	for(var/obj/machinery/door/airlock/door in view(1, src))
		if(door && door.density && !door.welded && !door.locked) //Ripping up time
			door.open(1)

/mob/living/carbon/Xenomorph/AI/handle_aura_receiver()
	return

/mob/living/carbon/Xenomorph/AI/handle_aura_emiter()
	return

/mob/living/carbon/Xenomorph/AI/proc/ConsiderMovement() //Move a tile somehow
	if(!src)
		return //Better exist
	if(resting && !(client || ckey)) //RISE MY SISTERS
		resting = 0
	if(client || ckey) //A player exists; don't do automated movement
		for(var/datum/action/path in actions)
			if(istype(path, /datum/action/xeno_action/followleader))
				path.remove_action(src)
		var/datum/action/xeno_action/followleader/leader = new/datum/action/xeno_action/followleader
		leader.give_action(src)
		addtimer(CALLBACK(src, .proc/ConsiderMovement), 100)
		return
	if(stat || !canmove)
		addtimer(CALLBACK(src, .proc/ConsiderMovement), 1) //Try again shortly
		return
	considerabilityhash += 1
	if(queuedmovement)
		CustomMove(src, get_step(src, queuedmovement), queuedmovement)
		queuedmovement = 0
		addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
		return
	switch(stance)
		if(HOSTILE_STANCE_IDLE) //Time for random movement
			HitNearbyObstacles()
			if(considerabilityhash >= 8)
				considerabilityhash = 0
				OpenDoor()
				ConsiderAbilities()
			if(!LeaderToFollow) //No leader to follow; do random stuff
				var/turf/randomturf = get_step_rand(src) //Random movement
				CustomMove(src, randomturf, get_dir(src, randomturf))
				addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
				return
			//We got a leader to follow; follow the leader
			if(LeaderToFollow.stat != DEAD && get_dist(src, LeaderToFollow) < 14)
				var/turf/turftoleader = get_step_to(src, LeaderToFollow, rand(1, 3)) //Keep some distance
				CustomMove(src, turftoleader, get_dir(src, turftoleader))
				addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
				return
			else
				LeaderToFollow = null //Dammit it died or too far away from us

		if(HOSTILE_STANCE_ATTACK) //It has a target, start moving to it
			if(!target_mob || get_dist(src, target_mob) > 14)
				RemoveTarget()
			ConsiderAttack()
			if(considerabilityhash >= 4)
				considerabilityhash = 0
				OpenDoor()
				ConsiderAbilities()
			if(get_dist(src, target_mob) > rangetomaintain)
				if(prob(75)) //Small chance to actually move towards the target_mob, otherwise go left or right
					CustomMove(src, get_step_to(src, target_mob), get_dir(src, get_step_to(src, target_mob)))
					addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
					return
				else //Side step dodging on way to target
					var/list/leftrightdir = LeftAndRightOfDir(dir)
					if(!(CustomMove(src, get_step(src, leftrightdir[1]), leftrightdir[1]))) //Damm the left side is blocked
						if(!CustomMove(src, get_step(src, leftrightdir[2]), leftrightdir[2])) //Try to right side anyway; chances are the right side could be blocked but don't care much about that
							addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
							return
					addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
					return
			else
				if(get_dist(src, target_mob) == rangetomaintain) //We now just side step because we're on the edge
					var/list/leftrightdir = LeftAndRightOfDir(dir)
					if(!(CustomMove(src, get_step(src, leftrightdir[1]), leftrightdir[1]))) //Damm the left side is blocked
						if(!CustomMove(src, get_step(src, leftrightdir[2]), leftrightdir[2])) //Try to right side anyway; chances are the right side could be blocked but don't care much about that
							addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
							return
					addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
					return
				else
					CustomMove(src, get_step_away(src, target_mob, rangetomaintain), get_dir(src, get_step_away(src, target_mob, rangetomaintain)))
					addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
					return

		if(HOSTILE_STANCE_ATTACKING) //It's right next to the target, slap it and stutter around it
			if(!target_mob || get_dist(src, target_mob) > 14)
				RemoveTarget()
			var/failedcounter = 0 //How many directions would fail if the xeno moves and the target would be out of melee range: make stance back to ATTACK so it can chase
			if(considerabilityhash >= 4)
				considerabilityhash = 0
				OpenDoor()
				ConsiderAbilities()
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
			ConsiderAttack()
			addtimer(CALLBACK(src, .proc/ConsiderMovement), movement_delay() + 3)
			return

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
	rangetomaintain = 12 //If it does aggro stay really far away
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/xenohide,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl
		)

/mob/living/carbon/Xenomorph/AI/Larva/update_progression()
	amount_grown += 1
	if(locate(/obj/effect/alien/weeds) in loc)
		amount_grown += 1
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
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Drone Walking"
	health = 120
	maxHealth = 120
	plasma_stored = 350
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	speed = -0.8
	pixel_x = -12
	old_x = -12
	pull_speed = -2

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
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Drone/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Drone/ancient
	upgrade = XENO_UPGRADE_THREE

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
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Runner/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Runner/ancient
	upgrade = XENO_UPGRADE_THREE

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
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Queen/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Queen/ancient
	upgrade = XENO_UPGRADE_THREE

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

/mob/living/carbon/Xenomorph/AI/Queen/ovi/ConsiderMovement()
	ConsiderAbilities()
	addtimer(CALLBACK(src, .proc/ConsiderMovement), larvacooldown)

/mob/living/carbon/Xenomorph/AI/Queen/ovi/ConsiderAbilities(isattacking)
	egg_amount = 0
	if(lastlarva < world.time)
		new /mob/living/carbon/Xenomorph/AI/Larva(get_turf(src))
		lastlarva = world.time + larvacooldown

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H && !H.stat)
			queen_screech() // ; halp there's tallhosts here
			for(var/mob/living/carbon/Xenomorph/AI/X in range(14)) //Here comes the horde
				if(!X.stat)
					X.SetTarget(H)
			break

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

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H && !H.stat)
			queen_screech() // ; halp there's tallhosts here
			for(var/mob/living/carbon/Xenomorph/AI/X in range(14)) //Here comes the horde
				if(!X.stat)
					X.SetTarget(H)
			break


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
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Crusher/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Crusher/ancient
	upgrade = XENO_UPGRADE_THREE

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
		/datum/action/xeno_action/activable/second_wind,
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
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Ravager/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Ravager/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/AI/Hunter
	caste_base_type = /mob/living/carbon/Xenomorph/Hunter
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
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
	if(get_dist(src, target_mob) <= 4 && !usedPounce && !target_mob.lying) //Pounce the target if in range; blind pounce as well, don't care about barricades.
		Pounce(target_mob)

/mob/living/carbon/Xenomorph/AI/Hunter/bullet_act(obj/item/projectile/P) //If it breaks our stealth stop the idle
	..()
	if(P.damage > 10)
		trueidle = 0 //Chances are we were stealth, stop the idle so we can fight manly
		doingaction = 0

/mob/living/carbon/Xenomorph/AI/Hunter/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Hunter/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Hunter/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/AI/Spitter
	caste_base_type = /mob/living/carbon/Xenomorph/Spitter
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/48x48_Xenos.dmi'
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
	rangetomaintain = 5

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
	if((has_spat < world.time) && target_mob && get_dist(src, target_mob) < 8)
		xeno_spit(target_mob)

/mob/living/carbon/Xenomorph/AI/Spitter/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Spitter/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Spitter/ancient
	upgrade = XENO_UPGRADE_THREE

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
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Defender/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Defender/ancient
	upgrade = XENO_UPGRADE_THREE

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
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Warrior/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Warrior/ancient
	upgrade = XENO_UPGRADE_THREE

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
	rangetomaintain = 5
	var/sticky_cooldown = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid,
		/datum/action/xeno_action/toggle_pheromones
		)

/mob/living/carbon/Xenomorph/AI/Praetorian/New()
	..()
	current_aura = pick("frenzy", "warding", "recovery")
	ammo = /datum/ammo/xeno/acid/heavy

/mob/living/carbon/Xenomorph/AI/Praetorian/ConsiderAbilities(isattacking)
	if(has_spat < world.time && target_mob)
		xeno_spit(target_mob)

/mob/living/carbon/Xenomorph/AI/Praetorian/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Praetorian/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Praetorian/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/AI/Sentinel
	caste_base_type = /mob/living/carbon/Xenomorph/Sentinel
	name = "Sentinel"
	desc = "A slithery, spitting kind of alien."
	icon = 'icons/Xeno/48x48_Xenos.dmi'
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
	rangetomaintain = 5
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
		/datum/action/xeno_action/build_tunnel,
		/datum/action/xeno_action/toggle_speed,
		/datum/action/xeno_action/toggle_pheromones
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
	for(var/obj/effect/alien/weeds/node/node in range(1))
		if(node)
			hasweeds = 1
	if(!hasweeds)
		new /obj/effect/alien/weeds/node(src.loc)
		playsound(loc, "alien_resin_build", 25)

/mob/living/carbon/Xenomorph/AI/Hivelord/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/AI/Hivelord/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/AI/Hivelord/ancient
	upgrade = XENO_UPGRADE_THREE
