/* Backpacks
 * Contains:
 *		Backpack
 *		Backpack Types
 *		Satchel Types
 */

/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "backpack"
	desc = ""
	icon_state = "backpack"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK	//ERROOOOO
	resistance_flags = NONE
	max_integrity = 300

/obj/item/storage/backpack/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 21
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_items = 21

/*
 * Backpack Types
 */

/obj/item/storage/backpack/old/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 12

/obj/item/storage/backpack/holding
	name = "bag of holding"
	desc = ""
	icon_state = "holdingpack"
	item_state = "holdingpack"
	resistance_flags = FIRE_PROOF
	item_flags = NO_MAT_REDEMPTION
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 50)
	component_type = /datum/component/storage/concrete/bluespace/bag_of_holding

/obj/item/storage/backpack/holding/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.allow_big_nesting = TRUE
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC
	STR.max_combined_w_class = 35

/obj/item/storage/backpack/holding/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is jumping into [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	user.dropItemToGround(src, TRUE)
	user.Stun(100, ignore_canstun = TRUE)
	sleep(20)
	playsound(src, "rustle", 50, TRUE, -5)
	qdel(user)

/obj/item/storage/backpack/holding/singularity_act(current_size)
	var/dist = max((current_size - 2),1)
	explosion(src.loc,(dist),(dist*2),(dist*4))

/obj/item/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = ""
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/backpack/santabag/Initialize()
	. = ..()
	regenerate_presents()

/obj/item/storage/backpack/santabag/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 60

/obj/item/storage/backpack/santabag/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] places [src] over [user.p_their()] head and pulls it tight! It looks like [user.p_they()] [user.p_are()]n't in the Christmas spirit...</span>")
	return (OXYLOSS)

/obj/item/storage/backpack/santabag/proc/regenerate_presents()
	addtimer(CALLBACK(src, .proc/regenerate_presents), rand(30 SECONDS, 60 SECONDS))

	var/mob/M = get(loc, /mob)
	if(!istype(M))
		return
	if(HAS_TRAIT(M, TRAIT_CANNOT_OPEN_PRESENTS))
		var/datum/component/storage/STR = GetComponent(/datum/component/storage)
		var/turf/floor = get_turf(src)
		var/obj/item/I = new /obj/item/a_gift/anything(floor)
		if(STR.can_be_inserted(I, stop_messages=TRUE))
			STR.handle_item_insertion(I, prevent_warning=TRUE)
		else
			qdel(I)


/obj/item/storage/backpack/cultpack
	name = "trophy rack"
	desc = ""
	icon_state = "cultpack"
	item_state = "backpack"

/obj/item/storage/backpack/clown
	name = "Giggles von Honkerton"
	desc = ""
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/storage/backpack/explorer
	name = "explorer bag"
	desc = ""
	icon_state = "explorerpack"
	item_state = "explorerpack"

/obj/item/storage/backpack/mime
	name = "Parcel Parceaux"
	desc = ""
	icon_state = "mimepack"
	item_state = "mimepack"

/obj/item/storage/backpack/medic
	name = "medical backpack"
	desc = ""
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = ""
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/storage/backpack/captain
	name = "captain's backpack"
	desc = ""
	icon_state = "captainpack"
	item_state = "captainpack"

/obj/item/storage/backpack/industrial
	name = "industrial backpack"
	desc = ""
	icon_state = "engiepack"
	item_state = "engiepack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/botany
	name = "botany backpack"
	desc = ""
	icon_state = "botpack"
	item_state = "botpack"

/obj/item/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = ""
	icon_state = "chempack"
	item_state = "chempack"

/obj/item/storage/backpack/genetics
	name = "genetics backpack"
	desc = ""
	icon_state = "genepack"
	item_state = "genepack"

/obj/item/storage/backpack/science
	name = "science backpack"
	desc = ""
	icon_state = "toxpack"
	item_state = "toxpack"

/obj/item/storage/backpack/virology
	name = "virology backpack"
	desc = ""
	icon_state = "viropack"
	item_state = "viropack"

