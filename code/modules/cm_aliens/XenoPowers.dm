//Xenomorph Super - Colonial Marines - Apophis775 - Last Edit: 8FEB2015

//Their verbs are all actually procs, so we don't need to add them like 4 times copypaste for different species
//Just add the name to the caste's inherent_verbs() list

/mob/living/carbon/Xenomorph/proc/plant()
	set name = "Plant Weeds (75)"
	set desc = "Plants some alien weeds"
	set category = "Alien"

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(!is_weedable(T))
		src << "Bad place for a garden!"
		return

	if(locate(/obj/effect/alien/weeds/node) in T)
		src << "There's a pod here already.!"
		return

	if(check_plasma(75))
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] regurgitates a pulsating node and plants it on the ground!</B>"), 1)
		new /obj/effect/alien/weeds/node(loc)
		playsound(loc, 'sound/effects/splat.ogg', 30, 1) //splat!
	return

//Queen Verbs

/mob/living/carbon/Xenomorph/proc/lay_egg()

	set name = "Lay Egg (100)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(locate(/obj/effect/alien/egg) in get_turf(src) /*|| locate(/obj/royaljelly) in get_turf(src)*/) //Turn em off for now
		src << "There's already an egg or royal jelly here."
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "Your eggs wouldn't grow well enough here. Lay them on resin."
		return

	if(check_plasma(100)) //New plasma check proc, removes/updates plasma automagically
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] has laid an egg!</B>"), 1)
		new /obj/effect/alien/egg(T)
	return

//Runner Verbs

/mob/living/carbon/Xenomorph/proc/Pounce()
	set name = "Pounce (25)"
	set desc = "Pounce onto your prey."
	set category = "Alien"

	if(usedPounce)
		src << "\red We must wait before pouncing again.. Timer is at: \b[usedPounce] ticks."
		return

	if(check_plasma(25))
		var/targets[] = list()
		for(var/mob/living/carbon/human/M in oview())
			if(M.stat)	continue//Doesn't target corpses or paralyzed persons.
			targets.Add(M)

		if(targets.len)
			var/mob/living/carbon/human/target=pick(targets)
			var/atom/targloc = get_turf(target)
			if (!targloc || !istype(targloc, /turf) || get_dist(src.loc,targloc)>=3)
				src << "We cannot reach our prey!"
				return
			if(src.weakened >= 1 || src.paralysis >= 1 || src.stunned >= 1)
				src << "We cannot pounce if we are stunned.."
				return

			visible_message("\red <B>[src] pounces on [target]!</B>")
			if(src.m_intent == "walk")
				src.m_intent = "run"
				src.hud_used.move_intent.icon_state = "running"
			src.loc = targloc
			usedPounce = 5
			adjustToxLoss(-50)
			if(target.r_hand && istype(target.r_hand, /obj/item/weapon/shield/riot) || target.l_hand && istype(target.l_hand, /obj/item/weapon/shield/riot))
				if (prob(35))	// If the human has riot shield in his hand
					src.weakened = 5//Stun the fucker instead
					visible_message("\red <B>[target] blocked [src] with his shield!</B>")
				else
					src.canmove = 0
					src.frozen = 1
					target.Weaken(2)
					spawn(15)
						src.frozen = 0
			else
				src.canmove = 0
				src.frozen = 1
				target.Weaken(2)

			spawn(15)
				src.frozen = 0
		else
			src << "\red We sense no prey.."

	return

/mob/living/carbon/Xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	handle_ventcrawl()
	return

/mob/living/carbon/Xenomorph/proc/xenohide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\blue You are now hiding.")
	else
		layer = MOB_LAYER
		src << text("\blue You have stopped hiding.")

/mob/living/carbon/Xenomorph/proc/gut()
	set category = "Alien"
	set name = "Gut (100)"
	set desc = "While pulling someone, rip their guts out or tear them apart."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying)
		src << "\red You cannot do that in your current state."
		return

	var/mob/living/victim = src.pulling
	if(!victim || isnull(victim) || !istype(victim))
		src << "You're not pulling anyone that can be gutted."
		return

	var/turf/cur_loc = victim.loc
	if(!cur_loc) return //logic
	if(!cur_loc || !istype(cur_loc)) return

	if(!check_plasma(100))
		return

	last_special = world.time + 50

	visible_message("<span class='warning'><b>\The [src]</b> lifts [victim] into the air...</span>")
	if(do_after(src,60))
		if(!victim || isnull(victim)) return
		if(victim.loc != cur_loc) return
		visible_message("<span class='warning'><b>\The [src]</b> viciously wrenches [victim] apart!</span>")
		emote("roar")
		src.attack_log += text("\[[time_stamp()]\] <font color='red'>gibbed [victim.name] ([victim.ckey])</font>")
		victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>was gibbed by [src.name] ([src.ckey])</font>")
		victim.gib() //Splut


