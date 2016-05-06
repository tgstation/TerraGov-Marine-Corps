//Xenomorph General Procs And Functions - Colonial Marines

///mob/living/carbon/Xenomorph/gib(anim="gibbed-m",do_gibs)
//	return ..(anim="gibbed-a",do_gibs)

//First, dealing with alt-clicking vents.
/mob/living/carbon/Xenomorph/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)

	if(modifiers["alt"] && istype(A,/obj/machinery/atmospherics/unary/vent_pump))
		var/verb_path = /mob/living/carbon/Xenomorph/proc/vent_crawl
		if(verb_path in inherent_verbs)
			if(check_state())
				src.handle_ventcrawl(A)
			return
	else
		..()

//Send a message to all xenos. Mostly used in the deathgasp display
/proc/xeno_message(var/message = null, var/size = 3)
	if(!message)
		return

	if(ticker && ticker.mode.aliens.len) //Send to only xenos in our gamemode list. This is faster than scanning all mobs
		for(var/datum/mind/L in ticker.mode.aliens)
			var/mob/living/carbon/Xenomorph/M = L.current
			if(M && istype(M) && !M.stat && M.client) //Only living and connected xenos
				M << "\red <font size=[size]> [message]</font>"


//Adds stuff to your "Status" pane -- Specific castes can have their own, like carrier hugger count
//Those are dealt with in their caste files.
/mob/living/carbon/Xenomorph/Stat()
	..()
	if(jelly)
		stat(null, "Jelly Progress: [jellyGrow]/[jellyMax]")

	if(maxplasma > 0)
		if(is_robotic)
			stat(null, "Charge: [storedplasma]/[maxplasma]")
		else
			stat(null, "Plasma: [storedplasma]/[maxplasma]")

	if(slashing_allowed == 1)
		stat(null,"Slashing of hosts is currently: PERMITTED.")
	else if(slashing_allowed == 2)
		stat(null,"Slashing of hosts is currently: ONLY WHEN NEEDED.")
	else
		stat(null,"Slashing of hosts is currently: NOT ALLOWED.")

	if(frenzy_aura)
		stat(null,"You are affected by a pheromone of FRENZY.")
	if(guard_aura)
		stat(null,"You are affected by a pheromone of GUARDING.")
	if(recovery_aura)
		stat(null,"You are affected by a pheromone of RECOVERY.")

	if(hive_orders && hive_orders != "")
		stat(null,"Hive Orders: [hive_orders]")

	return

//A simple handler for checking your state. Used in pretty much all the procs.
/mob/living/carbon/Xenomorph/proc/check_state()
	if(!istype(src,/mob/living/carbon/Xenomorph) || isnull(src)) //somehow
		return 0

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You cannot do this in your current state."
		return 0

	return 1

//Checks your plasma levels, removes them accordingly, and gives a handy message.
/mob/living/carbon/Xenomorph/proc/check_plasma(var/value)
	if(stat)
		src << "\red Can't do this while unconcious."
		return 0

	if(value)
		if(is_robotic)
			if(storedplasma < value)
				src << "\red Beep. Insufficient charge. You require [value] but have only [storedplasma]."
				return 0
		if(storedplasma < value)
			src << "\red Insufficient plasma. You require [value] but have only [storedplasma]."
			return 0

		storedplasma -= value
	return 1 //If plasma cost is 0 just go ahead and do it


//Check if you can plant on groundmap turfs.
//Does NOT return a message, just a 0 or 1.
/mob/living/carbon/Xenomorph/proc/is_weedable(turf/T)
	if(isnull(T) || !isturf(T)) return 0
	if(istype(T,/turf/space)) return 0
	if(istype(T,/turf/unsimulated/floor/gm/grass) || istype(T,/turf/unsimulated/floor/gm/dirtgrassborder) || istype(T,/turf/unsimulated/floor/gm/river) || istype(T,/turf/unsimulated/floor/gm/coast)) return 0
	return 1

