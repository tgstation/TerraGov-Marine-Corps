/obj/item/attachable/suppressor
	name = "suppressor"
	desc = "A small tube with exhaust ports to expel noise and gas.\nDoes not completely silence a weapon, but does make it much quieter and a little more accurate and stable at the cost of bullet speed."
	icon_state = "suppressor"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	slot = ATTACHMENT_SLOT_MUZZLE
	silence_mod = TRUE
	pixel_shift_y = 16
	attach_shell_speed_mod = -1
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -2
	recoil_unwielded_mod = -3
	scatter_unwielded_mod = -2
	damage_falloff_mod = 0.1

/obj/item/attachable/suppressor/unremovable
	attach_features_flags = NONE

/obj/item/attachable/suppressor/unremovable/invisible
	icon_state = ""

/obj/item/attachable/suppressor/unremovable/invisible/Initialize(mapload, ...)
	. = ..()

/obj/item/attachable/bayonet
	name = "\improper M-22 bayonet"
	desc = "A sharp knife that is the standard issue combat knife of the TerraGov Marine Corps can be attached to a variety of weapons at will or used as a standard knife."
	icon_state = "bayonetknife"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/melee_right.dmi',
	)
	force = 25
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	attack_speed = 8
	sharp = IS_SHARP_ITEM_ACCURATE
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

	attach_delay = 1 SECONDS
	detach_delay = 1 SECONDS
	slot = ATTACHMENT_SLOT_MUZZLE
	pixel_shift_x = 14
	pixel_shift_y = 18
	melee_mod = 25
	accuracy_mod = -0.05
	accuracy_unwielded_mod = -0.1
	size_mod = 1
	variants_by_parent_type = list(/obj/item/weapon/gun/shotgun/pump/t35 = "bayonetknife_t35")

/obj/item/attachable/bayonet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/scalping)

/obj/item/attachable/bayonet/som
	name = "\improper S20 SOM bayonet"
	desc = "A large knife that is the standard issue combat knife of the SOM. Can be attached to a variety of weapons at will or used as a standard knife."
	icon_state = "bayonetknife_som"
	worn_icon_state = "bayonetknife"
	force = 30

/obj/item/attachable/bayonet/converted
	name = "bayonet"
	desc = "A sharp blade for mounting on a weapon. It can be used to stab manually on anything but harm intent. Slightly reduces the accuracy of the gun when mounted."
	icon_state = "bayonet"
	force = 20
	throwforce = 10
	pixel_shift_x = 14
	pixel_shift_y = 18

