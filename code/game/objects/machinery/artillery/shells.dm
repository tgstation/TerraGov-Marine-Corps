// Shells themselves //

/obj/item/mortal_shell
	name = "\improper 80mm mortar shell"
	desc = "An unlabeled 80mm mortar shell, probably a casing."
	icon = 'icons/obj/items/ammo/artillery.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/ammo_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/ammo_right.dmi',
	)
	icon_state = "mortar"
	w_class = WEIGHT_CLASS_SMALL
	atom_flags = CONDUCT
	///Ammo datum typepath that the shell uses
	var/ammo_type

/obj/item/mortal_shell/he
	name = "\improper 80mm high explosive mortar shell"
	desc = "An 80mm mortar shell, loaded with a high explosive charge."
	icon_state = "mortar_he"
	ammo_type = /datum/ammo/mortar

/obj/item/mortal_shell/incendiary
	name = "\improper 80mm incendiary mortar shell"
	desc = "An 80mm mortar shell, loaded with a napalm charge."
	icon_state = "mortar_inc"
	ammo_type = /datum/ammo/mortar/incend

/obj/item/mortal_shell/smoke
	name = "\improper 80mm smoke mortar shell"
	desc = "An 80mm mortar shell, loaded with smoke dispersal agents. Can be fired at marines more-or-less safely. Way slimmer than your typical 80mm."
	icon_state = "mortar_smk"
	ammo_type = /datum/ammo/mortar/smoke

/obj/item/mortal_shell/plasmaloss
	name = "\improper 80mm tangle mortar shell"
	desc = "An 80mm mortar shell, loaded with plasma-draining Tanglefoot gas. Can be fired at marines more-or-less safely."
	icon_state = "mortar_fsh"
	ammo_type = /datum/ammo/mortar/smoke/plasmaloss

/obj/item/mortal_shell/flare
	name = "\improper 80mm flare mortar shell"
	desc = "An 80mm mortar shell, loaded with an illumination flare, far slimmer than your typical 80mm shell. Can be fired out of larger cannons."
	icon_state = "mortar_flr"
	ammo_type = /datum/ammo/mortar/flare

/obj/item/mortal_shell/howitzer
	name = "\improper 150mm artillery shell"
	desc = "An unlabeled 150mm shell, probably a casing."
	icon_state = "howitzer"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/mortal_shell/howitzer/he
	name = "\improper 150mm high explosive artillery shell"
	desc = "An 150mm artillery shell, loaded with a high explosive charge, whatever is hit by this will have, A really, REALLY bad day."
	ammo_type = /datum/ammo/mortar/howi

/obj/item/mortal_shell/howitzer/plasmaloss
	name = "\improper 150mm 'Tanglefoot' artillery shell"
	desc = "An 150mm artillery shell, loaded with a toxic intoxicating gas, whatever is hit by this will have their abilities sapped slowly. Acommpanied by a small moderate explosion."
	icon_state = "howitzer_plasmaloss"
	ammo_type = /datum/ammo/mortar/smoke/howi/plasmaloss

/obj/item/mortal_shell/howitzer/incendiary
	name = "\improper 150mm incendiary artillery shell"
	desc = "An 150mm artillery shell, loaded with explosives to punch through light structures then burn out whatever is on the other side. Will ruin their day and skin."
	icon_state = "howitzer_incend"
	ammo_type = /datum/ammo/mortar/howi/incend

/obj/item/mortal_shell/howitzer/white_phos
	name = "\improper 150mm white phosporous 'spotting' artillery shell"
	desc = "An 150mm artillery shell, loaded with a 'spotting' gas that sets anything it hits aflame, whatever is hit by this will have their day, skin and future ruined, with a demand for a warcrime tribunal."
	icon_state = "howitzer_wp"
	ammo_type = /datum/ammo/mortar/smoke/howi/wp

/obj/item/mortal_shell/rocket
	ammo_type = /datum/ammo/mortar/rocket

/obj/item/mortal_shell/rocket/incend
	ammo_type = /datum/ammo/mortar/rocket/incend

/obj/item/mortal_shell/rocket/minelaying
	ammo_type = /datum/ammo/mortar/rocket/minelayer

/obj/item/mortal_shell/rocket/mlrs
	name = "\improper 60mm rocket"
	desc = "A 60mm rocket loaded with explosives, meant to be used in saturation fire with high scatter."
	icon_state = "mlrs"
	ammo_type = /datum/ammo/mortar/rocket/mlrs

/obj/item/mortal_shell/rocket/mlrs/gas
	name = "\improper 60mm 'X-50' rocket"
	desc = "A 60mm rocket loaded with deadly X-50 gas that drains the energy and life out of anything unfortunate enough to find itself inside of it."
	icon_state = "mlrs_gas"
	ammo_type = /datum/ammo/mortar/rocket/smoke/mlrs

/obj/item/mortal_shell/rocket/mlrs/cloak
	name = "\improper 60mm 'S-2' cloak rocket"
	desc = "A 60mm rocket loaded with cloak smoke that hides any friendlies inside of it with advanced chemical technology."
	icon_state = "mlrs_cloak"
	ammo_type = /datum/ammo/mortar/rocket/smoke/mlrs/cloak

/obj/item/mortal_shell/rocket/mlrs/incendiary
	name = "\improper 60mm incendiary rocket"
	desc = "A 60mm rocket loaded with an incendiary payload with a minor side of explosive."
	icon_state = "mlrs_incendiary"
	ammo_type = /datum/ammo/mortar/rocket/mlrs/incendiary

/obj/structure/closet/crate/mortar_ammo
	name = "\improper T-50S mortar ammo crate"
	desc = "A crate containing live mortar shells with various payloads. DO NOT DROP. KEEP AWAY FROM FIRE SOURCES."
	icon_state = "closed_mortar"
	icon_opened = "open_mortar"
	icon_closed = "closed_mortar"

