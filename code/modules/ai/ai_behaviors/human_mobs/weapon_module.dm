//code specific to ranged and melee weapons
/datum/ai_behavior/human
	///Currently equipped and ready firearm
	var/obj/item/weapon/gun/gun
	///Currently equipped and ready melee weapon - could also be the gun
	var/obj/item/weapon/melee_weapon
	///Chat lines when opening fire
	var/list/start_fire_chat = list("Get some!!", "Engaging!", "Open fire!", "Firing!", "Hostiles!", "Take them out!", "Kill 'em!", "Lets rock!", "Fire!!", "Gun them down!", "Shooting!", "Weapons free!", "Fuck you!!")
	///Chat lines when reloading
	var/list/reloading_chat = list("Reloading!", "Cover me, reloading!", "Changing mag!", "Out of ammo!")
	///Chat lines when target goes out of range
	var/list/out_range_chat = list("Target out of range.", "Out of range.", "I lost them.", "Where'd they go?", "They're running!")
	///Chat lines when LOS broken
	var/list/no_los_chat = list("Target lost!", "Where'd they go?", "I lost sight of them!", "Where'd they go?", "They're running!", "Stop hiding!")
	///Chat lines when some asshole on your team is in the way
	var/list/friendly_blocked_chat = list("Get out of the way!", "You're in my line!", "Clear the firing lane!", "Move!", "Holding fire!", "Stop blocking me damn it!")
	///Chat lines when target dies or is destroyed
	var/list/dead_target_chat = list("Target down.", "Hostile down.", "Scratch one.", "I got one!", "Down for the count.", "Kill confirmed.")

/datum/ai_behavior/human/melee_interact(datum/source, atom/interactee, melee_tool = melee_weapon) //specifies the arg value
	return ..()

///Weapon stuff that happens during process
/datum/ai_behavior/human/proc/weapon_process()
	if((human_ai_state_flags & HUMAN_AI_NEED_WEAPONS) && !(human_ai_state_flags & HUMAN_AI_BUSY_ACTION))
		equip_weaponry()
	if(!gun)
		return

	var/fire_result = can_shoot_target(combat_target)
	if(human_ai_state_flags & HUMAN_AI_FIRING)
		if(fire_result != AI_FIRE_CAN_HIT)
			stop_fire(fire_result)
		return

	if(fire_result == AI_FIRE_NO_AMMO)
		INVOKE_ASYNC(src, PROC_REF(reload_gun))
		return
	if(fire_result != AI_FIRE_CAN_HIT)
		return
	if(prob(90))
		try_speak(pick(start_fire_chat))
	if(gun.reciever_flags & AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION)
		gun.unique_action(mob_parent)
	if(gun.start_fire(mob_parent, combat_target, get_turf(combat_target)) && gun.gun_firemode != GUN_FIREMODE_SEMIAUTO && gun.gun_firemode != GUN_FIREMODE_BURSTFIRE)
		human_ai_state_flags |= HUMAN_AI_FIRING

///Tries to equip weaponry from inventory, or find some if none are available
/datum/ai_behavior/human/proc/equip_weaponry(datum/source)
	SIGNAL_HANDLER
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		human_ai_state_flags |= HUMAN_AI_NEED_WEAPONS
		return
	if(!length(mob_inventory.melee_list) && !length(mob_inventory.gun_list))
		human_ai_state_flags |= HUMAN_AI_NEED_WEAPONS
		upper_engage_dist = initial(upper_engage_dist)
		lower_engage_dist = initial(lower_engage_dist)
		find_weapon()
		return
	INVOKE_ASYNC(src, PROC_REF(do_equip_weaponry))

///Searches for a weapon to pickup
/datum/ai_behavior/human/proc/find_weapon(range = 1, list/exlusion_turfs)
	var/list/search_list = list(get_turf(mob_parent))
	search_list |= RANGE_TURFS(range, mob_parent)
	for(var/turf/turf AS in search_list)
		for(var/obj/obj in turf)
			if(!istype(obj, /obj/item/weapon))
				continue
			set_interact_target(obj)
			return

