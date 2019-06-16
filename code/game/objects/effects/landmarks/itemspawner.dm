//Costume spawner landmarks
/obj/effect/landmark/itemspawner
	icon_state = "random_loot"
	var/list/items_to_spawn


/obj/effect/landmark/itemspawner/Initialize()
	for(var/path in items_to_spawn)
		new path(loc)
	. = INITIALIZE_HINT_QDEL


/obj/effect/landmark/itemspawner/chicken
	items_to_spawn = list(\
	/obj/item/clothing/suit/chickensuit,\
	/obj/item/clothing/head/chicken,\
	/obj/item/reagent_container/food/snacks/egg)


/obj/effect/landmark/itemspawner/gladiator
	items_to_spawn = list(\
	/obj/item/clothing/under/gladiator,\
	/obj/item/clothing/head/helmet/gladiator)


/obj/effect/landmark/itemspawner/madscientist
	items_to_spawn = list(\
	/obj/item/clothing/under/gimmick/rank/captain/suit,\
	/obj/item/clothing/head/flatcap,\
	/obj/item/clothing/suit/storage/labcoat/mad,\
	/obj/item/clothing/glasses/gglasses)


/obj/effect/landmark/itemspawner/elpresidente
	items_to_spawn = list(\
	/obj/item/clothing/under/gimmick/rank/captain/suit,\
	/obj/item/clothing/head/flatcap,\
	/obj/item/clothing/mask/cigarette/cigar/havana,\
	/obj/item/clothing/shoes/jackboots)


/obj/effect/landmark/itemspawner/nyangirl
	items_to_spawn = list(\
	/obj/item/clothing/under/schoolgirl,\
	/obj/item/clothing/head/kitty)


/obj/effect/landmark/itemspawner/maid
	items_to_spawn = list(\
	/obj/item/clothing/under/blackskirt,\
	/obj/item/clothing/head/rabbitears,\
	/obj/item/clothing/glasses/sunglasses/blindfold)


/obj/effect/landmark/itemspawner/butler
	items_to_spawn = list(\
	/obj/item/clothing/suit/wcoat,\
	/obj/item/clothing/under/suit_jacket,\
	/obj/item/clothing/head/that)


/obj/effect/landmark/itemspawner/scratch
	items_to_spawn = list(\
	/obj/item/clothing/gloves/white,\
	/obj/item/clothing/shoes/white,\
	/obj/item/clothing/under/scratch,\
	/obj/item/clothing/head/cueball)


/obj/effect/landmark/itemspawner/highlander
	items_to_spawn = list(\
	/obj/item/clothing/under/kilt,\
	/obj/item/clothing/head/beret)


/obj/effect/landmark/itemspawner/prig
	items_to_spawn = list(\
	/obj/item/clothing/suit/wcoat,\
	/obj/item/clothing/glasses/monocle,\
	/obj/item/clothing/head/that,\
	/obj/item/clothing/shoes/black,\
	/obj/item/cane,\
	/obj/item/clothing/under/sl_suit,\
	/obj/item/clothing/mask/fakemoustache)


/obj/effect/landmark/itemspawner/plaguedoctor
	items_to_spawn = list(\
	/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,\
	/obj/item/clothing/head/plaguedoctorhat)


/obj/effect/landmark/itemspawner/nightowl
	items_to_spawn = list(\
	/obj/item/clothing/under/owl,\
	/obj/item/clothing/mask/gas/owl_mask)


/obj/effect/landmark/itemspawner/waiter
	items_to_spawn = list(\
	/obj/item/clothing/under/waiter,\
	/obj/item/clothing/head/rabbitears,\
	/obj/item/clothing/suit/apron)


/obj/effect/landmark/itemspawner/pirate
	items_to_spawn = list(\
	/obj/item/clothing/under/pirate,\
	/obj/item/clothing/suit/pirate,\
	/obj/item/clothing/head/pirate,\
	/obj/item/clothing/glasses/eyepatch)


/obj/effect/landmark/itemspawner/commie
	items_to_spawn = list(\
	/obj/item/clothing/under/soviet,\
	/obj/item/clothing/head/ushanka)


/obj/effect/landmark/itemspawner/imperium_monk
	items_to_spawn = list(\
	/obj/item/clothing/suit/imperium_monk,\
	/obj/item/clothing/mask/gas/cyborg)


/obj/effect/landmark/itemspawner/holiday_priest
	items_to_spawn = list(\
	/obj/item/clothing/suit/holidaypriest)


/obj/effect/landmark/itemspawner/marisawizard/fake
	items_to_spawn = list(\
	/obj/item/clothing/head/wizard/marisa/fake,\
	/obj/item/clothing/suit/wizrobe/marisa/fake)


/obj/effect/landmark/itemspawner/cutewitch
	items_to_spawn = list(\
	/obj/item/clothing/under/sundress,\
	/obj/item/clothing/head/witchwig,\
	/obj/item/staff/broom)


/obj/effect/landmark/itemspawner/fakewizard
	items_to_spawn = list(\
	/obj/item/clothing/suit/wizrobe/fake,\
	/obj/item/clothing/head/wizard/fake,\
	/obj/item/staff)


/obj/effect/landmark/itemspawner/sexyclown
	items_to_spawn = list(\
	/obj/item/clothing/mask/gas/sexyclown,\
	/obj/item/clothing/under/sexyclown)


/obj/effect/landmark/itemspawner/sexymime
	items_to_spawn = list(\
	/obj/item/clothing/mask/gas/sexymime,\
	/obj/item/clothing/under/sexymime)