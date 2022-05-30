/obj/machinery/quick_vendor
	name = "Kwik-Equip vendor"
	desc = "An advanced vendor to instantly arm soldiers with specific sets of equipment for immediate combat deployment."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "specialist"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	req_access = null
	req_one_access = null
	///The faction of this loadout vendor
	var/faction = FACTION_NEUTRAL

/obj/machinery/quick_vendor/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!allowed(H))
		return FALSE

	if(!isidcard(H.get_idcard())) //not wearing an ID
		return FALSE

	var/obj/item/card/id/I = H.get_idcard()
	if(I.registered_name != H.real_name)
		return FALSE
	return TRUE


/obj/machinery/quick_vendor/interact(mob/user)
	. = ..()
	user.client.prefs.quick_loadout.loadout_vendor = src
	user.client.prefs.quick_loadout.ui_interact(user)

/obj/machinery/quick_vendor/loyalist
	faction = FACTION_TERRAGOV

/obj/machinery/quick_vendor/rebel
	faction = FACTION_TERRAGOV_REBEL

/obj/machinery/quick_vendor/som
	faction = FACTION_SOM

/obj/machinery/quick_vendor/valhalla
	resistance_flags = INDESTRUCTIBLE
	faction = FACTION_VALHALLA

///quick equip vendor specific code

//////
/datum/quickload_manager
	/**
	 * List of all loadouts. Format is list(list(loadout_job, loadout_name))
	 */
	var/list/loadouts_data = list(
		list("Squad Marine","ready to test"),
		list("Squad Corpsman","test"),
		list("Squad Marine","FC test loadout"),
		list("Squad Marine","culverin test"),
		list("SOM Standard","somtest1"),
		)
	/// The host of the quickload_manager, aka from which loadout vendor are you managing loadouts
	var/loadout_vendor
	/// The version of the loadout manager
	var/version = CURRENT_LOADOUT_VERSION

///Add the name and the job of a datum/loadout into the list of all loadout data
/datum/quickload_manager/proc/add_loadout(datum/loadout/next_loadout)
	loadouts_data += list(list(next_loadout.job, next_loadout.name))

/datum/quickload_manager/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		//gives the SOM loadouts if it's a SOM vendor. WIP/MVP concept
		var/obj/machinery/quick_vendor/L = loadout_vendor
		if(L.faction == FACTION_SOM)
			ui = new(user, src, "Quickload_SOM")
		else
			ui = new(user, src, "Quickload_TGMC")
		ui.open()

/datum/quickload_manager/ui_state(mob/user)
	return GLOB.human_adjacent_state

/datum/quickload_manager/ui_host()
	return loadout_vendor

/// Wrapper proc to set the host of our ui datum, aka the loadout vendor that's showing us the loadouts
/datum/quickload_manager/proc/set_host(_loadout_vendor)
	loadout_vendor = _loadout_vendor
	RegisterSignal(loadout_vendor, COMSIG_PARENT_QDELETING, .proc/close_ui)

/// Wrapper proc to handle loadout vendor being qdeleted while we have loadout manager opened
/datum/quickload_manager/proc/close_ui()
	SIGNAL_HANDLER
	ui_close()

/datum/quickload_manager/ui_data(mob/living/user)
	. = ..()
	var/data = list()
	var/list/loadouts_data_tgui = list()
	for(var/list/loadout_data in loadouts_data)
		var/next_loadout_data = list()
		next_loadout_data["job"] = loadout_data[1]
		next_loadout_data["name"] = loadout_data[2]
		loadouts_data_tgui += list(next_loadout_data)
	data["loadout_list"] = loadouts_data_tgui
	return data

