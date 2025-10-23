/mob/living/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_MOB_SLAM_DAMAGE, is_sharp = FALSE)
	if(!isliving(grab.grabbed_thing))
		return
	if(grab.grabbed_thing == src)
		return
	if(user == src)
		return

	var/mob/living/grabbed_mob = grab.grabbed_thing
	step_towards(grabbed_mob, src)
	user.drop_held_item()
	var/state = user.grab_state

	if(state >= GRAB_AGGRESSIVE)
		var/own_stun_chance = 0
		var/grabbed_stun_chance = 0
		if(grabbed_mob.mob_size > mob_size)
			own_stun_chance = 25
			grabbed_stun_chance = 10
		else if(grabbed_mob.mob_size < mob_size)
			own_stun_chance = 0
			grabbed_stun_chance = 25
		else
			own_stun_chance = 25
			grabbed_stun_chance = 25

		if(prob(own_stun_chance))
			Paralyze(1 SECONDS)
		if(prob(grabbed_stun_chance))
			grabbed_mob.Paralyze(1 SECONDS)

	var/damage = (user.skills.getRating(SKILL_UNARMED) * UNARMED_SKILL_DAMAGE_MOD)
	switch(state)
		if(GRAB_PASSIVE)
			damage += base_damage
			grabbed_mob.visible_message(span_warning("[user] slams [grabbed_mob] against [src]!"))
			log_combat(user, grabbed_mob, "slammed", "", "against [src]")
		if(GRAB_AGGRESSIVE)
			damage += base_damage * 1.5
			grabbed_mob.visible_message(span_danger("[user] bashes [grabbed_mob] against [src]!"))
			log_combat(user, grabbed_mob, "bashed", "", "against [src]")
		if(GRAB_NECK)
			damage += base_damage * 2
			grabbed_mob.visible_message(span_danger("<big>[user] crushes [grabbed_mob] against [src]!</big>"))
			log_combat(user, grabbed_mob, "crushed", "", "against [src]")
	grabbed_mob.apply_damage(damage, blocked = MELEE, updating_health = TRUE, attacker = user)
	apply_damage(damage, blocked = MELEE, updating_health = TRUE, attacker = user)
	playsound(src, 'sound/weapons/heavyhit.ogg', 40)
	return TRUE

/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0)
	return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	. = ..()
	var/list/L = GetAllContents()
	for(var/obj/O in L)
		O.emp_act(severity)

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM, speed = 5)
	. = TRUE
	if(isliving(AM))
		var/mob/living/thrown_mob = AM
		if(thrown_mob.mob_size >= mob_size)
			apply_damage((thrown_mob.mob_size + 1 - mob_size) * speed, BRUTE, BODY_ZONE_CHEST, MELEE, updating_health = TRUE)
		if(thrown_mob.mob_size <= mob_size)
			thrown_mob.set_throwing(FALSE)
			thrown_mob.apply_damage(speed, BRUTE, BODY_ZONE_CHEST, MELEE, updating_health = TRUE)
	else if(isobj(AM))
		var/obj/O = AM
		O.set_throwing(FALSE)
		apply_damage(O.throwforce*(speed * 0.2), O.damtype, BODY_ZONE_CHEST, MELEE, is_sharp(O), has_edge(O), TRUE, O.penetration)

	visible_message(span_warning("[src] has been hit by [AM]."), null, null, 5)
	if(ismob(AM.thrower))
		var/mob/M = AM.thrower
		if(M.client)
			log_combat(M, src, "hit", AM, "(thrown)")

	if(speed < 15)
		return
	if(isitem(AM))
		var/obj/item/W = AM
		if(W.sharp && prob(W.embedding.embed_chance))
			W.embed_into(src)
	if(AM.throw_source)
		visible_message(span_warning("[src] staggers under the impact!"),span_warning("You stagger under the impact!"), null, 5)
		src.throw_at(get_edge_target_turf(src, get_dir(AM.throw_source, src)), 1, speed * 0.5)

/mob/living/turf_collision(turf/T, speed)
	take_overall_damage(speed * 5, BRUTE, MELEE, FALSE, FALSE, TRUE, 0, 2)
	playsound(src, SFX_SLAM, 40)

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
	if(fire_stacks > 0 && !on_fire)
		on_fire = TRUE
		RegisterSignal(src, COMSIG_LIVING_DO_RESIST, PROC_REF(resist_fire))
		to_chat(src, span_danger("You are on fire! Use Resist to put yourself out!"))
		visible_message(span_danger("[src] bursts into flames!"), isxeno(src) ? span_xenodanger("You burst into flames!") : span_userdanger("You burst into flames!"))
		update_fire()
		SEND_SIGNAL(src, COMSIG_LIVING_IGNITED, fire_stacks)
		return TRUE

