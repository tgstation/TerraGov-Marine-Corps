
/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss


/mob/living
	New()
		..()
		attack_icon = image("icon" = 'icons/effects/attacks.dmi',"icon_state" = "", "layer" = 0)

	Dispose()
		. = ..()
		cdel(attack_icon)
		attack_icon = null

//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if(mShock in src.mutations) //shockproof
			return 0
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.limbs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/datum/limb/affecting in H.limbs)
			if(!affecting)	continue
			if(affecting.take_damage(0, divided_damage+extradam))	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
				H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey))
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature



/mob/proc/get_contents()


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += src.contents
		for(var/obj/item/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)

		for(var/obj/item/gift/G in src.contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in src.contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/get_limbzone_target()
	return ran_zone(zone_selected)



/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			usr << "[src]'s Metainfo:<br>[client.prefs.metadata]"
		else
			usr << "[src] does not have any stored infomation!"
	else
		usr << "OOC Metadata is not supported by this server!"

	return


/mob/living/Move(NewLoc, direct)
	if (buckled && buckled.loc != NewLoc) //not updating position
		if (!buckled.anchored)
			return buckled.Move(NewLoc, direct)
		else
			return 0

	var/atom/movable/pullee = pulling
	if(pullee && get_dist(src, pullee) > 1)
		stop_pulling()
	var/turf/T = loc
	. = ..()
	if(. && pulling && pulling == pullee) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
			return

		var/pull_dir = get_dir(src, pulling)
		if(get_dist(src, pulling) > 1 || ((pull_dir - 1) & pull_dir)) //puller and pullee more than one tile away or in diagonal position
			pulling.Move(T, get_dir(pulling, T)) //the pullee tries to reach our previous position
			if(pulling && get_dist(src, pulling) > 1) //the pullee couldn't keep up
				stop_pulling()

	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1)//separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()


	if (s_active && !( s_active in contents ) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)





/mob/proc/resist_grab(moving_resist)
	return //returning 1 means we successfully broke free

/mob/living/resist_grab(moving_resist)
	if(pulledby.grab_level)
		if(prob(30/pulledby.grab_level))
			visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>")
			pulledby.stop_pulling()
			return 1
		if(moving_resist && client) //we resisted by trying to move
			client.move_delay = world.time + 20
	else
		pulledby.stop_pulling()
		return 1


/mob/living/movement_delay()
	. = 0
	if(istype(loc, /turf/space))
		return -1 //It's hard to be slowed down in space by... anything

	if(pulling && pulling.drag_delay && !ignore_pull_delay())	//Dragging stuff can slow you down a bit.
		var/pull_delay = pulling.drag_delay
		if(ismob(pulling))
			var/mob/M = pulling
			if(M.buckled) //if the pulled mob is buckled to an object, we use that object's drag_delay.
				pull_delay = M.buckled.drag_delay
		. += pull_delay + 3*grab_level //harder grab makes you slower

	if(next_move_slowdown)
		. += next_move_slowdown
		next_move_slowdown = 0

//whether we are slowed when dragging things
/mob/living/proc/ignore_pull_delay()
	return FALSE

/mob/living/carbon/human/ignore_pull_delay()
	return has_species(src,"Yautja") //Predators aren't slowed when pulling their prey.

/mob/living/forceMove(atom/destination)
	stop_pulling()
	if(buckled)
		buckled.unbuckle()
	. = ..()
	if(.)
		reset_view(destination)


/mob/living/Bump(atom/movable/AM, yes)
	if(buckled || !yes || now_pushing)
		return
	now_pushing = 1
	if(isliving(AM))
		var/mob/living/L = AM

		//Leaping mobs just land on the tile, no pushing, no anything.
		if(status_flags & LEAPING)
			loc = L.loc
			status_flags &= ~LEAPING
			now_pushing = 0
			return

		if(isXeno(L) && !isXenoLarva(L)) // Prevents humans from pushing any Xenos, but big Xenos and Preds can still push small Xenos
			var/mob/living/carbon/Xenomorph/X = L
			if(has_species(src,"Human") || X.mob_size == MOB_SIZE_BIG)
				now_pushing = 0
				return

		if(L.pulledby && L.pulledby != src && L.is_mob_restrained())
			if(!(world.time % 5))
				src << "\red [L] is restrained, you cannot push past"
			now_pushing = 0
			return

 		if(L.pulling)
 			if(ismob(L.pulling))
 				var/mob/P = L.pulling
 				if(P.is_mob_restrained())
 					if(!(world.time % 5))
 						src << "<span class='warning'>[L] is restraining [P], you cannot push past.</span>"
					now_pushing = 0
					return

		if(ishuman(L))

			if(HULK in L.mutations)
				if(prob(70))
					usr << "\red <B>You fail to push [L]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
			if(!(L.status_flags & CANPUSH))
				now_pushing = 0
				return

		if(moving_diagonally)//no mob swap during diagonal moves.
			now_pushing = 0
			return

		if(!L.buckled && !L.anchored)
			var/mob_swap
			//the puller can always swap with its victim if on grab intent
			if(L.pulledby == src && a_intent == "grab")
				mob_swap = 1
			//restrained people act if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
			else if((L.is_mob_restrained() || L.a_intent == "help") && (is_mob_restrained() || a_intent == "help"))
				mob_swap = 1
			if(mob_swap)
				//switch our position with L
				if(loc && !loc.Adjacent(L.loc))
					now_pushing = 0
					return
				var/oldloc = loc
				var/oldLloc = L.loc


				var/L_passmob = (L.flags_pass & PASSMOB) // we give PASSMOB to both mobs to avoid bumping other mobs during swap.
				var/src_passmob = (flags_pass & PASSMOB)
				L.flags_pass |= PASSMOB
				flags_pass |= PASSMOB

				L.Move(oldloc)
				Move(oldLloc)

				if(!src_passmob)
					flags_pass &= ~PASSMOB
				if(!L_passmob)
					L.flags_pass &= ~PASSMOB

				now_pushing = 0
				return

		if(!(L.status_flags & CANPUSH))
			now_pushing = 0
			return

	now_pushing = 0
	..()
	if (!( istype(AM, /atom/movable) ))
		return
	if (!( now_pushing ))
		now_pushing = 1
		if (!( AM.anchored ))
			var/t = get_dir(src, AM)
			if (istype(AM, /obj/structure/window))
				var/obj/structure/window/W = AM
				if(W.is_full_window())
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
			step(AM, t)
		now_pushing = 0



/mob/living/throw_at(atom/target, range, speed, thrower)
	if(!target || !src)	return 0
	if(pulling) stop_pulling() //being thrown breaks pulls.
	if(pulledby) pulledby.stop_pulling()
	. = ..()
//to make an attack sprite appear on top of the target atom.
/mob/living/proc/flick_attack_overlay(atom/target, attack_icon_state)
	set waitfor = 0

	attack_icon.icon_state = attack_icon_state
	target.overlays += attack_icon
	var/old_icon = attack_icon.icon_state
	sleep(4)
	if(target)
		var/new_icon = attack_icon.icon_state
		attack_icon.icon_state = old_icon //necessary b/c the attack_icon can change sprite during the sleep.
		target.overlays -= attack_icon
		attack_icon.icon_state = new_icon

