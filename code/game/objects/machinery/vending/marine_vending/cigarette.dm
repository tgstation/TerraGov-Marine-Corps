//Cigarette vendor

/obj/machinery/vending/cigarette
	name = "cigarette machine" //OCD had to be uppercase to look nice with the new formating
	desc = "A specialized vending machine designed to contribute to your slow and uncomfortable death."
	product_slogans = "There's no better time to start smokin'.;\
		Smoke now, and win the adoration of your peers.;\
		They beat cancer centuries ago, so smoke away.;\
		If you're not smoking, you must be joking.;\
		Probably not bad for you!;\
		Don't believe the scientists!;\
		It's good for you!;\
		Don't quit, buy more!;\
		Smoke!;\
		Nicotine heaven.;\
		Best cigarettes since 2150.;\
		Don't be so hard on yourself, kid. Smoke a Lucky Star!;\
		Professionals. Better cigarettes for better people. Yes, better people."
	icon_state = "cigs"
	icon_vend = "cigs-vend"
	icon_deny = "cigs-deny"
	wrenchable = FALSE
	isshared = TRUE
	products = list(
		/obj/item/storage/fancy/cigarettes/luckystars = -1,
		/obj/item/storage/fancy/chemrettes = -1,
		/obj/item/storage/box/matches = -1,
		/obj/item/tool/lighter/random = -1,
		/obj/item/tool/lighter/zippo = -1,
		/obj/item/clothing/mask/cigarette/cigar/havana = 5
	)

	premium = list(/obj/item/storage/fancy/cigar = 25)
	seasonal_items = list()

/obj/machinery/vending/cigarette/colony
	product_slogans = "Koorlander Gold, for the refined palate.;Lady Fingers, for the dainty smoker.;Lady Fingers, treat your palete with pink!;The big blue K means a cool fresh day!;For the taste that cools your mood, look for the big blue K!;Refined smokers go for Gold!;Lady Fingers are preferred by women who appreciate a cool smoke.;Lady Fingers are the number one cigarette this side of Gateway!;The tobacco connoisseur prefers Koorlander Gold.;For the cool, filtered feel, Lady Finger Cigarettes provide the smoothest draw of any cigarette on the market.;For the man who knows his place is at the top, Koorlander Gold shows the world that you're the best and no-one can say otherwise.;The Colonial Administration Bureau would like to remind you that smoking kills."
	product_ads = "For the taste that cools your mood, look for the big blue K!;Refined smokers go for Gold!;Lady Fingers are preferred by women who appreciate a cool smoke.;Lady Fingers are the number one cigarette this side of Gateway!;The tobacco connoisseur prefers Koorlander Gold.;For the cool, filtered feel, Lady Finger Cigarettes provide the smoothest draw of any cigarette on the market.;For the man who knows his place is at the top, Koorlander Gold shows the world that you're the best and no-one can say otherwise.;The Colonial Administration Bureau would like to remind you that smoking kills."
	products = list(
		/obj/item/storage/fancy/cigarettes/kpack = 15,
		/obj/item/storage/fancy/cigarettes/lady_finger = 15,
		/obj/item/storage/box/matches = 10,
		/obj/item/tool/lighter/random = 20,
	)

/obj/machinery/vending/cigarette/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/cigarette/valhalla
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE
	products = list(
		/obj/item/storage/fancy/cigarettes/luckystars = -1,
		/obj/item/storage/fancy/chemrettes = -1,
		/obj/item/storage/box/matches = -1,
		/obj/item/tool/lighter/random = -1,
		/obj/item/tool/lighter/zippo = -1,
		/obj/item/clothing/mask/cigarette/cigar/havana = -1,
		/obj/item/storage/fancy/cigar = -1,
	)
