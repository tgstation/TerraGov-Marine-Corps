


//-------------------------------------------------------
//M41A PULSE RIFLE AMMUNITION

/obj/item/ammo_magazine/rifle/
	name = "\improper PR-412 magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "m412"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 40
	icon_state_mini = "mag_rifle"

/obj/item/ammo_magazine/rifle/extended
	name = "\improper PR-412 extended magazine (10x24mm)"
	desc = "A 10mm assault extended rifle magazine."
	icon_state = "m412_ext"
	max_rounds = 60
	icon_state_mini = "mag_rifle_big_yellow"
	bonus_overlay = "m412_ex"

/obj/item/ammo_magazine/rifle/incendiary
	name = "\improper PR-412 incendiary magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	icon_state = "m412_incendiary"
	default_ammo = /datum/ammo/bullet/rifle/incendiary
	icon_state_mini = "mag_rifle_big_red"
	bonus_overlay = "m412_incend"

/obj/item/ammo_magazine/rifle/ap
	name = "\improper PR-412 AP magazine (10x24mm)"
	desc = "A 10mm armor piercing magazine."
	icon_state = "m412_ap"
	default_ammo = /datum/ammo/bullet/rifle/ap
	icon_state_mini = "mag_rifle_big_green"
	bonus_overlay = "m412_ap"

//-------------------------------------------------------
//T18 Carbine

/obj/item/ammo_magazine/rifle/standard_carbine
	name = "\improper AR-18 magazine (10x24mm)"
	desc = "A 10mm carbine magazine."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "t18"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 36
	icon_state_mini = "mag_rifle_big"

/obj/item/ammo_magazine/rifle/standard_carbine/ap
	name = "\improper AR-18 AP magazine (10x24mm)"
	desc = "A 10mm armor piercing carbine magazine."
	icon_state = "t18_ap"
	bonus_overlay = "t18_ap"
	default_ammo = /datum/ammo/bullet/rifle/ap
	max_rounds = 36

//-------------------------------------------------------
//T12 Assault Rifle

/obj/item/ammo_magazine/rifle/standard_assaultrifle
	name = "\improper AR-12 magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "t12"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 50
	icon_state_mini = "mag_rifle_big"

/obj/item/ammo_magazine/rifle/standard_assaultrifle/ap
	name = "\improper AR-12 AP magazine (10x24mm)"
	desc = "A 10mm armor piercing assault rifle magazine."
	icon_state = "t12_ap"
	bonus_overlay = "t12_ap"
	default_ammo = /datum/ammo/bullet/rifle/ap
	max_rounds = 50

//-------------------------------------------------------
//T37 DMR

/obj/item/ammo_magazine/rifle/standard_dmr
	name = "\improper DMR-37 magazine (10x27mm)"
	desc = "A 10mm DMR magazine."
	caliber = CALIBER_10x27_CASELESS
	icon_state = "t37"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr
	max_rounds = 20
	icon_state_mini = "mag_dmr"

//-------------------------------------------------------
//T64 BR

/obj/item/ammo_magazine/rifle/standard_br
	name = "\improper BR-64 magazine (10x26.5mm)"
	desc = "A 10mm battle rifle magazine."
	caliber = CALIBER_10x265_CASELESS
	icon_state = "t64"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_br
	max_rounds = 36
	icon_state_mini = "mag_rifle_big"

/obj/item/ammo_magazine/rifle/standard_br/ap
	name = "\improper BR-64 AP magazine (10x26.5mm)"
	desc = "A 10mm armor piercing battle rifle magazine."
	caliber = CALIBER_10x265_CASELESS
	icon_state = "t64_ap"
	bonus_overlay = "t64_ap"
	default_ammo = /datum/ammo/bullet/rifle/standard_br/ap
	icon_state_mini = "mag_rifle_big"

//-------------------------------------------------------
//M41A TRUE AND ORIGINAL

/obj/item/ammo_magazine/rifle/m41a
	name = "\improper PR-11 magazine (10x24mm)"
	desc = "A semi-rectangular box of rounds for the PR-11 Pulse Rifle."
	icon_state = "m41a"
	max_rounds = 95
	icon_state_mini = "mag_rifle_big"


