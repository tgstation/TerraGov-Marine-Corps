/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 */

/*
 * First Aid Kits
 */
/obj/item/weapon/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	cant_hold = list("/obj/item/ammo_magazine") //to prevent powergaming.
	var/empty = 0 //whether the kit starts empty
	var/icon_full //icon state to use when kit is full
	var/possible_icons_full

	New()
		..()
		if(possible_icons_full)
			icon_state = pick(possible_icons_full)
		icon_full = icon_state
		if(empty)
			icon_state = "kit_empty"
		else
			fill_firstaid_kit()


	update_icon()
		if(!contents.len)
			icon_state = "kit_empty"
		else
			icon_state = icon_full


//to fill medkits with stuff when spawned
/obj/item/weapon/storage/firstaid/proc/fill_firstaid_kit()
	return


/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"
	possible_icons_full = list("ointment","firefirstaid")

	fill_firstaid_kit()
		new /obj/item/device/healthanalyzer( src )
		new /obj/item/stack/medical/ointment( src )
		new /obj/item/stack/medical/ointment( src )
		new /obj/item/stack/medical/ointment( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/storage/syringe_case/burn( src )



/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

	fill_firstaid_kit()
		new /obj/item/device/healthanalyzer(src)
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/ointment(src)
		new /obj/item/stack/medical/ointment(src)
		new /obj/item/weapon/storage/syringe_case/regular(src)


/obj/item/weapon/storage/firstaid/toxin
	name = "toxin first aid"
	desc = "Used to treat when you have a high amount of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"
	possible_icons_full = list("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

	fill_firstaid_kit()
		new /obj/item/device/healthanalyzer( src )
		new /obj/item/weapon/reagent_containers/syringe/antitoxin( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/storage/syringe_case/tox( src )


/obj/item/weapon/storage/firstaid/o2
	name = "oxygen deprivation first aid"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"

	fill_firstaid_kit()
		new /obj/item/device/healthanalyzer( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP(src)
		new /obj/item/weapon/storage/syringe_case/oxy( src )


/obj/item/weapon/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"

	fill_firstaid_kit()
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord(src)
		new /obj/item/stack/medical/advanced/bruise_pack(src)
		new /obj/item/stack/medical/advanced/bruise_pack(src)
		new /obj/item/stack/medical/advanced/bruise_pack(src)
		new /obj/item/stack/medical/advanced/ointment(src)
		new /obj/item/stack/medical/advanced/ointment(src)
		new /obj/item/stack/medical/splint(src)


/obj/item/weapon/storage/firstaid/rad
	name = "radiation first-aid kit"
	desc = "Contains treatment for radiation exposure"
	icon_state = "purplefirstaid"

	fill_firstaid_kit()
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard(src)


	/*
 * Syringe Case
 */


/obj/item/weapon/storage/syringe_case
	name = "syringe case"
	desc = "It's an medical case for storing syringes and bottles."
	icon_state = "syringe_case"
	throw_speed = 2
	throw_range = 8
	storage_slots = 3
	w_class = 2.0
	can_hold = list("/obj/item/weapon/reagent_containers/pill","/obj/item/weapon/reagent_containers/glass/bottle","/obj/item/weapon/paper","/obj/item/weapon/reagent_containers/syringe","/obj/item/weapon/reagent_containers/hypospray/autoinjector")

/obj/item/weapon/storage/syringe_case/regular

	New()
		..()
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/glass/bottle/spaceacillin( src )

/obj/item/weapon/storage/syringe_case/burn

	New()
		..()
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/glass/bottle/kelotane( src )
		new /obj/item/weapon/reagent_containers/glass/bottle/spaceacillin( src )

/obj/item/weapon/storage/syringe_case/tox

	New()
		..()
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin( src )
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin( src )

/obj/item/weapon/storage/syringe_case/oxy

	New()
		..()
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/glass/bottle/dexalin( src )

/*
 * Pill Bottles
 */


//randomizing pill icons
var/global/list/randomized_pillbottle_icons


/obj/item/weapon/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister1"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = 2.0
	can_hold = list("/obj/item/weapon/reagent_containers/pill","/obj/item/weapon/dice","/obj/item/weapon/paper")
	allow_quick_gather = 1
	use_to_pickup = 1
	storage_slots = null
	use_sound = null
	var/pillbottle_label = ""

	New()
		..()
		name = "pill bottle"
		if(!randomized_pillbottle_icons)
			var/allowed_numbers = list(1,2,3,4,5,6,7,8,9,10)
			randomized_pillbottle_icons = list()
			for(var/i = 1 to 20)
				randomized_pillbottle_icons += "pill_canister[pick_n_take(allowed_numbers)]"


	examine(mob/user)
		..()
		if(!user.mind || !user.mind.skills_list || user.mind.skills_list["medical"] >= SKILL_MEDICAL_CHEM)
			user << "Label reads: [pillbottle_label]."
		else
			user << "You don't understand what the label says."

/obj/item/weapon/storage/pill_bottle/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/hand_labeler) || istype(W, /obj/item/weapon/pen))
		//pill bottle label can only be read by the medically trained, this is to prevent you from not understanding your own label.
		if(user.mind && user.mind.skills_list && user.mind.skills_list["medical"] < SKILL_MEDICAL_CHEM)
			user << "<span class='warning'>Better not label what you don't understand.</span>"
			return TRUE //no afterattack call
		var/newlabel = copytext(reject_bad_text(input(user,"What should the label read?","Set label","")),1,MAX_NAME_LEN)
		if(!newlabel || !length(newlabel))
			user << "<span class='warning'>Invalid text.</span>"
			return TRUE //no afterattack call
		pillbottle_label = newlabel
		user << "<span class='notice'>You label [src] as '[newlabel]'.</span>"
		return TRUE //no afterattack call
	else
		return ..()


/obj/item/weapon/storage/pill_bottle/kelotane
	name = "\improper Kelotane pill bottle"
	pillbottle_label = "KELOTANE"

	New()
		..()
		icon_state = randomized_pillbottle_icons[1]
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )

/obj/item/weapon/storage/pill_bottle/antitox
	name = "\improper Dylovene pill bottle"
	pillbottle_label = "DYLOVENE"

	New()
		..()
		icon_state = randomized_pillbottle_icons[2]
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )

