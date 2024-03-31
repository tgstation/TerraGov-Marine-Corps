

/proc/accuracy_check(zone, mob/living/user, mob/living/target, associated_skill, datum/intent/used_intent, obj/item/I)
	if(!zone)
		return
	if(user == target)
		return zone
	if(zone == "chest")
		return zone
	if(target.grabbedby == user)
		if(user.grab_state >= GRAB_AGGRESSIVE)
			return zone
	if(target.lying)
		return zone
	if( (target.dir == turn(get_dir(target,user), 180)))
		return zone

	var/chance2hit = 0

	if(check_zone(zone) == zone)
		chance2hit += 10

	if(user.mind)
		chance2hit += (user.mind.get_skill_level(associated_skill) * 5)

	if(used_intent)
		if(used_intent.blade_class == BCLASS_STAB)
			chance2hit += 20
		if(used_intent.blade_class == BCLASS_CUT)
			chance2hit += 12

	if(I)
		if(I.wlength == WLENGTH_SHORT)
			chance2hit += 10

	if(user.STAPER > 10)
		chance2hit += ((20-user.STAPER)*3)

	if(user.STAPER < 10)
		chance2hit -= ((10-user.STAPER)*3)

	if(istype(user.rmb_intent, /datum/rmb_intent/aimed))
		chance2hit += 20
	if(istype(user.rmb_intent, /datum/rmb_intent/swift))
		chance2hit -= 20

	chance2hit = CLAMP(chance2hit, 5, 99)

	if(prob(chance2hit))
		return zone
	else
		if(prob(chance2hit+5))
			if(check_zone(zone) == zone)
				return zone
			else
				if(user.client?.prefs.showrolls)
					to_chat(user, "<span class='warning'>Accuracy fail! [chance2hit]%</span>")
				return check_zone(zone)
		else
			if(user.client?.prefs.showrolls)
				to_chat(user, "<span class='warning'>Ultra accuracy fail! [chance2hit]%</span>")
			return "chest"



/mob/proc/get_generic_parry_drain()
	return 30

/mob/living/proc/checkmiss(mob/living/user)
	if(user == src)
		return FALSE
	if(stat)
		return FALSE
	if(lying)
		return FALSE
	if(user.badluck(4))
		var/list/usedp = list("Critical miss!", "Damn! Critical miss!", "No! Critical miss!", "It can't be! Critical miss!", "Betrayed by lady luck! Critical miss!", "Bad luck! Critical miss!", "Curse creation! Critical miss!", "What?! Critical miss!")
		to_chat(user, "<span class='boldwarning'>[pick(usedp)]</span>")
		flash_fullscreen("blackflash2")
		user.aftermiss()
		return TRUE


/mob/living/proc/checkdefense(var/datum/intent/intenty, mob/living/user)
	testing("begin defense")
	if(!cmode)
		return FALSE
	if(stat)
		return FALSE
	if(!canparry && !candodge) //mob can do neither of these
		return FALSE
	if(!cmode)
		return FALSE
	if(user == src)
		return FALSE
	if(!(mobility_flags & MOBILITY_MOVE))
		return

	if(client && used_intent)
		if(client.charging && used_intent.tranged && !used_intent.tshield)
			return FALSE

	var/prob2defend = user.defprob
	var/mob/living/carbon/human/H
	var/mob/living/carbon/human/U
	if(ishuman(src))
		H = src
	if(ishuman(user))
		U = user

	if(H && U)
		prob2defend = 0

	if(!can_see_cone(user))
		if(d_intent == INTENT_PARRY)
			return FALSE
		else
			prob2defend = max(prob2defend-15,0)

