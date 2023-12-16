///Parent item for all holster type storage items
/obj/item/storage/holster
	name = "holster"
	desc = "Holds stuff, and sometimes goes swoosh."
	icon_state = "backpack"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_BULKY ///normally the special item will be larger than what should fit. Child items will have lower limits and an override
	storage_slots = 1
	max_storage_space = 4
	flags_equip_slot = ITEM_SLOT_BACK
	draw_mode = 1
	allow_drawing_method = TRUE
	storage_type_limits = list(/obj/item/weapon = 1)
	///the sound produced when the special item is drawn
	var/draw_sound = 'sound/weapons/guns/misc/rifle_draw.ogg'
	///the sound produced when the special item is sheathed
	var/sheathe_sound = 'sound/weapons/guns/misc/rifle_draw.ogg'
	///the snowflake item(s) that will update the sprite.
	var/list/holsterable_allowed = list()
	///records the specific special item currently in the holster
	var/obj/holstered_item = null
	///Image that get's underlayed under the sprite of the holster
	var/image/holstered_item_underlay

/obj/item/storage/holster/equipped(mob/user, slot)
	if (slot == SLOT_BACK || slot == SLOT_BELT || slot == SLOT_S_STORE || slot == SLOT_L_STORE || slot == SLOT_R_STORE )	//add more if needed
		mouse_opacity = MOUSE_OPACITY_OPAQUE //so it's easier to click when properly equipped.
	return ..()

/obj/item/storage/holster/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	return ..()

/obj/item/storage/holster/Destroy()
	if(holstered_item_underlay)
		QDEL_NULL(holstered_item_underlay)
	if(holstered_item)
		QDEL_NULL(holstered_item)
	return ..()

/obj/item/storage/holster/should_access_delay(obj/item/item, mob/user, taking_out) //defaults to 0
	if (!taking_out) // Always allow items to be tossed in instantly
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.back == src)
			return TRUE
	return FALSE

/obj/item/storage/holster/handle_item_insertion(obj/item/W, prevent_warning = 0)
	. = ..()
	if(!. || !is_type_in_list(W,holsterable_allowed)) //check to see if the item being inserted is the snowflake item
		return
	holstered_item = W
	update_icon() //So that the icon actually updates after we've assigned our holstered_item
	playsound(src, sheathe_sound, 15, 1)

/obj/item/storage/holster/remove_from_storage(obj/item/W, atom/new_location, mob/user)
	. = ..()
	if(!. || !is_type_in_list(W,holsterable_allowed)) //check to see if the item being removed is the snowflake item
		return
	holstered_item = null
	update_icon() //So that the icon actually updates after we've assigned our holstered_item
	playsound(src, draw_sound, 15, 1)

/obj/item/storage/holster/attack_hand(mob/living/user) //Prioritizes our snowflake item on unarmed click
	if(holstered_item && ishuman(user) && loc == user)
		holstered_item.attack_hand(user)
	else
		return ..()

/obj/item/storage/holster/update_icon_state()
	if(holstered_item)
		icon_state = initial(icon_state) + "_full"
	else
		icon_state = initial(icon_state)
	item_state = icon_state

/obj/item/storage/holster/update_icon()
	. = ..()
	if(flags_item & HAS_UNDERLAY)
		update_underlays()
	var/mob/user = loc
	if(!istype(user))
		return
	user.update_inv_back()
	user.update_inv_belt()
	user.update_inv_s_store()


///Adds or removes underlay sprites, checks holstered_item to see which underlay to add
/obj/item/storage/holster/proc/update_underlays()
	if(holstered_item && !holstered_item_underlay)
		if(holstered_item.greyscale_config && holstered_item.greyscale_colors)
			holstered_item_underlay = image(SSgreyscale.GetColoredIconByType(holstered_item.greyscale_config, holstered_item.greyscale_colors), "belt")
		else
			holstered_item_underlay = image(icon, src, holstered_item.icon_state)
		underlays += holstered_item_underlay
	else
		underlays -= holstered_item_underlay
		QDEL_NULL(holstered_item_underlay)

/obj/item/storage/holster/do_quick_equip(mob/user) //Will only draw the specific holstered item, not ammo etc.
	if(!holstered_item)
		return FALSE
	var/obj/item/W = holstered_item
	if(!remove_from_storage(W, null, user))
		return FALSE
	return W

