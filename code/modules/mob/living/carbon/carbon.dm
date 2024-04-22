/mob/living/carbon/Initialize()
	. = ..()
	create_reagents(1000)
	update_body_parts() //to update the carbon's new bodyparts appearance
	GLOB.carbon_list += src

/mob/living/carbon/Destroy()
	//This must be done first, so the mob ghosts correctly before DNA etc is nulled
	. =  ..()

	QDEL_LIST(hand_bodyparts)
	QDEL_LIST(internal_organs)
	QDEL_LIST(bodyparts)
	QDEL_LIST(implants)
	remove_from_all_data_huds()
	QDEL_NULL(dna)
	GLOB.carbon_list -= src

/mob/living/carbon/ZImpactDamage(turf/T, levels)
	var/obj/item/bodypart/affecting
	if(prob(66))
		affecting = get_bodypart("[pick("r","l")]_leg")
		to_chat(src, "<span class='warning'>I land on my leg!</span>")
		if(affecting && apply_damage((levels * 10), BRUTE, affecting))		// 100 brute damage
			update_damage_overlays()
	else
		switch(rand(1,3))
			if(1)
				affecting = get_bodypart("[pick("r","l")]_arm")
				to_chat(src, "<span class='warning'>I land on my arm!</span>")
				if(affecting && apply_damage((levels * 10), BRUTE, affecting))		// 100 brute damage
					update_damage_overlays()
			if(2)
				affecting = get_bodypart("chest")
				to_chat(src, "<span class='warning'>I land on my chest!</span>")
				adjustOxyLoss(50)
				emote("breathgasp")
				if(affecting && apply_damage((levels * 10), BRUTE, affecting))		// 100 brute damage
					update_damage_overlays()
			if(3)
				affecting = get_bodypart("head")
				to_chat(src, "<span class='warning'>I land on my head!</span>")
				if(levels > 2)
					AdjustUnconscious(levels * 100)
					if(affecting && apply_damage((levels * 10), BRUTE, affecting))		// 100 brute damage
						update_damage_overlays()
				else
					if(affecting && apply_damage((levels * 10), BRUTE, affecting))		// 100 brute damage
						update_damage_overlays()

	AdjustStun(levels * 20)
	AdjustKnockdown(levels * 20)

/mob/living/carbon/swap_hand(held_index)
	if(!held_index)
		held_index = (active_hand_index % held_items.len)+1

	var/obj/item/item_in_hand = src.get_active_held_item()
	if(item_in_hand) //this segment checks if the item in your hand is twohanded.
		if(istype(item_in_hand))
			if(item_in_hand.wielded == 1)
				to_chat(usr, "<span class='warning'>My other hand is too busy holding [item_in_hand].</span>")
				return FALSE
	if(atkswinging || atkreleasing)
		stop_attack(FALSE)
	var/oindex = active_hand_index
	active_hand_index = held_index
	if(hud_used)
		hud_used.throw_icon?.update_icon()
		hud_used.give_intent?.update_icon()
		var/obj/screen/inventory/hand/H
		H = hud_used.hand_slots["[oindex]"]
		if(H)
			H.update_icon()
		H = hud_used.hand_slots["[held_index]"]
		if(H)
			H.update_icon()
		H = hud_used.action_intent
	oactive = FALSE
	update_a_intents()

	givingto = null
	return TRUE


/mob/living/carbon/activate_hand(selhand) //l/r OR 1-held_items.len
	if(!selhand)
		selhand = (active_hand_index % held_items.len)+1

	if(istext(selhand))
		selhand = lowertext(selhand)
		if(selhand == "right" || selhand == "r")
			selhand = 2
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != active_hand_index)
		swap_hand(selhand)
	else
		mode() // Activate held item

/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	for(var/datum/surgery/S in surgeries)
		if(!(mobility_flags & MOBILITY_STAND) || !S.lying_required)
			if((S.self_operable || user != src) && (user.used_intent.type == INTENT_HELP || user.used_intent.type == INTENT_DISARM))
				if(S.next_step(user,user.used_intent))
					return 1
	return ..()

/mob/living/carbon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	var/hurt = TRUE
	if(istype(throwingdatum, /datum/thrownthing))
		var/datum/thrownthing/D = throwingdatum
		if(iscyborg(D.thrower))
			var/mob/living/silicon/robot/R = D.thrower
			if(!R.emagged)
				hurt = FALSE
	if(hit_atom.density && isturf(hit_atom))
		if(hurt)
			Paralyze(20)
			take_bodypart_damage(10,check_armor = TRUE)
	if(iscarbon(hit_atom) && hit_atom != src)
		var/mob/living/carbon/victim = hit_atom
		if(victim.movement_type & FLYING)
			return
		if(hurt)
			victim.take_bodypart_damage(10,check_armor = TRUE)
			take_bodypart_damage(10,check_armor = TRUE)
			if(victim.IsOffBalanced())
				victim.Knockdown(30)
			visible_message("<span class='danger'>[src] crashes into [victim]!",\
				"<span class='danger'>I violently crash into [victim]!</span>")
		playsound(src,"genblunt",100,TRUE)


//Throwing stuff
/mob/living/carbon/proc/toggle_throw_mode()
	if(stat)
		return
	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()


/mob/living/carbon/proc/throw_mode_off()
	in_throw_mode = 0
	if(client && hud_used)
		hud_used.throw_icon?.throwy = 0
		hud_used.throw_icon?.update_icon()


/mob/living/carbon/proc/throw_mode_on()
	in_throw_mode = 1
	if(client && hud_used)
		hud_used.throw_icon?.throwy = 1
		hud_used.throw_icon?.update_icon()

/mob/proc/throw_item(atom/target, offhand = FALSE)
	SEND_SIGNAL(src, COMSIG_MOB_THROW, target)
	return