//Strip all inherent xeno verbs from your caste. Used in evolution.
/mob/living/carbon/Xenomorph/proc/remove_inherent_verbs()
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			verbs -= verb_path
	return

//Add all your inherent caste verbs and procs. Used in evolution.
/mob/living/carbon/Xenomorph/proc/add_inherent_verbs()
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			verbs |= verb_path
	return


	return

/* OBSOLETE -- This is handled in Life() now
/mob/living/carbon/Xenomorph/proc/growJelly()//Grows the delicious Jelly 08FEB2015
	spawn while (1)
		if(jelly)
			if(jellyGrow<jellyMax)
				jellyGrow++
			sleep(10)

/mob/living/carbon/Xenomorph/proc/canEvolve()//Determines if they alien can evolve 08FEB2015
	if(!jelly)
		return 0
	if(jellyGrow < jellyMax)
		return 0
	return 1
*/
//Adds or removes a delay to movement based on your caste. If speed = 0 then it shouldn't do much.
//Runners are -2, -4 is BLINDLINGLY FAST, +2 is fat-level
/mob/living/carbon/Xenomorph/movement_delay()

	if(stat)
		return 0 //Shouldn't really matter, but still calculates if we're being dragged.

	var/tally = 0

	tally = speed

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	if(istype(loc,/turf/unsimulated/floor/gm/river)) //Rivers slow you down
		if(istype(src,/mob/living/carbon/Xenomorph/Boiler))
			tally -= 0.5
		else
			tally += 1.3

	if(istype(src,/mob/living/carbon/Xenomorph/Hivelord))
		if(src:speed_activated)
			if(locate(/obj/effect/alien/weeds) in src.loc)
				tally -= 1.5

	if(istype(loc,/turf/unsimulated/floor/snow)) //Snow slows you down
		var/turf/unsimulated/floor/snow/S = src.loc
		if(S && istype(S) && S.slayer > 0)
			tally += 0.5 * S.slayer
			if(S.slayer && prob(1))
				src << "\red Moving through [S] slows you down!"

			if(S.slayer == 3 && prob(5))
				src << "\red You got stuck in [S] for a moment!"
				tally += 10

	if(frenzy_aura)
		tally = tally - (frenzy_aura * 0.1) - 0.4

	if(src.pulling)  //Dragging stuff slows you down a bit.
		tally += 3

	if(istype(src,/mob/living/carbon/Xenomorph/Crusher)) //Handle crusher stuff.
		var/mob/living/carbon/Xenomorph/Crusher/X = src
		X.charge_timer = 2
		if(X.momentum == 0)
			X.charge_dir = dir
			X.handle_momentum()
		else
			if(X.charge_dir != dir) //Have we changed direction?
				X.stop_momentum() //This should disallow rapid turn bumps
			else
				X.handle_momentum()
		X.lastturf = get_turf(X)

	return (tally)

//These don't do much currently. Or anything? Only around for legacy code.
/mob/living/carbon/Xenomorph/restrained()
	return 0

/mob/living/carbon/Xenomorph/can_use_vents()
	return 1

/mob/living/carbon/Xenomorph/proc/update_progression()
	return

/mob/living/carbon/Xenomorph/show_inv(mob/user as mob)
	return