/obj/item/storage/backpack/ert
	name = "emergency response team commander backpack"
	desc = ""
	icon_state = "ert_commander"
	item_state = "securitypack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = ""
	icon_state = "ert_security"

/obj/item/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = ""
	icon_state = "ert_medical"

/obj/item/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = ""
	icon_state = "ert_engineering"

/*
 * Satchel Types
 */

/obj/item/storage/backpack/satchel
	name = "satchel"
	desc = ""
	icon_state = "satchel-norm"
	item_state = "satchel-norm"

/obj/item/storage/backpack/satchel/leather
	name = "leather satchel"
	desc = ""
	icon_state = "satchel"
	item_state = "satchel"

/obj/item/storage/backpack/satchel/leather/withwallet/PopulateContents()
	new /obj/item/storage/wallet/random(src)

/obj/item/storage/backpack/satchel/fireproof
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel/eng
	name = "industrial satchel"
	desc = ""
	icon_state = "satchel-eng"
	item_state = "satchel-eng"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel/med
	name = "medical satchel"
	desc = ""
	icon_state = "satchel-med"
	item_state = "satchel-med"

/obj/item/storage/backpack/satchel/vir
	name = "virologist satchel"
	desc = ""
	icon_state = "satchel-vir"
	item_state = "satchel-vir"

/obj/item/storage/backpack/satchel/chem
	name = "chemist satchel"
	desc = ""
	icon_state = "satchel-chem"
	item_state = "satchel-chem"

/obj/item/storage/backpack/satchel/gen
	name = "geneticist satchel"
	desc = ""
	icon_state = "satchel-gen"
	item_state = "satchel-gen"

/obj/item/storage/backpack/satchel/tox
	name = "scientist satchel"
	desc = ""
	icon_state = "satchel-tox"
	item_state = "satchel-tox"

/obj/item/storage/backpack/satchel/hyd
	name = "botanist satchel"
	desc = ""
	icon_state = "satchel-hyd"
	item_state = "satchel-hyd"

/obj/item/storage/backpack/satchel/sec
	name = "security satchel"
	desc = ""
	icon_state = "satchel-sec"
	item_state = "satchel-sec"

/obj/item/storage/backpack/satchel/explorer
	name = "explorer satchel"
	desc = ""
	icon_state = "satchel-explorer"
	item_state = "satchel-explorer"

/obj/item/storage/backpack/satchel/cap
	name = "captain's satchel"
	desc = ""
	icon_state = "satchel-cap"
	item_state = "satchel-cap"

/obj/item/storage/backpack/satchel/flat
	name = "smuggler's satchel"
	desc = ""
	icon_state = "satchel-flat"
	item_state = "satchel-flat"
	w_class = WEIGHT_CLASS_NORMAL //Can fit in backpacks itself.
	level = 1

/obj/item/storage/backpack/satchel/flat/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 15
	STR.set_holdable(null, list(/obj/item/storage/backpack/satchel/flat)) //muh recursive backpacks)

/obj/item/storage/backpack/satchel/flat/hide(intact)
	if(intact)
		invisibility = INVISIBILITY_OBSERVER
		anchored = TRUE //otherwise you can start pulling, cover it, and drag around an invisible backpack.
		icon_state = "[initial(icon_state)]2"
		ADD_TRAIT(src, TRAIT_T_RAY_VISIBLE, TRAIT_GENERIC)
	else
		invisibility = initial(invisibility)
		anchored = FALSE
		icon_state = initial(icon_state)
		REMOVE_TRAIT(src, TRAIT_T_RAY_VISIBLE, TRAIT_GENERIC)

/obj/item/storage/backpack/satchel/flat/PopulateContents()
	var/datum/supply_pack/costumes_toys/randomised/contraband/C = new
	for(var/i in 1 to 2)
		var/ctype = pick(C.contains)
		new ctype(src)

	qdel(C)

/obj/item/storage/backpack/satchel/flat/with_tools/PopulateContents()
	new /obj/item/stack/tile/plasteel(src)
	new /obj/item/crowbar(src)

	..()

/obj/item/storage/backpack/satchel/flat/empty/PopulateContents()
	return

