
///////////////////////
/// Globadier Mines ///
///////////////////////

/obj/structure/xeno/acid_mine
	name = "acid mine"
	desc = "A weird bulb, filled with acid."
	icon = 'icons/obj/items/mines.dmi'
	icon_state = "acid_mine"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 5
	hit_sound = SFX_ALIEN_RESIN_BREAK
	///The amount of acid damage this deals
	var/acid_damage = 30

/obj/structure/xeno/acid_mine/Initialize(mapload, _hivenumber)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(oncrossed),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/xeno/acid_mine/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	detonate(blame_mob)
	return ..()

// Checks if the mob walking over the mine is human, and calls detonate if so
/obj/structure/xeno/acid_mine/proc/oncrossed(datum/source, atom/movable/A, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!ishuman(A))
		return
	if(CHECK_MULTIPLE_BITFIELDS(A.allow_pass_flags, HOVERING))
		return
	INVOKE_ASYNC(src, PROC_REF(detonate), A)

/obj/structure/xeno/acid_mine/proc/detonate(triggerer)
	for(var/spatter_effect in filled_turfs(get_turf(src), 1, "square", pass_flags_checked = PASS_AIR))
		new /obj/effect/temp_visual/acid_splatter(spatter_effect)
	for(var/mob/living/carbon/human/human_victim AS in cheap_get_humans_near(src,1))
		human_victim.apply_damage(acid_damage/2, BURN, BODY_ZONE_L_LEG, ACID,  penetration = 30)
		human_victim.apply_damage(acid_damage/2, BURN, BODY_ZONE_R_LEG, ACID,  penetration = 30)
		playsound(src, "sound/bullets/acid_impact1.ogg", 10, FALSE, SUPER_SHORT_SOUND_RANGE)
	qdel(src)

////////////////
/// Gas Mine ///
////////////////

/obj/structure/xeno/acid_mine/gas_mine
	name = "gas mine"
	desc = "A weird bulb, overflowing with acid. Small wisps of gas escape every so often."
	icon_state = "gas_mine"
	acid_damage = 40

/obj/structure/xeno/acid_mine/gas_mine/detonate(triggerer)
	var/datum/effect_system/smoke_spread/xeno/acid/opaque/smog = new(get_turf(src))
	smog.set_up(1,src)
	smog.start()
	return ..()

//////////////////
/// Incen Mine ///
//////////////////

/obj/structure/xeno/acid_mine/incen_mine
	name = "incendiary mine"
	desc = "A purple blob that sparks like lightning."
	icon_state = "incen_mine"

/obj/structure/xeno/acid_mine/incen_mine/detonate(triggerer)
	flame_radius(1, get_turf(src), fire_type = /obj/fire/melting_fire/shattering, burn_intensity = 20, burn_duration = 180, colour = "violet")
	qdel(src)

//////////////////
/// Resin Mine ///
//////////////////

/obj/structure/xeno/acid_mine/resin_mine
	name = "resin mine"
	desc = "A translucent purple blob, insides lined with clear ampoules of resin."
	icon_state = "resin_mine"

/obj/structure/xeno/acid_mine/resin_mine/detonate(triggerer)
	var/cannotbuild = FALSE
	for(var/turf/resin_tile in filled_turfs(get_turf(src), 0.5, "circle", pass_flags_checked = PASS_AIR))
		cannotbuild = FALSE
		if((resin_tile.density || istype(resin_tile, /turf/open/space))) // No structures in space
			continue

		for(var/obj/O in resin_tile.contents)
			if(istype(O, /obj/alien/resin))
				cannotbuild = TRUE

		if(!cannotbuild)
			new /obj/alien/resin/sticky(resin_tile)

	for(var/mob/living/carbon/human/affected AS in cheap_get_humans_near(src,1))
		if(affected.stat == DEAD)
			continue
		var/throwloc = affected.loc
		for(var/x in 1 to 6)
			throwloc = get_step(throwloc, REVERSE_DIR(affected.dir))
		affected.throw_at(throwloc, 12, 2.5, src, TRUE)
	qdel(src)

//////////////////
/// Neuro Mine ///
//////////////////

/obj/structure/xeno/acid_mine/neuro_mine
	name = "neurotoxin mine"
	desc = "An oddly colored weed sac, filled with dense orange gas."
	icon_state = "neuro_mine"

/obj/structure/xeno/acid_mine/neuro_mine/detonate(triggerer)
	var/datum/effect_system/smoke_spread/xeno/neuro/medium/gas = new(get_turf(src))
	gas.set_up(2, src)
	gas.start()

	if(ishuman(triggerer))
		var/mob/living/carbon/human/victim = triggerer
		victim.reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, 5)
		to_chat(victim, span_userdanger("You are pricked by a spike on the mine!"))
	qdel(src)

//////////////////////
/// Lifetrade Mine ///
//////////////////////

/obj/structure/xeno/acid_mine/drain_mine
	name = "drain mine"
	desc = "A cyan blob that crackles with lifeblood."
	icon_state = "emp_mine"

/obj/structure/xeno/acid_mine/drain_mine/detonate(triggerer)
	if(ishuman(triggerer))
		var/mob/living/carbon/human/victim = triggerer
		victim.apply_status_effect(STATUS_EFFECT_LIFEDRAIN)
		new /obj/effect/temp_visual/telekinesis(get_turf(victim))
	var/datum/effect_system/smoke_spread/xeno/hemodile/gas = new(get_turf(src))
	gas.set_up(2, src)
	gas.start()
	qdel(src)
