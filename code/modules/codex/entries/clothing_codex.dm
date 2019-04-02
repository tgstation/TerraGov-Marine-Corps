
// Clothing armour values.
/obj/item/clothing
	var/list/armour_to_descriptive_term = list(
		"melee" = "melee attacks",
		"bullet" = "ballistics",
		"laser" = "lasers",
		"energy" = "energy",
		"bomb" = "explosions",
		"bio" = "biohazards",
		"rad" = "radiation",
		"fire" = "fire",
		"acid" = "acid"
		)

var/list/string_part_flags = list("head" = HEAD,
								"face" = FACE,
								"eyes" = EYES,
								"chest" = CHEST,
								"groin" = GROIN,
								"legs" = LEGS,
								"feet" = FEET,
								"arms" = ARMS,
								"hands" = HANDS)

var/list/string_equip_flags = list( "suit slot" = ITEM_SLOT_OCLOTHING,
									"uniform" = ITEM_SLOT_ICLOTHING,
									"gloves" = ITEM_SLOT_GLOVES,
									"eyes" = ITEM_SLOT_EYES,
									"ears" = ITEM_SLOT_EARS,
									"mask" = ITEM_SLOT_MASK,
									"head" = ITEM_SLOT_HEAD,
									"feet" = ITEM_SLOT_FEET,
									"ID" = ITEM_SLOT_ID,
									"belt" = ITEM_SLOT_BELT,
									"back" = ITEM_SLOT_BACK,
									"pocket" = ITEM_SLOT_POCKET)

/obj/item/clothing/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/obj/item/clothing/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.lore_text)
		return general_entry.lore_text

/obj/item/clothing/get_mechanics_info()
	var/list/armor_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		armor_strings += general_entry.mechanics_text + "<br>"

	for(var/armor_type in armour_to_descriptive_term)
		switch(armor.getRating(armor_type))
			if(0)
				armor_strings += "It provides no protection against [armour_to_descriptive_term[armor_type]]."
			if(1 to 20)
				armor_strings += "It barely protects against [armour_to_descriptive_term[armor_type]]."
			if(21 to 30)
				armor_strings += "It provides a very small defense against [armour_to_descriptive_term[armor_type]]."
			if(31 to 40)
				armor_strings += "It offers a small amount of protection against [armour_to_descriptive_term[armor_type]]."
			if(41 to 50)
				armor_strings += "It offers a moderate defense against [armour_to_descriptive_term[armor_type]]."
			if(51 to 60)
				armor_strings += "It provides a strong defense against [armour_to_descriptive_term[armor_type]]."
			if(61 to 70)
				armor_strings += "It is very strong against [armour_to_descriptive_term[armor_type]]."
			if(71 to 80)
				armor_strings += "This gives a very robust defense against [armour_to_descriptive_term[armor_type]]."
			if(81 to 99)
				armor_strings += "Wearing this would make you nigh-invulerable against [armour_to_descriptive_term[armor_type]]."
			if(100 to INFINITY)
				armor_strings += "You would have godly protection against [armour_to_descriptive_term[armor_type]] if you wore this."

	if(slowdown)
		switch(slowdown)
			if(SLOWDOWN_ARMOR_VERY_LIGHT)
				armor_strings += "<br>It will slow the wearer down by very little."
			if(SLOWDOWN_ARMOR_LIGHT)
				armor_strings += "<br>It will slow the wearer down by a small amount."
			if(SLOWDOWN_ARMOR_MEDIUM)
				armor_strings += "<br>It will slow the wearer down by a modest amount."
			if(SLOWDOWN_ARMOR_HEAVY)
				armor_strings += "<br>It will slow the wearer down by a large amount."
			if(SLOWDOWN_ARMOR_VERY_HEAVY)
				armor_strings += "<br>It will slow the wearer down by a massive amount."
	if(!slowdown)
		armor_strings += "<br>It will not slow the wearer down."

	if(flags_inventory & NOPRESSUREDMAGE)
		armor_strings += "Wearing this will protect you from the vacuum of space."

	if(flags_inventory & BLOCKSHARPOBJ)
		armor_strings += "The material is exceptionally thick."

	if(max_heat_protection_temperature >= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE)
		armor_strings += "This can protect you from high temperatures, but you aren't fireproof."
	else if(max_heat_protection_temperature >= SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE)
		armor_strings += "It provides good protection against fire and heat."

	if(!isnull(min_cold_protection_temperature) && min_cold_protection_temperature <= ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE)
		armor_strings += "It provides protection against cold temperatures."

	var/list/covers = list()
	var/list/slots = list()
	for(var/name in string_part_flags)
		if(flags_armor_protection & string_part_flags[name])
			covers += name
	for(var/name in string_equip_flags)
		if(flags_equip_slot & string_equip_flags[name])
			slots += name

	if(covers.len)
		armor_strings += "<br>It covers the [english_list(covers)]."

	if(slots.len)
		armor_strings += "It can be worn on your [english_list(slots)]."

	if(allowed)
		armor_strings += "<br><U>You can carry the following in it's storage slot</U>:"
		for(var/X in allowed)
			var/obj/B = X
			armor_strings += "[initial(B.name)]"


	. += jointext(armor_strings, "<br>")

/obj/item/clothing/tie/storage/get_mechanics_info()
	. = ..()
	. += "<br>This item has an internal inventory of [hold.storage_slots] slots."
	if(length(hold.bypass_w_limit))
		. += "<br><br><U>You can also carry the following special items in this</U>:"
		for(var/X in hold.bypass_w_limit)
			var/obj/B = X
			. += "<br>[initial(B.name)]"	

/obj/item/clothing/suit/storage/get_mechanics_info()
	. = ..()
	. += "<br><br>This item has an internal inventory of [pockets.storage_slots] slots."
	. += "<br>It can carry weight [pockets.max_w_class] things or lighter."
	if(length(pockets.bypass_w_limit))
		. += "<br><U>You can also carry the following special items in this internal inventory</U>:"
		for(var/X in pockets.bypass_w_limit)
			var/obj/B = X
			. += "<br>[initial(B.name)]"	

/obj/item/clothing/suit/armor/pcarrier/get_mechanics_info()
	. = ..()
	. += "<br>Its protection is provided by the plate inside, examine it for details on armor.<br>"

/datum/codex_entry/M3_normal
	display_name = "M3 pattern marine armor"
	mechanics_text = "This is the base armor, it neither good nor bad. It will serve you well in most situations."
	lore_text = "This armor was first developed for the TGMC upon requests by General McCoy because he was finding casualties happening due to chest penetrations a bit too common for his liking."

/datum/codex_entry/M3_edge
	display_name = "M3-E pattern marine armor"
	mechanics_text = "This is the edge armor. It is good vs melee based attacks but bad against most everything else. Great for those who like to get in close."
	lore_text = "This armor was first developed for the TGMC upon requests by General McCoy because he was finding casualties happening due to guerrilla machete commandos a bit too common for his liking."
