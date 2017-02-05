//MARINE SPECIAL CHEMICALS -APOPHIS - LAST UPDATE - 21SEP2015

//Auto-injectors Items


/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord
	name = "\improper Tricordrazine autoinjector"
	desc = "An auto-injector loaded with Tricordrazine."
	amount_per_transfer_from_this = 15
	volume = 15
	hType = "tricord"
	icon_state = "tricord"

//Auto-injector Generation Proc (to change the chemicals)
	New()
		..()
		spawn(1)
			reagents.add_reagent("tricordrazine", 15)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot
	name = "\improper Quick Clot autinjector"
	desc = "An Auto-injector loaded with Quick-clot, a chemical designed to stop internal bleeding instantly.  Do not use more than once every 5 seconds."
	amount_per_transfer_from_this = 3
	volume = 3
	hType = "quickclot"
	icon_state = "quickcloth"

	New()
		..()
		spawn(1)
			reagents.add_reagent("quickclot", 3)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP
	name = "\improper Dexalin Plus autoinjector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	amount_per_transfer_from_this = 1
	volume = 1
	hType = "dexalin"
	icon_state = "dexalin"

	New()
		..()
		spawn(1)
			reagents.add_reagent("dexalinp", 1)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/clonefix  //This may be removable soon, since we don't have cloning.  Holding for now, since it's a genetic/eye damage fixer.
	name = "Clone-Fix"
	desc = "An auto-injector loaded with special chemicals to aid in recovery after cloning, to be used in conjunction with Cryo."
	amount_per_transfer_from_this = 6
	volume = 6
	hType = "clonefix"
	icon_state = "clonefix"

	New()
		..()
		spawn(1)
			reagents.add_reagent("alkysine", 5)
			reagents.add_reagent("ryetalyn", 1)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/chloralhydrate
	name = "\improper Anesthetic autoinjector"
	desc = "An anesthetic autoinjector, to aid with surgery"
	amount_per_transfer_from_this = 10
	volume = 10
	hType = "anesthetic"
	icon_state = "anesthetic"

	New()
		..()
		spawn(1)
			reagents.add_reagent("chloralhydrate", 1)
			reagents.add_reagent("stoxin", 9)
			update_icon()
		return


/obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene
	name = "\improper Dylovene (anti-tox)autoinjector"
	desc = "An auto-injector loaded with 5u of Dylovene."
	amount_per_transfer_from_this = 5
	volume = 5
	hType = "dylovene"
	icon_state = "dylovene"

	New()
		..()
		spawn(1)
			reagents.add_reagent("anti_toxin", 5)
			update_icon()
		return


/obj/item/weapon/reagent_containers/hypospray/autoinjector/Oxycodone
	name = "\improper Oxycodone (EXTREME PAINKILLER) autoinjector"
	desc = "An auto-injector loaded with 5u of Oxycodone."
	amount_per_transfer_from_this = 5
	volume = 5
	hType = "oxycodine"
	icon_state = "oxycodine"

	New()
		..()
		spawn(1)
			reagents.add_reagent("oxycodone", 5)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/Kelo
	name = "\improper Kelotane autoinjector"
	desc = "An auto-injector loaded with 5u of Kelotane."
	amount_per_transfer_from_this = 5
	volume = 5
	hType = "kelotine"
	icon_state = "kelotine"

	New()
		..()
		spawn(1)
			reagents.add_reagent("kelotane", 5)
			update_icon()
		return


/obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard
	name = "\improper Bicaridine autoinjector"
	desc = "An auto-injector loaded with 5u of Bicaridine."
	amount_per_transfer_from_this = 5
	volume = 5
	hType = "bicardine"
	icon_state = "bicardine"

	New()
		..()
		spawn(1)
			reagents.add_reagent("bicaridine", 5)
			update_icon()
		return

//RUSSIAN RED ANTI-RAD

/obj/item/weapon/storage/pill_bottle/russianRed
	name = "\improper Russian Red pill bottle"
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



//PERIDAXON
/obj/item/weapon/storage/pill_bottle/peridaxon
	name = "\improper Peridaxon pill bottle"
	desc = "Pills that heal internal organs"

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )
		new /obj/item/weapon/reagent_containers/pill/peridaxon( src )


/obj/item/weapon/reagent_containers/pill/peridaxon
	name = "Peridaxon (10u)"
	desc = "Heals internal organ damage"
	icon_state = "pill13"
	New()
		..()
		reagents.add_reagent("peridaxon", 10)

//imidazoline
/obj/item/weapon/storage/pill_bottle/imidazoline
	name = "\improper Imidazoline pill bottle"
	desc = "Pills that heal eye damage"

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )
		new /obj/item/weapon/reagent_containers/pill/imidazoline( src )


/obj/item/weapon/reagent_containers/pill/imidazoline
	name = "Imidazoline (10u)"
	desc = "Heals eye damage"
	icon_state = "pill3"
	New()
		..()
		reagents.add_reagent("imidazoline", 10)

//Alkysine
/obj/item/weapon/storage/pill_bottle/alkysine
	name = "\improper Alkysine pill bottle"
	desc = "Pills that heal brain damage"

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )
		new /obj/item/weapon/reagent_containers/pill/alkysine( src )


/obj/item/weapon/reagent_containers/pill/alkysine
	name = "Alkysine (10u)"
	desc = "Heals brain damage"
	icon_state = "pill15"
	New()
		..()
		reagents.add_reagent("alkysine", 10)

//BICARDINE
/obj/item/weapon/storage/pill_bottle/bicardine
	name = "\improper Bicardine pill bottle"
	desc = "Pills that heal brute damage."

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )
		new /obj/item/weapon/reagent_containers/pill/bicardine( src )


/obj/item/weapon/reagent_containers/pill/bicardine
	name = "Bicardine (5u)"
	desc = "Heals Brute"
	icon_state = "pill13"
	New()
		..()
		reagents.add_reagent("bicardine", 5)

//DEXALIN
/obj/item/weapon/storage/pill_bottle/dexalin
	name = "\improper Dexalin pill bottle"
	desc = "Pills that heal oxygen damage."

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )

/*/obj/item/weapon/reagent_containers/pill/bicardine
	name = "Bicardine (5u)"
	desc = "Heals Brute"
	icon_state = "pill13"
	New()
		..()
		reagents.add_reagent("bicardine", 5)*/



//GLASS BOTTLES
