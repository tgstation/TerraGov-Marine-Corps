#define MAX_RANGE_FIND 32

/mob/living/carbon/human
	var/aggressive=0 //0= retaliate only
	var/frustration=0
	var/pickupTimer=0
	var/list/enemies = list()
	var/list/friends = list()
	var/mob/living/target
	var/obj/item/pickupTarget
	var/mode = AI_OFF
	var/list/myPath = list()
	var/list/blacklistItems = list()
	var/maxStepsTick = 6
	var/resisting = FALSE
	var/pickpocketing = FALSE
	var/del_on_deaggro = null
	var/last_aggro_loss = null
	var/wander = TRUE
	var/ai_when_client = FALSE
	var/next_idle = 0
	var/next_seek = 0
	var/flee_in_pain = FALSE
	var/stand_attempts = 0

	var/static_npc = TRUE
	var/returning_home = FALSE

/mob/living/carbon/human/proc/IsStandingStill()
	return resisting || pickpocketing

/mob/living/carbon/human/proc/handle_ai()
	if(client)
		if(!ai_when_client)
			return
	START_PROCESSING(SShumannpc,src)

/mob/living/carbon/human/proc/process_ai()
	if(stat == DEAD)
		walk_to(src,0)
		return TRUE
	if(client)
		if(!ai_when_client)
			return TRUE //remove us from processing
//	if(world.time < next_ai_tick)
//		return
//	next_ai_tick = world.time + rand(10,20)
	cmode = 1
	update_cone_show()
	if(stat == CONSCIOUS)
		if(on_fire || buckled || restrained() || pulledby)
			resisting = TRUE
			walk_to(src,0)
			resist()
			resisting = FALSE
		if(!(mobility_flags & MOBILITY_STAND) && (stand_attempts < 3))
			resisting = TRUE
			npc_stand()
			resisting = FALSE
		else
			stand_attempts = 0
			if(!handle_combat())
				if(mode == AI_IDLE && !pickupTarget)
					npc_idle()
					if(del_on_deaggro && last_aggro_loss && (world.time >= last_aggro_loss + del_on_deaggro))
						if(deaggrodel())
							return TRUE
	else
		walk_to(src,0)
		return TRUE

/mob/living/carbon/human/proc/npc_stand()
	if(stand_up())
		stand_attempts = 0
	else
		stand_attempts += rand(1,3)

/mob/living/carbon/human/proc/npc_idle()
	if(m_intent == MOVE_INTENT_SNEAK)
		return
	if(world.time < next_idle + rand(30,50))
		return
	next_idle = world.time + rand(30,50)
	if((mobility_flags & MOBILITY_MOVE) && isturf(loc))
		if(wander)
			if(prob(50))
				var/turf/T = get_step(loc,pick(GLOB.cardinals))
				if(!istype(T, /turf/open/transparent/openspace))
					Move(T)
			else
				setDir(turn(dir, pick(90,-90)))
		else
			setDir(turn(dir, pick(90,-90)))
	if(prob(3))
		emote("idle")

/mob/living/carbon/human/proc/deaggrodel()
	if(aggressive)
		var/list/around = hearers(7, src)  // scan for enemies
		for(var/mob/living/L in around)
			if( should_target(L) && (L != src))
				if(L.stat != DEAD)
					retaliate(L)
					return FALSE
	if(!target)
//		var/escape_path
//		for(var/obj/structure/flora/RT in view(6, src))
//			if(istype(RT,/obj/structure/flora/roguetree/stump))
//				continue
//			if(istype(RT,/obj/structure/flora/roguetree))
//				escape_path = RT
//				break
//			if(istype(RT,/obj/structure/flora/rogueshroom))
//				escape_path = RT
//				break
	//	if(escape_path)
		qdel(src)
		return TRUE

