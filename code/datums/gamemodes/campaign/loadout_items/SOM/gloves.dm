/datum/loadout_item/gloves/som_gloves
	name = "SOM gloves"
	desc = "Gloves with origins dating back to the old mining colonies, they look pretty tough."
	item_typepath = /obj/item/clothing/gloves/marine/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/gloves/som_veteran_gloves
	name = "Veteran gloves"
	desc = "Gloves with origins dating back to the old mining colonies. These ones seem tougher than normal."
	item_typepath = /obj/item/clothing/gloves/marine/som/veteran
	jobs_supported = list(SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/gloves/som_insulated
	name = "Insulated gloves"
	desc = "Gloves with origins dating back to the old mining colonies. These ones appear to have an electrically insulating layer built into them."
	item_typepath = /obj/item/clothing/gloves/marine/som/insulated
	jobs_supported = list(SOM_SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/gloves/som_officer_gloves
	name = "Officer gloves"
	desc = "Black gloves commonly worn by SOM officers."
	item_typepath = /obj/item/clothing/gloves/marine/som/officer
	jobs_supported = list(SOM_FIELD_COMMANDER, SOM_STAFF_OFFICER, SOM_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