/obj/structure/closet/crate/mortar_ammo/full/PopulateContents()
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke/sleep(src)
	new /obj/item/mortal_shell/smoke/sleep(src)
	new /obj/item/mortal_shell/smoke/satrapine(src)
	new /obj/item/mortal_shell/smoke/satrapine(src)
	new /obj/item/mortal_shell/smoke/aphrotox(src)
	new /obj/item/mortal_shell/smoke/aphrotox(src)
	new /obj/item/mortal_shell/smoke/neuro(src)
	new /obj/item/mortal_shell/smoke/neuro(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/razorburn(src)
	new /obj/item/mortal_shell/razorburn(src)
	new /obj/item/mortal_shell/metalfoam(src)
	new /obj/item/mortal_shell/metalfoam(src)

/obj/structure/closet/crate/mortar_ammo/mortar_kit
	name = "\improper TA-50S mortar kit"
	desc = "A crate containing a basic set of a mortar and some shells, to get an engineer started."

/obj/structure/closet/crate/mortar_ammo/mortar_kit/PopulateContents()
	new /obj/item/storage/holster/backholster/mortar/full(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke/sleep(src)
	new /obj/item/mortal_shell/smoke/sleep(src)
	new /obj/item/mortal_shell/smoke/sleep(src)
	new /obj/item/mortal_shell/smoke/sleep(src)
	new /obj/item/mortal_shell/smoke/sleep(src)
	new /obj/item/mortal_shell/smoke/satrapine(src)
	new /obj/item/mortal_shell/smoke/satrapine(src)
	new /obj/item/mortal_shell/smoke/aphrotox(src)
	new /obj/item/mortal_shell/smoke/aphrotox(src)
	new /obj/item/mortal_shell/smoke/aphrotox(src)
	new /obj/item/mortal_shell/smoke/aphrotox(src)
	new /obj/item/mortal_shell/smoke/aphrotox(src)
	new /obj/item/mortal_shell/smoke/neuro(src)
	new /obj/item/mortal_shell/smoke/neuro(src)
	new /obj/item/mortal_shell/smoke/neuro(src)
	new /obj/item/mortal_shell/smoke/neuro(src)
	new /obj/item/mortal_shell/smoke/neuro(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/razorburn(src)
	new /obj/item/mortal_shell/razorburn(src)
	new /obj/item/mortal_shell/metalfoam(src)
	new /obj/item/mortal_shell/metalfoam(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/binoculars/tactical/range(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/hud_tablet/artillery(src)


/obj/structure/closet/crate/mortar_ammo/howitzer_kit
	name = "\improper TA-100Y howitzer kit"
	desc = "A crate containing a basic, somehow compressed kit consisting of an entire howitzer and some shells, to get a artilleryman started."

/obj/structure/closet/crate/mortar_ammo/howitzer_kit/PopulateContents()
	new /obj/item/mortar_kit/howitzer(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new	/obj/item/mortal_shell/howitzer/plasmaloss(src)
	new	/obj/item/mortal_shell/howitzer/plasmaloss(src)
	new	/obj/item/mortal_shell/howitzer/plasmaloss(src)
	new	/obj/item/mortal_shell/howitzer/plasmaloss(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/binoculars/tactical/range(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/hud_tablet/artillery(src)


/obj/structure/closet/crate/mortar_ammo/mlrs_kit
	name = "\improper TA-40L MLRS kit"
	desc = "A crate containing a basic, somehow compressed kit consisting of an entire multiple launch rocket system and some rockets, to get a artilleryman started."

/obj/structure/closet/crate/mortar_ammo/mlrs_kit/PopulateContents()
	new /obj/item/mortar_kit/mlrs(src)
	new /obj/item/storage/box/mlrs_rockets(src)
	new /obj/item/storage/box/mlrs_rockets(src)
	new /obj/item/storage/box/mlrs_rockets(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/binoculars/tactical/range(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/hud_tablet/artillery(src)


/obj/item/storage/box/mlrs_rockets
	name = "\improper TA-40L rocket crate"
	desc = "A large case containing rockets in a compressed setting for the TA-40L MLRS. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."

/obj/item/storage/box/mlrs_rockets/Initialize(mapload)
	. = ..()
	storage_datum.storage_slots = 16

/obj/item/storage/box/mlrs_rockets/PopulateContents()
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)

/obj/item/storage/box/mlrs_rockets/gas
	name = "\improper TA-40L X-50 rocket crate"
	desc = "A large case containing rockets in a compressed setting for the TA-40L MLRS. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."

/obj/item/storage/box/mlrs_rockets/gas/Initialize(mapload)
	. = ..()
	storage_datum.storage_slots = 16

/obj/item/storage/box/mlrs_rockets/gas/PopulateContents()
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)

/obj/item/storage/box/mlrs_rockets/cloak
	name = "\improper TA-40L 'S-2' rocket crate"

/obj/item/storage/box/mlrs_rockets/cloak/PopulateContents()
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)
	new /obj/item/mortal_shell/rocket/mlrs/cloak(src)

/obj/item/storage/box/mlrs_rockets/incendiary
	name = "\improper TA-40L incendiary rocket crate"
	desc = "A large case containing rockets in a compressed setting for the TA-40L MLRS. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."

/obj/item/storage/box/mlrs_rockets/incendiary/Initialize(mapload)
	. = ..()
	storage_datum.storage_slots = 16

/obj/item/storage/box/mlrs_rockets/incendiary/PopulateContents()
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
	new /obj/item/mortal_shell/rocket/mlrs/incendiary(src)