/obj/item/storage/holster/vendor_equip(mob/user)
	..()
	return user.equip_to_appropriate_slot(src)

//backpack type holster items
/obj/item/storage/holster/backholster
	name = "backpack holster"
	desc = "You wear this on your back and put items into it. Usually one special item too."
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/backpacks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/backpacks_right.dmi',
	)
	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		)
	max_w_class = WEIGHT_CLASS_NORMAL //normal items
	max_storage_space = 24
	access_delay = 1.5 SECONDS ///0 out for satchel types

//only applies on storage of all items, not withdrawal
/obj/item/storage/holster/backholster/attackby(obj/item/I, mob/user, params)
	. = ..()
	if (use_sound)
		playsound(loc, use_sound, 15, 1, 6)

/obj/item/storage/holster/backholster/equipped(mob/user, slot)
	if (slot == SLOT_BACK)
		mouse_opacity = MOUSE_OPACITY_OPAQUE //so it's easier to click when properly equipped.
		if(use_sound)
			playsound(loc, use_sound, 15, 1, 6)
	return ..()

///RR bag
/obj/item/storage/holster/backholster/rpg
	name = "\improper TGMC rocket bag"
	desc = "This backpack can hold 4 67mm shells, in addition to a recoiless launcher."
	icon_state = "marine_rocket"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_BULKY
	access_delay = 0.5 SECONDS
	holsterable_allowed = list(
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle,
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle/low_impact,
	)
	bypass_w_limit = list(/obj/item/weapon/gun/launcher/rocket/recoillessrifle)
	///only one RR per bag
	storage_type_limits = list(/obj/item/weapon/gun/launcher/rocket/recoillessrifle = 1)
	can_hold = list(
		/obj/item/ammo_magazine/rocket,
		/obj/item/weapon/gun/launcher/rocket/recoillessrifle,
	)
	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		)