/mob/living/carbon/throw_item(atom/target, offhand = FALSE)
	. = ..()
	throw_mode_off()
	if(!target || !isturf(loc))
		return
	if(istype(target, /obj/screen))
		return

	var/atom/movable/thrown_thing
	var/thrown_speed
	var/thrown_range
	var/obj/item/I = get_active_held_item()
	if(offhand)
		I = get_inactive_held_item()

	var/used_sound

	if(I)
		if(istype(I, /obj/item/grabbing))
			var/obj/item/grabbing/G = I
			if(pulling && pulling != src)
				if(isliving(pulling))
					var/mob/living/throwable_mob = pulling
					if(!throwable_mob.buckled)
						thrown_thing = throwable_mob
						thrown_speed = 1
						if(STASTR > throwable_mob.STACON)
							thrown_range = 4
						else
							thrown_range = 1
						stop_pulling()
						if(G.grab_state < GRAB_AGGRESSIVE)
							return
						if(HAS_TRAIT(src, TRAIT_PACIFISM))
							to_chat(src, "<span class='notice'>I gently let go of [throwable_mob].</span>")
							return
						var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
						var/turf/end_T = get_turf(target)
						if(start_T && end_T)
							log_combat(src, throwable_mob, "thrown", addition="grab from tile in [AREACOORD(start_T)] towards tile at [AREACOORD(end_T)]")
				else
					thrown_thing = pulling
					dropItemToGround(I, silent = TRUE)

		else if(!CHECK_BITFIELD(I.item_flags, ABSTRACT) && !HAS_TRAIT(I, TRAIT_NODROP))
			thrown_thing = I
			if(I.swingsound)
				used_sound = pick(I.swingsound)
			dropItemToGround(I, silent = TRUE)

			if(HAS_TRAIT(src, TRAIT_PACIFISM) && I.throwforce)
				to_chat(src, "<span class='notice'>I set [I] down gently on the ground.</span>")
				return


	if(thrown_thing)
		if(!thrown_speed)
			thrown_speed = thrown_thing.throw_speed
		if(!thrown_range)
			thrown_range = thrown_thing.throw_range
		visible_message("<span class='danger'>[src] throws [thrown_thing].</span>", \
						"<span class='danger'>I toss [thrown_thing].</span>")
		log_message("has thrown [thrown_thing]", LOG_ATTACK)
		newtonian_move(get_dir(target, src))
		thrown_thing.safe_throw_at(target, thrown_range, thrown_speed, src, null, null, null, move_force)
		if(!used_sound)
			used_sound = pick(PUNCHWOOSH)
		playsound(get_turf(src), used_sound, 100, FALSE)

/mob/living/carbon/restrained(ignore_grab = TRUE)
//	. = (handcuffed || (!ignore_grab && pulledby && pulledby.grab_state >= GRAB_AGGRESSIVE))
	if(handcuffed)
		return TRUE
	if(pulledby && !ignore_grab)
		if(pulledby != src)
			return TRUE

/mob/living/carbon/proc/canBeHandcuffed()
	return 0


