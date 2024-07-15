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
	attack_verb = list("stabbed", "thrust", "smashed", "thumped", "bashed", "attacked", "clubbed", "speared", "jabbed", "torn", "gored")
	sharp = IS_SHARP_ITEM_BIG
	throw_speed = 1
	throw_range = 2
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 50, ACID = 50)
	///The item this deploys into
	var/deployable_item = /obj/structure/plantable_flag
	///The faction this belongs to
	var/faction = FACTION_TERRAGOV
	///Aura emitter
	var/datum/aura_bearer/current_aura
	///Range of the aura
	var/aura_radius = 10
	///Strength of the aura
	var/aura_strength = 3
	/// The range in tiles which the flag makes people warcry
	var/warcry_range = 5

/obj/item/plantable_flag/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, 1 SECONDS, 3 SECONDS)
	AddComponent(/datum/component/shield, SHIELD_PURE_BLOCKING, list(MELEE = 35, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0))

	current_aura = SSaura.add_emitter(src, AURA_HUMAN_FLAG, aura_radius, aura_strength, -1, faction)
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
	if(isturf(loc))
		current_aura.strength = LOST_FLAG_AURA_STRENGTH
		return
	if(isliving(loc))
		var/mob/living/living_holder = loc
		if(living_holder.faction == faction)
			current_aura.strength = aura_strength
		else
			current_aura.strength = LOST_FLAG_AURA_STRENGTH

///Waves the flag around heroically
/obj/item/plantable_flag/proc/lift_flag(mob/user)
	if(TIMER_COOLDOWN_CHECK(user, COOLDOWN_WHISTLE_WARCRY))
		to_chat(user, span_notice("You have to wait a while to rally your troops..."))
		return

	TIMER_COOLDOWN_START(user, COOLDOWN_WHISTLE_WARCRY, 1 MINUTES)
	user.visible_message(span_warning("[user] lifts up [src] triumphantly!"))
	playsound(get_turf(src), 'sound/items/plantable_flag/flag_raised.ogg', 75)
	addtimer(CALLBACK(src, PROC_REF(do_warcry), user), 1 SECONDS)

///Triggers a mass warcry from your faction
/obj/item/plantable_flag/proc/do_warcry(mob/user)
	for(var/mob/living/carbon/human/human in get_hearers_in_view(warcry_range, user.loc))
		if(human.faction != faction)
			continue
		human.emote("warcry", intentional = TRUE)
		CHECK_TICK

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

	var/obj/item/plantable_flag/new_internal_item = internal_item.resolve()

	name = new_internal_item.name
	desc = new_internal_item.desc
	icon = new_internal_item.icon
	soft_armor = new_internal_item.soft_armor
	hard_armor = new_internal_item.hard_armor
	update_appearance(UPDATE_ICON_STATE)
	if(deployer)
		new_internal_item.lift_flag(deployer)

/obj/structure/plantable_flag/get_internal_item()
	return internal_item?.resolve()

/obj/structure/plantable_flag/clear_internal_item()
	internal_item = null

/obj/structure/plantable_flag/update_icon_state()
	var/obj/item/current_internal_item = internal_item.resolve()
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

///Dissassembles the device
/obj/structure/plantable_flag/proc/disassemble(mob/user)
	var/obj/item/current_internal_item = get_internal_item()
	if(!current_internal_item)
		return
	if(current_internal_item.item_flags & DEPLOYED_NO_PICKUP)
		balloon_alert(user, "Cannot disassemble")
		return
	SEND_SIGNAL(src, COMSIG_ITEM_UNDEPLOY, user)

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
