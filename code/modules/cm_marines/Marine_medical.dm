//MARINE SPECIAL CHEMICALS -APOPHIS - LAST UPDATE - 21SEP2015

//Auto-injectors Items
/obj/item/reagent_container/hypospray/autoinjector/tricord
	name = "\improper Tricordrazine autoinjector"
	desc = "An autoinjector loaded with 15 units of Tricordrazine, a weak general use medicine for treating damage."
	amount_per_transfer_from_this = 15
	volume = 15
	icon_state = "tricord"

	New()
		..()
		reagents.add_reagent("tricordrazine", 15)
		update_icon()

/obj/item/reagent_container/hypospray/autoinjector/quickclot
	name = "\improper Quick Clot autoinjector"
	desc = "An autoinjector loaded with 10 units of Quick Clot, a chemical designed to pause all bleeding. Renew doses as needed."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "quickclot"

	New()
		..()
		reagents.add_reagent("quickclot", 10)
		update_icon()

/obj/item/reagent_container/hypospray/autoinjector/dexP
	name = "\improper Dexalin Plus autoinjector"
	desc = "An autoinjector loaded with 1 unit of Dexalin+, designed to immediately oxygenate the entire body."
	amount_per_transfer_from_this = 1
	volume = 1
	icon_state = "dexalin"

	New()
		..()
		reagents.add_reagent("dexalinp", 1)
		update_icon()

/obj/item/reagent_container/hypospray/autoinjector/chloralhydrate
	name = "anesthetic autoinjector"
	desc = "An autoinjector loaded with 1 unit of Chloral Hydrate and 9 units of Sleeping Agent. Good to quickly pacify someone, for surgery of course."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "anesthetic"

	New()
		..()
		reagents.add_reagent("chloralhydrate", 1)
		reagents.add_reagent("stoxin", 9)
		update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Dylovene
	name = "\improper Dylovene (anti-tox) autoinjector"
	desc = "An auto-injector loaded with 5 units of Dylovene, an anti-toxin agent useful in cases of poisoning, overdoses and toxin build-up."
	amount_per_transfer_from_this = 5
	volume = 5
	icon_state = "dylovene"

	New()
		..()
		reagents.add_reagent("anti_toxin", 5)
		update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Tramadol
	name = "\improper Tramadol autoinjector"
	desc = "An auto-injector loaded with 10 units of Tramadol, a weak but effective painkiller for normal wounds."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "tramadol"

	New()
		..()
		reagents.add_reagent("tramadol", 10)
		update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Oxycodone
	name = "\improper Oxycodone (EXTREME PAINKILLER) autoinjector"
	desc = "An auto-injector loaded with 5 units of Oxycodone, a powerful pankiller intended for life-threatening situations."
	amount_per_transfer_from_this = 5
	volume = 5
	icon_state = "oxycodone"

	New()
		..()
		reagents.add_reagent("oxycodone", 5)
		update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Kelo
	name = "\improper Kelotane autoinjector"
	desc = "An auto-injector loaded with 5 units of Kelotane, a common burn medicine."
	amount_per_transfer_from_this = 5
	volume = 5
	icon_state = "kelotine"

	New()
		..()
		reagents.add_reagent("kelotane", 5)
		update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Bicard
	name = "\improper Bicaridine autoinjector"
	desc = "An auto-injector loaded with 10 units of Bicaridine, a common brute and circulatory damage medicine."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "bicaridine"

	New()
		..()
		reagents.add_reagent("bicaridine", 10)
		update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Inaprovaline
	name = "\improper Inaprovaline autoinjector"
	desc = "An auto-injector loaded with 15 units of Inaprovaline, an emergency stabilization medicine for patients in critical condition."
	amount_per_transfer_from_this = 15
	volume = 15
	icon_state = "clonefix" //TEMP

	New()
		..()
		reagents.add_reagent("inaprovaline", 15)
		update_icon()