/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)
	var/dat = {"
	<HR>
	<B><FONT size=3>[name]</FONT></B>
	<HR>
	<BR><B>Head:</B> <A href='?src=[REF(src)];item=[SLOT_HEAD]'>[(head && !(head.item_flags & ABSTRACT)) ? head : "Nothing"]</A>"}

	var/list/obscured = check_obscured_slots()

	if(SLOT_NECK in obscured)
		dat += "<BR><B>Neck:</B> Obscured"
	else
		dat += "<BR><B>Neck:</B> <A href='?src=[REF(src)];item=[SLOT_NECK]'>[(wear_neck && !(wear_neck.item_flags & ABSTRACT)) ? (wear_neck) : "Nothing"]</A>"

	if(SLOT_WEAR_MASK in obscured)
		dat += "<BR><B>Mask:</B> Obscured"
	else
		dat += "<BR><B>Mask:</B> <A href='?src=[REF(src)];item=[SLOT_WEAR_MASK]'>[(wear_mask && !(wear_mask.item_flags & ABSTRACT))	? wear_mask	: "Nothing"]</a>"

	for(var/i in 1 to held_items.len)
		var/obj/item/I = get_item_for_held_index(i)
		dat += "<BR><B>[get_held_index_name(i)]:</B> </td><td><A href='?src=[REF(src)];item=[SLOT_HANDS];hand_index=[i]'>[(I && !(I.item_flags & ABSTRACT)) ? I : "Nothing"]</a>"

	dat += "<BR><B>Back:</B> <A href='?src=[REF(src)];item=[SLOT_BACK]'>[back ? back : "Nothing"]</A>"


	if(istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/tank))
		dat += "<BR><A href='?src=[REF(src)];internal=1'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	if(handcuffed)
		dat += "<BR><A href='?src=[REF(src)];item=[SLOT_HANDCUFFED]'>Handcuffed</A>"
	if(legcuffed)
		dat += "<BR><A href='?src=[REF(src)];item=[SLOT_LEGCUFFED]'>Legcuffed</A>"

	dat += {"
	<BR>
	<BR><A href='?src=[REF(user)];mach_close=mob[REF(src)]'>Close</A>
	"}
	user << browse(dat, "window=mob[REF(src)];size=325x500")
	onclose(user, "mob[REF(src)]")

/mob/living/carbon/Topic(href, href_list)
	..()
	//strip panel
	if(href_list["internal"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		var/slot = text2num(href_list["internal"])
		var/obj/item/ITEM = get_item_by_slot(slot)
		if(ITEM && istype(ITEM, /obj/item/tank) && wear_mask && (wear_mask.clothing_flags & MASKINTERNALS))
			visible_message("<span class='danger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM.name].</span>", \
							"<span class='danger'>[usr] tries to [internal ? "close" : "open"] the valve on your [ITEM.name].</span>", null, null, usr)
			to_chat(usr, "<span class='notice'>I try to [internal ? "close" : "open"] the valve on [src]'s [ITEM.name]...</span>")
			if(do_mob(usr, src, POCKET_STRIP_DELAY))
				if(internal)
					internal = null
					update_internals_hud_icon(0)
				else if(ITEM && istype(ITEM, /obj/item/tank))
					if((wear_mask && (wear_mask.clothing_flags & MASKINTERNALS)) || getorganslot(ORGAN_SLOT_BREATHING_TUBE))
						internal = ITEM
						update_internals_hud_icon(1)

				visible_message("<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM.name].</span>", \
								"<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on your [ITEM.name].</span>", null, null, usr)
				to_chat(usr, "<span class='notice'>I [internal ? "open" : "close"] the valve on [src]'s [ITEM.name].</span>")

/mob/living/carbon/fall(forced)
    loc.handle_fall(src, forced)//it's loc so it doesn't call the mob's handle_fall which does nothing

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))

/mob/living/carbon/hallucinating()
	if(hallucination)
		return TRUE
	else
		return FALSE

/obj/structure
	var/breakoutextra = 30 SECONDS

/mob/living/carbon/resist_buckle()
	if(restrained())
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		var/buckle_cd = 600
		if(handcuffed)
			var/obj/item/restraints/O = src.get_item_by_slot(SLOT_HANDCUFFED)
			buckle_cd = O.breakouttime
		if(istype(buckled, /obj/structure))
			var/obj/structure/S = buckled
			buckle_cd += S.breakoutextra
		if(STASTR > 15)
			buckle_cd = 3 SECONDS
		visible_message("<span class='warning'>[src] attempts to struggle free!</span>", \
					"<span class='notice'>I attempt to struggle free...</span>")
		if(do_after(src, buckle_cd, 0, target = src))
			if(!buckled)
				return
			buckled.user_unbuckle_mob(src,src)
		else
			if(src && buckled)
				to_chat(src, "<span class='warning'>I fail to struggle free!</span>")
	else
		buckled.user_unbuckle_mob(src,src)

/mob/living/carbon/resist_fire()
	fire_stacks -= 5
	if(fire_stacks > 10)
		Paralyze(60, TRUE, TRUE)
		spin(32,2)
		fire_stacks -= 5
		visible_message("<span class='warning'>[src] rolls on the ground, trying to put [p_them()]self out!</span>")
	else
		visible_message("<span class='notice'>[src] pats the flames to extinguish them.</span>")
	sleep(30)
	if(fire_stacks <= 0)
		ExtinguishMob(TRUE)
	return

/mob/living/carbon/resist_restraints()
	var/obj/item/I = null
	var/type = 0
	if(handcuffed)
		I = handcuffed
		type = 1
	else if(legcuffed)
		I = legcuffed
		type = 2
	if(I)
		if(type == 1)
			changeNext_move(CLICK_CD_BREAKOUT)
			last_special = world.time + CLICK_CD_BREAKOUT
		if(type == 2)
			changeNext_move(CLICK_CD_RANGE)
			last_special = world.time + CLICK_CD_RANGE
		cuff_resist(I)


/mob/living/carbon/proc/cuff_resist(obj/item/I, breakouttime = 600, cuff_break = 0)
	if(I.item_flags & BEING_REMOVED)
		to_chat(src, "<span class='warning'>You're already attempting to remove [I]!</span>")
		return
	I.item_flags |= BEING_REMOVED
	breakouttime = I.slipouttime
	if(STASTR > 10)
		cuff_break = FAST_CUFFBREAK
		breakouttime = I.breakouttime
	if(STASTR > 15 || (mind && mind.has_antag_datum(/datum/antagonist/zombie)) )
		cuff_break = INSTANT_CUFFBREAK
	if(!cuff_break)
		to_chat(src, "<span class='notice'>I attempt to remove [I]...</span>")
		if(do_after(src, breakouttime, 0, target = src))
			clear_cuffs(I, cuff_break)
		else
			to_chat(src, "<span class='danger'>I fail to remove [I]!</span>")

	else if(cuff_break == FAST_CUFFBREAK)
		to_chat(src, "<span class='notice'>I attempt to break [I]...</span>")
		if(do_after(src, breakouttime, 0, target = src))
			clear_cuffs(I, cuff_break)
		else
			to_chat(src, "<span class='danger'>I fail to break [I]!</span>")

	else if(cuff_break == INSTANT_CUFFBREAK)
		clear_cuffs(I, cuff_break)
	I.item_flags &= ~BEING_REMOVED

/mob/living/carbon/proc/uncuff()
	if (handcuffed)
		var/obj/item/W = handcuffed
		handcuffed = null
		if (buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		update_handcuffed()
		if (client)
			client.screen -= W
		if (W)
			W.forceMove(drop_location())
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
		changeNext_move(0)
	if (legcuffed)
		var/obj/item/W = legcuffed
		legcuffed = null
		update_inv_legcuffed()
		if (client)
			client.screen -= W
		if (W)
			W.forceMove(drop_location())
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
		changeNext_move(0)

/mob/living/carbon/proc/clear_cuffs(obj/item/I, cuff_break)
	if(!I.loc || buckled)
		return FALSE
	if(I != handcuffed && I != legcuffed)
		return FALSE
	visible_message("[cuff_break ? "<span class='danger'>" : "<span class='warning'>"][src] manages to [cuff_break ? "break" : "slip"] out of [I]!</span>")
	to_chat(src, "<span class='notice'>I [cuff_break ? "break" : "slip"] out of [I]!</span>")

	if(cuff_break)
		. = !((I == handcuffed) || (I == legcuffed))
		qdel(I)
		return TRUE

	else
		if(I == handcuffed)
			handcuffed.forceMove(drop_location())
			handcuffed.dropped(src)
			handcuffed = null
			if(buckled && buckled.buckle_requires_restraints)
				buckled.unbuckle_mob(src)
			update_handcuffed()
			return TRUE
		if(I == legcuffed)
			legcuffed.forceMove(drop_location())
			legcuffed.dropped()
			legcuffed = null
			update_inv_legcuffed()
			return TRUE

/mob/living/carbon/get_standard_pixel_y_offset(lying = 0)
	. = ..()
	if(lying)
		. = . - 6

/mob/living/carbon/proc/accident(obj/item/I)
	if(!I || (I.item_flags & ABSTRACT) || HAS_TRAIT(I, TRAIT_NODROP))
		return

	dropItemToGround(I)

	var/modifier = 0
	if(HAS_TRAIT(src, TRAIT_CLUMSY))
		modifier -= 40 //Clumsy people are more likely to hit themselves -Honk!

	switch(rand(1,100)+modifier) //91-100=Nothing special happens
		if(-INFINITY to 0) //attack yourself
			I.attack(src,src)
		if(1 to 30) //throw it at yourself
			I.throw_impact(src)
		if(31 to 60) //Throw object in facing direction
			var/turf/target = get_turf(loc)
			var/range = rand(2,I.throw_range)
			for(var/i = 1; i < range; i++)
				var/turf/new_turf = get_step(target, dir)
				target = new_turf
				if(new_turf.density)
					break
			I.throw_at(target,I.throw_range,I.throw_speed,src)
		if(61 to 90) //throw it down to the floor
			var/turf/target = get_turf(loc)
			I.safe_throw_at(target,I.throw_range,I.throw_speed,src, force = move_force)

/mob/living/carbon/proc/get_str_arms(num)
	if(!domhand || !num)
		return STASTR
	var/used = STASTR
	if(num == domhand)
		return used
	else
		used = STASTR - 1
		if(used < 1)
			used = 1
		return used

/mob/living/Stat()
	..()
	if(statpanel("Stats"))
		stat("STR: \Roman [STASTR]")
		stat("PER: \Roman [STAPER]")
		stat("INT: \Roman [STAINT]")
		stat("CON: \Roman [STACON]")
		stat("END: \Roman [STAEND]")
		stat("SPD: \Roman [STASPD]")
		stat("PATRON: [PATRON]")

/mob/living/carbon/Stat()
	..()
	if(statpanel("Status"))
		var/obj/item/organ/alien/plasmavessel/vessel = getorgan(/obj/item/organ/alien/plasmavessel)
		if(vessel)
			stat(null, "Plasma Stored: [vessel.storedPlasma]/[vessel.max_plasma]")
		if(locate(/obj/item/assembly/health) in src)
			stat(null, "Health: [health]")
	add_abilities_to_panel()

/mob/living/carbon/attack_ui(slot)
	if(!has_hand_for_held_index(active_hand_index))
		return 0
	return ..()

/mob/living/carbon
	var/nausea = 0

/mob/living/carbon/proc/add_nausea(amt)
	nausea = clamp(nausea + amt, 0, 300)

/mob/living/carbon/proc/handle_nausea()
	if(nausea >= 100)
		if(mob_timers["puke"])
			if(world.time > mob_timers["puke"] + 16 SECONDS)
				mob_timers["puke"] = world.time
				if(getorgan(/obj/item/organ/stomach))
					to_chat(src, "<span class='warning'>I'm going to puke...</span>")
					addtimer(CALLBACK(src, PROC_REF(vomit), 50), rand(8 SECONDS, 15 SECONDS))
			else
				if(prob(3))
					to_chat(src, "<span class='warning'>I feel sick...</span>")
		else
			if(getorgan(/obj/item/organ/stomach))
				mob_timers["puke"] = world.time
				to_chat(src, "<span class='warning'>I'm going to puke...</span>")
				addtimer(CALLBACK(src, PROC_REF(vomit), 50), rand(8 SECONDS, 15 SECONDS))
	add_nausea(-1)


/mob/living/carbon/proc/vomit(lost_nutrition = 50, blood = FALSE, stun = TRUE, distance = 1, message = TRUE, toxic = FALSE, harm = FALSE, force = FALSE)
	if(HAS_TRAIT(src, TRAIT_TOXINLOVER) && !force)
		return TRUE

	mob_timers["puke"] = world.time

	if(nutrition <= 50 && !blood)
		if(message)
			emote("gag")
		if(stun)
			Immobilize(50)
		return TRUE
	if(!blood)
		if(HAS_TRAIT(src, TRAIT_NOHUNGER))
			return TRUE
		add_nausea(-100)
		rogstam_add(-50)
		if(is_mouth_covered()) //make this add a blood/vomit overlay later it'll be hilarious
			if(message)
				visible_message("<span class='danger'>[src] throws up all over [p_them()]self!</span>", \
								"<span class='danger'>I puke all over myself!</span>")
				SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "vomit", /datum/mood_event/vomitself)
				add_stress(/datum/stressevent/vomitself)
			distance = 0
		else
			if(message)
				visible_message("<span class='danger'>[src] pukes!</span>", "<span class='danger'>I puke!</span>")
				if(!isflyperson(src))
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "vomit", /datum/mood_event/vomit)
					add_stress(/datum/stressevent/vomit)
	else
		if(NOBLOOD in dna?.species?.species_traits)
			return TRUE
		if(message)
			visible_message("<span class='danger'>[src] coughs up blood!</span>", "<span class='danger'>I cough up blood!</span>")

	if(stun)
		Immobilize(59)

	if(!blood)
		playsound(get_turf(src), pick('sound/vo/vomit.ogg','sound/vo/vomit_2.ogg'), 100, TRUE)
	else
		if(stat != DEAD)
			playsound(src, pick('sound/vo/throat.ogg','sound/vo/throat2.ogg','sound/vo/throat3.ogg'), 100, FALSE)

	blur_eyes(10)

	var/turf/T = get_turf(src)
	if(!blood)
		if(nutrition > 50)
			adjust_nutrition(-lost_nutrition)
			adjust_hydration(-lost_nutrition)
