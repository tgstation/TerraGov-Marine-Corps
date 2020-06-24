#define LIMBHEALTH_TORSO 150
#define LIMBHEALTH_ARM 60
#define LIMBHEALTH_LEG 90
#define LIMBHEALTH_HEAD 90

#define TORSO_LEAKRATE 40
#define LEG_LEAKRATE 20
#define ARM_LEAKRATE 10
#define HEAD_LEAKRATE 50

#define LEAKRATE_BASE ONE_ATMOSPHERE


/obj/item/clothing/head/helmet/space/soviet
	name = "soviet space helmet"
	desc = "Through this, red flags just look like flags!"
	icon_state = "soviet_space_helmet"
	sprite_sheet_id = 1

/obj/item/clothing/head/helmet/space/soviet/Initialize()
	..()
	add_limbhealth_components(src, TRUE)

/obj/item/clothing/suit/space/soviet
	name = "soviet space suit"
	desc = "The red shall be ours!"
	icon_state = "soviet_space_suit"
	sprite_sheet_id = 1

/obj/item/clothing/suit/space/soviet/Initialize()
	..()
	add_limbhealth_components(src, TRUE)

/proc/add_limbhealth_components(var/obj/item/I, var/venting = FALSE)
	var/coveragebits = I.flags_armor_protection

	if(CHECK_BITFIELD(coveragebits, HEAD))
		I.AddComponent(/datum/component/armor_protection_limb, HEAD, LIMBHEALTH_HEAD, LIMBHEALTH_HEAD, HEAD_LEAKRATE)
	if(CHECK_BITFIELD(coveragebits, CHEST) || CHECK_BITFIELD(coveragebits, GROIN))
		I.AddComponent(/datum/component/armor_protection_limb, CHEST|GROIN, LIMBHEALTH_TORSO, LIMBHEALTH_TORSO, TORSO_LEAKRATE)
	if(CHECK_BITFIELD(coveragebits, LEG_LEFT))
		I.AddComponent(/datum/component/armor_protection_limb, LEG_LEFT, LIMBHEALTH_LEG, LIMBHEALTH_LEG, LEG_LEAKRATE)
	if(CHECK_BITFIELD(coveragebits, LEG_RIGHT))
		I.AddComponent(/datum/component/armor_protection_limb, LEG_RIGHT, LIMBHEALTH_LEG, LIMBHEALTH_LEG, LEG_LEAKRATE)
	if(CHECK_BITFIELD(coveragebits, ARM_LEFT))
		I.AddComponent(/datum/component/armor_protection_limb, ARM_LEFT, LIMBHEALTH_ARM, LIMBHEALTH_ARM, ARM_LEAKRATE)
	if(CHECK_BITFIELD(coveragebits, ARM_RIGHT))
		I.AddComponent(/datum/component/armor_protection_limb, ARM_LEFT, LIMBHEALTH_ARM, LIMBHEALTH_ARM, ARM_LEAKRATE)


/datum/component/armor_protection_limb
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/covered_limbs //Uses a bodyzone define, BODY_ZONE_R_ARM for example
	var/health //How much health the coverage has
	var/max_health //Its max health, to heal up to
	var/venting = 0
	var/vent_amount
	var/has_overlay = 0

/datum/component/armor_protection_limb/Initialize(var/_covered_limb, var/_starting_health, var/_max_health, var/_vent_amount)
	.=..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	covered_limbs = _covered_limb
	max_health = _max_health
	health = min(max_health, _starting_health)
	if(_vent_amount)
		ENABLE_BITFIELD(venting, TRUE)
		vent_amount = _vent_amount
	if(CHECK_BITFIELD(covered_limbs, HEAD) && (CHECK_BITFIELD(venting, TRUE)))
		has_overlay = 1

/datum/component/armor_protection_limb/RegisterWithParent()
	.=..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, .proc/on_unequip)

/datum/component/armor_protection_limb/proc/on_equip(obj/item/I, mob/equipper)
	RegisterSignal(equipper, COMSIG_ATOM_BULLET_ACT, .proc/on_projectile)
	if(has_overlay)
		update_overlay()

/datum/component/armor_protection_limb/proc/on_unequip(obj/item/I, mob/unequipper, slot)
	if(isitem(parent))
		if(!(I.flags_equip_slot & slotdefine2slotbit(slot)))
			return
		if(has_overlay)
			usr.clear_fullscreen("helmet")
	UnregisterSignal(unequipper, COMSIG_ATOM_BULLET_ACT)

/datum/component/armor_protection_limb/proc/on_projectile(obj/item/I, var/obj/projectile/proj)
	if(covered_limbs & GLOB.string_part_flags[proj.def_zone])
		return adjust_health(max(0, proj.damage - round(proj.distance_travelled * proj.damage_falloff)))
	return FALSE

/datum/component/armor_protection_limb/proc/update_overlay(mob/user)
	switch(health)
		if(91 to INFINITY)
			return
		if(61 to 90)
			usr.overlay_fullscreen("helmet", /obj/screen/fullscreen/helmet, 1)
		if(31 to 60)
			usr.overlay_fullscreen("helmet", /obj/screen/fullscreen/helmet, 2)
		if(6 to 30)
			usr.overlay_fullscreen("helmet", /obj/screen/fullscreen/helmet, 3)
		if(-INFINITY to 5)
			usr.overlay_fullscreen("helmet", /obj/screen/fullscreen/helmet, 4)


#define VENTING (1<<1)

/datum/component/armor_protection_limb/proc/adjust_health(var/amount)
	health = CLAMP(health - amount, 0, max_health)
	if(has_overlay)
		update_overlay()
	if(health <= 0)
		if(CHECK_BITFIELD(venting, TRUE) && !CHECK_BITFIELD(venting, VENTING))
			ENABLE_BITFIELD(venting, VENTING)
			START_PROCESSING(SSprocessing, src)
		return FALSE
	return TRUE

/datum/component/armor_protection_limb/process()
	var/mob/living/carbon/L
	if(!isitem(parent))
		return
	var/obj/item/I = parent
	if(!iscarbon(I.loc))
		return
	L = I.loc
	if(L.internal)
		L.internal.pressure = max(L.internal.pressure - (LEAKRATE_BASE/100*vent_amount), 0)

#undef VENTING