//	if(!cmode) // not currently used, see cmode check above
//		prob2defend = max(prob2defend-15,0)

	if(m_intent == MOVE_INTENT_RUN)
		prob2defend = max(prob2defend-15,0)

	switch(d_intent)
		if(INTENT_PARRY)
			if(HAS_TRAIT(src, TRAIT_CHUNKYFINGERS))
				return FALSE
			if(pulledby == user && pulledby.grab_state >= GRAB_AGGRESSIVE)
				return FALSE
			if(pulling == user && grab_state >= GRAB_AGGRESSIVE)
				return FALSE
			if(world.time < last_parry + setparrytime)
				if(!istype(rmb_intent, /datum/rmb_intent/riposte))
					return FALSE
			if(has_status_effect(/datum/status_effect/debuff/feinted))
				return FALSE
			if(has_status_effect(/datum/status_effect/debuff/riposted))
				return FALSE
			last_parry = world.time
			if(intenty)
				if(!intenty.canparry)
					return FALSE
			var/drained = user.defdrain
			var/obj/item/mainhand = get_active_held_item()
			var/obj/item/offhand = get_inactive_held_item()
			var/used_index = active_hand_index
			var/weapon_parry = FALSE
			if(mainhand)
				if(mainhand.can_parry)
					weapon_parry = TRUE
			else
				if(offhand)
					if(offhand.can_parry)
						weapon_parry = TRUE
						used_index = get_inactive_hand_index()
			if(weapon_parry)
				var/obj/item/used_weapon = mainhand
				if(!mainhand)
					used_weapon = offhand
					used_index = get_inactive_hand_index()
				if(H)
					var/mainhandthing = 0
					if(mainhand && mainhand.can_parry)
						if(!mainhand.associated_skill)
							mainhandthing -= 10
						else
							mainhandthing += (H.mind.get_skill_level(mainhand.associated_skill) * 20)
						mainhandthing += (mainhand.wdefense * 10)
					var/offhandthing = 0
					if(offhand && offhand.can_parry)
						if(!offhand.associated_skill)
							offhandthing -= 10
						else
							offhandthing += (H.mind.get_skill_level(offhand.associated_skill) * 20)
						offhandthing += (offhand.wdefense * 10)
					if((mainhandthing >= offhandthing) && mainhand && mainhand.can_parry)
						used_weapon = mainhand
						used_index = active_hand_index
						prob2defend += mainhandthing
					else if(offhand && offhand.can_parry)
						used_weapon = offhand
						used_index = get_inactive_hand_index()
						prob2defend += offhandthing
				if(U && U.mind)
					if(intenty.masteritem)
						if(!intenty.masteritem.associated_skill) //nme weapon improvised
							prob2defend = prob2defend + 10
						else
							prob2defend = prob2defend - (U.mind.get_skill_level(intenty.masteritem.associated_skill) * 20)
							var/amt2raise = max(round(U.STAINT/2), 0)
							U.mind.adjust_experience(intenty.masteritem.associated_skill, amt2raise, FALSE)
						if((intenty.masteritem.wbalance > 0) && (user.STASPD > src.STASPD)) //nme weapon is quick, so get a bonus based on spddiff
							prob2defend = prob2defend - ( intenty.masteritem.wbalance * ((user.STASPD - src.STASPD) * 10) )
					else
						prob2defend = prob2defend - (U.mind.get_skill_level(/datum/skill/combat/unarmed) * 5)
				prob2defend = clamp(prob2defend, 5, 99)
				if(src.client?.prefs.showrolls)
					to_chat(src, "<span class='info'>Roll to parry with [used_weapon]... [prob2defend]%</span>")
				if(used_index == 1)
					used_hand = 1
				else
					used_hand = 2
			//	changeNext_move(5,used_hand)
				if(prob(prob2defend))
					if(intenty.masteritem)
						if(intenty.masteritem.wbalance < 0 && user.STASTR > src.STASTR) //nme weapon is heavy, so get a bonus scaling on strdiff
							drained = drained + ( intenty.masteritem.wbalance * ((user.STASTR - src.STASTR) * -5) )
/*					else
						if(src.rogfat_add(5))
							src.visible_message("<span class='boldwarning'><b>[src]</b> ripostes [user] with [used_weapon]!</span>")
							if(user.active_hand_index == 1)//this is currently not working, i asusme because mellee attack chain resets tempatarget. find workaround for this
								src.tempatarget = "l_arm"
							else
								src.tempatarget = "r_arm"
							used_weapon.melee_attack_chain(src, user)
							return TRUE
						else
							to_chat(src, "<span class='warning'>I'm too tired to riposte.</span>")
							return FALSE*/
				else
					to_chat(src, "<span class='warning'>The enemy defeated my parry!</span>")
					return FALSE
				drained = max(drained, 5)
				if(do_parry(used_weapon, drained, user)) //show message, invoke parry cd
					if(istype(rmb_intent, /datum/rmb_intent/riposte))
						user.apply_status_effect(/datum/status_effect/debuff/riposted)
					if(used_weapon.associated_skill && mind)
						var/amt2raise = STAINT/2
						mind.adjust_experience(used_weapon.associated_skill, amt2raise, FALSE)
					var/obj/item/AB = intenty.masteritem
					if(AB && AB.associated_skill && user.mind)
						var/amt2raise = max(round(user.STAINT/2),0)
						user.mind.adjust_experience(AB.associated_skill, amt2raise, FALSE)
					if(prob(66) && AB)
						if((used_weapon.flags_1 & CONDUCT_1) && (AB.flags_1 & CONDUCT_1))
							flash_fullscreen("whiteflash")
							user.flash_fullscreen("whiteflash")
							var/datum/effect_system/spark_spread/S = new()
							var/turf/front = get_step(src,src.dir)
							S.set_up(1, 1, front)
							S.start()
						else
							flash_fullscreen("blackflash2")
					else
						flash_fullscreen("blackflash2")
					if(used_weapon && AB)
						var/dam2take = round((get_complex_damage(AB,user,used_weapon.blade_dulling)/2),1)
						if(dam2take)
							used_weapon.take_damage(max(dam2take,1), BRUTE, "melee")
					return TRUE
				else
					return FALSE
			else
				testing("begin unarmed parry")
				if(!has_hand_for_held_index(active_hand_index))
					testing("noarm unarmed parry")
					return FALSE
				if(H)
					if(H.check_arm_grabbed())
						testing("grabbed unarmed parry")
						return FALSE
					if(H.mind)
						prob2defend = prob2defend + (H.mind.get_skill_level(/datum/skill/combat/unarmed) * 10)
				var/usename = intenty.name
				if(U && U.mind)
					if(intenty.masteritem)
						usename = intenty.masteritem.name
						if(!intenty.masteritem.associated_skill) //nme weapon improvised
							prob2defend = prob2defend + 10
						else
							prob2defend = prob2defend - (U.mind.get_skill_level(intenty.masteritem.associated_skill) * 10)
					else
						prob2defend = prob2defend - (U.mind.get_skill_level(/datum/skill/combat/unarmed) * 10)
						var/amt2raise = max(round(U.STAINT/2),0)
						U.mind.adjust_experience(/datum/skill/combat/unarmed, amt2raise, FALSE)

				prob2defend = clamp(prob2defend, 5, 99)
				if(client?.prefs.showrolls)
					to_chat(src, "<span class='info'>Roll to parry... [prob2defend]%</span>")
				if(prob(prob2defend))
					drained = max(drained, 5)