/mob/living/carbon/Xenomorph/proc/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach"
	set category = "Alien"

	if(stomach_contents.len)
		for(var/mob/M in src)
			if(M in stomach_contents)
				stomach_contents.Remove(M)
				M.loc = loc
		src.visible_message("\red <B>\The [src] hurls out the contents of their stomach!</B>")
	return

/mob/living/carbon/Xenomorph/proc/psychic_whisper(mob/M as mob in oview())
	set name = "Psychic Whisper"
	set desc = "Whisper silently to someone over a distance."
	set category = "Alien"

	var/msg = sanitize(input("Message:", "Psychic Whisper") as text|null)
	if(msg)
		log_say("PsychicWhisper: [key_name(src)]->[M.key] : [msg]")
		M << "\green You hear a strange, alien voice in your head... \italic [msg]"
		src << "\green You said: \"[msg]\" to [M]"
	return

/mob/living/carbon/Xenomorph/proc/transfer_plasma(mob/living/carbon/Xenomorph/M as mob in oview(1))
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien"
	set category = "Abilities"

	if (get_dist(src,M) <= 3)
		src << "\green You need to be closer."
		return

	var/amount = input("Amount:", "Transfer Plasma to [M]") as num
	if (amount)
		amount = abs(round(amount))
		if(storedplasma < amount)
			src << "You don't have that much. You only have: [storedplasma]."
			return
		storedplasma -= amount
		M.storedplasma += amount
		if(M.storedplasma > M.maxplasma) M.storedplasma = M.maxplasma
		M << "\green [src] has transfered [amount] plasma to you. You now have [M.storedplasma]."
		src << "\green You have transferred [amount] plasma to [M]. You now have [src.storedplasma]."
	return

/mob/living/carbon/Xenomorph/proc/build_resin() // -- TLE
	set name = "Secrete Resin (75)"
	set desc = "Secrete tough malleable resin."
	set category = "Abilities"

	var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin door","resin wall","resin membrane","resin nest")

	if(!choice)
		return

	if(!is_weedable(loc))
		src << "Bad place for a garden!"
		return

	var/turf/T = loc
	if(!T) //logic
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "You can only shape on weeds. Find some resin before you start building!"
		return

	if(locate(/obj/structure/mineral_door/resin) in T || locate(/obj/effect/alien/resin/wall) in T || locate(/obj/effect/alien/resin/membrane) in T || locate(/obj/structure/stool/bed/nest) in T )
		src << "There's something built here already."
		return

	if(!check_plasma(75))
		return

	src << "\green You shape a [choice]."
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>[src] vomits up a thick purple substance and begins to shape it!</B>"), 1)
	switch(choice)
		if("resin door")
			new /obj/structure/mineral_door/resin(T)
		if("resin wall")
			new /obj/effect/alien/resin/wall(T)
		if("resin membrane")
			new /obj/effect/alien/resin/membrane(T)
		if("resin nest")
			new /obj/structure/stool/bed/nest(T)
	return

/mob/living/carbon/Xenomorph/proc/corrosive_acid(O as obj|turf in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrosive Acid (200)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = "Abilities"

	if(!O in oview(1))
		src << "\green [O] is too far away."
		return

	// OBJ CHECK
	if(isobj(O))
		var/obj/I = O
		if(I.unacidable)	//So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
			src << "\green You cannot dissolve this object."
			return

	// TURF CHECK
	else if(istype(O, /turf/simulated))
		var/turf/T = O
		// R WALL
		if(istype(T, /turf/simulated/wall/r_wall))
			src << "\green You cannot dissolve this object."
			return
		// NO FLOORS! NONE!
		if(istype(T, /turf/simulated/floor) || istype(T,/turf/unsimulated/floor))
			src << "\green You cannot dissolve this object."
			return
		else// Not a type we can acid.
			return

	if(check_plasma(200))
		new /obj/effect/alien/acid(get_turf(O), O)
		visible_message("\green <B>[src] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</B>")

	return

/mob/living/carbon/Xenomorph/proc/neurotoxin(mob/target as mob in oview())
	set name = "Spit Neurotoxin (50)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time if they are not wearing protective gear."
	set category = "Abilities"

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You cannot spit neurotoxin in your current state."
		return

	if(!istype(target))
		return

	src << "\green You spit neurotoxin at [target]."
	if(!check_plasma(50))
		return

	for(var/mob/O in oviewers())
		if ((O.client && !(O.blinded )))
			O << "\red [src] spits neurotoxin at [target]!"

	//I'm not motivated enough to revise this. Prjectile code in general needs update.
	// Maybe change this to use throw_at? ~ Z
	var/turf/T = loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		usr.bullet_act(new /obj/item/projectile/energy/neurotoxin(usr.loc), get_organ_target())
		return
	if(!istype(U, /turf))
		return

	var/obj/item/projectile/energy/neurotoxin/A = new /obj/item/projectile/energy/neurotoxin(usr.loc)
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.process()
	return