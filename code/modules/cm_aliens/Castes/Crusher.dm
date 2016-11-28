//Crusher Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Crusher
	caste = "Crusher"
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Crusher Walking"
	melee_damage_lower = 15
	melee_damage_upper = 30
	tacklemin = 4
	tacklemax = 7
	tackle_chance = 95
	health = 200
	maxHealth = 200
	storedplasma = 200
	plasma_gain = 10
	maxplasma = 200
	jelly = 1
	jellyMax = 800
	caste_desc = "A huge tanky xenomorph."
	speed = 0.5
	evolves_to = list()
	armor_deflection = 65
	tier = 3
	upgrade = 0
	var/charge_dir = 0
	var/momentum = 0 //Builds up charge based on movement.
	var/charge_timer = 0 //Has a small charge window. has to keep moving to build momentum.
	var/turf/lastturf = null
	var/noise_timer = 0 // Makes a mech footstep, but only every 3 turfs.
	var/has_moved = 0
	big_xeno = 1
	var/is_charging = 1

	pixel_x = -16
	pixel_y = -3

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

	if(!isturf(loc)) //Messed up
		speed = initial(speed)
		momentum = 0
		return

	if(stunned && momentum > 24)
		Weaken(2)
		visible_message("<span class='danger'>\The [src] skids to a halt!</span>", \
		"<span class='danger'>You skid to a halt.</span>")
	flags_pass = 0
	momentum = 0
	speed = initial(speed)
	update_icons()

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

	if(dir != charge_dir || src.m_intent == "walk" || istype(loc, /turf/unsimulated/floor/gm/river))
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

	if(momentum <= 18) //Maximum 30 momentum.
		momentum += 3 //2 per turf. Max speed in 15.

	else if(momentum > 18 && momentum < 25)
		momentum += 2

	else if(momentum >= 25 && momentum < 30)
		momentum++ //Increases slower at high speeds so we don't go LAZERFAST

	if(momentum < 0)
		momentum = 0

	if(storedplasma > 5)
		storedplasma -= round(momentum / 10) //Eats up some plasma. max -3
	else
		stop_momentum(charge_dir)
		return

	if(charge_dir != dir) //Still not facing? What the heck!
		return

	//Some flavor text.
	if(momentum == 10)
		src << "<span class='xenonotice'>You begin churning up the ground with your charge!</span>"
	else if(momentum == 20)
		src << "<span class='xenowarning'>The ground begins to shake as you run!</span>"
	else if(momentum == 28) //Not 30, since it's max
		src << "<span class='xenodanger'>You have achieved maximum momentum!</span>"
		emote("roar")

	if(noise_timer)
		noise_timer--
	else
		noise_timer = 3

	if(noise_timer == 3 && momentum > 10)
		playsound(loc, 'sound/mecha/mechstep.ogg', 50 + (momentum), 0)

	for(var/mob/living/carbon/M in view(8))
		if(M && M.client && get_dist(M, src) <= round(momentum / 5) && src != M && momentum > 5)
			if(!isXeno(M))
				shake_camera(M, 1, 1)
		if(M && M.lying && M.loc == src.loc && !isXeno(M) && M.stat != DEAD && momentum > 6)
			visible_message("<span class='danger'>\The [src] runs \the [M] over!</span>", \
			"<span class='danger'>You run \the [M] over!</span>")
			M.take_overall_damage(momentum * 2)

	if(isturf(loc) && !istype(loc, /turf/space)) //Set their turf, to make sure they're moving and not jumped in a locker or some shit
		lastturf = loc
	else
		lastturf = null
	update_icons()

proc/diagonal_step(var/atom/movable/A, var/direction, var/probab = 75)
	if(!A)
		return
	if(direction == EAST || direction == WEST && prob(probab))
		if(prob(50))
			step(A, NORTH)
		else
			step(A, SOUTH)
	else if(direction == NORTH || direction == SOUTH && prob(probab))
		if(prob(50))
			step(A, EAST)
		else
			step(A, WEST)

