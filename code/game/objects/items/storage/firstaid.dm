/* First aid storage
* Contains:
*		First Aid Kits
* 		Pill Bottles
*/

/*
* First Aid Kits
*/
/obj/item/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 8
	cant_hold = list(
		/obj/item/ammo_magazine,
		/obj/item/explosive/grenade,
	)
	///Icon state to use when the kit is full
	var/icon_full
	///A list of all possible icon states when we're full
	var/list/possible_icons_full

/obj/item/storage/firstaid/update_icon()
	if(!contents.len)
		icon_state = "kit_empty"
	else
		icon_state = icon_full

/obj/item/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"
	possible_icons_full = list("ointment","firefirstaid")
	spawns_with = list(
		/obj/item/healthanalyzer,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/storage/pill_bottle/tramadol,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/storage/pill_bottle/packet/leporazine,
		/obj/item/storage/syringe_case/burn,
	)

/obj/item/storage/firstaid/regular
	icon_state = "firstaid"
	spawns_with = list(
		/obj/item/healthanalyzer,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine,
		/obj/item/reagent_containers/hypospray/autoinjector/tramadol,
		/obj/item/stack/medical/splint,
		/obj/item/storage/pill_bottle/packet/russian_red,
	)

/obj/item/storage/firstaid/toxin
	name = "toxin first aid"
	desc = "Used to treat when you have a high amount of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"
	possible_icons_full = list("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")
	spawns_with = list(
		/obj/item/healthanalyzer,
		/obj/item/storage/pill_bottle/dylovene,
		/obj/item/storage/pill_bottle/peridaxon,
		/obj/item/storage/pill_bottle/packet/ryetalyn,
		/obj/item/reagent_containers/hypospray/autoinjector/hypervene,
		/obj/item/reagent_containers/hypospray/autoinjector/hypervene,
		/obj/item/storage/syringe_case/tox,
	)

/obj/item/storage/firstaid/o2
	name = "oxygen deprivation first aid"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"
	spawns_with = list(
		/obj/item/healthanalyzer,
		/obj/item/storage/pill_bottle/dexalin = 1,
		/obj/item/storage/pill_bottle/inaprovaline = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = 3,
		/obj/item/storage/syringe_case/oxy = 1,
	)

/obj/item/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"
	spawns_with = list(
		/obj/item/healthanalyzer,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/storage/pill_bottle/tramadol,
		/obj/item/stack/medical/splint,
	)

/obj/item/storage/firstaid/rad
	name = "radiation first-aid kit"
	desc = "Contains treatment for radiation exposure"
	icon_state = "purplefirstaid"
	item_state = "firstaid-rad"
	spawns_with = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/pill_bottle/russian_red = 1,
		/obj/item/storage/pill_bottle/dylovene = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = 2,
	)

/**
 * Syringe Case
**/

/obj/item/storage/syringe_case
	name = "syringe case"
	desc = "It's a medical case for storing syringes and bottles."
	icon_state = "syringe_case"
	throw_speed = 2
	throw_range = 8
	storage_slots = 3
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/paper,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray/autoinjector,
	)

/obj/item/storage/syringe_case/regular
	name = "basic syringe case"
	desc = "It's a medical case for storing syringes and bottles. This one contains basic meds."

/obj/item/storage/syringe_case/regular/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/inaprovaline(src)
	new /obj/item/reagent_containers/glass/bottle/tricordrazine(src)

/obj/item/storage/syringe_case/burn
	name = "burn syringe case"
	desc = "It's a medical case for storing syringes and bottles. This one contains meds designed to treat burns."

/obj/item/storage/syringe_case/burn/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/kelotane(src)
	new /obj/item/reagent_containers/glass/bottle/oxycodone(src)

/obj/item/storage/syringe_case/tox
	name = "toxins syringe case"
	desc = "It's a medical case for storing syringes and bottles. This one contains meds designed to treat toxins."

/obj/item/storage/syringe_case/tox/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/dylovene(src)
	new /obj/item/reagent_containers/glass/bottle/hypervene(src)

/obj/item/storage/syringe_case/oxy
	name = "oxyloss syringe case"
	desc = "It's a medical case for storing syringes and bottles. This one contains meds designed to treat oxygen deprivation."

/obj/item/storage/syringe_case/oxy/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/inaprovaline(src)
	new /obj/item/reagent_containers/glass/bottle/dexalin(src)

/obj/item/storage/syringe_case/meralyne
	name = "syringe case (meralyne)"
	desc = "It's a medical case for storing syringes and bottles. This one contains Meralyne."

/obj/item/storage/syringe_case/meralyne/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/meralyne(src)
	new /obj/item/reagent_containers/glass/bottle/meralyne(src)

/obj/item/storage/syringe_case/dermaline
	name = "syringe case (dermaline)"
	desc = "It's a medical case for storing syringes and bottles. This one contains Dermaline."

/obj/item/storage/syringe_case/dermaline/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/dermaline(src)
	new /obj/item/reagent_containers/glass/bottle/dermaline(src)

