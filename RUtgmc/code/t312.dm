///////// revolver ///////
//////////////////////////
/obj/item/weapon/gun/revolver/t312
	name = "R-312 'Albedo' Revolver"
	desc = "Futuristic style revolver with railgun system, using to fire EMB (experimental medical bullets). Just first make sure that you chambered EMB, but not .500 White Express."
	icon = 'icons/Marine/t500.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/BFR_left.dmi',
		slot_r_hand_str = 'icons/mob/BFR_right.dmi',)
	icon_state = "t312"
	item_state = "t312"
	caliber =  CALIBER_500_EMB
	max_chamber_items = 5 //codex
	default_ammo_type = /datum/ammo/bullet/revolver/t500/t312
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/t500/t312, /obj/item/ammo_magazine/revolver/t500/med/syna, /obj/item/ammo_magazine/revolver/t500/med/rr, /obj/item/ammo_magazine/revolver/t500/med/md, /obj/item/ammo_magazine/revolver/t500/med/rye, /obj/item/ammo_magazine/revolver/t500/med/neu)
	force = 20
	actions_types = null
	gun_skill_category = GUN_SKILL_DARTGUN
	attachable_allowed = list(
		/obj/item/attachable/lace/t500,
	)
	attachable_offset = list("muzzle_x" = 0, "muzzle_y" = 0,"rail_x" = 0, "rail_y" = 0, "under_x" = 19, "under_y" = 13, "stock_x" = -19, "stock_y" = 0)
	opened_sound = 'sound/weapons/guns/interact/type71_unload.ogg'
	fire_sound = 'sound/weapons/guns/fire/medt500.ogg'
	dry_fire_sound = 'sound/mecha/mag_bullet_insert.ogg'
	fire_animation = "t312_fire"
	fire_delay = 0.2 SECONDS
	muzzleflash_iconstate = "muzzle_flash_pulse"
	muzzle_flash_color = COLOR_PULSE_BLUE
	scatter = -7
	scatter_unwielded = -5
	damage_mult = 0.25
	recoil = 0
	recoil_unwielded = 0
	accuracy_mult = 3
	accuracy_mult_unwielded = 2
	type_of_casings = null
	akimbo_additional_delay = 0.6

////// White Express /////
/////////////////////////
/obj/item/ammo_magazine/revolver/t500/t312
	name = "\improper R-312 White Express speed loader (.500)"
	desc = "A R-312 'Albedo' revolver speed loader."
	icon_state = "t500_we"
	default_ammo = /datum/ammo/bullet/revolver/t500/t312
	caliber = CALIBER_500_EMB

/obj/item/ammo_magazine/packet/t500/t312
	name = "packet of .500 White Express"
	icon_state = "boxt500_we"
	default_ammo = /datum/ammo/bullet/revolver/t500/t312
	caliber = CALIBER_500_EMB

/obj/item/ammo_magazine/packet/t500/t312/Initialize()
	. = ..()
	if(prob(1))
		icon_state = "boxt500_ke"

/datum/ammo/bullet/revolver/t500/t312
	name = ".500 White Express revolver bullet"
	handful_icon_state = "nigro_we"

///////// packets ////////
/////////////////////////
/obj/item/ammo_magazine/packet/t500/med
	caliber = CALIBER_500_EMB
	current_rounds = 35
	max_rounds = 35
	w_class = WEIGHT_CLASS_SMALL
	used_casings = 1

/obj/item/ammo_magazine/packet/t500/med/syna
	name = "packet of .500 Synaptizine EMB"
	icon_state = "boxt500_syn"
	max_rounds = 50
	default_ammo = /datum/ammo/bullet/revolver/t500/med/syna

/obj/item/ammo_magazine/packet/t500/med/rr
	name = "packet of .500 Russian Red EMB"
	icon_state = "boxt500_rr"
	default_ammo = /datum/ammo/bullet/revolver/t500/med/rr

/obj/item/ammo_magazine/packet/t500/med/md
	name = "packet of .500 Meraderm EMB"
	icon_state = "boxt500_md"
	default_ammo = /datum/ammo/bullet/revolver/t500/med/md

/obj/item/ammo_magazine/packet/t500/med/rye
	name = "packet of .500 Ryetalyn EMB"
	icon_state = "boxt500_rye"
	default_ammo = /datum/ammo/bullet/revolver/t500/med/rye

/obj/item/ammo_magazine/packet/t500/med/neu
	name = "packet of .500 Neuraline EMB"
	icon_state = "boxt500_neu"
	max_rounds = 15
	default_ammo = /datum/ammo/bullet/revolver/t500/med/neu