/obj/item/storage/backpack/duffelbag
	name = "duffel bag"
	desc = ""
	icon_state = "duffel"
	item_state = "duffel"
	slowdown = 1

/obj/item/storage/backpack/duffelbag/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 30

/obj/item/storage/backpack/duffelbag/captain
	name = "captain's duffel bag"
	desc = ""
	icon_state = "duffel-captain"
	item_state = "duffel-captain"

/obj/item/storage/backpack/duffelbag/med
	name = "medical duffel bag"
	desc = ""
	icon_state = "duffel-med"
	item_state = "duffel-med"

/obj/item/storage/backpack/duffelbag/med/surgery
	name = "surgical duffel bag"
	desc = ""

/obj/item/storage/backpack/duffelbag/med/surgery/PopulateContents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/razor(src)

/obj/item/storage/backpack/duffelbag/sec
	name = "security duffel bag"
	desc = ""
	icon_state = "duffel-sec"
	item_state = "duffel-sec"

/obj/item/storage/backpack/duffelbag/sec/surgery
	name = "surgical duffel bag"
	desc = ""

/obj/item/storage/backpack/duffelbag/sec/surgery/PopulateContents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/clothing/mask/surgical(src)

/obj/item/storage/backpack/duffelbag/engineering
	name = "industrial duffel bag"
	desc = ""
	icon_state = "duffel-eng"
	item_state = "duffel-eng"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/drone
	name = "drone duffel bag"
	desc = ""
	icon_state = "duffel-drone"
	item_state = "duffel-drone"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/drone/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)

/obj/item/storage/backpack/duffelbag/clown
	name = "clown's duffel bag"
	desc = ""
	icon_state = "duffel-clown"
	item_state = "duffel-clown"

/obj/item/storage/backpack/duffelbag/clown/cream_pie/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/reagent_containers/food/snacks/pie/cream(src)

/obj/item/storage/backpack/fireproof
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/syndie
	name = "suspicious looking duffel bag"
	desc = ""
	icon_state = "duffel-syndie"
	item_state = "duffel-syndieammo"
	slowdown = 0
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/syndie/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.silent = TRUE

/obj/item/storage/backpack/duffelbag/syndie/hitman
	desc = ""
	icon_state = "duffel-syndieammo"
	item_state = "duffel-syndieammo"

