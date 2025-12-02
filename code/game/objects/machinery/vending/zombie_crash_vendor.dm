#define CAT_ARTILLERY "ARTILLERY"
#define CAT_VEHICLE "VEHICLES"
#define CAT_EMPLACEMENTS "EMPLACEMENTS"
#define CAT_BUILDING_SUPPLIES "BUILDING SUPPLIES"
#define CAT_ARMOR_MODULE "ARMOR MODULES"
#define CAT_GRENADE "GRENADES"
#define CAT_ATTACHMENTS "ATTACHMENTS"
#define CAT_SMARTGUNNER "SMARTGUNNER"
#define CAT_WEAPONS "WEAPONS"
#define CAT_FUN "FUN"

/obj/machinery/zombie_crash_vendor
	name = "\improper progression rewards vendor"
	desc = "A mysterious vendor that keeps tracks of how well your team has done against the zombies and grants rewards for these efforts."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "marineuniform"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	interaction_flags = INTERACT_MACHINE_TGUI

	idle_power_usage = 60
	active_power_usage = 3000
	light_range = 1.5
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	/// A list of all category names. Will be set during Initialization.
	var/list/categories = list()
	/// An associative list of: [typepath] = list(category_name, product_name, product_cost, product_color)
	var/list/listed_products = list(
		// Artillery & Mortar
		/obj/item/binoculars/tactical/range = list(CAT_ARTILLERY, "Range Finders", 1, "tool"),
		/obj/item/mortar_kit = list(CAT_ARTILLERY, "Mortar", 1, "artillery"),
		/obj/item/mortal_shell/flare = list(CAT_ARTILLERY, "Mortar Flare Shell", 0.5, "artillery-ammo"),
		/obj/item/mortal_shell/he = list(CAT_ARTILLERY, "Mortar HE Shell", 0.75, "artillery-ammo"),
		/obj/item/mortal_shell/incendiary = list(CAT_ARTILLERY, "Mortar Incendiary Shell", 1.5, "artillery-ammo"),
		/obj/item/mortar_kit/howitzer = list(CAT_ARTILLERY, "Howitzer", 1, "artillery"),
		/obj/item/mortal_shell/howitzer/he = list(CAT_ARTILLERY, "Howitzer HE Shell", 0.75, "artillery-ammo"),
		/obj/item/mortal_shell/howitzer/incendiary = list(CAT_ARTILLERY, "Howitzer Incendiary Shell", 1.5, "artillery-ammo"),
		/obj/item/mortal_shell/howitzer/white_phos = list(CAT_ARTILLERY, "Howitzer WP Shell", 2, "artillery-ammo"),
		// Vehicles + Vehicle Ammo
		/obj/item/unmanned_vehicle_remote = list(CAT_VEHICLE, "Remote Control", 0.5, "tool"),
		/obj/item/deployable_vehicle/tiny = list(CAT_VEHICLE, "\"Skink\" Unmanned Vehicle", 1, "vehicle"),
		/obj/vehicle/unmanned = list(CAT_VEHICLE, "\"Iguana\" Unmanned Vehicle", 2, "vehicle"),
		/obj/vehicle/unmanned/medium = list(CAT_VEHICLE, "\"Komodo\" Unmanned Vehicle", 3, "vehicle"),
		/obj/vehicle/unmanned/heavy = list(CAT_VEHICLE, "\"Gecko\" Unmanned Vehicle", 4, "vehicle"),
		/obj/item/uav_turret/claw = list(CAT_VEHICLE, "Claw Module", 1, "vehicle-attachable"),
		/obj/item/uav_turret = list(CAT_VEHICLE, "Light UV Machinegun", 5, "vehicle-attachable"),
		/obj/item/ammo_magazine/box11x35mm = list(CAT_VEHICLE, "Light UV Machinegun Ammo", 4, "vehicle-ammo"),
		/obj/item/uav_turret/heavy = list(CAT_VEHICLE, "Heavy UV Machinegun", 5, "vehicle-attachable"),
		/obj/item/ammo_magazine/box12x40mm = list(CAT_VEHICLE, "Heavy UV Machinegun Ammo", 4, "vehicle-ammo"),
		// Emplacements + Emplacement Ammo
		/obj/item/weapon/gun/energy/lasgun/lasrifle/heavy_laser/deployable = list(CAT_EMPLACEMENTS, "\"TE-9001\" Emplacement", 8, "emplacement"),
		/obj/item/cell/lasgun/heavy_laser = list(CAT_EMPLACEMENTS, "\"TE-9001\" Laser Ammo", 6, "emplacement-ammo"),
		/obj/item/weapon/gun/hsg_102 = list(CAT_EMPLACEMENTS, "\"HSG-102\" Emplacement", 12, "emplacement"), // IFF.
		/obj/item/ammo_magazine/hsg_102 = list(CAT_EMPLACEMENTS, "\"HSG-102\" Ammo", 10, "emplacement-ammo"),
		/obj/item/weapon/gun/heavymachinegun = list(CAT_EMPLACEMENTS, "\"HMG-08\" Emplacement", 12, "emplacement"), // Non-IFF, more damage than HSG-102.
		/obj/item/ammo_magazine/heavymachinegun/small = list(CAT_EMPLACEMENTS, "\"HMG-08\" Ammo", 10, "emplacement-ammo"),
		/obj/item/weapon/gun/standard_minigun = list(CAT_EMPLACEMENTS, "\"MG-2005\" Emplacement", 12, "emplacement"), // Non-IFF, roughly same damage as HSG-102 with more ammo.
		/obj/item/ammo_magazine/heavy_minigun = list(CAT_EMPLACEMENTS, "\"MG-2005\" Ammo", 10, "emplacement-ammo"),
		/obj/item/weapon/gun/standard_auto_cannon = list(CAT_EMPLACEMENTS, "\"ATR-22\" Emplacement", 8, "emplacement"), // Cheap because it is bulky and can't be picked up.
		/obj/item/ammo_magazine/auto_cannon = list(CAT_EMPLACEMENTS, "\"ATR-22\" High-Velocity Ammo", 6, "emplacement-ammo"),
		/obj/item/ammo_magazine/auto_cannon/flak = list(CAT_EMPLACEMENTS, "\"ATR-22\" Flak Ammo", 10, "emplacement-ammo"), // Can potentially decapitate zombies.
		// Building Supplies
		/obj/item/stack/sheet/metal/small_stack = list(CAT_BUILDING_SUPPLIES, "Metal x10", 2, "materials"),
		/obj/item/stack/sheet/plasteel/small_stack = list(CAT_BUILDING_SUPPLIES, "Plasteel x10", 4, "materials"),
		/obj/item/stack/sandbags_empty/half = list(CAT_BUILDING_SUPPLIES, "Sandbags x25", 3, "materials"),
		/obj/item/quikdeploy/cade = list(CAT_BUILDING_SUPPLIES, "QuikCade - Metal", 1, "materials"),
		/obj/item/quikdeploy/cade/plasteel = list(CAT_BUILDING_SUPPLIES, "QuikCade - Plasteel", 2, "materials"),
		/obj/item/weapon/shield/riot/marine/deployable = list(CAT_BUILDING_SUPPLIES, "TL-182 deployable shield", 2, "materials"),
		/obj/item/deploy_capsule/barricade = list(CAT_BUILDING_SUPPLIES, "Barricade capsule", 10, "materials"),
		// Armor Modules
		/obj/item/armor_module/module/hlin_explosive_armor = list(CAT_ARMOR_MODULE, "\"Hlin\" Explosive-Armor Module", 6, "armor-module"),
		/obj/item/armor_module/module/valkyrie_autodoc = list(CAT_ARMOR_MODULE, "\"Valkyrie\" Autodoc Module", 10, "armor-module"),
		/obj/item/armor_module/module/tyr_extra_armor = list(CAT_ARMOR_MODULE, "\"Tyr\" Armor Module", 10, "armor-module"),
		/obj/item/armor_module/module/mimir_environment_protection = list(CAT_ARMOR_MODULE, "\"Mimir\" Bio-Armor Module", 10, "armor-module"),
		/obj/item/armor_module/module/fire_proof = list(CAT_ARMOR_MODULE, "\"Surt\" Fireproof Module", 30, "armor-module"),
		// Grenades
		/obj/item/explosive/grenade = list(CAT_GRENADE, "M40 HEDP grenade", 0.5, "grenade"),
		/obj/item/explosive/grenade/m15 = list(CAT_GRENADE, "M15 Fragmentation grenade", 1, "grenade"),
		/obj/item/explosive/grenade/incendiary  = list(CAT_GRENADE, "M40 HIDP Incendiary grenade", 2, "grenade"),
		/obj/item/explosive/grenade/smokebomb/antigas = list(CAT_GRENADE, "M40-AG Antigas grenade", 1, "grenade"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_small = list(CAT_GRENADE, "Razorburn grenade", 4, "grenade"),
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = list(CAT_GRENADE, "Razorburn canister", 8, "grenade"),
		// Attachments
		/obj/item/attachable/flamer_nozzle/wide = list(CAT_ATTACHMENTS, "Wide Flamer Nozzle", 30, "attachment"),
		/obj/item/attachable/flamer_nozzle/long = list(CAT_ATTACHMENTS, "Long Flamer Nozzle", 5, "attachment"),
		// Smartgunner Ammo
		/obj/item/ammo_magazine/standard_smartmachinegun = list(CAT_SMARTGUNNER, "SG-29 Ammo Drum", 4, "gun-ammo"),
		/obj/item/ammo_magazine/packet/smart_minigun = list(CAT_SMARTGUNNER, "SG-85 Ammo Bin", 8, "gun-ammo"),
		/obj/item/ammo_magazine/rifle/standard_smarttargetrifle = list(CAT_SMARTGUNNER, "SG-62 Target Rifle Magazine", 2, "gun-ammo"),
		/obj/item/ammo_magazine/packet/smart_targetrifle = list(CAT_SMARTGUNNER, "SG-62 Target Rifle Ammo Bin", 8, "gun-ammo"), // 1x packet = 5 mags; discount of 2 points.
		/obj/item/ammo_magazine/rifle/standard_spottingrifle = list(CAT_SMARTGUNNER, "SG-153 Spotting Rifle Magazine", 1, "gun-ammo"),
		/obj/item/ammo_magazine/packet/smart_spottingrifle = list(CAT_SMARTGUNNER, "SG-153 Spotting Rifle Ammo Bin", 3, "gun-ammo"), // 1x packet = 5 mags; discount of 2 points.
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact = list(CAT_SMARTGUNNER, "SG-153 Spotting Rifle High Impact Magazine", 1.5, "gun-ammo"),
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/heavyrubber = list(CAT_SMARTGUNNER, "SG-153 Spotting Rifle Heavy Rubber Magazine", 1.5, "gun-ammo"),
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten = list(CAT_SMARTGUNNER, "SG-153 Spotting Rifle Tungsten Magazine", 1.5, "gun-ammo"),
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/flak = list(CAT_SMARTGUNNER, "SG-153 Spotting Rifle Flak Magazine", 1.5, "gun-ammo"),
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary = list(CAT_SMARTGUNNER, "SG-153 Spotting Rifle Incendiary Magazine", 2, "gun-ammo"),
		// Weapons + Weapon Ammo
		/obj/item/weapon/twohanded/chainsaw = list(CAT_WEAPONS, "Chainsaw", 4, "melee"),
		/obj/item/weapon/twohanded/rocketsledge  = list(CAT_WEAPONS, "Rocketsledge", 8, "melee"),
		/obj/item/weapon/shield/riot/marine  = list(CAT_WEAPONS, "TL-172 defensive shield", 10, "melee"),
		/obj/item/weapon/gun/revolver/mateba = list(CAT_WEAPONS, "Mateba", 3, "gun"),
		/obj/item/ammo_magazine/revolver/mateba = list(CAT_WEAPONS, "Mateba Speedloader", 0.5, "gun-ammo"),
		/obj/item/ammo_magazine/packet/mateba = list(CAT_WEAPONS, "Mateba Packet", 2, "gun-ammo"), // 1x packet = 7x speedloaders; discount of 1.5 points.
		/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/smg = list(CAT_WEAPONS, "\"PL-51\" smg", 10, "gun"), // Plasma ammo is infinite with handheld recharger, so most of the costs is shifted onto the gun.
		/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle = list(CAT_WEAPONS, "\"PL-38\" plasma rifle", 10, "gun"),
		/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/cannon = list(CAT_WEAPONS, "\"PL-96\" plasma cannon", 20, "gun"),
		/obj/item/cell/lasgun/plasma = list(CAT_WEAPONS, "Plasma cell", 0.5, "gun-ammo"),
		/obj/item/weapon/gun/rifle/tx8 = list(CAT_WEAPONS, "\"BR-8\" scout rifle", 2, "gun"), // Gun itself is cheap because it can be found normally.
		/obj/item/ammo_magazine/rifle/tx8 = list(CAT_WEAPONS, "\"BR-8\" magazine", 1, "gun-ammo"),
		/obj/item/ammo_magazine/rifle/tx8/incendiary = list(CAT_WEAPONS, "\"BR-8\" incendiary magazine", 1.5, "gun-ammo"), // Can pierce through multiple zombies to set them on fire.
		/obj/item/ammo_magazine/rifle/tx8/impact = list(CAT_WEAPONS, "\"BR-8\" impact magazine", 0.5, "gun-ammo"),
		/obj/item/weapon/gun/minigun = list(CAT_WEAPONS, "\"MG-100\" Vindicator minigun", 5, "gun"),
		/obj/item/ammo_magazine/minigun_powerpack = list(CAT_WEAPONS, "\"MG-100\" powerpack", 15, "gun-ammo"),
		// Fun
		/obj/item/loot_box/tgmclootbox  = list(CAT_FUN, "Lootbox", 60, "other"),
	)
	/// The total amount of pooled points that have been gained. Shared across all vendors.
	var/static/total_pooled_points = 0
	/// The total amount of pooled points that have been spent. Shared across all vendors.
	var/static/spent_pooled_points = 0

/obj/machinery/zombie_crash_vendor/Initialize(mapload)
	. = ..()
	GLOB.zombie_crash_vendors += src
	for(var/typepath AS in listed_products)
		var/list/product_information = listed_products[typepath]
		var/category_name = product_information[1]
		if(categories[category_name])
			continue
		LAZYADD(categories, category_name)
	update_icon()

/obj/machinery/zombie_crash_vendor/Destroy()
	. = ..()
	GLOB.zombie_crash_vendors -= src

/obj/machinery/zombie_crash_vendor/update_icon()
	. = ..()
	set_light(is_operational() ? initial(light_range) : 0)

/obj/machinery/zombie_crash_vendor/update_icon_state()
	. = ..()
	icon_state = is_operational() ? initial(icon_state) : "[initial(icon_state)]-off"

/obj/machinery/zombie_crash_vendor/update_overlays()
	. = ..()
	if(!is_operational() || !icon_state)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive", src)

/obj/machinery/zombie_crash_vendor/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	if(!allowed(human_user))
		to_chat(human_user, span_warning("Access denied. Your assigned role doesn't have access to this machinery."))
		return FALSE
	var/obj/item/card/id/user_id = human_user.get_idcard()
	if(!istype(user_id))
		return FALSE
	if(user_id.registered_name != human_user.real_name)
		return FALSE
	return TRUE

/obj/machinery/zombie_crash_vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ZombieCrashSelector", name)
		ui.open()

/obj/machinery/zombie_crash_vendor/ui_static_data(mob/user)
	. = list()
	.["vendor_name"] = name
	.["displayed_products"] = list()
	for(var/category_name in categories)
		.["displayed_products"][category_name] = list()
	for(var/typepath in listed_products)
		var/list/product_information = listed_products[typepath]
		var/category_name = product_information[1]
		var/product_name = product_information[2]
		var/product_cost = product_information[3]
		var/atom/product_typepath = typepath
		LAZYADD(.["displayed_products"][category_name], list(list("product_index" = typepath, "product_name" = product_name, "product_color" = product_information[4], "product_cost" = product_cost, "product_desc" = initial(product_typepath.desc))))

/obj/machinery/zombie_crash_vendor/ui_data(mob/user)
	. = list()
	.["categories"] = list()
	for(var/category in categories)
		.["categories"][category] = TRUE
	.["pooled_points_remaining"] = total_pooled_points - spent_pooled_points
	.["pooled_points_total"] = max(total_pooled_points, 1)
	.["personal_points_remaining"] = get_remaining_personal_points(user)
	.["personal_points_total"] = ZOMBIE_CRASH_POINTS_MAXIMUM

/obj/machinery/zombie_crash_vendor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "vend")
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		flick("marineuniform-deny", src)
		return
	var/turf/current_turf = loc
	if(length(current_turf.contents) > 25)
		to_chat(usr, span_warning("The floor is too cluttered, make some space."))
		flick("marineuniform-deny", src)
		return

	var/product_typepath = text2path(params["vend"])
	var/list/product_information = listed_products[product_typepath]
	var/product_cost = product_information[3]

	if(!pay_with_any_points(usr, product_cost))
		to_chat(usr, span_warning("Not enough points."))
		flick("marineuniform-deny", src)
		return

	playsound(src, SFX_VENDING, 25, 0)
	flick("marineuniform-vend", src)
	use_power(active_power_usage)

	var/list/vended_items = list()
	if(ispath(product_typepath, /obj/effect/vendor_bundle))
		var/obj/effect/vendor_bundle/bundle = new product_typepath(loc, FALSE)
		vended_items += bundle.spawned_gear
		qdel(bundle)
	else
		vended_items += new product_typepath(loc)

	for (var/obj/item/vended_item in vended_items)
		vended_item.on_vend(usr, faction, auto_equip = TRUE)

