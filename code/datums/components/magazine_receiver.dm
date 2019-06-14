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

	if(!istype(parent, gun_type))
		to_chat(user, "<span class='warning'>That magazine doesn't fit in there!</span>")
		return COMPONENT_NO_AFTERATTACK
	
	if(magazine && !CHECK_BITFIELD(flags_receiver, RECEIVER_REPLACE))
		to_chat(user, "<span class='warning'>It's still got something loaded.</span>")
		return COMPONENT_NO_AFTERATTACK

	if(!user)
		load_magazine(null, I)
		return COMPONENT_NO_AFTERATTACK

/datum/component/magazine_receiver/proc/load_magazine(mob/user, obj/item/I)
	if(user)
		user.dropItemToGround(O)
		user.visible_message("<span class='notice'>[user] loads [I] into [parent]!</span>",
		"<span class='notice'>You load [I] into [parent]!</span>", null, 3)
	I.moveToNullspace()
	magazine = I
	SEND_SIGNAL(parent, COMSIG_MAGAZINE_LOADED, user)

