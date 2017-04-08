//MARINE SPECIAL CHEMICALS -APOPHIS - LAST UPDATE - 21SEP2015

//Auto-injectors Items


/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord
	name = "\improper Tricordrazine autoinjector"
	desc = "An auto-injector loaded with Tricordrazine."
	amount_per_transfer_from_this = 15
	volume = 15
	icon_state = "tricord"

//Auto-injector Generation Proc (to change the chemicals)
	New()
		..()
		spawn(1)
			reagents.add_reagent("tricordrazine", 15)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot
	name = "\improper Quick Clot autoinjector"
	desc = "An Auto-injector loaded with Quick-clot, a chemical designed to stop internal bleeding instantly.  Do not use more than once every 5 seconds."
	amount_per_transfer_from_this = 3
	volume = 3
	icon_state = "quickclot"

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
	icon_state = "clonefix"

	New()
		..()
		spawn(1)
			reagents.add_reagent("alkysine", 5)
			reagents.add_reagent("ryetalyn", 1)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/chloralhydrate
	name = "anesthetic autoinjector"
	desc = "An anesthetic autoinjector, to aid with surgery"
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "anesthetic"

	New()
		..()
		spawn(1)
			reagents.add_reagent("chloralhydrate", 1)
			reagents.add_reagent("stoxin", 9)
			update_icon()
		return


/obj/item/weapon/reagent_containers/hypospray/autoinjector/Dylovene
	name = "\improper Dylovene (anti-tox) autoinjector"
	desc = "An auto-injector loaded with 5u of Dylovene."
	amount_per_transfer_from_this = 5
	volume = 5
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
	icon_state = "bicaridine"

	New()
		..()
		spawn(1)
			reagents.add_reagent("bicaridine", 5)
			update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/Inaprovaline
	name = "\improper Inaprovaline autoinjector"
	desc = "An auto-injector loaded with Inaprovaline."
	amount_per_transfer_from_this = 15
	volume = 15
	icon_state = "clonefix" //TEMP

//Auto-injector Generation Proc (to change the chemicals)
	New()
		..()
		spawn(1)
			reagents.add_reagent("inaprovaline", 15)
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
	name = "\improper Russian Red (10u) pill"
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
	name = "\improper Peridaxon (10u) pill"
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
	name = "\improper Imidazoline (10u) pill"
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
	name = "\improper Alkysine (10u) pill"
	desc = "Heals brain damage"
	icon_state = "pill15"
	New()
		..()
		reagents.add_reagent("alkysine", 10)

//bicaridine
/obj/item/weapon/storage/pill_bottle/bicaridine
	name = "\improper Bicaridine pill bottle"
	desc = "Pills that heal brute damage."

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )


/obj/item/weapon/reagent_containers/pill/bicaridine
	name = "\improper Bicaridine (5u) pill"
	desc = "Heals Brute damage.  Take Orally."
	icon_state = "pill13"
	New()
		..()
		reagents.add_reagent("bicaridine", 5)

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

/*/obj/item/weapon/reagent_containers/pill/bicaridine
	name = "bicaridine (5u)"
	desc = "Heals Brute"
	icon_state = "pill13"
	New()
		..()
		reagents.add_reagent("bicaridine", 5)*/



//GLASS BOTTLES