/obj/item/attachable/bayonet/converted/screwdriver_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("You modify the bayonet back into a combat knife."))
	if(loc == user)
		user.dropItemToGround(src)
	var/obj/item/weapon/combat_knife/knife = new(loc)
	user.put_in_hands(knife) //This proc tries right, left, then drops it all-in-one.
	if(knife.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
		knife.forceMove(loc)
	qdel(src)

/obj/item/attachable/extended_barrel
	name = "extended barrel"
	desc = "A lengthened barrel allows for lessened scatter, greater accuracy and muzzle velocity due to increased stabilization and shockwave exposure."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "ebarrel"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	attach_shell_speed_mod = 1
	accuracy_mod = 0.15
	accuracy_unwielded_mod = 0.1
	scatter_mod = -1
	size_mod = 1
	variants_by_parent_type = list(
		/obj/item/weapon/gun/rifle/som = "ebarrel_big",
		/obj/item/weapon/gun/rifle/som_big = "ebarrel_big",
		/obj/item/weapon/gun/smg/som = "ebarrel_big",
		/obj/item/weapon/gun/shotgun/pump/t35 = "ebarrel_big",
	)

/obj/item/attachable/heavy_barrel
	name = "barrel charger"
	desc = "A fitted barrel extender that goes on the muzzle, with a small shaped charge that propels a bullet much faster.\nGreatly increases projectile speed and reduces damage falloff."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "hbarrel"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	attach_shell_speed_mod = 2
	accuracy_mod = -0.05
	damage_falloff_mod = -0.2

/obj/item/attachable/compensator
	name = "recoil compensator"
	desc = "A muzzle attachment that reduces recoil and scatter by diverting expelled gasses upwards. \nSignificantly reduces recoil and scatter, regardless of if the weapon is wielded."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "comp"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	pixel_shift_x = 17
	scatter_mod = -3
	recoil_mod = -2
	scatter_unwielded_mod = -3
	recoil_unwielded_mod = -2
	variants_by_parent_type = list(
		/obj/item/weapon/gun/rifle/som = "comp_big",
		/obj/item/weapon/gun/rifle/som_big = "comp_big",
		/obj/item/weapon/gun/smg/som = "comp_big",
		/obj/item/weapon/gun/shotgun/som = "comp_big",
		/obj/item/weapon/gun/shotgun/pump/t35 = "comp_big",
		/obj/item/weapon/gun/revolver/standard_magnum = "t76comp"
	)

/obj/item/attachable/sniperbarrel
	name = "sniper barrel"
	icon_state = "sniperbarrel" // missing icon?
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	attach_features_flags = NONE
	accuracy_mod = 0.15
	scatter_mod = -3

/obj/item/attachable/smartbarrel
	name = "smartgun barrel"
	icon_state = "smartbarrel"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	desc = "A heavy rotating barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	attach_features_flags = NONE

/obj/item/attachable/focuslens
	name = "M43 focused lens"
	desc = "Directs the beam into one specialized lens, allowing the lasgun to use the deadly focused bolts on overcharge, making it more like a high damage sniper."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "focus"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	pixel_shift_x = 17
	pixel_shift_y = 13
	ammo_mod = /datum/ammo/energy/lasgun/M43/overcharge
	damage_mod = -0.15

/obj/item/attachable/widelens
	name = "M43 wide lens"
	desc = "Splits the lens into three, allowing the lasgun to use a deadly close-range blast on overcharge akin to a traditional pellet based shotgun shot."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "wide"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	pixel_shift_x = 18
	pixel_shift_y = 15
	ammo_mod = /datum/ammo/energy/lasgun/M43/blast
	damage_mod = -0.15

/obj/item/attachable/heatlens
	name = "M43 heat lens"
	desc = "Changes the intensity and frequency of the laser. This makes your target be set on fire at a cost of upfront damage and penetration."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "heat"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	pixel_shift_x = 18
	pixel_shift_y = 16
	ammo_mod = /datum/ammo/energy/lasgun/M43/heat
	damage_mod = -0.15

/obj/item/attachable/efflens
	name = "M43 efficient lens"
	desc = "Makes the lens smaller and lighter to use, allowing the lasgun to use its energy much more efficiently. \nDecreases energy output of the lasgun."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "efficient"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	pixel_shift_x = 18
	pixel_shift_y = 14
	charge_mod = -5

/obj/item/attachable/sx16barrel
	name = "SX-16 barrel"
	desc = "The standard barrel on the SX-16. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "sx16barrel" // missing icon?
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	attach_features_flags = NONE

/obj/item/attachable/pulselens
	name = "M43 pulse lens"
	desc = "Agitates the lens, allowing the lasgun to discharge at a rapid rate. \nAllows the weapon to be fired automatically."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "pulse"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	pixel_shift_x = 18
	pixel_shift_y = 15
	damage_mod = -0.15
	gun_firemode_list_mod = list(GUN_FIREMODE_AUTOMATIC)

/obj/item/attachable/sgbarrel
	name = "SG-29 barrel"
	icon_state = "sg29barrel"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	attach_features_flags = NONE

/obj/item/attachable/lace
	name = "pistol lace"
	desc = "A simple lace to wrap around your wrist."
	icon_state = "lace"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	slot = ATTACHMENT_SLOT_MUZZLE //so you cannot have this and RC at once aka balance
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle

/obj/item/attachable/lace/activate(mob/living/user, turn_off)
	if(lace_deployed)
		REMOVE_TRAIT(master_gun, TRAIT_NODROP, PISTOL_LACE_TRAIT)
		to_chat(user, span_notice("You feel the [src] loosen around your wrist!"))
		playsound(user, 'sound/weapons/fistunclamp.ogg', 25, 1, 7)
		icon_state = "lace"
	else if(turn_off)
		return
	else
		if(user.do_actions)
			return
		to_chat(user, span_notice("You deploy the [src]."))
		ADD_TRAIT(master_gun, TRAIT_NODROP, PISTOL_LACE_TRAIT)
		to_chat(user, span_warning("You feel the [src] shut around your wrist!"))
		playsound(user, 'sound/weapons/fistclamp.ogg', 25, 1, 7)
		icon_state = "lace-on"

	lace_deployed = !lace_deployed

	update_icon()
	return TRUE

/obj/item/attachable/at45barrel
	name = "\improper CC/AT45 barrel"
	icon_state = "at45barrel"
	icon = 'icons/obj/items/guns/attachments/muzzle.dmi'
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	attach_features_flags = NONE
