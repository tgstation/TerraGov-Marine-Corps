/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/UnarmedAttack(atom/A, proximity, params)

	if(!has_active_hand()) //can't attack without a hand.
		to_chat(src, "<span class='warning'>I lack working hands.</span>")
		return

	if(!has_hand_for_held_index(used_hand)) //can't attack without a hand.
		to_chat(src, "<span class='warning'>I can't move this hand.</span>")
		return

	if(check_arm_grabbed(used_hand))
		to_chat(src, "<span class='warning'>Someone is grabbing my arm!</span>")
		return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A,1))
		return
	//This signal is needed to prevent gloves of the north star + hulk.
	if(SEND_SIGNAL(src, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, A, proximity) & COMPONENT_NO_ATTACK_HAND)
		return
	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A, proximity)
	if(isliving(A))
		var/mob/living/L = A
		if(!used_intent.noaa)
			playsound(get_turf(src), pick(GLOB.unarmed_swingmiss), 100, FALSE)
//			src.emote("attackgrunt")
		if(L.checkmiss(src))
			return
		if(!L.checkdefense(used_intent, src))
			L.attack_hand(src, params)
		return
	else
		var/item_skip = FALSE
		if(isitem(A))
			var/obj/item/I = A
			if(I.w_class < WEIGHT_CLASS_GIGANTIC)
				item_skip = TRUE
		if(!item_skip)
			if(used_intent.type == INTENT_GRAB)
				var/obj/AM = A
				if(istype(AM) && !AM.anchored)
					start_pulling(A) //add params to grab bodyparts based on loc
					return
			if(used_intent.type == INTENT_DISARM)
				var/obj/AM = A
				if(istype(AM) && !AM.anchored)
					var/jadded = max(100-(STASTR*10),5)
					if(rogfat_add(jadded))
						visible_message("<span class='info'>[src] pushes [AM].</span>")
						PushAM(AM, MOVE_FORCE_STRONG)
					else
						visible_message("<span class='warning'>[src] pushes [AM].</span>")
					changeNext_move(CLICK_CD_MELEE)
					return
		A.attack_hand(src, params)

/mob/living/rmb_on(atom/A, params)
	if(stat)
		return

	if(!has_active_hand()) //can't attack without a hand.
		to_chat(src, "<span class='warning'>I lack working hands.</span>")
		return

	if(!has_hand_for_held_index(used_hand)) //can't attack without a hand.
		to_chat(src, "<span class='warning'>I can't move this hand.</span>")
		return

	if(check_arm_grabbed())
		to_chat(src, "<span class='warning'>[pulledby] is restraining my arm!</span>")
		return

	A.attack_right(src, params)

/mob/living/attack_right(mob/user, params)
	. = ..()
//	if(!user.Adjacent(src)) //alreadyu checked in rmb_on
//		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.face_atom(src)
	if(user.cmode)
		if(user.rmb_intent)
			user.rmb_intent.special_attack(user, src)
	else
		ongive(user, params)

/turf/attack_right(mob/user, params)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE)
	user.face_atom(src)
	if(user.cmode)
		if(user.rmb_intent)
			user.rmb_intent.special_attack(user, src)

/atom/proc/ongive(mob/user, params)
	return

/obj/item/ongive(mob/user, params) //take an item if hand is empty
	if(user.get_active_held_item())
		return
	src.attack_hand(user, params)

/mob
	var/mob/givingto
	var/lastgibto

/mob/living/ongive(mob/user, params)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(givingto == H && !H.get_active_held_item()) //take item being offered
		if(world.time > lastgibto + 100) //time out give after a while
			givingto = null
			return
		var/obj/item/I = get_active_held_item()
		if(I)
			transferItemToLoc(I, newloc = H, force = FALSE, silent = TRUE)
			H.put_in_active_hand(I)
			visible_message("<span class='notice'>[src.name] gives [I] to [H.name].</span>")
			return
		else
			givingto = null
	else if(!H.givingto && H.get_active_held_item()) //offer item
		if(get_empty_held_indexes())
			var/obj/item/I = H.get_active_held_item()
			H.givingto = src
			H.lastgibto = world.time
			to_chat(src, "<span class='notice'>[H.name] offers [I] to me.</span>")
			to_chat(H, "<span class='notice'>I offer [I] to [src.name].</span>")
		else
			to_chat(H, "<span class='warning'>[src.name]'s hands are full.</span>")

