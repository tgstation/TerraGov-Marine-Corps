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
	desc = "An auto-injector loaded with 10u of Bicaridine."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "bicaridine"

	New()
		..()
		spawn(1)
			reagents.add_reagent("bicaridine", 10)
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