/*
/obj/item/projectile/energy/neuro
	name = "spit"
	icon_state = "neurotoxin"
	damage = 1
	damage_type = TOX
	weaken = 4
	skips_xenos = 1
	accuracy = 150 //Rarely misses.
	kill_count = 8

/obj/item/projectile/energy/neuro/strong
	damage = 5
	weaken = 6
	accuracy = 170 //Rarely misses.

/obj/item/projectile/energy/neuro/strongest
	damage = 10
	weaken = 8
	accuracy = 250 //Rarely misses.

/obj/item/projectile/energy/neuro/robot
	damage = 50
	weaken = 6
	icon_state = "pulse1"
	damage_type = BURN

/obj/item/projectile/energy/neuro/acid
	damage = 15
	name = "acid"
	icon_state = "declone"
	damage_type = BURN
	accuracy = 200

	on_hit(var/atom/target, var/blocked = 0)
		aoe_spit(target)
		return 1

	proc/aoe_spit(var/atom/target) //Doesn't actually do AoE anymore, just splatters
		var/turf/T = get_turf(target)
		if(istype(target,/mob/living/carbon/Xenomorph)) return
		if(isnull(T) || isnull(target)) return

		new /obj/effect/xenomorph/splatter(T) //do a splatty splat
		playsound(src.loc, 'sound/effects/blobattack.ogg', 50, 1)

/obj/item/projectile/energy/neuro/acid/heavy
	damage = 25
*/
//Xeno-style acids
//Ideally we'll consolidate all the "effect" objects here
//Also need to change the icons
/obj/effect/xenomorph
	name = "alien thing"
	desc = "You shouldn't be seeing this."
	icon = 'icons/Xeno/effects.dmi'
	unacidable = 1

/obj/effect/xenomorph/splatter
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "splatter"
	density = 0
	opacity = 0
	anchored = 1
	layer = 4.1

	New() //Self-deletes after creation & animation
		spawn(8)
			del(src)
			return

/obj/effect/xenomorph/splatterblob
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "acidblob"
	density = 0
	opacity = 0
	anchored = 1
	layer = 5

	New() //Self-deletes after creation & animation
		spawn(40)
			del(src)
			return

/obj/effect/xenomorph/spray
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "acid2"
	density = 0
	opacity = 0
	anchored = 1
	layer = 3.1
	mouse_opacity = 0

	New() //Self-deletes
		spawn(100 + rand(0,20))
			processing_objects.Remove(src)
			del(src)
			return

	Crossed(AM as mob|obj)
		..()
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			var/chance = 100
			if(H.shoes) chance = 40
			if(prob(chance))
				if(!H.lying)
					H << "\green Your feet burn! Argh!"
					if(prob(chance))
						H.emote("scream")
					if(prob(chance / 2))
						H.Weaken(2)
					var/datum/organ/external/affecting = H.get_organ("l_foot")
					if(istype(affecting) && affecting.take_damage(0, rand(5,10)))
						H.UpdateDamageIcon()
					affecting = H.get_organ("r_foot")
					if(istype(affecting) && affecting.take_damage(0, rand(5,10)))
						H.UpdateDamageIcon()
					H.updatehealth()
				else
					H.adjustFireLoss(rand(3,10))
					H.show_message(text("\green You are burned by acid!"),1)

	process()
		var/turf/simulated/T = src.loc
		if(!istype(T))
			processing_objects.Remove(src)
			del(src)
			return

		for(var/mob/living/carbon/M in loc)
			if(isXeno(M)) continue
			src.Crossed(M)

//Medium-strength acid
/obj/effect/xenomorph/acid
	name = "acid"
	desc = "Burbling corrosive stuff. I wouldn't want to touch it."
	icon_state = "acid"
	density = 0
	opacity = 0
	anchored = 1
	layer = 5 //Should be on top of most things

	var/atom/target
	var/ticks = 0
	var/target_strength = 0
	var/acid_strength = 100 //100% speed, normal

//Sentinel weakest acid
/obj/effect/xenomorph/acid/weak
	name = "weak acid"
	acid_strength = 250 //250% normal speed

//Superacid
/obj/effect/xenomorph/acid/strong
	name = "strong acid"
	acid_strength = 40 //20% normal speed

/obj/effect/xenomorph/acid/New(loc, target)
	..(loc)
	src.target = target

	if(isturf(target)) // Turf take twice as long to take down.
		target_strength = 8
	else
		target_strength = 4
	tick()