/atom/proc/onkick(mob/user)
	return

/obj/item/onkick(mob/user)
	if(!ontable())
		if(w_class < WEIGHT_CLASS_HUGE)
			throw_at(get_ranged_target_turf(src, get_dir(user,src), 2), 2, 2, user, FALSE)

/atom/proc/onbite(mob/user)
	return

/mob/living/onbite(mob/living/carbon/human/user)
	return

/mob/living/carbon/onbite(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>I don't want to harm [src]!</span>")
		return FALSE
	if(user.mouth)
		to_chat(user, "<span class='warning'>My mouth has something in it.</span>")
		return FALSE

	var/datum/intent/bite/bitten = new()
	if(checkdefense(bitten, user))
		return FALSE

	if(user.pulling != src)
		if(!lying_attack_check(user))
			return FALSE

	var/def_zone = check_zone(user.zone_selected)
	var/obj/item/bodypart/affecting = get_bodypart(def_zone)
	if(!affecting)
		to_chat(user, "<span class='warning'>Nothing to bite.</span>")
		return

	next_attack_msg.Cut()

	var/nodmg = FALSE
	var/dam2do = 10*(user.STASTR/20)
	if(HAS_TRAIT(user, RTRAIT_STRONGBITE))
		dam2do *= 2
	if(!HAS_TRAIT(user, RTRAIT_STRONGBITE))
		if(!affecting.has_wound(/datum/wound/bite))
			nodmg = TRUE
	if(!nodmg)
		var/armor_block = run_armor_check(user.zone_selected, "melee",blade_dulling=BCLASS_BITE)
		if(!apply_damage(dam2do, BRUTE, def_zone, armor_block, user))
			nodmg = TRUE
			next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"

	if(!nodmg)
		affecting.attacked_by(BCLASS_BITE, dam2do, user, user.zone_selected)
	visible_message("<span class='danger'>[user] bites [src]'s [parse_zone(user.zone_selected)]![next_attack_msg.Join()]</span>", \
					"<span class='userdanger'>[user] bites my [parse_zone(user.zone_selected)]![next_attack_msg.Join()]</span>")

	next_attack_msg.Cut()

	if(!nodmg)
		playsound(src, "smallslash", 100, TRUE, -1)
		if(user.mind && mind)
			if(user.mind.has_antag_datum(/datum/antagonist/werewolf))
				if(!src.mind.has_antag_datum(/datum/antagonist/werewolf))
					if(prob(10))
						addtimer(CALLBACK(src, .mob/living/carbon/human/proc/werewolf_infect), 3 MINUTES)
			if(user.mind.has_antag_datum(/datum/antagonist/zombie))
				if(!src.mind.has_antag_datum(/datum/antagonist/zombie))
					if(prob(23))
						addtimer(CALLBACK(src, .mob/living/carbon/human/proc/zombie_infect), 3 MINUTES)

	var/obj/item/grabbing/bite/B = new()
	user.equip_to_slot_or_del(B, SLOT_MOUTH)
	if(user.mouth == B)
		var/used_limb = src.find_used_grab_limb(user)
		B.name = "[src]'s [used_limb]"
		var/obj/item/bodypart/BP = get_bodypart(check_zone(user.zone_selected))
		BP.grabbedby += B
		B.grabbed = src
		B.grabbee = user
		B.limb_grabbed = BP
		B.sublimb_grabbed = used_limb

		lastattacker = user.real_name
		lastattackerckey = user.ckey
		if(mind)
			mind.attackedme[user.real_name] = world.time
		log_combat(user, src, "bit")

/mob/living/MiddleClickOn(atom/A, params)
	..()
	if(!mmb_intent)
		if(!A.Adjacent(src))
			return
		A.MiddleClick(src, params)
	else
		switch(mmb_intent.type)
//			if(INTENT_GIVE)
//				if(!A.Adjacent(src))
//					return
//				changeNext_move(mmb_intent.clickcd)
//				face_atom(A)
//				A.ongive(src, params)
			if(INTENT_KICK)
				if(src.get_num_legs() < 2)
					return
				if(!A.Adjacent(src))
					return
				if(A == src)
					return
				if(ismob(A))
					var/mob/M = A
					if(lying && M.pulling != src)
						return
				if(IsOffBalanced())
					to_chat(src, "<span class='warning'>I haven't regained my balance yet.</span>")
					return
				changeNext_move(mmb_intent.clickcd)
				face_atom(A)

				if(ismob(A))
					var/mob/living/M = A
					if(src.used_intent)

						src.do_attack_animation(M, visual_effect_icon = src.used_intent.animname)
						playsound(src, pick(PUNCHWOOSH), 100, FALSE, -1)

						sleep(src.used_intent.swingdelay)
						if(QDELETED(src) || QDELETED(M))
							return
						if(!M.Adjacent(src))
							return
						if(src.incapacitated())
							return
						if(M.checkmiss(src))
							return
						if(M.checkdefense(src.used_intent, src))
							return
					if(M.checkmiss(src))
						return
					if(!M.checkdefense(mmb_intent, src))
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							H.dna.species.kicked(src, H)
						else
							M.onkick(src)
				else
					A.onkick(src)
				OffBalance(30)
				return
			if(INTENT_JUMP)
				if(istype(src.loc, /turf/open/water))
					to_chat(src, "<span class='warning'>I'm floating.</span>")
					return
				if(A == src || A == src.loc)
					return
				if(src.get_num_legs() < 2)
					return
				if(pulledby && pulledby != src)
					to_chat(src, "<span class='warning'>I'm being grabbed.</span>")
					return
				if(IsOffBalanced())
					to_chat(src, "<span class='warning'>I haven't regained my balance yet.</span>")
					return
				if(lying)
					to_chat(src, "<span class='warning'>I should stand up first.</span>")
					return
				if(!ismob(A) && !isturf(A))
					return
				if(A.z != src.z)
					if(!HAS_TRAIT(src, RTRAIT_ZJUMP))
						return
				changeNext_move(mmb_intent.clickcd)
				face_atom(A)
				if(m_intent == MOVE_INTENT_RUN)
					emote("leap", forced = TRUE)
				else
					emote("jump", forced = TRUE)
				var/jadded
				var/jrange
				var/jextra = FALSE
				if(m_intent == MOVE_INTENT_RUN)
					OffBalance(30)
					jadded = 15
					jrange = 3
					jextra = TRUE
				else
					OffBalance(20)
					jadded = 10
					jrange = 2
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					jadded += H.get_complex_pain()/50
					if(!H.check_armor_skill())
						jadded += 50
						jrange = 1
				if(rogfat_add(min(jadded,100)))
					if(jextra)
						throw_at(A, jrange, 1, src, spin = FALSE)
						while(src.throwing)
							sleep(1)
						throw_at(get_step(src, src.dir), 1, 1, src, spin = FALSE)
					else
						throw_at(A, jrange, 1, src, spin = FALSE)
						while(src.throwing)
							sleep(1)
					if(isopenturf(src.loc))
						var/turf/open/T = src.loc
						if(T.landsound)
							playsound(T, T.landsound, 100, FALSE)
						T.Entered(src)
				else
					throw_at(A, 1, 1, src, spin = FALSE)
				return
			if(INTENT_BITE)
				if(!A.Adjacent(src))
					return
				if(A == src)
					return
				if(src.incapacitated())
					return
				if(!get_location_accessible(src, BODY_ZONE_PRECISE_MOUTH, grabs="other"))
					to_chat(src, "<span class='warning'>My mouth is blocked.</span>")
					return
				changeNext_move(mmb_intent.clickcd)
				face_atom(A)
				A.onbite(src)
				return
			if(INTENT_STEAL)
				if(!A.Adjacent(src))
					return
				if(ishuman(A))
					var/mob/living/carbon/human/U = src
					var/mob/living/carbon/human/V = A
					var/thiefskill = src.mind.get_skill_level(/datum/skill/misc/stealing)
					var/stealroll = roll("[thiefskill]d6")
					var/targetperception = (V.STAPER)
					var/list/stealablezones = list("chest", "neck", "groin", "r_hand", "l_hand")
					var/list/stealpos = list()
					if(stealroll > targetperception)
						if(!(zone_selected in stealablezones))
							to_chat()
							return
						switch(U.zone_selected)
							if("chest")
								stealpos.Add(V.get_item_by_slot(SLOT_BACK_L))
								stealpos.Add(V.get_item_by_slot(SLOT_BACK_R))
							if("neck")
								stealpos.Add(V.get_item_by_slot(SLOT_NECK))
							if("groin")
								stealpos.Add(V.get_item_by_slot(SLOT_BELT_R))
								stealpos.Add(V.get_item_by_slot(SLOT_BELT_L))	
							if("r_hand" || "l_hand")
								stealpos.Add(V.get_item_by_slot(SLOT_RING))
						var/obj/item/picked = pick(stealpos)
						V.dropItemToGround(picked)
						put_in_active_hand(picked)						
						to_chat(src, "<span class='green'>I stole [picked]!</span>")
					if(stealroll <= 4)	
						to_chat(V, "<span class='danger'>Someone tried pickpocketing me!</span>")
					if(stealroll < targetperception)
						to_chat(src, "<span class='danger'>I failed to pick the pocket!</span>")
					changeNext_move(mmb_intent.clickcd)
				return
			if(INTENT_SPELL)
				if(ranged_ability)
					if(ranged_ability.InterceptClickOn(src, params, A))
						changeNext_move(mmb_intent.clickcd)
						if(mmb_intent.releasedrain)
							rogfat_add(mmb_intent.releasedrain)
				return

//Return TRUE to cancel other attack hand effects that respect it.
/atom/proc/attack_hand(mob/user, params)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

/atom/proc/attack_right(mob/user)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

//Return a non FALSE value to cancel whatever called this from propagating, if it respects it.
/atom/proc/_try_interact(mob/user)
	if(IsAdminGhost(user))		//admin abuse
		return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user)
	if(!user.can_interact_with(src))
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>I don't have the dexterity to do this!</span>")
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/atom/ui_status(mob/user)
	. = ..()
	if(!can_interact(user))
		. = min(., UI_UPDATE)

/atom/movable/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	if(!anchored && (interaction_flags_atom & INTERACT_ATOM_REQUIRES_ANCHORED))
		return FALSE

/atom/proc/interact(mob/user)
	if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
		return ui_interact(user)
	return FALSE

/*
/mob/living/carbon/human/RestrainedClickOn(atom/A) ---carbons will handle this
	return
*/

/mob/living/carbon/RestrainedClickOn(atom/A)
	return 0

/mob/living/carbon/human/RangedAttack(atom/A, mouseparams)
	. = ..()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A,0)) // for magic gloves
			return
	if(!used_intent.noaa && ismob(A))
//		playsound(src, pick(GLOB.unarmed_swingmiss), 100, FALSE)
		do_attack_animation(A, visual_effect_icon = used_intent.animname)
		changeNext_move(used_intent.clickcd)
//		src.emote("attackgrunt")
		playsound(get_turf(src), used_intent.miss_sound, 100, FALSE)
		if(used_intent.miss_text)
			visible_message("<span class='warning'>[src] [used_intent.miss_text]!</span>", \
							"<span class='warning'>I [used_intent.miss_text]!</span>")
		aftermiss()

//	if(isturf(A) && get_dist(src,A) <= 1) //move this to grab inhand item being used on an empty tile
//		src.Move_Pulled(A)
//		return

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A)
	if(!isliving(A))
		if(used_intent.type == INTENT_GRAB)
			var/obj/structure/AM = A
			if(istype(AM) && !AM.anchored)
				start_pulling(A) //add params to grab bodyparts based on loc
				return
		if(used_intent.type == INTENT_DISARM)
			var/obj/structure/AM = A
			if(istype(AM) && !AM.anchored)
				var/jadded = max(100-(STASTR*10),5)
				if(rogfat_add(jadded))
					visible_message("<span class='info'>[src] pushes [AM].</span>")
					PushAM(AM, MOVE_FORCE_STRONG)
				else
					visible_message("<span class='warning'>[src] pushes [AM].</span>")
				return
	A.attack_animal(src)

