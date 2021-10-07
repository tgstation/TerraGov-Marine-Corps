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
		to_chat(user, span_notice("It is currently loaded."))
	else
		to_chat(user, span_notice("It is spent."))

/obj/item/reagent_containers/hypospray/autoinjector/fillable
	desc = "An autoinjector loaded with... something, consult the doctor who gave this to you."
	amount_per_transfer_from_this = 30
	volume = 30
	list_reagents = null

/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine
	name = "tricordrazine autoinjector"
	desc = "An autoinjector loaded with 3 doses of tricordrazine, a weak general use medicine for treating damage."
	icon_state = "autoinjector-4"
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 15)

/obj/item/reagent_containers/hypospray/autoinjector/combat
	name = "combat autoinjector"
	desc = "An autoinjector loaded with two doses of healing and painkilling chemicals. Intended for use in active combat."
	icon_state = "autoinjector-4"
	volume = 30
	list_reagents = list(
		/datum/reagent/medicine/bicaridine = 10,
		/datum/reagent/medicine/kelotane = 10,
		/datum/reagent/medicine/dylovene = 5,
		/datum/reagent/medicine/tramadol = 5,
	)

/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced
	name = "Advanced combat autoinjector"
	desc = "An autoinjector loaded with two doses of advanced healing and painkilling chemicals. Intended for use in active combat."
	icon_state = "autoinjector-7"
	volume = 30
	list_reagents = list(
		/datum/reagent/medicine/meralyne = 10,
		/datum/reagent/medicine/dermaline = 10,
		/datum/reagent/medicine/oxycodone = 10,
	)

/obj/item/reagent_containers/hypospray/autoinjector/quickclot
	name = "quick-clot autoinjector"
	desc = "An autoinjector loaded with three doses of quick-clot, a chemical designed to pause all bleeding. Renew doses as needed."
	icon_state = "autoinjector-7"
	amount_per_transfer_from_this = 10
	volume = 30
	list_reagents = list(/datum/reagent/medicine/quickclot = 30)

/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus
	name = "quick-clot plus autoinjector"
	desc = "An autoinjector loaded with 3 uses of quick-clot plus, a chemical designed to remove internal bleeding. Use with antitoxin. !DO NOT USE IN ACTIVE COMBAT!"
	icon_state = "autoinjector-7"
	amount_per_transfer_from_this = 5
	volume = 15
	list_reagents = list(/datum/reagent/medicine/quickclotplus = 15)

/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus
	name = "dexalin plus autoinjector"
	desc = "An autoinjector loaded with 3 uses of dexalin plus, designed to immediately oxygenate the entire body."
	icon_state = "autoinjector-2"
	amount_per_transfer_from_this = 1
	volume = 3
	list_reagents = list(/datum/reagent/medicine/dexalinplus = 3)

/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin
	name = "anesthetic autoinjector"
	desc = "An autoinjector loaded with 10 units of sleeping agent. Good to quickly pacify someone, for surgery of course."
	icon_state = "autoinjector-8"
	amount_per_transfer_from_this = 10
	volume = 10
	list_reagents = list(
		/datum/reagent/toxin/sleeptoxin = 8,
		/datum/reagent/toxin/chloralhydrate = 2,
	)

/obj/item/reagent_containers/hypospray/autoinjector/dylovene
	name = "dylovene autoinjector"
	desc = "An auto-injector loaded with 3 doses of dylovene, an anti-toxin agent useful in cases of poisoning, overdoses and toxin build-up."
	icon_state = "autoinjector-1"
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/medicine/dylovene = 15)

/obj/item/reagent_containers/hypospray/autoinjector/tramadol
	name = "tramadol autoinjector"
	desc = "An auto-injector loaded with 3 doses of tramadol, an effective painkiller for normal wounds."
	icon_state = "autoinjector-10"
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/medicine/tramadol = 15)

/obj/item/reagent_containers/hypospray/autoinjector/oxycodone
	name = "oxycodone autoinjector"
	desc = "An auto-injector loaded with 2 doses of oxycodone, a powerful pankiller intended for life-threatening situations."
	icon_state = "autoinjector-6"
	volume = 20
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/oxycodone = 20)

/obj/item/reagent_containers/hypospray/autoinjector/kelotane
	name = "kelotane autoinjector"
	desc = "An auto-injector loaded with 3 doses of kelotane, a common burn medicine."
	icon_state = "autoinjector-5"
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/medicine/kelotane = 15)

/obj/item/reagent_containers/hypospray/autoinjector/bicaridine
	name = "bicaridine autoinjector"
	desc = "An auto-injector loaded with 3 doses of bicaridine, a common brute and circulatory damage medicine."
	icon_state = "autoinjector-3"
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/medicine/bicaridine = 15)

/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline
	name = "inaprovaline autoinjector"
	desc = "An auto-injector loaded with 15 units of inaprovaline, an emergency stabilization medicine for patients in critical condition."
	icon_state = "autoinjector-9"
	list_reagents = list(/datum/reagent/medicine/inaprovaline = 15)

/obj/item/reagent_containers/hypospray/autoinjector/hypervene
	name = "hypervene autoinjector"
	desc = "An auto-injector loaded with 3 uses of hypervene, an emergency medicine that rapidly purges chems. Causes pain and vomiting."
	icon_state = "autoinjector-12"
	amount_per_transfer_from_this = 3
	volume = 9
	list_reagents = list(/datum/reagent/hypervene = 9)