//Custom bump for crushers. This overwrites normal bumpcode from carbon.dm
/mob/living/carbon/Xenomorph/Crusher/Bump(atom/AM as mob|obj|turf, yes)
	set waitfor = 0
	var/start_loc

	if(stat || momentum < 3 || !AM || !istype(AM) || AM == src || !yes)
		return

	if(now_pushing) //Just a plain ol turf, let's return.
		return

	if(dir != charge_dir) //We aren't facing the way we're charging.
		stop_momentum()
		return ..()

	now_pushing = 1

	if(istype(AM, /obj/item)) //Small items (ie. bullets) are unaffected.
		var/obj/item/obj = AM
		if(obj.w_class < 3)
			now_pushing = 0
			return

	if(istype(AM, /obj/structure/table))
		var/obj/structure/table/T = AM
		now_pushing = 0
		T.Crossed(src)
		return 0

	start_loc = AM.loc
	if(isobj(AM) && AM.density) //Generic dense objects that aren't tables.
		var/obj/O = AM
		if(O.anchored)
			if(momentum < 16)
				now_pushing = 0
				return ..()
			else
				//HOLY MOTHER OF OOP
				if(istype(O, /obj/structure/window) && momentum > 5)
					var/obj/structure/window/W = O
					W.hit((momentum * 4) + 10) //Should generally smash it unless not moving very fast.
					momentum -= 2
					now_pushing = 0
					return //Might be destroyed.

				if(istype(O, /obj/structure/grille))
					var/obj/structure/grille/G = O
					G.health -= (momentum * 3) //Usually knocks it down.
					G.healthcheck()
					now_pushing = 0
					return //Might be destroyed.

				if(istype(O, /obj/structure/m_barricade) && O.dir == reverse_direction(dir))
					if(momentum > 10)
						var/obj/structure/m_barricade/M = O
						M.health -= (momentum * 4)
						playsound(loc, "punch", 100, 1, -1)
						visible_message("<span class='danger'>The [src] smashes straight into \the [M]!</span>", \
						"<span class='danger'>You smash straight into \the [M]!</span>")
						M.update_health()
						src << "<span class='danger'>Bonk!</span>"
						Weaken(2)
						stop_momentum(charge_dir, 1)
						now_pushing = 0
						return
					else
						return ..()

				if(istype(O, /obj/machinery/vending))
					if(momentum > 20)
						var/obj/machinery/vending/V = O
						visible_message("<span class='danger'>\The [src] smashes straight into \the [V]!</span>", \
						"<span class='danger'>You smash straight into \the [V]!</span>")
						playsound(loc, "punch", 100, 1, -1)
						src << "<span class='danger'>Bonk!</span>"
						stop_momentum(charge_dir, 1)
						Weaken(2)
						now_pushing = 0
						V.tip_over()
						diagonal_step(V, dir, 50) //Occasionally fling it diagonally.
						step_away(V, src)
						step_away(V, src)
						return

				if(istype(O, /obj/structure/barricade/wooden))
					if(momentum > 8)
						var/obj/structure/barricade/wooden/S = O
						visible_message("<span class='danger'>\The [src] plows straight through \the [S]!</span>", \
						"<span class='danger'>You plow straight through \the [S]!</span>")
						S.destroy()
						momentum -= 3
						now_pushing = 0
						return //Might be destroyed, so we stop here.
					else
						now_pushing = 0
						return

				if(istype(O, /obj/structure/barricade/snow))
					if(momentum > 8)
						var/obj/structure/barricade/snow/S = O
						visible_message("<span class='danger'>\The [src] plows straight through \the [S]!</span>", \
						"<span class='danger'>You plow straight through \the [S]!</span>")
						del(S)
						momentum -= 3
						now_pushing = 0
						return //Might be destroyed, so we stop here.
					else
						now_pushing = 0
						return

				if(istype(O, /obj/mecha))
					var/obj/mecha/mech = O
					mech.take_damage(momentum * 8)
					visible_message("<span class='danger'>\The [src] rams \the [mech]!</span>", \
					"<span class='danger'>You ram \the [mech]!</span>")
					playsound(loc, "punch", 50, 1, -1)
					if(momentum > 25)
						diagonal_step(mech, dir, 50) //Occasionally fling it diagonally.
						step_away(mech, src)
					Weaken(2)
					stop_momentum(charge_dir, 1)
					now_pushing = 0
					return

				if(istype(O, /obj/machinery/marine_turret))
					var/obj/machinery/marine_turret/turret = O
					visible_message("<span class='danger'>\The [src] rams \the [turret]!</span>", \
					"<span class='danger'>You ram \the [turret]!</span>")
					playsound(loc, "punch", 70, 1, -1)
					if(momentum > 10)
						if(prob(70 + momentum))
							turret.stat = 1
							turret.on = 0
							turret.update_icon()
					turret.update_health(momentum * 2)
					if(!isnull(turret))
						src << "<span class='danger'>Bonk!</span>"
						Weaken(3)
						stop_momentum(charge_dir, 1)
						now_pushing = 0
					return

				if(O.unacidable)
					src << "<span class='danger'>Bonk!</span>"
					Weaken(2)
					if(momentum > 26)
						stop_momentum(charge_dir)
					now_pushing = 0
					return

				if(momentum > 20)
					visible_message("<span class='danger'>\The [src] crushes \the [O]!</span>", \
					"<span class='danger'>You crush \the [O]!</span>")
					if(O.contents) //Hopefully won't auto-delete things inside crushed stuff..
						for(var/atom/movable/S in O)
							if(S in O.contents && !isnull(get_turf(O)))
								S.loc = get_turf(O)
						spawn()
							del(O)
				now_pushing = 0
				return

		if(momentum > 5)
			visible_message("\The [src] knocks aside \the [O]!", \
			"You casually knock aside \the [O].") //Canisters, crates etc. go flying.
			playsound(loc, "punch", 25, 1, -1)
			diagonal_step(AM, dir) //Occasionally fling it diagonally.
			step_away(AM, src, round(momentum/10) + 1)
			now_pushing = 0
			return

	if(isXeno(AM))
		var/mob/living/carbon/Xenomorph/xeno = AM
		if(momentum > 6)
			playsound(loc, "punch", 25, 1, -1)
			diagonal_step(xeno, dir, 100) //Occasionally fling it diagonally.
			step_away(xeno, src) //GET OUTTA HERE
			now_pushing = 0
			return
		else
			now_pushing = 0
			return ..() //Just shove normally.

	if(iscarbon(AM) && momentum > 7)
		var/mob/living/carbon/C = AM
		playsound(loc, "punch", 25, 1, 1)
		if(momentum < 12 && momentum > 7)
			C.Weaken(2)
		else if(momentum < 20)
			C.Weaken(6)
			C.apply_damage(momentum, BRUTE)
		else if(momentum >= 20)
			C.Weaken(8)
			C.take_overall_damage(momentum * 2)
		diagonal_step(C, dir, 100) //Occasionally fling it diagonally.
		step_away(C, src, round(momentum / 10))
		visible_message("<span class='danger'>\The [src] rams \the [C]!</span>", \
		"<span class='danger'>You ram \the [C]!</span>")
		now_pushing = 0
		return

	if(isturf(AM) && AM.density) //We were called by turf bump.
		var/turf/T = AM
		if(momentum <= 25 && momentum > 14)
			src << "<span class='danger'>Bonk!</span>"
			stop_momentum(charge_dir, 1)
			Weaken(3)
		if(momentum > 26)
			T.ex_act(2) //Should dismantle, or at least heavily damage it.

		if(!isnull(T) && momentum > 20)
			stop_momentum(charge_dir, 1)
		now_pushing = 0
		return

	if(AM) //If the object still exists.
		if(AM.loc == start_loc) //And hasn't moved
			now_pushing = 0
			return ..() //Bump it normally

	//Otherwise, just get out
	now_pushing = 0

