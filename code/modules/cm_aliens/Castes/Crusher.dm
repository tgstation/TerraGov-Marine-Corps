
/mob/living/carbon/Xenomorph/Crusher
	caste = "Crusher"
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Crusher Walking"
	melee_damage_lower = 12
	melee_damage_upper = 22
	tacklemin = 4
	tacklemax = 7
	tackle_chance = 95
	health = 240
	maxHealth = 240
	storedplasma = 200
	plasma_gain = 10
	maxplasma = 200
	jellyMax = 0
	caste_desc = "A huge tanky xenomorph."
	speed = 0.5
	evolves_to = list()
	armor_deflection = 70
	var/charge_dir = 0
	var/momentum = 0 //Builds up charge based on movement.
	var/charge_timer = 0 //Has a small charge window. has to keep moving to build momentum.
	var/turf/lastturf = null
	var/noise_timer = 0 // Makes a mech footstep, but only every 3 turfs.
	var/has_moved = 0
	big_xeno = 1
	var/is_charging = 1

	adjust_pixel_x = -16
	adjust_pixel_y = -3

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/Crusher/proc/stomp,
		/mob/living/carbon/Xenomorph/Crusher/proc/ready_charge
		)

/mob/living/carbon/Xenomorph/Crusher/Stat()
	..()
	stat(null, "Momentum: [momentum]")


/mob/living/carbon/Xenomorph/Crusher/proc/stop_momentum(var/direction, var/stunned = 0)
	if(momentum < 0) //Somehow. Could happen if you slam into multiple things
		momentum = 0

	if(!momentum)
		return

	if(!isturf(src.loc)) //Messed up
		speed = initial(speed)
		momentum = 0
		return

	if(stunned && momentum > 24)
		Weaken(2)
		src.visible_message("<b>[src] skids to a halt!</b>","<b>You skid to a halt.</B>")
	pass_flags = 0
	momentum = 0
	speed = initial(speed)
	update_icons()
	return



/mob/living/carbon/Xenomorph/Crusher/proc/handle_momentum()
	if(throwing)
		return

	if(stat || pulledby || !loc || !isturf(loc))
		stop_momentum(charge_dir)
		return

	if(lastturf)
		if(loc == lastturf || loc.z != lastturf.z)
			stop_momentum(charge_dir)
			return

	if(dir != charge_dir || src.m_intent == "walk" || istype(src.loc,/turf/unsimulated/floor/gm/river))
		stop_momentum(charge_dir)
		return

	charge_dir = dir

	if(!is_charging)
		stop_momentum(charge_dir)
		return

	if(pulling && momentum > 12)
		stop_pulling()

	if(speed > -2.6)
		speed -= 0.2 //Speed increases each step taken. At 30 tiles, maximum speed is reached.

	if(momentum <= 18)	 //Maximum 30 momentum.
		momentum += 3 //2 per turf. Max speed in 15.

	else if(momentum > 18 && momentum < 25)
		momentum += 2

	else if(momentum >= 25 && momentum < 30)
		momentum++ //Increases slower at high speeds so we don't go LAZERFAST

	if(momentum < 0)
		momentum = 0

	if(storedplasma > 5)
		storedplasma -= round(momentum / 10) //eats up some plasma. max -3
	else
		stop_momentum(charge_dir)
		return

	if(charge_dir != dir) //Still not facing? What the heck!
		return

	//Some flavor text.
	if(momentum == 10)
		src << "<b>You begin churning up the ground with your charge!</b>"
	else if(momentum == 20)
		src << "<b>The ground begins to shake as you run!</b>"
	else if (momentum == 28) //Not 30, since it's max
		src << "\red <b>You have achieved maximum momentum!</b>"
		emote("roar")

	if(noise_timer)
		noise_timer--
	else
		noise_timer = 3

	if(noise_timer == 3 && momentum > 10)
		playsound(loc, 'sound/mecha/mechstep.ogg', 50 + (momentum), 0)

	for(var/mob/living/carbon/M in view(8))
		if(M && M.client && get_dist(M,src) <= round(momentum / 5) && src != M && momentum > 5)
			if(!isXeno(M))
				shake_camera(M, 1, 1)
		if(M && M.lying && M.loc == src.loc && !isXeno(M) && M.stat != DEAD && momentum > 6)
			visible_message("<span class ='warning'>[src] runs over [M]!","\red <B>You run over [M]!</b>")
			M.take_overall_damage(momentum * 2)

	if(isturf(loc) && !istype(loc,/turf/space)) //Set their turf, to make sure they're moving and not jumped in a locker or some shit
		lastturf = loc
	else
		lastturf = null
	update_icons()
	return

