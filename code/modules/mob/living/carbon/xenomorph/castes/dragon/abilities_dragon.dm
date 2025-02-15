/datum/action/ability/activable/xeno/backhand
	name = "Backhand"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 10 SECONDS

/datum/action/ability/activable/xeno/backhand/use_ability(atom/target)
	xeno_owner.face_atom(target)

	/* TODO: Grab comboing:
		Big chat message in place of telegraph.area
		After 3s, deal 150 brute damage (vs. melee defense) across 5 limbs.
		Restore 250 plasma after successful cast.
		End grab.
	*/

	var/turf/lower_left
	var/turf/upper_right
	switch(xeno_owner.dir)
		if(NORTH)
			lower_left = locate(xeno_owner.x - 1, xeno_owner.y + 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 1, xeno_owner.y + 2, xeno_owner.z)
		if(SOUTH)
			lower_left = locate(xeno_owner.x - 1, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 1, xeno_owner.y - 1, xeno_owner.z)
		if(WEST)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y - 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x - 1, xeno_owner.y + 1, xeno_owner.z)
		if(EAST)
			lower_left = locate(xeno_owner.x + 1, xeno_owner.y - 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y + 1, xeno_owner.z)


	var/list/obj/effect/xeno/dragon_warning/telegraphed_atoms = list()
	var/turf/affected_turfs = block(lower_left, upper_right) // 3x2
	for(var/turf/affected_turf AS in affected_turfs)
		telegraphed_atoms += new /obj/effect/xeno/dragon_warning(affected_turf)

	ADD_TRAIT(xeno_owner, TRAIT_IMMOBILE, XENO_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER) && can_use_ability(target, TRUE)
	REMOVE_TRAIT(xeno_owner, TRAIT_IMMOBILE, XENO_TRAIT)
	QDEL_LIST(telegraphed_atoms)
	if(!was_successful)
		return

	var/damage = 60 * xeno_owner.xeno_melee_damage_modifier
	var/played_sound = FALSE
	for(var/turf/affected_tile AS in block(lower_left, upper_right))
		for(var/atom/affected_atom AS in affected_tile)
			if(isxeno(affected_atom))
				continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				affected_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5)
				affected_living.knockback(xeno_owner, 2, 2)
				if(!played_sound)
					played_sound = TRUE
					playsound(xeno_owner, get_sfx(SFX_ALIEN_BITE), 50, 1)
				xeno_owner.do_attack_animation(affected_living)
				xeno_owner.visible_message(span_danger("\The [xeno_owner] smacks [affected_living]!"), \
					span_danger("We smack [affected_living]!"), null, 5) // TODO: Better flavor.
				continue
			if(!isobj(affected_atom) || !(affected_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			var/obj/affected_obj = affected_atom
			if(isvehicle(affected_obj))
				if(ismecha(affected_obj))
					affected_obj.take_damage(damage * 3, BRUTE, MELEE, armour_penetration = 50, blame_mob = xeno_owner)
					continue
				if(isarmoredvehicle(affected_obj) || ishitbox(affected_obj))
					affected_obj.take_damage(damage * 1/3, BRUTE, MELEE, blame_mob = xeno_owner) // Adjusted for 3x3 multitile vehicles.
					continue
				affected_obj.take_damage(damage * 2, BRUTE, MELEE, blame_mob = xeno_owner)
				continue
			affected_obj.take_damage(damage, BRUTE, MELEE, blame_mob = xeno_owner)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/fly
	name = "Fly"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 240 SECONDS
/* Fly, aka odd Hivemind's Manifest:
	TBD
*/

/datum/action/ability/activable/xeno/tailswipe
	name = "Tailswipe"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 12 SECONDS
/* Tailswipe, aka expanded Oppressor's Tail Lash:
	- Telegraphed
	- Bigger AoE (assuming 5x3)
	- Apparently casted from "behind"; just rotate 180 degrees after cast.
	- To marines:
		- 55 brute damage (vs. melee defense)
		- Knockdown (2s)
	- To vehicles (multitile):
		- Prevent movement for 1.5s
		- Knockdown everyone inside for 1.5s
	- Restore 75 plasma after successful cast.
*/

/datum/action/ability/activable/xeno/tail_swipe/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/turf/lower_left
	var/turf/upper_right
	switch(xeno_owner.dir)
		if(NORTH)
			lower_left = locate(xeno_owner.x - 3, xeno_owner.y + 3, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 3, xeno_owner.y + 5, xeno_owner.z)
		if(SOUTH)
			lower_left = locate(xeno_owner.x - 3, xeno_owner.y - 5, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 3, xeno_owner.y - 3, xeno_owner.z)
		if(WEST)
			lower_left = locate(xeno_owner.x - 5, xeno_owner.y - 3, xeno_owner.z)
			upper_right = locate(xeno_owner.x - 3, xeno_owner.y + 3, xeno_owner.z)
		if(EAST)
			lower_left = locate(xeno_owner.x + 3, xeno_owner.y - 3, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 5, xeno_owner.y + 3, xeno_owner.z)
	xeno_owner.setDir(turn(xeno_owner.dir, 180))

	var/list/obj/effect/xeno/dragon_warning/telegraphed_atoms = list()
	var/turf/affected_turfs = block(lower_left, upper_right) // 5x3
	for(var/turf/affected_turf AS in affected_turfs)
		telegraphed_atoms += new /obj/effect/xeno/dragon_warning(affected_turf)

	ADD_TRAIT(xeno_owner, TRAIT_IMMOBILE, XENO_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER) && can_use_ability(target, TRUE)
	REMOVE_TRAIT(xeno_owner, TRAIT_IMMOBILE, XENO_TRAIT)
	QDEL_LIST(telegraphed_atoms)
	if(!was_successful)
		return

	var/damage = 55 * xeno_owner.xeno_melee_damage_modifier
	var/has_hit_anything = FALSE
	var/list/atom/already_affected_so_far = list() // To prevent hitting the root/parent of multitile vehicles more than once.
	for(var/turf/affected_tile AS in block(lower_left, upper_right))
		for(var/atom/affected_atom AS in affected_tile)
			if(!(affected_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			if(affected_atom in already_affected_so_far)
				continue
			if(isxeno(affected_atom))
				continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				affected_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5)
				affected_living.apply_effect(2 SECONDS, EFFECT_PARALYZE)

				animate(affected_living, pixel_z = affected_living.pixel_z + 16, layer = max(MOB_JUMP_LAYER, affected_living.layer), time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(pixel_z = affected_living.pixel_z - 16, layer = affected_living.layer, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
				var/datum/component/jump/living_jump_component = affected_living.GetComponent(/datum/component/jump)
				if(living_jump_component)
					TIMER_COOLDOWN_START(affected_living, JUMP_COMPONENT_COOLDOWN, 0.5 SECONDS)

				xeno_owner.do_attack_animation(affected_living)
				xeno_owner.visible_message(span_danger("\The [xeno_owner] tail swipes [affected_living]!"), \
					span_danger("We tail swipes [affected_living]!"), null, 5) // TODO: Better flavor.
				already_affected_so_far += affected_atom
				has_hit_anything = TRUE
				continue
			if(ishitbox(affected_atom))
				var/obj/hitbox/vehicle_hitbox = affected_atom
				if(vehicle_hitbox.root in already_affected_so_far)
					continue
				handle_vehicle_effects(vehicle_hitbox.root, damage * 1/3)
				already_affected_so_far += vehicle_hitbox.root
				has_hit_anything = TRUE
				continue
			if(isvehicle(affected_atom))
				if(ismecha(affected_atom))
					handle_vehicle_effects(affected_atom, damage * 3, 50)
				else if(isarmoredvehicle(affected_atom))
					handle_vehicle_effects(affected_atom, damage / 3)
				else
					handle_vehicle_effects(affected_atom, damage)
				already_affected_so_far += affected_atom
				has_hit_anything = TRUE

	playsound(xeno_owner, has_hit_anything ? 'sound/weapons/alien_claw_block.ogg' : 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
	if(has_hit_anything)
		xeno_owner.gain_plasma(75)

	succeed_activate()
	add_cooldown()


/// Stuns the vehicle's occupants and does damage to the vehicle itself.
/datum/action/ability/activable/xeno/tail_swipe/proc/handle_vehicle_effects(obj/vehicle/vehicle, damage, ap)
	for(var/mob/living/living_occupant in vehicle.occupants)
		living_occupant.apply_effect(1.5 SECONDS, EFFECT_PARALYZE)
	vehicle.take_damage(damage, BRUTE, MELEE, armour_penetration = ap, blame_mob = xeno_owner)

/datum/action/ability/activable/xeno/dragon_breath
	name = "Dragon Breath"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 20 SECONDS
/* Dragon Breath, aka highly modified Acid Spit:
	IF NO GRAB:
		- Takes 3s to even start (basically telegraphed).
		- Primo doesn't modify damage.
		- do_after after start of 10s. Will keep track of how long the ability went on.
		- Slowdown during the entire do_after.
		- Press 'resist' to end shooting? Not really intitive.
		- Fires at 0.2s, 15 spread.
		- Proj on contact does 2 xeno fire stack + 40 burn damage (vs. fire defense). Leaves xeno fire on turf.
		- Timer (after start) that happens every 1s that gives 30 plasma; removed on end.
	IF GRAB:
		Big chat message in place of telegraph.
		After 3s, deal 200 burn damage (vs. fire defense) across 6 limbs (aka all).
		Knockback 5 tiles
		Restore 250 plasma after successful cast.
		End grab.
*/

/datum/action/ability/activable/xeno/wind_current
	name = "Wind Current"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 20 SECONDS
/* Windcurrent, aka utility Oppressor's Tail Lash:
	- Telegraphed.
	- Deletes gas in front in 5x5.
	- To marines:
		- Knockback (4 tiles)
		- 50 burn damage (vs. fire defense)
	- Restore 200 plasma after successful cast.
*/

/datum/action/ability/activable/xeno/grab
	name = "Grab"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 20 SECONDS
/* Grab, aka Gorger's Grab on Crack:
	- Telegraphed.
	- 1x3 line in front.
	- Picks the first marine in list and passively grabs them.
	- Slows down dragon (automatic, comes with the passive grab).
	- If grabbing & take 300 damage (post-armor), end ability.
	- To marines:
		- Can't move on their own (aka TRAIT_IMMOBILE)
		- Can still take out stuff, shoot, powerfist, whatever they do.
	- Restore 250 plasma after successful grab.
*/

/datum/action/ability/activable/xeno/miasma
	name = "Miasma"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 30 SECONDS


/datum/action/ability/activable/xeno/lightning_strike
	name = "Lightning Strike"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 25 SECONDS


/datum/action/ability/activable/xeno/fire_storm
	name = "Fire Storm"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 30 SECONDS

/datum/action/ability/activable/xeno/ice_spike
	name = "Ice Spike"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 30 SECONDS


/* Psychic Channel:
	TBA
*/

/obj/effect/xeno/dragon_warning
	icon = 'icons/effects/effects.dmi'
	icon_state = "shallnotpass"