//adjustToxLoss(-3)
	if(harm)
		adjustBruteLoss(3)
	for(var/i=0 to distance)
		if(blood)
			if(T)
				bleed(5)
		else if(src.reagents.has_reagent(/datum/reagent/consumable/ethanol/blazaam, needs_metabolizing = TRUE))
			if(T)
				T.add_vomit_floor(src, VOMIT_PURPLE)
		else
			if(T)
				T.add_vomit_floor(src, VOMIT_TOXIC)//toxic barf looks different
		T = get_step(T, dir)
		if (is_blocked_turf(T))
			break
	return TRUE

/mob/living/carbon/proc/spew_organ(power = 5, amt = 1)
	for(var/i in 1 to amt)
		if(!internal_organs.len)
			break //Guess we're out of organs!
		var/obj/item/organ/guts = pick(internal_organs)
		var/turf/T = get_turf(src)
		guts.Remove(src)
		guts.forceMove(T)
		var/atom/throw_target = get_edge_target_turf(guts, dir)
		guts.throw_at(throw_target, power, 4, src)


/mob/living/carbon/fully_replace_character_name(oldname,newname)
	..()
	if(dna)
		dna.real_name = real_name

/mob/living/carbon/update_mobility()
	. = ..()
	if(!(mobility_flags & MOBILITY_STAND))
		add_movespeed_modifier(MOVESPEED_ID_CARBON_CRAWLING, TRUE, multiplicative_slowdown = CRAWLING_ADD_SLOWDOWN)
	else
		remove_movespeed_modifier(MOVESPEED_ID_CARBON_CRAWLING, TRUE)

