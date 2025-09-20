/*!
 * # Mecha defence explanation
 * Mechs focus is on a more heavy-but-slower damage approach
 * For this they have the following mechanics
 *
 * ## Backstab
 * Basically the tldr is that mechs are less flexible so we encourage good positioning, pretty simple
 * ## Armor modules
 * Pretty simple, adds armor, you can choose against what
 * ## Internal damage
 * When taking damage will force you to take some time to repair, encourages improvising in a fight
 * Targetting different def zones will damage them to encurage a more strategic approach to fights
 * where they target the "dangerous" modules
 */

/// tries to damage mech equipment depending on damage and where is being targetted
/obj/vehicle/sealed/mecha/proc/try_damage_component(damage, def_zone)
	if(damage < component_damage_threshold)
		return
	var/obj/item/mecha_parts/mecha_equipment/gear
	switch(def_zone)
		if(BODY_ZONE_L_ARM)
			gear = equip_by_category[MECHA_L_ARM]
		if(BODY_ZONE_R_ARM)
			gear = equip_by_category[MECHA_R_ARM]
	if(!gear)
		return

	// always leave at least 1 health
	var/damage_to_deal = min(gear.obj_integrity - 1, damage)
	if(damage_to_deal <= 0)
		return
	gear.take_damage(damage_to_deal)

	if(gear.obj_integrity <= 1)
		to_chat(occupants, "[icon2html(src, occupants)][span_danger("[gear] is critically damaged!")]")
		playsound(src, gear.destroy_sound, 50)

/obj/vehicle/sealed/mecha/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir, armour_penetration, mob/living/blame_mob)
	var/damage_taken = ..()
	if(damage_taken <= 0 || obj_integrity < 0)
		return damage_taken

	log_message("Took [damage_taken] points of damage. Damage type: [damage_type]", LOG_MECHA)
	if(damage_taken < 5)
		return damage_taken //its only a scratch
	spark_system.start()
	try_deal_internal_damage(damage_taken)
	to_chat(occupants, "[icon2html(src, occupants)][span_userdanger("Taking damage!")]")

	return damage_taken

/obj/vehicle/sealed/mecha/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE) // Ugh. Ideally we shouldn't be setting cooldowns outside of click code.
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	playsound(loc, 'sound/weapons/tap.ogg', 40, TRUE, -1)
	user.visible_message(span_danger("[user] hits [src]. Nothing happens."), null, null, COMBAT_MESSAGE_RANGE)
	log_message("Attack by hand/paw (no damage). Attacker - [user].", LOG_MECHA, color="red")

/obj/vehicle/sealed/mecha/bullet_act(atom/movable/projectile/proj, def_zone, piercing_hit) //wrapper
	var/known_firer = key_name(proj.firer)
	if(known_firer)
		known_firer += " fired by [known_firer]"
	log_message("Hit by projectile [known_firer]. Type: [proj]([proj.ammo.damage_type]).", LOG_MECHA, color="red")
	// yes we *have* to run the armor calc proc here I love tg projectile code too
	try_damage_component(
		modify_by_armor(proj.damage, proj.ammo.armor_type, proj.ammo.penetration, attack_dir = REVERSE_DIR(proj.dir)),
		proj.def_zone,
	)
	return ..()

/obj/vehicle/sealed/mecha/ex_act(severity)
	log_message("Affected by explosion of severity: [severity].", LOG_MECHA, color="red")
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	if(!(atom_flags & PREVENT_CONTENTS_EXPLOSION))
		contents_explosion(severity)
	if(QDELETED(src))
		return
	var/stagger_duration
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(rand(1200, 1800), BRUTE, BOMB, 0)
			stagger_duration = 7 SECONDS
		if(EXPLODE_HEAVY)
			take_damage(rand(400, 600), BRUTE, BOMB, 0)
			stagger_duration = 5 SECONDS
		if(EXPLODE_LIGHT)
			take_damage(rand(150, 300), BRUTE, BOMB, 0)
			stagger_duration = 2 SECONDS
		if(EXPLODE_WEAK)
			take_damage(rand(50, 100), BRUTE, BOMB, 0)

	if(!stagger_duration)
		return
	for(var/mob/living/living_occupant AS in occupants)
		living_occupant.Stagger(stagger_duration)

/obj/vehicle/sealed/mecha/contents_explosion(severity)
	. = ..()
	severity--

	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(flat_equipment)
				SSexplosions.highMovAtom += flat_equipment
			if(trackers)
				SSexplosions.highMovAtom += trackers
		if(EXPLODE_HEAVY)
			if(flat_equipment)
				SSexplosions.medMovAtom += flat_equipment
			if(trackers)
				SSexplosions.medMovAtom += trackers
		if(EXPLODE_LIGHT)
			if(flat_equipment)
				SSexplosions.lowMovAtom += flat_equipment
			if(trackers)
				SSexplosions.lowMovAtom += trackers
		if(EXPLODE_WEAK)
			if(flat_equipment)
				SSexplosions.weakMovAtom += flat_equipment
			if(trackers)
				SSexplosions.weakMovAtom += trackers

