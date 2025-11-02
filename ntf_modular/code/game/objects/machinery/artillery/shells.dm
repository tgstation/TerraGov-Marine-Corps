/obj/item/mortal_shell/smoke/satrapine
	name = "\improper 80mm nerve gas mortar shell"
	desc = "An 80mm mortar shell, loaded with nerve gas smoke dispersal agents. No effect on xenomorphs. Way slimmer than your typical 80mm."
	icon = 'ntf_modular/icons/obj/ammo/artillery.dmi'
	icon_state = "mortar_ammo_nerve"
	ammo_type = /datum/ammo/mortar/smoke/satrapine

/datum/ammo/mortar/smoke/satrapine
	smoketype = /datum/effect_system/smoke_spread/satrapine

/obj/item/mortal_shell/smoke/sleep
	name = "\improper 80mm sleep gas mortar shell"
	desc = "An 80mm mortar shell, loaded with sleep gas smoke dispersal agents. No effect on xenomorphs. Way slimmer than your typical 80mm."
	icon = 'ntf_modular/icons/obj/ammo/artillery.dmi'
	icon_state = "mortar_ammo_sleep"
	ammo_type = /datum/ammo/mortar/smoke/sleep

/datum/ammo/mortar/smoke/sleep
	smoketype = /datum/effect_system/smoke_spread/sleepy

/obj/item/mortal_shell/smoke/aphrotox
	name = "\improper 80mm aphrotoxin gas mortar shell"
	desc = "An 80mm mortar shell, loaded with horny gas smoke dispersal agents. No effect on xenomorphs. Way slimmer than your typical 80mm."
	icon = 'ntf_modular/icons/obj/ammo/artillery.dmi'
	icon_state = "mortar_ammo_aphro"
	ammo_type = /datum/ammo/mortar/smoke/aphrotox

/datum/ammo/mortar/smoke/aphrotox
	smoketype = /datum/effect_system/smoke_spread/xeno/aphrotoxin

/obj/item/mortal_shell/smoke/neuro
	name = "\improper 80mm neurotoxin gas mortar shell"
	desc = "An 80mm mortar shell, loaded with synthesized concentrated xeno neurotoxin gas smoke dispersal agents. No effect on xenomorphs, pacifies huggers momentarily. Way slimmer than your typical 80mm."
	icon = 'ntf_modular/icons/obj/ammo/artillery.dmi'
	icon_state = "mortar_ammo_neuro"
	ammo_type = /datum/ammo/mortar/smoke/neuro

/datum/ammo/mortar/smoke/neuro
	smoketype = /datum/effect_system/smoke_spread/xeno/neuro/medium


/obj/item/mortal_shell/razorburn
	name = "\improper 80mm razorburn mortar shell"
	desc = "An 80mm mortar shell, loaded with synthesized concentrated razorburn foam dispersal agents."
	//icon = 'ntf_modular/icons/obj/ammo/artillery.dmi' // uncommant and put icon in this file if adding a new one
	icon_state = "mortar_he" //could use its own icon
	color = list( //recolor to keep it distinguishable from HE
		1,1,0,0,
		1,0,0,0,
		0,0,1,0,
		0,0,0,1,
		0,0,0,0,
	)
	ammo_type = /datum/ammo/mortar/razorburn

/datum/ammo/mortar/razorburn
	var/obj/item/reagent_containers/glass/beaker/large/B1
	var/obj/item/reagent_containers/glass/beaker/large/B2
	var/B1_chems = list(/datum/reagent/toxin/nanites = 30)
	var/B2_chems = list(/datum/reagent/foaming_agent = 30)

/datum/ammo/mortar/razorburn/New()
	B1 = new()
	B2 = new()

/datum/ammo/mortar/razorburn/drop_nade(turf/T)
	B1.reagents.add_reagent_list(B1_chems)
	B2.reagents.add_reagent_list(B2_chems)
	chem_splash(T, 7, list(B1.reagents, B2.reagents), 10, 1)

/obj/item/mortal_shell/metalfoam
	name = "\improper 80mm metal foam mortar shell"
	desc = "An 80mm mortar shell, loaded with synthesized concentrated metal foam dispersal agents."
	//icon = 'ntf_modular/icons/obj/ammo/artillery.dmi' // uncommant and put icon in this file if adding a new one
	icon_state = "mortar_he" //could use its own icon
	color = list( //recolor to keep it distinguishable from HE
		1,  1,0,0,
		0,0.5,0,0,
		0,  0,1,0,
		0,  0,0,1,
		0,  0,0,0,
	)
	ammo_type = /datum/ammo/mortar/razorburn/metalfoam

/datum/ammo/mortar/razorburn/metalfoam
	B1_chems = list(/datum/reagent/aluminum = 90)
	B2_chems = list(/datum/reagent/foaming_agent = 30, /datum/reagent/toxin/acid/polyacid = 30)

/obj/item/mortal_shell/rocket/mlrs/neuro
	name = "\improper 60mm Neurotoxin rocket"
	desc = "A 60mm rocket loaded with incapacitating neurotoxin gas."
	icon_state = "mlrs_gas"
	ammo_type = /datum/ammo/mortar/rocket/smoke/mlrs/neuro

/datum/ammo/mortar/rocket/smoke/mlrs/neuro
	smoketype = /datum/effect_system/smoke_spread/xeno/neuro/medium

/obj/item/storage/box/mlrs_rockets/neuro
	name = "\improper TA-40L Neurotoxin rocket crate"

/obj/item/storage/box/mlrs_rockets/neuro/PopulateContents()
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)
	new /obj/item/mortal_shell/rocket/mlrs/neuro(src)

/obj/item/mortal_shell/rocket/mlrs/aphro
	name = "\improper 60mm Neurotoxin rocket"
	desc = "A 60mm rocket loaded with aphrotoxin gas."
	icon_state = "mlrs_gas"
	ammo_type = /datum/ammo/mortar/rocket/smoke/mlrs/aphro

/datum/ammo/mortar/rocket/smoke/mlrs/aphro
	smoketype = /datum/effect_system/smoke_spread/xeno/aphrotoxin

/obj/item/storage/box/mlrs_rockets/aphro
	name = "\improper TA-40L Aphrotoxin rocket crate"

/obj/item/storage/box/mlrs_rockets/aphro/PopulateContents()
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)
	new /obj/item/mortal_shell/rocket/mlrs/aphro(src)

/obj/item/mortal_shell/rocket/mlrs/sleep
	name = "\improper 60mm Knock-Out rocket"
	desc = "A 60mm rocket loaded with soporific gas."
	icon_state = "mlrs_gas"
	ammo_type = /datum/ammo/mortar/rocket/smoke/mlrs/sleep

/datum/ammo/mortar/rocket/smoke/mlrs/sleep
	smoketype = /datum/effect_system/smoke_spread/sleepy

/obj/item/storage/box/mlrs_rockets/sleep
	name = "\improper TA-40L Knock-Out rocket crate"

/obj/item/storage/box/mlrs_rockets/sleep/PopulateContents()
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
	new /obj/item/mortal_shell/rocket/mlrs/sleep(src)