//Updates the mob's health from bodyparts and mob damage variables
/mob/living/carbon/updatehealth()
	if(status_flags & GODMODE)
		return
	var/total_burn	= 0
//	var/total_brute	= 0
	var/total_stamina = 0
	var/total_tox = getToxLoss()
	var/total_oxy = getOxyLoss()
	var/used_damage = 0
	for(var/X in bodyparts)	//hardcoded to streamline things a bit
		var/obj/item/bodypart/BP = X
		if(BP.name == "head")
			total_burn = ((BP.burn_dam / BP.max_damage) * 100)
		if(BP.name == "chest")
			total_burn = ((BP.burn_dam / BP.max_damage) * 100)
		if(used_damage < total_burn)
			used_damage = total_burn
	if(used_damage < total_tox)
		used_damage = total_tox
	if(used_damage < total_oxy)
		used_damage = total_oxy
	health = round(maxHealth - used_damage, DAMAGE_PRECISION)
	staminaloss = round(total_stamina, DAMAGE_PRECISION)
	update_stat()
	update_mobility()
//	if(((maxHealth - total_burn) < HEALTH_THRESHOLD_DEAD) && stat == DEAD )
//		become_husk("burn")

	med_hud_set_health()
	if(stat == SOFT_CRIT)
		add_movespeed_modifier(MOVESPEED_ID_CARBON_SOFTCRIT, TRUE, multiplicative_slowdown = SOFTCRIT_ADD_SLOWDOWN)
	else
		remove_movespeed_modifier(MOVESPEED_ID_CARBON_SOFTCRIT, TRUE)

/mob/living/carbon/human/updatehealth()
	if(mind && mind.has_antag_datum(/datum/antagonist/zombie))
		health = 100
		update_stat()
		update_mobility()
		med_hud_set_health()
		remove_movespeed_modifier(MOVESPEED_ID_CARBON_SOFTCRIT, TRUE)
		return
	..()

/mob/living/carbon/update_stamina()
	var/stam = getStaminaLoss()
	if(stam > DAMAGE_PRECISION && (maxHealth - stam) <= crit_threshold && !stat)
		enter_stamcrit()
	else if(stam_paralyzed)
		stam_paralyzed = FALSE
	else
		return
	update_health_hud()

/mob/living/carbon
	var/lightning_flashing = FALSE

/mob/living/carbon/update_sight()
	if(!client)
		return
//	if(stat == DEAD)
//		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
//		see_in_dark = 8
//		see_invisible = SEE_INVISIBLE_OBSERVER
//		return

	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)
	var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
	if(!E)
		update_tint()
	else
		see_invisible = E.see_invisible
		see_in_dark = E.see_in_dark
		sight |= E.sight_flags
		if(!isnull(E.lighting_alpha))
			lighting_alpha = E.lighting_alpha

	if(lightning_flashing)
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_INVISIBLE)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A)
			if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
				return

	if(glasses)
		var/obj/item/clothing/glasses/G = glasses
		sight |= G.vision_flags
		see_in_dark = max(G.darkness_view, see_in_dark)
		if(G.invis_override)
			see_invisible = G.invis_override
		else
			see_invisible = min(G.invis_view, see_invisible)
		if(!isnull(G.lighting_alpha))
			lighting_alpha = min(lighting_alpha, G.lighting_alpha)

	if(HAS_TRAIT(src, TRAIT_THERMAL_VISION))
		sight |= (SEE_MOBS)
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

	if(HAS_TRAIT(src, TRAIT_XRAY_VISION))
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = max(see_in_dark, 8)

	if(see_override)
		see_invisible = see_override
	. = ..()


//to recalculate and update the mob's total tint from tinted equipment it's wearing.
/mob/living/carbon/proc/update_tint()
	if(!GLOB.tinted_weldhelh)
		return
	tinttotal = get_total_tint()
	if(tinttotal >= TINT_BLIND)
		become_blind(EYES_COVERED)
	else if(tinttotal >= TINT_DARKENED)
		cure_blind(EYES_COVERED)
		overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
	else
		cure_blind(EYES_COVERED)
		clear_fullscreen("tint", 0)

