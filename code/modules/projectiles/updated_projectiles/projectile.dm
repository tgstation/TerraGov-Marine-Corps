
//Some debug variables. Toggle them to 1 in order to see the related debug messages. Helpful when testing out formulas.
#define DEBUG_HIT_CHANCE	0
#define DEBUG_HUMAN_DEFENSE	0
#define DEBUG_XENO_DEFENSE	0

//The actual bullet objects.
/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 0
	unacidable = 1
	anchored = 1 //You will not have me, space wind!
	flags_atom = NOINTERACT //No real need for this, but whatever. Maybe this flag will do something useful in the future.
	mouse_opacity = 0
	invisibility = 100 // We want this thing to be invisible when it drops on a turf because it will be on the user's turf. We then want to make it visible as it travels.
	layer = 10

	var/datum/ammo/ammo //The ammo data which holds most of the actual info.

	var/def_zone = "chest"	//So we're not getting empty strings.

	var/yo = null
	var/xo = null

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	var/current 		 = null
	var/atom/shot_from 	 = null // the object which shot us
	var/atom/original 	 = null // the original target clicked
	var/atom/firer 		 = null // Who shot it

	var/turf/target_turf = null
	var/turf/starting 	 = null // the projectile's starting turf

	var/turf/path[]  	 = null
	var/permutated[] 	 = null // we've passed through these atoms, don't try to hit them again

	var/damage = 0
	var/accuracy = 85 //Base projectile accuracy. Can maybe be later taken from the mob if desired.

	var/distance_travelled = 0
	var/in_flight = 0

	New()
		..()
		path = list()
		permutated = list()

	Dispose()
		..()
		in_flight = 0
		ammo = null
		shot_from = null
		original = null
		target_turf = null
		starting = null
		permutated = null
		path = null
		return TA_REVIVE_ME

	Recycle()
		var/blacklist[] = list("ammo","name","desc","icon_state","damage","in_flight","shot_from","original","target_turf","starting", "permutated","path")
		. = ..() + blacklist

	Bumped(atom/A as mob|obj|turf|area)
		if(A && !A in permutated)
			scan_a_turf(A.loc)

	Crossed(AM as mob|obj)
		if(AM && !AM in permutated)
			scan_a_turf(get_turf(AM))

/obj/item/projectile/proc/generate_bullet(ammo_datum, bonus_damage = 0)
	ammo 		= ammo_datum
	name 		= ammo.name
	icon_state 	= ammo.icon_state
	damage 		= ammo.damage + bonus_damage //Mainly for emitters.
	accuracy   += ammo.accuracy
	accuracy   *= rand(config.proj_variance_low-ammo.accuracy_var_low,config.proj_variance_high+ammo.accuracy_var_high)*config.proj_base_accuracy_mult//Rand only works with integers.
	damage     *= rand(config.proj_variance_low-ammo.damage_var_low,config.proj_variance_high+ammo.damage_var_high)*config.proj_base_damage_mult

//Target, firer, shot from. Ie the gun
/obj/item/projectile/proc/fire_at(atom/target,atom/F, atom/S, range = 30,speed = 1)
	if(!original) original = target
	if(!loc) loc = get_turf(F)
	starting = get_turf(src)
	if(starting != loc) loc = starting //Put us on the turf, if we're not.
	target_turf = get_turf(target)
	if(!target_turf || target_turf == starting) //This shouldn't happen, but it can.
		cdel(src)
		return
	firer = F
	if(F) permutated += F //Don't hit the shooter (firer)
	permutated += src //Don't try to hit self.
	shot_from = S
	in_flight = 1

	//If we have the the right kind of ammo, we can fire several projectiles at once.
	if(ammo.bonus_projectiles) ammo.multiple_projectiles(src, range, speed)

	path = getline2(starting,target_turf)

	var/change_x = target_turf.x - starting.x
	var/change_y = target_turf.y - starting.y

	var/angle = round(Get_Angle(starting,target_turf))

	var/matrix/rotate = matrix() //Change the bullet angle.
	rotate.Turn(angle)
	src.transform = rotate

	follow_flightpath(speed,change_x,change_y,range) //pyew!

