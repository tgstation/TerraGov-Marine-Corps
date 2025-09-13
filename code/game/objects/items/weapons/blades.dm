/obj/item/tool/kitchen/knife/shiv
	name = "glass shiv"
	icon = 'icons/obj/items/weapons/knives.dmi'
	icon_state = "shiv"
	desc = "A makeshift glass shiv."
	attack_verb = list("shanks", "shivs")
	hitsound = 'sound/weapons/slash.ogg'

/obj/item/tool/kitchen/knife/shiv/plasma
	icon_state = "plasmashiv"
	desc = "A makeshift plasma glass shiv."

/obj/item/tool/kitchen/knife/shiv/titanium
	icon_state = "titaniumshiv"
	desc = "A makeshift titanium shiv."

/obj/item/tool/kitchen/knife/shiv/plastitanium
	icon_state = "plastitaniumshiv"
	desc = "A makeshift plastitanium glass shiv."

/obj/item/weapon/combat_knife
	name = "\improper M5 survival knife"
	icon_state = "combat_knife"
	worn_icon_state = "combat_knife"
	icon = 'icons/obj/items/weapons/knives.dmi'
	desc = "A standard survival knife of high quality. You can slide this knife into your boots, and can be field-modified to attach to the end of a rifle with cable coil."
	atom_flags = CONDUCT
	sharp = IS_SHARP_ITEM_ACCURATE
	force = 30
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	attack_speed = 8
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

/obj/item/weapon/combat_knife/attackby(obj/item/I, mob/user)
	if(!istype(I,/obj/item/stack/cable_coil))
		return ..()
	var/obj/item/stack/cable_coil/CC = I
	if(!CC.use(5))
		to_chat(user, span_notice("You don't have enough cable for that."))
		return
	to_chat(user, "You wrap some cable around the bayonet. It can now be attached to a gun.")
	if(loc == user)
		user.temporarilyRemoveItemFromInventory(src)
	var/obj/item/attachable/bayonet/converted/F = new(src.loc)
	user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
	if(F.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
		F.forceMove(get_turf(src))
	qdel(src) //Delete da old knife

/obj/item/weapon/combat_knife/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/scalping)

/obj/item/weapon/combat_knife/suicide_act(mob/user)
	user.visible_message(pick(span_danger("[user] is slitting [user.p_their()] wrists with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
							span_danger("[user] is slitting [user.p_their()] throat with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
							span_danger("[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.")))
	return (BRUTELOSS)

/obj/item/weapon/combat_knife/upp
	name = "\improper Type 30 survival knife"
	icon_state = "upp_knife"
	worn_icon_state = "knife"
	desc = "The standard issue survival knife of the UPP forces, the Type 30 is effective, but humble. It is small enough to be non-cumbersome, but lethal none-the-less."
	force = 20
	throwforce = 10
	throw_speed = 2
	throw_range = 8

/obj/item/weapon/combat_knife/pmc
	name = "\improper M2X HF-S self defense blade"
	icon_state = "pmc_knife"
	worn_icon_state = "pmc_knife"
	desc = "A experemental short blade, utilizing high-frequency techology. A small but dangerous weapon, which can cut through even the heaviest of armors. Many mercenaries keep it close, for desperate situations."
	penetration = 25

/obj/item/weapon/karambit
	name = "karambit"
	icon = 'icons/obj/items/weapons/knives.dmi'
	icon_state = "karambit"
	worn_icon_state = "karambit"
	desc = "A small high quality knife with a curved blade, good for slashing and hooking. This one has a mottled red finish."
	atom_flags = CONDUCT
	sharp = IS_SHARP_ITEM_ACCURATE
	force = 30
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	attack_speed = 8
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "dices", "cuts", "hooks")

/obj/item/weapon/karambit/fade
	icon_state = "karambit_fade"
	worn_icon_state = "karambit_fade"
	desc = "A small high quality knife with a curved blade, good for slashing and hooking. This one has been painted by airbrushing transparent paints that fade together over a chrome base coat."

/obj/item/weapon/karambit/case_hardened
	icon_state = "karambit_case_hardened"
	worn_icon_state = "karambit_case_hardened"
	desc = "A small high quality knife with a curved blade, good for slashing and hooking. This one has been color case-hardened through the application of wood charcoal at high temperatures."

/obj/item/stack/throwing_knife
	name ="\improper M11 throwing knife"
	icon='icons/obj/items/weapons/throwing.dmi'
	icon_state = "throwing_knife"
	desc="A military knife designed to be thrown at the enemy. Much quieter than a firearm, but requires a steady hand to be used effectively."
	stack_name = "pile"
	singular_name = "knife"
	atom_flags = CONDUCT|DIRLOCK
	sharp = IS_SHARP_ITEM_ACCURATE
	force = 20
	w_class = WEIGHT_CLASS_TINY
	throwforce = 25
	throw_speed = 5
	throw_range = 7
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	equip_slot_flags = ITEM_SLOT_POCKET
	max_amount = 5
	amount = 5
	///Delay between throwing.
	var/throw_delay = 0.2 SECONDS
	///Current Target that knives are being thrown at. This is for aiming
	var/current_target
	///The person throwing knives
	var/mob/living/living_user
	///Do we change sprite depending on the amount left?
	var/update_on_throwing = TRUE

/obj/item/stack/throwing_knife/Initialize(mapload, new_amount)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(post_throw))
	AddComponent(/datum/component/automatedfire/autofire, throw_delay, _fire_mode = GUN_FIREMODE_AUTOMATIC, _callback_reset_fire = CALLBACK(src, PROC_REF(stop_fire)), _callback_fire = CALLBACK(src, PROC_REF(throw_knife)))

