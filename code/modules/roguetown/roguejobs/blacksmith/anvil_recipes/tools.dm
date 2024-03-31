/datum/anvil_recipe/tools/torch
	name = "iron torches (+c)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/rogueore/coal)
	created_item = list(/obj/item/flashlight/flare/torch/metal,
						/obj/item/flashlight/flare/torch/metal,
						/obj/item/flashlight/flare/torch/metal,
						/obj/item/flashlight/flare/torch/metal,
						/obj/item/flashlight/flare/torch/metal)

/datum/anvil_recipe/tools/pan
	name = "Frypan"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/cooking/pan

/datum/anvil_recipe/tools/keyring
	name = "Keyrings"
	req_bar = /obj/item/ingot/iron
	created_item = list(/obj/item/keyring,
						/obj/item/keyring,
						/obj/item/keyring)

/datum/anvil_recipe/tools/needle
	name = "Sewing Needles"
	req_bar = /obj/item/ingot/iron
	created_item = list(/obj/item/needle,
						/obj/item/needle,
						/obj/item/needle,
						/obj/item/needle,
						/obj/item/needle)

/datum/anvil_recipe/tools/shovel
	name = "shovel (+2s)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/grown/log/tree/stick,/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/shovel

/datum/anvil_recipe/tools/hammer
	name = "hammer (+s)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/hammer

/datum/anvil_recipe/tools/tongs
	name = "tongs"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/rogueweapon/tongs

/datum/anvil_recipe/tools/sickle
	name = "sickle (+s)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/sickle

/datum/anvil_recipe/tools/pick
	name = "pick (+s)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/pick

/datum/anvil_recipe/tools/hoe
	name = "hoe (+2s)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/grown/log/tree/stick,/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/hoe

/datum/anvil_recipe/tools/pitchfork
	name = "pitchfork (+2s)"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/grown/log/tree/stick,/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/pitchfork

/datum/anvil_recipe/tools/lamptern
	name = "lamptern"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/flashlight/flare/torch/lantern

/datum/anvil_recipe/tools/cups
	name = "iron cups"
	req_bar = /obj/item/ingot/iron
	created_item = list(/obj/item/reagent_containers/glass/cup,
						/obj/item/reagent_containers/glass/cup,
						/obj/item/reagent_containers/glass/cup)

/datum/anvil_recipe/tools/cupssteel
	name = "steel goblets"
	req_bar = /obj/item/ingot/steel
	created_item = list(/obj/item/reagent_containers/glass/cup/steel,
						/obj/item/reagent_containers/glass/cup/steel,
						/obj/item/reagent_containers/glass/cup/steel)

/datum/anvil_recipe/tools/cupssil
	name = "silver goblets"
	req_bar = /obj/item/ingot/silver
	created_item = list(/obj/item/reagent_containers/glass/cup/silver,
						/obj/item/reagent_containers/glass/cup/silver,
						/obj/item/reagent_containers/glass/cup/silver)

/datum/anvil_recipe/tools/cupsgold
	name = "golden goblets"
	req_bar = /obj/item/ingot/gold
	created_item = list(/obj/item/reagent_containers/glass/cup/golden,
						/obj/item/reagent_containers/glass/cup/golden,
						/obj/item/reagent_containers/glass/cup/golden)

/datum/anvil_recipe/tools/cogstee
	name = "steel cog"
	req_bar = /obj/item/ingot/steel
	created_item = list(/obj/item/roguegear,
						/obj/item/roguegear,
						/obj/item/roguegear)

/datum/anvil_recipe/tools/cogiron
	name = "iron cog"
	req_bar = /obj/item/ingot/iron
	created_item = list(/obj/item/roguegear,
						/obj/item/roguegear,
						/obj/item/roguegear)