/atom/proc/attack_animal(mob/user)
	return

/mob/living/RestrainedClickOn(atom/A)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(atom/A)
	A.attack_paw(src)

/atom/proc/attack_paw(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_PAW, user) & COMPONENT_NO_ATTACK_HAND)
		return TRUE
	return FALSE

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(atom/A)
	if(..())
		return
	if(used_intent.type != INTENT_HARM || !ismob(A))
		return
	if(is_muzzled())
		return
	var/mob/living/carbon/ML = A
	if(istype(ML))
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/affecting = null
		if(ishuman(ML))
			var/mob/living/carbon/human/H = ML
			affecting = H.get_bodypart(ran_zone(dam_zone))
		var/armor = ML.run_armor_check(affecting, "melee")
		if(prob(75))
			ML.apply_damage(rand(1,3), BRUTE, affecting, armor)
			ML.visible_message("<span class='danger'>[name] bites [ML]!</span>", \
							"<span class='danger'>[name] bites you!</span>", "<span class='hear'>I hear a chomp!</span>", COMBAT_MESSAGE_RANGE, name)
			to_chat(name, "<span class='danger'>I bite [ML]!</span>")
			if(armor >= 2)
				return
			for(var/thing in diseases)
				var/datum/disease/D = thing
				ML.ForceContractDisease(D)
		else
			ML.visible_message("<span class='danger'>[src]'s bite misses [ML]!</span>", \
							"<span class='danger'>I avoid [src]'s bite!</span>", "<span class='hear'>I hear jaws snapping shut!</span>", COMBAT_MESSAGE_RANGE, src)
			to_chat(src, "<span class='danger'>My bite misses [ML]!</span>")