/mob/living/carbon/proc/get_total_tint()
	. = 0
	if(isclothing(head))
		. += head.tint
	if(isclothing(wear_mask))
		. += wear_mask.tint

	var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
	if(E)
		. += E.tint

	else
		. += INFINITY

/mob/living/carbon/get_permeability_protection(list/target_zones = list(HANDS,CHEST,GROIN,LEGS,FEET,ARMS,HEAD))
	var/list/tally = list()
	for(var/obj/item/I in get_equipped_items())
		for(var/zone in target_zones)
			if(I.body_parts_covered & zone)
				tally["[zone]"] = max(1 - I.permeability_coefficient, target_zones["[zone]"])
	var/protection = 0
	for(var/key in tally)
		protection += tally[key]
	protection *= INVERSE(target_zones.len)
	return protection

/mob/living
	var/succumb_timer = 0

//this handles hud updates
/mob/living/carbon/update_damage_hud()

	if(!client)
		return
	if(cmode)
		overlay_fullscreen("CMODE", /obj/screen/fullscreen/crit/cmode)
	else
		clear_fullscreen("CMODE")

	if(health <= crit_threshold || (blood_volume in -INFINITY to BLOOD_VOLUME_SURVIVE))
		var/severity = 0
		switch(health)
			if(-20 to -10)
				severity = 1
			if(-30 to -20)
				severity = 2
			if(-40 to -30)
				severity = 3
			if(-50 to -40)
				severity = 4
			if(-50 to -40)
				severity = 5
			if(-60 to -50)
				severity = 6
			if(-70 to -60)
				severity = 7
			if(-90 to -70)
				severity = 8
			if(-95 to -90)
				severity = 9
			if(-INFINITY to -95)
				severity = 10
		if(!InFullCritical())
			var/visionseverity = 4
			switch(health)
				if(-8 to -4)
					visionseverity = 5
				if(-12 to -8)
					visionseverity = 6
				if(-16 to -12)
					visionseverity = 7
				if(-20 to -16)
					visionseverity = 8
				if(-24 to -20)
					visionseverity = 9
				if(-INFINITY to -24)
					visionseverity = 10
			overlay_fullscreen("critvision", /obj/screen/fullscreen/crit/vision, visionseverity)
		else
			clear_fullscreen("critvision")
		if(!succumb_timer)
			succumb_timer = world.time
		overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
		overlay_fullscreen("DD", /obj/screen/fullscreen/crit/death)
		overlay_fullscreen("DDZ", /obj/screen/fullscreen/crit/zeth)
	else
		if(succumb_timer)
			succumb_timer = 0
		clear_fullscreen("crit")
		clear_fullscreen("critvision")
		clear_fullscreen("DD")
		clear_fullscreen("DDZ")
	if(hud_used)
		if(hud_used.stressies)
			hud_used.stressies.update_icon()
//	if(blood_volume <= 0)
//		overlay_fullscreen("DD", /obj/screen/fullscreen/crit/death)
//	else
//		clear_fullscreen("DD")

	//Oxygen damage overlay
	if(oxyloss)
		var/severity = 0
		switch(oxyloss)
			if(10 to 20)
				severity = 1
			if(20 to 25)
				severity = 2
			if(25 to 30)
				severity = 3
			if(30 to 35)
				severity = 4
			if(35 to 40)
				severity = 5
			if(40 to 45)
				severity = 6
			if(45 to INFINITY)
				severity = 7
		overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
	else
		clear_fullscreen("oxy")
/*
	//Fire and Brute damage overlay (BSSR)
	var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
	if(hurtdamage)
		var/severity = 0
		switch(hurtdamage)
			if(5 to 15)
				severity = 1
			if(15 to 30)
				severity = 2
			if(30 to 45)
				severity = 3
			if(45 to 70)
				severity = 4
			if(70 to 85)
				severity = 5
			if(85 to INFINITY)
				severity = 6
		overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("brute")*/

	var/hurtdamage = ((get_complex_pain() / (STAEND * 10)) * 100) //what percent out of 100 to max pain
	if(hurtdamage)
		var/severity = 0
		switch(hurtdamage)
			if(5 to 20)
				severity = 1
			if(20 to 40)
				severity = 2
			if(40 to 60)
				severity = 3
			if(60 to 80)
				severity = 4
			if(80 to 99)
				severity = 5
				overlay_fullscreen("painflash", /obj/screen/fullscreen/painflash)
			if(99 to INFINITY)
				severity = 6
				overlay_fullscreen("painflash", /obj/screen/fullscreen/painflash)
		overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("brute")
		clear_fullscreen("painflash")

/mob/living/carbon/update_health_hud(shown_health_amount)
	if(!client || !hud_used)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			. = 1
			if(shown_health_amount == null)
				shown_health_amount = health
			if(shown_health_amount >= maxHealth)
				hud_used.healths.icon_state = "health0"
			else if(shown_health_amount > maxHealth*0.8)
				hud_used.healths.icon_state = "health1"
			else if(shown_health_amount > maxHealth*0.6)
				hud_used.healths.icon_state = "health2"
			else if(shown_health_amount > maxHealth*0.4)
				hud_used.healths.icon_state = "health3"
			else if(shown_health_amount > maxHealth*0.2)
				hud_used.healths.icon_state = "health4"
			else if(shown_health_amount > 0)
				hud_used.healths.icon_state = "health5"
			else
				hud_used.healths.icon_state = "health6"
		else
			hud_used.healths.icon_state = "health7"

/mob/living/carbon/proc/update_internals_hud_icon(internal_state = 0)
	if(hud_used && hud_used.internals)
		hud_used.internals.icon_state = "internal[internal_state]"

