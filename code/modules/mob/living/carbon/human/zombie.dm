/datum/action/rally_zombie
	name = "Rally Zombies"
	action_icon_state = "rally_minions"
	action_icon = 'icons/Xeno/actions/leader.dmi'

/datum/action/rally_zombie/action_activate()
	owner.emote("roar")
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_MINION_RALLY, owner)
	var/datum/action/set_agressivity/set_agressivity = owner.actions_by_path[/datum/action/set_agressivity]
	if(set_agressivity)
		SEND_SIGNAL(owner, COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED, set_agressivity.zombies_agressive) //New escorting ais should have the same behaviour as old one

/datum/action/set_agressivity
	name = "Set other zombie behavior"
	action_icon_state = "minion_agressive"
	///If zombies should be agressive
	var/zombies_agressive = TRUE

/datum/action/set_agressivity/action_activate()
	zombies_agressive = !zombies_agressive
	SEND_SIGNAL(owner, COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED, zombies_agressive)
	update_button_icon()

/datum/action/set_agressivity/update_button_icon()
	action_icon_state = zombies_agressive ? "minion_agressive" : "minion_passive"
	return ..()

/obj/item/weapon/zombie_claw
	name = "claws"
	hitsound = 'sound/weapons/slice.ogg'
	icon_state = ""
	force = 20
	sharp = IS_SHARP_ITEM_BIG
	edge = TRUE
	attack_verb = list("claws", "slashes", "tears", "rips", "dices", "cuts", "bites")
	item_flags = CAN_BUMP_ATTACK|DELONDROP
	attack_speed = 8 //Same as unarmed delay
	pry_capable = IS_PRY_CAPABLE_FORCE
	///How much zombium are transferred per hit. Set to zero to remove transmission
	var/zombium_per_hit = 5

/obj/item/weapon/zombie_claw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/weapon/zombie_claw/melee_attack_chain(mob/user, atom/target, params, rightclick)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.stat == DEAD)
			return
		human_target.reagents.add_reagent(/datum/reagent/zombium, zombium_per_hit)
	return ..()

/obj/item/weapon/zombie_claw/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(!has_proximity)
		return
	if(!istype(target, /obj/machinery/door/airlock))
		return
	if(user.do_actions)
		return

	target.balloon_alert_to_viewers("prying open [target]...")
	if(!do_after(user, 4 SECONDS, IGNORE_HELD_ITEM, target))
		return
	var/obj/machinery/door/airlock/door = target
	playsound(user.loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	if(door.locked)
		to_chat(user, span_warning("\The [target] is bolted down tight."))
		return FALSE
	if(door.welded)
		to_chat(user, span_warning("\The [target] is welded shut."))
		return FALSE
	if(door.density) //Make sure it's still closed
		door.open(TRUE)

/obj/item/weapon/zombie_claw/no_zombium
	zombium_per_hit = 0

// ***************************************
// *********** Emit Gas
// ***************************************
/datum/action/ability/emit_gas
	name = "Emit Gas"
	action_icon_state = "emit_neurogas"
	action_icon = 'icons/Xeno/actions/defiler.dmi'
	desc = "Use to emit a cloud of blinding smoke."
	cooldown_duration = 40 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY|ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EMIT_NEUROGAS,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// smoke type created when the grenade is primed
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	///radius this smoke grenade will encompass
	var/smokeradius = 4
	///The duration of the smoke in 2 second ticks
	var/smoke_duration = 9

/datum/action/ability/emit_gas/on_cooldown_finish()
	playsound(owner.loc, 'sound/effects/alien/new_larva.ogg', 50, 0)
	to_chat(owner, span_xenodanger("We feel our smoke filling us once more. We can emit gas again."))
	toggle_particles(TRUE)
	return ..()

/datum/action/ability/emit_gas/action_activate()
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	var/turf/owner_turf = get_turf(owner)
	playsound(owner_turf, 'sound/effects/smoke_bomb.ogg', 25, TRUE)
	smoke.set_up(smokeradius, owner_turf, smoke_duration)
	smoke.start()
	toggle_particles(FALSE)

	add_cooldown()
	succeed_activate()

	owner.record_war_crime()

/datum/action/ability/emit_gas/ai_should_start_consider()
	return TRUE

/datum/action/ability/emit_gas/ai_should_use(atom/target)
	var/mob/living/L = owner
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 2 && L.health > 50)
		return FALSE
	if(!can_use_action(override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(!line_of_sight(owner, target))
		return FALSE
	return TRUE

/// Toggles particles on or off
/datum/action/ability/emit_gas/proc/toggle_particles(activate)
	if(!activate)
		QDEL_NULL(particle_holder)
		return

	particle_holder = new(owner, /particles/smoker_zombie)
	particle_holder.pixel_y = 6

/datum/action/ability/emit_gas/give_action(mob/living/L)
	. = ..()
	toggle_particles(TRUE)

/datum/action/ability/emit_gas/remove_action(mob/living/L)
	. = ..()
	QDEL_NULL(particle_holder)

/datum/action/ability/emit_gas/Destroy()
	. = ..()
	QDEL_NULL(particle_holder)
