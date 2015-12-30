//MARINE SPECIAL CHEMICALS -APOPHIS - LAST UPDATE - 21SEP2015

//Auto-injectors Items

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord
	name = "Tricordrazine Auto-Injector"
	desc = "An auto-injector loaded with Tricordrazine."
	amount_per_transfer_from_this = 15
	volume = 15

//Auto-injector Generation Proc (to change the chemicals)
	New()
		..()
		spawn(1)
			reagents.add_reagent("tricordrazine", 15)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot
	name = "Quick Clot"
	desc = "An Auto-injector loaded with Quick-clot, a chemical designed to stop internal bleeding instantly."
	amount_per_transfer_from_this = 5
	volume = 5

	New()
		..()
		spawn(1)
			reagents.add_reagent("quickclot", 5)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP
	name = "Dexalin Plus Auto-Injector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	amount_per_transfer_from_this = 1
	volume = 1

	New()
		..()
		spawn(1)
			reagents.add_reagent("dexalinp", 1)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/clonefix
	name = "Clone-Fix"
	desc = "An auto-injector loaded with special chemicals to aid in recovery after cloning, to be used in conjunction with Cryo."
	amount_per_transfer_from_this = 6
	volume = 6

	New()
		..()
		spawn(1)
			reagents.add_reagent("alkysine", 5)
			reagents.add_reagent("ryetalyn", 1)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/chloralhydrate
	name = "Anesthetic"
	desc = "An anesthetic autoinjector, to aid with surgery"
	amount_per_transfer_from_this = 10
	volume = 10

	New()
		..()
		spawn(1)
			reagents.add_reagent("chloralhydrate", 1)
			reagents.add_reagent("stoxin", 9)
			update_icon()
		return


/obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene
	name = "Dylovene (anti-tox) Auto-Injector"
	desc = "An auto-injector loaded with 5u of Dylovene."
	amount_per_transfer_from_this = 5
	volume = 5

	New()
		..()
		spawn(1)
			reagents.add_reagent("anti_toxin", 5)
			update_icon()
		return


/obj/item/weapon/reagent_containers/hypospray/autoinjector/Oxycodone
	name = "Oxycodone (EXTREME PAINKILLER) Auto-Injector"
	desc = "An auto-injector loaded with 5u of Oxycodone."
	amount_per_transfer_from_this = 5
	volume = 5

	New()
		..()
		spawn(1)
			reagents.add_reagent("oxycodone", 5)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/Kelo
	name = "Kelotane Auto-Injector"
	desc = "An auto-injector loaded with 5u of Kelotane."
	amount_per_transfer_from_this = 5
	volume = 5

	New()
		..()
		spawn(1)
			reagents.add_reagent("kelotane", 5)
			update_icon()
		return


/obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard
	name = "Bicaridine Auto-Injector"
	desc = "An auto-injector loaded with 5u of Bicaridine."
	amount_per_transfer_from_this = 5
	volume = 5

	New()
		..()
		spawn(1)
			reagents.add_reagent("bicaridine", 5)
			update_icon()
		return




//New Medic Combat-Lifesaver Bag - 21SEP2015 - APOPHIS

/obj/item/weapon/storage/belt/medical/combatLifesaver
	name = "Combat Lifesaver Bag"
	desc = "Designed to hold ."
	icon_state = "medicalbag"
	item_state = "medicbag"
	storage_slots = 21 //can hold 3 "rows" of very limited medical equipment, but it *should* give a decent boost to squad medics.
	can_hold = list(
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/dispenser",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/clothing/gloves/latex",
		"/obj/item/weapon/storage/syringe_case",
		"/obj/item/weapon/reagent_containers/hypospray/autoinjector",
		"/obj/item/stack/medical"
	)
	max_combined_w_class = 42


/obj/item/weapon/storage/belt/medical/combatLifesaver/New()  //The belt, with all it's magic inside!
	..()
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Kelo(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Kelo(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/Oxycodone(src)
	new /obj/item/weapon/storage/pill_bottle/russianRed(src)



//RUSSIAN RED ANTI-RAD

/obj/item/weapon/storage/pill_bottle/russianRed
	name = "Russian Red"
	desc = "Pills to counter extreme radiation.  (VERY DANGEROUS)"

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )
		new /obj/item/weapon/reagent_containers/pill/russianRed( src )


/obj/item/weapon/reagent_containers/pill/russianRed
	name = "Russian Red (10u)"
	desc = "An EXTREME radiation countering pill.  VERY dangerous"
	icon_state = "pill4"
	New()
		..()
		reagents.add_reagent("russianred", 10)