//							if(U.aimheight != H.aimheight)
//								drained = drained + 15
					if(do_unarmed_parry(usename, drained, user))
						if(H && H.mind)
							var/amt2raise = max(round(H.STAINT/2),0)
							H.mind.adjust_experience(/datum/skill/combat/unarmed, amt2raise, FALSE)
						flash_fullscreen("blackflash2")
						return TRUE
					else
						testing("failparry")
						return FALSE
				else
					to_chat(src, "<span class='boldwarning'>The enemy defeated my parry!</span>")
					return FALSE
		if(INTENT_DODGE)
			if(pulledby && pulledby.grab_state >= GRAB_AGGRESSIVE)
				return FALSE
			if(pulling == user)
				return FALSE
			if(world.time < last_dodge + dodgetime)
				if(!istype(rmb_intent, /datum/rmb_intent/riposte))
					return FALSE
			if(has_status_effect(/datum/status_effect/debuff/riposted))
				return FALSE
			last_dodge = world.time
			if(src.loc == user.loc)
				return FALSE
			if(intenty)
				if(!intenty.candodge)
					return FALSE
			if(candodge)
				var/list/dirry = list()
				var/dx = x - user.x
				var/dy = y - user.y
				if(abs(dx) < abs(dy))
					if(dy > 0)
						dirry += NORTH
						dirry += WEST
						dirry += EAST
					else
						dirry += SOUTH
						dirry += WEST
						dirry += EAST
				else
					if(dx > 0)
						dirry += EAST
						dirry += SOUTH
						dirry += NORTH
					else
						dirry += WEST
						dirry += NORTH
						dirry += SOUTH
				var/turf/turfy
				for(var/x in shuffle(dirry.Copy()))
					turfy = get_step(src,x)
					if(turfy)
						if(turfy.density)
							continue
						for(var/atom/movable/AM in turfy)
							if(AM.density)
								continue
						break
				if(pulledby)
					return FALSE
				if(!turfy)
					to_chat(src, "<span class='boldwarning'>There's nowhere to dodge to!</span>")
					return FALSE
				else
					if(do_dodge(user, turfy))
						flash_fullscreen("blackflash2")
						user.aftermiss()
						return TRUE
					else
						return FALSE
			else
				return FALSE

/mob/proc/do_parry(var/obj/item/W, parrydrain as num, mob/living/user)
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.rogfat_add(parrydrain))
			if(W)
				playsound(get_turf(src), pick(W.parrysound), 100, FALSE)
			if(istype(rmb_intent, /datum/rmb_intent/riposte))
				src.visible_message("<span class='boldwarning'><b>[src]</b> ripostes [user] with [W]!</span>")
			else
				src.visible_message("<span class='boldwarning'><b>[src]</b> parries [user] with [W]!</span>")
			return TRUE
		else
			to_chat(src, "<span class='warning'>I'm too tired to parry!</span>")
			return FALSE //crush through
	else
		if(W)
			playsound(get_turf(src), pick(W.parrysound), 100, FALSE)
		return TRUE