/obj/item/stack/throwing_knife/update_icon_state()
	. = ..()
	if(update_on_throwing)
		icon_state = "throwing_knife_[amount]"

/obj/item/stack/throwing_knife/equipped(mob/user, slot)
	. = ..()
	if(user.get_active_held_item() != src && user.get_inactive_held_item() != src)
		return
	living_user = user
	RegisterSignal(user, COMSIG_MOB_MOUSEDRAG, PROC_REF(change_target))
	RegisterSignal(user, COMSIG_MOB_MOUSEUP, PROC_REF(stop_fire))
	RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_fire))

/obj/item/stack/throwing_knife/unequipped(mob/unequipper, slot)
	. = ..()
	living_user?.client?.mouse_pointer_icon = initial(living_user.client.mouse_pointer_icon) // Force resets the mouse pointer to default so it defaults when the last knife is thrown
	UnregisterSignal(unequipper, COMSIG_MOB_ITEM_AFTERATTACK)
	UnregisterSignal(unequipper, list(COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_MOB_MOUSEDOWN))
	living_user = null

///Changes the current target.
/obj/item/stack/throwing_knife/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	set_target(get_turf_on_clickcatcher(over_object, source, params))
	living_user.face_atom(current_target)

///Stops the Autofire component and resets the current cursor.
/obj/item/stack/throwing_knife/proc/stop_fire()
	SIGNAL_HANDLER
	living_user?.client?.mouse_pointer_icon = initial(living_user.client.mouse_pointer_icon)
	set_target(null)
	SEND_SIGNAL(src, COMSIG_GUN_STOP_FIRE)

///Starts the user firing.
/obj/item/stack/throwing_knife/proc/start_fire(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	if(living_user.get_active_held_item() != src) // If the object in our active hand is not a throwing knife, abort
		return
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] || modifiers["ctrl"])
		return
	set_target(get_turf_on_clickcatcher(object, living_user, params))
	if(!current_target)
		return
	SEND_SIGNAL(src, COMSIG_GUN_FIRE)
	living_user?.client?.mouse_pointer_icon = 'icons/UI_Icons/gun_crosshairs/rifle.dmi'

///Throws a knife from the stack, or, if the stack is one, throws the stack.
/obj/item/stack/throwing_knife/proc/throw_knife()
	SIGNAL_HANDLER
	if(living_user?.get_active_held_item() != src)
		return
	if(living_user.Adjacent(current_target))
		return AUTOFIRE_CONTINUE
	var/thrown_thing = src
	if(amount == 1)
		living_user.temporarilyRemoveItemFromInventory(src)
		forceMove(get_turf(src))
		throw_at(current_target, throw_range, throw_speed, living_user, TRUE)
		current_target = null
	else
		var/obj/item/stack/throwing_knife/knife_to_throw = new type(get_turf(src))
		knife_to_throw.amount = 1
		knife_to_throw.update_icon()
		knife_to_throw.throw_at(current_target, throw_range, throw_speed, living_user, TRUE)
		amount--
		thrown_thing = knife_to_throw
	playsound(src, 'sound/effects/throw.ogg', 30, 1)
	visible_message(span_warning("[living_user] expertly throws [thrown_thing]."), null, null, 5)
	update_icon()
	return AUTOFIRE_CONTINUE

///Fills any stacks currently in the tile that this object is thrown to.
/obj/item/stack/throwing_knife/proc/post_throw()
	SIGNAL_HANDLER
	if(amount >= max_amount)
		return
	for(var/item_in_loc in loc.contents)
		if(!istype(item_in_loc, /obj/item/stack/throwing_knife) || item_in_loc == src)
			continue
		var/obj/item/stack/throwing_knife/knife = item_in_loc
		if(!merge(knife))
			continue
		break

///Sets the current target and registers for qdel to prevent hardels
/obj/item/stack/throwing_knife/proc/set_target(atom/object)
	if(object == current_target || object == living_user)
		return
	if(current_target)
		UnregisterSignal(current_target, COMSIG_QDELETING)
	current_target = object
