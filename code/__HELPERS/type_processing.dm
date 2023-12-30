///Turns a list of typepaths into 'fancy' titles for admins.
/proc/make_types_fancy(list/types)
	if(ispath(types))
		types = list(types)
	. = list()
	for(var/type in types)
		var/typename = "[type]"
		var/static/list/TYPES_SHORTCUTS = list(
			/obj/effect/decal/cleanable = "CLEANABLE",
			/obj/item/radio/headset = "HEADSET",
			/obj/item/clothing/head/helmet/space = "SPESSHELMET",
			/obj/item/book/manual = "MANUAL",
			/obj/item/reagent_containers = "REAGENT_CONTAINERS",
			/obj/machinery/atmospherics = "ATMOS_MECH",
			/obj/machinery/portable_atmospherics = "PORT_ATMOS",
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack = "MECHA_MISSILE_RACK",
			/obj/item/mecha_parts/mecha_equipment = "MECHA_EQUIP",
			/obj/item/organ = "ORGAN",
			/obj/item = "ITEM",
			/obj/machinery = "MACHINERY",
			/obj/effect = "EFFECT",
			/obj = "O",
			/datum = "D",
			/turf/open = "OPEN",
			/turf/closed = "CLOSED",
			/turf = "T",
			/mob/living/carbon = "CARBON",
			/mob/living/simple_animal = "SIMPLE",
			/mob/living = "LIVING",
			/mob = "M"
		)
		for (var/tn in TYPES_SHORTCUTS)
			if(copytext(typename, 1, length("[tn]/") + 1) == "[tn]/" /*findtextEx(typename,"[tn]/",1,2)*/ )
				typename = TYPES_SHORTCUTS[tn] + copytext(typename, length("[tn]/"))
				break
		.[typename] = type

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