/datum/quickload_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(TIMER_COOLDOWN_CHECK(ui.user, COOLDOWN_LOADOUT_VISUALIZATION))
		return
	TIMER_COOLDOWN_START(ui.user, COOLDOWN_LOADOUT_VISUALIZATION, 1 SECONDS) //Anti spam cooldown
	switch(action)
		if("selectLoadout")
			var/job = params["loadout_job"]
			var/name = params["loadout_name"]
			if(isnull(name))
				return
			var/datum/loadout/loadout = load_loadout(name, job)
			if(!loadout)
				to_chat(ui.user, span_warning("Error when loading this loadout"))
				//delete_loadout(ui.user, name, job)
				CRASH("Fail to load loadouts")
			if(loadout.version != CURRENT_LOADOUT_VERSION)
				var/datum/item_representation/modular_helmet/helmet = loadout.item_list[slot_head_str]
				if(istype(helmet, /datum/item_representation/modular_helmet))
					if(loadout.version < 7)
						loadout.empty_slot(slot_head_str)
					if(loadout.version < 8)
						if("[helmet.item_type]" == "/obj/item/clothing/head/modular/marine/m10x/tech" || "[helmet.item_type]" == "/obj/item/clothing/head/modular/marine/m10x/corpsman" || "[helmet.item_type]" == "/obj/item/clothing/head/modular/marine/m10x/standard")
							helmet.item_type = /obj/item/clothing/head/modular/marine/m10x
					if(loadout.version < 10)
						helmet.greyscale_colors = initial(helmet.item_type.greyscale_colors)
						for(var/datum/item_representation/armor_module/colored/module AS in helmet.attachments)
							if(!istype(module, /datum/item_representation/armor_module/colored))
								continue
							module.greyscale_colors = initial(module.item_type.greyscale_colors)
				var/datum/item_representation/modular_armor/armor = loadout.item_list[slot_wear_suit_str]
				if(istype(armor, /datum/item_representation/modular_armor))
					if(loadout.version < 7)
						loadout.empty_slot(slot_wear_suit_str)
					if(loadout.version < 8)
						if("[armor.item_type]" == "/obj/item/clothing/suit/modular/pas11x")
							armor.item_type = /obj/item/clothing/suit/modular/xenonauten
					if(loadout.version < 10)
						for(var/datum/item_representation/armor_module/colored/module AS in armor.attachments)
							if(!istype(module, /datum/item_representation/armor_module/colored))
								continue
							module.greyscale_colors = initial(module.item_type.greyscale_colors)
				var/datum/item_representation/uniform_representation/uniform = loadout.item_list[slot_w_uniform_str]
				if(istype(uniform, /datum/item_representation/uniform_representation))
					if(loadout.version < 9)
						uniform.current_variant = null
						uniform.attachments = list()
				var/message_to_send = "Please note: The loadout code has been updated and due to that:"
				if(loadout.version < 7)
					message_to_send += "<br>any modular helmet/suit has been removed from it due to the transitioning of loadout version 6 to 7."
				if(loadout.version < 8)
					message_to_send += "<br>any PAS11 armor/M10x helmet has been removed from it due to the transitioning of loadout version 7 to 8(Xenonauten Addition)."
				if(loadout.version < 9)
					message_to_send += "<br>any uniforms have had their webbings/accessory removed due to the transitioning of loadout version 8 to 9."
				if(loadout.version < 10)
					message_to_send += "<br>any modular armor pieces and jaeger helmets have had their colors reset due to the new color/greyscale system. (version 9 to 10)"
				loadout.version = CURRENT_LOADOUT_VERSION
				message_to_send += "<br>This loadout is now on version [loadout.version]"
				to_chat(ui.user, span_warning(message_to_send))
				//delete_loadout(ui.user, name, job)
				ui.user.client.prefs.save_loadout(loadout)
				add_loadout(loadout)
				to_chat(ui.user, span_warning("Please note: The loadout code has been updated and as such any modular helmet/suit has been removed from it due to the transitioning of loadout versions. Any future modular helmet/suit saves should have no problem being saved."))
			update_static_data(ui.user, ui)
			loadout.loadout_vendor = loadout_vendor
			loadout.ui_interact(ui.user)