/obj/item/storage/syringe_case/meraderm
	name = "syringe case (meraderm)"
	desc = "It's a medical case for storing syringes and bottles. This one contains Meraderm."

/obj/item/storage/syringe_case/meraderm/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/meraderm(src)
	new /obj/item/reagent_containers/glass/bottle/meraderm(src)

/obj/item/storage/syringe_case/nanoblood
	name = "syringe case (nanoblood)"
	desc = "It's a medical case for storing syringes and bottles. This one contains nanoblood."

/obj/item/storage/syringe_case/nanoblood/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/nanoblood(src)
	new /obj/item/reagent_containers/glass/bottle/nanoblood(src)

/obj/item/storage/syringe_case/tricordrazine
	name = "syringe case (tricordrazine)"
	desc = "It's a medical case for storing syringes and bottles. This one contains Tricordrazine."
	spawns_with = list(
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/reagent_containers/glass/bottle/tricordrazine = 2,
	)

/obj/item/storage/syringe_case/combat
	name = "syringe case (combat)"
	desc = "It's a medical case for storing syringes and bottles. This one contains combat autoinjectors."
	spawns_with = list(/obj/item/reagent_containers/hypospray/autoinjector/combat = 3)

/*
* Pill Bottles
*/

/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister1"
	icon = 'icons/obj/items/chemistry.dmi'
	item_state = "contsolid"
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/reagent_containers/pill,
		/obj/item/toy/dice,
		/obj/item/paper,
	)
	allow_quick_gather = 1
	use_to_pickup = 1
	storage_slots = null
	use_sound = 'sound/items/pillbottle.ogg'
	max_storage_space = 16

/obj/item/storage/pill_bottle/attack_self(mob/living/user)
	if(user.get_inactive_held_item())
		to_chat(user, "<span class='warning'>You need an empty hand to take out a pill.</span>")
		return
	if(contents.len)
		var/obj/item/item = contents[1]
		if(!remove_from_storage(item,user,user))
			return
		if(user.put_in_inactive_hand(item))
			to_chat(user, "<span class='notice'>You take a pill out of \the [src].</span>")
			playsound(user, 'sound/items/pills.ogg', 15, 1)
			if(iscarbon(user))
				var/mob/living/carbon/carbon = user
				carbon.swap_hand()
		else
			user.dropItemToGround(item)
			to_chat(user, "<span class='notice'>You fumble around with \the [src] and drop a pill on the floor.</span>")
		return
	else
		to_chat(user, "<span class='warning'>\The [src] is empty.</span>")
		return

/obj/item/storage/pill_bottle/kelotane
	name = "kelotane pill bottle"
	desc = "Contains pills that heal burns, but cause slight pain. Take two to heal faster, but have slightly more pain."
	icon_state = "pill_canister2"
	spawns_with = list(/obj/item/reagent_containers/pill/kelotane = 16)

/obj/item/storage/pill_bottle/dermaline
	name = "dermaline pill bottle"
	desc = "Contains pills that heal burns, but cause slight pain. Take two to heal faster, but have slightly more pain."
	icon_state = "pill_canister2"
	spawns_with = list(/obj/item/reagent_containers/pill/dermaline = 16)

/obj/item/storage/pill_bottle/dylovene
	name = "dylovene pill bottle"
	desc = "Contains pills that heal toxic damage and purge toxins and neurotoxins of all kinds."
	icon_state = "pill_canister6"
	spawns_with = list(/obj/item/reagent_containers/pill/dylovene = 16)

/obj/item/storage/pill_bottle/inaprovaline
	name = "inaprovaline pill bottle"
	desc = "Contains pills that prevent wounds from getting worse on their own."
	icon_state = "pill_canister3"
	spawns_with = list(/obj/item/reagent_containers/pill/inaprovaline = 16)

/obj/item/storage/pill_bottle/tramadol
	name = "tramadol pill bottle"
	desc = "Contains pills that numb pain. Take two for a stronger effect at the cost of a toxic effect."
	icon_state = "pill_canister5"
	spawns_with = list(/obj/item/reagent_containers/pill/tramadol = 16)

/obj/item/storage/pill_bottle/paracetamol
	name = "paracetamol pill bottle"
	desc = "Contains pills that mildly numb pain. Take two for a slightly stronger effect."
	icon_state = "pill_canister5"
	spawns_with = list(/obj/item/reagent_containers/pill/paracetamol = 16)

/obj/item/storage/pill_bottle/spaceacillin
	name = "spaceacillin pill bottle"
	desc = "Contains pills that handle low-level viral and bacterial infections. Effect increases with dosage."
	icon_state = "pill_canister4"
	spawns_with = list(/obj/item/reagent_containers/pill/spaceacillin = 16)

/obj/item/storage/pill_bottle/bicaridine
	name = "bicaridine pill bottle"
	desc = "Contains pills that heal cuts and bruises, but cause slight pain. Take two to heal faster, but have slightly more pain."
	icon_state = "pill_canister11"
	spawns_with = list(/obj/item/reagent_containers/pill/bicaridine = 16)