/mob/living/carbon/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && !HAS_TRAIT(src, TRAIT_NODEATH))
			emote("deathgurgle")
			death()
			cure_blind(UNCONSCIOUS_BLIND)
			return
		if((blood_volume in -INFINITY to BLOOD_VOLUME_SURVIVE) || IsUnconscious() || IsSleeping() || getOxyLoss() > 75 || (HAS_TRAIT(src, TRAIT_DEATHCOMA)) || (health <= HEALTH_THRESHOLD_FULLCRIT && !HAS_TRAIT(src, TRAIT_NOHARDCRIT)))
			stat = UNCONSCIOUS
			become_blind(UNCONSCIOUS_BLIND)
			if(CONFIG_GET(flag/near_death_experience) && health <= HEALTH_THRESHOLD_NEARDEATH && !HAS_TRAIT(src, TRAIT_NODEATH))
				ADD_TRAIT(src, TRAIT_SIXTHSENSE, "near-death")
			else
				REMOVE_TRAIT(src, TRAIT_SIXTHSENSE, "near-death")
		else
			if(health <= crit_threshold && !HAS_TRAIT(src, TRAIT_NOSOFTCRIT))
				stat = SOFT_CRIT
			else
				stat = CONSCIOUS
			cure_blind(UNCONSCIOUS_BLIND)
			REMOVE_TRAIT(src, TRAIT_SIXTHSENSE, "near-death")
		update_mobility()
	update_damage_hud()
	update_health_hud()
//	update_tod_hud()
	update_spd()
	med_hud_set_status()

//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed()
	if(handcuffed)
//		drop_all_held_items()
		stop_pulling()
		throw_alert("handcuffed", /obj/screen/alert/restrained/handcuffed, new_master = src.handcuffed)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "handcuffed", /datum/mood_event/handcuffed)
	else
		clear_alert("handcuffed")
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "handcuffed")
	update_action_buttons_icon() //some of our action buttons might be unusable when we're handcuffed.
	update_inv_handcuffed()
	update_hud_handcuffed()
	update_mobility()

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	if(reagents)
		reagents.clear_reagents()
		for(var/addi in reagents.addiction_list)
			reagents.remove_addiction(addi)
	for(var/O in internal_organs)
		var/obj/item/organ/organ = O
		organ.setOrganDamage(0)
	var/obj/item/organ/brain/B = getorgan(/obj/item/organ/brain)
	if(B)
		B.brain_death = FALSE
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(D.severity != DISEASE_SEVERITY_POSITIVE)
			D.cure(FALSE)
	var/datum/component/rot/corpse/CR = GetComponent(/datum/component/rot/corpse)
	if(CR)
		CR.amount = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		for(var/datum/wound/D in BP.wounds)
			BP.wounds -= D
			qdel(D)
		if(BP.rotted && !BP.skeletonized) //reset rot when being healed by eating limbs
			BP.rotted = FALSE
			change_stat("constitution", 0, "rottenlimbs")
	if(mind?.has_antag_datum(/datum/antagonist/zombie))
		mind.remove_antag_datum(/datum/antagonist/zombie)
	if(admin_revive)
		suiciding = FALSE
		regenerate_limbs()
		regenerate_organs()
		handcuffed = initial(handcuffed)
		for(var/obj/item/restraints/R in contents) //actually remove cuffs from inventory
			qdel(R)
		update_handcuffed()
		if(reagents)
			reagents.addiction_list = list()
	cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
	..()
	// heal ears after healing traits, since ears check TRAIT_DEAF trait
	// when healing.
	restoreEars()

/mob/living/carbon/can_be_revived()
	. = ..()
	if(!getorgan(/obj/item/organ/brain) && (!mind || !mind.has_antag_datum(/datum/antagonist/changeling)))
		testing("norescarbon")
		return 0

/mob/living/carbon/harvest(mob/living/user)
	if(QDELETED(src))
		return
	var/organs_amt = 0
	for(var/X in internal_organs)
		var/obj/item/organ/O = X
		if(prob(50))
			organs_amt++
			O.Remove(src)
			O.forceMove(drop_location())
	if(organs_amt)
		to_chat(user, "<span class='notice'>I retrieve some of [src]\'s internal organs!</span>")

/mob/living/carbon/ExtinguishMob(itemz = TRUE)
	if(itemz)
		for(var/X in get_equipped_items())
			var/obj/item/I = X
			I.acid_level = 0 //washes off the acid on our clothes
			I.extinguish() //extinguishes our clothes
		var/obj/item/I = get_active_held_item()
		if(I)
			I.extinguish()
		I = get_inactive_held_item()
		if(I)
			I.extinguish()
	..()

/mob/living/carbon/fakefire(fire_icon = "Generic_mob_burning")
	var/mutable_appearance/new_fire_overlay = mutable_appearance('icons/mob/OnFire.dmi', fire_icon, -FIRE_LAYER)
	new_fire_overlay.appearance_flags = RESET_COLOR
	overlays_standing[FIRE_LAYER] = new_fire_overlay
	apply_overlay(FIRE_LAYER)

/mob/living/carbon/fakefireextinguish()
	remove_overlay(FIRE_LAYER)

/mob/living/carbon/proc/create_bodyparts()
	var/l_arm_index_next = -1
	var/r_arm_index_next = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/O = new X()
		O.owner = src
		bodyparts.Remove(X)
		bodyparts.Add(O)
		if(O.body_part == ARM_LEFT)
			l_arm_index_next += 2
			O.held_index = l_arm_index_next //1, 3, 5, 7...
			hand_bodyparts += O
		else if(O.body_part == ARM_RIGHT)
			r_arm_index_next += 2
			O.held_index = r_arm_index_next //2, 4, 6, 8...
			hand_bodyparts += O