///Tries to equip weaponry, and updates behavior appropriately
/datum/ai_behavior/human/proc/do_equip_weaponry()
	store_hands()

	var/obj/item/weapon/primary
	var/obj/item/weapon/secondary

	var/obj/item/weapon/primary_melee_choice
	var/obj/item/weapon/standard_melee_choice
	var/obj/item/weapon/low_melee_choice
	var/obj/item/weapon/shield/shield_choice
	var/obj/item/weapon/gun/big_gun_choice
	var/obj/item/weapon/gun/small_gun_choice

	for(var/obj/item/weapon/melee_option AS in mob_inventory.melee_list)
		var/melee_option_str = max(melee_option.force, melee_option.force_activated)
		if((melee_option_str >= 80) && (melee_option_str >= max(primary_melee_choice?.force, primary_melee_choice?.force_activated)))
			primary_melee_choice = melee_option
		if((melee_option_str >= 50) && (melee_option_str >= max(standard_melee_choice?.force, standard_melee_choice?.force_activated)))
			standard_melee_choice = melee_option
		else if((melee_option_str < 50) && (melee_option_str >= max(low_melee_choice?.force, low_melee_choice?.force_activated)))
			low_melee_choice = melee_option
		if(istype(melee_option, /obj/item/weapon/shield) && melee_option.obj_integrity > shield_choice?.obj_integrity) //shield could be the best melee weapon full stop
			shield_choice = melee_option

	for(var/obj/item/weapon/gun/gun_option AS in mob_inventory.gun_list)
		if(!gun_option.ai_should_use(user = mob_parent))
			continue
		if((gun_option.w_class >= 4) && ((gun_option.fire_delay * 0.1 * gun_option.ammo_datum_type::damage) > (big_gun_choice?.fire_delay * 0.1 * big_gun_choice?.ammo_datum_type::damage)))
			big_gun_choice = gun_option
		if((gun_option.w_class < 4) && ((gun_option.fire_delay * 0.1 * gun_option.ammo_datum_type::damage) > (small_gun_choice?.fire_delay * 0.1 * small_gun_choice?.ammo_datum_type::damage)))
			small_gun_choice = gun_option

	if(shield_choice)
		secondary = shield_choice
	if(primary_melee_choice)
		primary = primary_melee_choice
	else if(big_gun_choice && !primary)
		primary = big_gun_choice
	else if(standard_melee_choice)
		primary = standard_melee_choice
	if(small_gun_choice)
		if(!primary)
			primary = small_gun_choice
		else if(!secondary && !(primary.item_flags & TWOHANDED)) //no double guns for now
			secondary = small_gun_choice
	if(low_melee_choice && !primary)
		primary = low_melee_choice

	if(!primary)
		return

	var/equip_success = FALSE
	if(primary)
		if(isgun(primary))
			if(equip_gun(primary))
				equip_success = TRUE
			if(!secondary)
				equip_melee(primary)
				primary.ai_use(null, mob_parent)
		else if(equip_melee(primary))
			equip_success = TRUE
			primary.ai_use(null, mob_parent)
	if(secondary)
		if(isgun(secondary))
			equip_gun(secondary) //don't wield a pistol and drop your sword
		else if(secondary == shield_choice)
			after_equip_melee(shield_choice) //doesnt override a primary melee weapon
		else
			equip_melee(secondary)
			secondary.ai_use(null, mob_parent)

	if(!equip_success)
		return

	human_ai_state_flags &= ~HUMAN_AI_NEED_WEAPONS

	var/list/primary_range = primary.get_ai_combat_range()
	upper_engage_dist = max(primary_range)
	lower_engage_dist = min(primary_range)

///Equips a gun
/datum/ai_behavior/human/proc/equip_gun(obj/item/weapon/new_weapon)
	if(new_weapon != mob_parent.l_hand && new_weapon != mob_parent.r_hand)
		mob_parent.temporarilyRemoveItemFromInventory(new_weapon)
		if(!mob_parent.put_in_hands(new_weapon))
			return FALSE

	SEND_SIGNAL(new_weapon, COMSIG_AI_EQUIPPED_GUN, mob_parent) //todo: make another sig for belt strap to trigger off
	RegisterSignals(new_weapon, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(unequip_weapon), TRUE) //One item can be both the gun and melee weapon for a mob
	gun = new_weapon
	return TRUE

///Equips a melee weapon
/datum/ai_behavior/human/proc/equip_melee(obj/item/weapon/new_weapon)
	if(new_weapon != mob_parent.l_hand && new_weapon != mob_parent.r_hand)
		mob_parent.temporarilyRemoveItemFromInventory(new_weapon)
		if(!mob_parent.put_in_hands(new_weapon))
			return FALSE

	melee_weapon = new_weapon
	after_equip_melee(new_weapon)
	return TRUE

///Handles signals for equip melee
/datum/ai_behavior/human/proc/after_equip_melee(obj/item/weapon/new_weapon)
	SEND_SIGNAL(new_weapon, COMSIG_AI_EQUIPPED_MELEE, mob_parent)
	RegisterSignals(new_weapon, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(unequip_weapon), TRUE)

