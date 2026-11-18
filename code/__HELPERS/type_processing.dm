///Turns a list of typepaths into 'fancy' titles for admins.
/proc/make_types_fancy(list/types)
	if(ispath(types))
		types = list(types)
	var/static/list/types_to_replacement
	var/static/list/replacement_to_text
	if(!types_to_replacement)
		// Longer paths come after shorter ones, try and keep the structure
		var/list/work_from = list(
			/datum = "DATUM",
			/area = "AREA",
			/atom/movable = "MOVABLE",
			/atom/movable/projectile = "PROJECTILE",
			/obj = "OBJ",
			/turf = "TURF",
			/turf/closed = "CLOSED",
			/turf/open = "OPEN",

			/mob = "MOB",
			/mob/living = "LIVING",
			/mob/living/carbon = "CARBON",
			/mob/living/carbon/human = "HUMANOID",
			/mob/living/carbon/xenomorph = "XENO",
			/mob/living/simple_animal = "SIMPLE",
			/mob/living/silicon = "SILICON",
			/mob/living/silicon/robot = "CYBORG",

			/obj/item = "ITEM",
			/obj/item/mecha_parts/mecha_equipment = "MECHA_EQUIP",
			/obj/item/mecha_parts/mecha_equipment/weapon = "MECHA_WEAPON",
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack = "MECHA_MISSILE_RACK",
			/obj/item/organ = "ORGAN",
			/obj/item/weapon/gun = "GUN",
			/obj/item/ammo_magazine = "AMMO_MAGAZINE",
			/obj/item/stack/sheet = "SHEET",
			/obj/item/stack/sheet/mineral = "MINERAL_SHEET",
			/obj/item/circuitboard = "CIRCUITBOARD",
			/obj/item/circuitboard/machine = "MACHINE_BOARD",
			/obj/item/circuitboard/computer = "COMPUTER_BOARD",
			/obj/item/reagent_containers = "REAGENT_CONTAINERS",
			/obj/item/reagent_containers/pill = "PILL",
			/obj/item/reagent_containers/cup/glass = "DRINK",
			/obj/item/reagent_containers/food = "FOOD",
			/obj/effect/decal/cleanable = "CLEANABLE",
			/obj/item/radio/headset = "HEADSET",
			/obj/item/clothing = "CLOTHING",
			/obj/item/clothing/mask = "MASK",
			/obj/item/clothing/mask/gas = "GASMASK",
			/obj/item/clothing/gloves = "GLOVES",
			/obj/item/clothing/shoes = "SHOES",
			/obj/item/clothing/under = "JUMPSUIT",
			/obj/item/clothing/suit = "SUIT",
			/obj/item/clothing/suit/armor = "ARMOR",
			/obj/item/clothing/head = "HEAD",
			/obj/item/clothing/head/helmet = "HELMET",
			/obj/item/clothing/head/helmet/space = "SPESSHELMET",
			/obj/item/storage/backpack = "BACKPACK",
			/obj/item/storage/belt = "BELT",
			/obj/item/storage/pill_bottle = "PILL_BOTTLE",
			/obj/item/book/manual = "MANUAL",

			/obj/structure = "STRUCTURE",
			/obj/structure/closet = "CLOSET",
			/obj/structure/closet/crate = "CRATE",
			/obj/structure/closet/crate/secure = "LOCKED_CRATE",
			/obj/structure/closet/secure_closet = "LOCKED_CLOSET",

			/obj/machinery = "MACHINERY",
			/obj/machinery/atmospherics = "ATMOS_MECH",
			/obj/machinery/portable_atmospherics = "PORT_ATMOS",
			/obj/machinery/door = "DOOR",
			/obj/machinery/door/airlock = "AIRLOCK",
			/obj/machinery/computer = "COMPUTER",
			/obj/machinery/computer/camera_advanced/shuttle_docker = "DOCKING_COMPUTER",
			/obj/machinery/vending = "VENDING",
			/obj/effect = "EFFECT",
		)
		// ignore_root_path so we can draw the root normally
		types_to_replacement = zebra_typecacheof(work_from, ignore_root_path = TRUE)
		replacement_to_text = list()
		for(var/key in work_from)
			replacement_to_text[work_from[key]] = "[key]"

	. = list()
	for(var/type in types)
		var/replace_with = types_to_replacement[type]
		if(!replace_with)
			.["[type]"] = type
			continue
		var/cut_out = replacement_to_text[replace_with]
		// + 1 to account for /
		.[replace_with + copytext("[type]", length(cut_out) + 1)] = type

///Generates a static list of 'fancy' atom types, or returns that if its already been generated.
/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(typesof(/atom))
	return pre_generated_list

///Generates a static list of 'fancy' datum types, excluding everything atom, or returns that if its already been generated.
/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(sort_list(typesof(/datum) - typesof(/atom)))
	return pre_generated_list

/**
 * Takes a given fancy list and filters out a given filter text.
 * Args:
 * fancy_list - The list provided we filter.
 * filter - the text we use to filter fancy_list
 */
/proc/filter_fancy_list(list/fancy_list, filter as text)
	var/list/matches = new
	var/end_len = -1
	var/list/endcheck = splittext(filter, "!")
	if(endcheck.len > 1)
		filter = endcheck[1]
		end_len = length_char(filter)

	for(var/key in fancy_list)
		var/value = fancy_list[key]
		if(findtext("[key]", filter, -end_len) || findtext("[value]", filter, -end_len))
			matches[key] = value
	return matches

///Splits the type with parenthesis between each word so admins visually tell it is a typepath.
/proc/return_typenames(type)
	return splittext("[type]", "/")