/////
///Load a loadout from the savefile and returns it
/datum/quickload_manager/proc/load_loadout(loadout_name, loadout_job)
	///list of all available loadouts, in jatum format because horrible to read is nicer than horrible to create and edit
	var/list/loadout_list = list(
		("ready to testSquad Marine") = "{\"jatum\\\\version\":1,\"content\":{\"jatum\\\\id\":1,\"type\":\"/datum/loadout\",\"name\":{\"type\":\"jatum\\\\raw\",\"value\":\"ready to test\"},\"version\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"job\":{\"type\":\"jatum\\\\raw\",\"value\":\"Squad Marine\"},\"item_list\":{\"jatum\\\\id\":2,\"type\":\"/list\",\"contents\":\[{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_back\"},\"value\":{\"jatum\\\\id\":3,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":4,\"type\":\"/list\",\"contents\":\[\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/backpack/marine/satchel\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_w_uniform\"},\"value\":{\"jatum\\\\id\":5,\"type\":\"/datum/item_representation/uniform_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/under/marine\"},\"attachments\":{\"jatum\\\\id\":6,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":7,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":8,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":9,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":10,\"type\":\"/datum/item_representation/armor_module\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_suit\"},\"value\":{\"jatum\\\\id\":11,\"type\":\"/datum/item_representation/suit_with_storage\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/suit/storage/marine/harness\"},\"pockets\":{\"jatum\\\\id\":12,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":13,\"type\":\"/list\",\"contents\":\[\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/internal/suit/marine\"},\"bypass_vendor_check\":{\"type\":\"jatum\\\\raw\",\"value\":1}}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_gloves\"},\"value\":{\"jatum\\\\id\":14,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/gloves/marine\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_shoes\"},\"value\":{\"jatum\\\\id\":15,\"type\":\"/datum/item_representation/boot\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/shoes/marine/full\"},\"boot_content\":{\"jatum\\\\id\":16,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/attachable/bayonetknife\"}}}}\]}}}",
		("testSquad Corpsman") = "{\"jatum\\\\version\":1,\"content\":{\"jatum\\\\id\":1,\"type\":\"/datum/loadout\",\"name\":{\"type\":\"jatum\\\\raw\",\"value\":\"test\"},\"version\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"job\":{\"type\":\"jatum\\\\raw\",\"value\":\"Squad Corpsman\"},\"item_list\":{\"jatum\\\\id\":2,\"type\":\"/list\",\"contents\":\[{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_head\"},\"value\":{\"jatum\\\\id\":3,\"type\":\"/datum/item_representation/modular_helmet\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/head/modular/marine/skirmisher\"},\"attachments\":{\"jatum\\\\id\":4,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":5,\"type\":\"/datum/item_representation/armor_module/colored\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/armor_module/armor/visor/marine/skirmisher\"},\"greyscale_colors\":{\"type\":\"jatum\\\\raw\",\"value\":\"#6a5b2d#928446#a59770\"}}},{\"value\":{\"jatum\\\\id\":6,\"type\":\"/datum/item_representation/armor_module/storage\",\"storage\":{\"jatum\\\\id\":7,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":8,\"type\":\"/list\",\"contents\":\[\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/internal/marinehelmet\"},\"bypass_vendor_check\":{\"type\":\"jatum\\\\raw\",\"value\":1}},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/armor_module/storage/helmet\"}}},{\"value\":{\"jatum\\\\id\":9,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":10,\"type\":\"/datum/item_representation/armor_module\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_back\"},\"value\":{\"jatum\\\\id\":11,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":12,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":13,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/box/MRE\"}}}\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/backpack/marine/corpsman\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_w_uniform\"},\"value\":{\"jatum\\\\id\":14,\"type\":\"/datum/item_representation/uniform_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/under/marine/corpsman\"},\"attachments\":{\"jatum\\\\id\":15,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":16,\"type\":\"/datum/item_representation/armor_module/storage\",\"storage\":{\"jatum\\\\id\":17,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":18,\"type\":\"/list\",\"contents\":\[\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/internal/white_vest/medic\"},\"bypass_vendor_check\":{\"type\":\"jatum\\\\raw\",\"value\":1}},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/armor_module/storage/uniform/white_vest/medic\"}}},{\"value\":{\"jatum\\\\id\":19,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":20,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":21,\"type\":\"/datum/item_representation/armor_module\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_gloves\"},\"value\":{\"jatum\\\\id\":22,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/gloves/marine\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_shoes\"},\"value\":{\"jatum\\\\id\":23,\"type\":\"/datum/item_representation/boot\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/shoes/marine/full\"},\"boot_content\":{\"jatum\\\\id\":24,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/attachable/bayonetknife\"}}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_belt\"},\"value\":{\"jatum\\\\id\":25,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":26,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":27,\"type\":\"/datum/item_representation/stack\",\"amount\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/stack/medical/heal_pack/advanced/bruise_pack\"}}},{\"value\":{\"jatum\\\\id\":28,\"type\":\"/datum/item_representation/stack\",\"amount\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/stack/medical/heal_pack/advanced/bruise_pack\"}}},{\"value\":{\"jatum\\\\id\":29,\"type\":\"/datum/item_representation/stack\",\"amount\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/stack/medical/heal_pack/advanced/bruise_pack\"}}},{\"value\":{\"jatum\\\\id\":30,\"type\":\"/datum/item_representation/stack\",\"amount\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/stack/medical/heal_pack/advanced/burn_pack\"}}},{\"value\":{\"jatum\\\\id\":31,\"type\":\"/datum/item_representation/stack\",\"amount\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/stack/medical/heal_pack/advanced/burn_pack\"}}},{\"value\":{\"jatum\\\\id\":32,\"type\":\"/datum/item_representation/stack\",\"amount\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/stack/medical/heal_pack/advanced/burn_pack\"}}},{\"value\":{\"jatum\\\\id\":33,\"type\":\"/datum/item_representation/stack\",\"amount\":{\"type\":\"jatum\\\\raw\",\"value\":5},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/stack/medical/splint\"}}},{\"value\":{\"jatum\\\\id\":34,\"type\":\"/datum/item_representation/stack\",\"amount\":{\"type\":\"jatum\\\\raw\",\"value\":5},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/stack/medical/splint\"}}},{\"value\":{\"jatum\\\\id\":35,\"type\":\"/datum/item_representation/stack\",\"amount\":{\"type\":\"jatum\\\\raw\",\"value\":5},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/stack/medical/splint\"}}},{\"value\":{\"jatum\\\\id\":36,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pill_bottle/bicaridine\"}}},{\"value\":{\"jatum\\\\id\":37,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pill_bottle/kelotane\"}}},{\"value\":{\"jatum\\\\id\":38,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pill_bottle/dylovene\"}}},{\"value\":{\"jatum\\\\id\":39,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pill_bottle/tramadol\"}}},{\"value\":{\"jatum\\\\id\":40,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pill_bottle/tricordrazine\"}}},{\"value\":{\"jatum\\\\id\":41,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pill_bottle/inaprovaline\"}}},{\"value\":{\"jatum\\\\id\":42,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pill_bottle/peridaxon\"}}},{\"value\":{\"jatum\\\\id\":43,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pill_bottle/quickclot\"}}},{\"value\":{\"jatum\\\\id\":44,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/reagent_containers/hypospray/autoinjector/combat\"}}},{\"value\":{\"jatum\\\\id\":45,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/reagent_containers/hypospray/autoinjector/combat\"}}},{\"value\":{\"jatum\\\\id\":46,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus\"}}},{\"value\":{\"jatum\\\\id\":47,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/reagent_containers/hypospray/autoinjector/hypervene\"}}}\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/belt/medicLifesaver\"}}}\]}}}",
		("FC test loadoutSquad Marine") = "{\"jatum\\\\version\":1,\"content\":{\"jatum\\\\id\":1,\"type\":\"/datum/loadout\",\"name\":{\"type\":\"jatum\\\\raw\",\"value\":\"FC test loadout\"},\"version\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"job\":{\"type\":\"jatum\\\\raw\",\"value\":\"Squad Marine\"},\"item_list\":{\"jatum\\\\id\":2,\"type\":\"/list\",\"contents\":\[{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_head\"},\"value\":{\"jatum\\\\id\":3,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/head/tgmcberet/fc\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_back\"},\"value\":{\"jatum\\\\id\":4,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":5,\"type\":\"/list\",\"contents\":\[\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/backpack/marine/satchel\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_w_uniform\"},\"value\":{\"jatum\\\\id\":6,\"type\":\"/datum/item_representation/uniform_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/under/marine/officer/exec\"},\"attachments\":{\"jatum\\\\id\":7,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":8,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":9,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":10,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":11,\"type\":\"/datum/item_representation/armor_module\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_suit\"},\"value\":{\"jatum\\\\id\":12,\"type\":\"/datum/item_representation/modular_armor\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/suit/modular/xenonauten\"},\"current_variant\":{\"type\":\"jatum\\\\raw\",\"value\":\"black\"},\"attachments\":{\"jatum\\\\id\":13,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":14,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":15,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":16,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":17,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":18,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":19,\"type\":\"/datum/item_representation/armor_module\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_gloves\"},\"value\":{\"jatum\\\\id\":20,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/gloves/marine/officer\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_shoes\"},\"value\":{\"jatum\\\\id\":21,\"type\":\"/datum/item_representation/boot\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/shoes/marine/full\"},\"boot_content\":{\"jatum\\\\id\":22,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/attachable/bayonetknife\"}}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_s_store\"},\"value\":{\"jatum\\\\id\":23,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":24,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":25,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/ammo_magazine/pistol/m1911\"}}},{\"value\":{\"jatum\\\\id\":26,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/ammo_magazine/pistol/m1911\"}}},{\"value\":{\"jatum\\\\id\":27,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/ammo_magazine/pistol/m1911\"}}},{\"value\":{\"jatum\\\\id\":28,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/ammo_magazine/pistol/m1911\"}}},{\"value\":{\"jatum\\\\id\":29,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/ammo_magazine/pistol/m1911\"}}},{\"value\":{\"jatum\\\\id\":30,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/ammo_magazine/pistol/m1911\"}}},{\"value\":{\"jatum\\\\id\":31,\"type\":\"/datum/item_representation/gun\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/weapon/gun/pistol/m1911/custom\"},\"attachments\":{\"jatum\\\\id\":32,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":33,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":34,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":35,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":36,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":37,\"type\":\"/datum/item_representation/gun_attachement\"}}\]}}}\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/belt/gun/pistol/m4a3/fieldcommander\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_belt\"},\"value\":{\"jatum\\\\id\":38,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":39,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":40,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/weapon/claymore/mercsword/officersword\"}}}\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/holster/blade/officer/full\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_l_store\"},\"value\":{\"jatum\\\\id\":41,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/hud_tablet/fieldcommand\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_r_store\"},\"value\":{\"jatum\\\\id\":42,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":43,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":44,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/binoculars/tactical\"}}},{\"value\":{\"jatum\\\\id\":45,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/megaphone\"}}},{\"value\":{\"jatum\\\\id\":46,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/pinpointer\"}}}\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pouch/general/large/command\"}}}\]}}}",
		("culverin testSquad Marine") = "{\"jatum\\\\version\":1,\"content\":{\"jatum\\\\id\":1,\"type\":\"/datum/loadout\",\"name\":{\"type\":\"jatum\\\\raw\",\"value\":\"culverin test\"},\"version\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"job\":{\"type\":\"jatum\\\\raw\",\"value\":\"Squad Marine\"},\"item_list\":{\"jatum\\\\id\":2,\"type\":\"/list\",\"contents\":\[{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_head\"},\"value\":{\"jatum\\\\id\":3,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/head/tgmcberet/fc\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_back\"},\"value\":{\"jatum\\\\id\":4,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/cell/lasgun/volkite/powerpack\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_w_uniform\"},\"value\":{\"jatum\\\\id\":5,\"type\":\"/datum/item_representation/uniform_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/under/marine/officer/exec\"},\"attachments\":{\"jatum\\\\id\":6,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":7,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":8,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":9,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":10,\"type\":\"/datum/item_representation/armor_module\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_suit\"},\"value\":{\"jatum\\\\id\":11,\"type\":\"/datum/item_representation/modular_armor\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/suit/modular/xenonauten\"},\"current_variant\":{\"type\":\"jatum\\\\raw\",\"value\":\"black\"},\"attachments\":{\"jatum\\\\id\":12,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":13,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":14,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":15,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":16,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":17,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":18,\"type\":\"/datum/item_representation/armor_module\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_gloves\"},\"value\":{\"jatum\\\\id\":19,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/gloves/marine/officer\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_shoes\"},\"value\":{\"jatum\\\\id\":20,\"type\":\"/datum/item_representation/boot\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/shoes/marine/full\"},\"boot_content\":{\"jatum\\\\id\":21,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/attachable/bayonetknife\"}}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_s_store\"},\"value\":{\"jatum\\\\id\":22,\"type\":\"/datum/item_representation/gun\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin\"},\"attachments\":{\"jatum\\\\id\":23,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":24,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":25,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":26,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":27,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":28,\"type\":\"/datum/item_representation/gun_attachement\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_belt\"},\"value\":{\"jatum\\\\id\":29,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":30,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":31,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/weapon/claymore/mercsword/officersword\"}}}\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/holster/blade/officer/full\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_l_store\"},\"value\":{\"jatum\\\\id\":32,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/hud_tablet/fieldcommand\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_r_store\"},\"value\":{\"jatum\\\\id\":33,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":34,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":35,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/binoculars/tactical\"}}},{\"value\":{\"jatum\\\\id\":36,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/megaphone\"}}},{\"value\":{\"jatum\\\\id\":37,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/pinpointer\"}}}\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pouch/general/large/command\"}}}\]}}}",
		("somtest1SOM Standard") = "{\"jatum\\\\version\":1,\"content\":{\"jatum\\\\id\":1,\"type\":\"/datum/loadout\",\"name\":{\"type\":\"jatum\\\\raw\",\"value\":\"culverin test\"},\"version\":{\"type\":\"jatum\\\\raw\",\"value\":10},\"job\":{\"type\":\"jatum\\\\raw\",\"value\":\"SOM Standard\"},\"item_list\":{\"jatum\\\\id\":2,\"type\":\"/list\",\"contents\":\[{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_head\"},\"value\":{\"jatum\\\\id\":3,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/head/tgmcberet/fc\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_back\"},\"value\":{\"jatum\\\\id\":4,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/cell/lasgun/volkite/powerpack\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_w_uniform\"},\"value\":{\"jatum\\\\id\":5,\"type\":\"/datum/item_representation/uniform_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/under/marine/officer/exec\"},\"attachments\":{\"jatum\\\\id\":6,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":7,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":8,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":9,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":10,\"type\":\"/datum/item_representation/armor_module\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_suit\"},\"value\":{\"jatum\\\\id\":11,\"type\":\"/datum/item_representation/modular_armor\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/suit/modular/xenonauten\"},\"current_variant\":{\"type\":\"jatum\\\\raw\",\"value\":\"black\"},\"attachments\":{\"jatum\\\\id\":12,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":13,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":14,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":15,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":16,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":17,\"type\":\"/datum/item_representation/armor_module\"}},{\"value\":{\"jatum\\\\id\":18,\"type\":\"/datum/item_representation/armor_module\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_gloves\"},\"value\":{\"jatum\\\\id\":19,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/gloves/marine/officer\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_shoes\"},\"value\":{\"jatum\\\\id\":20,\"type\":\"/datum/item_representation/boot\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/clothing/shoes/marine/full\"},\"boot_content\":{\"jatum\\\\id\":21,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/attachable/bayonetknife\"}}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_s_store\"},\"value\":{\"jatum\\\\id\":22,\"type\":\"/datum/item_representation/gun\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin\"},\"attachments\":{\"jatum\\\\id\":23,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":24,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":25,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":26,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":27,\"type\":\"/datum/item_representation/gun_attachement\"}},{\"value\":{\"jatum\\\\id\":28,\"type\":\"/datum/item_representation/gun_attachement\"}}\]}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_belt\"},\"value\":{\"jatum\\\\id\":29,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":30,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":31,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/weapon/claymore/mercsword/officersword\"}}}\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/holster/blade/officer/full\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_l_store\"},\"value\":{\"jatum\\\\id\":32,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/hud_tablet/fieldcommand\"}}},{\"key\":{\"type\":\"jatum\\\\raw\",\"value\":\"slot_r_store\"},\"value\":{\"jatum\\\\id\":33,\"type\":\"/datum/item_representation/storage\",\"contents\":{\"jatum\\\\id\":34,\"type\":\"/list\",\"contents\":\[{\"value\":{\"jatum\\\\id\":35,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/binoculars/tactical\"}}},{\"value\":{\"jatum\\\\id\":36,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/megaphone\"}}},{\"value\":{\"jatum\\\\id\":37,\"type\":\"/datum/item_representation\",\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/pinpointer\"}}}\]},\"item_type\":{\"type\":\"jatum\\\\path\",\"path\":\"/obj/item/storage/pouch/general/large/command\"}}}\]}}}",
	)
	var/loadout_json = loadout_list["[loadout_name + loadout_job]"]
	if(!loadout_json)
		return FALSE
	var/datum/loadout/loadout = jatum_deserialize(loadout_json)
	return loadout