/obj/item/storage/pill_bottle/meralyne
	name = "meralyne pill bottle"
	desc = "Contains pills that heal cuts and bruises, but cause slight pain. Take two to heal faster, but have slightly more pain."
	icon_state = "pill_canister11"
	spawns_with = list(/obj/item/reagent_containers/pill/meralyne = 16)

/obj/item/storage/pill_bottle/dexalin
	name = "dexalin pill bottle"
	desc = "Contains pills that heal oxygen damage. They can suppress bloodloss symptoms as well."
	icon_state = "pill_canister12"
	spawns_with = list(/obj/item/reagent_containers/pill/dexalin = 16)

/obj/item/storage/pill_bottle/alkysine
	name = "alkysine pill bottle"
	desc = "Contains pills that heal brain damage."
	icon_state = "pill_canister7"
	spawns_with = list(/obj/item/reagent_containers/pill/alkysine = 16)

/obj/item/storage/pill_bottle/imidazoline
	name = "imidazoline pill bottle"
	desc = "Contains pills that heal eye damage."
	icon_state = "pill_canister9"
	spawns_with = list(/obj/item/reagent_containers/pill/imidazoline = 16)

/obj/item/storage/pill_bottle/peridaxon
	name = "peridaxon pill bottle"
	desc = "Contains pills that suppress organ damage while waiting for a full treatment."
	icon_state = "pill_canister10"
	spawns_with = list(/obj/item/reagent_containers/pill/peridaxon = 16)

/obj/item/storage/pill_bottle/russian_red
	name = "\improper Russian Red pill bottle"
	desc = "Contains pills that heal all damage rapidly at the cost of small amounts of unhealable damage."
	icon_state = "pill_canister1"
	spawns_with = list(/obj/item/reagent_containers/pill/russian_red = 16)

/obj/item/storage/pill_bottle/quickclot
	name = "quick-clot pill bottle"
	desc = "Contains pills that suppress internal bleeding while waiting for full treatment."
	icon_state = "pill_canister8"
	spawns_with = list(/obj/item/reagent_containers/pill/quickclot = 16)

/obj/item/storage/pill_bottle/hypervene
	name = "hypervene pill bottle"
	desc = "A purge medication used to treat overdoses and rapidly remove toxins. Causes pain and vomiting."
	icon_state = "pill_canister7"
	spawns_with = list(/obj/item/reagent_containers/pill/hypervene = 16)

/obj/item/storage/pill_bottle/tricordrazine
	name = "tricordrazine pill bottle"
	desc = "Contains pills commonly used by untrained Squad Marines to avoid seeing their Squad Medic."
	icon_state = "pill_canister9"
	spawns_with = list(/obj/item/reagent_containers/pill/tricordrazine = 16)

/obj/item/storage/pill_bottle/happy
	name = "happy pill bottle"
	desc = "Contains highly illegal drugs. When you want to see the rainbow."
	max_storage_space = 7
	spawns_with = list(/obj/item/reagent_containers/pill/happy = 7)

/obj/item/storage/pill_bottle/zoom
	name = "zoom pill bottle"
	desc = "Containts highly illegal drugs. Trade heart for speed."
	max_storage_space = 7
	spawns_with = list(/obj/item/reagent_containers/pill/zoom = 7)

//Pill bottles with identification locks.

/obj/item/storage/pill_bottle/restricted
	var/req_id_role
	var/scan_name = FALSE
	var/req_role

///Checks to see if the user has access to our contents
/obj/item/storage/pill_bottle/restricted/proc/scan(mob/living/living)

	if(living.status_flags & GODMODE) //Let it be
		return TRUE

	if(!allowed(living))
		to_chat(living, "<span class='notice'>It seems to have some kind of ID lock...</span>")
		return FALSE

	if(req_id_role || scan_name)
		var/obj/item/card/id/idcard = living.get_idcard()
		if(!idcard)
			to_chat(living, "<span class='notice'>It seems to have some kind of ID lock...</span>")
			return FALSE

		if(scan_name && (idcard.registered_name != living.real_name))
			to_chat(living, "<span class='warning'>it seems to have some kind of ID lock...</span>")
			return FALSE

		if(req_id_role && (idcard.rank != req_id_role))
			to_chat(living, "<span class='notice'>It must have some kind of ID lock...</span>")
			return FALSE

	if(req_role && (!living.job || living.job.title != req_role))
		to_chat(living, "<span class='notice'>It must have some kind of special lock...</span>")
		return FALSE

	return TRUE

/obj/item/storage/pill_bottle/restricted/attack_self(mob/living/user)
	if(scan(user))
		return ..()

/obj/item/storage/pill_bottle/restricted/open(mob/user)
	if(scan(user))
		return ..()

/obj/item/storage/pill_bottle/restricted/ultrazine
	icon_state = "pill_canister11"
	max_storage_space = 5
	spawns_mult = 5
	spawns_with = list(/obj/item/reagent_containers/pill/ultrazine)

	req_access = list(ACCESS_NT_CORPORATE)
	req_id_role = CORPORATE_LIAISON
	scan_name = TRUE
