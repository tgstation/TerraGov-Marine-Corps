/obj/item/mule_module
	name = "mule module"
	desc = "Can be used to improve a mule and specialize it"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "modkit"
	//the mule we are currently on
	var/mob/living/simple_animal/mule_bot/attached_mule
	//overlay that reprents the sprite when attached to the bot
	var/mutable_appearance/mod_overlay
	var/overlay_icon = 'icons/mob/kerfus.dmi'
	var/overlay_icon_state = "backpack"
	//This description appears when examining the bot that has this attached
	var/module_desc = "this module does not do that much, you think. You'd have no way of knowing."


/obj/item/mule_module/Initialize()
	. = ..()
	mod_overlay = mutable_appearance(overlay_icon, overlay_icon_state, BACK_LAYER, FLOAT_PLANE)

/**
 * Applys all the things that this module should do to the mob. register signals and such here
 */
/obj/item/mule_module/proc/apply(mob/living/simple_animal/mule_bot/mule)
	RegisterSignal(mule, COMSIG_PARENT_EXAMINE, PROC_REF(examine_parent))
	mule.installed_module = src
	attached_mule = mule
	forceMove(mule)
	return TRUE

/**
 * Cleans up everything done in apply() so that the bot is back to its basic state, overwrite this for cleanup
 */
/obj/item/mule_module/proc/unapply(delete_mod = TRUE)
	UnregisterSignal(attached_mule, COMSIG_PARENT_EXAMINE)
	if(!delete_mod)
		forceMove(attached_mule.loc)
	else
		qdel(src)
	attached_mule.installed_module = null
	attached_mule = null
/**
 * If you examine the bot when it has this installed. will show lil blib. You can add more stuff to this if for example your module has ammo count/charge
 */
/obj/item/mule_module/proc/examine_parent(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice(module_desc)

/obj/item/storage/mule_pack
	name = "internal storage"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_storage_space = 48
	max_w_class = 6
	storage_slots = null

/**
 * Storage module
 *
 * A very large backpack for the bot. can store what ever you want
 * Currently if the bot dies you can still acces the story, but it wont drop its things if it where to get shuttle gibbed
 */
/obj/item/mule_module/storage
	name = "Storage module"
	desc = "A module that allows the mule to carry various items"
	overlay_icon_state = "backpack"

	var/obj/item/storage/mule_pack/storage_pack = /obj/item/storage/mule_pack

/obj/item/mule_module/storage/Initialize(mapload, ...)
	. = ..()
	storage_pack = new(src)

/obj/item/mule_module/storage/apply(mob/living/simple_animal/mule_bot/mule)
	RegisterSignal(mule,COMSIG_ATOM_ATTACK_HAND, PROC_REF(acces_storage))
	return ..()

/obj/item/mule_module/storage/unapply(delete_mod = TRUE)
	UnregisterSignal(attached_mule, COMSIG_ATOM_ATTACK_HAND)
	return ..()

/obj/item/mule_module/storage/proc/acces_storage(mob/mule, mob/user)
	SIGNAL_HANDLER
	storage_pack.open(user)


/obj/item/storage/mule_pack/small
	name = "small internal storage"
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 12
	storage_slots = null

/**
 * Personal storage
 *
 * This module will open up a small storage thats only accasible to THAT marine
 * checking is done by ID, so you can take a dead marines ID and look inside there storage if they died and you needed something
 */

/obj/item/mule_module/personal_storage
	name = "Personal storage module"
	desc = "A module that allows the mule to carry various items for various individuels"
	overlay_icon_state = "private_storage_mod"
	module_desc = "The installed module allows you to have a personal storage inside the mule based on ID"
	var/list/obj/item/storage/mule_pack/small/packs = list()

/obj/item/mule_module/personal_storage/apply(mob/living/simple_animal/mule_bot/mule)
	RegisterSignal(mule,COMSIG_ATOM_ATTACK_HAND, PROC_REF(acces_storage))
	return ..()

/obj/item/mule_module/personal_storage/unapply(delete_mod = TRUE)
	UnregisterSignal(attached_mule, COMSIG_ATOM_ATTACK_HAND)
	return ..()

//Since every person gets there own storage bit with this module, we need to either create new storage for the person or let it acces the old one
/obj/item/mule_module/personal_storage/proc/acces_storage(mob/mule, mob/user)
	var/card = user.get_idcard(TRUE)
	if(!card)
		to_chat(user,span_warning("You need an valid ID to store items here!"))
		return
	if(!packs[card])
		packs[card] = new /obj/item/storage/mule_pack/small(src)
	packs[card].open(user)

/*
Spot light module

Bassicly baldur jeager mod for robot. gives light

*/

/obj/item/mule_module/light
	name = "Spot light module"
	desc = "This module lets the bot cast a bright light."
	overlay_icon_state = "light_mod"
	var/mod_Light_power = 10
	var/mod_Light_range = 23
	var/mod_light_color = COLOR_BEIGE

/obj/item/mule_module/light/apply(mob/living/simple_animal/mule_bot/mule)
	mule.set_light_range_power_color(mod_Light_power,mod_Light_range,mod_light_color)
	mule.set_light_on(TRUE)
	return ..()

/obj/item/mule_module/light/unapply(delete_mod)
	attached_mule.set_light_range_power_color(initial(attached_mule.light_range) ,initial(attached_mule.light_power),initial(attached_mule.light_color))
	attached_mule.set_light_on(FALSE)
	return ..()

/*
Flare placing module

Place flares on turf if we find its too dark

has cooldown of 3 seconds per flare
*/

/obj/item/mule_module/flare_placer
	name = "Flare placing module"
	desc = "This module places flare automaticly when its too dark."
	overlay_icon_state = "flare_mod"
	COOLDOWN_DECLARE(flare_place)

/obj/item/mule_module/flare_placer/apply(mob/living/simple_animal/mule_bot/mule)
	RegisterSignal(mule, COMSIG_MOVABLE_MOVED, PROC_REF(check_lumcount))
	return ..()


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
		COOLDOWN_START(src,flare_place, 3 SECONDS)
