
/mob/living/carbon/Xenomorph/Crusher
	caste = "Crusher"
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Crusher Walking"
	melee_damage_lower = 10
	melee_damage_upper = 18
	tacklemin = 3
	tacklemax = 6
	tackle_chance = 90
	health = 270
	maxHealth = 270
	storedplasma = 200
	plasma_gain = 10
	maxplasma = 200
	jellyMax = 0
	caste_desc = "A huge tanky xenomorph."
	speed = -0.5
	evolves_to = list()
	armor_deflection = 68
	var/charge_dir = 0
	var/momentum = 0 //Builds up charge based on movement.
	var/charge_timer = 0 //Has a small charge window. has to keep moving to build momentum.
	var/turf/lastturf = null
	var/noise_timer = 0 // Makes a mech footstep, but only every 3 turfs.
	var/has_moved = 0
	big_xeno = 1

	adjust_pixel_x = -16
	adjust_pixel_y = 0

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		)

/mob/living/carbon/Xenomorph/Crusher/Stat()
	..()
	stat(null, "Momentum: [momentum]")


/mob/living/carbon/Xenomorph/Crusher/proc/stop_momentum(var/direction)
	if(momentum < 0) //Somehow. Could happen if you slam into multiple things
		momentum = 0

	if(!momentum || throwing)
		return

	if(!isturf(src.loc)) //Messed up
		speed = initial(speed)
		momentum = 0
		return

	if(momentum > 18)
		Weaken(2)
		src.visible_message("<b>[src] skids to a halt!</b>","<b>You skid to a halt.</B>")

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
		if(loc == lastturf || get_dist(loc,lastturf) > 1 || loc.z != lastturf.z)
			stop_momentum(charge_dir)
			return

	if(dir != charge_dir || src.m_intent == "walk" || istype(src.loc,/turf/simulated/floor/gm/river))
		stop_momentum(charge_dir)
		return

	if(pulling && momentum > 9)
		stop_pulling()

	if(speed > -3)
		speed -= 0.2 //Speed increases each step taken. At 30 tiles, maximum speed is reached.

	if(momentum < 30)	 //Maximum 30 momentum.
		momentum += 2 //2 per turf. Max speed in 15.

	if(momentum < 0)
		momentum = 0

	spawn(10) //After 1 seconds, window closes. This is reset in xeno_procs, movedelay
		if(!has_moved)
			charge_timer = 0
			stop_momentum()
			return

	if(!charge_timer && !has_moved)
		stop_momentum(charge_dir)
		return

	if(storedplasma > 5)
		storedplasma -= round(momentum / 10) //eats up some plasma. max -3
	else
		stop_momentum(charge_dir)
		return

	if(momentum <= 2)
		charge_dir = dir

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

	for(var/mob/living/carbon/M in view(4))
		if(M && M.client && get_dist(M,src) <= round(momentum / 10) && src != M && momentum > 5)
			if(!isXeno(M))
				shake_camera(M, 1, 1)
		if(M && M.lying && M.loc == src.loc && !isXeno(M) && M.stat != DEAD && momentum > 3)
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

		if(src.stat || src.momentum < 3 || !AM || !istype(AM) || AM == src)
			return 0

		if(now_pushing) //Just a plain ol turf, let's return.
			return 0

		if(dir != charge_dir) //We aren't facing the way we're charging.
			return ..()

		now_pushing = 1

		if(istype(AM,/obj/item)) //Small items (ie. bullets) are unaffected.
			var/obj/item/obj = AM
			if(obj.w_class < 3)
				now_pushing = 0
				return 0

		start_loc = AM.loc
		if (isobj(AM) && AM.density) //Generic dense objects that aren't tables.
			if(AM:anchored)
				if(momentum < 12)
					now_pushing = 0
					return ..()
				else
					if(istype(AM,/obj/mecha))
						var/obj/mecha/mech = AM
						mech.take_damage(momentum * 8)
						visible_message("<b>[src] rams into [AM]!</b>","<b>You ram into [AM]!</b>")
						playsound(loc, "punch", 50, 1, -1)
						if(momentum > 25)
							diagonal_step(mech,dir,50)//Occasionally fling it diagonally.
							step_away(mech,src)
						Weaken(2)
						stop_momentum(charge_dir)
						now_pushing = 0
						return
					if(AM:unacidable)
						src << "\red Bonk!"
						Weaken(2)
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
				momentum -= 5
				now_pushing = 0
				return

		if (istype(AM,/obj/structure/window) && momentum > 5)
			AM:hit((momentum * 4) + 10) //Should generally smash it unless not moving very fast.
			momentum -= 5
			now_pushing = 0
			return //Might be destroyed.

		if (istype(AM,/obj/structure/grille))
			AM:health -= (momentum * 3) //Usually knocks it down.
			AM:healthcheck()
			now_pushing = 0
			return //Might be destroyed.

		if(istype(AM,/obj/structure/table) || istype(AM,/obj/structure/rack) || istype(AM,/obj/structure/barricade/wooden))
			if(momentum > 2)
				var/obj/structure/S = AM
				visible_message("<span class='danger'>[src] plows straight through the [S.name]!</span>")
				S.destroy()
				momentum -= 3
				now_pushing = 0
				return 0//Might be destroyed, so we stop here.
			else
				now_pushing = 0
				return ..()

		if(istype(AM,/mob/living/carbon/Xenomorph) && momentum > 6)
			playsound(loc, "punch", 25, 1, -1)
			diagonal_step(AM,dir,100)//Occasionally fling it diagonally.
			step_away(AM,src) //GET OUTTA HERE
			now_pushing = 0
			return

		if(istype(AM,/mob/living/carbon) && momentum > 7)
			var/mob/living/carbon/H = AM
			playsound(loc, "punch", 25, 1, -1)
			if(momentum < 12 && momentum > 7)
				H.Weaken(2)
			else if(momentum < 20)
				H.Weaken(6)
				H.apply_damage(momentum,BRUTE)
			else if (momentum >= 20)
				H.Weaken(8)
				H.take_overall_damage(momentum * 2)
			diagonal_step(H,dir, 50)//Occasionally fling it diagonally.
			step_away(H,src,round(momentum / 10))
			momentum -= 3
			visible_message("<B>[src] knocks over [H]!</b>","<B>You knock over [H]!</B>")
			now_pushing = 0
			return

		if(isturf(AM) && AM.density) //We were called by turf bump.
			if(momentum <= 25 && momentum > 8)
				src << "\red Bonk!"
				stop_momentum(charge_dir)
				src.Weaken(3)
			if(momentum > 15)
				AM:ex_act(3) //Should dismantle, or at least heavily damage it.
			if(momentum > 25) //WHAM!
				explosion(src,-1,-1,round(momentum / 10),-1)  //We're immune to explosions. Fuck that wall up.
			if(AM) //Still there?
				src.Weaken(2)
				stop_momentum(charge_dir)
				now_pushing = 0
				return ..()

		if(AM) //If the object still exists.
			if(AM.loc == start_loc) //And hasn't moved
				now_pushing = 0
				return ..() //Bump it normally.
		//Otherwise, just get out
		now_pushing = 0
		return

