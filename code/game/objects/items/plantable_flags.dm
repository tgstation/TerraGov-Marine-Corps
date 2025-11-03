///Range of the aura
#define FLAG_AURA_RANGE 9
///Range of the aura when deployed
#define FLAG_AURA_DEPLOYED_RANGE 12
///The range in tiles which the flag makes people warcry
#define FLAG_WARCRY_RANGE 5
///Strength of the aura
#define FLAG_AURA_STRENGTH 3
///Penalty aura for losing or otherwise disgracing the flag
#define LOST_FLAG_AURA_STRENGTH -2

/obj/item/plantable_flag
	name = "\improper TerraGov flag"
	desc = "A flag bearing the symbol of TerraGov. It flutters in the breeze heroically. This one looks ready to be planted into the ground."
	icon = 'icons/obj/items/flags/plantable_flag_large.dmi'
	icon_state = "flag_tgmc"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/large_flag_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/large_flag_right.dmi',
	)
	w_class = WEIGHT_CLASS_HUGE
	force = 55
	attack_speed = 15
	attack_verb = list("stabs", "thrusts", "smashes", "thumps", "bashes", "attacks", "clubs", "spears", "jabs", "tears", "gores")
	sharp = IS_SHARP_ITEM_BIG
	throw_speed = 1
	throw_range = 2
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 50, ACID = 50)
	faction = FACTION_TERRAGOV
	///Aura emitter
	var/datum/aura_bearer/current_aura
	///Start point for it to return to when called
	var/turf/origin_point

/obj/item/plantable_flag/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(mission_end))
	origin_point = get_turf(src)
	if(isturf(loc))
		item_flags |= DEPLOY_ON_INITIALIZE
	AddComponent(/datum/component/deployable_item, /obj/structure/plantable_flag, 1 SECONDS, 3 SECONDS)
	AddComponent(/datum/component/shield, SHIELD_PURE_BLOCKING, list(MELEE = 35, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0))
	current_aura = SSaura.add_emitter(src, AURA_HUMAN_FLAG, FLAG_AURA_RANGE, FLAG_AURA_STRENGTH, -1, faction)
	return INITIALIZE_HINT_LATELOAD

/obj/item/plantable_flag/LateInitialize()
	. = ..()
	update_aura()

/obj/item/plantable_flag/Destroy()
	origin_point = null
	return ..()

/obj/item/plantable_flag/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	SSaura.add_emitter(get_turf(src), AURA_HUMAN_FLAG, INFINITY, LOST_FLAG_AURA_STRENGTH, -1, faction)

	if(istype(blame_mob) && blame_mob.ckey)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[blame_mob.ckey]
		if(faction == blame_mob.faction) //prepare for court martial
			personal_statistics.flags_destroyed --
			personal_statistics.mission_flags_destroyed --
		else
			personal_statistics.flags_destroyed ++
			personal_statistics.mission_flags_destroyed ++
	return ..()

/obj/item/plantable_flag/toggle_deployment_flag(deployed)
	. = ..()
	update_aura()

/obj/item/plantable_flag/Moved()
	. = ..()
	update_aura()

/obj/item/plantable_flag/attack_self(mob/user)
	. = ..()
	lift_flag(user)

