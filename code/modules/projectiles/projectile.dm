/*
#define BRUTE "brute"
#define BURN "burn"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"

#define ADD "add"
#define SET "set"
*/

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 1
	unacidable = 1
	anchored = 1 //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	flags = FPRINT | TABLEPASS
	pass_flags = PASSTABLE | PASSGRILLE
	mouse_opacity = 0
	var/bumped = 0		//Prevents it from hitting more than one guy at once
	var/def_zone = ""	//Aiming at
	var/atom/firer = null//Who shot it
	var/silenced = 0	//Attack message
	var/yo = null
	var/xo = null
	var/current = null
	var/atom/shot_from = null // the object which shot us
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid
	var/projectile_type = "/obj/item/projectile"
	var/kill_count = 30 //This will de-increment every process(). When 0, it will delete the projectile.
		//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0
	var/embed = 0 // whether or not the projectile can embed itself in the mob
	var/skip_over = 0
	var/iff = 0
	var/accuracy = 0
	var/skips_xenos = 0
	var/armor_pierce = 0
	var/incendiary = 0
	var/reverse_accuracy = 0
	var/range_falloff_at = 0

	proc/on_hit(var/atom/target, var/blocked = 0)
		if(blocked >= 2)		return 0//Full block
		if(!isliving(target))	return 0
		if(isanimal(target))	return 0
		var/mob/living/L = target
		if(!istype(L,/mob/living/carbon/Xenomorph)) //Xenos are immune to ALL of these things via projectiles. No stun guns, etc
			L.apply_effects(stun, weaken, paralyze, irradiate, stutter, eyeblur, drowsy, agony, blocked) // add in AGONY!
		return 1

	proc/check_fire(var/mob/living/target as mob, var/mob/living/user as mob)  //Checks if you can hit them or not.
		if(!istype(target) || !istype(user))
			return 0
		var/obj/item/projectile/test/in_chamber = new /obj/item/projectile/test(get_step_to(user,target)) //Making the test....
		in_chamber.target = target
		in_chamber.flags = flags //Set the flags...
		in_chamber.pass_flags = pass_flags //And the pass flags to that of the real projectile...
		in_chamber.firer = user
		var/output = in_chamber.process() //Test it!
		del(in_chamber) //No need for it anymore
		return output //Send it back to the gun!

	Bump(atom/A as mob|obj|turf|area)

		if(A == firer)
			loc = A.loc
			return 0 //cannot shoot yourself

		if(bumped)	return 0

		if(firer && A && get_adj_simple(firer,A) && A.loc != get_step(firer,firer.dir)) //No adjacencies at all.
			bumped = 0
			if(isturf(A))
				loc = A
			else
				loc = get_turf(A)
			permutated.Add(A)
			return 0

		var/forcedodge = 0 // force the projectile to pass

		bumped = 1
		if(firer && istype(A, /mob))
			var/mob/M = A
			if(!istype(A, /mob/living))
				loc = A.loc
				return 0// nope.avi

			if(get_adj_simple(firer,A) && A.loc != get_step(firer,firer.dir))
				bumped = 0
				permutated.Add(A)
				skip_over = 1
				return 0

			var/distance = get_dist(starting,loc)
			var/miss_modifier = -20 //NEGATIVE IS BETTER HERE.

			if (istype(shot_from,/obj/item/weapon/gun))	//If you aim at someone beforehead, it'll hit more often.
				var/obj/item/weapon/gun/daddy = shot_from //Kinda balanced by fact you need like 2 seconds to aim
				if (daddy.target && original in daddy.target) //As opposed to no-delay pew pew
					miss_modifier -= 20

				//Weapon attachment modifiers.
				if(daddy.rail)
					if(daddy.rail.accuracy_mod) miss_modifier -= daddy.rail.accuracy_mod
				if(daddy.muzzle)
					if(daddy.muzzle.accuracy_mod) miss_modifier -= daddy.muzzle.accuracy_mod
				if(daddy.under)
					if(daddy.under.accuracy_mod) miss_modifier -= daddy.under.accuracy_mod

			miss_modifier -= accuracy

			if(reverse_accuracy) //Sniper rifles have different miss chance by distance.
				if(distance <= 7)
					miss_modifier += ((12 - distance) * 10)

			if(range_falloff_at > 0 && range_falloff_at < distance)
				miss_modifier += (distance * 4) //Pretends to be half again as far.

			if(iff && ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.get_marine_id())
					bumped = 0
					permutated.Add(H)
					src.loc = get_turf(H)
					skip_over = 1
					return 0

			if(skips_xenos && isXeno(A)) //Xenos are immune to spit.
				bumped = 0
				permutated.Add(A)
				src.loc = get_turf(A.loc)
				skip_over = 1
				return 0

			def_zone = get_zone_with_miss_chance(def_zone, M, miss_modifier + (8 * distance))

			if(!def_zone)
				visible_message("\blue \The [src] misses [M] narrowly!")
				forcedodge = -1
			else
				if(silenced)
					M << "\red You've been shot in the [parse_zone(def_zone)] by the [src.name]!"
				else
					visible_message("\red [A.name] is hit by the [src.name] in the [parse_zone(def_zone)]!")//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
				if(istype(firer, /mob))
					M.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer:ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>[src.type]</b>"
					firer:attack_log += "\[[time_stamp()]\] <b>[firer]/[firer:ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>[src.type]</b>"
					msg_admin_attack("[firer] ([firer:ckey]) shot [M] ([M.ckey]) with a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)") //BS12 EDIT ALG
				else
					M.attack_log += "\[[time_stamp()]\] <b>SOMETHING (sentry?)</b> shot <b>[M]/[M.ckey]</b> with a <b>[src]</b>"
					msg_admin_attack("SOMETHING (sentry probably) shot [M] ([M.ckey]) with a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)") //BS12 EDIT ALG

		if(A)
			if(!forcedodge)
				forcedodge = A.bullet_act(src, def_zone) // searches for return value

			if(forcedodge == -1) // the bullet passes through a dense object!
				bumped = 0 // reset bumped variable!
				if(istype(A, /turf))
					loc = A
				else
					loc = A.loc
				permutated.Add(A)
				return 0
			if(istype(A,/turf))
				for(var/obj/O in A)
					O.bullet_act(src)
				for(var/mob/M in A)
					M.bullet_act(src, def_zone)
			if(bumped && !skip_over)
				density = 0
				invisibility = 101
				del(src)
				return
			else if(skip_over)
				skip_over--
		bumped = 0
		return 1


	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if(istype(mover, /obj/item/projectile))
			return prob(95)
		else
			return 1

	process()
		if(!src) return
		if(kill_count < 1)
			del(src)
			return
		kill_count--
		spawn while(src)
			if((!( current ) || loc == current))
				current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
			if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
				del(src)
				return
			step_towards(src, current)
			sleep(1)
			if(!bumped && !isturf(original) && !istype(original,/obj/effect/alien/weeds))
				if(loc == get_turf(original))
					if(!(original in permutated))
						Bump(original)
						sleep(1)
		return

