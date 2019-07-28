
//Some debug variables. Toggle them to 1 in order to see the related debug messages. Helpful when testing out formulas.
#define DEBUG_HIT_CHANCE	0
#define DEBUG_HUMAN_DEFENSE	0
#define DEBUG_XENO_DEFENSE	0
#define DEBUG_CREST_DEFENSE	0

//The actual bullet objects.
/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "bullet"
	density = FALSE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	anchored = TRUE //You will not have me, space wind!
	flags_atom = NOINTERACT //No real need for this, but whatever. Maybe this flag will do something useful in the future.
	mouse_opacity = 0
	invisibility = 100 // We want this thing to be invisible when it drops on a turf because it will be on the user's turf. We then want to make it visible as it travels.
	layer = FLY_LAYER

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

	var/damage_falloff = 0 //how many damage point the projectile loses per tiles travelled

	var/scatter = 0

	var/distance_travelled = 0
	var/in_flight = 0

	var/projectile_speed = 0
	var/armor_type = null

/obj/item/projectile/New()
	. = ..()
	path = list()
	permutated = list()

/obj/item/projectile/Destroy()
	in_flight = 0
	ammo = null
	shot_from = null
	original = null
	target_turf = null
	starting = null
	permutated = null
	path = null
	return ..()

/obj/item/projectile/Bumped(atom/A as mob|obj|turf|area)
	if(A && !A in permutated)
		scan_a_turf(A.loc)

/obj/item/projectile/Crossed(AM as mob|obj)
	if(AM && !AM in permutated)
		scan_a_turf(get_turf(AM))

/obj/item/projectile/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_NERF_BEAM) && ammo.flags_ammo_behavior & AMMO_ENERGY)
		damage -= max(damage - ammo.damage * 0.5, 0)

/obj/item/projectile/proc/generate_bullet(ammo_datum, bonus_damage = 0, reagent_multiplier = 0)
	ammo 		= ammo_datum
	name 		= ammo.name
	icon_state 	= ammo.icon_state
	damage 		= ammo.damage + bonus_damage //Mainly for emitters.
	scatter		= ammo.scatter
	accuracy   += ammo.accuracy
	accuracy   *= rand(CONFIG_GET(number/combat_define/proj_variance_low)-ammo.accuracy_var_low, CONFIG_GET(number/combat_define/proj_variance_high)+ammo.accuracy_var_high) * CONFIG_GET(number/combat_define/proj_base_accuracy_mult)//Rand only works with integers.
	damage     *= rand(CONFIG_GET(number/combat_define/proj_variance_low)-ammo.damage_var_low, CONFIG_GET(number/combat_define/proj_variance_high)+ammo.damage_var_high) * CONFIG_GET(number/combat_define/proj_base_damage_mult)
	damage_falloff = ammo.damage_falloff
	armor_type = ammo.armor_type