/obj/item/plantable_flag/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(150, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(75, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(15, BRUTE, BOMB)

/obj/item/plantable_flag/fire_act(burn_level)
	take_damage(burn_level * 3, BURN, FIRE)

///Updates the aura strength based on where its currently located
/obj/item/plantable_flag/proc/update_aura()
	if(!current_aura)
		return
	current_aura.range = item_flags & IS_DEPLOYED ? FLAG_AURA_DEPLOYED_RANGE : FLAG_AURA_RANGE
	if(isturf(loc))
		current_aura.strength = LOST_FLAG_AURA_STRENGTH
		return
	if(!isliving(loc))
		return
	var/mob/living/living_holder = loc
	if(living_holder.faction == faction)
		current_aura.strength = FLAG_AURA_STRENGTH
	else
		current_aura.strength = LOST_FLAG_AURA_STRENGTH //this explicitly lets enemies deploy it for the extended debuff range

///Waves the flag around heroically
/obj/item/plantable_flag/proc/lift_flag(mob/user)
	if(TIMER_COOLDOWN_RUNNING(user, COOLDOWN_WHISTLE_WARCRY))
		user.balloon_alert(user, "on cooldown!")
		return

	TIMER_COOLDOWN_START(user, COOLDOWN_WHISTLE_WARCRY, 1 MINUTES)
	user.visible_message(span_boldnotice("[user] lifts up [src] triumphantly!"))
	playsound(get_turf(src), 'sound/items/plantable_flag/flag_raised.ogg', 75)
	addtimer(CALLBACK(src, PROC_REF(do_warcry), user), 1 SECONDS)

///Triggers a mass warcry from your faction
/obj/item/plantable_flag/proc/do_warcry(mob/user)
	for(var/mob/living/carbon/human/human in get_hearers_in_view(FLAG_WARCRY_RANGE, user.loc))
		if(human.faction != faction)
			continue
		human.emote("warcry", intentional = TRUE)
		CHECK_TICK

///End of mission bonuses
/obj/item/plantable_flag/proc/mission_end(datum/source, datum/campaign_mission/completed_mission, winning_faction)
	SIGNAL_HANDLER
	if(!isliving(loc))
		forceMove(origin_point)
		return
	var/mob/living/controlling_mob = loc
	if(!controlling_mob.ckey)
		forceMove(origin_point)
		return
	if(faction == controlling_mob.faction)
		forceMove(origin_point)
		return
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[controlling_mob.ckey]
	personal_statistics.flags_captured ++
	personal_statistics.mission_flags_captured ++

/obj/item/plantable_flag/som
	name = "\improper SOM flag"
	desc = "A flag bearing the symbol of the Sons of Mars. It flutters in the breeze heroically. This one looks ready to be planted into the ground."
	icon_state = "flag_som"
	faction = FACTION_SOM

/obj/structure/plantable_flag
	name = "flag"
	desc = "A flag of something. This one looks like you could dismantle it."
	icon = 'icons/obj/items/flags/plantable_flag_large.dmi'
	pixel_x = 9
	pixel_y = 12
	layer = ABOVE_ALL_MOB_LAYER
	resistance_flags = XENO_DAMAGEABLE
	///Weakref to item that is deployed to create src
	var/datum/weakref/internal_item

/obj/structure/plantable_flag/Initialize(mapload, _internal_item, mob/deployer)
	. = ..()
	if(!internal_item && !_internal_item)
		return INITIALIZE_HINT_QDEL

	internal_item = WEAKREF(_internal_item)

	var/obj/item/plantable_flag/new_internal_item = get_internal_item()

	name = new_internal_item.name
	desc = new_internal_item.desc
	icon = new_internal_item.icon
	soft_armor = new_internal_item.soft_armor
	hard_armor = new_internal_item.hard_armor
	update_appearance(UPDATE_ICON_STATE)
	if(deployer)
		new_internal_item.lift_flag(deployer)
		log_game("[key_name(deployer)] has deployed the flag at [AREACOORD(src)].")

/obj/structure/plantable_flag/Destroy()
	clear_internal_item()
	return ..()

/obj/structure/plantable_flag/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	var/obj/item/plantable_flag/internal_flag = get_internal_item()
	internal_flag?.deconstruct(FALSE, blame_mob)
	return ..()

/obj/structure/plantable_flag/get_internal_item()
	return internal_item?.resolve()

/obj/structure/plantable_flag/clear_internal_item()
	internal_item = null

/obj/structure/plantable_flag/update_icon_state()
	var/obj/item/current_internal_item = get_internal_item()
	icon_state = "[current_internal_item.icon_state]_planted"

/obj/structure/plantable_flag/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(150, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(75, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(15, BRUTE, BOMB)

/obj/structure/plantable_flag/fire_act(burn_level)
	take_damage(burn_level, BURN, FIRE)

/obj/structure/plantable_flag/MouseDrop(over_object, src_location, over_location)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(over_object != user || !in_range(src, user))
		return
	var/obj/item/current_internal_item = get_internal_item()
	if(!current_internal_item)
		return
	disassemble(user)
	log_game("[key_name(user)] has undeployed the flag at [AREACOORD(src)].")
