//towing moduke
//pepperball module
//motion detector module
//auto flare mod
//medical mod
//personal storage module

/obj/item/mule_module
	name = "mule module"
	desc = "Can be used to improve a mule and specialize it"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "modkit"
	var/mob/living/simple_animal/mule_bot/attached_mule
	var/mutable_appearance/mod_overlay
	var/overlay_icon = 'icons/mob/kerfus.dmi'
	var/overlay_icon_state = "backpack"
	var/y_offset = 0
	var/x_offset = 0
	var/module_desc = "this module does not do that much, you think. You'd have no way of knowing."


/obj/item/mule_module/Initialize()
	. = ..()
	mod_overlay = mutable_appearance(overlay_icon, overlay_icon_state, BACK_LAYER, FLOAT_PLANE)
	mod_overlay.pixel_y = y_offset
	mod_overlay.pixel_x = x_offset

/obj/item/mule_module/proc/apply(mob/living/simple_animal/mule_bot/mule)
	RegisterSignal(mule, COMSIG_PARENT_EXAMINE, PROC_REF(examine_parent))
	mule.installed_module = src
	attached_mule = mule
	src.forceMove(mule)
	return TRUE


/obj/item/mule_module/proc/unapply(delete_mod = TRUE)
	UnregisterSignal(attached_mule, COMSIG_PARENT_EXAMINE)
	if(!delete_mod)
		src.forceMove(attached_mule.loc)
	else
		qdel(src)
	attached_mule.installed_module = null
	attached_mule = null

/obj/item/mule_module/proc/examine_parent(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice(module_desc)

/obj/item/storage/mule_pack
	name = "internal storage"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_storage_space = 48
	max_w_class = 6
	storage_slots = null

/obj/item/mule_module/storage
	name = "Storage module"
	desc = "A module that allows the mule to carry various items"
	overlay_icon_state = "marine_rocket_full"
	overlay_icon = 'icons/mob/kerfus.dmi'
	overlay_icon_state = "backpack"

	var/obj/item/storage/mule_pack/storage_pack = /obj/item/storage/mule_pack

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


/obj/item/storage/mule_pack/small
	name = "small internal storage"
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 12
	storage_slots = null

/obj/item/mule_module/personal_storage
	name = "Personal storage module"
	desc = "A module that allows the mule to carry various items for various individuels"
	overlay_icon_state = "marine_rocket_full"
	overlay_icon = 'icons/mob/kerfus.dmi'
	overlay_icon_state = "backpack"
	module_desc = "The installed module allows you to have a personal storage inside the mule based on ID"
	var/list/obj/item/storage/mule_pack/small/packs = list()

/obj/item/mule_module/personal_storage/apply(mob/living/simple_animal/mule_bot/mule)
	RegisterSignal(mule,COMSIG_ATOM_ATTACK_HAND, PROC_REF(acces_storage))
	. = ..()

/obj/item/mule_module/personal_storage/unapply(delete_mod = TRUE)
	UnregisterSignal(attached_mule, COMSIG_ATOM_ATTACK_HAND)
	. = ..()

/obj/item/mule_module/personal_storage/proc/acces_storage(mob/mule, mob/user)
	var/card = user.get_idcard(TRUE)
	if(!card)
		to_chat(user,span_warning("You need an valid ID to store items here!"))
		return
	if(!packs[card])
		packs[card] = new /obj/item/storage/mule_pack/small(src)
	packs[card].open(user)

/obj/item/mule_module/light
	name = "Spot light module"
	desc = "This module lets the bot cast a bright light."
	var/mod_Light_power = 10
	var/mod_Light_range = 23
	var/mod_light_color = "#f0e0b6"

/obj/item/mule_module/light/apply(mob/living/simple_animal/mule_bot/mule)
	mule.set_light_range_power_color(mod_Light_power,mod_Light_range,mod_light_color)
	mule.light_on = TRUE
	. = ..()

/obj/item/mule_module/light/unapply(delete_mod)
	attached_mule.set_light_range_power_color(initial(attached_mule.light_range) ,initial(attached_mule.light_power),initial(attached_mule.light_color))
	attached_mule.light_on = FALSE
	. = ..()

/obj/item/mule_module/flare_placer
	name = "Flare placing module"
	desc = "This module places flare automaticly when its too dark."
	var/flare_type = /obj/item/explosive/grenade/flare
	COOLDOWN_DECLARE(flare_place)

/obj/item/mule_module/flare_placer/apply(mob/living/simple_animal/mule_bot/mule)
	RegisterSignal(mule, COMSIG_MOVABLE_MOVED, PROC_REF(check_lumcount))
	. = ..()


/obj/item/mule_module/flare_placer/proc/check_lumcount(atom/bot)
	SIGNAL_HANDLER
	if(!COOLDOWN_CHECK(src,flare_place))
		return
	if(!isturf(bot.loc))
		return
	var/turf/T = bot.loc
	if(T.dynamic_lumcount < 0.5 && T.luminosity < 1)
		var/obj/item/explosive/grenade/flare/F = new(T)
		F.activate(bot)
		//lum count wont update properly since lighting uses moved signals
		F.forceMove(T)
		COOLDOWN_START(src,flare_place, 0)
