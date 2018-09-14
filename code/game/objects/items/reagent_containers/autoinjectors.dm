


/obj/item/reagent_container/hypospray/autoinjector
	name = "\improper Inaprovaline autoinjector"
	//desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	desc = "An autoinjector containing Inaprovaline.  Useful for saving lives."
	icon_state = "autoinjector"
	item_state = "hypo"
	amount_per_transfer_from_this = 15
	w_class = 1.0
	volume = 15
	skilllock = 0

/obj/item/reagent_container/hypospray/autoinjector/attack(mob/M as mob, mob/user as mob)
	. = ..()
	if(.)
		if(reagents.total_volume <= 0) //Prevents autoinjectors to be refilled.
			flags_atom &= ~OPENCONTAINER
			update_icon()

/obj/item/reagent_container/hypospray/autoinjector/attackby()
	return

/obj/item/reagent_container/hypospray/autoinjector/update_icon()
	if(reagents.total_volume <= 0)
		icon_state += "0"
		name += " expended" //So people can see what have been expended since we have smexy new sprites people aren't used too...

/obj/item/reagent_container/hypospray/autoinjector/examine(mob/user)
	..()
	if(reagents && reagents.reagent_list.len)
		to_chat(user, "\blue It is currently loaded.")
	else
		to_chat(user, "\blue It is spent.")



/obj/item/reagent_container/hypospray/autoinjector/tricord
	name = "\improper Tricordrazine autoinjector"
	desc = "An autoinjector loaded with 15 units of Tricordrazine, a weak general use medicine for treating damage."
	icon_state = "tricord"

/obj/item/reagent_container/hypospray/autoinjector/tricord/New()
	..()
	reagents.add_reagent("tricordrazine", 15)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/quickclot
	name = "\improper Quick Clot autoinjector"
	desc = "An autoinjector loaded with 10 units of Quick Clot, a chemical designed to pause all bleeding. Renew doses as needed."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "quickclot"

/obj/item/reagent_container/hypospray/autoinjector/quickclot/New()
	..()
	reagents.add_reagent("quickclot", 10)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/dexP
	name = "\improper Dexalin Plus autoinjector"
	desc = "An autoinjector loaded with 1 unit of Dexalin+, designed to immediately oxygenate the entire body."
	amount_per_transfer_from_this = 1
	volume = 1
	icon_state = "dexalin"

/obj/item/reagent_container/hypospray/autoinjector/dexP/New()
	..()
	reagents.add_reagent("dexalinp", 1)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/chloralhydrate
	name = "anesthetic autoinjector"
	desc = "An autoinjector loaded with 1 unit of Chloral Hydrate and 9 units of Sleeping Agent. Good to quickly pacify someone, for surgery of course."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "anesthetic"

/obj/item/reagent_container/hypospray/autoinjector/chloralhydrate/New()
	..()
	reagents.add_reagent("chloralhydrate", 1)
	reagents.add_reagent("stoxin", 9)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Dylovene
	name = "\improper Dylovene (anti-tox) autoinjector"
	desc = "An auto-injector loaded with 15 units of Dylovene, an anti-toxin agent useful in cases of poisoning, overdoses and toxin build-up."
	icon_state = "dylovene"

/obj/item/reagent_container/hypospray/autoinjector/Dylovene/New()
	..()
	reagents.add_reagent("anti_toxin", 15)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Tramadol
	name = "\improper Tramadol autoinjector"
	desc = "An auto-injector loaded with 15 units of Tramadol, a weak but effective painkiller for normal wounds."
	icon_state = "tramadol"

/obj/item/reagent_container/hypospray/autoinjector/Tramadol/New()
	..()
	reagents.add_reagent("tramadol", 15)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Oxycodone
	name = "\improper Oxycodone (EXTREME PAINKILLER) autoinjector"
	desc = "An auto-injector loaded with 5 units of Oxycodone, a powerful pankiller intended for life-threatening situations."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "oxycodone"

/obj/item/reagent_container/hypospray/autoinjector/Oxycodone/New()
	..()
	reagents.add_reagent("oxycodone", 10)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Kelo
	name = "\improper Kelotane autoinjector"
	desc = "An auto-injector loaded with 15 units of Kelotane, a common burn medicine."
	icon_state = "kelotine"

/obj/item/reagent_container/hypospray/autoinjector/Kelo/New()
	..()
	reagents.add_reagent("kelotane", 15)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Bicard
	name = "\improper Bicaridine autoinjector"
	desc = "An auto-injector loaded with 15 units of Bicaridine, a common brute and circulatory damage medicine."
	icon_state = "bicaridine"

/obj/item/reagent_container/hypospray/autoinjector/Bicard/New()
	..()
	reagents.add_reagent("bicaridine", 15)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Inaprovaline
	name = "\improper Inaprovaline autoinjector"
	desc = "An auto-injector loaded with 15 units of Inaprovaline, an emergency stabilization medicine for patients in critical condition."
	icon_state = "clonefix" //TEMP

/obj/item/reagent_container/hypospray/autoinjector/Inaprovaline/New()
	..()
	reagents.add_reagent("inaprovaline", 15)
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/hypervene
	name = "\improper Hypervene autoinjector"
	desc = "An auto-injector loaded with 3 units of Hypervene, an emergency medicine that rapidly purges chems. Causes pain and vomitting."
	icon_state = "anesthetic" //TEMP

/obj/item/reagent_container/hypospray/autoinjector/hypervene/New()
	..()
	reagents.add_reagent("hypervene", 3)
	update_icon()
