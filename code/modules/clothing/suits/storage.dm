/obj/item/clothing/suit/storage
	var/obj/item/storage/internal/pockets = /obj/item/storage/internal/suit
	var/flags_armor_features
	var/brightness_on = 5 //Average attachable pocket light
	var/flashlight_cooldown = 0 //Cooldown for toggling the light


/obj/item/clothing/suit/storage/Initialize()
	. = ..()
	pockets = new pockets(src)


/obj/item/clothing/suit/storage/attack_hand(mob/living/user)
	if(pockets.handle_attack_hand(user))
		return ..()


/obj/item/clothing/suit/storage/MouseDrop(obj/over_object)
	if(pockets.handle_mousedrop(usr, over_object))
		return ..(over_object)


/obj/item/clothing/suit/storage/attackby(obj/item/I, mob/user, params)
	. = ..()
	return pockets.attackby(I, user, params)


/obj/item/clothing/suit/storage/emp_act(severity)
	pockets.emp_act(severity)
	return ..()


/obj/item/clothing/suit/storage/proc/turn_off_light(mob/wearer)
	if(flags_armor_features & ARMOR_LAMP_ON)
		set_light(0)
		toggle_armor_light(wearer) //turn the light off
		return TRUE
	return FALSE


/obj/item/clothing/suit/storage/proc/toggle_armor_light(mob/user)
	flashlight_cooldown = world.time + 2 SECONDS
	if(flags_armor_features & ARMOR_LAMP_ON)
		set_light(0)
	else
		set_light(brightness_on)
	flags_armor_features ^= ARMOR_LAMP_ON
	playsound(src,'sound/items/flashlight.ogg', 15, 1)
	update_icon(user)
	update_action_button_icons()


/obj/item/storage/internal/suit
	storage_slots = 2	//two slots
	max_w_class = 2		//fit only small items
	max_storage_space = 4