/obj/item/projectile/test //Used to see if you can hit them.
	invisibility = 101 //Nope!  Can't see me!
	yo = null
	xo = null
	var/target = null
	var/result = 0 //To pass the message back to the gun.

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return //cannot shoot yourself
		if(istype(A, /obj/item/projectile))
			return
		if(istype(A, /mob/living))
			result = 2 //We hit someone, return 1!
			return
		result = 1
		return

	process()
		var/turf/curloc = get_turf(src)
		var/turf/targloc = get_turf(target)
		if(!curloc || !targloc)
			return 0
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		target = targloc
		while(src) //Loop on through!
			if(result)
				return (result - 1)
			if((!( target ) || loc == target))
				target = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z) //Finding the target turf at map edge
			step_towards(src, target)
			var/mob/living/M = locate() in get_turf(src)
			if(istype(M)) //If there is someting living...
				return 1 //Return 1
			else
				M = locate() in get_step(src,target)
				if(istype(M))
					return 1

//Abby -- Just check if they're 1 tile horizontal or vertical, no diagonals
/proc/get_adj_simple(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	if(dx == 0) //left or down of you
		if(dy == -1 || dy == 1)
			return 1
	if(dy == 0) //above or below you
		if(dx == -1 || dx == 1)
			return 1

	return 0

/obj/item/projectile/Crossed(atom/movable/AM) //A mob moving on a tile with a projectile is hit by it.
	..()
	if(isliving(AM) && AM.density)
		Bump(AM, 1)
