
//The actual bullet objects.
/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 0
	unacidable = 1
	anchored = 1
	flags = FPRINT | TABLEPASS
	pass_flags = PASSTABLE | PASSGRILLE
	mouse_opacity = 0

	var/datum/ammo/ammo //The ammo data which holds most of the actual info.

	var/bumped = 0		//Prevents it from hitting more than one guy at once
	var/def_zone = ""	//Aiming at
	var/atom/firer = null//Who shot it
	var/silenced = 0	//Attack message

	var/yo = null
	var/xo = null

	var/current = null
	var/atom/shot_from = null // the object which shot us
	var/atom/original = null // the original target clicked

	var/turf/target_turf = null
	var/turf/starting = null // the projectile's starting turf

	var/list/turf/path = list()

	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again

	var/paused = 0 //For suspending projectiles. Neat idea! Stolen shamelessly from TG.

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
//	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions

	var/distance_travelled = 0
	var/in_flight = 0
	var/saved = 0
	var/flight_check = 50
	var/scatter_chance = 20

	Del()
		path = null
		permutated = null
		target_turf = null
		starting = null
		return ..()

	proc/each_turf()
		distance_travelled++
		if(ammo)
			if(distance_travelled == round(ammo.max_range / 2) && loc)
				ammo.do_at_half_range(src)
			if(istype(ammo,/datum/ammo/rocket))
				if(distance_travelled > 3 && ammo.shell_speed == 1) //No need to set it EVERY turf.
					ammo.shell_speed = 2
				else if (distance_travelled > 11 && ammo.shell_speed < 3)
					ammo.shell_speed = 3
		return

	proc/get_accuracy()
		var/acc = 85 //Base accuracy.
		if(!ammo) //Oh, it's not a bullet? Or something? Let's leave.
			return acc

		acc += ammo.accuracy //Add the ammo's accuracy bonus/pens

		if(istype(shot_from,/obj/item/weapon/gun)) //Does our gun exist? If so, add attachable bonuses.
			var/obj/item/weapon/gun/gun = shot_from
			if(gun.rail && gun.rail.accuracy_mod) acc += gun.rail.accuracy_mod
			if(gun.muzzle && gun.muzzle.accuracy_mod) acc += gun.muzzle.accuracy_mod
			if(gun.under && gun.under.accuracy_mod) acc += gun.under.accuracy_mod
			if(gun.stock && gun.stock.accuracy_mod) acc += gun.stock.accuracy_mod

			acc += gun.accuracy

		//These should all be 0 if the bullet is still in the barrel.
		if(ammo.accurate_range + rand(0,3) < distance_travelled) //Determine ranged accuracy
			acc -= (distance_travelled * 5) //-5% accuracy per turf
		else if (distance_travelled <= 2)
			acc += 25 //Big bonus for point blanks.

		if(acc < 5) acc = 5 //There's always some chance.
		return acc

	//The attack roll. Returns -1 for an IFF-based miss (smartgun), 0 on a regular miss, 1 on a hit.
	proc/roll_to_hit(var/atom/shooter,var/atom/target)
		var/hit_chance = get_accuracy() //Get the bullet's pure accuracy.
		if(target == shooter) return -1

		if(istype(target,/mob/living))
			var/mob/living/T = target
			if(T.lying && T.stat) hit_chance += 15 //Bonus hit against unconscious people.
			if(istype(T,/mob/living/carbon/Xenomorph))
				if(T:big_xeno)
					hit_chance += 10
				else
					hit_chance -= 10

			if(ammo.skips_marines && ishuman(target))
				var/mob/living/carbon/human/H = target
				if(H.get_marine_id())
					return -1 //Pass straight through.

			if(ammo.skips_xenos && isXeno(target)) return -1 //Mostly some spits.

			if(istype(target,/mob/living/carbon/human) && istype(shooter,/mob/living/carbon/human))
				if(target:faction == shooter:faction || target:m_intent == "walk") //Humans can aim around their buddies to an extent.
					hit_chance -= 15

			if(ismob(shooter))
				if(!can_see(shooter,target)) //Can't see the target
					hit_chance -= 15
				hit_chance -= round((shooter:maxHealth - shooter:health) / 4)

			var/hit_roll = rand(0,100) //Our randomly generated roll.
			if(hit_roll < 25)
				def_zone = pick(base_miss_chance)

			hit_chance -= base_miss_chance[def_zone] //Reduce accuracy based on spot

			if(hit_chance < hit_roll - 20) //Mega miss!
				if (!target:lying) target.visible_message("\blue \The [src] misses \the [target]!","\blue \The [src] narrowly misses you!")
				return -1
			else if (hit_chance > hit_roll) //You hit!
				return 1
			else
				//You got lucky buddy, you got a second try! Pick a random organ instead.
				if(saved)
					return -1
				def_zone = pick(base_miss_chance)
				saved = 1
				return roll_to_hit(shooter,target) //Let's try this again.
		else if (isobj(target))
		//Deal with some special cases.
			if((istype(target,/obj/structure/table) && target:flipped) || istype(target,/obj/structure/m_barricade))
				var/chance = 0
				if(dir == reverse_direction(target.dir))
					chance = 95
				else if(dir == target.dir)
					chance = 1
				else
					chance = 20
				if(prob(chance))
					return 1
				else
					return 0

		return 0

	Bumped(atom/A as mob|obj|turf|area)
		if(A && !A in permutated)
			scan_a_turf(A.loc)

	Crossed(AM as mob|obj)
		if(AM && !AM in permutated)
			scan_a_turf(get_turf(AM))

	proc/follow_flightpath(var/speed = 1, var/change_x, var/change_y, var/range) //Everytime we reach the end of the turf list, we slap a new one and keep going.
		set waitfor = 0

		var/dist_since_sleep = 5 //Just so we always see the bullet.
		var/turf/current_turf = get_turf(src)
		var/turf/next_turf
		in_flight = 1
		var/this_iteration = 0
		spawn()
			for(next_turf in path)
				if(!src || !loc)
					return

				if(!in_flight) return

				if(distance_travelled >= range)
					ammo.do_at_max_range(src)
					in_flight = 0
					if(src) del(src)
					return

				if(scan_a_turf(next_turf) == 1) //We hit something! Get out of all of this.
					in_flight = 0
					sleep(0)
					if(src) del(src)
					return

				src.loc = next_turf
				each_turf()

				dist_since_sleep++
				this_iteration++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)

				current_turf = get_turf(src)
				if(this_iteration == path.len)
					next_turf = locate(current_turf.x + change_x, current_turf.y + change_y, current_turf.z)
					if(current_turf && next_turf)
						path = null
						path = getline2(current_turf,next_turf) //Build a new flight path.
						if(path.len && src)
							follow_flightpath(speed, change_x, change_y, range) //Onwards!