//-------------------------------------------------------
//Kalashnikov rifles

/obj/item/ammo_magazine/rifle/mpi_km
	name = "\improper MPi-KM magazine (7.62x39mm)"
	desc = "A 40 round 7.62x39mm magazine for the Kalashnikov series of firearms."
	caliber = CALIBER_762X39
	icon_state = "ak_40"
	bonus_overlay = "ak_40"
	default_ammo = /datum/ammo/bullet/rifle/mpi_km
	max_rounds = 40
	icon_state_mini = "mag_rifle_big"
	scatter_mod = 2
	aim_speed_mod = 0.1
	wield_delay_mod = 0.1 SECONDS

/obj/item/ammo_magazine/rifle/mpi_km/plum
	desc = "A 7.62x39mm magazine for the Kalashnikov series of firearms. This one had an old plum finish."
	icon_state = "ak_40_plum"
	bonus_overlay = "ak_40_plum"

/obj/item/ammo_magazine/rifle/mpi_km/black
	desc = "A 7.62x39mm magazine for the Kalashnikov series of firearms. This one had an modern black polymer finish."
	icon_state = "ak_40_black"
	bonus_overlay = "ak_40_black"

/obj/item/ammo_magazine/rifle/mpi_km/carbine
	name = "\improper V-34 magazine (7.62x39mm)"
	desc = "A 30 round 7.62x39mm magazine for the Kalashnikov series of firearms."
	icon_state = "ak_30"
	bonus_overlay = "ak_30"
	max_rounds = 30
	scatter_mod = 0
	aim_speed_mod = 0
	wield_delay_mod = 0

/obj/item/ammo_magazine/rifle/mpi_km/carbine/plum
	desc = "A 30 round 7.62x39mm magazine for the Kalashnikov series of firearms. This one had an old plum finish."
	icon_state = "ak_30_plum"
	bonus_overlay = "ak_30_plum"

/obj/item/ammo_magazine/rifle/mpi_km/carbine/black
	desc = "A 30 round 7.62x39mm magazine for the Kalashnikov series of firearms. This one had an modern black polymer finish."
	icon_state = "ak_30_black"
	bonus_overlay = "ak_30_black"

/obj/item/ammo_magazine/rifle/mpi_km/extended
	name = "\improper MPi-KM extended magazine (7.62x39mm)"
	desc = "A 60 round 7.62x39mm Kalashnikov magazine. this one is notably heavy."
	icon_state = "ak47_ext"
	bonus_overlay = "ak47_ex"
	max_rounds = 60
	aim_speed_mod = 0.2
	wield_delay_mod = 0.2

// RPD

/obj/item/ammo_magazine/rifle/lmg_d
	name = "\improper lMG-D drum magazine (7.62x39mm)"
	desc = "A 100 round 7.62x39mm Kalashnikov drum, won't fit on most kalasnikov rifles, as it is made for the beltfed variant."
	caliber = CALIBER_762X39
	default_ammo = /datum/ammo/bullet/rifle/mpi_km
	icon_state = "rpd"
	bonus_overlay = "rpd_100"
	max_rounds = 100

//-------------------------------------------------------
//M16 RIFLE

/obj/item/ammo_magazine/rifle/m16
	name = "\improper M16 magazine (5.56x45mm)"
	desc = "A 5.56x45mm magazine for the M16 assault rifle platform."
	caliber = CALIBER_556X45
	icon_state = "m16" //PLACEHOLDER
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 30 //Also comes in 30 and 100 round Beta-C mag.
	icon_state_mini = "mag_rifle_big"

//-------------------------------------------------------
//FAMAS RIFLE

/obj/item/ammo_magazine/rifle/famas
	name = "\improper FAMAS magazine (5.56x45mm)"
	desc = "A 5.56x45mm magazine for the FAMAS assault rifle."
	caliber = CALIBER_556X45
	icon_state = "famas"
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 24

//-------------------------------------------------------
//MG-42 Light Machine Gun

