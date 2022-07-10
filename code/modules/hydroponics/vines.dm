
// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/effect/plantsegment
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	density = FALSE
	layer = FLY_LAYER
	flags_pass = PASSTABLE|PASSGRILLE

	// Vars used by vines with seed data.
	var/age = 0
	var/lastproduce = 0
	var/harvest = 0
	var/list/chems
	var/plant_damage_noun = "Thorns"
	var/limited_growth = 0

	// Life vars/
	var/energy = 0
	var/obj/effect/plant_controller/master = null
	var/datum/seed/seed

/obj/effect/plantsegment/Destroy()
	if(master)
		master.vines -= src
		master.growth_queue -= src
	return ..()

/obj/effect/plantsegment/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(0, user))
			return

		qdel(src)

	else if(I.heat >= 3500)
		qdel(src)

	else if(I.sharp)
		switch(I.sharp)
			if(IS_SHARP_ITEM_BIG)
				qdel(src)
			if(IS_SHARP_ITEM_ACCURATE)
				if(prob(60))
					qdel(src)
			if(IS_SHARP_ITEM_SIMPLE)
				if(prob(25))
					qdel(src)
	else
		manual_unbuckle(user)


/obj/effect/plantsegment/attack_hand(mob/living/user)
	.  = ..()
	if(.)
		return
	if(user.a_intent == INTENT_HELP && seed && harvest)
		seed.harvest(user,1)
		harvest = 0
		lastproduce = age
		update()
		return

	manual_unbuckle(user)


/obj/effect/plantsegment/proc/manual_unbuckle(mob/user)
	if(!LAZYLEN(buckled_mobs))
		return FALSE
	if(!prob(seed ? min(max(0,100 - seed.potency),100) : 50))
		var/text = pick("rips","tears","pulls")
		user.visible_message(
			span_notice("[user.name] [text] at [src]."),
			span_notice("You [text] at [src]."),
			span_warning("You hear shredding and ripping."))
		return FALSE
	var/mob/living/prisoner = buckled_mobs[1]
	if(prisoner.buckled != src)
		CRASH("[user] attempted to free [prisoner] by attacking [src], but it was buckled to [prisoner.buckled].")
	if(prisoner != user)
		prisoner.visible_message(
			span_notice("[user.name] frees [prisoner.name] from [src]."),
			span_notice("[user.name] frees you from [src]."),
			span_warning("You hear shredding and ripping."))
	else
		prisoner.visible_message(
			span_notice("[prisoner.name] struggles free of [src]."),
			span_notice("You untangle [src] from around yourself."),
			span_warning("You hear shredding and ripping."))
	unbuckle_mob(prisoner)
	return TRUE


/obj/effect/plantsegment/proc/grow()

	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1

		//Low-lying creepers do not block vision or grow thickly.
		if(limited_growth)
			energy = 2
			return

		src.opacity = TRUE
		layer = FLY_LAYER
	else if(!limited_growth)
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

/obj/effect/plantsegment/proc/entangle_mob()
	if(limited_growth)
		return
	if(!prob(seed ? seed.potency : 25))
		return
	var/mob/living/carbon/victim = locate() in loc
	if(!QDELETED(victim) && victim.stat != DEAD && victim.buckled != src) // If mob exists and is not dead or captured.
		buckle_mob(victim, silent = TRUE)
		to_chat(victim, span_danger("The vines [pick("wind", "tangle", "tighten")] around you!"))

	// FEED ME, SEYMOUR.
	if(seed)
		for(var/m in buckled_mobs)
			victim = m
			if(victim == DEAD)
				continue

			// Drink some blood/cause some brute.
			if(seed.carnivorous == 2)
				to_chat(victim, span_danger("\The [src] pierces your flesh greedily!"))

				var/damage = rand(round(seed.potency/2),seed.potency)
				if(!ishuman(victim))
					victim.adjustBruteLoss(damage)
					return

				var/datum/limb/affecting = victim.get_limb(pick("l_foot","r_foot","l_leg","r_leg","l_hand","r_hand","l_arm", "r_arm","head","chest","groin"))

				if(affecting)
					affecting.take_damage_limb(damage, updating_health = TRUE)
				else
					victim.adjustBruteLoss(damage, updating_health = TRUE)

				victim.UpdateDamageIcon()

			// Inject some chems.
			if(length(seed.chems) && ishuman(victim))
				to_chat(victim, span_danger("You feel something seeping into your skin!"))
				for(var/rid in seed.chems)
					var/injecting = clamp(seed.potency * 0.2, 1, 5)
					victim.reagents.add_reagent(rid, injecting)


