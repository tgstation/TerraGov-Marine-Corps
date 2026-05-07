
///Sheets required to add an upgrade to a barricade
#define CADE_UPGRADE_REQUIRED_SHEETS 1

//cade armor defines
#define CADE_UPGRADE_BOMB 80
#define CADE_UPGRADE_MELEE list(melee = 30, bullet = 50, laser = 50, energy = 50)
#define CADE_UPGRADE_ACID 35

/obj/structure/barricade/solid
	name = "metal barricade"
	desc = "A sturdy and easily assembled barricade made of metal plates, often used for quick fortifications. Use a blowtorch to repair."
	icon = 'icons/obj/structures/barricades/metal.dmi'
	icon_state = "metal_0"
	max_integrity = 250
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 40)
	coverage = 128
	stack_type = /obj/item/stack/sheet/metal
	stack_amount = BUILD_COST_METAL_CADE
	destroyed_stack_amount = 2
	hit_sound = "sound/effects/metalhit.ogg"
	base_icon_state = "metal"
	barricade_flags = parent_type::barricade_flags|BARRICADE_CAN_WIRE|BARRICADE_CAN_MOVE|BARRICADE_STANDARD_REPAIR
	///The type of upgrade and corresponding overlay we have attached
	var/barricade_upgrade_type

/obj/structure/barricade/solid/Initialize(mapload, mob/user)
	. = ..()
	if(!user || !HAS_TRAIT(user, TRAIT_SUPERIOR_BUILDER))
		return
	modify_max_integrity(max_integrity + 75)

/obj/structure/barricade/solid/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -40, 8, 1)

/obj/structure/barricade/solid/update_overlays()
	. = ..()
	if(!barricade_upgrade_type)
		return
	var/damage_state
	var/percentage = (obj_integrity / max_integrity) * 100
	switch(percentage)
		if(-INFINITY to 25)
			damage_state = 3
		if(25 to 50)
			damage_state = 2
		if(50 to 75)
			damage_state = 1
		if(75 to INFINITY)
			damage_state = 0
	switch(barricade_upgrade_type)
		if(CADE_TYPE_BOMB)
			. += image('icons/obj/structures/barricades/upgrades.dmi', icon_state = "[base_icon_state]+explosive_upgrade_[damage_state]")
		if(CADE_TYPE_MELEE)
			. += image('icons/obj/structures/barricades/upgrades.dmi', icon_state = "[base_icon_state]+brute_upgrade_[damage_state]")
		if(CADE_TYPE_ACID)
			. += image('icons/obj/structures/barricades/upgrades.dmi', icon_state = "[base_icon_state]+burn_upgrade_[damage_state]")

/obj/structure/barricade/solid/return_stack(disassembled = TRUE)
	var/stack_amt = destroyed_stack_amount
	if(disassembled)
		stack_amt = round(stack_amount * (obj_integrity/max_integrity))
	if(!stack_amt)
		return
	//upgrades are always metal, so for non metal cades we need to split them out
	if(barricade_upgrade_type)
		if(stack_type == /obj/item/stack/sheet/metal)
			stack_amt += CADE_UPGRADE_REQUIRED_SHEETS
		else
			new /obj/item/stack/sheet/metal(loc, CADE_UPGRADE_REQUIRED_SHEETS)

	new stack_type(loc, stack_amt)

/obj/structure/barricade/solid/examine(mob/user)
	. = ..()
	. += span_info("It is [barricade_upgrade_type ? "upgraded with [barricade_upgrade_type]" : "not upgraded"].")

/obj/structure/barricade/solid/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(build_state != BARRICADE_FIRM)
		return FALSE
	if(!barricade_upgrade_type)
		balloon_alert(user, "no upgrades to remove!")
		return FALSE

	if(user.skills.getRating(SKILL_CONSTRUCTION) < skill_level)
		var/fumbling_time = 5 SECONDS * ( skill_level - user.skills.getRating(SKILL_CONSTRUCTION))
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE

	balloon_alert_to_viewers("removing armor plates...")

	playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
	if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return FALSE

	balloon_alert_to_viewers("removed armor plates")
	playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

	switch(barricade_upgrade_type)
		if(CADE_TYPE_BOMB)
			soft_armor = soft_armor.modifyRating(BOMB = -CADE_UPGRADE_BOMB)
		if(CADE_TYPE_MELEE)
			soft_armor = soft_armor.modifyRating(MELEE = -CADE_UPGRADE_MELEE["melee"], BULLET = -CADE_UPGRADE_MELEE["bullet"], LASER = -CADE_UPGRADE_MELEE["laser"], ENERGY = -CADE_UPGRADE_MELEE["energy"])
		if(CADE_TYPE_ACID)
			soft_armor = soft_armor.modifyRating(ACID = -CADE_UPGRADE_ACID)
			resistance_flags &= ~UNACIDABLE

	new /obj/item/stack/sheet/metal(loc, CADE_UPGRADE_REQUIRED_SHEETS)
	barricade_upgrade_type = null
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/barricade/solid/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(rand(400, 600), BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(rand(150, 350), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 100), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(25, 50), BRUTE, BOMB)

