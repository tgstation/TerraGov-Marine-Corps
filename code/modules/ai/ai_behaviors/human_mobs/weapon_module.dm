#define AI_FIRE_CAN_HIT (1<<0)
#define AI_FIRE_INVALID_TARGET (1<<1)
#define AI_FIRE_NO_AMMO (1<<2)
#define AI_FIRE_OUT_OF_RANGE (1<<3)
#define AI_FIRE_NO_LOS (1<<4)
#define AI_FIRE_FRIENDLY_BLOCKED (1<<5)
#define AI_FIRE_TARGET_DEAD (1<<6)

//TODO: split distance_to_maintain into:
// engagement_distance - range to keep from a hostile we are fighting
// follow/loiter distance - range to keep to everything else

//code specific to ranged and melee weapons
/datum/ai_behavior/human
	var/obj/item/weapon/gun/gun

	var/obj/item/weapon/melee_weapon

	var/gun_firing = FALSE

	var/no_ff = TRUE //make this a flag

	var/need_weapons = TRUE //flag

	//todo: add cooldowns
	var/list/start_fire_chat = list("Get some!!", "Engaging!", "Open fire!", "Firing!", "Hostiles!", "Take them out!", "Kill 'em!", "Lets rock!", "Fire!!", "Gun them down!", "Shooting!", "Weapons free!", "Fuck you!!")

	var/list/reloading_chat = list("Reloading!", "Cover me, reloading!", "Changing mag!", "Out of ammo!")

	var/list/out_range_chat = list("Target out of range.", "Out of range.", "I lost them.", "Where'd they go?", "They're running!")

	var/list/no_los_chat = list("Target lost!", "Where'd they go?", "I lost sight of them!", "Where'd they go?", "They're running!", "Stop hiding!")

	var/list/friendly_blocked_chat = list("Get out of the way!", "You're in my line!", "Clear the firing lane!", "Move!", "Holding fire!", "Stop blocking me damn it!")

	var/list/dead_target_chat = list("Target down.", "Hostile down.", "Scratch one.", "I got one!", "Down for the count.", "Kill confirmed.")

///Weapon stuff that happens during process
/datum/ai_behavior/human/proc/weapon_process()
	if(need_weapons)
		equip_weaponry()

	if(gun)
		check_gun_fire(combat_target)

/datum/ai_behavior/human/proc/equip_weaponry(datum/source)
	SIGNAL_HANDLER
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		need_weapons = TRUE
		return
	if(!length(mob_inventory.melee_list) && !length(mob_inventory.gun_list))
		need_weapons = TRUE
		engagement_range = initial(engagement_range)
		find_weapon() //todo
		return
	INVOKE_ASYNC(src, PROC_REF(do_equip_weaponry))

/datum/ai_behavior/human/proc/find_weapon(range = 1, list/exlusion_turfs)
	var/list/search_list = list(get_turf(mob_parent))
	search_list |= RANGE_TURFS(range, mob_parent)
	for(var/turf/turf AS in search_list)
		for(var/obj/obj in turf)
			if(!istype(obj, /obj/item/weapon))
				continue
			change_action(MOVING_TO_ATOM, obj, list(0, 1))
			return

