
//Not to be confused with /obj/item/reagent_container/food/drinks/bottle

/obj/item/reagent_container/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,60)
	flags_atom = FPRINT|OPENCONTAINER
	volume = 60
	attack_speed = 4

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_hand()
		..()
		update_icon()

	New()
		..()
		if(!icon_state)
			icon_state = "bottle-[rand(1.4)]"

	update_icon()
		overlays.Cut()

		if(reagents.total_volume && (icon_state == "bottle-1" || icon_state == "bottle-2" || icon_state == "bottle-3" || icon_state == "bottle-4"))
			var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

			var/percent = round((reagents.total_volume / volume) * 100)
			switch(percent)
				if(0 to 9)		filling.icon_state = "[icon_state]--10"
				if(10 to 24) 	filling.icon_state = "[icon_state]-10"
				if(25 to 49)	filling.icon_state = "[icon_state]-25"
				if(50 to 74)	filling.icon_state = "[icon_state]-50"
				if(75 to 79)	filling.icon_state = "[icon_state]-75"
				if(80 to 90)	filling.icon_state = "[icon_state]-80"
				if(91 to INFINITY)	filling.icon_state = "[icon_state]-100"

			filling.color = mix_color_from_reagents(reagents.reagent_list)
			overlays += filling

		if (!is_open_container())
			var/image/lid = image(icon, src, "lid_bottle")
			overlays += lid

/obj/item/reagent_container/glass/bottle/inaprovaline
	name = "\improper Inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle19"

	New()
		..()
		reagents.add_reagent("inaprovaline", 60)

/obj/item/reagent_container/glass/bottle/kelotane
	name = "\improper Kelotane bottle"
	desc = "A small bottle. Contains kelotane - used to treat burned areas."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle16"

	New()
		..()
		reagents.add_reagent("kelotane", 60)

/obj/item/reagent_container/glass/bottle/dexalin
	name = "\improper Dexaline bottle"
	desc = "A small bottle. Contains dexalin - used to supply blood with oxygen."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle10"

	New()
		..()
		reagents.add_reagent("dexalin", 60)

/obj/item/reagent_container/glass/bottle/spaceacillin
	name = "\improper Spaceacillin bottle"
	desc = "A small bottle. Contains spaceacillin - used to treat infected wounds."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle8"

	New()
		..()
		reagents.add_reagent("spaceacillin", 60)

/obj/item/reagent_container/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle12"

	New()
		..()
		reagents.add_reagent("toxin", 60)

/obj/item/reagent_container/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle12"

	New()
		..()
		reagents.add_reagent("cyanide", 60)

/obj/item/reagent_container/glass/bottle/stoxin
	name = "soporific bottle"
	desc = "A small bottle of soporific. Just the fumes make you sleepy."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("stoxin", 60)

/obj/item/reagent_container/glass/bottle/chloralhydrate
	name = "chloral hydrate bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("chloralhydrate", 30)		//Intentionally low since it is so strong. Still enough to knock someone out.

/obj/item/reagent_container/glass/bottle/antitoxin
	name = "\improper Dylovene bottle"
	desc = "A small bottle of dylovene. Counters poisons, and repairs damage. A wonder drug."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle7"

	New()
		..()
		reagents.add_reagent("anti_toxin", 60)

/obj/item/reagent_container/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle7"

	New()
		..()
		reagents.add_reagent("mutagen", 60)

/obj/item/reagent_container/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("ammonia", 60)

/obj/item/reagent_container/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle17"

	New()
		..()
		reagents.add_reagent("diethylamine", 60)

/obj/item/reagent_container/glass/bottle/flu_virion
	name = "flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/advance/flu(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/epiglottis_virion
	name = "epiglottis virion culture bottle"
	desc = "A small bottle. Contains Epiglottis virion culture in synthblood medium."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/advance/voice_change(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/liver_enhance_virion
	name = "liver enhancement virion culture bottle"
	desc = "A small bottle. Contains liver enhancement virion culture in synthblood medium."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/advance/heal(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/hullucigen_virion
	name = "hullucigen virion culture bottle"
	desc = "A small bottle. Contains hullucigen virion culture in synthblood medium."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/advance/hullucigen(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/pierrot_throat
	name = "\improper Pierrot's Throat culture bottle"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/pierrot_throat(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/cold
	name = "rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/advance/F = new /datum/disease/advance/cold(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/random
	name = "random culture bottle"
	desc = "A small bottle. Contains a random disease."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/advance/F = new(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/retrovirus
	name = "retrovirus culture bottle"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/dna_retrovirus(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)


/obj/item/reagent_container/glass/bottle/gbs
	name = "\improper GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/gbs
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/fake_gbs
	name = "\improper GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/fake_gbs(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)
/*
/obj/item/reagent_container/glass/bottle/rhumba_beat
	name = "Rhumba Beat culture bottle"
	desc = "A small bottle. Contains The Rhumba Beat culture in synthblood medium."//Or simply - General BullShit
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/rhumba_beat
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)
*/

/obj/item/reagent_container/glass/bottle/brainrot
	name = "\improper Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/brainrot(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/magnitis
	name = "\improper Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/magnitis(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)


/obj/item/reagent_container/glass/bottle/wizarditis
	name = "\improper Wizarditis culture bottle"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/wizarditis(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/reagent_container/glass/bottle/pacid
	name = "polytrinic acid bottle"
	desc = "A small bottle. Contains a small amount of Polytrinic Acid"
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("pacid", 60)

/obj/item/reagent_container/glass/bottle/adminordrazine
	name = "\improper Adminordrazine bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/items/drinks.dmi'
	icon_state = "holyflask"
	New()
		..()
		reagents.add_reagent("adminordrazine", 60)

/obj/item/reagent_container/glass/bottle/capsaicin
	name = "\improper Capsaicin bottle"
	desc = "A small bottle. Contains hot sauce."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle3"
	New()
		..()
		reagents.add_reagent("capsaicin", 60)

/obj/item/reagent_container/glass/bottle/frostoil
	name = "\improper Frost Oil bottle"
	desc = "A small bottle. Contains cold sauce."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("frostoil", 60)

/obj/item/reagent_container/glass/bottle/bicaridine
	name = "\improper Bicaridine bottle"
	desc = "A small bottle. Contains Bicaridine - Used to treat brute damage by doctors."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle17"

	New()
		..()
		reagents.add_reagent("bicaridine", 60)

/obj/item/reagent_container/glass/bottle/peridaxon
	name = "\improper Peridaxon bottle"
	desc = "A small bottle. Contains Peridaxon - Used by lazy doctors to treat internal organ damage."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle4"
	volume = 20

	New()
		..()
		reagents.add_reagent("peridaxon", 20)

/obj/item/reagent_container/glass/bottle/tramadol
	name = "\improper Tramadol bottle"
	desc = "A small bottle. Contains Tramadol - Used as a basic painkiller."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle1"
	volume = 20

	New()
		..()
		reagents.add_reagent("tramadol", 20)

/obj/item/reagent_container/glass/bottle/oxycodone
	name = "\improper Oxycodone bottle"
	desc = "A very small bottle. Contains Oxycodone - Used as an Extreme Painkilled.  ILLEGAL TO DISTRIBUTE."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle2"
	volume = 10

	New()
		..()
		reagents.add_reagent("oxycodone", 10)