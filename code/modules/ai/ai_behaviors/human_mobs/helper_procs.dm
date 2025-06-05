//Interaction stuff

///Checks if the AI can or should use this
/obj/item/proc/ai_should_use(mob/living/target, mob/living/user)
	return TRUE

/obj/item/stack/medical/heal_pack/ai_should_use(mob/living/target, mob/living/user)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_mob = target
	for(var/limb AS in human_mob.limbs)
		if(can_heal_limb(limb))
			return TRUE
	return FALSE

/obj/item/reagent_containers/ai_should_use(mob/living/target, mob/living/user)
	if(!length(reagents.reagent_list)) //this should never fail but some reagent container code is old and cursed
		return FALSE
	for(var/datum/reagent/reagent AS in reagents.reagent_list)
		if(!reagent.ai_should_use(target, reagent.volume))
			return FALSE
	return TRUE

/obj/item/reagent_containers/hypospray/ai_should_use(mob/living/target, mob/living/user)
	if(!length(reagents.reagent_list)) //todo: discard if empty
		return FALSE
	for(var/datum/reagent/reagent AS in reagents.reagent_list)
		if(!reagent.ai_should_use(target, reagent.volume / reagents.total_volume * amount_per_transfer_from_this))
			return FALSE
	return TRUE

/obj/item/weapon/gun/ai_should_use(mob/living/target, mob/living/user)
	if(gun_features_flags & GUN_DEPLOYED_FIRE_ONLY)
		return FALSE //some day
	return TRUE

/obj/item/reagent_containers/food/ai_should_use(mob/living/target, mob/living/user)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	if((reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) * 37.5) + human_target.nutrition >= NUTRITION_OVERFED)
		return FALSE
	return TRUE

///AI uses this item in some manner, such as consuming or activating it
/obj/item/proc/ai_use(mob/living/target, mob/living/user)
	return FALSE

/obj/item/stack/medical/ai_use(mob/living/target, mob/living/user)
	attack(target, user)

/obj/item/reagent_containers/ai_use(mob/living/target, mob/living/user)
	afterattack(target, user, TRUE) //why are all these medical item inconsistant with their proc usage, holy shit

/obj/item/reagent_containers/pill/ai_use(mob/living/target, mob/living/user)
	attack(target, user)

/obj/item/tweezers/ai_use(mob/living/target, mob/living/user)
	attack(target, user)

/obj/item/tweezers_advanced/ai_use(mob/living/target, mob/living/user)
	attack(target, user)

/obj/item/weapon/ai_use(mob/living/target, mob/living/user)
	if(!(item_flags & TWOHANDED))
		return
	if(item_flags & WIELDED)
		return
	wield(user)
	return TRUE

/obj/item/weapon/energy/axe/ai_use(mob/living/target, mob/living/user) //todo: make all energy weapon use the sane code as esword
	if(!active)
		attack_self(user)
		return TRUE

/obj/item/weapon/energy/sword/ai_use(mob/living/target, mob/living/user)
	if(!active)
		switch_state(null, user)
		return TRUE

/obj/item/weapon/butterfly/ai_use(mob/living/target, mob/living/user)
	if(!active)
		attack_self(user)
		return TRUE

/obj/item/weapon/gun/ai_use(mob/living/target, mob/living/user)
	. = ..()
	if((GUN_FIREMODE_AUTOBURST in gun_firemode_list) && gun_firemode != GUN_FIREMODE_AUTOBURST)
		do_toggle_firemode(new_firemode = GUN_FIREMODE_AUTOBURST) //auto is on by default for guns that have it, but autoburst is always the best mode if its available

/obj/item/reagent_containers/food/ai_use(mob/living/target, mob/living/user)
	target.attackby(src, user)

/obj/item/reagent_containers/food/snacks/ai_use(mob/living/target, mob/living/user)
	if(package)
		attack_self(user)
	return ..()

///AI mob interaction with this atom, such as picking it up
/atom/proc/do_ai_interact(mob/living/interactor, datum/ai_behavior/human/behavior_datum)
	return

/obj/do_ai_interact(mob/living/interactor, datum/ai_behavior/human/behavior_datum)
	//todo: this will still make non engineers investigate something they can't repair
	if(behavior_datum.engineer_rating < AI_ENGIE_STANDARD)
		return
	behavior_datum.add_to_engineering_list(src)
	behavior_datum.repair_obj(src)

/obj/machinery/door/airlock/do_ai_interact(mob/living/interactor, datum/ai_behavior/human/behavior_datum)
	if(density)
		open(TRUE)
	else
		close(TRUE)

/obj/alien/do_ai_interact(mob/living/interactor, datum/ai_behavior/human/behavior_datum)
	if(behavior_datum.melee_weapon)
		attackby(behavior_datum.melee_weapon, interactor)

/obj/item/do_ai_interact(mob/living/interactor, datum/ai_behavior/human/behavior_datum)
	behavior_datum.store_hands()
	if(interactor.get_active_held_item())
		return
	interactor.UnarmedAttack(src, TRUE) //only used for picking up items atm
	if(loc != interactor)
		return
	behavior_datum.try_store_item(src)

/obj/item/storage/box/visual/magazine/do_ai_interact(mob/living/interactor, datum/ai_behavior/human/behavior_datum)
	behavior_datum.store_hands()
	if(interactor.get_active_held_item())
		return

	var/list/valid_ammo = list()
	for(var/obj/item/weapon/gun/gun AS in behavior_datum.mob_inventory.gun_list)
		valid_ammo += gun.allowed_ammo_types

	if(!length(valid_ammo))
		return

	for(var/obj/magazine AS in contents)
		if(!(magazine.type in valid_ammo))
			continue
		if(!behavior_datum.try_store_item(magazine))
			return