/obj/item/projectile/proc/each_turf(speed = 1)
	var/new_speed = speed
	distance_travelled++
	if(invisibility && distance_travelled > 1) invisibility = 0 //Let there be light (visibility).
	if(distance_travelled == round(ammo.max_range / 2) && loc) ammo.do_at_half_range(src)
	if(ammo.flags_ammo_behavior & AMMO_ROCKET) //Just rockets for now. Not all explosive ammo will travel like this.
		switch(speed) //Get more speed the longer it travels. Travels pretty quick at full swing.
			if(1)
				if(distance_travelled > 2) new_speed++
			if(2)
				if(distance_travelled > 8) new_speed++
	return new_speed //Need for speed.

/obj/item/projectile/proc/follow_flightpath(speed = 1, change_x, change_y, range) //Everytime we reach the end of the turf list, we slap a new one and keep going.
	set waitfor = 0

	var/dist_since_sleep = 5 //Just so we always see the bullet.
	var/turf/current_turf = get_turf(src)
	var/turf/next_turf
	var/this_iteration = 0
	in_flight = 1
	for(next_turf in path)
		if(!loc || !in_flight) return

		if(distance_travelled >= range)
			ammo.do_at_max_range(src)
			cdel(src)
			return

		if(scan_a_turf(next_turf)) //We hit something! Get out of all of this.
			in_flight = 0
			sleep(0)
			cdel(src)
			return

		loc = next_turf
		speed = each_turf(speed)

		this_iteration++
		if(++dist_since_sleep >= speed)
			//TO DO: Adjust flight position every time we see the projectile.
			//I wonder if I can leave sleep out and just have it stall based on adjustment proc.
			//Might still be too fast though.
			dist_since_sleep = 0
			sleep(1)

		current_turf = get_turf(src)
		if(this_iteration == path.len)
			next_turf = locate(current_turf.x + change_x, current_turf.y + change_y, current_turf.z)
			if(current_turf && next_turf)
				path = getline2(current_turf,next_turf) //Build a new flight path.
				if(path.len && src)
					follow_flightpath(speed, change_x, change_y, range) //Onwards!

/obj/item/projectile/proc/scan_a_turf(turf/T)
	if(!istype(T)) return //Not a turf. Back out.
	if(T.density) //Hit a wall, back out.
		ammo.on_hit_turf(T,src)
		if(T && T.loc) T.bullet_act(src)
		return 1
	if(firer && T == firer.loc) return //Is it our turf? Continue on if it is.
	if(ammo.flags_ammo_behavior & AMMO_EXPLOSIVE && T == target_turf) //Explosive ammo always explodes on the turf of the clicked target.
		ammo.on_hit_turf(T,src)
		if(T && T.loc) T.bullet_act(src)
		return 1
	if(!T.contents.len) return //Nothing here.
	for(var/atom/A in T)
		if(A in permutated) continue

		//Don't need to check for turfs inside turfs. Turfs can't be in turfs.
		//The space flight check never worked anyway, because T.contents.len above would cancel it.

		if(isobj(A))
			if(istype(A,/obj/structure/window) && (ammo.flags_ammo_behavior & AMMO_ENERGY))
				continue

			if(A == original) //Specifically clicking on eggs / huggers
				if(istype(A,/obj/effect/alien/egg) || istype(A,/obj/item/clothing/mask/facehugger))
					ammo.on_hit_obj(A,src)
					if(A && A.loc) A.bullet_act(src)
					return 1

			if(!A.density) //We're scanning a non dense object.
				continue

			//Scan for tables, barricades, and other assorted larger nonsense
			if( (!A.throwpass && A.layer >= 3) || roll_to_hit_obj(firer,A))
				ammo.on_hit_obj(A,src)
				if(A && A.loc) A.bullet_act(src)
				return 1

		else if(ismob(A))
			if( isliving(A) && roll_to_hit_mob(firer,A) && (A:lying == 0 || A == original))
				ammo.on_hit_mob(A,src)
				if(A && A.loc) A.bullet_act(src)
				return 1

//----------------------------------------------------------
		    	//				    	\\
			    //  HITTING THE TARGET  \\
			    //						\\
			    //						\\
//----------------------------------------------------------


