//Handles the effects of "stun" weapons
/**
	stun_effect_act(stun_amount, agony_amount, def_zone)

	Handle the effects of a "stun" weapon

	Arguments
		stun_amount {int} applied as Stun and Paralyze
		def_zone {enum} which body part to target
*/
/mob/living/proc/stun_effect_act(stun_amount, agony_amount, def_zone)
	if(status_flags & GODMODE)
		return FALSE

	flash_pain()

	if(stun_amount)
		Stun(stun_amount * 20) // TODO: replace these amounts in stun_effect_stun() calls
		Paralyze(stun_amount * 20)
		apply_effect(STUTTER, stun_amount)
		apply_effect(EYE_BLUR, stun_amount)

	if(agony_amount)
		apply_effect(STUTTER, agony_amount/10)
		apply_effect(EYE_BLUR, agony_amount/10)


/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0)
	return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM as mob|obj,speed = 5)//Standardization and logging -Sieve
	if(istype(AM,/obj/))
		var/obj/O = AM
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
		var/throw_damage = O.throwforce*(speed/5)

		var/miss_chance = 15
		if (O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			miss_chance = min(15*(distance-2), 0)

		if (prob(miss_chance))
			visible_message(span_notice(" \The [O] misses [src] narrowly!"), null, null, 5)
			return

		src.visible_message(span_warning(" [src] has been hit by [O]."), null, null, 5)
		var/armor = get_soft_armor("melee")

		apply_damage(throw_damage, dtype, BODY_ZONE_CHEST, armor, is_sharp(O), has_edge(O), TRUE)

		if(O.item_fire_stacks)
			fire_stacks += O.item_fire_stacks
		if(CHECK_BITFIELD(O.resistance_flags, ON_FIRE))
			IgniteMob()

		O.set_throwing(FALSE) //it hit, so stop moving

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				log_combat(M, src, "hit", O, "(thrown)")

		// Begin BS12 momentum-transfer code.
		if(O.throw_source && speed >= 15)
			var/obj/item/W = O
			var/momentum = speed/2
			var/dir = get_dir(O.throw_source, src)

			visible_message(span_warning(" [src] staggers under the impact!"),span_warning(" You stagger under the impact!"), null, 5)
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!W || !src) return

			if(W.sharp && prob(W.embedding.embed_chance)) //Projectile is suitable for pinning.
				//Handles embedding for non-humans and simple_animals.
				W.embed_into(src)

//This is called when the mob is thrown into a dense turf
/mob/living/proc/turf_collision(turf/T, speed)
	src.take_limb_damage(speed*5)

/mob/living/proc/near_wall(direction,distance=1)
	var/turf/T = get_step(get_turf(src),direction)
	var/turf/last_turf = src.loc
	var/i = 1

	while(i>0 && i<=distance)
		if(T.density) //Turf is a wall!
			return last_turf
		i++
		last_turf = T
		T = get_step(T,direction)

	return 0

// End BS12 momentum-transfer code.


//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(status_flags & GODMODE) //Invulnerable mobs don't get ignited
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NON_FLAMMABLE))
		return FALSE
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		return FALSE
	if(get_fire_resist() <= 0 || get_hard_armor("fire", BODY_ZONE_CHEST) >= 100)	//having high fire resist makes you immune
		return FALSE
	if(fire_stacks > 0 && !on_fire)
		on_fire = TRUE
		RegisterSignal(src, COMSIG_LIVING_DO_RESIST, .proc/resist_fire)
		to_chat(src, span_danger("You are on fire! Use Resist to put yourself out!"))
		update_fire()
		return TRUE

/mob/living/carbon/human/IgniteMob()
	. = ..()
	if(.)
		if(!stat && !(species.species_flags & NO_PAIN))
			emote("scream")

/mob/living/carbon/xenomorph/IgniteMob()
	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	. = ..()
	if(!.)
		return
	var/fire_light = min(fire_stacks,5)
	if(fire_light > fire_luminosity) // light up xenos if new light source thats bigger hits them
		if(fire_light < light_range)
			set_light_range(fire_light) //update range
		set_light_color(BlendRGB(light_color, LIGHT_COLOR_LAVA))
		fire_luminosity = fire_light
		set_light_on(TRUE) //And activate it
	var/obj/item/clothing/mask/facehugger/F = get_active_held_item()
	var/obj/item/clothing/mask/facehugger/G = get_inactive_held_item()
	if(istype(F))
		F.kill_hugger()
		dropItemToGround(F)
	if(istype(G))
		G.kill_hugger()
		dropItemToGround(G)