/obj/item/storage/holster/backholster/rpg/full/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rocket/recoilless/light(src)
	new /obj/item/ammo_magazine/rocket/recoilless/light(src)
	new /obj/item/ammo_magazine/rocket/recoilless(src)
	new /obj/item/ammo_magazine/rocket/recoilless(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/recoillessrifle(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/backholster/rpg/low_impact/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	new /obj/item/ammo_magazine/rocket/recoilless/low_impact(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/recoillessrifle/low_impact(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/backholster/rpg/heam/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rocket/recoilless/heam(src)
	new /obj/item/ammo_magazine/rocket/recoilless/heam(src)
	new /obj/item/ammo_magazine/rocket/recoilless/heam(src)
	new /obj/item/ammo_magazine/rocket/recoilless/heam(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/recoillessrifle/heam(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/backholster/rpg/som
	name = "\improper SOM RPG bag"
	desc = "This backpack can hold 4 RPGs, in addition to a RPG launcher."
	icon_state = "som_rocket"
	holsterable_allowed = list(
		/obj/item/weapon/gun/launcher/rocket/som,
		/obj/item/weapon/gun/launcher/rocket/som/rad,
	)
	bypass_w_limit = list(/obj/item/weapon/gun/launcher/rocket/som)
	storage_type_limits = list(/obj/item/weapon/gun/launcher/rocket/som = 1)
	can_hold = list(
		/obj/item/ammo_magazine/rocket,
		/obj/item/weapon/gun/launcher/rocket/som,
	)

/obj/item/storage/holster/backholster/rpg/som/war_crimes/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rocket/som/incendiary(src)
	new /obj/item/ammo_magazine/rocket/som/incendiary(src)
	new /obj/item/ammo_magazine/rocket/som/rad(src)
	new /obj/item/ammo_magazine/rocket/som/rad(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/som/rad(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/backholster/rpg/som/ert/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rocket/som/thermobaric(src)
	new /obj/item/ammo_magazine/rocket/som/thermobaric(src)
	new /obj/item/ammo_magazine/rocket/som/heat(src)
	new /obj/item/ammo_magazine/rocket/som/rad(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/som/rad(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/backholster/rpg/som/heat/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rocket/som/heat(src)
	new /obj/item/ammo_magazine/rocket/som/heat(src)
	new /obj/item/ammo_magazine/rocket/som/heat(src)
	new /obj/item/ammo_magazine/rocket/som/heat(src)
	var/obj/item/new_item = new /obj/item/weapon/gun/launcher/rocket/som/heat(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/backholster/mortar
	name = "\improper TGMC mortar bag"
	desc = "This backpack can hold 11 80mm mortar shells, in addition to the mortar itself."
	icon_state = "marinepackt"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = null
	max_storage_space = 30
	access_delay = 0
	holsterable_allowed = list(/obj/item/mortar_kit)
	bypass_w_limit = list(/obj/item/mortar_kit)
	storage_type_limits = list(/obj/item/mortar_kit = 1)
	can_hold = list(
		/obj/item/mortal_shell/he,
		/obj/item/mortal_shell/incendiary,
		/obj/item/mortal_shell/smoke,
		/obj/item/mortal_shell/flare,
		/obj/item/mortal_shell/plasmaloss,
		/obj/item/mortar_kit,
	)

	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		)


/obj/item/storage/holster/backholster/mortar/full/Initialize()
	. = ..()
	var/obj/item/new_item = new /obj/item/mortar_kit(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/backholster/flamer
	name = "\improper TGMC flamethrower bag"
	desc = "This backpack can carry its accompanying flamethrower as well as a modest general storage capacity. Automatically refuels it's accompanying flamethrower."
	icon_state = "pyro_bag"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = null
	max_storage_space = 16
	max_w_class = WEIGHT_CLASS_NORMAL
	access_delay = 0
	holsterable_allowed = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer)
	bypass_w_limit = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer)
	storage_type_limits = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer = 1)
	///The internal fuel tank
	var/obj/item/ammo_magazine/flamer_tank/internal/tank

	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		)

/obj/item/storage/holster/backholster/flamer/Initialize(mapload)
	. = ..()
	tank = new
	update_icon()

/obj/item/storage/holster/backholster/flamer/MouseDrop_T(obj/item/W, mob/living/user)
	. = ..()
	if(istype(W,/obj/item/ammo_magazine/flamer_tank))
		refuel(W, user)

/obj/item/storage/holster/backholster/flamer/afterattack(obj/O as obj, mob/user as mob, proximity)
	. = ..()
	//uses the tank's proc to refuel
	if(istype(O, /obj/structure/reagent_dispensers/fueltank))
		tank.afterattack(O, user)
	if(istype(O,/obj/item/ammo_magazine/flamer_tank))
		refuel(O, user)

/obj/item/storage/holster/backholster/flamer/handle_item_insertion(obj/item/item, prevent_warning = 0, mob/user)
	. = ..()
	if(holstered_item == item)
		var/obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer/flamer = item
		refuel(flamer.chamber_items[1], user)
		flamer.update_ammo_count()

/* Used to refuel the attached FL-86 flamer when it is put into the backpack
 *
 * param1 - The flamer tank, the actual tank we are refilling
 * param2 - The person wearing the backpack
*/
/obj/item/storage/holster/backholster/flamer/proc/refuel(obj/item/ammo_magazine/flamer_tank/flamer_tank, mob/living/user)
	if(!istype(flamer_tank,/obj/item/ammo_magazine/flamer_tank))
		return
	if(get_dist(user, flamer_tank) > 1)
		return
	if(flamer_tank.current_rounds >= flamer_tank.max_rounds)
		to_chat(user, span_warning("[flamer_tank] is already full."))
		return
	if(tank.current_rounds <= 0)
		to_chat(user, span_warning("The [tank] is empty!"))
		return
	var/liquid_transfer_amount = min(tank.current_rounds, flamer_tank.max_rounds - flamer_tank.current_rounds)
	tank.current_rounds -= liquid_transfer_amount
	flamer_tank.current_rounds += liquid_transfer_amount
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(user, span_notice("[flamer_tank] is refilled with [lowertext(tank.caliber)]."))
	update_icon()

/obj/item/storage/holster/backholster/flamer/examine(mob/user)
	. = ..()
	. += "[tank.current_rounds] units of fuel left!"

/obj/item/storage/holster/backholster/flamer/full/Initialize(mapload)
	. = ..()
	var/flamer = new /obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), flamer)

//one slot holsters

///swords
/obj/item/storage/holster/blade
	///used only for storage path purposes
	name = "\improper default holster"
	desc = "You shouldn't see this."

/obj/item/storage/holster/blade/machete
	name = "\improper H5 pattern M2132 machete scabbard"
	desc = "A large leather scabbard used to carry a M2132 machete. It can be strapped to the back, waist or armor."
	icon_state = "machete_holster"
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	holsterable_allowed = list(
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/claymore/harvester,
	)
	can_hold = list(
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/claymore/harvester,
	)

/obj/item/storage/holster/blade/machete/full/Initialize(mapload)
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/claymore/mercsword/machete(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/blade/machete/full_harvester
	name = "H5 Pattern M2132 harvester scabbard"

/obj/item/storage/holster/blade/machete/full_harvester/Initialize(mapload)
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/claymore/harvester(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/blade/katana
	name = "\improper katana scabbard"
	desc = "A large, vibrantly colored katana scabbard used to carry a japanese sword. It can be strapped to the back, waist or armor. Because of the sturdy wood casing of the scabbard, it makes an okay defensive weapon in a pinch."
	icon_state = "katana_holster"
	force = 12
	attack_verb = list("bludgeoned", "struck", "cracked")
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	holsterable_allowed = list(/obj/item/weapon/katana)
	can_hold = list(/obj/item/weapon/katana)

/obj/item/storage/holster/blade/katana/full/Initialize(mapload)
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/katana(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/blade/officer
	name = "\improper officer sword scabbard"
	desc = "A large leather scabbard used to carry a sword. Appears to be a reproduction, rather than original. It can be strapped to the waist or armor."
	icon_state = "officer_sheath"
	flags_equip_slot = ITEM_SLOT_BELT
	holsterable_allowed = list(/obj/item/weapon/claymore/mercsword/machete/officersword)
	can_hold = list(/obj/item/weapon/claymore/mercsword/machete/officersword)

/obj/item/storage/holster/blade/officer/full/Initialize(mapload)
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/claymore/mercsword/machete/officersword(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

//guns

/obj/item/storage/holster/m37
	name = "\improper L44 shotgun scabbard"
	desc = "A large leather holster allowing the storage of any shotgun. It contains harnesses that allow it to be secured to the back for easy storage."
	icon_state = "m37_holster"
	holsterable_allowed = list(
		/obj/item/weapon/gun/shotgun/combat,
		/obj/item/weapon/gun/shotgun/pump,
	)
	can_hold = list(
		/obj/item/weapon/gun/shotgun/combat,
		/obj/item/weapon/gun/shotgun/pump,
	)

/obj/item/storage/holster/m37/full/Initialize(mapload)
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/gun/shotgun/pump(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/t35
	name = "\improper L44 SH-35 scabbard"
	desc = "A large leather holster allowing the storage of an SH-35 Shotgun. It contains harnesses that allow it to be secured to the back for easy storage."
	icon_state = "t35_holster"
	holsterable_allowed = list(/obj/item/weapon/gun/shotgun/pump/t35)
	can_hold = list(
		/obj/item/weapon/gun/shotgun/pump/t35,
	)

/obj/item/storage/holster/t35/full/Initialize(mapload)
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/gun/shotgun/pump/t35(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/m25
	name = "\improper M276 pattern M25 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is designed for the M25 SMG, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	icon_state = "m25_holster"
	icon = 'icons/obj/clothing/belts.dmi'
	flags_equip_slot = ITEM_SLOT_BELT
	holsterable_allowed = list(
		/obj/item/weapon/gun/smg/m25,
		/obj/item/weapon/gun/smg/m25/holstered,
	)
	can_hold = list(/obj/item/weapon/gun/smg/m25)

/obj/item/storage/holster/m25/full/Initialize(mapload)
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/gun/smg/m25(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/t19
	name = "\improper M276 pattern MP-19 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is designed for the MP-19 SMG, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	icon_state = "t19_holster"
	icon = 'icons/obj/clothing/belts.dmi'
	flags_equip_slot = ITEM_SLOT_BELT
	holsterable_allowed = list(
		/obj/item/weapon/gun/smg/standard_machinepistol,
		/obj/item/weapon/gun/smg/standard_machinepistol/compact,
		/obj/item/weapon/gun/smg/standard_machinepistol/vgrip,
	)

	storage_slots = 4
	max_storage_space = 10
	max_w_class = WEIGHT_CLASS_BULKY

	can_hold = list(
		/obj/item/weapon/gun/smg/standard_machinepistol,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
	)

/obj/item/storage/holster/t19/full/Initialize(mapload)
	. = ..()
	var/obj/item/new_item = new /obj/item/weapon/gun/smg/standard_machinepistol(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/obj/item/storage/holster/flarepouch
	name = "flare pouch"
	desc = "A pouch designed to hold flares and a single flaregun. Refillable with a M94 flare pack."
	flags_equip_slot = ITEM_SLOT_POCKET
	storage_slots = 28
	max_storage_space = 28
	icon = 'icons/Marine/marine-pouches.dmi'
	icon_state = "flare"
	storage_type_limits = list(/obj/item/weapon/gun/grenade_launcher/single_shot/flare = 1)
	can_hold = list(
		/obj/item/explosive/grenade/flare/civilian,
		/obj/item/weapon/gun/grenade_launcher/single_shot/flare,
		/obj/item/explosive/grenade/flare,
	)
	refill_types = list(/obj/item/storage/box/m94)
	refill_sound = "rustle"
	holsterable_allowed = list(/obj/item/weapon/gun/grenade_launcher/single_shot/flare/marine)

/obj/item/storage/holster/flarepouch/attackby_alternate(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/weapon/gun/grenade_launcher/single_shot/flare))
		return ..()
	var/obj/item/weapon/gun/grenade_launcher/single_shot/flare/flare_gun = I
	if(flare_gun.in_chamber)
		return
	for(var/obj/item/flare in contents)
		remove_from_storage(flare, get_turf(user), user)
		user.put_in_any_hand_if_possible(flare)
		flare_gun.reload(flare, user)
		return

/obj/item/storage/holster/flarepouch/full/Initialize(mapload)
	. = ..()
	var/obj/item/flare_gun = new /obj/item/weapon/gun/grenade_launcher/single_shot/flare/marine(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), flare_gun)
	for(var/i in 1 to (storage_slots-flare_gun.w_class))
		new /obj/item/explosive/grenade/flare(src)

////////////////////////////// GUN BELTS /////////////////////////////////////

/obj/item/storage/holster/belt
	name = "pistol belt"
	desc = "A belt-holster assembly that allows one to hold a pistol and two magazines."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "m4a3_holster"
	flags_equip_slot = ITEM_SLOT_BELT
	flags_item = HAS_UNDERLAY
	use_sound = null
	storage_slots = 7
	max_storage_space = 15
	max_w_class = WEIGHT_CLASS_NORMAL
	sheathe_sound = 'sound/weapons/guns/misc/pistol_sheathe.ogg'
	draw_sound = 'sound/weapons/guns/misc/pistol_draw.ogg'
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/pistol,
		/obj/item/cell/lasgun/plasma,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta,
		/obj/item/cell/lasgun/lasrifle,
		/obj/item/cell/lasgun/volkite/small,
	)
	holsterable_allowed = list(
		/obj/item/weapon/gun,
	) //Any pistol you add to a holster should update the sprite. Ammo/Magazines dont update any sprites

//This deliniates between belt/gun/pistol and belt/gun/revolver
/obj/item/storage/holster/belt/pistol
	name = "generic pistol belt"
	desc = "A pistol belt that is not a revolver belt"

/obj/item/storage/holster/belt/pistol/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/tac_reload_storage)

/obj/item/storage/holster/belt/pistol/m4a3
	name = "\improper M4A3 holster rig"
	desc = "The M4A3 is a common holster belt. It consists of a modular belt with various clips. This version has a holster assembly that allows one to carry a handgun. It also contains side pouches that can store 9mm or .45 magazines."
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/cell/lasgun/lasrifle,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/pistol,
		/obj/item/cell/lasgun/plasma,
	)

/obj/item/storage/holster/belt/pistol/m4a3/full/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/rt3(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	new /obj/item/ammo_magazine/pistol/extended(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/officer/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/rt3(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/hp(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	new /obj/item/ammo_magazine/pistol/ap(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/fieldcommander/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/m1911/custom(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	new /obj/item/ammo_magazine/pistol/m1911(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/vp70/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/vp70_pmc/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp70/tactical(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	new /obj/item/ammo_magazine/pistol/vp70(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/vp78/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	new /obj/item/ammo_magazine/pistol/vp78(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/som
	name = "\improper S19 holster rig"
	desc = "A belt with origins dating back to old colony security holster rigs."
	icon_state = "som_belt_pistol"
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta,
		/obj/item/cell/lasgun/lasrifle,
		/obj/item/cell/lasgun/volkite/small,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/pistol,
		/obj/item/cell/lasgun/plasma,
	)

/obj/item/storage/holster/belt/pistol/m4a3/som/serpenta/Initialize(mapload, ...)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/m4a3/som/fancy
	name = "\improper S19-B holster rig"
	desc = "A quality pistol belt of a style typically seen worn by SOM officers. It looks old, but well looked after."
	icon_state = "som_belt_pistol_fancy"

/obj/item/storage/holster/belt/pistol/m4a3/som/fancy/fieldcommander/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta/custom(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	new /obj/item/cell/lasgun/volkite/small(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/stand
	name = "\improper M276 pattern M4A3 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version has a holster assembly that allows one to carry the M4A3 comfortably secure. It also contains side pouches that can store 9mm or .45 magazines."
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
	)

/obj/item/storage/holster/belt/pistol/standard_pistol
	name = "\improper T457 pattern pistol holster rig"
	desc = "The T457 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips."
	icon_state = "tp14_holster"

/obj/item/storage/holster/belt/revolver/standard_revolver
	name = "\improper T457 pattern revolver holster rig"
	desc = "The T457 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips."
	icon_state = "tp44_holster"
	bypass_w_limit = list(
		/obj/item/weapon/gun/revolver,
	)
	can_hold = list(
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
	)

/obj/item/storage/holster/belt/m44
	name = "\improper M276 pattern M44 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is for the M44 magnum revolver, along with three pouches for speedloaders."
	icon_state = "m44_holster"
	max_storage_space = 16
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
	)

/obj/item/storage/holster/belt/m44/full/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/single_action/m44(src)
	new /obj/item/ammo_magazine/revolver/heavy(src)
	new /obj/item/ammo_magazine/revolver/marksman(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	new /obj/item/ammo_magazine/revolver(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/mateba
	name = "\improper M276 pattern Mateba holster rig"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is for the powerful Mateba magnum revolver, along with three pouches for speedloaders."
	icon_state = "mateba_holster"
	max_storage_space = 16
	bypass_w_limit = list(
		/obj/item/weapon/gun/revolver/mateba,
	)
	can_hold = list(
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/ammo_magazine/revolver/mateba,
	)

/obj/item/storage/holster/belt/mateba/full/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/mateba/officer
	icon_state = "c_mateba_holster"

/obj/item/storage/holster/belt/mateba/officer/full/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba/custom(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/mateba/notmarine/Initialize(mapload)
	. = ..()
	icon_state = "a_mateba_holster"
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/revolver/mateba/(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	new /obj/item/ammo_magazine/revolver/mateba(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/korovin
	name = "\improper Type 41 pistol holster rig"
	desc = "A modification of the standard UPP pouch rig to carry a single Korovin PK-9 pistol. It also contains side pouches that can store .22 magazines, either hollowpoints or tranquilizers."
	icon_state = "korovin_holster"
	can_hold = list(
		/obj/item/weapon/gun/pistol/c99,
		/obj/item/ammo_magazine/pistol/c99,
		/obj/item/ammo_magazine/pistol/c99t,
	)

/obj/item/storage/holster/belt/korovin/standard/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/korovin/tranq/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/c99/tranq(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99t(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	new /obj/item/ammo_magazine/pistol/c99(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/ts34
	name = "\improper M276 pattern SH-34 shotgun holster rig"
	desc = "A purpose built belt-holster assembly that holds a SH-34 shotgun and one shell box or 2 handfuls."
	icon_state = "ts34_holster"
	max_w_class = WEIGHT_CLASS_BULKY //So it can hold the shotgun.
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 3
	max_storage_space = 8
	can_hold = list(
		/obj/item/weapon/gun/shotgun/double/marine,
		/obj/item/ammo_magazine/shotgun,
		/obj/item/ammo_magazine/handful,
	)
	holsterable_allowed = list(/obj/item/weapon/gun/shotgun/double/marine)

/obj/item/storage/holster/belt/ts34/full/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/shotgun/double/marine(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)

/obj/item/storage/holster/belt/pistol/smart_pistol
	name = "\improper SP-13 holster rig"
	desc = "A holster belt, which holds SP-13 smartpistol and magazines for it."
	can_hold = list(
		/obj/item/weapon/gun/pistol/smart_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol,
	)

/obj/item/storage/holster/belt/pistol/smart_pistol/full/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/gun/new_gun = new /obj/item/weapon/gun/pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol(src)
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_gun)
