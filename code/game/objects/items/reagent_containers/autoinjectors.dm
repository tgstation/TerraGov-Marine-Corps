/obj/item/reagent_containers/hypospray/autoinjector
	name = "generic autoinjector"
	desc = "An autoinjector containing... table salt? <i>\"For any client assistance, please contact the coderbus\" is written on the back.</i>"
	icon_state = "autoinjector"
	item_state = "hypo"
	w_class = WEIGHT_CLASS_TINY
	skilllock = 0
	init_reagent_flags = DRAWABLE
	amount_per_transfer_from_this = 10
	volume = 30
	list_reagents = list(/datum/reagent/consumable/sodiumchloride = 30)

/obj/item/reagent_containers/hypospray/autoinjector/update_icon_state()
	if(!(reagents.total_volume) && is_drawable())
		icon_state += "X"
		name = "expended [name]" //So people can see what have been expended since we have smexy new sprites people aren't used too...
		DISABLE_BITFIELD(reagents.reagent_flags, DRAWABLE)
	else if(reagents.total_volume && !CHECK_BITFIELD(reagents.reagent_flags, DRAWABLE)) // refilling it somehow
		icon_state = initial(icon_state)
		name = initial(name)
		ENABLE_BITFIELD(reagents.reagent_flags, DRAWABLE)

/obj/item/reagent_containers/hypospray/autoinjector/examine(mob/user)
	. = ..()
	if(length(reagents.reagent_list))
		. += span_notice("It is currently loaded.")
	else
		. += span_notice("It is spent.")

/obj/item/reagent_containers/hypospray/autoinjector/fillable
	desc = "An autoinjector loaded with... something, consult the doctor who gave this to you."
	amount_per_transfer_from_this = 30
	list_reagents = null

/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine
	name = "tricordrazine autoinjector"
	desc = "An autoinjector loaded with 3 doses of tricordrazine, a weak general use medicine for treating damage."
	icon_state = "autoinjector-4"
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 30)
	description_overlay = "Ti"

/obj/item/reagent_containers/hypospray/autoinjector/combat
	name = "combat autoinjector"
	desc = "An autoinjector loaded with 2 doses of healing and painkilling chemicals. Intended for use in active combat."
	icon_state = "RedGreen"
	amount_per_transfer_from_this = 15
	list_reagents = list(
		/datum/reagent/medicine/bicaridine = 10,
		/datum/reagent/medicine/kelotane = 10,
		/datum/reagent/medicine/tricordrazine = 5,
		/datum/reagent/medicine/tramadol = 5,
	)
	description_overlay = "Cb"

/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced
	name = "advanced combat autoinjector"
	desc = "An autoinjector loaded with 2 doses of advanced healing and painkilling chemicals. Intended for use in active combat."
	icon_state = "Lilac"
	amount_per_transfer_from_this = 15
	list_reagents = list(
		/datum/reagent/medicine/meralyne = 10,
		/datum/reagent/medicine/dermaline = 10,
		/datum/reagent/medicine/oxycodone = 10,
	)
	description_overlay = "Ca"

/obj/item/reagent_containers/hypospray/autoinjector/quickclot
	name = "quick-clot autoinjector"
	desc = "An autoinjector loaded with 3 doses of quick-clot, a chemical designed to pause all bleeding. Renew doses as needed."
	icon_state = "autoinjector-7"
	list_reagents = list(/datum/reagent/medicine/quickclot = 30)
	description_overlay = "Qk"

/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus
	name = "quick-clot plus autoinjector"
	desc = "An autoinjector loaded with 3 uses of quick-clot plus, a chemical designed to remove internal bleeding. Use with antitoxin. !DO NOT USE IN ACTIVE COMBAT!"
	icon_state = "autoinjector-7"
	amount_per_transfer_from_this = 5
	volume = 15
	list_reagents = list(/datum/reagent/medicine/quickclotplus = 15)
	description_overlay = "Qk+"

/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus
	name = "dexalin plus autoinjector"
	desc = "An autoinjector loaded with 3 uses of dexalin plus, designed to immediately oxygenate the entire body."
	icon_state = "autoinjector-2"
	amount_per_transfer_from_this = 1
	volume = 3
	list_reagents = list(/datum/reagent/medicine/dexalinplus = 3)
	description_overlay = "Dx+"

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
	list_reagents = list(/datum/reagent/medicine/dylovene = 30)
	description_overlay = "Dy"