/mob/living/carbon/xenomorph/IgniteMob()
	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	. = ..()
	if(!.)
		return
	update_fire()

	for(var/obj/item/clothing/mask/facehugger/hugger in get_held_items())
		hugger.kill_hugger()
		dropItemToGround(hugger)

///Puts out any fire on the mob
/mob/living/proc/ExtinguishMob()
	var/datum/status_effect/stacking/melting_fire/xeno_fire = has_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(xeno_fire)
		remove_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(!on_fire)
		return FALSE
	on_fire = FALSE
	adjust_bodytemperature(-80, 300)
	fire_stacks = 0
	update_fire()
	UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)

///Returns true if the mob is on fire
/mob/living/proc/is_on_fire()
	if(on_fire) //todo: someone please make normal fire a status effect
		return TRUE
	if(has_status_effect(STATUS_EFFECT_MELTING_FIRE))
		return TRUE
	return FALSE

///Updates fire visuals
/mob/living/proc/update_fire()
	return

///Adjusting the amount of fire_stacks we have on person
/mob/living/proc/adjust_fire_stacks(add_fire_stacks)
	if(QDELETED(src))
		return
	if(add_fire_stacks > 0)	//Fire stack increases are affected by armor, end result rounded up.
		if(status_flags & GODMODE)
			return
		add_fire_stacks = CEILING(modify_by_armor(add_fire_stacks, FIRE), 1)
	fire_stacks = clamp(fire_stacks + add_fire_stacks, -20, 20)
	if(on_fire && fire_stacks <= 0)
		ExtinguishMob()
		return
	update_fire()

///Update fire stacks on life tick
/mob/living/proc/handle_fire()
	if(fire_stacks < 0)
		fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return 1
	SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_FIRE)
	if(fire_stacks > 0)
		adjust_fire_stacks(-1) //the fire is consumed slowly

/mob/living/lava_act()
	if(resistance_flags & INDESTRUCTIBLE)
		return FALSE
	if(stat == DEAD)
		return FALSE
	if(status_flags & GODMODE)
		return TRUE //while godmode will stop the damage, we don't want the process to stop in case godmode is removed
	if(pass_flags & PASS_FIRE) //As above, we want lava to keep processing in case pass_fire is removed
		return TRUE

	var/lava_damage = 20
	take_overall_damage(max(modify_by_armor(lava_damage, FIRE), lava_damage * 0.3), BURN, updating_health = TRUE, max_limbs = 3) //snowflakey interaction to stop complete lava immunity
	adjust_fire_stacks(20)
	IgniteMob()
	return TRUE

/mob/living/fire_act(burn_level)
	if(!burn_level)
		return
	if(status_flags & (INCORPOREAL|GODMODE))
		return FALSE
	if(pass_flags & PASS_FIRE)
		return FALSE
	if(soft_armor.getRating(FIRE) >= 100)
		to_chat(src, span_warning("You are untouched by the flames."))
		return FALSE

	take_overall_damage(rand(10, burn_level), BURN, FIRE, updating_health = TRUE, max_limbs = 4)
	to_chat(src, span_warning("You are burned!"))

	. = TRUE
	adjust_fire_stacks(burn_level)
	if(on_fire || !fire_stacks)
		return
	IgniteMob()

///Try and remove fire from ourselves
/mob/living/proc/resist_fire(datum/source)
	SIGNAL_HANDLER
	fire_stacks = max(fire_stacks - rand(3, 6), 0)
	var/turf/T = get_turf(src)
	if(istype(T, /turf/open/floor/plating/ground/snow))
		visible_message(span_danger("[src] rolls in the snow, putting themselves out!"), \
		span_notice("You extinguish yourself in the snow!"), null, 5)
		ExtinguishMob()
	else
		visible_message(span_danger("[src] rolls on the floor, trying to put themselves out!"), \
		span_notice("You stop, drop, and roll!"), null, 5)
		if(fire_stacks <= 0)
			visible_message(span_danger("[src] has successfully extinguished themselves!"), \
			span_notice("You extinguish yourself."), null, 5)
			ExtinguishMob()
	Paralyze(3 SECONDS)


//Mobs on Fire end
// When they are affected by a queens screech
/mob/living/proc/screech_act(distance, screech_range = WORLD_VIEW_NUM, within_sight = TRUE)
	shake_camera(src, 3 SECONDS, 1)

