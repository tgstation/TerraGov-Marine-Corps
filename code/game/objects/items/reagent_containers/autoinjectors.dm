


/obj/item/reagent_container/hypospray/autoinjector
	name = "\improper Inaprovaline autoinjector"
	//desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	desc = "An autoinjector containing Inaprovaline.  Useful for saving lives."
	icon_state = "autoinjector"
	item_state = "hypo"
	amount_per_transfer_from_this = 15
	w_class = 1
	volume = 15
	skilllock = 0
	container_type = DRAWABLE

/obj/item/reagent_container/hypospray/autoinjector/attack(mob/M as mob, mob/user as mob)
	. = ..()
	if(.)
		if(reagents.total_volume <= 0)
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



/obj/item/reagent_container/hypospray/autoinjector/tricordrazine
	name = "\improper Tricordrazine autoinjector"
	desc = "An autoinjector loaded with 15 units of Tricordrazine, a weak general use medicine for treating damage."
	icon_state = "tricord"
	list_reagents = list("tricordrazine" = 15)


/obj/item/reagent_container/hypospray/autoinjector/tricordrazine/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/quickclot
	name = "\improper Quick Clot autoinjector"
	desc = "An autoinjector loaded with 10 units of Quick Clot, a chemical designed to pause all bleeding. Renew doses as needed."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "quickclot"
	list_reagents = list("quickclot" = 10)

/obj/item/reagent_container/hypospray/autoinjector/quickclot/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/dexP
	name = "\improper Dexalin Plus autoinjector"
	desc = "An autoinjector loaded with 1 unit of Dexalin+, designed to immediately oxygenate the entire body."
	amount_per_transfer_from_this = 1
	volume = 1
	icon_state = "dexalin"
	list_reagents = list("dexalinp" = 1)

/obj/item/reagent_container/hypospray/autoinjector/dexP/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/stoxin
	name = "anesthetic autoinjector"
	desc = "An autoinjector loaded with 10 units of Sleeping Agent. Good to quickly pacify someone, for surgery of course."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "anesthetic"
	list_reagents = list("stoxin" = 10)

/obj/item/reagent_container/hypospray/autoinjector/stoxin/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Dylovene
	name = "\improper Dylovene (anti-tox) autoinjector"
	desc = "An auto-injector loaded with 15 units of Dylovene, an anti-toxin agent useful in cases of poisoning, overdoses and toxin build-up."
	icon_state = "dylovene"
	list_reagents = list("anti_toxin" = 15)

/obj/item/reagent_container/hypospray/autoinjector/Dylovene/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/tramadol
	name = "\improper Tramadol autoinjector"
	desc = "An auto-injector loaded with 15 units of Tramadol, a weak but effective painkiller for normal wounds."
	icon_state = "tramadol"
	list_reagents = list("tramadol" = 15)

/obj/item/reagent_container/hypospray/autoinjector/tramadol/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Oxycodone
	name = "\improper Oxycodone (EXTREME PAINKILLER) autoinjector"
	desc = "An auto-injector loaded with 5 units of Oxycodone, a powerful pankiller intended for life-threatening situations."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "oxycodone"
	list_reagents = list("oxycodone" = 10)

/obj/item/reagent_container/hypospray/autoinjector/Oxycodone/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Kelo
	name = "\improper Kelotane autoinjector"
	desc = "An auto-injector loaded with 15 units of Kelotane, a common burn medicine."
	icon_state = "kelotine"
	list_reagents = list("kelotane" = 15)

/obj/item/reagent_container/hypospray/autoinjector/Kelo/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/Bicard
	name = "\improper Bicaridine autoinjector"
	desc = "An auto-injector loaded with 15 units of Bicaridine, a common brute and circulatory damage medicine."
	icon_state = "bicaridine"
	list_reagents = list("bicaridine" = 15)

/obj/item/reagent_container/hypospray/autoinjector/Bicard/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/inaprovaline
	name = "\improper Inaprovaline autoinjector"
	desc = "An auto-injector loaded with 15 units of Inaprovaline, an emergency stabilization medicine for patients in critical condition."
	icon_state = "clonefix" //TEMP
	list_reagents = list("inaprovaline" = 15)

/obj/item/reagent_container/hypospray/autoinjector/inaprovaline/New()
	..()
	update_icon()

/obj/item/reagent_container/hypospray/autoinjector/hypervene
	name = "\improper Hypervene autoinjector"
	desc = "An auto-injector loaded with 3 units of Hypervene, an emergency medicine that rapidly purges chems. Causes pain and vomiting."
	icon_state = "anesthetic" //TEMP
	list_reagents = list("hypervene" = 3)

/obj/item/reagent_container/hypospray/autoinjector/hypervene/New()
	..()
	update_icon()
