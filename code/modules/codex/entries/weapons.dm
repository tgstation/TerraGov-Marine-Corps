/obj/item/attachable/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/obj/item/attachable/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.lore_text)
		return general_entry.lore_text

/obj/item/attachable/get_mechanics_info()
	. = ..()
	var/list/attach_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		attach_strings += general_entry.mechanics_text

	if(slot = "muzzle")
		attach_strings += "This attaches to the muzzle slot."
	if(slot = "rail")
		attach_strings += "This attaches to the rail slot."
	if(slot = "stock")
		attach_strings += "This attaches to the stock slot."
	if(slot = "under")
		attach_strings += "This attaches to the underbarrel slot."

	if(flags_attach_features & ATTACH_WEAPON)
		attach_strings += "This can be attached to a weapon."

	if(flags_attach_features & ATTACH_REMOVABLE)
		attach_strings += "This can be field stripped off the weapon if needed."

	if(flags_attach_features & ATTACH_ACTIVATION)
		attach_strings += "This needs to be activated to be used."

	if(flags_attach_features & ATTACH_RELOADABLE)
		attach_strings += "This can be reloaded with the appropriate ammunition."	

	if(max_rounds)
		attach_strings += "This attachment can hold [max_rounds] rounds of ammunition."

	if(max_range)
		attach_strings += "This attachment has a max range of [max_range] tiles."

	if(accuracy_mod)
		switch(accuracy_mod)
			if(-INFINITY to -51)
				attach_strings += "This will make it almost impossible to hit with when wielded."
			if(-50 to -41)
				attach_strings += "this will extremely negatively impact your wielded aim."
			if(-40 to -31)
				attach_strings += "this will harshly negatively impact your wielded aim."
			if(-30 to -21)
				attach_strings += "this will moderately negatively impact your wielded aim."
			if(-20 to -11)
				attach_strings += "this will lightly negatively impact your wielded aim."
			if(-10 to -1)
				attach_strings += "this will minorly negatively impact your wielded aim."
			if(0 to 9)
				attach_strings += "this will minorly positively impact your wielded aim."
			if(10 to 19)
				attach_strings += "this will lightly positively impact your wielded aim."
			if(20 to 29)
				attach_strings += "this will moderately positively impact your wielded aim."
			if(30 to 39)
				attach_strings += "this will harshly positively impact your wielded aim."
			if(40 to 49)
				attach_strings += "this will extremely positively impact your wielded aim."
			if(50 to INFINITY)
				attach_strings += "this will make it almost impossible to miss when wielded."

	if(accuracy_unwielded_mod)
		switch(accuracy_unwielded_mod)
			if(-INFINITY to -51)
				attach_strings += "This will make it almost impossible to hit with when unwielded."
			if(-50 to -41)
				attach_strings += "this will extremely negatively impact your unwielded aim."
			if(-40 to -31)
				attach_strings += "this will harshly negatively impact your unwielded aim."
			if(-30 to -21)
				attach_strings += "this will moderately negatively impact your unwielded aim."
			if(-20 to -11)
				attach_strings += "this will lightly negatively impact your unwielded aim."
			if(-10 to -1)
				attach_strings += "this will minorly negatively impact your unwielded aim."
			if(0 to 9)
				attach_strings += "this will minorly positively impact your unwielded aim."
			if(10 to 19)
				attach_strings += "this will lightly positively impact your unwielded aim."
			if(20 to 29)
				attach_strings += "this will moderately positively impact your unwielded aim."
			if(30 to 39)
				attach_strings += "this will harshly positively impact your unwielded aim."
			if(40 to 49)
				attach_strings += "this will extremely positively impact your unwielded aim."
			if(50 to INFINITY)
				attach_strings += "this will make it almost impossible to miss when unwielded."


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


	. += jointext(attach_strings, "<br>")


/datum/codex_entry/baton
	associated_paths = list(/obj/item/weapon/baton)
	mechanics_text = "The baton needs to be turned on to apply the stunning effect. Use it in your hand to toggle it on or off. If your intent is \
	set to 'harm', you will inflict damage when using it, regardless if it is on or not. Each stun reduces the baton's charge, which can be replenished by \
	putting it inside a weapon recharger."

/datum/codex_entry/mines
	associated_paths = list(/obj/item/explosive/mine)
	mechanics_text = "Claymores are best used in tandem with sentry guns that can shoot enemies which trip them, and ambushing marines concealed by tarps or cloaking devices."
