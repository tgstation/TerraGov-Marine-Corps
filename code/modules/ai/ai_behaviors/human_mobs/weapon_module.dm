#define AI_FIRE_CAN_HIT (1<<0)
#define AI_FIRE_INVALID_TARGET (1<<1)
#define AI_FIRE_NO_AMMO (1<<2)
#define AI_FIRE_OUT_OF_RANGE (1<<3)
#define AI_FIRE_NO_LOS (1<<4)
#define AI_FIRE_FRIENDLY_BLOCKED (1<<5)
#define AI_FIRE_TARGET_DEAD (1<<6)

//code specific to ranged and melee weapons
/datum/ai_behavior/human
	var/obj/item/weapon/gun/gun

	var/obj/item/weapon/melee_weapon

	var/gun_firing = FALSE

	var/no_ff = TRUE //make this a flag

	var/list/start_fire_chat = list("Get some!!", "Engaging!", "Open fire!", "Firing!", "Hostiles!", "Take them out!", "Kill 'em!", "Lets rock!", "Fire!!", "Gun them down!", "Shooting!", "Weapons free!", "Fuck you!!")

	var/list/reloading_chat = list("Reloading!", "Cover me, reloading!", "Changing mag!", "Out of ammo!")

	var/list/out_range_chat = list("Target out of range.", "Out of range.", "I lost them.", "Where'd they go?", "They're running!")

	var/list/no_los_chat = list("Target lost!", "Where'd they go?", "I lost sight of them!", "Where'd they go?", "They're running!", "Stop hiding!")

	var/list/friendly_blocked_chat = list("Get out of the way!", "You're in my line!", "Clear the firing lane!", "Move!", "Holding fire!", "Stop blocking me damn it!")

	var/list/dead_target_chat = list("Target down.", "Hostile down.", "Scratch one.", "I got one!", "Down for the count.", "Kill confirmed.")

///Weapon stuff that happens during process
/datum/ai_behavior/human/proc/weapon_process()
	if(!gun && (!melee_weapon || !(melee_weapon.item_flags & WIELDED)))
		equip_gun(TRUE)
	if(gun) //todo: probably make this behavior more gun specific, so smg/shotgun tries to stay closer
		distance_to_maintain = 5
		check_gun_fire(atom_to_walk_to) //todo: shotguns (probably revovlers too) fail checks and don't fire. db fires once?
	else
		distance_to_maintain = 1 //maybe placeholder. melee range

/datum/ai_behavior/human/proc/equip_gun(alt_equip = FALSE) //unsafe atm, need to reg sigs for it being moved etc.
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return FALSE
	if(mob_parent.get_active_held_item() && mob_parent.get_inactive_held_item()) //does this stop wielding or toggling in any cases?
		return FALSE

	var/obj/item/weapon/weapon_to_equip
	for(var/obj/item/weapon/gun/option AS in mob_inventory.gun_list)
		if(option.w_class <= weapon_to_equip?.w_class) //omega hacky for now, but generally we want to equip the bigger gun
			continue
		weapon_to_equip = option

	if(!weapon_to_equip)
		if(!melee_weapon && alt_equip)
			equip_melee()
		return FALSE

	mob_parent.temporarilyRemoveItemFromInventory(weapon_to_equip)
	if(!mob_parent.put_in_hands(weapon_to_equip))
		if(!melee_weapon && alt_equip)
			equip_melee()
		return FALSE

	gun = weapon_to_equip
	RegisterSignals(weapon_to_equip, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(unequip_gun))

	if(!melee_weapon)
		weapon_to_equip.attack_self(mob_parent) //wield gun
	//are any (fireable) guns even NOT wieldable?
	if(!(weapon_to_equip.item_flags & WIELDED) && alt_equip) //spare hand, lets fill it
		equip_melee()
	return TRUE