/obj/item/projectile/proc/roll_to_hit_mob(atom/shooter,mob/living/target)
	permutated += target //Don't want to hit them again, no matter what the outcome.

	var/acc = accuracy //We want a temporary variable so accuracy doesn't change every time the bullet misses.
	#if DEBUG_HIT_CHANCE
	world << "<span class='debuginfo'>Base accuracy is <b>[acc]</b></span>"
	#endif
	if(distance_travelled <= (ammo.accurate_range + rand(0,2)) ) //Less to or equal.
		if(ammo.flags_ammo_behavior & AMMO_SNIPER) 	acc -= (ammo.max_range - distance_travelled) * 4.8
		else if(distance_travelled <= 2)		acc += 25
	else acc -= (ammo.flags_ammo_behavior & AMMO_SNIPER) ? (distance_travelled * 1.3) : (distance_travelled * 5)
	#if DEBUG_HIT_CHANCE
	world << "<span class='debuginfo'>Final accuracy is <b>[acc]</b></span>"
	#endif

	var/hit_chance = max(5,acc) //At least 5%.
	if(target.lying && target.stat) hit_chance += 15 //Bonus hit against unconscious people.

	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		if( ammo.flags_ammo_behavior & AMMO_SKIPS_HUMANS && target_human.get_target_lock() ) return
		var/mob/living/carbon/human/shooter_human = shooter
		if( istype(shooter_human) && (shooter_human.faction == target_human.faction || target_human.m_intent == "walk") ) hit_chance -= 15
	else if(isXeno(target))
		if(ammo.flags_ammo_behavior & AMMO_SKIPS_ALIENS) return
		var/mob/living/carbon/Xenomorph/target_xeno = target
		if(target_xeno.big_xeno)	hit_chance += 10
		else						hit_chance -= 10

	if(isliving(shooter))
		var/mob/living/shooter_living = shooter
		if( !can_see(shooter_living,target) ) hit_chance -= 15 //Can't see the target
		hit_chance -= round((shooter_living.maxHealth - shooter_living.health) / 4) //Less chance to hit when injured.
	#if DEBUG_HIT_CHANCE
	world << "<span class='debuginfo'>Calculated hit chance is <b>[hit_chance]</b></span>"
	#endif

	var/hit_roll
	var/critical_miss = rand(config.critical_chance_low,config.critical_chance_high)
	var/i = 0
	while(++i <= 2 && hit_chance > 0) //This runs twice if necessary.
		hit_roll 					= rand(0,100) //Our randomly generated roll.
		if(hit_roll < 25) def_zone 	= pick(base_miss_chance)
		hit_chance 				   -= base_miss_chance[def_zone] //Reduce accuracy based on spot.

		switch(i)
			if(1)
				if(hit_chance > hit_roll) 			return 1 //Hit
				if( hit_chance < (hit_roll - 20) ) 	break //Outright miss.
				def_zone 	  = pick(base_miss_chance) //We're going to pick a new target and let this run one more time.
				hit_chance   -= 10 //If you missed once, the next go around will be harder to hit.
			if(2)
				if(prob(critical_miss) ) 			break //Critical miss on the second go around.
				if(hit_chance > hit_roll) 			return 1
	if (!target.lying)
		animatation_displace_reset(target)
		if(ammo.sound_miss) target << sound(pick(ammo.sound_miss))
		target.visible_message("<span class='avoidharm'>[src] misses [target]!</span>","<span class='avoidharm'>[src] narrowly misses you!</span>")

/obj/item/projectile/proc/roll_to_hit_obj(atom/shooter,obj/target)
	permutated += target
	var/obj/structure/table/target_table = target
	if( (istype(target_table) && target_table.flipped) || istype(target,/obj/structure/m_barricade) )
		var/chance = 0
		if(dir == reverse_direction(target.dir)) chance = 95
		else if(dir == target.dir) chance = 1
		else chance = 20
		if(prob(chance)) return 1

/obj/item/projectile/proc/play_damage_effect(mob/M)
	if(ammo.sound_hit) playsound(M, pick(ammo.sound_hit), 120, 1)
	if(M.stat != DEAD) animation_flash_color(M)

//----------------------------------------------------------
				//				    \\
				//    OTHER PROCS	\\
				//					\\
				//					\\
//----------------------------------------------------------

/atom/proc/bullet_act(obj/item/projectile/P)
	return density

/mob/dead/bullet_act(/obj/item/projectile/P)
	return