proc/diagonal_step(var/atom/movable/A, var/direction, var/probab = 75)
	if(!A) return
	if(direction == EAST || direction == WEST && prob(probab))
		if(prob(50))
			step(A,NORTH)
		else
			step(A,SOUTH)
	else if (direction == NORTH || direction == SOUTH && prob(probab))
		if(prob(50))
			step(A,EAST)
		else
			step(A,WEST)
	return

//Custom bump for crushers. This overwrites normal bumpcode from carbon.dm
/mob/living/carbon/Xenomorph/Crusher/Bump(atom/AM as mob|obj|turf, yes)
	spawn(0)
		var/start_loc

		if(src.stat || src.momentum < 3 || !AM || !istype(AM) || AM == src || !yes)
			return

		if(now_pushing) //Just a plain ol turf, let's return.
			return

		if(dir != charge_dir) //We aren't facing the way we're charging.
			stop_momentum()
			return ..()

		now_pushing = 1

		if(istype(AM,/obj/item)) //Small items (ie. bullets) are unaffected.
			var/obj/item/obj = AM
			if(obj.w_class < 3)
				now_pushing = 0
				return

		if(istype(AM,/obj/structure/table))
			now_pushing = 0
			AM:Crossed(src)
			return 0

		start_loc = AM.loc
		if (isobj(AM) && AM.density) //Generic dense objects that aren't tables.
			if(AM:anchored)
				if(momentum < 16)
					now_pushing = 0
					return ..()
				else
					if (istype(AM,/obj/structure/window) && momentum > 5)
						AM:hit((momentum * 4) + 10) //Should generally smash it unless not moving very fast.
						momentum -= 2
						now_pushing = 0
						return //Might be destroyed.

					if (istype(AM,/obj/structure/grille))
						AM:health -= (momentum * 3) //Usually knocks it down.
						AM:healthcheck()
						now_pushing = 0
						return //Might be destroyed.

					if(istype(AM,/obj/structure/m_barricade) && AM.dir == reverse_direction(dir))
						if(momentum > 10)
							var/obj/structure/m_barricade/M = AM
							M.health -= (momentum * 4)
							playsound(loc, "punch", 100, 1, -1)
							visible_message("\red The [src] smashes straight into [M]!")
							M.update_health()
							src << "\red Bonk!"
							Weaken(2)
							stop_momentum(charge_dir,1)
							now_pushing = 0
							return
						else
							return ..()

					if(istype(AM,/obj/machinery/vending))
						if(momentum > 20)
							visible_message("\red The [src] smashes straight into the [AM]!")
							playsound(loc, "punch", 100, 1, -1)
							src << "\red Bonk!"
							stop_momentum(charge_dir,1)
							Weaken(2)
							now_pushing = 0
							AM:tip_over()
							diagonal_step(AM,dir,50)//Occasionally fling it diagonally.
							step_away(AM,src)
							step_away(AM,src)
							return

					if(istype(AM,/obj/structure/barricade/wooden))
						if(momentum > 8)
							var/obj/structure/S = AM
							visible_message("<span class='danger'>[src] plows straight through the [S.name]!</span>")
							S.destroy()
							momentum -= 3
							now_pushing = 0
							return //Might be destroyed, so we stop here.
						else
							now_pushing = 0
							return

					if(istype(AM,/obj/structure/barricade/snow))
						if(momentum > 8)
							var/obj/structure/S = AM
							visible_message("<span class='danger'>[src] plows straight through the [S.name]!</span>")
							del(S)
							momentum -= 3
							now_pushing = 0
							return //Might be destroyed, so we stop here.
						else
							now_pushing = 0
							return

					if(istype(AM,/obj/mecha))
						var/obj/mecha/mech = AM
						mech.take_damage(momentum * 8)
						visible_message("<b>[src] rams into [AM]!</b>","<b>You ram into [AM]!</b>")
						playsound(loc, "punch", 50, 1, -1)
						if(momentum > 25)
							diagonal_step(mech,dir,50)//Occasionally fling it diagonally.
							step_away(mech,src)
						Weaken(2)
						stop_momentum(charge_dir,1)
						now_pushing = 0
						return
					if(istype(AM,/obj/machinery/marine_turret))
						var/obj/machinery/marine_turret/turret = AM
						visible_message("<b>[src] rams into [AM]!</b>","<b>You ram into [AM]!</b>")
						playsound(loc, "punch", 70, 1, -1)
						if(momentum > 10)
							if(prob(70+momentum))
								turret.stat = 1
								turret.on = 0
								turret.update_icon()
						turret.update_health(momentum * 2)
						if(!isnull(turret))
							src << "\red Bonk!"
							Weaken(3)
							stop_momentum(charge_dir,1)
							now_pushing = 0
						return
					if(AM:unacidable)
						src << "\red Bonk!"
						Weaken(2)
						if(momentum > 26)
							stop_momentum(charge_dir)
						now_pushing = 0
						return
					if(momentum > 20)
						visible_message("<b>[src] crushes [AM]!</b>","<b>You crush [AM]!</b>")
						if(AM.contents) //Hopefully won't auto-delete things inside crushed stuff..
							for(var/atom/movable/S in AM)
								if(S in AM.contents && !isnull(get_turf(AM)))
									S.loc = get_turf(AM)
							spawn(0)
								del(AM)
					now_pushing = 0
					return
			if(momentum > 5)
				visible_message("[src] knocks aside [AM]!","You casually knock aside [AM].") //Canisters, crates etc. go flying.
				playsound(loc, "punch", 25, 1, -1)
				diagonal_step(AM,dir)//Occasionally fling it diagonally.
				step_away(AM,src,round(momentum/10) +1)
				now_pushing = 0
				return

		if(istype(AM,/mob/living/carbon/Xenomorph))
			if(momentum > 6)
				playsound(loc, "punch", 25, 1, -1)
				diagonal_step(AM,dir,100)//Occasionally fling it diagonally.
				step_away(AM,src) //GET OUTTA HERE
				now_pushing = 0
				return
			else
				now_pushing = 0
				return ..() //Just shove normally.

		if(istype(AM,/mob/living/carbon) && momentum > 7)
			var/mob/living/carbon/H = AM
			playsound(loc, "punch", 25, 1, 1)
			if(momentum < 12 && momentum > 7)
				H.Weaken(2)
			else if(momentum < 20)
				H.Weaken(6)
				H.apply_damage(momentum,BRUTE)
			else if (momentum >= 20)
				H.Weaken(8)
				H.take_overall_damage(momentum * 2)
			diagonal_step(H,dir, 100)//Occasionally fling it diagonally.
			step_away(H,src,round(momentum / 10))
			visible_message("<B>[src] rams into [H]!</b>","<B>You ram into [H]!</B>")
			now_pushing = 0
			return

		if(isturf(AM) && AM.density) //We were called by turf bump.
			if(momentum <= 25 && momentum > 14)
				src << "\red Bonk!"
				stop_momentum(charge_dir,1)
				src.Weaken(3)
			if(momentum > 26)
				AM:ex_act(2) //Should dismantle, or at least heavily damage it.

			if(!isnull(AM) && momentum > 20)
				stop_momentum(charge_dir,1)
			now_pushing = 0
			return

		if(AM) //If the object still exists.
			if(AM.loc == start_loc) //And hasn't moved
				now_pushing = 0
				return ..() //Bump it normally.
		//Otherwise, just get out
		now_pushing = 0
		return

