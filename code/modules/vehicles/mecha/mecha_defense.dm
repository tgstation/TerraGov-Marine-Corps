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
	if(!gear.obj_integrity <= 1)
		return
	gear.take_damage(min(gear.obj_integrity-1, damage))

/obj/vehicle/sealed/mecha/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		spark_system.start()
		try_deal_internal_damage(.)
		if(. >= 5 || prob(33))
			to_chat(occupants, "[icon2html(src, occupants)][span_userdanger("Taking damage!")]")
		log_message("Took [.] points of damage. Damage type: [damage_type]", LOG_MECHA)

/obj/vehicle/sealed/mecha/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penentration)
	. = ..()
	if(attack_dir)
		var/facing_modifier = get_armour_facing(abs(dir2angle(dir) - dir2angle(attack_dir)))
		if(.)
			. *= facing_modifier

/obj/vehicle/sealed/mecha/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE) // Ugh. Ideally we shouldn't be setting cooldowns outside of click code.
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	playsound(loc, 'sound/weapons/tap.ogg', 40, TRUE, -1)
	user.visible_message(span_danger("[user] hits [src]. Nothing happens."), null, null, COMBAT_MESSAGE_RANGE)
	log_message("Attack by hand/paw (no damage). Attacker - [user].", LOG_MECHA, color="red")

/obj/vehicle/sealed/mecha/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit) //wrapper
	log_message("Hit by projectile. Type: [hitting_projectile]([hitting_projectile.ammo.damage_type]).", LOG_MECHA, color="red")
	// yes we *have* to run the armor calc proc here I love tg projectile code too
	try_damage_component(run_obj_armor(hitting_projectile.damage, hitting_projectile.ammo.damage_type, hitting_projectile.ammo.armor_type, 0, REVERSE_DIR(hitting_projectile.dir), hitting_projectile.ammo.penetration), hitting_projectile.def_zone)
	return ..()

/obj/vehicle/sealed/mecha/ex_act(severity, target)
	log_message("Affected by explosion of severity: [severity].", LOG_MECHA, color="red")
	return ..()

/obj/vehicle/sealed/mecha/contents_explosion(severity, target)
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

/obj/vehicle/sealed/mecha/handle_atom_del(atom/A)
	if(A in occupants) //todo does not work and in wrong file
		LAZYREMOVE(occupants, A)
		icon_state = initial(icon_state)+"-open"
		setDir(dir_in)

/obj/vehicle/sealed/mecha/emp_act(severity)
	. = ..()
	if(get_charge())
		use_power((cell.charge/3)/(severity*2))
		take_damage(30 / severity, BURN, ENERGY, 1)
	log_message("EMP detected", LOG_MECHA, color="red")

	if(!equipment_disabled && LAZYLEN(occupants)) //prevent spamming this message with back-to-back EMPs
		to_chat(occupants, span_warning("Error -- Connection to equipment control unit has been lost."))
	addtimer(CALLBACK(src, /obj/vehicle/sealed/mecha.proc/restore_equipment), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	equipment_disabled = TRUE
	set_mouse_pointer()

/obj/vehicle/sealed/mecha/fire_act() //Check if we should ignite the pilot of an open-canopy mech
	. = ..()
	if(enclosed || mecha_flags & SILICON_PILOT)
		return
	for(var/mob/living/cookedalive as anything in occupants)
		if(cookedalive.fire_stacks < 5)
			cookedalive.adjust_fire_stacks(1)
			cookedalive.IgniteMob()

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
	. = ..()
	log_message("Attacked by [W]. Attacker - [user], Damage - [.]", LOG_MECHA)
	if(isliving(user))
		var/mob/living/living_user = user
		try_damage_component(., living_user.zone_selected)

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

/obj/vehicle/sealed/mecha/welder_act(mob/living/user, obj/item/W)
	. = ..()
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(obj_integrity < max_integrity)
		if(!W.use_tool(src, user, 0, volume=50, amount=1))
			return
		user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to [src]."))
		obj_integrity += min(10, max_integrity-obj_integrity)
		if(obj_integrity == max_integrity)
			to_chat(user, span_notice("It looks to be fully repaired now."))
		return
	to_chat(user, span_warning("[src] is at full integrity!"))

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

/obj/vehicle/sealed/mecha/obj_destruction(damage_amount, damage_type, damage_flag)
	if(wreckage)
		var/mob/living/silicon/ai/AI
		for(var/crew in occupants)
			if(isAI(crew))
				if(AI)
					var/mob/living/silicon/ai/unlucky_ais = crew
					unlucky_ais.gib()
					continue
				AI = crew
		var/obj/structure/mecha_wreckage/WR = new wreckage(loc, AI)
		for(var/obj/item/mecha_parts/mecha_equipment/E in flat_equipment)
			if(E.detachable && prob(30))
				WR.crowbar_salvage += E
				E.detach(WR) //detaches from src into WR
				E.activated = TRUE
			else
				E.detach(loc)
				qdel(E)
		if(cell)
			WR.crowbar_salvage += cell
			cell.forceMove(WR)
			cell.charge = rand(0, cell.charge)
			cell = null
	return ..()

/obj/vehicle/sealed/mecha/proc/ammo_resupply(obj/item/mecha_ammo/reload_box, mob/user,fail_chat_override = FALSE)
	if(!reload_box.rounds)
		if(!fail_chat_override)
			to_chat(user, span_warning("This box of ammo is empty!"))
		return FALSE
	var/ammo_needed
	var/found_gun
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in flat_equipment)
		ammo_needed = 0

		if(!istype(gun, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic) && gun.ammo_type == reload_box.ammo_type)
			continue
		found_gun = TRUE
		if(reload_box.direct_load)
			ammo_needed = initial(gun.projectiles) - gun.projectiles
		else
			ammo_needed = gun.projectiles_cache_max - gun.projectiles_cache

		if(!ammo_needed)
			continue
		if(ammo_needed < reload_box.rounds)
			if(reload_box.direct_load)
				gun.projectiles = gun.projectiles + ammo_needed
			else
				gun.projectiles_cache = gun.projectiles_cache + ammo_needed
			playsound(get_turf(user), reload_box.load_audio, 50, TRUE)
			to_chat(user, span_notice("You add [ammo_needed] [reload_box.ammo_type][ammo_needed > 1?"s":""] to the [gun.name]"))
			reload_box.rounds = reload_box.rounds - ammo_needed
			return TRUE

		if(reload_box.direct_load)
			gun.projectiles = gun.projectiles + reload_box.rounds
		else
			gun.projectiles_cache = gun.projectiles_cache + reload_box.rounds
		playsound(get_turf(user),reload_box.load_audio,50,TRUE)
		to_chat(user, span_notice("You add [reload_box.rounds] [reload_box.ammo_type][reload_box.rounds > 1?"s":""] to the [gun.name]"))
		reload_box.rounds = 0
		return TRUE
	if(!fail_chat_override)
		if(found_gun)
			to_chat(user, span_notice("You can't fit any more ammo of this type!"))
		else
			to_chat(user, span_notice("None of the equipment on this exosuit can use this ammo!"))
	return FALSE