//Target, firer, shot from. Ie the gun
	proc/fire_at(atom/target,atom/F, atom/S, range = 30,speed = 1)

		if(!original || isnull(original)) original = target
		if(!loc) loc = get_turf(F)
		starting = get_turf(src)
		if(starting != src.loc) src.loc = starting //Put us on the turf, if we're not.
		target_turf = get_turf(target)
		if(starting == target_turf) //What? We can't fire at our own turf.
			return 0
		firer = F
		if(F) permutated.Add(F) //Don't hit the shooter (firer)
		shot_from = S
		in_flight = 1

		path = getline2(starting,target_turf)

		var/change_x = target_turf.x - starting.x
		var/change_y = target_turf.y - starting.y

//		var/dist_since_sleep = 0
		var/angle = round(Get_Angle(starting,target_turf))

		var/matrix/rotate = matrix() //Change the bullet angle.
		rotate.Turn(angle)
		src.transform = rotate

		follow_flightpath(speed,change_x,change_y,range) //pyew!

	proc/scan_a_turf(var/turf/T)
		if(!istype(T)) return 0
		if(T.density) //Shit, we hit a wall.
			if(ammo) ammo.on_hit_turf(T,src)
			if(T) T.bullet_act(src)
			return 1
		if(firer && T == firer.loc) return 0 //Never.
		if(!T.contents.len) return 0 //Nothing here.
		if(isnull(src)) return 1 //??
		for(var/atom/A in T)
			if(!A || A == src || A == firer || A in permutated) continue

			//TODO: Make this a var
			if(A == original && istype(A,/obj/item/clothing/mask/facehugger)) //Shoot that fucker!
				A.bullet_act(src)
				continue

			if(isturf(A))
				if(istype(A,/turf/space)) return 1 //no space flight sorry
				if(!A.density) continue
				if(ammo) ammo.on_hit_turf(A,src)
				if(A) A.bullet_act(src) //Turf could blow up before the hit
				return 1

			else if(isobj(A))
				if(istype(A,/obj/structure/window) && (ammo && istype(ammo,/datum/ammo/energy))) //this is bad too
					continue

				if(A == original && istype(A,/obj/effect/alien/egg)) //Specifically clicking on eggs
					if(ammo) ammo.on_hit_obj(A,src)
					if(A) A.bullet_act(src)
					return 1

				if(A.density == 0) //We're scanning a non dense object.
					continue

				//Scan for tables, barricades, and other assorted larger nonsense
				if(roll_to_hit(firer,A) == 1 || (A.throwpass == 0 && A.layer >= 3))
					if(ammo) ammo.on_hit_obj(A,src)
					if(A) A.bullet_act(src)
					return 1

			else if(ismob(A))
				if(istype(A,/mob/living) && roll_to_hit(firer,A) == 1 && (A:lying == 0 || A == original))
					if(ammo) ammo.on_hit_mob(A,src)
					if(A) A.bullet_act(src)
					return 1

		return 0 //Found nothing.