/obj/effect/xenomorph/acid/proc/tick()
	if(!target || isnull(target))
		del(src)
		return

	if(!src) //Woops, abort
		return

	if(isturf(target.loc) && src.loc != target.loc)
		src.loc = target.loc

	var/tick_timer = rand(200,300) * acid_strength / 100 //Acid strength is just a percentage of time between ticks

	ticks += 1

	if(ticks >= target_strength)

		for(var/mob/O in hearers(src, null))
			O.show_message("\green <B>[src.target] collapses under its own weight into a puddle of goop and undigested debris!</B>", 1)

		if(istype(target, /turf/simulated/wall)) // I hate turf code.
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			if(target.contents) //Hopefully won't auto-delete things inside melted stuff..
				for(var/atom/movable/S in target)
					if(S in target.contents && !isnull(get_turf(target)))
						S.loc = get_turf(target)

			if(istype(target,/turf)) //We don't want space tiles appearing everywhere... but this sucks!
				var/turf/T = target
				T.ChangeTurf(/turf/simulated/floor/plating)
			else
				del(target)
		del(src)
		return

	switch(target_strength - ticks)
		if(6)
			visible_message("\green <B>[src.target] is holding up against the acid!</B>")
		if(4)
			visible_message("\green <B>[src.target]\s structure is being melted by the acid!</B>")
		if(2)
			visible_message("\green <B>[src.target] is struggling to withstand the acid!</B>")
		if(0 to 1)
			visible_message("\green <B>[src.target] begins to crumble under the acid!</B>")
	spawn(tick_timer)
		tick()

//This deals with "throwing" xenos -- ravagers, hunters, and runners in particular. Everyone else defaults to normal
//Pounce, charge both use throw_at, so we need extra code to do stuff rather than just push people aside.
/mob/living/carbon/Xenomorph/throw_impact(atom/hit_atom, var/speed)

	if(!charge_type || stat || !usedPounce) //0: No special charge. 1: pounce, 2: claw. Can add new ones here. Check if alive.
		..()
		return

	if(isobj(hit_atom)) //Deal with smacking into dense objects. This overwrites normal throw code.
		var/obj/O = hit_atom
		if(!O.density) //Not a dense object? Doesn't matter then, pass over it.
			..()
			return

		if(!O.anchored)
			step(O,src.dir) //Not anchored? Knock the object back a bit. Ie. canisters.

		if(istype(src,/mob/living/carbon/Xenomorph/Ravager)) //Ravagers destroy tables.
			if(istype(O,/obj/structure/table) || istype(O,/obj/structure/rack))
				var/obj/structure/S = O
				visible_message("<span class='danger'>[src] plows straight through the [S.name]!</span>")
				S.destroy()
				O = null

		if(!isnull(O) && !istype(O,/obj/structure/table) && O.density && O.anchored && !istype(O,/obj/item)) // new - xeno charge ignore tables
			O.hitby(src,speed)
			src << "Bonk!" //heheh. Smacking into dense objects stuns you slightly.
			src.Weaken(2)
		return

	if(ismob(hit_atom)) //Hit a mob! This overwrites normal throw code.
		var/mob/living/carbon/V = hit_atom
		if(istype(V) && !V.stat && !istype(V,/mob/living/carbon/Xenomorph)) //We totally ignore other xenos. LIKE GREASED WEASELS
			if(istype(V,/mob/living/carbon/human) && charge_type != 2)
				var/mob/living/carbon/human/H = V //Human shield block.
				if((H.r_hand && istype(H.r_hand, /obj/item/weapon/shield/riot)) || (H.l_hand && istype(H.l_hand, /obj/item/weapon/shield/riot)))
					if (prob(45))	// If the human has riot shield in his hand,  65% chance
						src.Weaken(4) //Stun the fucker instead
						visible_message("\red <B> \The [src] bounces off [H]'s shield!</B>", "\red <B>You bounce off [src]'s shield!</B>")
						src.throwing = 0
						return

				if(H.species && H.species.name == "Yautja" && prob(40))
					visible_message("\red <b>[H] emits a roar and body slams \the [src]!</B>","\red <B>[H] emits a roar and body slams you!</b>")
					src.Weaken(4)
					src.throwing = 0
					return

			if(charge_type == 2) //Ravagers get a free attack if they charge into someone. This will tackle if disarm is set instead
				V.attack_alien(src)
				V.Weaken(2)
				src.throwing = 0

			if(charge_type == 1) //Runner/hunter pounce.
				visible_message("\red \The [src] pounces on [V]!","You pounce on [V]!")
				V.Weaken(4)
				src.canmove = 0
				src.frozen = 1
				src.loc = V.loc
				src.throwing = 0 //Stop the movement
				if(!is_robotic)
					playsound(src.loc, 'sound/voice/alien_pounce.ogg', 50, 1)
				spawn(20)
					src.frozen = 0
		return

	if(isturf(hit_atom))
		var/turf/T = hit_atom
		if(T.density)
			src << "Bonk!" //ouchie
			src.Weaken(2)

	..() //Do the rest normally - mostly turfs.
	return


