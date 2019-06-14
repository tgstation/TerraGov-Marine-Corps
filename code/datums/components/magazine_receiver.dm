#define RECEIVER_REPLACE (1 << 0)

/datum/component/magazine_receiver

	var/obj/item/magazine // contained magazine
	var/flags_receiver

/datum/component/magazine_receiver/Initialize(flags_receiver)
	src.flags_receiver = flags_receiver

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/hit_by_obj)


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

	if(!user || reload_delay =< 1)
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
		return LC

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
	if(flags & GUN_HAS_AMMO_COUNTER)