/mob/living/carbon/Xenomorph/Crusher/proc/stomp()
	set name = "Stomp (50)"
	set desc = "Strike the earth!"
	set category = "Alien"

	if(!check_state())
		return

	if(has_screeched) //Sure, let's use this.
		src << "<span class='warning'>You are not ready to stomp again.</span>"
		return

	if(!check_plasma(50))
		return

	has_screeched = 1
	spawn(500) //50 seconds
		has_screeched = 0
		src << "<span class='notice'>You are ready to stomp again.</span>"

	playsound(loc, 'sound/effects/bang.ogg', 50, 0, 100, -1)
	visible_message("<span class='xenodanger'>\The [src] smashes into the ground!</span>", \
	"<span class='xenodanger'>You smash into the ground!</span>")
	create_shriekwave() //Adds the visual effect. Wom wom wom
	for(var/mob/living/carbon/human/M in oview())
		var/dist = get_dist(src, M)
		if(M && M.client && dist < 6)
			shake_camera(M, 5, 1)
		if(dist < 3 && !M.lying && !M.stat)
			M << "<span class='danger'>The earth moves beneath your feet!</span>"
			M.Weaken(rand(2, 3))

/mob/living/carbon/Xenomorph/Crusher/proc/ready_charge()
	set name = "Toggle Charging"
	set desc = "Stop auto-charging when you move."
	set category = "Alien"

	if(!check_state())
		return //Nope

	if(!is_charging) //We're using tail because they don't have the verb anyway (crushers)
		src << "<span class='notice'>You will now charge when moving.</span>"
		is_charging = 1
	else
		src << "<span class='notice'>You will no longer charge when moving.</span>"
		is_charging = 0
