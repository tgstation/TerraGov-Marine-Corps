/obj/item/mule_module
	name = "mule module"
	desc = "Can be used to improve a mule and specialize it"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "modkit"
	var/mob/living/simple_animal/mule_bot/attached_mule
	var/mutable_appearance/mod_overlay
	var/overlay_icon = 'icons/mob/mule_bot.dmi'
	var/overlay_icon_state = "test"
	var/y_offset = 0
	var/x_offset = 0


/obj/item/mule_module/Initialize()
	. = ..()
	mod_overlay = mutable_appearance(overlay_icon, overlay_icon_state, BACK_LAYER, FLOAT_PLANE)
	mod_overlay.pixel_y = y_offset
	mod_overlay.pixel_x = x_offset

/obj/item/mule_module/proc/apply(mob/living/simple_animal/mule_bot/mule)
	mule.installed_module = src
	attached_mule = mule
	src.forceMove(mule)
	mule.add_overlay(mod_overlay)
	return TRUE


/obj/item/mule_module/proc/unapply(delete_mod = TRUE)
	attached_mule.cut_overlay(mod_overlay)
	if(!delete_mod)
		src.forceMove(attached_mule.loc)
	else
		qdel(src)
	attached_mule.installed_module = null
	attached_mule = null


/obj/item/storage/mule_pack
	name = "internal storage"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_storage_space = 48
	max_w_class = 6
	storage_slots = null

/obj/item/mule_module/storage
	name = "Storage module"
	desc = "A module that allows the mule to carry various items"
	var/obj/item/storage/mule_pack/storage_pack = /obj/item/storage/mule_pack
	overlay_icon_state = "marine_rocket_full"

/obj/item/mule_module/storage/Initialize(mapload, ...)
	. = ..()
	storage_pack = new(src)

/obj/item/mule_module/storage/apply(mob/living/simple_animal/mule_bot/mule)
	RegisterSignal(mule,COMSIG_ATOM_ATTACK_HAND, PROC_REF(acces_storage))
	. = ..()

/obj/item/mule_module/storage/unapply(delete_mod = TRUE)
	UnregisterSignal(attached_mule, COMSIG_ATOM_ATTACK_HAND)
	. = ..()

/obj/item/mule_module/storage/proc/acces_storage(mob/mule, mob/user)
	SIGNAL_HANDLER
	storage_pack.open(user)


/obj/item/mule_module/light
	name = "Spot light module"
	desc = "This module lets the bot cast a bright light."
	var/mod_Light_power = 10
	var/mod_Light_range = 23
	var/mod_light_color = "#f0e0b6"

/obj/item/mule_module/light/apply(mob/living/simple_animal/mule_bot/mule)
	mule.set_light_range_power_color(mod_Light_power,mod_Light_range,mod_light_color)
	mule.set_light_on(TRUE)
	. = ..()

/obj/item/mule_module/light/unapply(delete_mod)
	attached_mule.set_light_range_power_color(initial(attached_mule.light_range) ,initial(attached_mule.light_power),initial(attached_mule.light_color))
	attached_mule.set_light_on(FALSE)
	. = ..()
