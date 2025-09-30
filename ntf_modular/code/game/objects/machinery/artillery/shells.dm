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