/obj/item/reagent_containers/hypospray/autoinjector/hyperzine
	name = "hyperzine autoinjector"
	desc = "An auto-injector freshly loaded with a safe-to-use hyperzine mix."
	icon_state = "autoinjector-8"
	amount_per_transfer_from_this = 25
	volume = 25
	list_reagents = list(
		/datum/reagent/medicine/hyperzine = 5,
		/datum/reagent/medicine/dexalin = 10,
		/datum/reagent/medicine/inaprovaline = 10,
	)

/obj/item/reagent_containers/hypospray/autoinjector/hyperzine/expired
	name = "expired hyperzine autoinjector"
	desc = "An auto-injector said to be loaded with a safe-to-use hyperzine mix, 3 months past it's expiration date."
	list_reagents = list(
		/datum/reagent/medicine/hyperzine = 4,
		/datum/reagent/medicine/dexalin = 8,
		/datum/reagent/medicine/inaprovaline = 8,
		/datum/reagent/toxin = 5,
	)

/obj/item/reagent_containers/hypospray/autoinjector/synaptizine
	name = "synaptizine autoinjector"
	desc = "An auto-injector freshly loaded with a safe-to-use synaptizine mix."
	icon_state = "autoinjector-1"
	amount_per_transfer_from_this = 3
	volume = 9
	list_reagents = list(
		/datum/reagent/medicine/synaptizine = 3,
		/datum/reagent/medicine/hyronalin = 6,
	)

/obj/item/reagent_containers/hypospray/autoinjector/synaptizine_expired
	name = "expired synaptizine autoinjector"
	desc = "An auto-injector said to be loaded with a safe-to-use synaptizine mix, 3 months past it's expiration date."
	icon_state = "autoinjector-1"
	amount_per_transfer_from_this = 2
	volume = 6
	list_reagents = list(
		/datum/reagent/medicine/synaptizine = 3,
		/datum/reagent/medicine/hyronalin = 3,
	)

/obj/item/reagent_containers/hypospray/autoinjector/neuraline
	name = "neuraline autoinjector"
	desc = "An auto-injector loaded with 3 doses of neuraline, an extremely powerful stimulant. !DO NOT USE MORE THAN ONCE AT A TIME!"
	icon_state = "autoinjector-6"
	amount_per_transfer_from_this = 4
	volume = 12
	list_reagents = list(/datum/reagent/medicine/neuraline = 12)

/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus
	name = "peridaxon Plus autoinjector"
	desc = "An auto-injector loaded with 3 doses of Peridaxon Plus, a chemical that heals organs while causing a buildup of toxins. Use with antitoxin. !DO NOT USE IN ACTIVE COMBAT!"
	icon_state = "autoinjector-8"
	amount_per_transfer_from_this = 3
	volume = 9
	list_reagents = list(
		/datum/reagent/medicine/peridaxon_plus = 3,
		/datum/reagent/medicine/hyronalin = 6,
	)

/obj/item/reagent_containers/hypospray/autoinjector/russian_red
	name = "Emergency autoinjector"
	desc = "An autoinjector loaded with a single use of Russian Red. Restores a significant amount of stamina and heals a large amount of damage, but causes slight permanent damage."
	icon_state = "autoinjector-7"
	amount_per_transfer_from_this = 15
	volume = 15
	list_reagents = list(
		/datum/reagent/medicine/russian_red = 10,
		/datum/reagent/medicine/ryetalyn = 5,
	)

/obj/item/reagent_containers/hypospray/autoinjector/polyhexanide
	name = "polyhexanide autoinjector"
	desc = "An auto-injector loaded with a dose of Polyhexanide, a sterilizer for internal surgical use."
	icon_state = "autoinjector-10"
	volume = 20
	list_reagents = list(/datum/reagent/medicine/polyhexanide = 20)

/obj/item/reagent_containers/hypospray/autoinjector/isotonic
	name = "isotonic solution autoinjector"
	desc = "An auto-injector loaded with a single dose of isotonic solution, formulated to quickly recover fluid volume after blood loss or trauma."
	icon_state = "autoinjector-8"
	amount_per_transfer_from_this = 25
	volume = 25
	list_reagents = list(
		/datum/reagent/iron = 10,
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/sugar = 5,
	)

/obj/item/reagent_containers/hypospray/autoinjector/roulettium
	name = "roulettium autoinjector"
	desc = "An auto-injector loaded with one shot of roulettium, an extremely powerful panacea. !THIS HAS A CHANCE OF UNRECOVERABLE DEATH!"
	icon_state = "autoinjector-6"
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/medicine/roulettium = 1)

/obj/item/reagent_containers/hypospray/autoinjector/elite //only deathsquad should be able to get this
	name = "elite autoinjector"
	desc = "An elite auto-injector loaded with a strong and versatile combination of chemicals, healing most types of damage. Issued almost excusively to the infamous Nanotrasen deathsquads"
	icon_state = "autoinjector-7"
	amount_per_transfer_from_this = 10
	volume = 30
	list_reagents = list(
		/datum/reagent/medicine/russian_red = 15,
		/datum/reagent/medicine/rezadone = 15,
	)

/obj/item/reagent_containers/hypospray/autoinjector/hydrocodone //made for debugging
	name = "hydrocodone autoinjector"
	desc = "An auto-injector loaded with hydrocodone."
	icon_state = "autoinjector-6"
	amount_per_transfer_from_this = 4
	volume = 100

	list_reagents = list(/datum/reagent/medicine/hydrocodone = 100)
