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
	for(var/datum/reagent/reagent AS in reagents.reagent_list)
		if(reagent.volume + target.reagents.get_reagent_amount(reagent.type) > reagent.overdose_threshold)
			return FALSE
	return TRUE

/obj/item/reagent_containers/hypospray/ai_should_use(mob/living/target, mob/living/user)
	if(!length(reagents.reagent_list)) //todo: discard if empty
		return FALSE
	for(var/datum/reagent/reagent AS in reagents.reagent_list)
		if((reagent.volume / reagents.total_volume * amount_per_transfer_from_this) + target.reagents.get_reagent_amount(reagent.type) > reagent.overdose_threshold)
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
	if(item_flags != TWOHANDED)
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

///AI mob interaction with this atom, such as picking it up
/atom/proc/do_ai_interact(mob/living/interactor)
	interactor.UnarmedAttack(src, TRUE) //only used for picking up items atm

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
	return null //null means no danger, vs 0 means stay off the hazard's turf

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

/obj/fire/get_ai_hazard_radius(mob/living/victim)
	if((victim.get_soft_armor(FIRE) >= 100))
		return null
	return 0

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