/obj/item/reagent_containers/hypospray/autoinjector/tramadol
	name = "tramadol autoinjector"
	desc = "An auto-injector loaded with 3 doses of tramadol, an effective painkiller for normal wounds."
	icon_state = "autoinjector-10"
	list_reagents = list(/datum/reagent/medicine/tramadol = 30)
	description_overlay = "Ta"

/obj/item/reagent_containers/hypospray/autoinjector/oxycodone
	name = "oxycodone autoinjector"
	desc = "An auto-injector loaded with 2 doses of oxycodone, a powerful pankiller intended for life-threatening situations."
	icon_state = "autoinjector-6"
	volume = 20
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/oxycodone = 20)
	description_overlay = "Ox"

/obj/item/reagent_containers/hypospray/autoinjector/kelotane
	name = "kelotane autoinjector"
	desc = "An auto-injector loaded with 3 doses of kelotane, a common burn medicine."
	icon_state = "autoinjector-5"
	list_reagents = list(/datum/reagent/medicine/kelotane = 30)
	description_overlay = "Ke"

/obj/item/reagent_containers/hypospray/autoinjector/bicaridine
	name = "bicaridine autoinjector"
	desc = "An auto-injector loaded with 3 doses of bicaridine, a common brute and circulatory damage medicine."
	icon_state = "autoinjector-3"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 30)
	description_overlay = "Bi"

/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline
	name = "inaprovaline autoinjector"
	desc = "An auto-injector loaded with 2 doses of inaprovaline, an emergency stabilization medicine for patients in critical condition."
	icon_state = "autoinjector-9"
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/inaprovaline = 30)
	description_overlay = "In"

/obj/item/reagent_containers/hypospray/autoinjector/dexalin
	name = "dexalin autoinjector"
	desc = "An auto-injector loaded with 3 doses of dexalin, a medicine that oxygenates the body helping those with respiratory issues or low blood."
	icon_state = "autoinjector-2"
	volume = 15
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/medicine/dexalin = 15)
	description_overlay = "Dx"

/obj/item/reagent_containers/hypospray/autoinjector/spaceacillin
	name = "spaceacillin autoinjector"
	desc = "An auto-injector loaded with 3 doses of spaceacillin, an antibiotic medicine that helps combat infection and fight necrosis."
	icon_state = "autoinjector-1"
	volume = 15
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 15)
	description_overlay = "Sp"

/obj/item/reagent_containers/hypospray/autoinjector/alkysine
	name = "alkysine autoinjector"
	desc = "An auto-injector loaded with 3 doses of alkysine, long-living medicine for fixing brain and ear damage."
	icon_state = "autoinjector-12"
	volume = 15
	amount_per_transfer_from_this = 5
	list_reagents = list(/datum/reagent/medicine/alkysine = 15)
	description_overlay = "Al"

/obj/item/reagent_containers/hypospray/autoinjector/imidazoline
	name = "imidazoline autoinjector"
	desc = "An auto-injector loaded with 3 doses of imidazoline, medicine for fixing eyesight."
	icon_state = "autoinjector-5"
	list_reagents = list(/datum/reagent/medicine/imidazoline = 30)
	description_overlay = "Im"

/obj/item/reagent_containers/hypospray/autoinjector/hypervene
	name = "hypervene autoinjector"
	desc = "An auto-injector loaded with 3 uses of hypervene, an emergency medicine that rapidly purges chems. Causes pain and vomiting."
	icon_state = "Toxic"
	amount_per_transfer_from_this = 3
	volume = 9
	list_reagents = list(/datum/reagent/hypervene = 9)
	description_overlay = "Hy"

/obj/item/reagent_containers/hypospray/autoinjector/virilyth //not accessible during normal play, only for valhalla
	name = "virilyth autoinjector"
	desc = "A large auto-injector freshly loaded with virilynth."
	icon_state = "autoinjector-8"
	amount_per_transfer_from_this = 10
	volume = 50
	list_reagents = list(
		/datum/reagent/virilyth = 50,
	)

/obj/item/reagent_containers/hypospray/autoinjector/rezadone //not accessible during normal play, only for valhalla
	name = "rezadone autoinjector"
	desc = "A large auto-injector freshly loaded with rezadone."
	icon_state = "autoinjector-8"
	amount_per_transfer_from_this = 10
	volume = 50
	list_reagents = list(
		/datum/reagent/medicine/rezadone = 50,
	)