/obj/item/storage/backpack/duffelbag/syndie/hitman/PopulateContents()
	new /obj/item/clothing/under/suit/black(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/suit/toggle/lawyer/black(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/head/fedora(src)

/obj/item/storage/backpack/duffelbag/syndie/med
	name = "medical duffel bag"
	desc = ""
	icon_state = "duffel-syndiemed"
	item_state = "duffel-syndiemed"

/obj/item/storage/backpack/duffelbag/syndie/surgery
	name = "surgery duffel bag"
	desc = ""
	icon_state = "duffel-syndiemed"
	item_state = "duffel-syndiemed"

/obj/item/storage/backpack/duffelbag/syndie/surgery/PopulateContents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/clothing/mask/muzzle(src)
	new /obj/item/mmi/syndie(src)

/obj/item/storage/backpack/duffelbag/syndie/ammo
	name = "ammunition duffel bag"
	desc = ""
	icon_state = "duffel-syndieammo"
	item_state = "duffel-syndieammo"

/obj/item/storage/backpack/duffelbag/syndie/ammo/shotgun
	desc = ""

/obj/item/storage/backpack/duffelbag/syndie/ammo/shotgun/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g/slug(src)
	new /obj/item/ammo_box/magazine/m12g/slug(src)
	new /obj/item/ammo_box/magazine/m12g/dragon(src)

/obj/item/storage/backpack/duffelbag/syndie/ammo/smg
	desc = ""

/obj/item/storage/backpack/duffelbag/syndie/ammo/smg/PopulateContents()
	for(var/i in 1 to 9)
		new /obj/item/ammo_box/magazine/smgm45(src)

/obj/item/storage/backpack/duffelbag/syndie/ammo/dark_gygax
	desc = ""

/obj/item/storage/backpack/duffelbag/syndie/ammo/dark_gygax/PopulateContents()
	new /obj/item/mecha_ammo/incendiary(src)
	new /obj/item/mecha_ammo/incendiary(src)
	new /obj/item/mecha_ammo/incendiary(src)
	new /obj/item/mecha_ammo/flashbang(src)
	new /obj/item/mecha_ammo/flashbang(src)
	new /obj/item/mecha_ammo/flashbang(src)

/obj/item/storage/backpack/duffelbag/syndie/ammo/mauler
	desc = ""

/obj/item/storage/backpack/duffelbag/syndie/ammo/mauler/PopulateContents()
	new /obj/item/mecha_ammo/lmg(src)
	new /obj/item/mecha_ammo/lmg(src)
	new /obj/item/mecha_ammo/lmg(src)
	new /obj/item/mecha_ammo/scattershot(src)
	new /obj/item/mecha_ammo/scattershot(src)
	new /obj/item/mecha_ammo/scattershot(src)
	new /obj/item/mecha_ammo/missiles_he(src)
	new /obj/item/mecha_ammo/missiles_he(src)
	new /obj/item/mecha_ammo/missiles_he(src)

/obj/item/storage/backpack/duffelbag/syndie/c20rbundle
	desc = ""

/obj/item/storage/backpack/duffelbag/syndie/c20rbundle/PopulateContents()
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/gun/ballistic/automatic/c20r(src)
	new /obj/item/suppressor/specialoffer(src)

/obj/item/storage/backpack/duffelbag/syndie/bulldogbundle
	desc = ""

/obj/item/storage/backpack/duffelbag/syndie/bulldogbundle/PopulateContents()
	new /obj/item/gun/ballistic/shotgun/bulldog(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)

/obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle
	desc = ""

/obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle/PopulateContents()
	new /obj/item/clothing/shoes/magboots/syndie(src)
	new /obj/item/storage/firstaid/tactical(src)
	new /obj/item/gun/ballistic/automatic/l6_saw/toy(src)
	new /obj/item/ammo_box/foambox/riot(src)

/obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle
	desc = ""

/obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle/PopulateContents()
	new /obj/item/reagent_containers/spray/chemsprayer/bioterror(src)
	new /obj/item/storage/box/syndie_kit/chemical(src)
	new /obj/item/gun/syringe/syndicate(src)
	new /obj/item/gun/ballistic/automatic/c20r/toy(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/ammo_box/foambox/riot(src)
	new /obj/item/grenade/chem_grenade/bioterrorfoam(src)
	if(prob(5))
		new /obj/item/reagent_containers/food/snacks/pizza/pineapple(src)

/obj/item/storage/backpack/duffelbag/syndie/c4/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/grenade/c4(src)

/obj/item/storage/backpack/duffelbag/syndie/x4/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/grenade/c4/x4(src)

/obj/item/storage/backpack/duffelbag/syndie/firestarter
	desc = ""

/obj/item/storage/backpack/duffelbag/syndie/firestarter/PopulateContents()
	new /obj/item/clothing/under/syndicate/soviet(src)
	new /obj/item/watertank/op(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi/elite(src)
	new /obj/item/gun/ballistic/automatic/pistol/APS(src)
	new /obj/item/ammo_box/magazine/pistolm9mm(src)
	new /obj/item/ammo_box/magazine/pistolm9mm(src)
	new /obj/item/reagent_containers/food/drinks/bottle/vodka/badminka(src)
	new /obj/item/reagent_containers/hypospray/medipen/stimulants(src)
	new /obj/item/grenade/syndieminibomb(src)

// For ClownOps.
/obj/item/storage/backpack/duffelbag/clown/syndie/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	slowdown = 0
	STR.silent = TRUE

/obj/item/storage/backpack/duffelbag/clown/syndie/PopulateContents()
	new /obj/item/pda/clown(src)
	new /obj/item/clothing/under/rank/civilian/clown(src)
	new /obj/item/clothing/shoes/clown_shoes(src)
	new /obj/item/clothing/mask/gas/clown_hat(src)
	new /obj/item/bikehorn(src)
	new /obj/item/implanter/sad_trombone(src)