/atom/proc/bullet_ping(var/obj/item/projectile/P)
	if(!P || isnull(P)) return

	var/image/ping = image('icons/obj/projectiles.dmi',src,"ping",10) //Layer 10, above most things but not the HUD.
	var/angle = round(rand(1,359))
	ping.pixel_x += rand(-6,6)
	ping.pixel_y += rand(-6,6)

	if(P.firer && prob(60))
		angle = round(Get_Angle(P.firer,src))

	var/matrix/rotate = matrix()

	rotate.Turn(angle)
	ping.transform = rotate

	for(var/mob/M in viewers(src))
		M << ping

	sleep(3)
	del(ping)

/atom/proc/bullet_act(obj/item/projectile/P)
	return density

/mob/proc/bullet_message(obj/item/projectile/P)
	if(!P || !P.ammo) return

	if(P.ammo.silenced)
		src << "\red You've been shot in the [parse_zone(P.def_zone)] by \the [P.name]!"
	else
		visible_message("\red [name] is hit by the [P.name] in the [parse_zone(P.def_zone)]!")

	if(istype(P.firer, /mob))
		attack_log += "\[[time_stamp()]\] <b>[P.firer]/[P.firer:ckey]</b> shot <b>[src]/[src.ckey]</b> with a <b>[P]</b>"
		P.firer:attack_log += "\[[time_stamp()]\] <b>[P.firer]/[P.firer:ckey]</b> shot <b>[src]/[src.ckey]</b> with a <b>[P]</b>"
		msg_admin_attack("[P.firer] ([P.firer:ckey]) shot [src] ([src.ckey]) with a [P] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[P.firer.x];Y=[P.firer.y];Z=[P.firer.z]'>JMP</a>)")
	else if(P.firer)
		attack_log += "\[[time_stamp()]\] <b>[P.firer]</b> shot <b>[src]/[src.ckey]</b> with a <b>[P]</b>"
		msg_admin_attack("[P.firer] shot [src] ([src.ckey]) with a [P] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[P.firer.x];Y=[P.firer.y];Z=[P.firer.z]'>JMP</a>)")
	else
		attack_log += "\[[time_stamp()]\] <b>SOMETHING??</b> shot <b>[src]/[src.ckey]</b> with a <b>[P]</b>"
		msg_admin_attack("SOMETHING?? shot [src] ([src.ckey]) with a [P])")
	return

/mob/dead/bullet_act(/obj/item/projectile/P)
	return 0

/mob/living/bullet_act(obj/item/projectile/P)
	if(!P || !istype(P) || !P.ammo) return 0 //Somehow. Just some logic.

	var/damage = P.damage - (P.distance_travelled * P.ammo.damage_bleed)
	if(damage < 0) damage = 0 //NO HEALING


	if(stat != DEAD) //Not on deads please
		//Apply happy funtime effects! Based on the ammo datum attached to the bullet.
		apply_effects(P.ammo.stun,P.ammo.weaken,P.ammo.paralyze,P.ammo.irradiate,P.ammo.stutter,P.ammo.eyeblur,P.ammo.drowsy,P.ammo.agony)

	if(src && P && damage > 0)
		apply_damage(damage, P.ammo.damage_type, P.def_zone, 0, 0, 0, P)

	if(!src || !P || !P.ammo) return 0

	bullet_message(P)

	if(P && P.ammo && damage > 0 && P.ammo.incendiary)
		adjust_fire_stacks(rand(6,10))
		IgniteMob()