/obj/item/weapon/storage/pill_bottle/inaprovaline
	name = "\improper Inaprovaline pill bottle"
	pillbottle_label = "INAPROVALINE"

	New()
		..()
		icon_state = randomized_pillbottle_icons[3]
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )

/obj/item/weapon/storage/pill_bottle/tramadol
	name = "\improper Tramadol pill bottle"
	pillbottle_label = "TRAMADOL"

	New()
		..()
		icon_state = randomized_pillbottle_icons[4]
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )

/obj/item/weapon/storage/pill_bottle/spaceacillin
	name = "\improper Spaceacillin pill bottle"
	pillbottle_label = "ANTIBIOTIC"

	New()
		..()
		icon_state = randomized_pillbottle_icons[5]
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )
		new /obj/item/weapon/reagent_containers/pill/spaceacillin( src )



/obj/item/weapon/storage/pill_bottle/bicaridine
	name = "\improper Bicaridine pill bottle"
	pillbottle_label = "BICARIDINE"

	New()
		..()
		icon_state = randomized_pillbottle_icons[6]
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
		new /obj/item/weapon/reagent_containers/pill/bicaridine(src)


/obj/item/weapon/storage/pill_bottle/dexalin
	name = "\improper Dexalin pill bottle"
	pillbottle_label = "DEXALIN"

	New()
		..()
		icon_state = randomized_pillbottle_icons[7]
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)


//Alkysine
/obj/item/weapon/storage/pill_bottle/alkysine
	name = "\improper Alkysine pill bottle"
	pillbottle_label = "ALKYSINE"

	New()
		..()
		icon_state = randomized_pillbottle_icons[8]
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)
		new /obj/item/weapon/reagent_containers/pill/alkysine(src)


//imidazoline
/obj/item/weapon/storage/pill_bottle/imidazoline
	name = "\improper Imidazoline pill bottle"
	pillbottle_label = "IMIDAZOLINE"

	New()
		..()
		icon_state = randomized_pillbottle_icons[9]
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)
		new /obj/item/weapon/reagent_containers/pill/imidazoline(src)

//PERIDAXON
/obj/item/weapon/storage/pill_bottle/peridaxon
	name = "\improper Peridaxon pill bottle"
	pillbottle_label = "PERIDAXON"

	New()
		..()

		icon_state = randomized_pillbottle_icons[10]
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)
		new /obj/item/weapon/reagent_containers/pill/peridaxon(src)


//RUSSIAN RED ANTI-RAD
/obj/item/weapon/storage/pill_bottle/russianRed
	name = "\improper Russian Red pill bottle"
	pillbottle_label = "RUSSIAN RED (VERY DANGEROUS)"

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
		new /obj/item/weapon/reagent_containers/pill/russianRed(src)