/mob/living/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CAMO))
			smokecloak_off()
		return
	if(status_flags & GODMODE)
		return FALSE
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO) && (stat == DEAD || isnestedhost(src)))
		return FALSE
	if(LAZYACCESS(smoke_delays, S.type) > world.time)
		return FALSE
	LAZYSET(smoke_delays, S.type, world.time + S.minimum_effect_delay)
	smoke_contact(S)

/mob/living/proc/smoke_contact(obj/effect/particle_effect/smoke/S)
	var/bio_protection = max(1 - get_permeability_protection() * S.bio_protection, 0)
	var/acid_protection = max(1 - get_soft_acid_protection(), 0)
	var/acid_hard_protection = get_hard_acid_protection()
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_EXTINGUISH))
		ExtinguishMob()
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		adjustFireLoss(15 * bio_protection)
		to_chat(src, span_danger("It feels as if you've been dumped into an open fire!"))
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		if(prob(25 * acid_protection))
			to_chat(src, span_danger("Your skin feels like it is melting away!"))
		adjustFireLoss(max(S.strength * rand(20, 23) * acid_protection - acid_hard_protection, 0))
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_TOXIC))
		if(HAS_TRAIT(src, TRAIT_INTOXICATION_IMMUNE))
			return
		if(has_status_effect(STATUS_EFFECT_INTOXICATED))
			var/datum/status_effect/stacking/intoxicated/debuff = has_status_effect(STATUS_EFFECT_INTOXICATED)
			debuff.add_stacks(SENTINEL_TOXIC_GRENADE_STACKS_PER)
		apply_status_effect(STATUS_EFFECT_INTOXICATED, SENTINEL_TOXIC_GRENADE_STACKS_PER)
		adjustFireLoss(SENTINEL_TOXIC_GRENADE_GAS_DAMAGE * bio_protection)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.reagents?.reaction(src, TOUCH, S.fraction)
	return bio_protection

/mob/living/proc/check_shields(attack_type, damage, damage_type = "melee", silent, penetration = 0)
	if(!damage)
		stack_trace("check_shields called without a damage value")
		return 0
	. = damage
	var/list/affecting_shields = list()
	SEND_SIGNAL(src, COMSIG_LIVING_SHIELDCALL, affecting_shields, damage_type)
	if(length(affecting_shields) > 1)
		sortTim(affecting_shields, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	for(var/shield in affecting_shields)
		var/datum/callback/shield_check = shield
		. = shield_check.Invoke(attack_type, ., damage_type, silent, penetration)
		if(!.)
			break

///Applies radiation effects to a mob
/mob/living/proc/apply_radiation(rad_strength = 7, sound_level = null)
	var/datum/looping_sound/geiger/geiger_counter = new(null, TRUE)
	geiger_counter.severity = sound_level ? sound_level : clamp(round(rad_strength * 0.15, 1), 1, 4)
	geiger_counter.start(src)

	adjustCloneLoss(rad_strength)
	adjustStaminaLoss(rad_strength * 7)
	adjust_stagger(rad_strength SECONDS * 0.5)
	add_slowdown(rad_strength * 0.5)
	blur_eyes(rad_strength) //adds a visual indicator that you've just been irradiated
	adjust_radiation(rad_strength * 20) //Radiation status effect, duration is in deciseconds
	to_chat(src, span_warning("Your body tingles as you suddenly feel the strength drain from your body!"))

/**
 * A proc triggered by callback when someone gets slammed by the tram and lands somewhere.
 *
 * This proc is used to force people to fall through things like lattice and unplated flooring at the expense of some
 * extra damage, so jokers can't use half a stack of iron rods to make getting hit by the tram immediately lethal.
 */
/mob/living/proc/tram_slam_land()
	if(!istype(loc, /turf/open/openspace) && !isplatingturf(loc))
		return

	if(isplatingturf(loc))
		var/turf/open/floor/smashed_plating = loc
		visible_message(span_danger("[src] is thrown violently into [smashed_plating], smashing through it and punching straight through!"),
				span_userdanger("You're thrown violently into [smashed_plating], smashing through it and punching straight through!"))
		apply_damage(rand(5,20), BRUTE, BODY_ZONE_CHEST)
		smashed_plating.ScrapeAway(1)

	for(var/obj/structure/lattice/lattice in loc)
		visible_message(span_danger("[src] is thrown violently into [lattice], smashing through it and punching straight through!"),
			span_userdanger("You're thrown violently into [lattice], smashing through it and punching straight through!"))
		apply_damage(rand(5,10), BRUTE, BODY_ZONE_CHEST)
		lattice.deconstruct(FALSE)