/obj/item/ammo_magazine/standard_lmg
	name = "\improper MG-42 drum magazine (10x24mm)"
	desc = "A drum magazine for the MG-42 light machine gun."
	icon_state = "t42"
	caliber = CALIBER_10X24_CASELESS
	default_ammo = /datum/ammo/bullet/rifle
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 120
	icon_state_mini = "mag_t42"

//-------------------------------------------------------
//MG-60 General Purpose Machine Gun

/obj/item/ammo_magazine/standard_gpmg
	name = "\improper MG-60 GPMG box magazine (10x26mm)"
	desc = "A belt box for the MG-60 general purpose machinegun."
	icon_state = "t60"
	caliber = CALIBER_10x26_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/machinegun
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 200
	reload_delay = 3 SECONDS
	icon_state_mini = "mag_gpmg"

//-------------------------------------------------------
//PR-412L1 HEAVY PULSE RIFLE

/obj/item/ammo_magazine/m412l1_hpr
	name = "\improper PR-412L1 box magazine (10x24mm)"
	desc = "A semi-rectangular box of rounds for the PR-412L1 heavy pulse rifle."
	icon_state = "m412l1"
	caliber = CALIBER_10X24_CASELESS
	default_ammo = /datum/ammo/bullet/rifle
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 200
	icon_state_mini = "mag_gpmg"

//-------------------------------------------------------
//UPP TYPE 71 RIFLE

/obj/item/ammo_magazine/rifle/type71
	name = "\improper Type 71 magazine (7.62x39mm)"
	desc = "A 7.62x39mm magazine that fits in the Type 71 rifle."
	caliber = CALIBER_762X39
	icon_state = "type_71"
	default_ammo = /datum/ammo/bullet/rifle/mpi_km
	max_rounds = 42
	icon_state_mini = "mag_rifle_big"

//TX-16 AUTOMATIC SHOTGUN

/obj/item/ammo_magazine/rifle/tx15_flechette
	name = "\improper SH-15 flechette magazine (16 gauge)"
	desc = "A magazine of 16 gauge flechette rounds, for the SH-15."
	caliber = CALIBER_16G
	icon_state = "tx15_flechette"
	default_ammo = /datum/ammo/bullet/shotgun/tx15_flechette
	max_rounds = 12
	icon_state_mini = "mag_tx15_flechette"
	bonus_overlay = "tx15_flech"

/obj/item/ammo_magazine/rifle/tx15_slug
	name = "\improper SH-15 slug magazine (16 gauge)"
	desc = "A magazine of 16 gauge slugs, for the SH-15."
	caliber = CALIBER_16G
	icon_state = "tx15_slug"
	default_ammo = /datum/ammo/bullet/shotgun/tx15_slug
	max_rounds = 12
	icon_state_mini = "mag_tx15_slug"
	bonus_overlay = "tx15_slug"

//-------------------------------------------------------
//SMARTMACHINEGUN AMMUNITION

/obj/item/ammo_magazine/standard_smartmachinegun
	name = "\improper SG-29 drum magazine"
	desc = "A wide drum magazine carefully filled to capacity with 10x26mm specialized smart rounds."
	caliber = CALIBER_10x26_CASELESS
	icon_state = "sg29"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/smartmachinegun
	max_rounds = 250
	reload_delay = 2.5 SECONDS
	icon_state_mini = "mag_sg29"

//-------------------------------------------------------
//Sectoid Rifle

/obj/item/ammo_magazine/rifle/sectoid_rifle
	name = "alien rifle plasma magazine"
	desc = "A magazine filled with powerful plasma rounds. The ammo inside doesn't look like anything you've seen before."
	caliber = CALIBER_ALIEN
	icon_state = "alien_rifle"
	default_ammo = /datum/ammo/energy/plasma
	max_rounds = 20
	icon_state_mini = "mag_rifle_purple"