/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/UnarmedAttack(atom/A)
	A.attack_alien(src)

/atom/proc/attack_alien(mob/living/carbon/alien/user)
	attack_paw(user)
	return

/mob/living/carbon/alien/RestrainedClickOn(atom/A)
	return

// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(atom/A)
	A.attack_larva(src)
/atom/proc/attack_larva(mob/user)
	return


/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/UnarmedAttack(atom/A)
	A.attack_slime(src)
/atom/proc/attack_slime(mob/user)
	return
/mob/living/simple_animal/slime/RestrainedClickOn(atom/A)
	return


/*
	Drones
*/
/mob/living/simple_animal/drone/UnarmedAttack(atom/A)
	A.attack_drone(src)

/atom/proc/attack_drone(mob/living/simple_animal/drone/user)
	attack_hand(user) //defaults to attack_hand. Override it when you don't want drones to do same stuff as humans.

/mob/living/simple_animal/slime/RestrainedClickOn(atom/A)
	return


/*
	True Devil
*/

/mob/living/carbon/true_devil/UnarmedAttack(atom/A, proximity)
	A.attack_hand(src)

/*
	Brain
*/

/mob/living/brain/UnarmedAttack(atom/A)//Stops runtimes due to attack_animal being the default
	return


/*
	pAI
*/

/mob/living/silicon/pai/UnarmedAttack(atom/A)//Stops runtimes due to attack_animal being the default
	return


/*
	Simple animals
*/

/mob/living/simple_animal/UnarmedAttack(atom/A, proximity)
	if(!dextrous)
		return ..()
	if(!ismob(A))
		A.attack_hand(src)
		update_inv_hands()


/*
	Hostile animals
*/

/mob/living/simple_animal/hostile/UnarmedAttack(atom/A)
	target = A
	if(dextrous && !ismob(A))
		..()
	else
		AttackingTarget()



/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/dead/new_player/ClickOn()
	return
