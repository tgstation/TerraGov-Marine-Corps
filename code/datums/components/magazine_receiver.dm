#define RECEIVER_REPLACE 	(1 << 0)
#define RECEIVER_PERMANENT	(1 << 1)
#define RECEIVER_INTERNAL	(1 << 2)

/datum/component/magazine_receiver

	var/obj/item/magazine // contained magazine
	var/flags_receiver

/datum/component/magazine_receiver/Initialize(flags_receiver, obj/item/starting)
	src.flags_receiver = flags_receiver

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/hit_by_obj)
	RegisterSignal(parent, COMSIG_MAGAZINE_AMMO_COUNT, .proc/examine_ammo_count)

	load_magazine(null, starting)

/datum/component/magazine_receiver/proc/hit_by_obj(datum/source, obj/item/I, mob/user, params)
	var/reload_delay
	var/gun_type
	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = I
		reload_delay = AM.reload_delay
		gun_type = AM.gun_type

	else if(istype(I, /obj/item/cell/lasgun))
		var/obj/item/cell/lasgun/LC = I
		reload_delay = LC.reload_delay
		gun_type = LC.gun_type
	else
		return

	. = COMPONENT_NO_AFTERATTACK

	if(!istype(parent, gun_type))
		to_chat(user, "<span class='warning'>That magazine doesn't fit in there!</span>")
		return
	
	if(magazine && !CHECK_BITFIELD(flags_receiver, RECEIVER_REPLACE))
		to_chat(user, "<span class='warning'>It's still got something loaded.</span>")
		return

	if(!user || reload_delay <= 1)
		load_magazine(user, I)
		return

	to_chat(user, "<span class='notice'>You begin reloading [src]. Hold still...</span>")
	if(!do_after(user,reload_delay, TRUE, src, BUSY_ICON_GENERIC))
		to_chat(user, "<span class='warning'>Your reload was interrupted!</span>")
		return

	load_magazine(user, I)

/datum/component/magazine_receiver/proc/get_ammo_count()
	if(istype(magazine, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = I
		return AM.current_rounds

	else if(istype(I, /obj/item/cell/lasgun))
		var/obj/item/cell/lasgun/LC = I
		return LC.charge

/datum/component/magazine_receiver/proc/load_magazine(mob/user, obj/item/I)
	if(user)
		user.dropItemToGround(O)
		user.visible_message("<span class='notice'>[user] loads [I] into [parent]!</span>",
		"<span class='notice'>You load [I] into [parent]!</span>", null, 3)
	I.moveToNullspace()
	magazine = I
	SEND_SIGNAL(parent, COMSIG_MAGAZINE_LOADED, user)

#define GUN_HAS_AMMO_COUNTER 	(1 << 0)
#define GUN_IS_CHAMBERED 		(1 << 1)
/datum/component/magazine_receiver/proc/examine_ammo_count(datum/source, mob/user, flags, ammo_per_shot)
	if(!magazine)
		to_chat(user, "It's unloaded[flags & GUN_IS_CHAMBERED?" but has a round chambered":""].")
		return
	var/current_shots = FLOOR(get_ammo_count()/max(ammo_per_shot, 1), 1)

	if(flags & GUN_HAS_AMMO_COUNTER)
		to_chat(user, "Ammo counter shows [current_shots + (flags & GUN_IS_CHAMBERED ? 1:0)] round\s remaining.")
		return
	
	to_chat(user, "It's loaded[flags & GUN_IS_CHAMBERED?" and has a round chambered":""].")

/*
uses a magazine
/obj/item/weapon/gun/rifle/sniper/M42A
/obj/item/weapon/gun/rifle/sniper/elite
/obj/item/weapon/gun/rifle/sniper/svd
/obj/item/weapon/gun/rifle/m4ra
* /obj/item/weapon/gun/launcher/rocket
/obj/item/weapon/gun/minigun
/obj/item/weapon/gun/smg
/obj/item/weapon/gun/rifle
/obj/item/weapon/gun/pistol
/obj/item/weapon/gun/flamer
* /obj/item/weapon/gun/energy


internal magazine
/obj/item/weapon/gun/smartgun
/obj/item/weapon/gun/shotgun/merc/scout
/obj/item/weapon/gun/shotgun
/obj/item/weapon/gun/revolver
/obj/item/weapon/gun/launcher/rocket/toy


weird special cases
/obj/item/weapon/gun/launcher/m92
/obj/item/weapon/gun/launcher/m81
/obj/item/weapon/gun/flare
/obj/item/weapon/gun/syringe

*/
