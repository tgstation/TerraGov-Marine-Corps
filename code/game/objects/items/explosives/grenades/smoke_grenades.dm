/obj/item/explosive/grenade/smokebomb
	name = "\improper M40 HSDP smoke grenade"
	desc = "The M40 HSDP is a small, but powerful smoke grenade. Based off the same platform as the M40 HEDP. It is set to detonate in 2 seconds."
	icon_state = "grenade_smoke"
	worn_icon_state = "grenade_smoke"
	det_time = 2 SECONDS
	hud_state = "grenade_smoke"
	dangerous = FALSE
	icon_state_mini = "grenade_blue"
	/// smoke type created when the grenade is primed
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	///radius this smoke grenade will encompass
	var/smokeradius = 6
	///The duration of the smoke in 2 second ticks
	var/smoke_duration = 9

/obj/item/explosive/grenade/smokebomb/prime()
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(loc, 'sound/effects/smoke_bomb.ogg', 25, TRUE)
	smoke.set_up(smokeradius, loc, smoke_duration)
	smoke.start()
	qdel(src)

/obj/item/explosive/grenade/smokebomb/som
	name = "\improper S30-S smoke grenade"
	desc = "The S30-S is a small, but powerful smoke grenade. Based off the S30 platform shared by most SOM grenades. It is set to detonate in 2 seconds."
	icon_state = "grenade_smoke_som"
	worn_icon_state = "grenade_smoke_som"

/obj/item/explosive/grenade/smokebomb/neuro
	name = "\improper M40-N Neurotoxin smoke grenade"
	desc = "A smoke grenade containing a concentrated neurotoxin developed by Nanotrasen, supposedly derived from xenomorphs. Banned in some sectors as a chemical weapon, but classed as a less lethal riot control tool by the TGMC."
	icon_state = "grenade_neuro"
	worn_icon_state = "grenade_neuro"
	hud_state = "grenade_neuro"
	det_time = 4 SECONDS
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/xeno/neuro/medium

/obj/item/explosive/grenade/smokebomb/acid
	name = "\improper M40-A Acid smoke grenade"
	desc = "A grenade set to release a cloud of extremely acidic smoke developed by Nanotrasen, supposedly derived from xenomorphs. Has a shiny acid resistant shell. Its use is considered a warcrime under several treaties, none of which Terra Gov is a signatory to."
	icon_state = "grenade_acid"
	worn_icon_state = "grenade_acid"
	hud_state = "grenade_acid"
	det_time = 4 SECONDS
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/xeno/acid/opaque
	smokeradius = 5

/obj/item/explosive/grenade/smokebomb/satrapine
	name = "satrapine smoke grenade"
	desc = "A smoke grenade containing a nerve agent that can debilitate victims with severe pain, while purging common painkillers. Employed heavily by the SOM."
	icon_state = "grenade_nerve"
	worn_icon_state = "grenade_nerve"
	hud_state = "grenade_nerve"
	det_time = 4 SECONDS
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/satrapine

/obj/item/explosive/grenade/smokebomb/satrapine/activate(mob/user)
	. = ..()
	if(!.)
		return FALSE
	user?.record_war_crime()

/obj/item/explosive/grenade/smokebomb/cloak
	name = "\improper M40-2 SCDP smoke grenade"
	desc = "A sophisticated version of the M40 HSDP with a slighty improved smoke screen payload. It's set to detonate in 2 seconds."
	icon_state = "grenade_cloak"
	worn_icon_state = "grenade_cloak"
	hud_state = "grenade_hide"
	icon_state_mini = "grenade_green"
	smoketype = /datum/effect_system/smoke_spread/tactical
	smoke_duration = 11
	smokeradius = 7

/obj/item/explosive/grenade/smokebomb/cloak/som
	name = "\improper S30-C smoke grenade"
	desc = "A sophisticated version of the S30-S with a slighty improved smoke screen payload. It's set to detonate in 2 seconds."
	icon_state = "grenade_cloak_som"
	worn_icon_state = "grenade_cloak_som"

/obj/item/explosive/grenade/smokebomb/cloak/ags
	name = "\improper AGLS-37 SCDP smoke grenade"
	desc = "A small tiny smart grenade, it is about to blow up in your face, unless you found it inert. Otherwise a pretty normal grenade, other than it is somehow in a primeable state."
	icon_state = "ags_cloak"
	smokeradius = 4

/obj/item/explosive/grenade/smokebomb/drain
	name = "\improper M40-T smoke grenade"
	desc = "The M40-T is a small, but powerful Tanglefoot grenade, designed to remove plasma with minimal side effects. Based off the same platform as the M40 HEDP. It is set to detonate in 6 seconds."
	icon_state = "grenade_pgas"
	worn_icon_state = "grenade_pgas"
	hud_state = "grenade_drain"
	det_time = 6 SECONDS
	icon_state_mini = "grenade_blue"
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/plasmaloss
	smoke_duration = 11
	smokeradius = 7

/obj/item/explosive/grenade/smokebomb/antigas
	name = "\improper M40-AG smoke grenade"
	desc = "A gas grenade originally designed to remove any contaminants in the air for the purpose of cleaning, now repurposed to remove hostile gases."
	icon_state = "grenade_agas"
	worn_icon_state = "grenade_agas"
	hud_state = "grenade_antigas"
	det_time = 3 SECONDS
	icon_state_mini = "grenade_antigas"
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/antigas
	smoke_duration = 11
	smokeradius = 7

/obj/item/explosive/grenade/smokebomb/drain/agls
	name = "\improper AGLS-T smoke grenade"
	desc = "A small tiny smart grenade, it is about to blow up in your face, unless you found it inert. Otherwise a pretty normal grenade, other than it is somehow in a primeable state."
	icon_state = "ags_pgas"
	det_time = 3 SECONDS
	smokeradius = 4

/obj/item/explosive/grenade/smokebomb/drain/pellet
	name = "tanglefoot emitting system pellet"
	desc = "A small pellet dropped from the sky. Emits tanglefoot on a landing position."
	icon_state = "pellet_pgas"
	det_time = 2 SECONDS
	smokeradius = 10
	smoke_duration = 15