/obj/vehicle/sealed/mecha/handle_atom_del(atom/A)
	. = ..()
	if(A in occupants) //todo does not work and in wrong file
		LAZYREMOVE(occupants, A)
		icon_state = initial(icon_state)+"-open"
		setDir(dir_in)

/obj/vehicle/sealed/mecha/emp_act(severity)
	. = ..()
	playsound(src, 'sound/magic/lightningshock.ogg', 50, FALSE)
	use_power((cell.maxcharge * 0.4) / (severity))
	take_damage(600 / severity, BURN, ENERGY)

	for(var/mob/living/living_occupant AS in occupants)
		living_occupant.Stagger((8 - severity) SECONDS)

	log_message("EMP detected", LOG_MECHA, color="red")

	var/disable_time = (5 - severity) SECONDS
	if(!disable_time)
		return
	if(!equipment_disabled && LAZYLEN(occupants)) //prevent spamming this message with back-to-back EMPs
		to_chat(occupants, span_warning("Error -- Connection to equipment control unit has been lost."))
	mecha_flags |= MECHA_EMPED
	update_appearance(UPDATE_OVERLAYS)
	var/time_left = timeleft(emp_timer)
	if(time_left)
		disable_time += time_left
		deltimer(emp_timer)
	emp_timer = addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/vehicle/sealed/mecha, emp_restore)), disable_time, TIMER_DELETE_ME|TIMER_STOPPABLE)
	equipment_disabled = TRUE
	set_mouse_pointer()

/obj/vehicle/sealed/mecha/fire_act(burn_level) //Check if we should ignite the pilot of an open-canopy mech
	. = ..()
	if(enclosed || mecha_flags & SILICON_PILOT)
		return
	for(var/mob/living/cookedalive AS in occupants)
		if(cookedalive.fire_stacks < 5)
			cookedalive.adjust_fire_stacks(1)
			cookedalive.IgniteMob()

/obj/vehicle/sealed/mecha/lava_act()
	if(resistance_flags & INDESTRUCTIBLE)
		return FALSE
	take_damage(80, BURN, FIRE, armour_penetration = 30)
	return TRUE

/obj/vehicle/sealed/mecha/attackby_alternate(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/mecha_parts))
		var/obj/item/mecha_parts/parts = weapon
		parts.try_attach_part(user, src, TRUE)
		return TRUE
	return ..()

/obj/vehicle/sealed/mecha/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/mecha_ammo))
		ammo_resupply(W, user)
		return

	if(istype(W, /obj/item/repairpack))
		if(max_repairpacks <=0)
			balloon_alert(user, "Repairpacks not supported")
			return
		if(stored_repairpacks >= max_repairpacks)
			balloon_alert(user, "Repairpacks full")
			return
		stored_repairpacks++
		qdel(W)
		return

	if(isidcard(W))
		if((mecha_flags & ADDING_ACCESS_POSSIBLE) || (mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE))
			if(internals_access_allowed(user))
				ui_interact(user)
				return
			to_chat(user, span_warning("Invalid ID: Access denied."))
			return
		to_chat(user, span_warning("Maintenance protocols disabled by operator."))
		return

	if(istype(W, /obj/item/cell))
		if(construction_state == MECHA_OPEN_HATCH)
			if(!cell)
				if(!user.transferItemToLoc(W, src))
					return
				var/obj/item/cell/C = W
				to_chat(user, span_notice("You install the power cell."))
				playsound(src, 'sound/items/screwdriver2.ogg', 50, FALSE)
				cell = C
				log_message("Power cell installed", LOG_MECHA)
			else
				to_chat(user, span_warning("There's already a power cell installed!"))
		return

	if(istype(W, /obj/item/stock_parts/scanning_module))
		if(construction_state == MECHA_OPEN_HATCH)
			if(!scanmod)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, span_notice("You install the scanning module."))
				playsound(src, 'sound/items/screwdriver2.ogg', 50, FALSE)
				scanmod = W
				log_message("[W] installed", LOG_MECHA)
				update_part_values()
			else
				to_chat(user, span_warning("There's already a scanning module installed!"))
		return

	if(istype(W, /obj/item/stock_parts/capacitor))
		if(construction_state == MECHA_OPEN_HATCH)
			if(!capacitor)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, span_notice("You install the capacitor."))
				playsound(src, 'sound/items/screwdriver2.ogg', 50, FALSE)
				capacitor = W
				log_message("[W] installed", LOG_MECHA)
				update_part_values()
			else
				to_chat(user, span_warning("There's already a capacitor installed!"))
		return

	if(istype(W, /obj/item/mecha_parts))
		var/obj/item/mecha_parts/P = W
		P.try_attach_part(user, src, FALSE)
		return
	return ..()