/mob/living/bullet_act(obj/item/projectile/P)
	if(!P) return

	var/damage = max(0, ( P.damage - (P.distance_travelled * P.ammo.damage_bleed) ) )

	if(P.ammo.debilitate && stat != DEAD && ( damage || (P.ammo.flags_ammo_behavior & AMMO_IGNORE_RESIST) ) )
		apply_effects(arglist(P.ammo.debilitate))

	if(damage)
		bullet_message(P)
		apply_damage(damage, P.ammo.damage_type, P.def_zone, 0, 0, 0, P)
		P.play_damage_effect(src)

		if(P.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
			adjust_fire_stacks(rand(6,10))
			IgniteMob()
			emote("scream")
			src << "<span class='highdanger'>You burst into flames!! Stop drop and roll!</span>"
	return 1

/*
Fixed and rewritten. For best results, the defender's combined armor for an area should not exceed 100.
If it does, it's going to be really hard to damage them with anything less than an armor penetrating
sniper rifle or something similar. I suppose that's to be expected though.
Normal range for a defender's bullet resist should be something around 30-50. ~N
*/
/mob/living/carbon/human/bullet_act(obj/item/projectile/P)
	if(!P) return

	flash_weak_pain()

	var/damage = max(0, ( P.damage - (P.distance_travelled * P.ammo.damage_bleed) ) )
	#if DEBUG_HUMAN_DEFENSE
	world << "<span class='debuginfo'>Initial damage is: <b>[damage]</b></span>"
	#endif

	//Any projectile can decloak a predator. It does defeat one free bullet though.
	if(gloves)
		var/obj/item/clothing/gloves/yautja/Y = gloves
		if(istype(Y) && Y.cloaked)
			if( P.ammo.flags_ammo_behavior & (AMMO_ROCKET|AMMO_ENERGY|AMMO_XENO_ACID) ) //<--- These will auto uncloak.
				Y.decloak(src) //Continue on to damage.
			else if(rand(0,100) < 20)
				Y.decloak(src)
				return //Absorb one free bullet.
			//Else we're moving on to damage.

	//Shields
	if( !(P.ammo.flags_ammo_behavior & AMMO_ROCKET) ) //No, you can't block rockets.
		if( P.dir == reverse_direction(dir) && check_shields(damage * 0.65, "[P]") )
			P.ammo.on_shield_block(src)
			bullet_ping(P)
			return

	var/datum/organ/external/organ = get_organ(check_zone(P.def_zone)) //Let's finally get what organ we actually hit.
	if(!organ) return//Nope. Gotta shoot something!

	//Run armor check. We won't bother if there is no damage being done.
	if( damage > 0 && !(P.ammo.flags_ammo_behavior & AMMO_IGNORE_ARMOR) )
		var/armor //Damage types don't correspond to armor types. We are thus merging them.
		switch(P.ammo.damage_type)
			if(BRUTE) armor = P.ammo.flags_ammo_behavior & AMMO_ROCKET ? getarmor_organ(organ, "bomb") : getarmor_organ(organ, "bullet")
			if(BURN) armor = P.ammo.flags_ammo_behavior & AMMO_ENERGY ? getarmor_organ(organ, "energy") : getarmor_organ(organ, "laser")
			if(TOX, OXY, CLONE) armor = getarmor_organ(organ, "bio")
			else armor = getarmor_organ(organ, "energy") //Won't be used, but just in case.
		#if DEBUG_HUMAN_DEFENSE
		world << "<span class='debuginfo'>Initial armor is: <b>[armor]</b></span>"
		#endif
		armor -= P.ammo.penetration//Minus armor penetration from the bullet.
		#if DEBUG_HUMAN_DEFENSE
		world << "<span class='debuginfo'>Adjusted armor after penetration is: <b>[armor]</b></span>"
		#endif

		if(armor > 0) //Armor check. We should have some to continue.
			 /*Automatic damage soak due to armor. Greater difference between armor and damage, the more damage
			 soaked. Small caliber firearms aren't really effective against combat armor.*/
			var/armor_soak	 = round( ( armor / damage ) * 10 )//Setting up for next action.
			var/critical_hit = rand(config.critical_chance_low,config.critical_chance_high)
			damage 			-= prob(critical_hit) ? 0 : armor_soak //Chance that you won't soak the initial amount.
			armor			-= round(armor_soak * config.base_armor_resist_low) //If you still have armor left over, you generally should, we subtract the soak.
											  		   //This gives smaller calibers a chance to actually deal damage.
			#if DEBUG_HUMAN_DEFENSE
			world << "<span class='debuginfo'>Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[armor]</b></span>"
			#endif
			var/i = 0
			if(damage)
				while(armor > 0 && i < 2) //Going twice. Armor has to exist to continue. Post increment.
					if(prob(armor))
						armor_soak 	 = round(damage * 0.5)  //Cut it in half.
						armor 		-= armor_soak * config.base_armor_resist_high
						damage 		-= armor_soak
						#if DEBUG_HUMAN_DEFENSE
						world << "<span class='debuginfo'>Currently soaked: <b>[armor_soak]</b>. Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[armor]</b></span>"
						#endif
					else break //If we failed to block the damage, it's time to get out of the loop.
					i++
			if(i || damage <= 5) src << "\blue Your armor [ i == 2 ? "absorbs the force of [P]!" : "softens the impact of [P]!" ]"
			if(damage <= 0)
				damage = 0
				if(P.ammo.sound_armor) playsound(src, pick(P.ammo.sound_armor), 120, 1)

	if(P.ammo.debilitate && stat != DEAD && ( damage || (P.ammo.flags_ammo_behavior & AMMO_IGNORE_RESIST) ) )  //They can't be dead and damage must be inflicted (or it's a xeno toxin).
		//Predators are immune to these effects to cut down on the stun spam. This should later be moved to their apply_effects proc, but right now they're just humans.
		if(!isYautja(src)) apply_effects(arglist(P.ammo.debilitate))

	bullet_message(P) //We still want this, regardless of whether or not the bullet did damage. For griefers and such.

	if(damage)
		apply_damage(damage, P.ammo.damage_type, P.def_zone)
		P.play_damage_effect(src)
		if(P.ammo.shrapnel_chance > 0 && prob(P.ammo.shrapnel_chance + round(damage / 10) ) )
			var/obj/item/weapon/shard/shrapnel/shrap = new()
			shrap.name = "[P.name] shrapnel"
			shrap.desc = "[shrap.desc] It looks like it was fired from [P.shot_from ? P.shot_from : "something unknown"]."
			shrap.loc = organ
			organ.embed(shrap)
			if(!stat)
				emote("scream")
				src << "<span class='highdanger'>You scream in pain as the impact sends <B>shrapnel</b> into the wound!</span>"

		if(P.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
			adjust_fire_stacks(rand(6,11))
			IgniteMob()
			if(!stat)
				emote("scream")
				src << "<span class='highdanger'>You burst into flames!! Stop drop and roll!</span>"
		return 1

//Deal with xeno bullets.
/mob/living/carbon/Xenomorph/bullet_act(obj/item/projectile/P)
	if(!P || !istype(P)) return
	if(P.ammo.flags_ammo_behavior & (AMMO_XENO_ACID|AMMO_XENO_TOX) ) //Aliens won't be harming aliens.
		bullet_ping(P)
		return

	flash_weak_pain()

	var/damage = max(0, ( P.damage - (P.distance_travelled * P.ammo.damage_bleed) ) ) //Has to be at least zero, no negatives.
	#if DEBUG_XENO_DEFENSE
	world << "<span class='debuginfo'>Initial damage is: <b>[damage]</b></span>"
	#endif

	var/armor 		= armor_deflection - P.ammo.penetration//Initial armor.
	var/armor_pass 	= 0
	if( damage && !(P.ammo.flags_ammo_behavior & AMMO_IGNORE_ARMOR) ) //No point in these checks if there is no damage.
		armor += guard_aura ? (guard_aura * 5) : 0 //Bonus armor from pheroes.
		if(istype(src,/mob/living/carbon/Xenomorph/Crusher)) //Crusher resistances. Crushers get a lot of armor, with a base of 95 at ancient status.
			var/mob/living/carbon/Xenomorph/Crusher/current_crusher = src
			armor += round(current_crusher.momentum / 3) //Some armor deflection when charging.
			if(P.dir == current_crusher.dir) armor = max(0, armor - (armor_deflection * config.xeno_armor_resist_low) ) //Both facing same way -- ie. shooting from behind.
			else if(P.dir == reverse_direction(current_crusher.dir)) armor += round(armor_deflection * config.xeno_armor_resist_low) //We are facing the bullet.
			//Otherwise use the standard armor deflection for crushers.
			#if DEBUG_XENO_DEFENSE
			world << "<span class='debuginfo'>Adjusted crusher armor is: <b>[armor]</b></span>"
			#endif

		#if DEBUG_XENO_DEFENSE
		world << "<span class='debuginfo'>Adjusted armor is: <b>[armor]</b></span>"
		#endif
		var/critical_hit	 = rand(config.critical_chance_low,config.critical_chance_high)
		armor_pass 	 	 	 = round( ( armor * damage * config.xeno_armor_resist_low ) * 0.01 )
		armor				-= prob(critical_hit) ? round(armor*0.5) : armor_pass //Small chance to completely ignore armor.
		#if DEBUG_XENO_DEFENSE
		world << "<span class='debuginfo'>Armor after initial soak is: <b>[armor]</b>. Pass was : <b>[armor_pass]</b></span>"
		#endif

	armor = armor < 0 ? 0 : armor

	if(damage)
		var/i = 0
		while(armor > 0 && ++i <= 2)
			if(prob(armor))
				damage = 0
				break
			else
				armor_pass	 = damage * config.xeno_armor_resist_high
				armor 		-= armor_pass//One more chance, with a lower armor value.
			#if DEBUG_XENO_DEFENSE
			world << "<span class='debuginfo'>Armor after first pass is: <b>[armor]</b>. Pass was : <b>[armor_pass]</b></span>"
			#endif

	if(!damage)
		bullet_ping(P)
		visible_message("<span class='avoidharm'>The [src]'s thick exoskeleton deflects [P]!</span>","<span class='avoidharm'>Your thick exoskeleton deflected [P]!</span>")
		return

	bullet_message(P) //Message us about the bullet, since damage was inflicted.
	P.play_damage_effect(src)

	apply_damage(damage,P.ammo.damage_type, P.def_zone)	//Deal the damage.
	if(!stat && prob(5 + round(damage / 4)))
		var/pain_emote = prob(70) ? "hiss" : "roar"
		emote(pain_emote)
	if(P.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
		if(fire_immune)
			if(!stat) src << "<span class='avoidharm'>You shrug off some persistent flames.</span>"
		else
			adjust_fire_stacks(rand(2,6) + round(damage / 8))
			IgniteMob()
			visible_message("<span class='danger'>[src] bursts into flames!</span>","<span class='xenodanger'>You burst into flames!! Auuugh! Resist to put out the flames!</span>")
	updatehealth()

	return 1

/turf/bullet_act(obj/item/projectile/P)
	if(!P || !density) return //It's just an empty turf

	bullet_ping(P)

	var/turf/target_turf = P.loc
	if(!istype(target_turf)) return //The bullet's not on a turf somehow.

	var/list/mobs_list = list() //Let's built a list of mobs on the bullet turf and grab one.
	for(var/mob/living/L in target_turf)
		if(L in P.permutated) continue
		mobs_list += L

	if(mobs_list.len)
		var/mob/living/picked_mob = pick(mobs_list) //Hit a mob, if there is one.
		if(istype(picked_mob) && P.firer && P.roll_to_hit_mob(P.firer,picked_mob))
			picked_mob.bullet_act(P)
			return 1
/*
	//This is probably going to create lag, so I'm leaving it commented out. Maybe in the future we can enable this.
	//Right now extra effects like ping and muzzle flash are the greatest resource hogs when it comes to the fire cycle.
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
	var/damage = P.damage
	if(damage < 1) return

	switch(P.ammo.damage_type)
		if(BRUTE) 	damage = P.ammo.flags_ammo_behavior & AMMO_ROCKET ? round(damage * 10) : damage //Bullets do much less to walls and such.
		if(BURN)	damage = P.ammo.flags_ammo_behavior & (AMMO_ENERGY|AMMO_XENO_ACID) ? round(damage * 7) : damage
		else return
	take_damage(damage)
	if(prob(30 + damage)) P.visible_message("<span class='warning'>[src] is damaged by [P]!</span>")
	return 1

//Hitting an object. These are too numerous so they're staying in their files.
//Why are there special cases listed here? Oh well, whatever. ~N
/obj/bullet_act(obj/item/projectile/P)
	if(!CanPass(P,get_turf(src),src.layer) && density)
		bullet_ping(P)
		return 1

/obj/structure/table/bullet_act(obj/item/projectile/P)
	src.bullet_ping(P)
	health -= round(P.damage/2)
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

//----------------------------------------------------------
					//				    \\
					//    OTHER PROCS	\\
					//					\\
					//					\\
//----------------------------------------------------------


//This is where the bullet bounces off.
/atom/proc/bullet_ping(obj/item/projectile/P)
	set waitfor = 0
	if(!P || !P.ammo.ping) return
	if(prob(65))
		if(P.ammo.sound_bounce) playsound(src, pick(P.ammo.sound_bounce), 120, 1)
		var/image/reusable/ping = rnew(/image/reusable, list('icons/obj/projectiles.dmi',src,P.ammo.ping,10))
		var/angle = (P.firer && prob(60)) ? round(Get_Angle(P.firer,src)) : round(rand(1,359))
		ping.pixel_x += rand(-6,6)
		ping.pixel_y += rand(-6,6)

		var/matrix/rotate = matrix()
		rotate.Turn(angle)
		ping.transform = rotate

		for(var/mob/M in viewers(src))
			M << ping

		cdel(ping,,3)

/mob/proc/bullet_message(obj/item/projectile/P)
	if(!P) return

	if(P.ammo.flags_ammo_behavior & AMMO_IS_SILENCED)
		src << "[isXeno(src) ? "<span class='xenodanger'>" : "<span class='highdanger'>" ]You've been shot in the [parse_zone(P.def_zone)] by [P.name]!</span>"
	else
		visible_message("<span class='danger'>[name] is hit by the [P.name] in the [parse_zone(P.def_zone)]!</span>")

	if(ismob(P.firer))
		var/mob/firingMob = P.firer
		if(ishuman(firingMob) && ishuman(src) && firingMob.mind && !firingMob.mind.special_role && mind && !mind.special_role) //One human shot another, be worried about it but do everything basically the same //special_role should be null or an empty string if done correctly
			attack_log += "\[[time_stamp()]\] <b>[firingMob]/[firingMob.ckey]</b> shot <b>[src]/[ckey]</b> with a <b>[P]</b>"
			P.firer:attack_log += "\[[time_stamp()]\] <b>[firingMob]/[firingMob.ckey]</b> shot <b>[src]/[ckey]</b> with a <b>[P]</b>"
			msg_admin_ff("[firingMob] ([firingMob.ckey]) shot [src] ([ckey]) with a [P] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[P.firer.x];Y=[P.firer.y];Z=[P.firer.z]'>JMP</a>) (<a href='?priv_msg=\ref[firingMob.client]'>PM</a>)")
		else
			attack_log += "\[[time_stamp()]\] <b>[firingMob]/[firingMob.ckey]</b> shot <b>[src]/[src.ckey]</b> with a <b>[P]</b>"
			P.firer:attack_log += "\[[time_stamp()]\] <b>[firingMob]/[firingMob.ckey]</b> shot <b>[src]/[ckey]</b> with a <b>[P]</b>"
			msg_admin_attack("[firingMob] ([firingMob.ckey]) shot [src] ([ckey]) with a [P] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[P.firer.x];Y=[P.firer.y];Z=[P.firer.z]'>JMP</a>)")
		return

	if(P.firer)
		attack_log += "\[[time_stamp()]\] <b>[P.firer]</b> shot <b>[src]/[ckey]</b> with a <b>[P]</b>"
		msg_admin_attack("[P.firer] shot [src] ([ckey]) with a [P] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[P.firer.x];Y=[P.firer.y];Z=[P.firer.z]'>JMP</a>)")
	else
		attack_log += "\[[time_stamp()]\] <b>SOMETHING??</b> shot <b>[src]/[ckey]</b> with a <b>[P]</b>"
		msg_admin_attack("SOMETHING?? shot [src] ([ckey]) with a [P])")

//Abby -- Just check if they're 1 tile horizontal or vertical, no diagonals
/proc/get_adj_simple(atom/Loc1,atom/Loc2)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	if(dx == 0) //left or down of you
		if(dy == -1 || dy == 1)
			return 1
	if(dy == 0) //above or below you
		if(dx == -1 || dx == 1)
			return 1

#undef DEBUG_HIT_CHANCE
#undef DEBUG_HUMAN_DEFENSE
#undef DEBUG_XENO_DEFENSE
