/obj/structure/barricade/solid/deployable
	icon = 'icons/obj/structures/barricades/folding.dmi'
	icon_state = "folding_0"
	max_integrity = 325
	coverage = 100
	base_icon_state = "folding"
	soft_armor = list(MELEE = 35, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 25, BIO = 100, FIRE = 100, ACID = 30)
	barricade_flags = BARRICADE_DAMAGE_STATES|BARRICADE_CAN_WIRE|BARRICADE_STANDARD_REPAIR
	///What it deploys into. typecast version of internal_item
	var/obj/item/weapon/shield/riot/marine/deployable/internal_shield

/obj/structure/barricade/solid/deployable/Initialize(mapload, _internal_item, deployer)
	. = ..()
	if(!_internal_item && !internal_shield)
		return INITIALIZE_HINT_QDEL

	internal_shield = _internal_item

	name = internal_shield.name
	desc = internal_shield.desc
	//if the shield is wired, it deploys wired
	if(internal_shield.is_wired)
		DISABLE_BITFIELD(barricade_flags, BARRICADE_CAN_WIRE)
		barricade_flags |= BARRICADE_IS_WIRED
		remove_component(/datum/component/climbable)

/obj/structure/barricade/solid/deployable/get_internal_item()
	return internal_shield

/obj/structure/barricade/solid/deployable/clear_internal_item()
	internal_shield = null

/obj/structure/barricade/solid/deployable/Destroy()
	if(internal_shield)
		QDEL_NULL(internal_shield)
	return ..()

/obj/structure/barricade/solid/deployable/MouseDrop(over_object, src_location, over_location)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(over_object != user || !in_range(src, user) || user.incapacitated() || user.lying_angle)
		return
	disassemble(user)

/obj/structure/barricade/solid/deployable/wire()
	. = ..()
	//makes the shield item wired as well
	internal_shield.is_wired = TRUE
	internal_shield.modify_max_integrity(max_integrity + 50)

/obj/structure/barricade/solid/deployable/attempt_barricade_upgrade()
	return //not upgradable