///////// loaders ////////
/////////////////////////
/obj/item/ammo_magazine/revolver/t500/med
	name = "R-312 EMB speed loader"
	desc = "A R-500 'Albedo' revolver speed loader."
	caliber = CALIBER_500_EMB

/obj/item/ammo_magazine/revolver/t500/med/syna
	name = "R-312 Synaptizine EMB speed loader"
	icon_state = "t500_syn"
	default_ammo = /datum/ammo/bullet/revolver/t500/med/syna

/obj/item/ammo_magazine/revolver/t500/med/rr
	name = "R-312 Russian Red EMB speed loader"
	icon_state = "t500_rr"
	default_ammo = /datum/ammo/bullet/revolver/t500/med/rr

/obj/item/ammo_magazine/revolver/t500/med/md
	name = "R-312 Meraderm EMB speed loader"
	icon_state = "t500_md"
	default_ammo = /datum/ammo/bullet/revolver/t500/med/md

/obj/item/ammo_magazine/revolver/t500/med/rye
	name = "R-312 Ryetalyn EMB speed loader"
	icon_state = "t500_rye"
	default_ammo = /datum/ammo/bullet/revolver/t500/med/rye

/obj/item/ammo_magazine/revolver/t500/med/neu
	name = "R-312 Neuraline EMB speed loader"
	icon_state = "t500_neu"
	default_ammo = /datum/ammo/bullet/revolver/t500/med/neu

///////// bullets ////////
/////////////////////////
/datum/ammo/bullet/revolver/t500/med
	name = ".500"
	handful_icon_state = "nigro"
	accurate_range = 10
	handful_amount = 1
	damage = 25
	penetration = 100
	sundering = 0
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_ALIENS

/datum/ammo/bullet/revolver/t500/med/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 0, slowdown = 0, knockback = 0)

/datum/ammo/bullet/revolver/t500/med/syna
	name = ".500 Synaptizin EMB"
	handful_icon_state = "nigro_syn"
	hud_state = "t312_syn"

/datum/ammo/bullet/revolver/t500/med/syna/on_hit_mob(mob/M,obj/projectile/P)
	if(ishuman(M))
		M.reagents.add_reagent(/datum/reagent/medicine/synaptizine, 2)
		M.reagents.add_reagent(/datum/reagent/medicine/hyronalin, 3)
		return

/datum/ammo/bullet/revolver/t500/med/rr
	name = ".500 Russian Red EMB"
	handful_icon_state = "nigro_rr"
	hud_state = "t312_rr"

/datum/ammo/bullet/revolver/t500/med/rr/on_hit_mob(mob/M,obj/projectile/P)
	if(ishuman(M))
		M.reagents.add_reagent(/datum/reagent/medicine/russian_red, 5)
		return

/datum/ammo/bullet/revolver/t500/med/md
	name = "packet of .500 Meraderm EMB"
	handful_icon_state = "nigro_md"
	hud_state = "t312_md"

/datum/ammo/bullet/revolver/t500/med/md/on_hit_mob(mob/M,obj/projectile/P)
	if(ishuman(M))
		M.reagents.add_reagent(/datum/reagent/medicine/meralyne, 2.5)
		M.reagents.add_reagent(/datum/reagent/medicine/dermaline, 2.5)

/datum/ammo/bullet/revolver/t500/med/rye
	name = ".500 Ryetalyn EMB"
	handful_icon_state = "nigro_rye"
	hud_state = "t312_rye"

/datum/ammo/bullet/revolver/t500/med/rye/on_hit_mob(mob/M,obj/projectile/P)
	if(ishuman(M))
		M.reagents.add_reagent(/datum/reagent/medicine/ryetalyn, 5)

/datum/ammo/bullet/revolver/t500/med/neu
	name = ".500 Neuraline EMB"
	handful_icon_state = "nigro_neu"
	hud_state = "t312_neu"

/datum/ammo/bullet/revolver/t500/med/neu/on_hit_mob(mob/M,obj/projectile/P)
	if(ishuman(M))
		M.reagents.add_reagent(/datum/reagent/medicine/neuraline, 4)
		M.reagents.add_reagent(/datum/reagent/medicine/hyronalin, 6)

