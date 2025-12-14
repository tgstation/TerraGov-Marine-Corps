/obj/item/weapon/twohanded/spear
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	icon_state = "spearglass"
	worn_icon_state = "spearglass"
	force = 40
	equip_slot_flags = ITEM_SLOT_BACK
	force_activated = 75
	throwforce = 75
	throw_speed = 3
	reach = 2
	edge = 1
	sharp = IS_SHARP_ITEM_SIMPLE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "stabs", "jabs", "tears", "gores")
	///Based on what direction the tip of the spear is pointed at in the sprite; maybe someone makes a spear that points northwest
	var/current_angle = 45

/obj/item/weapon/twohanded/spear/throw_at(atom/target, range, speed, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	spin = FALSE
	//Find the angle the spear is to be thrown at, then rotate it based on that angle
	var/rotation_value = Get_Angle(thrower, get_turf(target)) - current_angle
	current_angle += rotation_value
	var/matrix/rotate_me = matrix()
	rotate_me.Turn(rotation_value)
	transform = rotate_me
	return ..()

/obj/item/weapon/twohanded/spear/pickup(mob/user)
	. = ..()
	if(initial(current_angle) == current_angle)
		return
	//Reset the angle of the spear when picked up off the ground so it doesn't stay lopsided
	var/matrix/rotate_me = matrix()
	rotate_me.Turn(initial(current_angle) - current_angle)
	//Rotate the object in the opposite direction because for some unfathomable reason, the above Turn() is applied twice; it just works
	rotate_me.Turn(-(initial(current_angle) - current_angle))
	transform = rotate_me
	current_angle = initial(current_angle)	//Reset the angle

/obj/item/weapon/twohanded/spear/tactical
	name = "M-23 spear"
	desc = "A tactical spear. Used for 'tactical' combat."
	icon_state = "spear"
	worn_icon_state = "spear"

/obj/item/weapon/twohanded/spear/tactical/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/strappable)

/obj/item/weapon/twohanded/spear/tactical/tacticool
	name = "M-23 TACTICOOL spear"
	icon = 'icons/obj/items/weapons/64x64.dmi'
	desc = "A TACTICOOL spear. Used for TACTICOOLNESS in combat."

/obj/item/weapon/twohanded/spear/tactical/tacticool/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/attachment_handler, \
	list(ATTACHMENT_SLOT_RAIL, ATTACHMENT_SLOT_UNDER, ATTACHMENT_SLOT_MUZZLE), \
	list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet/converted,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/angledgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	), \
	attachment_offsets = list("muzzle_x" = 59, "muzzle_y" = 16, "rail_x" = 26, "rail_y" = 18, "under_x" = 40, "under_y" = 12))
