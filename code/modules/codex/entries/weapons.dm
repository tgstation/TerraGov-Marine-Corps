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

	if(slot == "muzzle")
		attach_strings += "This attaches to the muzzle slot on most weapons.<br>"
	if(slot == "rail")
		attach_strings += "This attaches to the rail slot on most weapons.<br>"
	if(slot == "stock")
		attach_strings += "This attaches to the stock slot on most weapons.<br>"
	if(slot == "under")
		attach_strings += "This attaches to the underbarrel slot on most weapons.<br>"

	if(flags_attach_features & ATTACH_REMOVABLE)
		attach_strings += "This can be field stripped off the weapon if needed."

	if(flags_attach_features & ATTACH_ACTIVATION)
		attach_strings += "This needs to be activated to be used."

	if(flags_attach_features & ATTACH_RELOADABLE)
		attach_strings += "This can be reloaded with the appropriate ammunition."	

	//if(max_rounds) doesn't work for all the attachements, only the attached_gun ones, UGL, shottie, flamer.
	//	attach_strings += "This attachment can hold [max_rounds] rounds of ammunition."

	//if(max_range) same here as above.
	//	attach_strings += "This attachment has a max range of [max_range] tiles."

	if(accuracy_mod)
		switch(accuracy_mod)
			if(-INFINITY to -1.01)
				attach_strings += "You will basically never hit with this attached to your weapon while wielded."
			if(-1 to -0.01)
				attach_strings += "You will potentially hit [accuracy_mod * 100]% less with your weapon while wielded with this attached."
			if(0 to 1)
				attach_strings += "You will potentially hit [accuracy_mod * 100]% more with your weapon while wielded with this attached."
			if(1 to INFINITY)
				attach_strings += "You will basically always hit attached to your weapon when it's wielded."

	if(accuracy_unwielded_mod)
		switch(accuracy_unwielded_mod)
			if(-INFINITY to -1.01)
				attach_strings += "You will basically never hit with this attached to your weapon while unwielded."
			if(-1 to -0.01)
				attach_strings += "You will potentially hit [accuracy_unwielded_mod * 100]% less with your weapon while unwielded with this attached."
			if(0 to 1)
				attach_strings += "You will potentially hit [accuracy_unwielded_mod * 100]% more with your weapon while unwielded with this attached."
			if(1 to INFINITY)
				attach_strings += "You will basically always hit attached to your weapon when it's unwielded."

	if(damage_mod)
		switch(damage_mod)
			if(-INFINITY to -1.01)
				attach_strings += "You will actively heal your target with your weapon with this attached."
			if(-1 to -0.01)
				attach_strings += "You will do [damage_mod * 100]% less damage with your weapon with this attached."
			if(0 to 1)
				attach_strings += "You will do [damage_mod * 100]% more damage with your weapon with this attached."
			if(1 to INFINITY)
				attach_strings += "You will basically destroy whatever you hit with this weapon."

	if(damage_falloff_mod)
		switch(damage_falloff_mod)
			if(-INFINITY to -1.01)
				attach_strings += "Your bullets will lose all of their damage over distance with this attached."
			if(-1 to -0.01)
				attach_strings += "You will do [damage_falloff_mod * 100]% less damage with your weapon over distance with this attached."
			if(0 to 1)
				attach_strings += "You will do [damage_falloff_mod * 100]% more damage with your weapon over distance with this attached."
			if(1 to INFINITY)
				attach_strings += "You will basically destroy whatever you hit with this weapon at range with this attached."

	if(scatter_mod)
		switch(scatter_mod)
			if(-INFINITY to -0.01)
				attach_strings += "This will make the weapon have [scatter_mod]% less scatter with this attached and wielded."
			if(0 to INFINITY)	
				attach_strings += "This will make the weapon have [scatter_mod]% more scatter with this attached and wielded."

	if(scatter_unwielded_mod)
		switch(scatter_unwielded_mod)
			if(-INFINITY to -0.01)
				attach_strings += "This will make the weapon have [scatter_unwielded_mod]% less scatter with this attached and unwielded."
			if(0 to INFINITY)	
				attach_strings += "This will make the weapon have [scatter_unwielded_mod]% more scatter with this attached and unwielded."

	if(recoil_mod)
		switch(recoil_mod)
			if(-INFINITY to -0.01)
				attach_strings += "This will make the weapon have [recoil_mod] less recoil with this attached and wielded."
			if(0 to INFINITY)	
				attach_strings += "This will make the weapon have [recoil_mod] more recoil with this attached and wielded."

	if(recoil_unwielded_mod)
		switch(recoil_unwielded_mod)
			if(-INFINITY to -0.01)
				attach_strings += "This will make the weapon have [recoil_unwielded_mod] less recoil with this attached and unwielded."
			if(0 to INFINITY)	
				attach_strings += "This will make the weapon have [recoil_unwielded_mod] more recoil with this attached and unwielded."

	if(burst_scatter_mod)
		switch(burst_scatter_mod)
			if(-INFINITY to -1.01)
				attach_strings += "Your bullets will hone in like a laser with this attached."
			if(-1 to -0.01)
				attach_strings += "Your bullets will scatter [burst_scatter_mod * 100]% less with this attached."
			if(0 to 1)
				attach_strings += "Your bullets will scatter [burst_scatter_mod * 100]% more with this attached."
			if(1 to INFINITY)
				attach_strings += "Your bullets will basically spray like a hose with this attached."

	if(silence_mod)
		attach_strings += "This can silence the weapon if it is attached."

	if(light_mod)
		attach_strings += "This can add an additional [light_mod] tiles of light if it is turned on when attached to a weapon."

	if(delay_mod)
		switch(delay_mod)
			if(-INFINITY to -30)
				attach_strings += "Your bullets will fire at the speed of your clicks with this attached."
			if(-29.99 to -0.01)
				attach_strings += "You will be able to shoot [delay_mod / 10] faster between clicks with this attached."
			if(0 to 29.99)
				attach_strings += "You will be able to shoot [delay_mod / 10] slower between clicks with this attached."
			if(30 to INFINITY)
				attach_strings += "You will almost never be able to shoot this weapon. Better pack a book to read inbetween shots."

	//if(burst_delay_mod) no attachment uses this, yet it's defined in gun_attachables
	//	switch(burst_delay_mod)

	if(burst_mod)
		switch(burst_mod)
			if(-INFINITY to -0.01)
				attach_strings += "This will make the weapons burst mode decrease by [burst_mod] shots per trigger pull."
			if(0 to INFINITY)	
				attach_strings += "This will make the weapons burst mode increase by [burst_mod] shots per trigger pull."
	
	if(size_mod)
		attach_strings += "This will make your weapon [size_mod] weight bigger. Potentially making it no longer suitable for holsters."
	
	if(aim_speed_mod)
		switch(aim_speed_mod)
			if(SLOWDOWN_ADS_SHOTGUN)
				attach_strings += "<br>It will slow the user down by a small amount if wielded."
			if(SLOWDOWN_ADS_SPECIALIST_LIGHT)
				attach_strings += "<br>It will slow the user down by a modest amount if wielded."
			if(SLOWDOWN_ADS_SCOPE)
				attach_strings += "<br>It will slow the user down by a large amount if wielded."
			if(SLOWDOWN_ADS_SPECIALIST_HEAVY to INFINITY)
				attach_strings += "<br>It will slow the user down by a massive amount if wielded."
	if(!aim_speed_mod)
		attach_strings += "<br>It will not slow the user down if this is attached and wielded."
	
	if(melee_mod)
		attach_strings += "This will make the weapon do [melee_mod] more damage per swing with it attached."

	if(wield_delay_mod)
		attach_strings += "This will make the weapon take [wield_delay_mod / 10] seconds longer to wield."
	
	if(attach_shell_speed_mod)
		switch(attach_shell_speed_mod)
			if(-INFINITY to -1.01)
				attach_strings += "Your bullets move at the speed of molasses, cold molasses."
			if(-1 to -0.01)
				attach_strings += "Your bullets will move [attach_shell_speed_mod * 100]% faster with this attached."
			if(0 to 10)
				attach_strings += "Your bullets will move [attach_shell_speed_mod * 100]% slower with this attached."
			if(10.01 to INFINITY)
				attach_strings += "Your bullets will instantly teleport to your foes with this attached."
	
	if(movement_acc_penalty_mod)
		switch(movement_acc_penalty_mod)
			if(-INFINITY to -1.01)
				attach_strings += "Your will never hit anything while moving with this attached.."
			if(-1 to -0.01)
				attach_strings += "Your bullets will move [attach_shell_speed_mod * 100]% faster with this attached."
			if(0 to 10)
				attach_strings += "Your bullets will move [attach_shell_speed_mod * 100]% slower with this attached."
			if(10.01 to INFINITY)
				attach_strings += "Your bullets will instantly teleport to your foes with this attached."

	if(max_rounds)
		attach_strings += "This attachment can hold [max_rounds] of its ammunition."

	if(scope_zoom_mod)
		attach_strings += "This has optical glass allowing for magnification and viewing long distances."

	. += jointext(attach_strings, "<br>")


/datum/codex_entry/baton
	associated_paths = list(/obj/item/weapon/baton)
	mechanics_text = "The baton needs to be turned on to apply the stunning effect. Use it in your hand to toggle it on or off. If your intent is \
	set to 'harm', you will inflict damage when using it, regardless if it is on or not. Each stun reduces the baton's charge, which can be replenished by \
	putting it inside a weapon recharger."

/datum/codex_entry/mines
	associated_paths = list(/obj/item/explosive/mine)
	mechanics_text = "Claymores are best used in tandem with sentry guns that can shoot enemies which trip them, and ambushing marines concealed by tarps or cloaking devices."