//Target, firer, shot from. Ie the gun
/obj/item/projectile/proc/fire_at(atom/target,atom/F, atom/S, range = 30,speed = 1)
	projectile_speed += speed
	if(!original) original = target
	if(!loc) loc = get_turf(F)
	starting = get_turf(src)
	if(starting != loc) loc = starting //Put us on the turf, if we're not.
	target_turf = get_turf(target)
	if(!target_turf || target_turf == starting) //This shouldn't happen, but it can.
		qdel(src)
		return
	firer = F
	if(F) permutated += F //Don't hit the shooter (firer)
	permutated += src //Don't try to hit self.
	shot_from = S
	in_flight = 1

	setDir(get_dir(loc, target_turf))

	GLOB.round_statistics.total_projectiles_fired++
	if(ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		GLOB.round_statistics.total_bullets_fired++
		if(ammo.bonus_projectiles_amount)
			GLOB.round_statistics.total_bullets_fired += ammo.bonus_projectiles_amount

	//If we have the the right kind of ammo, we can fire several projectiles at once.
	if(ammo.bonus_projectiles_amount && ammo.bonus_projectiles_type) ammo.fire_bonus_projectiles(src)

	path = getline(starting,target_turf)

	var/change_x = target_turf.x - starting.x
	var/change_y = target_turf.y - starting.y

	var/angle = round(Get_Angle(starting,target_turf))

	var/matrix/rotate = matrix() //Change the bullet angle.
	rotate.Turn(angle)
	src.transform = rotate

	follow_flightpath(projectile_speed,change_x,change_y,range) //pyew!

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
		if(!loc || gc_destroyed || !in_flight) return

		if(distance_travelled >= range)
			ammo.do_at_max_range(src)
			qdel(src)
			return

		var/proj_dir = get_dir(current_turf, next_turf)
		if(proj_dir & (proj_dir-1)) //diagonal direction
			if(!current_turf.Adjacent(next_turf)) //we can't reach the next turf
				ammo.on_hit_turf(current_turf,src)
				current_turf.bullet_act(src)
				in_flight = 0
				sleep(0)
				qdel(src)
				return

		if(scan_a_turf(next_turf)) //We hit something! Get out of all of this.
			in_flight = 0
			sleep(0)
			qdel(src)
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
				path = getline(current_turf,next_turf) //Build a new flight path.
				if(path.len && src) //TODO look into this. This should always be true, but it can fail, apparently, against DCed people who fall down. Better yet, redo this.
					distance_travelled-- //because the new follow_flightpath() repeats the last step.
					follow_flightpath(speed, change_x, change_y, range) //Onwards!
				else
					qdel(src)
					return
			else //To prevent bullets from getting stuck in maps like WO.
				qdel(src)
				return

/obj/item/projectile/proc/scan_a_turf(turf/T)
	// Not a turf, keep moving
	if(!istype(T))
		return FALSE

	if(T.density) // Handle wall hit
		ammo.on_hit_turf(T,src)

		if(T?.loc)
			T.bullet_act(src)

		return TRUE

	// Firer's turf, keep moving
	if(firer && T == firer.loc)
		return FALSE

	// Explosive ammo always explodes on the turf of the clicked target
	if(!QDELETED(src) && ammo.flags_ammo_behavior & AMMO_EXPLOSIVE && T == target_turf)
		ammo.on_hit_turf(T,src)
		if(T?.loc)
			T.bullet_act(src)
		return TRUE

	// Empty turf, keep moving
	if(!length(T.contents))
		return FALSE

	for(var/a in T)
		var/atom/movable/A = a
		// If we've already handled this atom, don't do it again
		if(A in permutated)
			continue

		permutated += A // Don't want to hit them again, no matter what the outcome

		var/hit_chance = A.get_projectile_hit_chance(src) // Calculated from combination of both ammo accuracy and gun accuracy

		if(!hit_chance)
			continue

		if(isobj(A))
			ammo.on_hit_obj(A,src)
			if(A?.loc)
				A.bullet_act(src)
			return TRUE

		if(!isliving(A))
			continue

		if(shot_from?.sniper_target(A) && A != shot_from.sniper_target(A)) //First check to see if we've actually got anyone targeted; If we've singled out someone with a targeting laser, forsake all others
			continue
		var/mob_is_hit = FALSE
		var/mob/living/L = A

		var/hit_roll
		var/critical_miss = rand(CONFIG_GET(number/combat_define/critical_chance_low), CONFIG_GET(number/combat_define/critical_chance_high))
		var/i = 0
		while(++i <= 2 && hit_chance > 0) // This runs twice if necessary
			hit_roll 					= rand(0, 99) //Our randomly generated roll
			#if DEBUG_HIT_CHANCE
			to_chat(world, "DEBUG: Hit Chance 1: [hit_chance], Hit Roll: [hit_roll]")
			#endif
			if(hit_roll < 25) //Sniper targets more likely to hit
				if(shot_from && !shot_from.sniper_target(A) || !shot_from) //Avoid sentry run times
					def_zone = pick(GLOB.base_miss_chance)	// Still hit but now we might hit the wrong body part

			if(shot_from && !shot_from.sniper_target(A)) //Avoid sentry run times
				hit_chance -= GLOB.base_miss_chance[def_zone] // Reduce accuracy based on spot.
				#if DEBUG_HIT_CHANCE
				to_chat(world, "Hit Chance 2: [hit_chance]")
				#endif

			switch(i)
				if(1)
					if(hit_chance > hit_roll)
						mob_is_hit = TRUE
						break //Hit
					if( hit_chance < (hit_roll - 20) )
						break //Outright miss.
					def_zone 	  = pick(GLOB.base_miss_chance) //We're going to pick a new target and let this run one more time.
					hit_chance   -= 10 //If you missed once, the next go around will be harder to hit.
				if(2)
					if(prob(critical_miss) )
						break //Critical miss on the second go around.
					if(hit_chance > hit_roll)
						mob_is_hit = TRUE
						break
		if(mob_is_hit)
			ammo.on_hit_mob(L,src)
			if(L?.loc)
				L.bullet_act(src)
			return TRUE
		else if (!L.lying)
			animatation_displace_reset(L)
			if(ammo.sound_miss) L.playsound_local(get_turf(L), ammo.sound_miss, 75, 1)
			L.visible_message("<span class='avoidharm'>[src] misses [L]!</span>","<span class='avoidharm'>[src] narrowly misses you!</span>", null, 4)

//----------------------------------------------------------
			//				    	\\
			//  HITTING THE TARGET  \\
			//						\\
			//						\\
//----------------------------------------------------------


//returns probability for the projectile to hit us.
/atom/movable/proc/get_projectile_hit_chance(obj/item/projectile/P)
	return 0

//obj version just returns true or false.
/obj/get_projectile_hit_chance(obj/item/projectile/P)
	if(!density)
		return FALSE

	if(layer >= OBJ_LAYER || src == P.original)
		return TRUE

/obj/structure/get_projectile_hit_chance(obj/item/projectile/P)
	if(!density) //structure is passable
		return FALSE

	if(src == P.original) //clicking on the structure itself hits the structure
		return TRUE

	if(!anchored) //unanchored structure offers no protection.
		return FALSE

	if(!throwpass)
		return TRUE

	if(P.ammo.flags_ammo_behavior & AMMO_SNIPER || P.ammo.flags_ammo_behavior & AMMO_SKIPS_HUMANS || P.ammo.flags_ammo_behavior & AMMO_ROCKET) //sniper, rockets and IFF rounds bypass cover
		return FALSE

	if(!(flags_atom & ON_BORDER))
		return FALSE //window frames, unflipped tables

	if(!( P.dir & reverse_direction(dir) || P.dir & dir))
		return FALSE //no effect if bullet direction is perpendicular to barricade

	var/distance = P.distance_travelled - 1
	if(distance < P.ammo.barricade_clear_distance)
		return FALSE

	var/coverage = 90 //maximum probability of blocking projectile
	var/distance_limit = 6 //number of tiles needed to max out block probability
	var/accuracy_factor = 50 //degree to which accuracy affects probability   (if accuracy is 100, probability is unaffected. Lower accuracies will increase block chance)

	var/hitchance = min(coverage, (coverage * distance/distance_limit) + accuracy_factor * (1 - P.accuracy/100))
	//to_chat(world, "Distance travelled: [distance]  |  Accuracy: [P.accuracy]  |  Hit chance: [hitchance]")
	return prob(hitchance)

/obj/structure/window/get_projectile_hit_chance(obj/item/projectile/P)
	if(P.ammo.flags_ammo_behavior & AMMO_ENERGY || ( (flags_atom & ON_BORDER) && P.dir != dir && P.dir != reverse_direction(dir) ) )
		return FALSE
	else
		return TRUE

/obj/machinery/door/poddoor/railing/get_projectile_hit_chance(obj/item/projectile/P)
	return src == P.original

/obj/effect/alien/egg/get_projectile_hit_chance(obj/item/projectile/P)
	return src == P.original

/obj/effect/alien/resin/trap/get_projectile_hit_chance(obj/item/projectile/P)
	return src == P.original

/obj/item/clothing/mask/facehugger/get_projectile_hit_chance(obj/item/projectile/P)
	return src == P.original

/mob/living/get_projectile_hit_chance(obj/item/projectile/P)

	if(lying && src != P.original)
		return 0

	if(P.ammo.flags_ammo_behavior & (AMMO_XENO_ACID|AMMO_XENO_TOX))
		if(isnestedhost(src) || stat == DEAD)
			return FALSE

	. = P.accuracy //We want a temporary variable so accuracy doesn't change every time the bullet misses.
	#if DEBUG_HIT_CHANCE
	to_chat(world, "<span class='debuginfo'>Base accuracy is <b>[P.accuracy]; scatter:[P.scatter]; distance:[P.distance_travelled]</b></span>")
	#endif

	if (P.distance_travelled <= P.ammo.accurate_range + rand(0, 2))
	// If bullet stays within max accurate range + random variance
		if (P.distance_travelled <= P.ammo.point_blank_range)
			//If bullet within point blank range, big accuracy buff
			. += 25
		else if ((P.ammo.flags_ammo_behavior & AMMO_SNIPER) && P.distance_travelled <= P.ammo.accurate_range_min)
			// Snipers have accuracy falloff at closer range before point blank
			. -= (P.ammo.accurate_range_min - P.distance_travelled) * 5
	else
		. -= (P.ammo.flags_ammo_behavior & AMMO_SNIPER) ? (P.distance_travelled * 3) : (P.distance_travelled * 5)
		// Snipers have a smaller falloff constant due to longer max range


	#if DEBUG_HIT_CHANCE
	to_chat(world, "<span class='debuginfo'>Final accuracy is <b>[.]</b></span>")
	#endif

	. = max(5, .) //default hit chance is at least 5%.
	if(lying && stat) . += 15 //Bonus hit against unconscious people.

	if(isliving(P.firer))
		var/mob/living/shooter_living = P.firer
		if( !can_see(shooter_living,src) )
			. -= 15 //Can't see the target (Opaque thing between shooter and target)
		if(shooter_living.last_move_intent < world.time - 20) //We get a nice accuracy bonus for standing still.
			. += 15
		else if(shooter_living.m_intent == MOVE_INTENT_WALK) //We get a decent accuracy bonus for walking
			. += 10

	if(ishuman(P.firer))
		var/mob/living/carbon/human/shooter_human = P.firer
		. -= round(max(30,(shooter_human.traumatic_shock) * 0.2)) //Chance to hit declines with pain, being reduced by 0.2% per point of pain.
		if(shooter_human.stagger)
			. -= 30 //Being staggered fucks your aim.
		if(shooter_human.marksman_aura) // Accuracy bonus from active focus order: flat bonus + bonus per tile traveled
			. += shooter_human.marksman_aura * CONFIG_GET(number/combat_define/focus_base_bonus)
			. += P.distance_travelled * shooter_human.marksman_aura * CONFIG_GET(number/combat_define/focus_per_tile_bonus)


/mob/living/carbon/human/get_projectile_hit_chance(obj/item/projectile/P)
	. = ..()
	if(.)
		if(P.ammo.flags_ammo_behavior & AMMO_SKIPS_HUMANS && get_target_lock(P.ammo.iff_signal))
			return 0
		if(mobility_aura)
			. -= mobility_aura * 5
		var/mob/living/carbon/human/shooter_human = P.firer
		if(istype(shooter_human))
			if(shooter_human.faction == faction || m_intent == MOVE_INTENT_WALK)
				. -= 15


/mob/living/carbon/xenomorph/get_projectile_hit_chance(obj/item/projectile/P)
	. = ..()
	if(.)
		if(P.ammo.flags_ammo_behavior & AMMO_SKIPS_ALIENS)
			return 0
		if(mob_size == MOB_SIZE_BIG)	. += 10
		else							. -= 10


/obj/item/projectile/proc/play_damage_effect(mob/M)
	if(ammo.sound_hit) playsound(M, ammo.sound_hit, 50, 1)
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

	var/damage = max(0, P.damage - round(P.distance_travelled * P.damage_falloff))
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
			to_chat(src, "<span class='highdanger'>You burst into flames!! Stop drop and roll!</span>")
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

	if(P.ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		GLOB.round_statistics.total_bullet_hits_on_humans++

	var/damage = max(0, P.damage - round(P.distance_travelled * P.damage_falloff))
	#if DEBUG_HUMAN_DEFENSE
	to_chat(world, "<span class='debuginfo'>Initial damage is: <b>[damage]</b></span>")
	#endif

	//Shields
	if( !(P.ammo.flags_ammo_behavior & AMMO_ROCKET) ) //No, you can't block rockets.
		if( P.dir == reverse_direction(dir) && check_shields(damage * 0.65, "[P]") && src != P.shot_from.sniper_target(src)) //Aimed sniper shots will ignore shields
			P.ammo.on_shield_block(src)
			bullet_ping(P)
			return

	var/datum/limb/organ = get_limb(check_zone(P.def_zone)) //Let's finally get what organ we actually hit.
	if(!organ) return//Nope. Gotta shoot something!

	//Run armor check. We won't bother if there is no damage being done.
	if( damage > 0 && !(P.ammo.flags_ammo_behavior & AMMO_IGNORE_ARMOR) )
		var/armor //Damage types don't correspond to armor types. We are thus merging them.
		armor = getarmor_organ(organ, P.armor_type) //Should always have a type; this defaults to bullet if nothing else.

		#if DEBUG_HUMAN_DEFENSE
		to_chat(world, "<span class='debuginfo'>Initial armor is: <b>[armor]</b></span>")
		#endif
		var/penetration = P.ammo.penetration > 0 || armor > 0 ? P.ammo.penetration : 0
		if(P.shot_from && src == P.shot_from.sniper_target(src)) //Runtimes bad
			damage *= SNIPER_LASER_DAMAGE_MULTIPLIER
			penetration *= SNIPER_LASER_ARMOR_MULTIPLIER
			add_slowdown(SNIPER_LASER_SLOWDOWN_STACKS)

		armor -= penetration//Minus armor penetration from the bullet. If the bullet has negative penetration, adding to their armor, but they don't have armor, they get nothing.
		#if DEBUG_HUMAN_DEFENSE
		to_chat(world, "<span class='debuginfo'>Adjusted armor after penetration is: <b>[armor]</b></span>")
		#endif

		if(armor > 0) //Armor check. We should have some to continue.
			/*Automatic damage soak due to armor. Greater difference between armor and damage, the more damage
			soaked. Small caliber firearms aren't really effective against combat armor.*/
			var/armor_soak	 = round( ( armor / damage ) * 10 )//Setting up for next action.
			var/critical_hit = rand(CONFIG_GET(number/combat_define/critical_chance_low),CONFIG_GET(number/combat_define/critical_chance_high))
			damage 			-= prob(critical_hit) ? 0 : armor_soak //Chance that you won't soak the initial amount.
			armor			-= round(armor_soak * CONFIG_GET(number/combat_define/base_armor_resist_low)) //If you still have armor left over, you generally should, we subtract the soak.
													//This gives smaller calibers a chance to actually deal damage.
			#if DEBUG_HUMAN_DEFENSE
			to_chat(world, "<span class='debuginfo'>Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[armor]</b></span>")
			#endif
			var/i = 0
			if(damage)
				while(armor > 0 && i < 2) //Going twice. Armor has to exist to continue. Post increment.
					if(prob(armor))
						armor_soak 	 = round(damage * 0.5)  //Cut it in half.
						armor 		-= armor_soak * CONFIG_GET(number/combat_define/base_armor_resist_high)
						damage 		-= armor_soak
						#if DEBUG_HUMAN_DEFENSE
						to_chat(world, "<span class='debuginfo'>Currently soaked: <b>[armor_soak]</b>. Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[armor]</b></span>")
						#endif
					else break //If we failed to block the damage, it's time to get out of the loop.
					i++
			if(i || damage <= 5) to_chat(src, "<span class='notice'>Your armor [ i == 2 ? "absorbs the force of [P]!" : "softens the impact of [P]!" ]</span>")
			if(damage <= 0)
				damage = 0
				if(P.ammo.sound_armor) playsound(src, P.ammo.sound_armor, 50, 1)

	if(P.ammo.debilitate && stat != DEAD && ( damage || (P.ammo.flags_ammo_behavior & AMMO_IGNORE_RESIST) ) )  //They can't be dead and damage must be inflicted (or it's a xeno toxin).
		//Synths are immune to these effects to cut down on the stun spam. This should later be moved to their apply_effects proc, but right now they're just humans.
		if(!(species.species_flags & IS_SYNTHETIC))
			apply_effects(arglist(P.ammo.debilitate))

	bullet_message(P) //We still want this, regardless of whether or not the bullet did damage. For griefers and such.

	if(damage)
		apply_damage(damage, P.ammo.damage_type, P.def_zone)
		P.play_damage_effect(src)
		if(P.ammo.shrapnel_chance > 0 && prob(P.ammo.shrapnel_chance + round(damage / 10) ) )
			var/obj/item/shard/shrapnel/shrap = new()
			shrap.name = "[P.name] shrapnel"
			shrap.desc = "[shrap.desc] It looks like it was fired from [P.shot_from ? P.shot_from : "something unknown"]."
			shrap.loc = organ
			organ.embed(shrap)
			if(!stat && !(species && species.species_flags & NO_PAIN))
				emote("scream")
				to_chat(src, "<span class='highdanger'>You scream in pain as the impact sends <B>shrapnel</b> into the wound!</span>")

		if(P.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
			adjust_fire_stacks(rand(6,11))
			IgniteMob()
			if(!stat && !(species.species_flags & NO_PAIN))
				emote("scream")
				to_chat(src, "<span class='highdanger'>You burst into flames!! Stop drop and roll!</span>")
		return 1

//Deal with xeno bullets.
/mob/living/carbon/xenomorph/bullet_act(obj/item/projectile/P)
	if(!P || !istype(P))
		return
	if(issamexenohive(P.firer)) //Aliens won't be harming allied aliens.
		bullet_ping(P)
		return

	if(P.ammo.flags_ammo_behavior & AMMO_BALLISTIC)
		GLOB.round_statistics.total_bullet_hits_on_xenos++

	flash_weak_pain()

	var/damage = max(0, P.damage - round(P.distance_travelled * P.damage_falloff)) //Has to be at least zero, no negatives.
	#if DEBUG_XENO_DEFENSE
	to_chat(world, "<span class='debuginfo'>Initial damage is: <b>[damage]</b></span>")
	#endif

	if(warding_aura) //Damage reduction. Every point of warding decreases damage by 1%. Maximum is 5% at 5 pheromone strength.
		damage = round(damage * (1 - (warding_aura * 0.01) ) )
		#if DEBUG_XENO_DEFENSE
		to_chat(world, "<span class='debuginfo'>Damage migated by a warding aura level of [warding_aura], damage is now <b>[damage]</b></span>")
		#endif

	if(damage > 0 && !(P.ammo.flags_ammo_behavior & AMMO_IGNORE_ARMOR))
		var/initial_armor = armor.getRating(P.ammo.armor_type)
		var/affecting_armor = initial_armor + armor_bonus + armor_pheromone_bonus
		#if DEBUG_XENO_DEFENSE
		world << "<span class='debuginfo'>Initial armor is: <b>[affecting_armor]</b></span>"
		#endif
		if(isxenoqueen(src) || isxenocrusher(src)) //Charging and crest resistances. Charging Xenos get a lot of extra armor, currently Crushers and Queens
			var/mob/living/carbon/xenomorph/charger = src
			affecting_armor += round(charger.charge_speed * 5) //Some armor deflection when charging.
			#if DEBUG_CREST_DEFENSE
			world << "<span class='debuginfo'>Projectile direction is: <b>[P.dir]</b> and crest direction is: <b>[charger.dir]</b></span>"
			#endif
			if(P.dir == charger.dir)
				if(isxenoqueen(src))
					affecting_armor = max(0, affecting_armor - (initial_armor * CONFIG_GET(number/combat_define/xeno_armor_resist_low))) //Both facing same way -- ie. shooting from behind; armour reduced by 50% of base.
				else
					affecting_armor = max(0, affecting_armor - (initial_armor * CONFIG_GET(number/combat_define/xeno_armor_resist_lmed))) //Both facing same way -- ie. shooting from behind; armour reduced by 75% of base.
			else if(P.dir == reverse_direction(charger.dir))
				affecting_armor += round(initial_armor * CONFIG_GET(number/combat_define/xeno_armor_resist_low)) //We are facing the bullet.
			else if(isxenocrusher(src))
				affecting_armor = max(0, affecting_armor - (initial_armor * CONFIG_GET(number/combat_define/xeno_armor_resist_vlow))) //side armour eats a bit of shit if we're a Crusher
			//Otherwise use the standard armor deflection for crushers.
			#if DEBUG_XENO_DEFENSE
			to_chat(world, "<span class='debuginfo'>Adjusted crest armor is: <b>[affecting_armor]</b></span>")
			#endif

		var/penetration = P.ammo.penetration > 0 || affecting_armor > 0 ? P.ammo.penetration : 0
		if(P.shot_from && src == P.shot_from.sniper_target(src))
			damage *= SNIPER_LASER_DAMAGE_MULTIPLIER
			penetration *= SNIPER_LASER_ARMOR_MULTIPLIER
			add_slowdown(SNIPER_LASER_SLOWDOWN_STACKS)

		affecting_armor -= penetration

		#if DEBUG_XENO_DEFENSE
		world << "<span class='debuginfo'>Adjusted armor after penetration is: <b>[affecting_armor]</b></span>"
		#endif
		if(affecting_armor > 0) //Armor check. We should have some to continue.
			/*Automatic damage soak due to armor. Greater difference between armor and damage, the more damage
			soaked. Small caliber firearms aren't really effective against combat armor.*/
			var/armor_soak	 = round( ( affecting_armor / damage ) * 10 )//Setting up for next action.
			var/critical_hit = rand(CONFIG_GET(number/combat_define/critical_chance_low),CONFIG_GET(number/combat_define/critical_chance_high))
			damage 			-= prob(critical_hit) ? 0 : armor_soak //Chance that you won't soak the initial amount.
			affecting_armor			-= round(armor_soak * CONFIG_GET(number/combat_define/base_armor_resist_low)) //If you still have armor left over, you generally should, we subtract the soak.
													//This gives smaller calibers a chance to actually deal damage.
			#if DEBUG_XENO_DEFENSE
			to_chat(world, "<span class='debuginfo'>Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[affecting_armor]</b></span>")
			#endif
			var/i = 0
			if(damage)
				while(affecting_armor > 0 && i < 2) //Going twice. Armor has to exist to continue. Post increment.
					if(prob(affecting_armor))
						armor_soak 	 = round(damage * 0.5)
						affecting_armor 		-= armor_soak * CONFIG_GET(number/combat_define/base_armor_resist_high)
						damage 		-= armor_soak
						#if DEBUG_XENO_DEFENSE
						to_chat(world, "<span class='debuginfo'>Currently soaked: <b>[armor_soak]</b>. Adjusted damage is: <b>[damage]</b>. Adjusted armor is: <b>[affecting_armor]</b></span>")
						#endif
					else break //If we failed to block the damage, it's time to get out of the loop.
					i++
			if(i || damage <= 5) to_chat(src, "<span class='xenonotice'>Your exoskeleton [ i == 2 ? "absorbs the force of [P]!" : "softens the impact of [P]!" ]</span>")
			if(damage <= 3)
				damage = 0
				bullet_ping(P)
				visible_message("<span class='avoidharm'>[src]'s thick exoskeleton deflects [P]!</span>")

	bullet_message(P) //Message us about the bullet, since damage was inflicted.

	if(damage)
		apply_damage(damage,P.ammo.damage_type, P.def_zone)	//Deal the damage.
		P.play_damage_effect(src)
		if(!stat && prob(5 + round(damage / 4)))
			var/pain_emote = prob(70) ? "hiss" : "roar"
			emote(pain_emote)
		if(P.ammo.flags_ammo_behavior & AMMO_INCENDIARY)
			if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
				if(!stat) to_chat(src, "<span class='avoidharm'>You shrug off some persistent flames.</span>")
			else
				adjust_fire_stacks(rand(2,6) + round(damage / 8))
				IgniteMob()
				visible_message("<span class='danger'>[src] bursts into flames!</span>", \
				"<span class='xenodanger'>You burst into flames!! Auuugh! Resist to put out the flames!</span>")
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
		if(istype(picked_mob) && P.firer && prob(P.get_projectile_hit_chance(P.firer,picked_mob)))
			picked_mob.bullet_act(P)
			return 1
	return 1

// walls can get shot and damaged, but bullets (vs energy guns) do much less.
/turf/closed/wall/bullet_act(obj/item/projectile/P)
	if(!..())
		return
	var/damage = P.damage
	if(damage < 1) return

	switch(P.ammo.damage_type)
		if(BRUTE) 	damage = P.ammo.flags_ammo_behavior & AMMO_ROCKET ? round(damage * 10) : damage //Bullets do much less to walls and such.
		if(BURN)	damage = P.ammo.flags_ammo_behavior & (AMMO_ENERGY) ? round(damage * 1.5) : damage
		else return
	if(P.ammo.flags_ammo_behavior & AMMO_BALLISTIC) current_bulletholes++
	take_damage(damage)
	if(prob(30 + damage)) P.visible_message("<span class='warning'>[src] is damaged by [P]!</span>")
	return 1


/turf/closed/wall/mainship/research/containment/bullet_act(obj/item/projectile/P)
	if(P && P.ammo.flags_ammo_behavior & AMMO_XENO_ACID)
		return //immune to acid spit
	. = ..()




//Hitting an object. These are too numerous so they're staying in their files.
//Why are there special cases listed here? Oh well, whatever. ~N
/obj/bullet_act(obj/item/projectile/P)
	if(!CanPass(P, get_turf(src)) && density)
		bullet_ping(P)
		return 1

/obj/structure/table/bullet_act(obj/item/projectile/P)
	src.bullet_ping(P)
	obj_integrity -= round(P.damage/2)
	if (obj_integrity < 0)
		visible_message("<span class='warning'>[src] breaks down!</span>")
		destroy_structure()
	return 1


//----------------------------------------------------------
					//				    \\
					//    OTHER PROCS	\\
					//					\\
					//					\\
//----------------------------------------------------------


//This is where the bullet bounces off.
/atom/proc/bullet_ping(obj/item/projectile/P)
	if(!P || !P.ammo.ping) return
	if(prob(65))
		if(P.ammo.sound_bounce) playsound(src, P.ammo.sound_bounce, 50, 1)
		var/image/I = image('icons/obj/items/projectiles.dmi',src,P.ammo.ping,10)
		var/angle = (P.firer && prob(60)) ? round(Get_Angle(P.firer,src)) : round(rand(1,359))
		I.pixel_x += rand(-6,6)
		I.pixel_y += rand(-6,6)

		var/matrix/rotate = matrix()
		rotate.Turn(angle)
		I.transform = rotate
		flick_overlay_view(I, src, 3)

/mob/living/proc/bullet_message(obj/item/projectile/P)
	if(!P) return

	if(P.ammo.flags_ammo_behavior & AMMO_IS_SILENCED)
		to_chat(src, "[isxeno(src) ? "<span class='xenodanger'>" : "<span class='highdanger'>" ]You've been shot in the [parse_zone(P.def_zone)] by [P.name]!</span>")
	else
		visible_message("<span class='danger'>[name] is hit by the [P.name] in the [parse_zone(P.def_zone)]!</span>", \
						"<span class='highdanger'>You are hit by the [P.name] in the [parse_zone(P.def_zone)]!</span>", null, 4)

	if(isliving(P.firer))
		var/mob/living/firingMob = P.firer
		var/turf/T = get_turf(firingMob)
		if(ishuman(firingMob) && ishuman(src) && !firingMob.mind?.bypass_ff && !mind?.bypass_ff && firingMob.faction == faction)
			log_combat(firingMob, src, "shot", P)
			log_ffattack("[key_name(firingMob)] shot [key_name(src)] with [P] in [AREACOORD(T)].")
			msg_admin_ff("[ADMIN_TPMONTY(firingMob)] shot [ADMIN_TPMONTY(src)] with [P] in [ADMIN_VERBOSEJMP(T)].")
			GLOB.round_statistics.total_bullet_hits_on_marines++
		else
			log_combat(firingMob, src, "shot", P)
			msg_admin_attack("[ADMIN_TPMONTY(firingMob)] shot [ADMIN_TPMONTY(src)] with [P] in [ADMIN_VERBOSEJMP(T)].")
		return

	if(P.firer)
		log_combat(P.firer, src, "shot", P)
		msg_admin_attack("[ADMIN_TPMONTY(P.firer)] shot [ADMIN_TPMONTY(src)] with a [P]")
	else
		log_message("SOMETHING?? shot [key_name(src)] with a [P]", LOG_ATTACK)
		msg_admin_attack("SOMETHING?? shot [ADMIN_TPMONTY(src)] with a [P])")

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