/obj/structure/barricade/solid/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(I, /obj/item/stack/sheet/metal)) //we can't use apply_stack for non-metal cades since its not our stack type
		return attempt_barricade_upgrade(I, user)

///Tries to add an upgrade to the cade
/obj/structure/barricade/solid/proc/attempt_barricade_upgrade(obj/item/stack/sheet/metal/metal_sheets, mob/user)
	if(barricade_upgrade_type)
		balloon_alert(user, "already upgraded!")
		return FALSE
	if(obj_integrity < max_integrity)
		balloon_alert(user, "not at full health!")
		return FALSE

	if(metal_sheets.get_amount() < CADE_UPGRADE_REQUIRED_SHEETS)
		balloon_alert(user, "[CADE_UPGRADE_REQUIRED_SHEETS] metal sheets required!")
		return FALSE

	var/static/list/cade_types = list(CADE_TYPE_BOMB = image(icon = 'icons/obj/structures/barricades/upgrades.dmi', icon_state = "explosive_obj"), CADE_TYPE_MELEE = image(icon = 'icons/obj/structures/barricades/upgrades.dmi', icon_state = "brute_obj"), CADE_TYPE_ACID = image(icon = 'icons/obj/structures/barricades/upgrades.dmi', icon_state = "burn_obj"))
	var/choice = show_radial_menu(user, src, cade_types, require_near = TRUE, tooltips = TRUE)

	if(!choice)
		return FALSE

	if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_METAL)
		balloon_alert(user, "fumbling...")
		var/fumbling_time = 2 SECONDS * ( SKILL_CONSTRUCTION_METAL - user.skills.getRating(SKILL_CONSTRUCTION) )
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE

	balloon_alert_to_viewers("attaching [choice]...")
	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return FALSE
	if(QDELETED(src))
		return TRUE
	if(barricade_upgrade_type)
		balloon_alert(user, "already upgraded!")
		return FALSE

	if(!metal_sheets.use(CADE_UPGRADE_REQUIRED_SHEETS))
		return FALSE

	switch(choice)
		if(CADE_TYPE_BOMB)
			soft_armor = soft_armor.modifyRating(BOMB = CADE_UPGRADE_BOMB)
		if(CADE_TYPE_MELEE)
			soft_armor = soft_armor.modifyRating(MELEE = CADE_UPGRADE_MELEE["melee"], BULLET = CADE_UPGRADE_MELEE["bullet"], LASER = CADE_UPGRADE_MELEE["laser"], ENERGY = CADE_UPGRADE_MELEE["energy"])
		if(CADE_TYPE_ACID)
			soft_armor = soft_armor.modifyRating(ACID = CADE_UPGRADE_ACID)
			resistance_flags |= UNACIDABLE

	barricade_upgrade_type = choice
	balloon_alert_to_viewers("[choice] attached")

	playsound(loc, 'sound/items/screwdriver.ogg', 25, TRUE)
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/barricade/solid/capsule
	name = "capsule-deployed metal barricade"
	desc = parent_type::desc + " Deconstruction will yield less materials due to being deployed via capsule."
	stack_amount = 3

/obj/structure/barricade/solid/plasteel
	name = "plasteel barricade"
	desc = "A sturdy and easily assembled barricade made of reinforced plasteel plates, the pinnacle of strongpoints. Use a blowtorch to repair."
	icon = 'icons/obj/structures/barricades/plasteel.dmi'
	icon_state = "plasteel_0"
	max_integrity = 400
	stack_type = /obj/item/stack/sheet/plasteel
	stack_amount = BUILD_COST_PLASTEEL_CADE
	destroyed_stack_amount = 1
	base_icon_state = "plasteel"
	skill_level = SKILL_ENGINEER_PLASTEEL
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 50)

#undef CADE_UPGRADE_REQUIRED_SHEETS
#undef CADE_UPGRADE_BOMB
#undef CADE_UPGRADE_MELEE
#undef CADE_UPGRADE_ACID
