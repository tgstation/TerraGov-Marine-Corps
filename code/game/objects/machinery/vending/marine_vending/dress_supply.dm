//Dress uniform vendor

/obj/machinery/vending/dress_supply
	name = "\improper TerraGovTech dress uniform vendor"
	desc = "An automated rack hooked up to a colossal storage of dress uniforms."
	icon_state = "marineuniform"
	icon_vend = "marineuniform_vend"
	icon_deny = "marineuniform"
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_CARGO)
	product_ads = "Hey! You! Stop looking like a turtle and start looking like a TRUE marine!;Dress whites, fresh off the ironing board!;Why kill in armor when you can kill in style?;These uniforms are so sharp you'd cut yourself just looking at them!"
	wrenchable = FALSE
	isshared = TRUE
	products = list(
		/obj/effect/vendor_bundle/white_dress = -1,
		/obj/item/clothing/under/marine/whites = -1,
		/obj/item/clothing/suit/white_dress_jacket = -1,
		/obj/item/clothing/head/white_dress = -1,
		/obj/item/clothing/shoes/white = -1,
		/obj/item/clothing/gloves/white = -1,
		/obj/effect/vendor_bundle/service_uniform = -1,
		/obj/item/clothing/under/marine/service = -1,
		/obj/item/clothing/head/garrisoncap = -1,
		/obj/item/clothing/head/servicecap = -1,
		/obj/item/clothing/under/marine/black_suit = -1,
	)

/obj/machinery/vending/dress_supply/valhalla
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE