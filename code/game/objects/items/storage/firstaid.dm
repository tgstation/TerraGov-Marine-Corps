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
	var/empty = FALSE //whether the kit starts empty
	var/icon_full //icon state to use when kit is full
	var/possible_icons_full

/obj/item/storage/firstaid/Initialize(mapload, ...)
	. = ..()
	if(possible_icons_full)
		icon_state = pick(possible_icons_full)
	icon_full = icon_state
	if(empty)
		icon_state = "kit_empty"
	else
		fill_firstaid_kit()


/obj/item/storage/firstaid/update_icon()
	if(!contents.len)
		icon_state = "kit_empty"
	else
		icon_state = icon_full


//to fill medkits with stuff when spawned
/obj/item/storage/firstaid/proc/fill_firstaid_kit()
	return


/obj/item/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"
	possible_icons_full = list("ointment","firefirstaid")

/obj/item/storage/firstaid/fire/fill_firstaid_kit()
	new /obj/item/healthanalyzer(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/storage/pill_bottle/packet/leporazine(src)
	new /obj/item/storage/syringe_case/burn(src)


/obj/item/storage/firstaid/regular
	icon_state = "firstaid"

/obj/item/storage/firstaid/regular/fill_firstaid_kit()
	new /obj/item/healthanalyzer(src)
	new /obj/item/stack/medical/heal_pack/gauze(src)
	new /obj/item/stack/medical/heal_pack/ointment(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tramadol(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/storage/pill_bottle/packet/russian_red(src)


/obj/item/storage/firstaid/toxin
	name = "toxin first aid"
	desc = "Used to treat when you have a high amount of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"
	possible_icons_full = list("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

/obj/item/storage/firstaid/toxin/fill_firstaid_kit()
	new /obj/item/healthanalyzer(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/packet/ryetalyn(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/hypervene(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/hypervene(src)
	new /obj/item/storage/syringe_case/tox(src)


/obj/item/storage/firstaid/o2
	name = "oxygen deprivation first aid"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"

/obj/item/storage/firstaid/o2/fill_firstaid_kit()
	new /obj/item/healthanalyzer(src)
	new /obj/item/storage/pill_bottle/dexalin(src)
	new /obj/item/storage/pill_bottle/inaprovaline(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/storage/syringe_case/oxy(src)


/obj/item/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"

/obj/item/storage/firstaid/adv/fill_firstaid_kit()
	new /obj/item/healthanalyzer(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/stack/medical/splint(src)


/obj/item/storage/firstaid/rad
	name = "radiation first-aid kit"
	desc = "Contains treatment for radiation exposure"
	icon_state = "purplefirstaid"
	item_state = "firstaid-rad"

/obj/item/storage/firstaid/rad/fill_firstaid_kit()
	new /obj/item/healthanalyzer(src)
	new /obj/item/storage/pill_bottle/russian_red(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine(src)


/*
* Syringe Case
*/

/obj/item/storage/syringe_case
	name = "syringe case"
	desc = "It's a medical case for storing syringes and bottles."
	icon_state = "syringe_case"
	throw_speed = 2
	throw_range = 8
	storage_slots = 3
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/syringe,
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

/obj/item/storage/syringe_case/tricordrazine/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/tricordrazine(src)
	new /obj/item/reagent_containers/glass/bottle/tricordrazine(src)

/*
* Bottle Cases
*/


/obj/item/storage/bottlecase
	name = "regeant bottle case"
	desc = "It's a medical case for only storing regeant bottles."
	icon_state = "syringe_case"
	throw_speed = 2
	throw_range = 8
	storage_slots = 3
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/glass/bottle,
	)

/obj/item/storage/bottlecase/bica
	name = "bicaridine bottle case"
	desc = "It's a medical case for storing three bicaridine bottles."
	icon_state = "bica_bottles_case"

/obj/item/storage/bottlecase/bica/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/glass/bottle/bicaridine(src)
	new /obj/item/reagent_containers/glass/bottle/bicaridine(src)
	new /obj/item/reagent_containers/glass/bottle/bicaridine(src)

/obj/item/storage/bottlecase/kelo
	name = "kelotane bottle case"
	desc = "It's a medical case for storing three kelotane bottles."
	icon_state = "kelo_bottles_case"

/obj/item/storage/bottlecase/kelo/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/glass/bottle/kelotane(src)
	new /obj/item/reagent_containers/glass/bottle/kelotane(src)
	new /obj/item/reagent_containers/glass/bottle/kelotane(src)

/obj/item/storage/bottlecase/dylo
	name = "dylovene bottle case"
	desc = "It's a medical case for storing three dylovene bottles."
	icon_state = "dylo_bottles_case"

/obj/item/storage/bottlecase/dylo/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/glass/bottle/dylovene(src)
	new /obj/item/reagent_containers/glass/bottle/dylovene(src)
	new /obj/item/reagent_containers/glass/bottle/dylovene(src)

/obj/item/storage/bottlecase/tram
	name = "tramadol bottle case"
	desc = "It's a medical case for storing three tramadol bottles."
	icon_state = "tram_bottles_case"

/obj/item/storage/bottlecase/tram/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/glass/bottle/tramadol(src)
	new /obj/item/reagent_containers/glass/bottle/tramadol(src)
	new /obj/item/reagent_containers/glass/bottle/tramadol(src)

/obj/item/storage/bottlecase/tricord
	name = "tricordrazine bottle case"
	desc = "It's a medical case for storing three tricordrazine bottles."
	icon_state = "tricord_bottles_case"

/obj/item/storage/bottlecase/tricord/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/glass/bottle/tricordrazine(src)
	new /obj/item/reagent_containers/glass/bottle/tricordrazine(src)
	new /obj/item/reagent_containers/glass/bottle/tricordrazine(src)

/obj/item/storage/bottlecase/dex
	name = "dexalin bottle case"
	desc = "It's a medical case for storing three dexalin bottles."
	icon_state = "dex_bottles_case"

/obj/item/storage/bottlecase/dex/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/glass/bottle/dexalin(src)
	new /obj/item/reagent_containers/glass/bottle/dexalin(src)
	new /obj/item/reagent_containers/glass/bottle/dexalin(src)


/*
* Pill Bottles
*/


/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
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
	greyscale_config = /datum/greyscale_config/pillbottle
	greyscale_colors = "#d9cd07#f2cdbb" //default colors
	var/pill_type_to_fill //type of pill to use to fill in the bottle in New()


/obj/item/storage/pill_bottle/Initialize(mapload, ...)
	. = ..()
	if(pill_type_to_fill)
		for(var/i in 1 to max_storage_space)
			new pill_type_to_fill(src)
	update_icon()

/obj/item/storage/pill_bottle/attack_self(mob/living/user)
	if(user.get_inactive_held_item())
		to_chat(user, span_warning("You need an empty hand to take out a pill."))
		return
	if(contents.len)
		var/obj/item/I = contents[1]
		if(!remove_from_storage(I,user,user))
			return
		if(user.put_in_inactive_hand(I))
			to_chat(user, span_notice("You take a pill out of \the [src]."))
			playsound(user, 'sound/items/pills.ogg', 15, 1)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.swap_hand()
		else
			user.dropItemToGround(I)
			to_chat(user, span_notice("You fumble around with \the [src] and drop a pill on the floor."))
		return
	else
		to_chat(user, span_warning("\The [src] is empty."))
		return

/obj/item/storage/pill_bottle/update_overlays()
	. = ..()
	if(isturf(loc))
		return
	var/mutable_appearance/number = mutable_appearance()
	number.maptext = MAPTEXT(length(contents))
	. += number

/obj/item/storage/pill_bottle/equipped(mob/user, slot)
	. = ..()
	update_icon()

/obj/item/storage/pill_bottle/removed_from_inventory()
	. = ..()
	update_icon()

/obj/item/storage/pill_bottle/kelotane
	name = "kelotane pill bottle"
	desc = "Contains pills that heal burns, but cause slight pain. Take two to heal faster, but have slightly more pain."
	pill_type_to_fill = /obj/item/reagent_containers/pill/kelotane
	greyscale_colors = "#CC9900#FFFFFF"

/obj/item/storage/pill_bottle/dermaline
	name = "dermaline pill bottle"
	desc = "Contains pills that heal burns, but cause slight pain. Take two to heal faster, but have slightly more pain."
	pill_type_to_fill = /obj/item/reagent_containers/pill/dermaline
	greyscale_config = /datum/greyscale_config/pillbottleround
	greyscale_colors = "#ffef00#FFFFFF"

/obj/item/storage/pill_bottle/dylovene
	name = "dylovene pill bottle"
	desc = "Contains pills that heal toxic damage and purge toxins and neurotoxins of all kinds."
	pill_type_to_fill = /obj/item/reagent_containers/pill/dylovene
	greyscale_colors = "#669900#ffffff"

/obj/item/storage/pill_bottle/inaprovaline
	name = "inaprovaline pill bottle"
	desc = "Contains pills that prevent wounds from getting worse on their own."
	pill_type_to_fill = /obj/item/reagent_containers/pill/inaprovaline
	greyscale_config = /datum/greyscale_config/pillbottlebox
	greyscale_colors = "#9966CC#ffffff"

/obj/item/storage/pill_bottle/tramadol
	name = "tramadol pill bottle"
	desc = "Contains pills that numb pain. Take two for a stronger effect at the cost of a toxic effect."
	pill_type_to_fill = /obj/item/reagent_containers/pill/tramadol
	greyscale_colors = "#a09ca0#ffffff"

/obj/item/storage/pill_bottle/paracetamol
	name = "paracetamol pill bottle"
	desc = "Contains pills that mildly numb pain. Take two for a slightly stronger effect."
	pill_type_to_fill = /obj/item/reagent_containers/pill/paracetamol
	greyscale_config = /datum/greyscale_config/pillbottlebox

/obj/item/storage/pill_bottle/spaceacillin
	name = "spaceacillin pill bottle"
	desc = "Contains pills that handle low-level viral and bacterial infections. Effect increases with dosage."
	pill_type_to_fill = /obj/item/reagent_containers/pill/spaceacillin
	greyscale_config = /datum/greyscale_config/pillbottlebox
	greyscale_colors = "#90F7F5#ffffff"

/obj/item/storage/pill_bottle/bicaridine
	name = "bicaridine pill bottle"
	desc = "Contains pills that heal cuts and bruises, but cause slight pain. Take two to heal faster, but have slightly more pain."
	pill_type_to_fill = /obj/item/reagent_containers/pill/bicaridine
	greyscale_colors = "#DA0000#ffffff"

/obj/item/storage/pill_bottle/meralyne
	name = "meralyne pill bottle"
	desc = "Contains pills that heal cuts and bruises, but cause slight pain. Take two to heal faster, but have slightly more pain."
	icon_state = "pill_canistercomplete"
	pill_type_to_fill = /obj/item/reagent_containers/pill/meralyne
	greyscale_config = /datum/greyscale_config/pillbottleround
	greyscale_colors = "#FD5964#ffffff"

/obj/item/storage/pill_bottle/dexalin
	name = "dexalin pill bottle"
	desc = "Contains pills that heal oxygen damage. They can suppress bloodloss symptoms as well."
	pill_type_to_fill = /obj/item/reagent_containers/pill/dexalin
	greyscale_colors = "#5972FD#ffffff"

/obj/item/storage/pill_bottle/alkysine
	name = "alkysine pill bottle"
	desc = "Contains pills that heal brain damage."
	icon_state = "pill_canistercomplete"
	pill_type_to_fill = /obj/item/reagent_containers/pill/alkysine
	greyscale_config = /datum/greyscale_config/pillbottlebubble
	greyscale_colors = "#0292AC#ffffff"

/obj/item/storage/pill_bottle/imidazoline
	name = "imidazoline pill bottle"
	desc = "Contains pills that heal eye damage."
	pill_type_to_fill = /obj/item/reagent_containers/pill/imidazoline
	greyscale_config = /datum/greyscale_config/pillbottlebubble
	greyscale_colors = "#F7A151#ffffff" //orange like carrots

/obj/item/storage/pill_bottle/russian_red
	name = "\improper Russian Red pill bottle"
	desc = "Contains pills that heal all damage rapidly at the cost of small amounts of unhealable damage."
	icon_state = "pill_canister"
	pill_type_to_fill = /obj/item/reagent_containers/pill/russian_red
	greyscale_colors = "#E07BAD#ffffff"

/obj/item/storage/pill_bottle/quickclot
	name = "quick-clot pill bottle"
	desc = "Contains pills that suppress internal bleeding while waiting for full treatment."
	icon_state = "pill_canistercomplete"
	pill_type_to_fill = /obj/item/reagent_containers/pill/quickclot
	greyscale_config = /datum/greyscale_config/pillbottleround
	greyscale_colors = "#5ed75e#ffffff"

/obj/item/storage/pill_bottle/hypervene
	name = "hypervene pill bottle"
	desc = "A purge medication used to treat overdoses and rapidly remove toxins. Causes pain and vomiting."
	icon_state = "pill_canister"
	pill_type_to_fill = /obj/item/reagent_containers/pill/hypervene
	greyscale_config = /datum/greyscale_config/pillbottlebubble
	greyscale_colors = "#AC6D32#ffffff"

/obj/item/storage/pill_bottle/tricordrazine
	name = "tricordrazine pill bottle"
	desc = "Contains pills capable of minorly healing all main types of damages."
	icon_state = "pill_canistercomplete"
	pill_type_to_fill = /obj/item/reagent_containers/pill/tricordrazine
	greyscale_config = /datum/greyscale_config/pillbottleround
	greyscale_colors = "#f8f4f8#ffffff"

/obj/item/storage/pill_bottle/happy
	name = "happy pill bottle"
	desc = "Contains highly illegal drugs. When you want to see the rainbow."
	max_storage_space = 7
	pill_type_to_fill = /obj/item/reagent_containers/pill/happy
	greyscale_colors = "#6C52BF#ffffff"

/obj/item/storage/pill_bottle/zoom
	name = "zoom pill bottle"
	desc = "Containts highly illegal drugs. Trade heart for speed."
	max_storage_space = 7
	pill_type_to_fill = /obj/item/reagent_containers/pill/zoom
	greyscale_colors = "#ef3ad4#ffffff"

/obj/item/storage/pill_bottle/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(!istype(I, /obj/item/facepaint) || isnull(greyscale_config))
		return

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, span_warning("\the [paint] is out of color!"))
		return
	var/bottle_color
	var/label_color
	bottle_color = input(user, "Pick a color", "Pick color") as null|color
	label_color = input(user, "Pick a color", "Pick color") as null|color

	if(!bottle_color || !label_color || !do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return


	set_greyscale_colors(list(bottle_color,label_color))
	paint.uses--
	update_icon()