// blocks
// taken from /mob/living/carbon/human/interactive/
/mob/living/carbon/human/proc/walk2derpless(target)
	if(!target || IsStandingStill())
		back_to_idle()
		return 0

	var/dir_to_target = get_dir(src, target)
	var/turf/turf_of_target = get_turf(target)
	if(!turf_of_target)
		back_to_idle()
		return 0
	var/target_z = turf_of_target.z
	if(turf_of_target?.z == z)
		if(myPath.len <= 0)
			for(var/obj/structure/O in get_step(src,dir_to_target))
				if(O.density && O.climbable)
					O.climb_structure(src)
					myPath = list()
					break
			myPath = get_path_to(src, turf_of_target, /turf/proc/Distance, MAX_RANGE_FIND + 1, 250,1)

		if(myPath)
			if(myPath.len > 0)
				for(var/i = 0; i < maxStepsTick; ++i)
					if(!IsDeadOrIncap())
						if(myPath.len >= 1)
							walk_to(src,myPath[1],0,update_movespeed())
							myPath -= myPath[1]
				return 1
	else
		if(turf_of_target?.z < z)
			turf_of_target = get_step_multiz(turf_of_target, DOWN)
		else
			turf_of_target = get_step_multiz(turf_of_target, UP)
		if(turf_of_target?.z != target_z) //too far away
			back_to_idle()
			return 0
	// failed to path correctly so just try to head straight for a bit
	walk_to(src,turf_of_target,0,update_movespeed())
	sleep(1)
	walk_to(src,0)

	return 0

// taken from /mob/living/carbon/human/interactive/
/mob/living/carbon/human/proc/IsDeadOrIncap(checkDead = TRUE)
	if(!(mobility_flags & MOBILITY_FLAGS_INTERACTION))
		return 1
	if(health <= 0 && checkDead)
		return 1
	if(IsUnconscious())
		return 1
	if(IsStun() || IsParalyzed())
		return 1
	if(stat)
		return 1
	return 0


/mob/living/carbon/human/proc/equip_item(obj/item/I)
	if(I.loc == src)
		return TRUE

	if(I.anchored)
		blacklistItems[I] ++
		return FALSE

	// WEAPONS
	if(istype(I, /obj/item))
		if(put_in_hands(I))
			return TRUE

//	// CLOTHING
//	else if(istype(I, /obj/item/clothing))
//		var/obj/item/clothing/C = I
//		monkeyDrop(C)
//		addtimer(CALLBACK(src, .proc/pickup_and_wear, C), 5)
//		return TRUE

	// EVERYTHING ELSE
//	else
//		if(!get_item_for_held_index(1) || !get_item_for_held_index(2))
//			put_in_hands(I)
//			return TRUE

	blacklistItems[I] ++
	return FALSE

/mob/living/carbon/human/proc/pickup_and_wear(var/obj/item/clothing/C)
	if(!equip_to_appropriate_slot(C))
		monkeyDrop(get_item_by_slot(C)) // remove the existing item if worn
		addtimer(CALLBACK(src, .proc/equip_to_appropriate_slot, C), 5)

/mob/living/carbon/human/proc/monkeyDrop(var/obj/item/A)
	if(A)
		dropItemToGround(A, TRUE)

/mob/living/carbon/human/resist_restraints()
	var/obj/item/I = null
	if(handcuffed)
		I = handcuffed
	else if(legcuffed)
		I = legcuffed
	if(I)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		cuff_resist(I)

/mob/living/carbon/human/proc/should_target(var/mob/living/L)
	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		return FALSE

	if(L == src)
		return FALSE

	if(!is_in_zweb(src.z,L.z))
		return FALSE

	if(L.stat == DEAD)
		return FALSE

	if(L.InFullCritical())
		return FALSE

	if(L.name in friends)
		return FALSE

	if(enemies[L])
		return TRUE

	if(aggressive && !faction_check_mob(L))
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/handle_combat()
	switch(mode)
		if(AI_IDLE)		// idle
			if(world.time >= next_seek)
				next_seek = world.time + 3 SECONDS
				var/list/around = hearers(7, src) // scan for enemies
				for(var/mob/living/L in around)
					if(should_target(L))
						retaliate(L)

		if(AI_HUNT)		// hunting for attacker
			if(target != null)
				if(!should_target(target))
					back_to_idle()
					return TRUE
				m_intent = MOVE_INTENT_WALK
				INVOKE_ASYNC(src, .proc/walk2derpless, target)

			if(!get_active_held_item() && !get_inactive_held_item())
				// pickup any nearby weapon
				for(var/obj/item/I in view(1,src))
					if(!isturf(I.loc))
						continue
					if(I in blacklistItems)
						continue
					if(I && I.force > 7)
						equip_item(I)

