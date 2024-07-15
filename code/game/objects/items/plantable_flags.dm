/obj/item/flag_base
	name = "basic flag"
	desc = "It's a one time use flag built into a telescoping pole ripe for planting."
	icon = 'icons/obj/items/flags/plantable_flag.dmi'
	icon_state = "flag_collapsed"
	force = 3
	throwforce = 2
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	var/is_collapsed = TRUE
	var/country_name = "TGMC" //presume it is prefaced with 'the'

/obj/item/flag_base/examine(mob/user)
	. = ..()
	. += "It has a flag made for the [country_name] inside it."


/obj/item/flag_base/attack_self(mob/user)
	to_chat(user, "<span class='warning'>You start to deploy the flag between your feet...")
	if(!do_after(usr, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
		to_chat(user, "<span class='warning'>You decide against deploying the flag here.")
		return

	playsound(loc, 'sound/effects/thud.ogg', 100)
	user.dropItemToGround(src)
	is_collapsed = FALSE
	update_appearance()


/obj/item/flag_base/attack_hand(mob/living/user)
	if(!is_collapsed)
		if(!do_after(usr, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
			to_chat(user, "<span class='warning'>You decide against removing the flag here.")
			return
		is_collapsed = TRUE
		update_appearance()
	return ..()


/obj/item/flag_base/update_icon_state()
	. = ..()
	if(!is_collapsed)
		layer = ABOVE_OBJ_LAYER
		icon_state = "flag_[country_name]"
	else
		layer = OBJ_LAYER
		icon_state = "flag_collapsed"

/obj/item/flag_base/tgmc_flag
	name = "Flag of TGMC"
	country_name = "TGMC"

/obj/item/flag_base/upp_flag
	name = "Flag of UPP"
	country_name = "UPP"

/obj/item/flag_base/xeno_flag
	name = "Flag of Xenomorphs"
	country_name = "Xenomorph"

#define LOST_FLAG_AURA_STRENGTH -2
/obj/item/plantable_flag
	name = "\improper TerraGov flag"
	desc = "A flag bearing the symbol of TerraGov. It flutters in the breeze heroically. This one looks ready to be planted into the ground."
	icon = 'icons/obj/items/flags/plantable_flag_large.dmi'
	icon_state = "flag_tgmc"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/large_flag_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/large_flag_right.dmi',
	)
	w_class = WEIGHT_CLASS_HUGE
	force = 25
	throw_speed = 1
	throw_range = 2
	///The item this deploys into
	var/deployable_item = /obj/structure/plantable_flag
	///The faction this belongs to
	var/faction = FACTION_TERRAGOV
	///Aura emitter
	var/datum/aura_bearer/current_aura
	///Range of the aura
	var/aura_radius = 10
	///Strength of the aura
	var/aura_strength = 3

/obj/item/plantable_flag/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, 2 SECONDS, 2 SECONDS)
	current_aura = SSaura.add_emitter(src, AURA_HUMAN_FLAG, aura_radius, aura_strength, -1, faction)
	update_aura()

/obj/item/plantable_flag/Moved()
	. = ..()
	update_aura()

/obj/item/plantable_flag/proc/update_aura()
	if(isturf(loc))
		current_aura.strength = LOST_FLAG_AURA_STRENGTH
		return
	if(isliving(loc))
		var/mob/living/living_holder = loc
		if(living_holder.faction == faction)
			current_aura.strength = aura_strength
		else
			current_aura.strength = LOST_FLAG_AURA_STRENGTH

/obj/item/plantable_flag/som
	name = "\improper SOM flag"
	desc = "A flag bearing the symbol of the Sons of Mars. It flutters in the breeze heroically. This one looks ready to be planted into the ground."
	icon_state = "flag_som"
	faction = FACTION_SOM

/obj/structure/plantable_flag
	name = "flag"
	desc = "A flag of something. This one looks like you could dismantle it."
	icon = 'icons/obj/items/flags/plantable_flag_large.dmi'
	pixel_x = 9
	pixel_y = 12
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 800
	resistance_flags = RESIST_ALL //maybe placeholder
	///Weakref to item that is deployed to create src
	var/datum/weakref/internal_item

/obj/structure/plantable_flag/Initialize(mapload, _internal_item, mob/deployer)
	. = ..()
	if(!internal_item && !_internal_item)
		return INITIALIZE_HINT_QDEL

	internal_item = WEAKREF(_internal_item)

	var/obj/item/new_internal_item = internal_item.resolve()

	name = new_internal_item.name
	desc = new_internal_item.desc
	icon = new_internal_item.icon
	soft_armor = new_internal_item.soft_armor
	hard_armor = new_internal_item.hard_armor
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/plantable_flag/get_internal_item()
	return internal_item?.resolve()

/obj/structure/plantable_flag/clear_internal_item()
	internal_item = null

/obj/structure/plantable_flag/update_icon_state()
	var/obj/item/current_internal_item = internal_item.resolve()
	icon_state = "[current_internal_item.icon_state]_planted"

///Dissassembles the device
/obj/structure/plantable_flag/proc/disassemble(mob/user)
	var/obj/item/current_internal_item = get_internal_item()
	if(!current_internal_item)
		return
	if(current_internal_item.item_flags & DEPLOYED_NO_PICKUP)
		balloon_alert(user, "Cannot disassemble")
		return
	SEND_SIGNAL(src, COMSIG_ITEM_UNDEPLOY, user)

/obj/structure/plantable_flag/MouseDrop(over_object, src_location, over_location)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(over_object != user || !in_range(src, user))
		return
	var/obj/item/current_internal_item = get_internal_item()
	if(!current_internal_item)
		return
	disassemble(user)
