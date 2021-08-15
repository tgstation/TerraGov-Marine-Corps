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

	if(slot == ATTACHMENT_SLOT_MUZZLE)
		attach_strings += "This attaches to the muzzle slot on most weapons.<br>"
	if(slot == ATTACHMENT_SLOT_RAIL)
		attach_strings += "This attaches to the rail slot on most weapons.<br>"
	if(slot == ATTACHMENT_SLOT_STOCK)
		attach_strings += "This attaches to the stock slot on most weapons.<br>"
	if(slot == ATTACHMENT_SLOT_UNDER)
		attach_strings += "This attaches to the underbarrel slot on most weapons.<br>"

	if(flags_attach_features & ATTACH_REMOVABLE)
		attach_strings += "This can be field stripped off the weapon if needed."

	if(flags_attach_features & ATTACH_ACTIVATION)
		attach_strings += "This needs to be activated to be used."

	attach_strings += "<br><U>Always on modifications</U>:<br>"

	if(damage_mod)
		attach_strings += "Damage: [damage_mod * 100]%"
	if(damage_falloff_mod)
		attach_strings += "Damage falloff: [damage_falloff_mod * 100]%"
	if(burst_scatter_mod)
		attach_strings += "Burst scatter multiplier: [burst_scatter_mod]"
	if(silence_mod)
		attach_strings += "This can silence the weapon if it is attached."
	if(light_mod)
		attach_strings += "Light increase: [light_mod] if turned on."
	if(delay_mod)
		attach_strings += "Delay between shots: [delay_mod / 10]"
	if(burst_mod)
		attach_strings += "Burst change: [burst_mod] shots."
	if(size_mod)
		attach_strings += "This will make your weapon [size_mod] weight bigger. Potentially making it no longer suitable for holsters."
	if(melee_mod)
		attach_strings += "Melee damage: [melee_mod]."
	if(wield_delay_mod)
		attach_strings += "Wield delay: [wield_delay_mod / 10] seconds."
	if(attach_shell_speed_mod)
		attach_strings += "Bullet speed: [attach_shell_speed_mod * 100]%"
	if(aim_mode_movement_mult)
		attach_strings += "Aim Mode slowdow modifier: [aim_mode_movement_mult*100]%"
	if(movement_acc_penalty_mod)
		attach_strings += "Running accuracy penalty: [movement_acc_penalty_mod * 100]%"
	if(scope_zoom_mod)
		attach_strings += "This has optical glass allowing for magnification and viewing long distances."
	if(aim_speed_mod)
		switch(aim_speed_mod)
			if(-INFINITY to 0.35)
				attach_strings += "<br>It will slow the user down more by a small amount if wielded."
			if((0.36) to 0.75)
				attach_strings += "<br>It will slow the user down more by a modest amount if wielded."
			if((0.76) to 1)
				attach_strings += "<br>It will slow the user down more by a large amount if wielded."
			if((1.01) to INFINITY)
				attach_strings += "<br>It will slow the user down more by a massive amount if wielded."
	if(!aim_speed_mod)
		attach_strings += "<br>It will not slow the user down more if this is attached and wielded."
	if(ammo_mod)
		attach_strings += "This will allow you to overcharge your weapon."
	if(charge_mod)
		attach_strings += "Charge cost: [charge_mod]."
	if(length(gun_firemode_list_mod) > 0)
		attach_strings += "This will allow for additional firemodes."


	attach_strings += "<br><U>Wielded modifications</U>:<br>"

	if(accuracy_mod)
		attach_strings += "Accuracy wielded: [accuracy_mod * 100]%"
	if(scatter_mod)
		attach_strings += "Scatter wielded: [scatter_mod]%"
	if(recoil_mod)
		attach_strings += "Recoil wielded: [recoil_mod]"

	attach_strings += "<br><U>un-wielded modifications</U>:<br>"

	if(accuracy_unwielded_mod)
		attach_strings += "Accuracy un-wielded: [accuracy_unwielded_mod * 100]%"
	if(scatter_unwielded_mod)
		attach_strings += "Scatter un-wielded: [scatter_unwielded_mod]%"
	if(recoil_unwielded_mod)
		attach_strings += "Recoil un-wielded: [recoil_unwielded_mod]"

	. += jointext(attach_strings, "<br>")


/datum/codex_entry/baton
	associated_paths = list(/obj/item/weapon/baton)
	mechanics_text = "The baton needs to be turned on to apply the stunning effect. Use it in your hand to toggle it on or off. If your intent is \
	set to 'harm', you will inflict damage when using it, regardless if it is on or not. Each stun reduces the baton's charge, which can be replenished by \
	putting it inside a weapon recharger."

/datum/codex_entry/mines
	associated_paths = list(/obj/item/explosive/mine)
	mechanics_text = "Claymores are best used in tandem with sentry guns that can shoot enemies which trip them, and ambushing marines concealed by tarps or cloaking devices."