//			// switch targets
//			if(prob(15))
//				for(var/mob/living/L in around)
//					if((L != target) && should_target(L) && (L.stat == CONSCIOUS))
//						retaliate(L)
//						return TRUE

			// if can't reach target for long enough, go idle
			if(frustration >= 15)
				back_to_idle()
				return TRUE

			if(Adjacent(target) && isturf(target.loc))	// if right next to perp
				frustration = 0
				face_atom(target)
				monkey_attack(target)
				if(flee_in_pain && (target.stat == CONSCIOUS))
					var/paine = get_complex_pain()
					if(paine >= ((STAEND * 10)*0.9))
//						mode = AI_FLEE
						walk_away(src, target, 5, update_movespeed())
				return TRUE
			else								// not next to perp
				frustration++

		if(AI_FLEE)
			back_to_idle()
			return TRUE
/*		if(AI_FLEE)
			var/list/around = view(src, 7)
			// flee from anyone who attacked us and we didn't beat down
			for(var/mob/living/L in around)
				if( enemies[L] && (L.stat != DEAD) )
					target = L
					break

			if(target != null)
				frustration++
				if(Adjacent(target))
					retalitate(target)
					return TRUE
				walk_away(src, target, 5, update_movespeed())
			else
				back_to_idle()

			return TRUE*/

	return IsStandingStill()


/mob/living/carbon/human/proc/back_to_idle()
	last_aggro_loss = world.time
	if(pulling)
		stop_pulling()
	myPath = list()
	mode = AI_IDLE
	target = null
	a_intent = INTENT_HELP
	frustration = 0
	walk_to(src,0)

// attack using a held weapon otherwise bite the enemy, then if we are angry there is a chance we might calm down a little
/mob/living/carbon/human/proc/monkey_attack(mob/living/L)
	if(next_move > world.time)
		return
	var/obj/item/Weapon = get_active_held_item()
	var/obj/item/OffWeapon = get_inactive_held_item()
	if(Weapon && OffWeapon)
		if(OffWeapon.force > Weapon.force)
			swap_hand()
			Weapon = get_active_held_item()
			OffWeapon = get_inactive_held_item()
	if(!Weapon)
		swap_hand()
		Weapon = get_active_held_item()
		OffWeapon = get_inactive_held_item()
	if(!(mobility_flags & MOBILITY_STAND))
		aimheight_change(rand(10,19))
	else
		aimheight_change(rand(10,19))

	// attack with weapon if we have one
	if(Weapon)
		if(!Weapon.wielded)
			if(Weapon.force_wielded > Weapon.force)
				if(!OffWeapon)
					Weapon.attack_self(src)
		rog_intent_change(1)
		used_intent = a_intent
		Weapon.melee_attack_chain(src, L)
	else
		rog_intent_change(4)
		used_intent = a_intent
		UnarmedAttack(L,1)

	var/adf = used_intent.clickcd
	if(istype(rmb_intent, /datum/rmb_intent/aimed))
		adf = round(adf * 1.4)
	if(istype(rmb_intent, /datum/rmb_intent/swift))
		adf = round(adf * 0.6)
	changeNext_move(adf)

	// no de-aggro
	if(aggressive)
		return

//	// if we arn't enemies, we were likely recruited to attack this target, jobs done if we calm down so go back to idle
//	if(!enemies[L])
//		if( target == L )
//			back_to_idle()
//		return // already de-aggroed
//
	// if we are not angry at our target, go back to idle
//	if(L in enemies)
//		enemies.Remove(L)
//		if( target == L )
//			back_to_idle()

// get angry at a mob
/mob/living/carbon/human/proc/retaliate(mob/living/L)
	if(!wander)
		wander = TRUE
	if(L == src)
		return
	if(mode != AI_OFF)
		mode = AI_HUNT
		last_aggro_loss = null
		face_atom(L)
		if(!target)
			emote("aggro")
		target = L
		enemies |= L


/mob/living/carbon/human/attackby(obj/item/W, mob/user, params)
	. = ..()
	if((W.force) && (!target) && (W.damtype != STAMINA) )
		retaliate(user)


#undef MAX_RANGE_FIND