//-------------------------------------------------------
//Marine magazine sniper, or the SR-127.
/obj/item/ammo_magazine/rifle/chamberedrifle
	name = "SR-127 bolt action rifle magazine"
	desc = "A box magazine filled with 8.6x70mm rifle rounds for the SR-127."
	caliber = CALIBER_86X70
	icon_state = "tl127"
	default_ammo = /datum/ammo/bullet/sniper/pfc
	max_rounds = 10
	icon_state_mini = "mag_sniper"
	bonus_overlay = "tl127_mag"

/obj/item/ammo_magazine/rifle/chamberedrifle/flak
	name = "SR-127 bolt action rifle flak magazine"
	desc = "A box magazine filled with 8.6x70mm rifle flak rounds for the SR-127."
	icon_state = "tl127_flak"
	default_ammo = /datum/ammo/bullet/sniper/pfc/flak
	icon_state_mini = "mag_sniper_blue"
	bonus_overlay = "tl127_flak"

//-------------------------------------------------------
//Marine magazine automatic sniper, or the SR-81.
/obj/item/ammo_magazine/rifle/autosniper
	name = "\improper SR-81 automatic sniper rifle magazine"
	desc = "A box magazine filled with low pressure 8.6x70mm rifle rounds for the SR-81."
	caliber = CALIBER_86X70
	icon_state = "t81"
	default_ammo = /datum/ammo/bullet/sniper/auto
	max_rounds = 20
	icon_state_mini = "mag_sniper"

//-------------------------------------------------------
//G-11, AR-11
/obj/item/ammo_magazine/rifle/tx11
	name = "\improper AR-11 combat rifle magazine"
	desc = "A magazine filled with 4.92×34mm rifle rounds for the AR-11."
	caliber = CALIBER_492X34_CASELESS
	icon_state = "tx11"
	default_ammo = /datum/ammo/bullet/rifle/hv
	max_rounds = 70
	icon_state_mini = "mag_tx11"

//-------------------------------------------------------
//AR-21
/obj/item/ammo_magazine/rifle/standard_skirmishrifle
	name = "\improper AR-21 skirmish rifle magazine"
	desc = "A magazine filled with 10x25mm rifle rounds for the AR-21."
	caliber = CALIBER_10X25_CASELESS
	icon_state = "t21"
	default_ammo = /datum/ammo/bullet/rifle/heavy
	max_rounds = 30
	icon_state_mini = "mag_rifle"

/obj/item/ammo_magazine/rifle/standard_skirmishrifle/ap
	name = "\improper AR-21 skirmish AP rifle magazine"
	desc = "A magazine filled with 10x25mm armor piercing rifle rounds for the AR-21."
	icon_state = "t21_ap"
	bonus_overlay = "t21_ap"
	default_ammo = /datum/ammo/bullet/rifle/heavy/ap

//ALF-51B

/obj/item/ammo_magazine/rifle/alf_machinecarbine
	name = "\improper ALF-51B box magazine (10x25mm)"
	desc = "A box magazine for the ALF-51B machinecarbine."
	icon_state = "t60"
	caliber = CALIBER_10X25_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/som_machinegun
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 80
	reload_delay = 1 SECONDS
	icon_state_mini = "mag_t42"

//-------------------------------------------------------
//MKH98

/obj/item/ammo_magazine/rifle/mkh
	name = "\improper MKH-98 storm rifle magazine"
	desc = "A magazine filled with 7.62X39 rifle rounds for the MKH."
	caliber = CALIBER_762X39
	icon_state = "mkh98"
	default_ammo = /datum/ammo/bullet/rifle/heavy
	max_rounds = 30
	icon_state_mini = "mag_rifle"

//-------------------------------------------------------
//GL-54 and AR-55

/obj/item/ammo_magazine/rifle/tx55
	name = "\improper AR-55 magazine (10x24mm)"
	desc = "A small capacity 10mm rifle magazine. Differs from a AR-18 magazine enough to bypass relevant patents."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "tx55"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 36
	icon_state_mini = "mag_rifle_big"