/obj/vehicle/sealed/mecha/attacked_by(obj/item/attacking_item, mob/living/user)
	if(!attacking_item.force)
		return

	var/damage_taken = take_damage(attacking_item.force, attacking_item.damtype, MELEE, attack_dir = get_dir(src, attacking_item), blame_mob = user)
	try_damage_component(damage_taken, user.zone_selected)

	var/hit_verb = length(attacking_item.attack_verb) ? "[pick(attacking_item.attack_verb)]" : "hit"
	user.visible_message(
		span_danger("[user] [hit_verb][plural_s(hit_verb)] [src] with [attacking_item][damage_taken ? "." : ", without leaving a mark!"]"),
		span_danger("You [hit_verb] [src] with [attacking_item][damage_taken ? "." : ", without leaving a mark!"]"),
		span_hear("You hear a [hit_verb]."),
		COMBAT_MESSAGE_RANGE,
	)

	log_combat(user, src, "attacked", attacking_item)
	log_message("Attacked by [user]. Item - [attacking_item], Damage - [damage_taken]", LOG_MECHA)

/obj/vehicle/sealed/mecha/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = 0)
	. = ..()
	if(.)
		try_damage_component(., user.zone_selected)

/obj/vehicle/sealed/mecha/wrench_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(construction_state == MECHA_SECURE_BOLTS)
		construction_state = MECHA_LOOSE_BOLTS
		to_chat(user, span_notice("You undo the securing bolts."))
		return
	if(construction_state == MECHA_LOOSE_BOLTS)
		construction_state = MECHA_SECURE_BOLTS
		to_chat(user, span_notice("You tighten the securing bolts."))

/obj/vehicle/sealed/mecha/crowbar_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(construction_state == MECHA_LOOSE_BOLTS)
		construction_state = MECHA_OPEN_HATCH
		to_chat(user, span_notice("You open the hatch to the power unit."))
		return
	if(construction_state == MECHA_OPEN_HATCH)
		construction_state = MECHA_LOOSE_BOLTS
		to_chat(user, span_notice("You close the hatch to the power unit."))

/obj/vehicle/sealed/mecha/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 100, 4 SECONDS, 0, SKILL_ENGINEER_ENGI, 2, 4 SECONDS)

/obj/vehicle/sealed/mecha/proc/full_repair(charge_cell)
	obj_integrity = max_integrity
	if(cell && charge_cell)
		cell.charge = cell.maxcharge
	if(internal_damage & MECHA_INT_FIRE)
		clear_internal_damage(MECHA_INT_FIRE)
	if(internal_damage & MECHA_INT_TEMP_CONTROL)
		clear_internal_damage(MECHA_INT_TEMP_CONTROL)
	if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
		clear_internal_damage(MECHA_INT_SHORT_CIRCUIT)
	if(internal_damage & MECHA_INT_TANK_BREACH)
		clear_internal_damage(MECHA_INT_TANK_BREACH)
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		clear_internal_damage(MECHA_INT_CONTROL_LOST)

/obj/vehicle/sealed/mecha/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_SMASH
		if(damtype == BURN)
			visual_effect_icon = ATTACK_EFFECT_MECHFIRE
		else if(damtype == TOX)
			visual_effect_icon = ATTACK_EFFECT_MECHTOXIN
	..()

/obj/vehicle/sealed/mecha/proc/ammo_resupply(obj/item/mecha_ammo/reload_box, mob/user,fail_chat_override = FALSE)
	if(!reload_box.rounds)
		if(!fail_chat_override)
			to_chat(user, span_warning("This box of ammo is empty!"))
		return FALSE
	var/found_gun
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in flat_equipment)
		if(gun.ammo_type != reload_box.ammo_type)
			continue
		found_gun = TRUE

		if(reload_box.direct_load)
			if((gun.projectiles >= initial(gun.projectiles)) && (gun.projectiles_cache >= gun.projectiles_cache_max))
				continue
		else if(gun.projectiles_cache >= gun.projectiles_cache_max)
			continue

		var/amount_to_fill
		var/amount_filled = 0
		if(reload_box.direct_load)
			amount_to_fill = min(initial(gun.projectiles) - gun.projectiles, reload_box.rounds)
			gun.projectiles += amount_to_fill
			reload_box.rounds -= amount_to_fill
			amount_filled += amount_to_fill

		amount_to_fill = min(gun.projectiles_cache_max - gun.projectiles_cache, reload_box.rounds)
		gun.projectiles_cache += amount_to_fill
		reload_box.rounds -= amount_to_fill
		amount_filled += amount_to_fill

		playsound(get_turf(user), reload_box.load_audio, 50, TRUE)
		to_chat(user, span_notice("You add [amount_filled] [reload_box.ammo_type][amount_filled > 1?"s":""] to the [gun.name]"))

		if(!reload_box.rounds && reload_box.qdel_on_empty)
			qdel(reload_box)
		reload_box.update_icon()
		return TRUE

	if(!fail_chat_override)
		if(found_gun)
			to_chat(user, span_notice("You can't fit any more ammo of this type!"))
		else
			to_chat(user, span_notice("None of the equipment on this exosuit can use this ammo!"))
	return FALSE