/mob/living/carbon/Xenomorph/Crusher/proc/stomp()
	set name = "Stomp (50)"
	set desc = "Strike the earth!"
	set category = "Alien"

	if(!check_state()) return

	if(has_screeched) //Sure, let's use this.
		src << "\red You are not yet prepared to shake the ground."
		return

	if(!check_plasma(50))
		return

	has_screeched = 1
	spawn(500) //50 seconds
		has_screeched = 0
		src << "You feel ready to shake the earth again."

	playsound(loc, 'sound/effects/bang.ogg', 50, 0, 100, -1)
	visible_message("\red <B> \The [src] smashes the ground!</B>","\red <b>You smash the ground!</b>")
	create_shriekwave() //Adds the visual effect. Wom wom wom
	for (var/mob/living/carbon/human/M in oview())
		var/dist = get_dist(src,M)
		if(M && M.client && dist < 6)
			shake_camera(M, 5, 1)
		if (dist < 3 && !M.lying && !M.stat && prob(75))
			M << "<span class='warning'><B>The earth moves beneath your feet!</span></b>"
			M.Weaken(rand(2,3))
	return

/mob/living/carbon/Xenomorph/Crusher/proc/ready_charge()
	set name = "Toggle Charging"
	set desc = "Stop auto-charging when you move."
	set category = "Alien"

	if(!check_state()) return //Nope

	if(!istype(src,/mob/living/carbon/Xenomorph/Crusher)) //Logic. Other mobs don't have the verb
		return

	if(!src:is_charging) //We're using tail because they don't have the verb anyway (crushers)
		src << "\blue You will now charge when moving."
		src:is_charging = 1
	else
		src << "\blue You will no longer charge when moving."
		src:is_charging = 0
	return