//		emote("scream")
		src << "\red <B>You burst into flames!! Stop drop and roll!</b>"
	return 1

/mob/living/carbon/human/bullet_act(obj/item/projectile/P)
	if(!P || !istype(P) || !P.ammo) return 0 //Somehow. Just some logic.

	flash_weak_pain()

	var/damage = P.damage - (P.distance_travelled * P.ammo.damage_bleed)
	if(damage < 0) damage = 0 //NO HEALING

	//Any projectile can decloak a predator. It does defeat one free bullet though.
	if(gloves)
		var/obj/item/clothing/gloves/yautja/Y = gloves
		if(istype(Y) && Y.cloaked && rand(0,100) < 20 )
			Y.decloak(src)
			return 0

	var/datum/organ/external/organ = get_organ(check_zone(P.def_zone)) //Let's finally get what organ we actually hit.

	if(!organ) return 0//Nope. Gotta shoot something!

	//Run armor check
	//Shields
	if(check_shields(20 + P.ammo.accuracy, "the [P.name]"))
		P.ammo.on_shield_block(src)
		src.bullet_ping(P)
		return 1

	var/armor = 0 //Why are damage types different from armor types? Who the fuck knows. Let's merge them anyway.
	var/absorbed = 0

	if(!P.ammo.ignores_armor)
		if(P.damage_type == "BRUTE")
			armor = getarmor_organ(organ, "bullet")
		else if(P.damage_type == "TOX") //Mostly some acid spits. These use "BIO" armor value from now on.
			armor = getarmor_organ(organ, "bio")
		else if(P.damage_type == "BURN")  //Sizzle!
			armor = getarmor_organ(organ, "laser")
		else
			armor = getarmor_organ(organ, "energy") //Everything else. Bullet act should probably not use this except for exotic bullets.

		armor -= P.ammo.armor_pen

		if(armor > 0) damage = damage - (damage * armor / 100)

		if(damage < 0) damage = 0

		if(damage > 0 && prob(armor)) //Yay we absorbed more!
			damage = damage - round(damage / 2)
			absorbed = 1
			if(damage > 0 && prob(armor - 20)) //Let's go one more time.
				damage = damage - round(damage / 2) //Nice!
				absorbed = 2

			if(absorbed == 1 && !stat)
				src << "\red Your armor softens the impact of \the [P]!"
			else if (absorbed == 2 && !stat)
				src << "\red Your armor absorbs the force of \the [P]!"

		if(damage < 0) damage = 0

	if(stat != DEAD && absorbed <= 1) //Not on deads please
		//Apply happy funtime effects! Based on the ammo datum attached to the bullet.
		apply_effects(P.ammo.stun,P.ammo.weaken,P.ammo.paralyze,P.ammo.irradiate,P.ammo.stutter,P.ammo.eyeblur,P.ammo.drowsy,P.ammo.agony)

	if(src && P && damage > 0)
		apply_damage(damage, P.damage_type, P.def_zone)

	bullet_message(P)

	if (P && P.ammo && src && absorbed == 0 && damage > 0 && P.ammo.shrapnel_chance > 0)
		if(prob(P.ammo.shrapnel_chance + round(damage / 10)))
			embed_shrapnel(P,organ)

	if(P.ammo && !damage > 0 && absorbed == 0 && P.ammo.incendiary)
		adjust_fire_stacks(rand(6,11))
		IgniteMob()
		emote("scream")
		src << "\red <B>You burst into flames!! Stop drop and roll!</b>"

	return 1

/mob/living/carbon/human/proc/embed_shrapnel(var/obj/item/projectile/P, var/datum/organ/external/organ)
	var/obj/item/weapon/shard/shrapnel/SP = new()
	SP.name = "[P.name] shrapnel"
	SP.desc = "[SP.desc] It looks like it was fired from [P.shot_from]."
	SP.loc = organ
	organ.embed(SP)
	if(!stat)
		src << "\red You scream in pain as the impact sends <B>shrapnel</b> into the wound!"
		emote("scream")