//Bleuugh
/mob/living/carbon/Xenomorph/proc/empty_gut()
	if(stomach_contents.len)
		for(var/S in src.stomach_contents)
			if(S)
				stomach_contents.Remove(S)
				S:loc = get_turf(src)

	if(contents.len) //Get rid of anything that may be stuck inside us as well
		for(var/A in src.contents)
			if(A)
				src.contents.Remove(A)
				A:loc = get_turf(src)

	return

/mob/living/carbon/Xenomorph/verb/toggle_darkness()
	set name = "Toggle Darkvision"
	set category = "Alien"

	if (see_invisible == SEE_INVISIBLE_MINIMUM)
		see_invisible = SEE_INVISIBLE_LEVEL_TWO //Turn it off.
		see_in_dark = 4
		sight |= SEE_MOBS
		sight &= ~SEE_TURFS
		sight &= ~SEE_OBJS
	else
		see_invisible = SEE_INVISIBLE_MINIMUM
		see_in_dark = 8
		sight |= SEE_MOBS

//Random bite attack. Procs more often on downed people. Returns 0 if the check fails.
//Does a LOT of damage.
/mob/living/carbon/Xenomorph/proc/check_bite(var/mob/living/carbon/human/M)
	if(!M || !istype(M)) return 0
	if(!bite_chance) return 0 //does not have a bite attack

	var/chance = bite_chance
	var/dmg = rand(melee_damage_lower,melee_damage_upper) + 20

	if(M.lying) chance += 10
	if(M.head) chance -= 5 //Helmet? Less likely to bite, even if not all bites target head.

	if(rand(0,100) > chance) return 0 //Failed the check, get out

	var/datum/organ/external/affecting
	affecting = M.get_organ(ran_zone("head",50))
	if(!affecting) //No head? Just get a random one
		affecting = M.get_organ(ran_zone(null,0))
	if(!affecting) //Still nothing??
		affecting = M.get_organ("chest") // Gotta have a torso?!
	var/armor_block = M.run_armor_check(affecting, "melee")

	playsound(loc, 'sound/weapons/bite.ogg', 100, 1, -1)
	visible_message("<span class = 'warning'>[M] is viciously shredded by \the [src]'s sharp teeth!</span>","<span class='warning'>You viciously rend [M] with your teeth!</span>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>bit [src.name] ([src.ckey])</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was bitten by [M.name] ([M.ckey])</font>")

	M.apply_damage(dmg, BRUTE, affecting, armor_block, sharp=1) //This should slicey dicey
	M.updatehealth()

	return 1