/obj/item/reagent_containers/hypospray/autoinjector/synaptizine
	name = "synaptizine autoinjector"
	desc = "An auto-injector freshly loaded with a safe-to-use synaptizine mix."
	icon_state = "Mystery"
	amount_per_transfer_from_this = 3
	volume = 9
	list_reagents = list(
		/datum/reagent/medicine/synaptizine = 3,
		/datum/reagent/medicine/hyronalin = 6,
	)
	description_overlay = "Sy"

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
	description_overlay = "Sy-"

/obj/item/reagent_containers/hypospray/autoinjector/neuraline
	name = "neuraline autoinjector"
	desc = "An auto-injector loaded with 3 doses of neuraline, an extremely powerful stimulant. !DO NOT USE MORE THAN ONCE AT A TIME!"
	icon_state = "RedWhite"
	amount_per_transfer_from_this = 4
	volume = 12
	list_reagents = list(/datum/reagent/medicine/neuraline = 12)
	description_overlay = "Ne"

/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus
	name = "peridaxon Plus autoinjector"
	desc = "An auto-injector loaded with 3 doses of Peridaxon Plus, a chemical that heals organs while causing a buildup of toxins. Use with antitoxin. !DO NOT USE IN ACTIVE COMBAT!"
	icon_state = "VioWhite"
	amount_per_transfer_from_this = 3
	volume = 9
	list_reagents = list(
		/datum/reagent/medicine/peridaxon_plus = 3,
		/datum/reagent/medicine/hyronalin = 6,
	)
	description_overlay = "Pe+"

/obj/item/reagent_containers/hypospray/autoinjector/russian_red
	name = "emergency autoinjector"
	desc = "An autoinjector loaded with a single use of Russian Red. Restores a significant amount of stamina and heals a large amount of damage, but causes slight permanent damage."
	icon_state = "Redwood"
	amount_per_transfer_from_this = 15
	volume = 30
	list_reagents = list(
		/datum/reagent/medicine/russian_red = 20,
		/datum/reagent/medicine/oxycodone = 10,
	)
	description_overlay = "Rr"
	free_refills = FALSE

/obj/item/reagent_containers/hypospray/autoinjector/polyhexanide
	name = "polyhexanide autoinjector"
	desc = "An auto-injector loaded with a dose of Polyhexanide, a sterilizer for internal surgical use."
	icon_state = "autoinjector-10"
	amount_per_transfer_from_this = 5
	volume = 20
	list_reagents = list(/datum/reagent/medicine/polyhexanide = 20)

/obj/item/reagent_containers/hypospray/autoinjector/isotonic
	name = "isotonic solution autoinjector"
	desc = "An auto-injector loaded with 2 doses of isotonic solution, formulated to quickly recover fluid volume after blood loss or trauma."
	icon_state = "autoinjector-8"
	amount_per_transfer_from_this = 15
	volume = 30
	list_reagents = list(
		/datum/reagent/medicine/saline_glucose = 30,
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
	volume = 37.5
	amount_per_transfer_from_this = 12.4
	list_reagents = list(
		/datum/reagent/medicine/russian_red = 30,
		/datum/reagent/medicine/rezadone = 7.2,
	)

/obj/item/reagent_containers/hypospray/autoinjector/medicalnanites
	name = "nanomachines autoinjector"
	desc = "An auto-injector loaded with medical nanites. A potent new method of healing that that reproduces using a subject's blood and has a brief but potentially dangerous activation period! Beware of Neurotoxin!"
	icon_state = "autoinjector-6"
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/medicine/research/medicalnanites = 1)
	free_refills = FALSE

/obj/item/reagent_containers/hypospray/autoinjector/pain //made for debugging
	name = "liquid pain autoinjector"
	desc = "An auto-injector loaded with liquid pain. Ow."
	icon_state = "autoinjector-6"
	amount_per_transfer_from_this = 20
	volume = 100

	list_reagents = list(/datum/reagent/toxin/pain = 100)
/obj/item/reagent_containers/hypospray/autoinjector/spacedrugs //CL goodie
	name = "space drugs autoinjector"
	desc = "An auto-injector loaded with sweet, sweet space drugs... Hard to get as a marine."
	icon_state = "autoinjector-1"
	amount_per_transfer_from_this = 25
	volume = 25

	list_reagents = list(/datum/reagent/space_drugs = 25)
/obj/item/reagent_containers/hypospray/autoinjector/mindbreaker //made for debugging
	name = "mindbreaker toxin autoinjector"
	desc = "An auto-injector loaded with the hardest, deadliest drug around. May cure PTSD. May cause it."
	icon_state = "Toxic"
	amount_per_transfer_from_this = 30
	volume = 30

	list_reagents = list(/datum/reagent/toxin/mindbreaker = 50)