/mob/proc/do_unarmed_parry(intenty as text, parrydrain as num, mob/living/user)
	if(intenty == "help")
		return FALSE
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.rogfat_add(parrydrain))
			playsound(get_turf(src), pick(parry_sound), 100, FALSE)
			src.visible_message("<span class='warning'><b>[src]</b> parries [user]'s [intenty]!</span>")
			return TRUE
		else
			to_chat(src, "<span class='boldwarning'>I'm too tired to parry!</span>")
			return FALSE
	else
		playsound(get_turf(src), pick(parry_sound), 100, FALSE)
		return TRUE


/mob/proc/do_dodge(mob/user, var/turf/turfy)
	if(!dodgecd)
		var/mob/living/L = src
		var/mob/living/U = user
		var/mob/living/carbon/human/H
		var/mob/living/carbon/human/UH
		var/obj/item/I
		var/drained = 10
		if(ishuman(src))
			H = src
		if(ishuman(user))
			UH = user
			I = UH.used_intent.masteritem
		var/prob2defend = U.defprob
		if(L.rogfat >= L.maxrogfat)
			return FALSE
		if(L)
			prob2defend = prob2defend + (L.STASPD * 10)
		if(U)
			prob2defend = prob2defend - (U.STASPD * 10)
		if(I)
			if(I.wbalance > 0 && U.STASPD > L.STASPD) //nme weapon is quick, so they get a bonus based on spddiff
				prob2defend = prob2defend - ( I.wbalance * ((U.STASPD - L.STASPD) * 10) )
			if(I.wbalance < 0 && L.STASPD > U.STASPD) //nme weapon is slow, so its easier to dodge if we're faster
				prob2defend = prob2defend + ( I.wbalance * ((U.STASPD - L.STASPD) * -10) )
			if(UH?.mind)
				prob2defend = prob2defend - (UH.mind.get_skill_level(I.associated_skill) * 10)
		if(H)
			if(!H.check_armor_skill())
				H.Knockdown(1)
				return FALSE
//			if(H.mind)
//				drained = drained + max((H.checkwornweight() * 10)-(mind.get_skill_level(/datum/skill/misc/athletics) * 10),0)
//			else
//				drained = drained + (H.checkwornweight() * 10)
			if(I) //the enemy attacked us with a weapon
				if(!I.associated_skill) //the enemy weapon doesn't have a skill because its improvised, so penalty to attack
					prob2defend = prob2defend + 10
				else
					if(H.mind)
						prob2defend = prob2defend + (H.mind.get_skill_level(I.associated_skill) * 10)
//				var/thing = H.encumbrance
//				if(thing > 0)
//					drained = drained + (thing * 10)
			else //the enemy attacked us unarmed or is nonhuman
				if(UH)
					if(UH.used_intent.unarmed)
						if(UH.mind)
							prob2defend = prob2defend - (UH.mind.get_skill_level(/datum/skill/combat/unarmed) * 10)
						if(H.mind)
							prob2defend = prob2defend + (H.mind.get_skill_level(/datum/skill/combat/unarmed) * 10)
			prob2defend = clamp(prob2defend, 5, 99)
			if(client?.prefs.showrolls)
				to_chat(src, "<span class='info'>Roll to dodge... [prob2defend]%</span>")
			if(!prob(prob2defend))
				return FALSE
			if(!H.rogfat_add(max(drained,5)))
				to_chat(src, "<span class='warning'>I'm too tired to dodge!</span>")
				return FALSE
		else //we are a non human
			if(client?.prefs.showrolls)
				to_chat(src, "<span class='info'>Roll to dodge... [prob2defend]%</span>")
			prob2defend = clamp(prob2defend, 5, 99)
			if(!prob(prob2defend))
				return FALSE
		dodgecd = TRUE
		throw_at(turfy, 1, 2, src, FALSE)
		if(drained > 0)
			src.visible_message("<span class='warning'><b>[src]</b> dodges [user]'s attack!</span>")
		else
			src.visible_message("<span class='warning'><b>[src]</b> easily dodges [user]'s attack!</span>")
		dodgecd = null
//		if(H)
//			if(H.IsOffBalanced())
//				H.Knockdown(1)
//				to_chat(H, "<span class='danger'>I tried to dodge off-balance!</span>")
		playsound(src, 'sound/combat/dodge.ogg', 100, FALSE)
//		if(isturf(loc))
//			var/turf/T = loc
//			if(T.landsound)
//				playsound(T, T.landsound, 100, FALSE)
		return TRUE
	else
		return FALSE

/mob/proc/food_tempted(/obj/item/W, mob/user)
	return

/mob/proc/taunted(mob/user)
	return

/mob/proc/shood(mob/user)
	return

/mob/proc/beckoned(mob/user)
	return

/mob/proc/get_punch_dmg()
	return


/mob/proc/add_family_hud(antag_hud_type, antag_hud_name)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.join_hud(src)
	set_antag_hud(src, antag_hud_name)


/mob/proc/remove_family_hud(antag_hud_type)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.leave_hud(src)
	set_antag_hud(src, null)