/obj/item/ammo_magazine/rifle/tx54
	name = "\improper 20mm airburst grenade magazine"
	desc = "A 20mm magazine loaded with airburst grenades. For use with the GL-54 or AR-55."
	caliber = CALIBER_20MM
	icon_state = "tx54_airburst"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/tx54
	max_rounds = 8
	icon_state_mini = "mag_sniper"
	greyscale_config = /datum/greyscale_config/ammo
	greyscale_colors = COLOR_AMMO_AIRBURST

/obj/item/ammo_magazine/rifle/tx54/he
	name = "\improper 20mm HE grenade magazine"
	desc = "A 20mm magazine loaded with HE grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/he
	icon_state = "tx54_airburst"
	greyscale_colors = COLOR_AMMO_HIGH_EXPLOSIVE

/obj/item/ammo_magazine/rifle/tx54/incendiary
	name = "\improper 20mm incendiary grenade magazine"
	desc = "A 20mm magazine loaded with incendiary grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/incendiary
	icon_state = "tx54_airburst"
	greyscale_colors = COLOR_AMMO_INCENDIARY

/obj/item/ammo_magazine/rifle/tx54/smoke
	name = "\improper 20mm tactical smoke grenade magazine"
	desc = "A 20mm magazine loaded with tactical smoke grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/smoke
	icon_state = "tx54_airburst"
	greyscale_colors = COLOR_AMMO_TACTICAL_SMOKE

/obj/item/ammo_magazine/rifle/tx54/smoke/dense
	name = "\improper 20mm smoke grenade magazine"
	desc = "A 20mm magazine loaded with smoke grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/smoke/dense
	icon_state = "tx54_airburst"
	greyscale_colors = COLOR_AMMO_SMOKE

/obj/item/ammo_magazine/rifle/tx54/smoke/tangle
	name = "\improper 20mm tanglefoot grenade magazine"
	desc = "A 20mm magazine loaded with tanglefoot grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/smoke/tangle
	icon_state = "tx54_airburst"
	greyscale_colors = COLOR_AMMO_TANGLEFOOT

/obj/item/ammo_magazine/rifle/tx54/razor
	name = "\improper 20mm razorburn grenade magazine"
	desc = "A 20mm magazine loaded with razorburn grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/razor
	icon_state = "tx54_airburst"
	greyscale_colors = COLOR_AMMO_RAZORBURN

//-------------------------------------------------------
//Garand
/obj/item/ammo_magazine/rifle/garand
	name = "C1 Garand enbloc clip"
	desc = "A enbloc clip filled with .30 caliber rifle rounds for the C1 Garand."
	caliber = CALIBER_3006
	icon_state = "garand"
	default_ammo = /datum/ammo/bullet/rifle/garand
	max_rounds = 8
	icon_state_mini = "mag_sniper"

//-------------------------------------------------------
//V-31 SOM rifle

/obj/item/ammo_magazine/rifle/som
	name = "\improper V-31 magazine (10x24mm)"
	desc = "A 10mm rifle magazine designed for the V-31."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "v31"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 50
	icon_state_mini = "mag_rifle_big"

/obj/item/ammo_magazine/rifle/som/ap
	name = "\improper V-31 AP magazine (10x24mm)"
	desc = "A 10mm rifle magazine designed for the V-31, loaded with armor piercing rounds."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "v31_ap"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/hv
	max_rounds = 50
	icon_state_mini = "mag_rifle_big_green"

/obj/item/ammo_magazine/rifle/som/incendiary
	name = "\improper V-31 incendiary magazine (10x24mm)"
	desc = "A 10mm rifle magazine designed for the V-31, loaded with incendiary rounds."
	icon_state = "v31_incend"
	default_ammo = /datum/ammo/bullet/rifle/incendiary
	icon_state_mini = "mag_rifle_big_red"

//-------------------------------------------------------
//V-41 Machine Gun

/obj/item/ammo_magazine/som_mg
	name = "\improper V-41 box magazine (10x26mm)"
	desc = "A drum magazine for the V-41 machinegun."
	icon_state = "v41"
	caliber = CALIBER_10x26_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/som_machinegun
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 200
	reload_delay = 3 SECONDS
	icon_state_mini = "mag_gpmg"