/obj/effect/plantsegment/proc/update()
	if(!seed) return

	// Update bioluminescence.
	if(seed.biolum)
		if(seed.biolum_colour)
			set_light(1 + round(seed.potency / 10), l_color = seed.biolum_colour)
		else
			set_light(1 + round(seed.potency / 10))
		return
	else
		set_light(0)

	// Update flower/product overlay.
	overlays.Cut()
	if(age >= seed.maturation)
		if(prob(20) && seed.products && seed.products.len && !harvest && ((age-lastproduce) > seed.production))
			harvest = 1
			lastproduce = age

		if(harvest)
			var/image/fruit_overlay = image('icons/obj/machines/hydroponics.dmi',"")
			if(seed.product_colour)
				fruit_overlay.color = seed.product_colour
			overlays += fruit_overlay

		if(seed.flowers)
			var/image/flower_overlay = image('icons/obj/machines/hydroponics.dmi',"[seed.flower_icon]")
			if(seed.flower_colour)
				flower_overlay.color = seed.flower_colour
			overlays += flower_overlay

/obj/effect/plantsegment/proc/spread()
	var/direction = pick(GLOB.cardinals)
	var/step = get_step(src,direction)
	if(istype(step,/turf/open/floor))
		var/turf/open/floor/F = step
		if(!locate(/obj/effect/plantsegment,F))
			if(F.Enter(src))
				if(master)
					master.spawn_piece( F )

// Explosion damage.
/obj/effect/plantsegment/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			die()
		if(EXPLODE_HEAVY)
			if (prob(90))
				die()
		if(EXPLODE_LIGHT)
			if (prob(50))
				die()


// Hotspots kill vines.
/obj/effect/plantsegment/fire_act(null, temp, volume)
	qdel(src)

/obj/effect/plantsegment/proc/die()
	if(seed && harvest && rand(5))
		seed.harvest(src,1)
		qdel(src)

/obj/effect/plantsegment/proc/life()

	if(!seed)
		return

	if(prob(30))
		age++

	var/turf/T = loc
	if(!loc)
		return

	var/pressure = T.return_pressure()
	var/temperature = T.return_temperature()

	if(pressure < seed.lowkpa_tolerance || pressure > seed.highkpa_tolerance)
		die()
		return

	if(abs(temperature - seed.ideal_heat) > seed.heat_tolerance)
		die()
		return


/obj/effect/plantsegment/flamer_fire_act(burnlevel)
	qdel(src)

/obj/effect/plant_controller

	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the spacevines' size to something less than 20 plots, it won't grow anymore.

	var/list/obj/effect/plantsegment/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	var/datum/seed/seed

	var/collapse_limit = 250
	var/slowdown_limit = 30
	var/limited_growth = 0

/obj/effect/plant_controller/creeper
	collapse_limit = 6
	slowdown_limit = 3
	limited_growth = 1

/obj/effect/plant_controller/Initialize()
	. = ..()

	if(!istype(loc,/turf/open/floor))
		return INITIALIZE_HINT_QDEL

	spawn_piece(loc)

	START_PROCESSING(SSobj, src)

/obj/effect/plant_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/plant_controller/proc/spawn_piece(turf/location)
	var/obj/effect/plantsegment/SV = new(location)
	SV.limited_growth = src.limited_growth
	growth_queue += SV
	vines += SV
	SV.master = src
	if(seed)
		SV.seed = seed
		SV.name = "[seed.seed_name] vines"
		SV.update()

/obj/effect/plant_controller/process()

	// Space vines exterminated. Remove the controller
	if(!vines)
		qdel(src)
		return

	// Sanity check.
	if(!growth_queue)
		qdel(src)
		return

	// Check if we're too big for our own good.
	if(vines.len >= (seed ? seed.potency * collapse_limit : 250) && !reached_collapse_size)
		reached_collapse_size = 1
	if(vines.len >= (seed ? seed.potency * slowdown_limit : 30) && !reached_slowdown_size )
		reached_slowdown_size = 1

	var/length = 0
	if(reached_collapse_size)
		length = 0
	else if(reached_slowdown_size)
		if(prob(seed ? seed.potency : 25))
			length = 1
		else
			length = 0
	else
		length = 1

	length = min(30, max(length, vines.len/5))

	// Update as many pieces of vine as we're allowed to.
	// Append updated vines to the end of the growth queue.
	var/i = 0
	var/list/obj/effect/plantsegment/queue_end = list()
	for(var/obj/effect/plantsegment/SV in growth_queue)
		i++
		queue_end += SV
		growth_queue -= SV

		SV.life()
		if(!SV) continue

		if(SV.energy < 2) //If tile isn't fully grown
			var/chance
			if(seed)
				chance = limited_growth ? round(seed.potency/2,1) : seed.potency
			else
				chance = 20

			if(prob(chance))
				SV.grow()

		else if(!seed || !limited_growth) //If tile is fully grown and not just a creeper.
			SV.entangle_mob()

		SV.update()
		SV.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end
