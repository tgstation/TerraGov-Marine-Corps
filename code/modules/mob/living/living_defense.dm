/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0)
	return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = GetAllContents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM, speed = 5)
	. = TRUE
	if(isliving(AM))
		var/mob/living/thrown_mob = AM
		if(thrown_mob.mob_size >= mob_size)
			apply_damage((thrown_mob.mob_size + 1 - mob_size) * speed, BRUTE, BODY_ZONE_CHEST, MELEE, updating_health = TRUE)
		if(thrown_mob.mob_size <= mob_size)
			thrown_mob.stop_throw()
			thrown_mob.apply_damage(speed, BRUTE, BODY_ZONE_CHEST, MELEE, updating_health = TRUE)
	else if(isobj(AM))
		var/obj/O = AM
		O.stop_throw()
		apply_damage(O.throwforce*(speed * 0.2), O.damtype, BODY_ZONE_CHEST, MELEE, is_sharp(O), has_edge(O), TRUE, O.penetration)
		if(O.item_fire_stacks)
			fire_stacks += O.item_fire_stacks
			IgniteMob()

	visible_message(span_warning(" [src] has been hit by [AM]."), null, null, 5)
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
		visible_message(span_warning(" [src] staggers under the impact!"),span_warning(" You stagger under the impact!"), null, 5)
		src.throw_at(get_edge_target_turf(src, get_dir(AM.throw_source, src)), 1, speed * 0.5)

/mob/living/turf_collision(turf/T, speed)
	take_overall_damage(speed * 5, BRUTE, MELEE, FALSE, FALSE, TRUE, 0, 2)
	playsound(src, 'sound/weapons/heavyhit.ogg', 40)

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
		visible_message(span_danger("[src] bursts into flames!"), isxeno(src) ? span_xenodanger("You burst into flames!") : span_highdanger("You burst into flames!"))
		update_fire()
		SEND_SIGNAL(src, COMSIG_LIVING_IGNITED, fire_stacks)
		return TRUE

/mob/living/carbon/human/IgniteMob()
	. = ..()
	if(on_fire == TRUE)
		if(!stat && !(species.species_flags & NO_PAIN))
			emote("scream")

/mob/living/carbon/xenomorph/IgniteMob()
	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	. = ..()
	if(!.)
		return
	update_fire()
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

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	if(QDELETED(src))
		return
	if(status_flags & GODMODE) //Invulnerable mobs don't get fire stacks
		return
	if(add_fire_stacks > 0)	//Fire stack increases are affected by armor, end result rounded up.
		add_fire_stacks = CEILING(modify_by_armor(add_fire_stacks, FIRE), 1)
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

/mob/living/flamer_fire_act(burnlevel)
	if(!burnlevel)
		return
	if(status_flags & (INCORPOREAL|GODMODE)) //Ignore incorporeal/invul targets
		return
	if(hard_armor.getRating(FIRE) >= 100)
		to_chat(src, span_warning("You are untouched by the flames."))
		return

	take_overall_damage(rand(10, burnlevel), BURN, FIRE, updating_health = TRUE, max_limbs = 4)
	to_chat(src, span_warning("You are burned!"))

	if(pass_flags & PASS_FIRE) //Pass fire allow to cross fire without being ignited
		return

	adjust_fire_stacks(burnlevel)
	IgniteMob()

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
/mob/living/proc/screech_act(mob/living/carbon/xenomorph/queen/Q)
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
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_TOXIC))
		if(HAS_TRAIT(src, TRAIT_INTOXICATION_IMMUNE))
			return
		if(has_status_effect(STATUS_EFFECT_INTOXICATED))
			var/datum/status_effect/stacking/intoxicated/debuff = has_status_effect(STATUS_EFFECT_INTOXICATED)
			debuff.add_stacks(SENTINEL_TOXIC_GRENADE_STACKS_PER)
		apply_status_effect(STATUS_EFFECT_INTOXICATED, SENTINEL_TOXIC_GRENADE_STACKS_PER)
		adjustFireLoss(SENTINEL_TOXIC_GRENADE_GAS_DAMAGE * protection)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.reagents?.reaction(src, TOUCH, S.fraction)
	return protection

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
