/obj/item/reagent_containers/hypospray/autoinjector
	name = "generic autoinjector"
	//desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	desc = "An autoinjector containing... table salt? <i>\"For any client assistance, please contact the coderbus\" is written on the back.</i>"
	icon_state = "autoinjector"
	item_state = "hypo"
	amount_per_transfer_from_this = 15
	w_class = WEIGHT_CLASS_TINY
	volume = 15
	skilllock = 0
	init_reagent_flags = DRAWABLE
	list_reagents = list(/datum/reagent/consumable/sodiumchloride = 15)

/obj/item/reagent_containers/hypospray/autoinjector/update_icon()
	if(!(reagents.total_volume) && is_drawable())
		icon_state += "X"
		name = "expended [name]" //So people can see what have been expended since we have smexy new sprites people aren't used too...
		DISABLE_BITFIELD(reagents.reagent_flags, DRAWABLE)
	else if(reagents.total_volume && !CHECK_BITFIELD(reagents.reagent_flags, DRAWABLE)) // refilling it somehow
		icon_state = initial(icon_state)
		name = initial(name)
		ENABLE_BITFIELD(reagents.reagent_flags, DRAWABLE)

/obj/item/reagent_containers/hypospray/autoinjector/examine(mob/user)
	..()
	if(reagents && reagents.reagent_list.len)
		to_chat(user, "<span class='notice'>It is currently loaded.</span>")
	else
		to_chat(user, "<span class='notice'>It is spent.</span>")

/obj/item/reagent_containers/hypospray/autoinjector/fillable
	desc = "An autoinjector loaded with... something, consult the doctor who gave this to you."
	amount_per_transfer_from_this = 30
	volume = 30
	list_reagents = null

/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine
	name = "tricordrazine autoinjector"
	desc = "An autoinjector loaded with 15 units of tricordrazine, a weak general use medicine for treating damage."
	icon_state = "autoinjector-4"
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 15)

/obj/item/reagent_containers/hypospray/autoinjector/quickclot
	name = "quick-clot autoinjector"
	desc = "An autoinjector loaded with 10 units of quick-clot, a chemical designed to pause all bleeding. Renew doses as needed."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "autoinjector-7"
	list_reagents = list(/datum/reagent/medicine/quickclot = 10)

/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus
	name = "dexalin plus autoinjector"
	desc = "An autoinjector loaded with 3 uses of dexalin plus, designed to immediately oxygenate the entire body."
	amount_per_transfer_from_this = 1
	volume = 3
	icon_state = "autoinjector-2"
	list_reagents = list(/datum/reagent/medicine/dexalinplus = 1)

/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin
	name = "anesthetic autoinjector"
	desc = "An autoinjector loaded with 10 units of sleeping agent. Good to quickly pacify someone, for surgery of course."
	amount_per_transfer_from_this = 10
	volume = 10
	icon_state = "autoinjector-8"
	list_reagents = list(/datum/reagent/toxin/sleeptoxin = 10)

/obj/item/reagent_containers/hypospray/autoinjector/dylovene
	name = "dylovene autoinjector"
	desc = "An auto-injector loaded with 15 units of dylovene, an anti-toxin agent useful in cases of poisoning, overdoses and toxin build-up."
	icon_state = "autoinjector-1"
	list_reagents = list(/datum/reagent/medicine/dylovene = 15)

/obj/item/reagent_containers/hypospray/autoinjector/tramadol
	name = "tramadol autoinjector"
	desc = "An auto-injector loaded with 15 units of tramadol, an effective painkiller for normal wounds. Adjustible dosage, defaults to 3 uses of 5 units each."
	amount_per_transfer_from_this = 5
	icon_state = "autoinjector-10"
	list_reagents = list(/datum/reagent/medicine/tramadol = 15)


/obj/item/reagent_containers/hypospray/autoinjector/combat
	name = "combat autoinjector"
	desc = "An auto-injector loaded with 5 units each of bicaridine, kelotane, and tramadol, intended for usage in high-stress situations"
	icon_state = "autoinjector-3"//Could use a mixed-sprite for this, whenever someone feels like it.
	list_reagents = list(/datum/reagent/medicine/bicaridine = 5,
						/datum/reagent/medicine/kelotane = 5,
						/datum/reagent/medicine/tramadol = 5)

/obj/item/reagent_containers/hypospray/autoinjector/oxycodone
	name = "oxycodone autoinjector"
	desc = "An auto-injector loaded with 10 units of oxycodone, a powerful pankiller intended for life-threatening situations. Adjustible dosage, defaults to 2 uses of 5 each."
	amount_per_transfer_from_this = 5
	volume = 10
	icon_state = "autoinjector-6"
	list_reagents = list(/datum/reagent/medicine/oxycodone = 10)