///Tries to equip weaponry, and updates behavior appropriately
/datum/ai_behavior/human/proc/do_equip_weaponry()
	var/obj/item/weapon/primary
	var/obj/item/weapon/secondary

	var/obj/item/weapon/high_dam_melee_choice
	var/obj/item/weapon/melee_choice
	var/obj/item/weapon/shield/shield_choice
	var/obj/item/weapon/gun/big_gun_choice
	var/obj/item/weapon/gun/small_gun_choice

	//melee loop
	for(var/obj/item/weapon/melee_option AS in mob_inventory.melee_list)
		var/melee_option_str = max(melee_option.force, melee_option.force_activated)
		if((melee_option_str >= 50) && (melee_option_str >= max(high_dam_melee_choice?.force, high_dam_melee_choice?.force_activated)))
			high_dam_melee_choice = melee_option
		else if((melee_option_str < 50) && (melee_option_str >= max(melee_choice?.force, melee_choice?.force_activated)))
			melee_choice = melee_option
		if(istype(melee_option, /obj/item/weapon/shield) && melee_option.obj_integrity > shield_choice?.obj_integrity) //shield could be the best melee weapon full stop
			shield_choice = melee_option

	//gun loop
	for(var/obj/item/weapon/gun/gun_option AS in mob_inventory.gun_list)
		if((gun_option.w_class >= 4) && ((gun_option.fire_delay * 0.1 * gun_option.ammo_datum_type::damage) > (big_gun_choice?.fire_delay * 0.1 * big_gun_choice?.ammo_datum_type::damage)))
			big_gun_choice = gun_option
		if((gun_option.w_class < 4) && ((gun_option.fire_delay * 0.1 * gun_option.ammo_datum_type::damage) > (small_gun_choice?.fire_delay * 0.1 * small_gun_choice?.ammo_datum_type::damage)))
			small_gun_choice = gun_option

	//logic block
	if(shield_choice)
		secondary = shield_choice
	if(high_dam_melee_choice)
		primary = high_dam_melee_choice
	if(big_gun_choice)
		if(!primary)
			primary = big_gun_choice
		else if(!secondary)
			secondary = big_gun_choice
	if(small_gun_choice)
		if(!primary)
			primary = small_gun_choice
		else if(!secondary && primary != big_gun_choice && !(primary.item_flags & TWOHANDED)) //no double guns for now
			secondary = small_gun_choice
	if(melee_choice) //this will never equip pistol dagger. not necessarily a bad thing though
		if(!primary)
			primary = melee_choice
		else if(!secondary && primary != high_dam_melee_choice  && !(primary.item_flags & TWOHANDED)) //no double melee
			secondary = melee_choice

	need_weapons = FALSE //fuck you if you somehow are unable to equip weapons at this point, you probs have no arms or something.
	//equip block
	if(primary)
		if(isgun(primary))
			equip_gun(primary)
			if(!secondary)
				equip_melee(primary)
				primary.attack_self(mob_parent)
		else
			equip_melee(primary)
			primary.attack_self(mob_parent) //this failed on disarm (not knockover)
	if(secondary)
		if(isgun(secondary))
			equip_gun(secondary)
		else
			if(isgun(primary))
				equip_melee(secondary)
			else //this is purely for shield, but we still need to reg the sigs. yes this is horrible
				RegisterSignals(secondary, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(unequip_weapon), TRUE)
			equip_melee(secondary)
			secondary.attack_self(mob_parent)

	engagement_range = primary.get_ai_combat_range()

/datum/ai_behavior/human/proc/equip_gun(obj/item/weapon/new_weapon)
	if(new_weapon != mob_parent.l_hand && new_weapon != mob_parent.r_hand)
		mob_parent.temporarilyRemoveItemFromInventory(new_weapon)
		if(!mob_parent.put_in_hands(new_weapon))
			return FALSE

	RegisterSignals(new_weapon, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(unequip_weapon), TRUE) //hacky, can probs unfuck this later
	gun = new_weapon
	return TRUE

/datum/ai_behavior/human/proc/equip_melee(obj/item/weapon/new_weapon)
	if(new_weapon != mob_parent.l_hand && new_weapon != mob_parent.r_hand)
		mob_parent.temporarilyRemoveItemFromInventory(new_weapon)
		if(!mob_parent.put_in_hands(new_weapon))
			return FALSE

	RegisterSignals(new_weapon, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(unequip_weapon), TRUE) //hacky, can probs unfuck this later
	melee_weapon = new_weapon
	return TRUE