/datum/ai_behavior/human/proc/equip_melee(alt_equip = FALSE) //unsafe atm, need to reg sigs for it being moved etc.
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return FALSE
	if(mob_parent.get_active_held_item() && mob_parent.get_inactive_held_item()) //does this stop wielding or toggling in any cases?
		return FALSE

	var/obj/item/weapon/weapon_to_equip
	for(var/obj/item/weapon/option AS in mob_inventory.melee_list)
		if(option.force <= weapon_to_equip?.force)
			continue
		//todo: account for wield force and activated force
		weapon_to_equip = option

	if(!weapon_to_equip)
		if(!melee_weapon && alt_equip)
			equip_melee()
		return FALSE

	mob_parent.temporarilyRemoveItemFromInventory(weapon_to_equip)
	if(!mob_parent.put_in_hands(weapon_to_equip))
		if(!melee_weapon && alt_equip)
			equip_melee()
		return FALSE

	melee_weapon = weapon_to_equip
	RegisterSignals(weapon_to_equip, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(unequip_melee_weapon))

	melee_weapon.attack_self(mob_parent) //toggle on or wield 2 hander
	if(!(weapon_to_equip.item_flags & WIELDED) && alt_equip) //spare hand, lets fill it
		equip_gun()
	return TRUE

/datum/ai_behavior/human/proc/unequip_gun()
	UnregisterSignal(gun, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	stop_fire()
	gun = null

/datum/ai_behavior/human/proc/unequip_melee_weapon()
	UnregisterSignal(melee_weapon, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	melee_weapon = null

/datum/ai_behavior/human/proc/check_gun_fire(atom/target) //change this horrible name oh god
	var/fire_result = can_shoot_target(target)
	if(!gun_firing)
		if(fire_result == AI_FIRE_NO_AMMO)
			reload_gun()
			return
		if(fire_result != AI_FIRE_CAN_HIT)
			return //cant shoot yet
		if(prob(90))
			mob_parent.say(pick(start_fire_chat))
		gun.start_fire(mob_parent, target, get_turf(target))
		gun_firing = TRUE
		return

	if(fire_result == AI_FIRE_CAN_HIT)
		return //keep shooting, before switch for reload consideration

	stop_fire()

	//already firing
	switch(fire_result)
		if(AI_FIRE_INVALID_TARGET)
			return //how'd you do this?
		if(AI_FIRE_TARGET_DEAD) //todo: add chat cooldowns based on these defines
			if(prob(75))
				mob_parent.say(pick(dead_target_chat))
		if(AI_FIRE_NO_AMMO)
			reload_gun()
		if(AI_FIRE_OUT_OF_RANGE)
			if(prob(50))
				mob_parent.say(pick(out_range_chat))
		if(AI_FIRE_NO_LOS)
			if(prob(50))
				mob_parent.say(pick(no_los_chat))
		if(AI_FIRE_FRIENDLY_BLOCKED)
			if(prob(50))
				mob_parent.say(pick(friendly_blocked_chat))

//inline before release unless needed
/datum/ai_behavior/human/proc/can_shoot_target(atom/target)
	if(QDELETED(target) || !isliving(target)) //placeholder, logic for non mob targets like vehicles needed
		return AI_FIRE_INVALID_TARGET
	if(!length(gun.chamber_items) || !gun.get_current_rounds(gun.chamber_items[gun.current_chamber_position]))
		return AI_FIRE_NO_AMMO
	var/mob/living/living_target = target //todo: logic will change a bit when non mob targets come in
	if(living_target.stat == DEAD)
		return AI_FIRE_TARGET_DEAD
	if(get_dist(target, mob_parent) > target_distance) //placeholder range, will offscreen
		return AI_FIRE_OUT_OF_RANGE
	if(!line_of_sight(mob_parent, target))
		return AI_FIRE_NO_LOS
	if(no_ff && !(gun.gun_features_flags & GUN_IFF) && !(gun.ammo_datum_type::ammo_behavior_flags & AMMO_IFF)) //ammo_datum_type is always populated, with the last loaded ammo type. This shouldnt be an issue since we check ammo first
		var/list/turf_line = get_line(mob_parent, target)
		turf_line.Cut(1, 2) //don't count our own turf
		for(var/turf/line_turf AS in turf_line)
			for(var/mob/line_mob in line_turf) //todo: add checks for vehicles etc
				if(line_mob.faction == mob_parent.faction)
					return AI_FIRE_FRIENDLY_BLOCKED //friendly in the way
	return AI_FIRE_CAN_HIT


/datum/ai_behavior/human/proc/stop_fire()
	gun.stop_fire()
	gun_firing = FALSE

/datum/ai_behavior/human/proc/reload_gun()
	if(prob(90))
		mob_parent.say(pick(reloading_chat))
	var/new_ammo = gun.default_ammo_type ? gun.default_ammo_type : gun.allowed_ammo_types[1]
	gun.reload(new new_ammo, mob_parent) //maybe add force = TRUE, if needed