/obj/item/reagent_containers/hypospray/autoinjector/kelotane
	name = "kelotane autoinjector"
	desc = "An auto-injector loaded with 15 units of kelotane, a common burn medicine. Adjustible dosage, defaults to 3 uses of 5 units each."
	amount_per_transfer_from_this = 5
	icon_state = "autoinjector-5"
	list_reagents = list(/datum/reagent/medicine/kelotane = 15)

/obj/item/reagent_containers/hypospray/autoinjector/bicaridine
	name = "bicaridine autoinjector"
	desc = "An auto-injector loaded with 15 units of bicaridine, a common brute damage medicine. Adjustible dosage, defaults to 3 uses of 5 units each."
	amount_per_transfer_from_this = 5
	icon_state = "autoinjector-3"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 15)

/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline
	name = "inaprovaline autoinjector"
	desc = "An auto-injector loaded with 15 units of inaprovaline, an emergency stabilization medicine for patients in critical condition."
	icon_state = "autoinjector-9"
	list_reagents = list(/datum/reagent/medicine/inaprovaline = 15)

/obj/item/reagent_containers/hypospray/autoinjector/hypervene
	name = "hypervene autoinjector"
	desc = "An auto-injector loaded with 3 units of hypervene, an emergency medicine that rapidly purges chems. Causes pain and vomiting."
	amount_per_transfer_from_this = 3
	volume = 3
	icon_state = "autoinjector-8" //TEMP
	list_reagents = list(/datum/reagent/medicine/hypervene = 3)

/obj/item/reagent_containers/hypospray/autoinjector/hyperzine/expired
	name = "expired hyperzine autoinjector"
	desc = "An auto-injector said to be loaded with a safe-to-use hyperzine mix, 3 months past it's expiration date."
	list_reagents = list(/datum/reagent/medicine/hyperzine = 4, 
							/datum/reagent/medicine/dexalin = 8, 
							/datum/reagent/medicine/inaprovaline = 8, 
							/datum/reagent/toxin = 5)

/obj/item/reagent_containers/hypospray/autoinjector/hyperzine
	name = "hyperzine autoinjector"
	desc = "An auto-injector freshly loaded with a safe-to-use hyperzine mix."
	amount_per_transfer_from_this = 25
	volume = 25
	icon_state = "autoinjector-1" //TEMP, god willing
	list_reagents = list(/datum/reagent/medicine/hyperzine = 5, 
							/datum/reagent/medicine/dexalin = 10, 
							/datum/reagent/medicine/inaprovaline = 10)

/obj/item/reagent_containers/hypospray/autoinjector/synaptizine
	name = "synaptizine autoinjector"
	desc = "An auto-injector loaded with a safe-to-use synaptizine mix, a good anti-stun chemical."
	volume = 20
	icon_state = "autoinjector-10"
	list_reagents = list(/datum/reagent/medicine/synaptizine = 5, 
							/datum/reagent/medicine/tricordrazine = 15)

/obj/item/reagent_containers/hypospray/autoinjector/synaptizine/expired
	name = "expired synaptizine autoinjector"
	desc = "An auto-injector loaded with a safe-to-use synaptizine mix, 3 months past it's expiration date."
	icon_state = "autoinjector-10"
	list_reagents = list(/datum/reagent/medicine/synaptizine = 3, 
							/datum/reagent/medicine/tricordrazine = 11, 
							/datum/reagent/toxin = 6)

/obj/item/reagent_containers/hypospray/autoinjector/neuraline
	name = "neuraline autoinjector"
	desc = "An auto-injector loaded with 3 units of Neuraline, a very potent short-lived anti-stun chemical."
	amount_per_transfer_from_this = 3
	volume = 3
	icon_state = "autoinjector-6"
	list_reagents = list(/datum/reagent/medicine/neuraline = 4)

/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus
	name = "peridaxon plus autoinjector"
	desc = "An auto-injector loaded with 3 seperate injections of Peridaxon Plus, a miracle drug for healing internal damage. !!DO NOT INJECT MORE THAN ONCE AT A TIME!!"
	amount_per_transfer_from_this = 1
	volume = 3
	icon_state = "autoinjector-1"
	list_reagents = list(/datum/reagent/medicine/peridaxon_plus = 3)

/obj/item/reagent_containers/hypospray/autoinjector/quickclot_plus
	name = "quickclot plus autoinjector"
	desc = "An auto-injector loaded with 3 seperate injections of Quickclot Plus, a miracle drug for healing internal bleeding. !!DO NOT INJECT MORE THAN ONCE AT A TIME!!"
	amount_per_transfer_from_this = 1
	volume = 3
	icon_state = "autoinjector-7"
	list_reagents = list(/datum/reagent/medicine/quickclot_plus = 3)