//Deal with xeno bullets.
/mob/living/carbon/Xenomorph/bullet_act(obj/item/projectile/P)
	if(!istype(P) || isnull(P.ammo) || !P) return 0

	flash_weak_pain()

	var/damage = P.damage - (P.distance_travelled * P.ammo.damage_bleed)
	if(damage < 0) damage = 0 //NO HEALING

	var/armor = armor_deflection - P.ammo.armor_pen

	if(istype(src,/mob/living/carbon/Xenomorph/Crusher)) //Crusher resistances - more depending on facing.
		armor += (src:momentum / 3) //Up to +15% armor deflection all-around when charging.
		if(P.dir == src.dir) //Both facing same way -- ie. shooting from behind.
			armor -= 70 //Ouch.
		else if(P.dir == reverse_direction(src.dir)) //We are facing the bullet.
			armor += 45
		//Otherwise use the standard armor deflection for crushers.

	if(guard_aura) //Yay bonus armor!
		armor += (guard_aura * 3)
	if(P.ammo.ignores_armor) armor = 0 //Nope

	if(prob(armor - damage))
		src.bullet_ping(P)
		visible_message("\blue The [src]'s thick exoskeleton deflects \the [P]!","\blue Your thick exoskeleton deflected \the [P]!")
		return 1

	bullet_message(P)
	if(P && P.ammo && P.ammo.incendiary)
		if(fire_immune)
			src << "You shrug off some persistent flames."
		else
			adjust_fire_stacks(rand(2,6) + round(damage / 8))
			IgniteMob()
			src.visible_message("\red <B>\The [src] bursts into flames!</b>","\red <B>You burst into flames!! Auuugh! Stop drop and roll!</b>")

	if(src && P && damage > 0)
		apply_damage(damage,P.damage_type, P.def_zone)	//Deal the damage.
		if(prob(5 + round(damage / 4)) && !stat)
			if(prob(70))
				emote("hiss")
			else
				emote("roar")

	updatehealth()
	return 1

/turf/bullet_act(obj/item/projectile/P)
	if(!src.density || !P || !P.ammo || isnull(P))
		return 0 //It's just an empty turf

	src.bullet_ping(P)

	var/turf/target_turf = P.loc
	if(!istype(target_turf)) return 0 //The bullet's not on a turf somehow.

	var/list/mobs_list = list() //Let's built a list of mobs on the bullet turf and grab one.
	for(var/mob/living/L in target_turf)
		if(L in P.permutated) continue
		mobs_list += L

	if(mobs_list.len)
		var/mob/living/picked_mob = pick(mobs_list) //Hit a mob, if there is one.
		if(istype(picked_mob) && P.firer && P.roll_to_hit(P.firer,picked_mob) == 1)
			picked_mob.bullet_act(P)
			return 1
/*
	if(P && src.can_bullets && src.bullet_holes < 5 ) //Pop a bullet hole on that fucker. 5 max per turf
		var/image/I = image('icons/effects/effects.dmi',src,"dent")
		I.pixel_x = P.p_x
		I.pixel_y = P.p_y
		if(P.damage > 30)
			I.icon_state = "bhole"
		//I.dir = pick(NORTH,SOUTH,EAST,WEST) // random scorch design
		overlays += I
		bullet_holes++
*/
	return 1

//Simulated walls can get shot and damaged, but bullets (vs energy guns) do much less.
/turf/simulated/wall/bullet_act(obj/item/projectile/P)
	..()
	var/D = P.damage

	if(D < 1) return 0

	if(P.damage_type == "BRUTE") D = round(D/5) //Bullets do much less to walls and such.
	if(P.damage_type == "TOX") return 0
	take_damage(P.damage)
	if(prob(30 + D))
		P.visible_message("\The [src] is damaged by [P]!")
	return 1

//Hitting an object. These are too numerous so they're staying in their files.
/obj/bullet_act(obj/item/projectile/P)
	if(!CanPass(P,get_turf(src),src.layer) && density)
		src.bullet_ping(P)
		return 1
	else
		return 0

/obj/structure/table/bullet_act(obj/item/projectile/P)
	src.bullet_ping(P)
	health -= round(P.damage/10)
	if (health < 0)
		visible_message("<span class='warning'>[src] breaks down!</span>")
		destroy()
	return 1

/obj/structure/m_barricade/bullet_act(obj/item/projectile/P)
	src.bullet_ping(P)
	health -= round(P.damage/10)
	if (health < 0)
		visible_message("<span class='warning'>[src] breaks down!</span>")
		destroy()
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