/obj/machinery/zombie_crash_vendor/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return TRUE
	var/obj/item/card/id/id_card = user.get_idcard(TRUE)
	if(I != id_card)
		return FALSE
	var/points_to_transfer = id_card.marine_points[CAT_ZOMBIE_CRASH]
	if(!points_to_transfer)
		balloon_alert(user, "no points transferred!")
		return TRUE
	balloon_alert(user, "[points_to_transfer] points transferred!")
	total_pooled_points += points_to_transfer
	id_card.marine_points[CAT_ZOMBIE_CRASH] = 0

/// Gets all points that can be spent.
/obj/machinery/zombie_crash_vendor/proc/get_remaining_all_points(mob/user)
	return get_remaining_personal_points(user) + (total_pooled_points - spent_pooled_points)

/// Gets all points on a user's ID card.
/obj/machinery/zombie_crash_vendor/proc/get_remaining_personal_points(mob/user)
	var/obj/item/card/id/I = user.get_idcard()
	return I?.marine_points[CAT_ZOMBIE_CRASH] ? I.marine_points[CAT_ZOMBIE_CRASH] : 0

/// Attempts to pay with points. Uses personal points first and then pooled points second. Returns TRUE if it was successfully paid off.
/obj/machinery/zombie_crash_vendor/proc/pay_with_any_points(mob/user, amount)
	if(get_remaining_all_points(user) < amount)
		return FALSE
	var/obj/item/card/id/I = user.get_idcard()
	if(!I)
		spent_pooled_points += amount
		return TRUE
	var/paid_points = clamp(get_remaining_personal_points(user), 0, amount)
	I.marine_points[CAT_ZOMBIE_CRASH] = I.marine_points[CAT_ZOMBIE_CRASH] - paid_points
	amount -= paid_points
	spent_pooled_points += amount
	return TRUE

/// Adds an amount of personal points to someone. Any excess is added to the pooled points.
/obj/machinery/zombie_crash_vendor/proc/add_personal_points(mob/living/carbon/human/human_user, amount)
	var/obj/item/card/id/user_id = human_user.get_idcard()
	if(!user_id)
		return
	var/final_points = user_id.marine_points[CAT_ZOMBIE_CRASH] + amount
	if(final_points <= ZOMBIE_CRASH_POINTS_MAXIMUM)
		user_id.marine_points[CAT_ZOMBIE_CRASH] = final_points
		return
	user_id.marine_points[CAT_ZOMBIE_CRASH] = ZOMBIE_CRASH_POINTS_MAXIMUM
	total_pooled_points += final_points - ZOMBIE_CRASH_POINTS_MAXIMUM

#undef CAT_ARTILLERY
#undef CAT_VEHICLE
#undef CAT_EMPLACEMENTS
#undef CAT_BUILDING_SUPPLIES
#undef CAT_ARMOR_MODULE
#undef CAT_GRENADE
#undef CAT_ATTACHMENTS
#undef CAT_SMARTGUNNER
#undef CAT_WEAPONS
#undef CAT_FUN