/mob/living/proc/ExtinguishMob()
	if(!on_fire)
		return FALSE
	on_fire = FALSE
	adjust_bodytemperature(-80, 300)
	fire_stacks = 0
	update_fire()
	UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)


/mob/living/carbon/xenomorph/ExtinguishMob()
	. = ..()
	set_light_on(FALSE) //Reset lighting

/mob/living/carbon/xenomorph/boiler/ExtinguishMob()
	. = ..()
	update_boiler_glow()

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	if(status_flags & GODMODE) //Invulnerable mobs don't get fire stacks
		return
	if(add_fire_stacks > 0)	//Fire stack increases are affected by armor, end result rounded up.
		add_fire_stacks = CEILING(add_fire_stacks * get_fire_resist(), 1)
	fire_stacks = clamp(fire_stacks + add_fire_stacks, -20, 20)
	if(on_fire && fire_stacks <= 0)
		ExtinguishMob()

/mob/living/proc/handle_fire()
	if(fire_stacks < 0)
		fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return 1
	if(fire_stacks > 0)
		adjust_fire_stacks(-1) //the fire is consumed slowly

/mob/living/fire_act()
	adjust_fire_stacks(rand(1,2))
	IgniteMob()


/mob/living/proc/resist_fire(datum/source)
	SIGNAL_HANDLER
	fire_stacks = max(fire_stacks - rand(3, 6), 0)
	Paralyze(80)

	var/turf/T = get_turf(src)
	if(istype(T, /turf/open/floor/plating/ground/snow))
		visible_message(span_danger("[src] rolls in the snow, putting themselves out!"), \
		span_notice("You extinguish yourself in the snow!"), null, 5)
		ExtinguishMob()
		return

	visible_message(span_danger("[src] rolls on the floor, trying to put themselves out!"), \
	span_notice("You stop, drop, and roll!"), null, 5)
	if(fire_stacks <= 0)
		visible_message(span_danger("[src] has successfully extinguished themselves!"), \
		span_notice("You extinguish yourself."), null, 5)
		ExtinguishMob()


//Mobs on Fire end
// When they are affected by a queens screech
/mob/living/proc/screech_act(mob/living/carbon/xenomorph/queen/Q)
	shake_camera(src, 3 SECONDS, 1)

/mob/living/effect_smoke(atom/movable/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CAMO))
			smokecloak_off()
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO) && (stat == DEAD || isnestedhost(src)))
		return FALSE
	if(LAZYACCESS(smoke_delays, S.type) > world.time)
		return FALSE
	LAZYSET(smoke_delays, S.type, world.time + S.minimum_effect_delay)
	smoke_contact(S)

/mob/living/proc/smoke_contact(atom/movable/effect/particle_effect/smoke/S)
	var/protection = max(1 - get_permeability_protection() * S.bio_protection, 0)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_EXTINGUISH))
		ExtinguishMob()
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		adjustFireLoss(15 * protection)
		to_chat(src, span_danger("It feels as if you've been dumped into an open fire!"))
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		if(prob(25 * protection))
			to_chat(src, span_danger("Your skin feels like it is melting away!"))
		adjustFireLoss(S.strength * rand(20, 23) * protection)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.reagents?.reaction(src, TOUCH, S.fraction)
	return protection

/mob/living/proc/check_shields(attack_type, damage, damage_type = "melee", silent)
	if(!damage)
		stack_trace("check_shields called without a damage value")
		return 0
	. = damage
	var/list/affecting_shields = list()
	SEND_SIGNAL(src, COMSIG_LIVING_SHIELDCALL, affecting_shields, damage_type)
	if(length(affecting_shields) > 1)
		sortTim(affecting_shields, /proc/cmp_numeric_dsc, associative = TRUE)
	for(var/shield in affecting_shields)
		var/datum/callback/shield_check = shield
		. = shield_check.Invoke(attack_type, ., damage_type, silent)
		if(!.)
			break

/mob/living/proc/get_fire_resist()
	return clamp((100 - get_soft_armor("fire", null)) * 0.01, 0, 1)