/mob/living/carbon/do_after_coefficent()
	. = ..()
	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood) //Currently, only carbons or higher use mood, move this once that changes.
	if(mood)
		switch(mood.sanity) //Alters do_after delay based on how sane you are
			if(-INFINITY to SANITY_DISTURBED)
				. *= 1.25
			if(SANITY_NEUTRAL to INFINITY)
				. *= 0.90

/mob/living/carbon/proc/create_internal_organs()
	for(var/X in internal_organs)
		var/obj/item/organ/I = X
		I.Insert(src)

/mob/living/carbon/proc/update_disabled_bodyparts()
	for(var/B in bodyparts)
		var/obj/item/bodypart/BP = B
		BP.update_disabled()

/mob/living/carbon/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_AI, "Make AI")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_BODYPART, "Modify bodypart")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_ORGANS, "Modify organs")
	VV_DROPDOWN_OPTION(VV_HK_HALLUCINATION, "Hallucinate")
	VV_DROPDOWN_OPTION(VV_HK_MARTIAL_ART, "Give Martial Arts")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_TRAUMA, "Give Brain Trauma")
	VV_DROPDOWN_OPTION(VV_HK_CURE_TRAUMA, "Cure Brain Traumas")

/mob/living/carbon/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_MODIFY_BODYPART])
		if(!check_rights(R_SPAWN))
			return
		var/edit_action = input(usr, "What would you like to do?","Modify Body Part") as null|anything in list("add","remove", "augment")
		if(!edit_action)
			return
		var/list/limb_list = list()
		if(edit_action == "remove" || edit_action == "augment")
			for(var/obj/item/bodypart/B in bodyparts)
				limb_list += B.body_zone
			if(edit_action == "remove")
				limb_list -= BODY_ZONE_CHEST
		else
			limb_list = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			for(var/obj/item/bodypart/B in bodyparts)
				limb_list -= B.body_zone
		var/result = input(usr, "Please choose which body part to [edit_action]","[capitalize(edit_action)] Body Part") as null|anything in sortList(limb_list)
		if(result)
			var/obj/item/bodypart/BP = get_bodypart(result)
			switch(edit_action)
				if("remove")
					if(BP)
						BP.drop_limb()
					else
						to_chat(usr, "<span class='boldwarning'>[src] doesn't have such bodypart.</span>")
				if("add")
					if(BP)
						to_chat(usr, "<span class='boldwarning'>[src] already has such bodypart.</span>")
					else
						if(!regenerate_limb(result))
							to_chat(usr, "<span class='boldwarning'>[src] cannot have such bodypart.</span>")
				if("augment")
					if(ishuman(src))
						if(BP)
							BP.change_bodypart_status(BODYPART_ROBOTIC, TRUE, TRUE)
						else
							to_chat(usr, "<span class='boldwarning'>[src] doesn't have such bodypart.</span>")
					else
						to_chat(usr, "<span class='boldwarning'>Only humans can be augmented.</span>")
		admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [src]")
	if(href_list[VV_HK_MAKE_AI])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makeai"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MODIFY_ORGANS])
		if(!check_rights(NONE))
			return
		usr.client.manipulate_organs(src)
	if(href_list[VV_HK_MARTIAL_ART])
		if(!check_rights(NONE))
			return
		var/list/artpaths = subtypesof(/datum/martial_art)
		var/list/artnames = list()
		for(var/i in artpaths)
			var/datum/martial_art/M = i
			artnames[initial(M.name)] = M
		var/result = input(usr, "Choose the martial art to teach","JUDO CHOP") as null|anything in sortNames(artnames)
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "<span class='boldwarning'>Mob doesn't exist anymore.</span>")
			return
		if(result)
			var/chosenart = artnames[result]
			var/datum/martial_art/MA = new chosenart
			MA.teach(src)
			log_admin("[key_name(usr)] has taught [MA] to [key_name(src)].")
			message_admins("<span class='notice'>[key_name_admin(usr)] has taught [MA] to [key_name_admin(src)].</span>")
	if(href_list[VV_HK_GIVE_TRAUMA])
		if(!check_rights(NONE))
			return
		var/list/traumas = subtypesof(/datum/brain_trauma)
		var/result = input(usr, "Choose the brain trauma to apply","Traumatize") as null|anything in sortList(traumas, GLOBAL_PROC_REF(cmp_typepaths_asc))
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!result)
			return
		var/datum/brain_trauma/BT = gain_trauma(result)
		if(BT)
			log_admin("[key_name(usr)] has traumatized [key_name(src)] with [BT.name]")
			message_admins("<span class='notice'>[key_name_admin(usr)] has traumatized [key_name_admin(src)] with [BT.name].</span>")
	if(href_list[VV_HK_CURE_TRAUMA])
		if(!check_rights(NONE))
			return
		cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)
		log_admin("[key_name(usr)] has cured all traumas from [key_name(src)].")
		message_admins("<span class='notice'>[key_name_admin(usr)] has cured all traumas from [key_name_admin(src)].</span>")
	if(href_list[VV_HK_HALLUCINATION])
		if(!check_rights(NONE))
			return
		var/list/hallucinations = subtypesof(/datum/hallucination)
		var/result = input(usr, "Choose the hallucination to apply","Send Hallucination") as null|anything in sortList(hallucinations, GLOBAL_PROC_REF(cmp_typepaths_asc))
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(result)
			new result(src, TRUE)

/mob/living/carbon/can_resist()
	return bodyparts.len > 2 && ..()

/mob/living/carbon/proc/hypnosis_vulnerable()
	if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
		return FALSE
	if(hallucinating())
		return TRUE
	if(IsSleeping())
		return TRUE
	if(HAS_TRAIT(src, TRAIT_DUMB))
		return TRUE
	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
	if(mood)
		if(mood.sanity < SANITY_UNSTABLE)
			return TRUE