//Tail stab. Checked during a slash, after the above.
//Deals a monstrous amount of damage based on how long it's been charging, but charging it drains plasma.
//Toggle is in XenoPowers.dm.
/mob/living/carbon/Xenomorph/proc/check_tail_attack(var/mob/living/carbon/human/M)
	if(!M || !istype(M)) return 0

	if(!readying_tail || readying_tail == -1) return 0 //Tail attack not prepared, or not available.

	var/dmg = (round(readying_tail * 2.5)) + rand(5,10) //Ready max is 20
	if(adjust_pixel_x) //Big xenos get a damage bonus.
		dmg += 10
	var/datum/organ/external/affecting
	var/tripped = 0

	if(M.lying) dmg += 10 //more damage when hitting downed people.

	affecting = M.get_organ(ran_zone(zone_sel.selecting,75))
	if(!affecting) //No organ, just get a random one
		affecting = M.get_organ(ran_zone(null,0))
	if(!affecting) //Still nothing??
		affecting = M.get_organ("chest") // Gotta have a torso?!
	var/armor_block = M.run_armor_check(affecting, "melee")

	var/miss_chance = 15
	if(istype(src,/mob/living/carbon/Xenomorph/Hivelord)) miss_chance += 20 //Fuck hivelords
	if(prob(miss_chance))
		playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
		visible_message("<span class = 'warning'>\The [src] lashes out with its tail but <b>misses</b> [M]!","<span class='warning'>You snap your tail out but <b>miss</b> [M]!</span>")
		readying_tail = 0
		return

	//Selecting feet? Drop the damage and trip them.
	if(zone_sel.selecting == "r_leg" || zone_sel.selecting == "l_leg" || zone_sel.selecting == "l_foot" || zone_sel.selecting == "r_foot")
		if(prob(60) && !M.lying)
			playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
			visible_message("<span class = 'warning'>\The [src] lashes out with its tail and [M] goes down!</span>","<span class='warning'><b>You snap your tail out and trip [M]!</span></b>")
			M.Weaken(5)
			dmg = dmg / 2 //Half damage for a tail strike.
			tripped = 1

	playsound(loc, 'sound/weapons/wristblades_hit.ogg', 50, 1, -1) //Stolen from Yautja! Owned!
	if(!tripped) visible_message("<span class = 'warning'><b>[M] is suddenly impaled by \the [src]'s sharp tail!</span>","<span class='warning'><b>You violently impale [M] with your tail!</span></b>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>tail-stabbed [src.name] ([src.ckey])</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was tail-stabbed by [M.name] ([M.ckey])</font>")

	M.apply_damage(dmg, BRUTE, affecting, armor_block, sharp=1, edge=1) //This should slicey dicey
	M.updatehealth()
	readying_tail = 0
	return 1

/mob/living/carbon/Xenomorph/proc/zoom_in(var/tileoffset = 5, var/viewsize = 12)
	if(stat)
		if(is_zoomed)
			is_zoomed = 0
			zoom_out()
			return
		return
	if(is_zoomed) return
	if(!client) return
	if(!src.hud_used.hud_shown)
		src.button_pressed_F12(1)	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
	src.button_pressed_F12(1)
	zoom_turf = get_turf(src)
	is_zoomed = 1
	client.view = viewsize
	var/viewoffset = 32 * tileoffset
	switch(dir)
		if (NORTH)
			client.pixel_x = 0
			client.pixel_y = viewoffset
		if (SOUTH)
			client.pixel_x = 0
			client.pixel_y = -viewoffset
		if (EAST)
			client.pixel_x = viewoffset
			client.pixel_y = 0
		if (WEST)
			client.pixel_x = -viewoffset
			client.pixel_y = 0
	return

/mob/living/carbon/Xenomorph/proc/zoom_out()
	if(!client)
		return
	if(!src.hud_used.hud_shown)
		src.button_pressed_F12(1)
	client.view = world.view
	client.pixel_x = 0
	client.pixel_y = 0
	is_zoomed = 0
	if(istype(src,/mob/living/carbon/Xenomorph/Boiler))
		src:zoom_timer = 0
	zoom_turf = null
	return