/obj/machinery/power/apc/do_ai_interact(mob/living/interactor, datum/ai_behavior/human/behavior_datum)
	if(length(wires.cut_wires))
		var/obj/item/tool/wirecutters/cutters = behavior_datum.mob_inventory.find_tool(TOOL_WIRECUTTER)
		if(cutters)
			for(var/wire in wires.cut_wires)
				wires.cut(wire)

	if(!cell || (!cell.charge && charging == APC_NOT_CHARGING))
		var/obj/item/cell/new_cell
		for(var/obj/item/cell/candidate_cell in behavior_datum.mob_inventory.engineering_list)
			if(candidate_cell.charge)
				new_cell = candidate_cell
				break
		if(new_cell)
			if(cell)
				//clean this up
				balloon_alert_to_viewers("Removes [cell] from [src]")
				interactor.put_in_hands(cell)
				cell.update_appearance()
				set_cell(null)
				charging = APC_NOT_CHARGING
				update_appearance()
			attackby(new_cell, interactor)

	if(!operating)
		toggle_breaker(interactor)

	if(opened == APC_COVER_OPENED)
		var/obj/item/crowbar = behavior_datum.mob_inventory.find_tool(TOOL_CROWBAR)
		if(crowbar)
			crowbar_act(interactor, crowbar)
	if(machine_stat & PANEL_OPEN)
		var/obj/item/screwdriver = behavior_datum.mob_inventory.find_tool(TOOL_SCREWDRIVER)
		if(screwdriver)
			screwdriver_act(interactor, screwdriver)

/obj/effect/build_designator/do_ai_interact(mob/living/interactor, datum/ai_behavior/human/behavior_datum)
	behavior_datum.try_build_holo(src)

/turf/closed/interior/tank/door/do_ai_interact(mob/living/interactor, datum/ai_behavior/human/behavior_datum)
	attack_hand(interactor)

//weapon engagement range

///Optimal range for AI to fight at, using this weapon
/obj/item/weapon/proc/get_ai_combat_range()
	return list(0, 1)

/obj/item/weapon/twohanded/spear/get_ai_combat_range()
	return 2

/obj/item/weapon/gun/get_ai_combat_range()
	if((gun_features_flags & GUN_IFF) || (ammo_datum_type::ammo_behavior_flags & AMMO_IFF))
		return list(5, 7)
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

//Hazards

///Notifies AI of a new hazard
/atom/proc/notify_ai_hazard()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_HAZARD_NOTIFIED, src)

///Returns the radius around this considered a hazard
/atom/proc/get_ai_hazard_radius(mob/living/victim)
	return 0 //null means no danger, vs 0 means stay off the hazard's turf

/obj/item/explosive/grenade/get_ai_hazard_radius(mob/living/victim)
	if(!dangerous)
		return null
	if((victim.get_soft_armor(BOMB) >= 100))
		return null
	return light_impact_range ? light_impact_range : 3

/obj/item/explosive/grenade/smokebomb/get_ai_hazard_radius(mob/living/victim)
	if(!dangerous)
		return null
	if((victim.get_soft_armor(BIO) >= 100))
		return null
	return smokeradius

/obj/item/explosive/grenade/globadier/get_ai_hazard_radius(mob/living/victim)
	return 1

/obj/fire/get_ai_hazard_radius(mob/living/victim)
	if((victim.get_soft_armor(FIRE) >= 100))
		return null
	return 0

//Obstacle handling
///Handles the obstacle or tells AI behavior how to interact with it
/obj/proc/ai_handle_obstacle(mob/living/user, move_dir) //do we need to/can we just check can_pass???
	if((loc == user.loc) && !(atom_flags & ON_BORDER)) //dense things under us don't block
		return AI_OBSTACLE_IGNORED
	if((atom_flags & ON_BORDER) && (move_dir != (loc == user.loc ? dir : REVERSE_DIR(dir)))) //we only care about border objects actually blocking us
		return AI_OBSTACLE_IGNORED
	//todo:walkover stuff?
	if(user.can_jump() && is_jumpable(user))
		return AI_OBSTACLE_JUMP
	if(faction == user.faction) //don't break our shit
		return AI_OBSTACLE_FRIENDLY
	if(!(resistance_flags & INDESTRUCTIBLE) && (obj_flags & CAN_BE_HIT))
		return AI_OBSTACLE_ATTACK

/obj/structure/ai_handle_obstacle(mob/living/user, move_dir)
	. = ..()
	if(. == AI_OBSTACLE_IGNORED)
		return
	if(. == AI_OBSTACLE_JUMP)
		return //jumping is always best
	if(!climbable)
		return
	INVOKE_ASYNC(src, PROC_REF(do_climb), user)
	return AI_OBSTACLE_RESOLVED

/obj/structure/barricade/folding/ai_handle_obstacle(mob/living/user, move_dir)
	toggle_open(null, user)
	return AI_OBSTACLE_RESOLVED

/obj/machinery/door/airlock/ai_handle_obstacle(mob/living/user, move_dir)
	. = ..()
	if(!.)
		return
	if(operating) //Airlock already doing something
		return null
	if(welded || locked) //It's welded or locked, can't force that open
		return
	open(TRUE)
	return AI_OBSTACLE_RESOLVED

///Whether an NPC mob should stay buckled to this atom or not
/atom/movable/proc/ai_should_stay_buckled(mob/living/carbon/npc)
	return FALSE

//test stuff
/mob/living/proc/add_test_ai()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)

/mob/living/proc/add_test_ai_all()
	for(var/mob/living/carbon/human/human_mob AS in GLOB.alive_human_list)
		if(human_mob.client)
			continue
		human_mob.AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)

/mob/living/carbon/human/ai/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)
