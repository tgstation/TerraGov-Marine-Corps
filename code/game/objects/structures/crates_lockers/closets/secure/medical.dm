/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	desc = "Filled with medical items."
	icon_state = "secure_locked_medical_white"
	icon_closed = "secure_unlocked_medical_white"
	icon_locked = "secure_locked_medical_white"
	icon_opened = "secure_open_medical_white"
	icon_broken = "secure_closed_medical_white"
	icon_off = "secure_closed_medical_white"
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/structure/closet/secure_closet/medical1/PopulateContents()
	. = ..()
	new /obj/item/storage/box/autoinjectors(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/bottle/inaprovaline(src)
	new /obj/item/reagent_containers/glass/bottle/inaprovaline(src)
	new /obj/item/reagent_containers/glass/bottle/dylovene(src)
	new /obj/item/reagent_containers/glass/bottle/dylovene(src)
	new /obj/item/reagent_containers/glass/bottle/spaceacillin(src)
	new /obj/item/reagent_containers/glass/bottle/kelotane(src)
	new /obj/item/storage/box/pillbottles(src)

/obj/structure/closet/secure_closet/medical1/colony
	req_access = list(ACCESS_CIVILIAN_PUBLIC)

/obj/structure/closet/secure_closet/medical2
	name = "anesthetic closet"
	desc = "Used to knock people out."
	icon_state = "secure_locked_medical_white"
	icon_closed = "secure_unlocked_medical_white"
	icon_locked = "secure_locked_medical_white"
	icon_opened = "secure_open_medical_white"
	icon_broken = "secure_closed_medical_white"
	icon_off = "secure_closed_medical_white"
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/structure/closet/secure_closet/medical2/PopulateContents()
	. = ..()
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)

/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	req_access = list(ACCESS_MARINE_MEDBAY)
	icon_state = "secure_locked_medical_white"
	icon_closed = "secure_unlocked_medical_white"
	icon_locked = "secure_locked_medical_white"
	icon_opened = "secure_open_medical_white"
	icon_broken = "secure_closed_medical_white"
	icon_off = "secure_closed_medical_white"

/obj/structure/closet/secure_closet/medical3/PopulateContents()
	. = ..()
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/storage/belt/lifesaver/full(src)
	new /obj/item/storage/backpack/marine/satchel(src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/suit/surgical(src)
	new /obj/item/clothing/suit/surgical(src)
	new /obj/item/storage/box/trampop(src)
	if(is_mainship_level(z))
		new /obj/item/radio/headset/mainship/doc(src)

/obj/structure/closet/secure_closet/medical3/colony
	req_access = list(ACCESS_CIVILIAN_PUBLIC)

/obj/structure/closet/secure_closet/CMO
	name = "chief medical officer's locker"
	req_access = list(ACCESS_MARINE_CMO)
	icon_state = "cmosecure1"
	icon_closed = "cmosecure"
	icon_locked = "cmosecure1"
	icon_opened = "cmosecureopen"
	icon_broken = "cmosecurebroken"
	icon_off = "cmosecureoff"

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	. = ..()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/latex(src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/head/cmo(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/flash(src)
	new /obj/item/clothing/suit/surgical(src)
	new /obj/item/storage/box/trampop(src)



/obj/structure/closet/secure_closet/animal
	name = "animal control closet"
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/structure/closet/secure_closet/animal/PopulateContents()
	. = ..()
	new /obj/item/assembly/signaler(src)
	new /obj/item/electropack(src)
	new /obj/item/electropack(src)
	new /obj/item/electropack(src)



/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "secure_locked_medical_white"
	icon_closed = "secure_unlocked_medical_white"
	icon_locked = "secure_locked_medical_white"
	icon_opened = "secure_open_medical_white"
	icon_broken = "secure_closed_medical_white"
	icon_off = "secure_closed_medical_white"
	req_access = list(ACCESS_MARINE_CHEMISTRY)

/obj/structure/closet/secure_closet/chemical/PopulateContents()
	. = ..()
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/pillbottles(src)

/obj/structure/closet/secure_closet/chemical/colony
	req_access = list(ACCESS_CIVILIAN_PUBLIC)