///Unequips a weapon
/datum/ai_behavior/human/proc/unequip_weapon(obj/item/weapon/old_weapon)
	UnregisterSignal(old_weapon, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	human_ai_state_flags |= HUMAN_AI_NEED_WEAPONS
	//todo: loosen straps?
	if(gun == old_weapon)
		stop_fire()
		gun = null
		if(melee_weapon)
			var/list/melee_range = melee_weapon.get_ai_combat_range()
			upper_engage_dist = max(melee_range)
			lower_engage_dist = min(melee_range)
		else
			upper_engage_dist = initial(upper_maintain_dist)
			lower_engage_dist = initial(lower_maintain_dist)
	if(melee_weapon == old_weapon)
		melee_weapon = null

//Check if a target is valid for shooting
/datum/ai_behavior/human/proc/can_shoot_target(atom/target)
	if(QDELETED(target))
		return AI_FIRE_INVALID_TARGET
	if(gun.rounds <= 0)
		return AI_FIRE_NO_AMMO

	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return AI_FIRE_TARGET_DEAD
	else
		if(isarmoredvehicle(target))
			var/obj/vehicle/sealed/armored/armored_target = target
			if(armored_target.armored_flags & ARMORED_IS_WRECK)
				return AI_FIRE_TARGET_DEAD
		if(ismachinery(target))
			var/obj/machinery/machinery_target = target
			if(machinery_target.machine_stat & BROKEN)
				return AI_FIRE_TARGET_DEAD
		if(isfacehugger(target))
			var/obj/item/clothing/mask/facehugger/hugger = target
			if(hugger.stat == DEAD || !isturf(hugger.loc))
				return AI_FIRE_TARGET_DEAD //dead or nothing we can do about it

	var/dist = get_dist(target, mob_parent)
	if(dist > target_distance)
		return AI_FIRE_OUT_OF_RANGE
	//dist 1 has issues with LOS checks, causing failure to fire when being hit diagonally past a wall
	if((dist > 1) && !line_of_sight(mob_parent, target)) //todo: This doesnt check if we can actually shoot past stuff in the line, but also checking path seems excessive
		return AI_FIRE_NO_LOS

	//ammo_datum_type is always populated, with the last loaded ammo type. This shouldnt be an issue since we check ammo first
	if((human_ai_behavior_flags & HUMAN_AI_NO_FF) && !(gun.gun_features_flags & GUN_IFF) && !(gun.ammo_datum_type::ammo_behavior_flags & AMMO_IFF) && !check_path_ff(mob_parent, target))
		return AI_FIRE_FRIENDLY_BLOCKED
	return AI_FIRE_CAN_HIT

///Stops gunfire
/datum/ai_behavior/human/proc/stop_fire(stop_reason)
	human_ai_state_flags &= ~HUMAN_AI_FIRING
	gun?.stop_fire()

	if(!stop_reason)
		return

	switch(stop_reason)
		if(AI_FIRE_TARGET_DEAD, AI_FIRE_INVALID_TARGET)
			if(prob(75))
				try_speak(pick(dead_target_chat))
		if(AI_FIRE_NO_AMMO)
			INVOKE_ASYNC(src, PROC_REF(reload_gun))
		if(AI_FIRE_OUT_OF_RANGE)
			if(prob(50))
				try_speak(pick(out_range_chat))
		if(AI_FIRE_NO_LOS)
			if(prob(50))
				try_speak(pick(no_los_chat))
		if(AI_FIRE_FRIENDLY_BLOCKED)
			if(prob(50))
				try_speak(pick(friendly_blocked_chat))

///Tries to reload our gun
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
		//todo: drop/store ammoless gun - what about empty magharnessed guns tho?
		//insert messaging etc
		return
	if(prob(90))
		try_speak(pick(reloading_chat))
	if(gun.reciever_flags & AMMO_RECIEVER_TOGGLES_OPEN)
		gun.unique_action(mob_parent)
	if((gun.reciever_flags & AMMO_RECIEVER_HANDFULS))
		var/obj/item/ammo_magazine/handful_mag = new_ammo
		while(handful_mag.current_rounds)
			if(!gun.reload(handful_mag, mob_parent))
				break
	else
		gun.reload(new_ammo, mob_parent)

	if(gun.reciever_flags & AMMO_RECIEVER_TOGGLES_OPEN)
		gun.unique_action(mob_parent)

///Returns true is a path is clear of friendlies
/datum/ai_behavior/human/proc/check_path_ff(atom/start, atom/end)
	var/list/turf_line = get_traversal_line(start, end)
	turf_line.Cut(1, 2) //don't count our own turf
	for(var/turf/line_turf AS in turf_line)
		for(var/mob/line_mob in line_turf) //todo: add checks for vehicles etc
			if(line_mob.faction == mob_parent.faction)
				return FALSE
	return TRUE