/datum/ai_behavior/human/proc/unequip_weapon(obj/item/weapon/old_weapon)
	UnregisterSignal(old_weapon, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	need_weapons = TRUE //this may actually make a lot of stuff redundant? need to test
	if(gun == old_weapon)
		stop_fire()
		gun = null
		engagement_range = melee_weapon ? melee_weapon.get_ai_combat_range(): initial(distance_to_maintain)
	if(melee_weapon == old_weapon)
		melee_weapon = null
//shooting stuff

/datum/ai_behavior/human/proc/check_gun_fire(atom/target) //change this horrible name oh god
	var/fire_result = can_shoot_target(target)
	if(!gun_firing)
		if(fire_result == AI_FIRE_NO_AMMO)
			reload_gun()
			return
		if(fire_result != AI_FIRE_CAN_HIT)
			return //cant shoot yet
		if(prob(90))
			try_speak(pick(start_fire_chat))
		if(gun.start_fire(mob_parent, target, get_turf(target)) && gun.gun_firemode != GUN_FIREMODE_SEMIAUTO && gun.gun_firemode != GUN_FIREMODE_BURSTFIRE) //failed to fire or not autofire
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
				try_speak(pick(dead_target_chat))
		if(AI_FIRE_NO_AMMO)
			reload_gun()
		if(AI_FIRE_OUT_OF_RANGE)
			if(prob(50))
				try_speak(pick(out_range_chat))
		if(AI_FIRE_NO_LOS)
			if(prob(50))
				try_speak(pick(no_los_chat))
		if(AI_FIRE_FRIENDLY_BLOCKED)
			if(prob(50))
				try_speak(pick(friendly_blocked_chat))

//inline before release unless needed
/datum/ai_behavior/human/proc/can_shoot_target(atom/target)
	if(QDELETED(target))
		return AI_FIRE_INVALID_TARGET
	if(gun.rounds <= 0)
		return AI_FIRE_NO_AMMO

	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return AI_FIRE_TARGET_DEAD
	else //must be obj
		if(isarmoredvehicle(target))
			var/obj/vehicle/sealed/armored/armored_target = target
			if(armored_target.armored_flags & ARMORED_IS_WRECK)
				return AI_FIRE_TARGET_DEAD
		if(ismachinery(target))
			var/obj/machinery/machinery_target = target
			if(machinery_target.machine_stat & BROKEN)
				return AI_FIRE_TARGET_DEAD

	if(get_dist(target, mob_parent) > target_distance)
		return AI_FIRE_OUT_OF_RANGE
	if(!line_of_sight(mob_parent, target)) //todo: this proc could have checks for friendlies in it
		return AI_FIRE_NO_LOS

	if(no_ff && !(gun.gun_features_flags & GUN_IFF) && !(gun.ammo_datum_type::ammo_behavior_flags & AMMO_IFF)) //ammo_datum_type is always populated, with the last loaded ammo type. This shouldnt be an issue since we check ammo first
		var/list/turf_line = get_traversal_line(mob_parent, target)
		turf_line.Cut(1, 2) //don't count our own turf
		for(var/turf/line_turf AS in turf_line)
			for(var/mob/line_mob in line_turf) //todo: add checks for vehicles etc
				if(line_mob.faction == mob_parent.faction)
					return AI_FIRE_FRIENDLY_BLOCKED //friendly in the way
	return AI_FIRE_CAN_HIT


/datum/ai_behavior/human/proc/stop_fire()
	//is there any case where we want this triggering from COMSIG_GUN_STOP_FIRE ?
	gun_firing = FALSE
	gun.stop_fire()

/datum/ai_behavior/human/proc/reload_gun()
	var/obj/item/new_ammo
	if(gun.reciever_flags & AMMO_RECIEVER_HANDFULS)
		handful_loop:
			for(var/obj/item/ammo_magazine/handful_option in mob_inventory.ammo_list)
				if(handful_option.caliber != gun.caliber)
					continue
				new_ammo = handful_option
				break handful_loop
	else
		find_ammo_loop:
			for(var/ammo_type in gun.allowed_ammo_types)
				for(var/obj/item/ammo_option AS in mob_inventory.ammo_list)
					if(ammo_option.type != ammo_type)
						continue
					new_ammo = ammo_option
					break find_ammo_loop
	if(!new_ammo)
		//drop gun - what about empty magharnessed guns tho? oh well
		//insert messaging etc
		return
	if(prob(90))
		try_speak(pick(reloading_chat))
	if((gun.reciever_flags & AMMO_RECIEVER_HANDFULS))
		var/obj/item/ammo_magazine/handful_mag = new_ammo
		while(handful_mag.current_rounds)
			if(!gun.reload(handful_mag, mob_parent))
				return
	gun.reload(new_ammo, mob_parent) //skips tac reload but w/e. if we want it, then we need to check for skills...
	//note: force arg on reload will allow reloading closed chamber weapons, but also bypasses reload delays... funny rapid rockets

/////probs move
///Optimal range for AI to fight at, using this weapon
/obj/item/weapon/proc/get_ai_combat_range()
	return list(0, 1)

/obj/item/weapon/twohanded/spear/get_ai_combat_range()
	return 2

/obj/item/weapon/gun/get_ai_combat_range()
	if((gun_features_flags & GUN_IFF) || (ammo_datum_type::ammo_behavior_flags & AMMO_IFF))
		return list(5, 7) //hang in the back with IFF
	return list(4, 5)

/obj/item/weapon/gun/shotgun/get_ai_combat_range()
	if(ammo_datum_type == /datum/ammo/bullet/shotgun/buckshot)
		return 1
	return list(4, 5)

/obj/item/weapon/gun/smg/get_ai_combat_range()
	return list(3, 4)

/obj/item/weapon/gun/pistol/get_ai_combat_range()
	return list(3, 4)

/obj/item/weapon/gun/revolver/get_ai_combat_range()
	return list(3, 4)

/obj/item/weapon/gun/launcher/get_ai_combat_range()
	return list(7, 8)

/obj/item/weapon/gun/grenade_launcher/get_ai_combat_range()
	return list(6, 8)