///////// storage ////////
/////////////////////////
/obj/item/storage/box/t312case
	name = "R-312 'Albedo' Revolver special case"
	desc = "High-tech case made by BMSS for delivery their special weapons. Label on this case says: 'Since we have already called Nigredo death, within the same metaphor we can call Albedo life. It is time to shoot at people legally.'"
	icon = 'icons/Marine/t500.dmi'
	icon_state = "med_case"
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = 1
	storage_slots = 7
	max_storage_space = 1
	bypass_w_limit = list(
		/obj/item/ammo_magazine/packet/t500/med/syna,
		/obj/item/ammo_magazine/packet/t500/med/rr,
		/obj/item/ammo_magazine/packet/t500/med/md,
		/obj/item/ammo_magazine/packet/t500/med/rye,
		/obj/item/ammo_magazine/packet/t500/med/neu,
		/obj/item/ammo_magazine/revolver/t500/med/syna,
		/obj/item/ammo_magazine/revolver/t500/med/rr,
		/obj/item/ammo_magazine/revolver/t500/med/md,
		/obj/item/ammo_magazine/revolver/t500/med/rye,
		/obj/item/ammo_magazine/revolver/t500/med/neu,
		/obj/item/storage/pouch/medkit/t312,
		/obj/item/attachable/lace/t500,
		/obj/item/weapon/gun/revolver/t312,
	)

/obj/item/storage/box/t312case/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/packet/t500/med/syna(src)
	new /obj/item/ammo_magazine/packet/t500/med/rr(src)
	new /obj/item/ammo_magazine/packet/t500/med/md(src)
	new /obj/item/ammo_magazine/packet/t500/med/rye(src)
	new /obj/item/ammo_magazine/revolver/t500/med/syna(src)
	new /obj/item/ammo_magazine/revolver/t500/med/rr(src)
	new /obj/item/ammo_magazine/revolver/t500/med/md(src)
	new /obj/item/ammo_magazine/revolver/t500/med/rye(src)
	new /obj/item/storage/pouch/medkit/t312(src)
	new /obj/item/attachable/lace/t500(src)
	new /obj/item/weapon/gun/revolver/t312(src)

/obj/item/storage/pouch/medkit/t312
	name = "BMSS medkit pouch"
	desc = "Advanced medkit pouch made by BMSS. it also can hold R-312 ammo and tweezers."
	icon = 'icons/Marine/t500.dmi'
	icon_state = "medkit"
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/storage/pill_bottle/packet,
		/obj/item/reagent_containers/hypospray,
		/obj/item/ammo_magazine/packet/t500/med,
		/obj/item/ammo_magazine/revolver/t500/med,
		/obj/item/tweezers,
	)

///////// cargo //////////
/////////////////////////
/datum/supply_packs/medical/t312case
	name = "R-312 'Albedo' Revolver bundle"
	contains = list(/obj/item/storage/box/t312case)
	cost = 330

/datum/supply_packs/medical/t312
	name = "R-312 'Albedo' Revolver"
	contains = list(/obj/item/attachable/lace/t500, /obj/item/weapon/gun/revolver/t312)
	cost = 120

/datum/supply_packs/medical/t312_syn
	name = "R-312 packet of .500 Synaptizin EMB"
	contains = list(/obj/item/ammo_magazine/packet/t500/med/syna, /obj/item/ammo_magazine/revolver/t500/med/syna)
	cost = 50

/datum/supply_packs/medical/t312_rr
	name = "R-312 packet of .500 Russian Red EMB"
	contains = list(/obj/item/ammo_magazine/packet/t500/med/rr, /obj/item/ammo_magazine/revolver/t500/med/rr)
	cost = 40

/datum/supply_packs/medical/t312_md
	name = "R-312 packet of .500 Meraderm EMB"
	contains = list(/obj/item/ammo_magazine/packet/t500/med/md, /obj/item/ammo_magazine/revolver/t500/med/md)
	cost = 90

/datum/supply_packs/medical/t312_neu
	name = "R-312 packet of .500 Neuraline EMB"
	contains = list(/obj/item/ammo_magazine/packet/t500/med/neu, /obj/item/ammo_magazine/revolver/t500/med/neu)
	cost = 90

/datum/supply_packs/medical/t312_rye
	name = "R-312 packet of .500 Ryetalyn EMB"
	contains = list(/obj/item/ammo_magazine/packet/t500/med/rye, /obj/item/ammo_magazine/revolver/t500/med/rye)
	cost = 20

/datum/supply_packs/medical/t312_medkit
	name = "BMSS medkit pouch"
	contains = list(/obj/item/storage/pouch/medkit/t312)
	cost = 10

/obj/effect/vendor_bundle/neu_bullets
	desc = "R-312 Neuraline EMB kit, has safe mixture of neuraline and hyronaline."
	gear_to_spawn = list(
		/obj/item/ammo_magazine/packet/t500/med/neu,
		/obj/item/ammo_magazine/revolver/t500/med/neu,
	)










