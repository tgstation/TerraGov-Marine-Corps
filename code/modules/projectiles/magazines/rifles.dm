//-------------------------------------------------------
//M41A PULSE RIFLE AMMUNITION

/obj/item/ammo_magazine/rifle/
	name = "\improper PR-412 magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "m412"
	icon = 'icons/obj/items/ammo/rifle.dmi'
	icon_state_mini = "mag_rifle"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 40

/obj/item/ammo_magazine/rifle/extended
	name = "\improper PR-412 extended magazine (10x24mm)"
	desc = "A 10mm assault extended rifle magazine."
	icon_state = "m412_ext"
	icon_state_mini = "mag_rifle_big_yellow"
	max_rounds = 60
	bonus_overlay = "m412_ex"

/obj/item/ammo_magazine/rifle/incendiary
	name = "\improper PR-412 incendiary magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	icon_state = "m412_incendiary"
	icon_state_mini = "mag_rifle_big_red"
	default_ammo = /datum/ammo/bullet/rifle/incendiary
	bonus_overlay = "m412_incend"

/obj/item/ammo_magazine/rifle/ap
	name = "\improper PR-412 AP magazine (10x24mm)"
	desc = "A 10mm armor piercing magazine."
	icon_state = "m412_ap"
	icon_state_mini = "mag_rifle_big_green"
	default_ammo = /datum/ammo/bullet/rifle/ap
	bonus_overlay = "m412_ap"

//-------------------------------------------------------
//T18 Carbine

/obj/item/ammo_magazine/rifle/standard_carbine
	name = "\improper AR-18 magazine (10x24mm)"
	desc = "A 10mm carbine magazine."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "t18"
	icon_state_mini = "mag_rifle_big"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 36

/obj/item/ammo_magazine/rifle/standard_carbine/ap
	name = "\improper AR-18 AP magazine (10x24mm)"
	desc = "A 10mm assault carbine magazine, loaded with light armor piercing rounds."
	icon_state = "t18_ap"
	icon_state_mini = "mag_rifle_big_green"
	default_ammo = /datum/ammo/bullet/rifle/hv
	bonus_overlay = "t18_ap"

//-------------------------------------------------------
//T12 Assault Rifle

/obj/item/ammo_magazine/rifle/standard_assaultrifle
	name = "\improper AR-12 magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "t12"
	icon_state_mini = "mag_rifle_big"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 50

/obj/item/ammo_magazine/rifle/standard_assaultrifle/ap
	name = "\improper AR-12 AP magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine, loaded with light armor piercing rounds."
	icon_state = "t12_ap"
	icon_state_mini = "mag_rifle_big_green"
	default_ammo = /datum/ammo/bullet/rifle/hv
	bonus_overlay = "t12_ap"

//-------------------------------------------------------
//T37 DMR

/obj/item/ammo_magazine/rifle/standard_dmr
	name = "\improper DMR-37 magazine (10x27mm)"
	desc = "A 10mm DMR magazine."
	caliber = CALIBER_10x27_CASELESS
	icon_state = "t37"
	icon_state_mini = "mag_rifle_big"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr
	max_rounds = 20

//-------------------------------------------------------
//T64 BR

/obj/item/ammo_magazine/rifle/standard_br
	name = "\improper BR-64 magazine (10x26.5mm)"
	desc = "A 10mm battle rifle magazine."
	caliber = CALIBER_10x265_CASELESS
	icon_state = "t64"
	icon_state_mini = "mag_rifle_big"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_br
	max_rounds = 36

//-------------------------------------------------------
//M41A TRUE AND ORIGINAL

/obj/item/ammo_magazine/rifle/m41a
	name = "\improper PR-11 magazine (10x24mm)"
	desc = "A semi-rectangular box of rounds for the PR-11 Pulse Rifle."
	icon_state = "m41a"
	icon_state_mini = "mag_rifle_big_light"
	max_rounds = 95


//-------------------------------------------------------
//Kalashnikov rifles

/obj/item/ammo_magazine/rifle/mpi_km
	name = "\improper MPi-KM magazine (7.62x39mm)"
	desc = "A 40 round 7.62x39mm magazine for the Kalashnikov series of firearms."
	caliber = CALIBER_762X39
	icon_state = "ak_40"
	icon_state_mini = "mag_rifle_brown"
	bonus_overlay = "ak_40"
	default_ammo = /datum/ammo/bullet/rifle/mpi_km
	max_rounds = 40
	scatter_mod = 2
	aim_speed_mod = 0.1
	wield_delay_mod = 0.1 SECONDS

/obj/item/ammo_magazine/rifle/mpi_km/plum
	desc = "A 7.62x39mm magazine for the Kalashnikov series of firearms. This one had an old plum finish."
	icon_state = "ak_40_plum"
	icon_state_mini = "mag_rifle_darkpurple"
	bonus_overlay = "ak_40_plum"

/obj/item/ammo_magazine/rifle/mpi_km/black
	desc = "A 7.62x39mm magazine for the Kalashnikov series of firearms. This one had an modern black polymer finish."
	icon_state = "ak_40_black"
	icon_state_mini = "mag_rifle"
	bonus_overlay = "ak_40_black"

/obj/item/ammo_magazine/rifle/mpi_km/carbine
	name = "\improper V-34 magazine (7.62x39mm)"
	desc = "A 30 round 7.62x39mm magazine for the Kalashnikov series of firearms."
	icon_state = "ak_30"
	icon_state_mini = "mag_rifle_brown"
	bonus_overlay = "ak_30"
	max_rounds = 30
	scatter_mod = 0
	aim_speed_mod = 0
	wield_delay_mod = 0

/obj/item/ammo_magazine/rifle/mpi_km/carbine/plum
	desc = "A 30 round 7.62x39mm magazine for the Kalashnikov series of firearms. This one had an old plum finish."
	icon_state = "ak_30_plum"
	icon_state_mini = "mag_rifle_darkpurple"
	bonus_overlay = "ak_30_plum"

/obj/item/ammo_magazine/rifle/mpi_km/carbine/black
	desc = "A 30 round 7.62x39mm magazine for the Kalashnikov series of firearms. This one had an modern black polymer finish."
	icon_state = "ak_30_black"
	icon_state_mini = "mag_rifle"
	bonus_overlay = "ak_30_black"

/obj/item/ammo_magazine/rifle/mpi_km/extended
	name = "\improper MPi-KM extended magazine (7.62x39mm)"
	desc = "A 60 round 7.62x39mm Kalashnikov magazine. this one is notably heavy."
	icon_state = "ak47_ext"
	icon_state_mini = "mag_rifle"
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
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_drum_big"
	bonus_overlay = "rpd_100"
	max_rounds = 100

//-------------------------------------------------------
//DP-27

/obj/item/ammo_magazine/rifle/dpm
	name = "\improper Degtyaryov drum AP magazine (7.62x39mm)"
	desc = "A drum magazine for the Degtyaryov machine gun."
	caliber = CALIBER_762X39
	icon_state = "dp27"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	default_ammo = /datum/ammo/bullet/rifle/ap
	max_rounds = 47
	icon_state_mini = "dpm"

//-------------------------------------------------------
//M16 RIFLE

/obj/item/ammo_magazine/rifle/m16
	name = "\improper M16 magazine (5.56x45mm)"
	desc = "A 5.56x45mm magazine for the M16 assault rifle platform."
	caliber = CALIBER_556X45
	icon_state = "m16" //PLACEHOLDER
	icon_state_mini = "mag_rifle_big"
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 30 //Also comes in 30 and 100 round Beta-C mag.

//-------------------------------------------------------
//FAMAS RIFLE

/obj/item/ammo_magazine/rifle/famas
	name = "\improper FAMAS magazine (5.56x45mm)"
	desc = "A 5.56x45mm magazine for the FAMAS assault rifle."
	caliber = CALIBER_556X45
	icon_state = "famas"
	icon_state_mini = "mag_rifle_greyblue"
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 24

//-------------------------------------------------------
//MG-42 Light Machine Gun

/obj/item/ammo_magazine/standard_lmg
	name = "\improper MG-42 drum magazine (10x24mm)"
	desc = "A drum magazine for the MG-42 light machine gun."
	icon_state = "t42"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_drum"
	caliber = CALIBER_10X24_CASELESS
	default_ammo = /datum/ammo/bullet/rifle
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 120

//-------------------------------------------------------
//MG-60 General Purpose Machine Gun

/obj/item/ammo_magazine/standard_gpmg
	name = "\improper MG-60 GPMG box magazine (10x26mm)"
	desc = "A belt box for the MG-60 general purpose machinegun."
	icon_state = "t60"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_gpmg"
	caliber = CALIBER_10x26_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/machinegun
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 200
	reload_delay = 3 SECONDS

//-------------------------------------------------------
//PR-412L1 HEAVY PULSE RIFLE

/obj/item/ammo_magazine/m412l1_hpr
	name = "\improper PR-412L1 box magazine (10x24mm)"
	desc = "A semi-rectangular box of rounds for the PR-412L1 heavy pulse rifle."
	icon_state = "m412l1"
	icon = 'icons/obj/items/ammo/rifle.dmi'
	icon_state_mini = "mag_box"
	caliber = CALIBER_10X24_CASELESS
	default_ammo = /datum/ammo/bullet/rifle
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 200

//-------------------------------------------------------
//UPP TYPE 71 RIFLE

/obj/item/ammo_magazine/rifle/type71
	name = "\improper Type 71 magazine (7.62x39mm)"
	desc = "A 7.62x39mm magazine that fits in the Type 71 rifle."
	caliber = CALIBER_762X39
	icon_state = "type_71"
	icon_state_mini = "mag_rifle_big"
	default_ammo = /datum/ammo/bullet/rifle/mpi_km
	max_rounds = 42

//-------------------------------------------------------
//PMC PR-416
/obj/item/ammo_magazine/rifle/m416
	name = "\improper RA-SH-416 magazine (10x25mm AP)"
	desc = "A 10x25mm armor-piercing magazine."
	caliber = CALIBER_10X25_CASELESS
	icon_state = "pr416"
	icon_state_mini = "mag_rifle_big"
	default_ammo = /datum/ammo/bullet/rifle/heavy/ap
	max_rounds = 40


//TX-16 AUTOMATIC SHOTGUN

/obj/item/ammo_magazine/rifle/tx15_flechette
	name = "\improper SH-15 flechette magazine (16 gauge)"
	desc = "A magazine of 16 gauge flechette rounds, for the SH-15."
	caliber = CALIBER_16G
	icon_state = "tx15_flechette"
	icon_state_mini = "mag_tx15_flechette"
	default_ammo = /datum/ammo/bullet/shotgun/tx15_flechette
	max_rounds = 12
	bonus_overlay = "tx15_flech"

/obj/item/ammo_magazine/rifle/tx15_slug
	name = "\improper SH-15 slug magazine (16 gauge)"
	desc = "A magazine of 16 gauge slugs, for the SH-15."
	caliber = CALIBER_16G
	icon_state = "tx15_slug"
	icon_state_mini = "mag_tx15_slug"
	default_ammo = /datum/ammo/bullet/shotgun/tx15_slug
	max_rounds = 12
	bonus_overlay = "tx15_slug"

//-------------------------------------------------------
//SMARTMACHINEGUN AMMUNITION

/obj/item/ammo_magazine/standard_smartmachinegun
	name = "\improper SG-29 drum magazine"
	desc = "A wide drum magazine carefully filled to capacity with 10x26mm specialized smart rounds."
	caliber = CALIBER_10x26_CASELESS
	icon_state = "sg29"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_sg29"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/smartmachinegun
	max_rounds = 250
	reload_delay = 2.5 SECONDS

/obj/item/ammo_magazine/smart_gpmg
	name = "\improper SG-60 box magazine (10x26mm HP)"
	desc = "A belt box for the SG-60 machinegun."
	icon_state = "sg60"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_gpmg"
	caliber = CALIBER_10x26_CASELESS
	default_ammo = /datum/ammo/bullet/smartmachinegun
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 250
	reload_delay = 3 SECONDS

//-------------------------------------------------------
//SMART TARGET RIFLE AMMUNITION

/obj/item/ammo_magazine/rifle/standard_smarttargetrifle
	name = "\improper SG-62 magazine (10x27mm HV)"
	desc = "A magazine filled with 10x27mm specialized smart rounds."
	caliber = CALIBER_10x27_CASELESS
	icon_state = "sg62"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/smarttargetrifle
	max_rounds = 40
	icon_state_mini = "mag_rifle"

//-------------------------------------------------------
//SPOTTING RIFLE AMMUNITION

/obj/item/ammo_magazine/rifle/standard_spottingrifle
	name = "\improper SG-153 magazine (12.7mm Smart Magnum)"
	desc = "A magazine filled with 12.7mm lethal smart rounds, these will do nothing other than pack a big punch."
	caliber = CALIBER_12x7
	icon_state = "sg153"
	icon_state_mini = "mag_rifle"
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/bullet/spottingrifle
	max_rounds = 5

/obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact
	name = "\improper SG-153 high impact magazine (12.7mm Smart Magnum)"
	desc = "A magazine filled with 12.7mm high impact smart rounds, these will likely stagger and slow anything they hit."
	icon_state = "sg153_hi"
	icon_state_mini = "mag_rifle_blue"
	default_ammo = /datum/ammo/bullet/spottingrifle/highimpact

/obj/item/ammo_magazine/rifle/standard_spottingrifle/heavyrubber
	name = "\improper SG-153 heavy rubber magazine (12.7mm Smart Magnum)"
	desc = "A magazine filled with 12.7mm heavy rubber smart rounds, these will likely stun and displace anything they hit."
	icon_state = "sg153_hr"
	icon_state_mini = "mag_rifle_red"
	default_ammo = /datum/ammo/bullet/spottingrifle/heavyrubber

/obj/item/ammo_magazine/rifle/standard_spottingrifle/plasmaloss
	name = "\improper SG-153 tanglefoot magazine (12.7mm Smart Magnum)"
	desc = "A magazine filled with 12.7mm smart rounds tipped with 'Tanglefoot' poison, these rounds will drain the energy out of targets they hit."
	icon_state = "sg153_pl"
	icon_state_mini = "mag_rifle_purple"
	default_ammo = /datum/ammo/bullet/spottingrifle/plasmaloss

/obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten
	name = "\improper SG-153 tungsten magazine (12.7mm Smart Magnum)"
	desc = "A magazine filled with 12.7mm tungsten smart rounds, these rounds will massively knock back any target it hits."
	icon_state = "sg153_tg"
	icon_state_mini = "mag_rifle_green"
	default_ammo = /datum/ammo/bullet/spottingrifle/tungsten

/obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary
	name = "\improper SG-153 incendiary magazine (12.7mm Smart Magnum)"
	desc = "A magazine filled with 12.7mm incendiary smart rounds, these rounds will set alight anything they hit."
	icon_state = "sg153_ic"
	icon_state_mini = "mag_rifle_orange"
	default_ammo = /datum/ammo/bullet/spottingrifle/incendiary

/obj/item/ammo_magazine/rifle/standard_spottingrifle/flak
	name = "\improper SG-153 flak magazine (12.7mm Smart Magnum)"
	desc = "A magazine filled with 12.7mm flak smart rounds, these rounds will airburst on contact with an organic target, causing damage in a small area near the target."
	icon_state = "sg153_fl"
	icon_state_mini = "mag_rifle_cyan"
	default_ammo = /datum/ammo/bullet/spottingrifle/flak

//-------------------------------------------------------
//SMARTRIFLE AMMUNITION

/obj/item/ammo_magazine/rifle/standard_smartrifle
	name = "\improper SG-25 magazine (10x26mm HP)"
	desc = "A 10mm assault rifle magazine."
	caliber = CALIBER_10x26_CASELESS
	icon_state = "sg25"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/smartmachinegun
	max_rounds = 100
	icon_state_mini = "mag_rifle_big"


//-------------------------------------------------------
//Sectoid Rifle

/obj/item/ammo_magazine/rifle/sectoid_rifle
	name = "alien rifle plasma magazine"
	desc = "A magazine filled with powerful plasma rounds. The ammo inside doesn't look like anything you've seen before."
	caliber = CALIBER_ALIEN
	icon_state = "alien_rifle"
	icon_state_mini = "mag_rifle_alien"
	default_ammo = /datum/ammo/energy/sectoid_plasma
	max_rounds = 20

//-------------------------------------------------------
//Marine magazine sniper, or the SR-127.
/obj/item/ammo_magazine/rifle/chamberedrifle
	name = "SR-127 bolt action rifle magazine"
	desc = "A box magazine filled with 8.6x70mm rifle rounds for the SR-127."
	caliber = CALIBER_86X70
	icon_state = "tl127"
	icon = 'icons/obj/items/ammo/sniper.dmi'
	icon_state_mini = "mag_rifle_big"
	default_ammo = /datum/ammo/bullet/sniper/pfc
	max_rounds = 10
	bonus_overlay = "tl127_mag"

/obj/item/ammo_magazine/rifle/chamberedrifle/flak
	name = "SR-127 bolt action rifle flak magazine"
	desc = "A box magazine filled with 8.6x70mm rifle flak rounds for the SR-127."
	icon_state = "tl127_flak"
	icon_state_mini = "mag_rifle_big_blue"
	default_ammo = /datum/ammo/bullet/sniper/pfc/flak
	bonus_overlay = "tl127_flak"

//-------------------------------------------------------
//Marine magazine automatic sniper, or the SR-81.
/obj/item/ammo_magazine/rifle/autosniper
	name = "\improper SR-81 automatic sniper rifle magazine"
	desc = "A box magazine filled with low pressure 8.6x70mm rifle rounds for the SR-81."
	caliber = CALIBER_86X70
	icon_state = "t81"
	icon_state_mini = "mag_rifle_greyblue"
	default_ammo = /datum/ammo/bullet/sniper/auto
	max_rounds = 20

//-------------------------------------------------------
//G-11, AR-11
/obj/item/ammo_magazine/rifle/tx11
	name = "\improper AR-11 combat rifle magazine"
	desc = "A magazine filled with 4.92×34mm rifle rounds for the AR-11."
	caliber = CALIBER_492X34_CASELESS
	icon_state = "tx11"
	icon_state_mini = "mag_tx11"
	default_ammo = /datum/ammo/bullet/rifle/hv
	max_rounds = 70

//-------------------------------------------------------
//AR-21
/obj/item/ammo_magazine/rifle/standard_skirmishrifle
	name = "\improper AR-21 skirmish rifle magazine"
	desc = "A magazine filled with 10x25mm rifle rounds for the AR-21."
	caliber = CALIBER_10X25_CASELESS
	icon_state = "t21"
	icon_state_mini = "mag_rifle"
	default_ammo = /datum/ammo/bullet/rifle/heavy
	max_rounds = 40

//ALF-51B

/obj/item/ammo_magazine/rifle/alf_machinecarbine
	name = "\improper ALF-51B box magazine (10x25mm)"
	desc = "A box magazine for the ALF-51B machinecarbine."
	icon_state = "t60"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_gpmg"
	caliber = CALIBER_10X25_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/som_machinegun
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 80
	reload_delay = 1 SECONDS

//-------------------------------------------------------
//MKH98

/obj/item/ammo_magazine/rifle/mkh
	name = "\improper MKH-98 storm rifle magazine"
	desc = "A magazine filled with 7.62X39 rifle rounds for the MKH."
	caliber = CALIBER_762X39
	icon_state = "mkh98"
	icon_state_mini = "mag_rifle_greyblue"
	default_ammo = /datum/ammo/bullet/rifle/heavy
	max_rounds = 30

//-------------------------------------------------------
//GL-54
/obj/item/ammo_magazine/rifle/tx54
	name = "\improper 20mm airburst grenade magazine"
	desc = "A 20mm magazine loaded with airburst grenades. For use with the GL-54 or AR-55."
	caliber = CALIBER_20MM
	icon_state = "tx54_airburst"
	icon_state_mini = "mag_sniper_blue"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/tx54
	max_rounds = 8
	greyscale_config = /datum/greyscale_config/ammo
	greyscale_colors = COLOR_AMMO_AIRBURST

/obj/item/ammo_magazine/rifle/tx54/he
	name = "\improper 20mm HE grenade magazine"
	desc = "A 20mm magazine loaded with HE grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/he
	icon_state = "tx54_airburst"
	icon_state_mini = "mag_sniper_red"
	greyscale_colors = COLOR_AMMO_HIGH_EXPLOSIVE

/obj/item/ammo_magazine/rifle/tx54/incendiary
	name = "\improper 20mm incendiary grenade magazine"
	desc = "A 20mm magazine loaded with incendiary grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/incendiary
	icon_state = "tx54_airburst"
	icon_state_mini = "mag_sniper_orange"
	greyscale_colors = COLOR_AMMO_INCENDIARY

/obj/item/ammo_magazine/rifle/tx54/smoke
	name = "\improper 20mm tactical smoke grenade magazine"
	desc = "A 20mm magazine loaded with tactical smoke grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/smoke
	icon_state = "tx54_airburst"
	icon_state_mini = "mag_sniper_green"
	greyscale_colors = COLOR_AMMO_TACTICAL_SMOKE

/obj/item/ammo_magazine/rifle/tx54/smoke/dense
	name = "\improper 20mm smoke grenade magazine"
	desc = "A 20mm magazine loaded with smoke grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/smoke/dense
	icon_state = "tx54_airburst"
	icon_state_mini = "mag_sniper_cyan"
	greyscale_colors = COLOR_AMMO_SMOKE

/obj/item/ammo_magazine/rifle/tx54/smoke/tangle
	name = "\improper 20mm tanglefoot grenade magazine"
	desc = "A 20mm magazine loaded with tanglefoot grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/smoke/tangle
	icon_state = "tx54_airburst"
	icon_state_mini = "mag_sniper_purple"
	greyscale_colors = COLOR_AMMO_TANGLEFOOT

/obj/item/ammo_magazine/rifle/tx54/smoke/acid
	name = "\improper 20mm acid smoke grenade magazine"
	desc = "A 20mm magazine loaded with acid grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/smoke/acid
	icon_state = "tx54_airburst"
	icon_state_mini = "mag_sniper_green"
	greyscale_colors = COLOR_AMMO_ACID

/obj/item/ammo_magazine/rifle/tx54/razor
	name = "\improper 20mm razorburn grenade magazine"
	desc = "A 20mm magazine loaded with razorburn grenades. For use with the GL-54 or AR-55."
	default_ammo = /datum/ammo/tx54/razor
	icon_state = "tx54_airburst"
	icon_state_mini = "mag_sniper_yellow"
	greyscale_colors = COLOR_AMMO_RAZORBURN

//-------------------------------------------------------
//Garand
/obj/item/ammo_magazine/rifle/garand
	name = "C1 Garand enbloc clip"
	desc = "A enbloc clip filled with .30 caliber rifle rounds for the C1 Garand."
	caliber = CALIBER_3006
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "garand"
	icon_state_mini = "clips"
	default_ammo = /datum/ammo/bullet/rifle/garand
	max_rounds = 8

//-------------------------------------------------------
//V-31 SOM rifle

/obj/item/ammo_magazine/rifle/som
	name = "\improper V-31 magazine (10x24mm)"
	desc = "A 10mm rifle magazine designed for the V-31."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "v31"
	icon_state_mini = "mag_thin_cyan"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 50

/obj/item/ammo_magazine/rifle/som/ap
	name = "\improper V-31 AP magazine (10x24mm)"
	desc = "A 10mm rifle magazine designed for the V-31, loaded with armor piercing rounds."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "v31_ap"
	icon_state_mini = "mag_thin_green"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/hv
	max_rounds = 50

/obj/item/ammo_magazine/rifle/som/incendiary
	name = "\improper V-31 incendiary magazine (10x24mm)"
	desc = "A 10mm rifle magazine designed for the V-31, loaded with incendiary rounds."
	icon_state = "v31_incend"
	icon_state_mini = "mag_thin_red"
	default_ammo = /datum/ammo/bullet/rifle/incendiary

/obj/item/ammo_magazine/rifle/som_big
	name = "\improper V-35 magazine (10x27mm)"
	desc = "A 10mm rifle magazine designed for the V-35."
	caliber = CALIBER_10x27_CASELESS
	icon_state = "v35"
	base_ammo_icon = "v35"
	icon_state_mini = "mag_rifle_big_yellowtip"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/som_big
	max_rounds = 20
	bonus_overlay = "v35_mag"
	magazine_flags = MAGAZINE_REFILLABLE|MAGAZINE_SHOW_AMMO

/obj/item/ammo_magazine/rifle/som_big/incendiary
	name = "\improper V-35 incendiary magazine (10x27mm)"
	desc = "A 10mm rifle magazine designed for the V-35, loaded with incendiary ammunition."
	icon_state = "v35_incend"
	icon_state_mini = "mag_rifle_big_red_yellow"
	default_ammo = /datum/ammo/bullet/rifle/som_big/incendiary
	bonus_overlay = "v35_incend"

/obj/item/ammo_magazine/rifle/som_big/anti_armour
	name = "\improper V-35 AT magazine (10x27mm)"
	desc = "A 10mm rifle magazine designed for the V-35, loaded with powerful anti armor ammunition. Deals significant damage to vehicles, and can punch through some cover."
	icon_state = "v35_at"
	icon_state_mini = "mag_rifle_big_blue_yellow"
	default_ammo = /datum/ammo/bullet/rifle/som_big/anti_armour
	bonus_overlay = "v35_at"

//-------------------------------------------------------
//V-41 Machine Gun

/obj/item/ammo_magazine/som_mg
	name = "\improper V-41 box magazine (10x26mm)"
	desc = "A drum magazine for the V-41 machinegun."
	icon_state = "v41"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_drum_big_long"
	caliber = CALIBER_10x26_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/som_machinegun
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 200
	reload_delay = 3 SECONDS

//-------------------------------------------------------
//L-11 Sharpshooter Rifle

/obj/item/ammo_magazine/rifle/icc_sharpshooter
	name = "\improper L-11 sharpshooter rifle magazine (10x27mm)"
	desc = "A 10mm DMR magazine."
	caliber = CALIBER_10x27_CASELESS
	icon_state = "l11"
	icon_state_mini = "mag_rifle"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr
	max_rounds = 20

//-------------------------------------------------------
//L-15 Battlecarbine
/obj/item/ammo_magazine/rifle/icc_battlecarbine
	name = "\improper L-15 battlecarbine rifle magazine (10x25mm)"
	desc = "A magazine filled with 10x25mm rifle rounds for the L-15."
	caliber = CALIBER_10X25_CASELESS
	icon_state = "l15"
	icon_state_mini = "mag_rifle"
	default_ammo = /datum/ammo/bullet/rifle/heavy
	max_rounds = 30

//-------------------------------------------------------
//ML-12 Confrontation Rifle
/obj/item/ammo_magazine/rifle/icc_confrontationrifle
	name = "\improper ML-12 battlecarbine rifle magazine (10x28mm)"
	desc = "A magazine filled with 10x28mm armor-piercing rifle rounds for the ML-12."
	caliber = CALIBER_10X28_CASELESS
	icon_state = "ml12"
	icon_state_mini = "mag_rifle_big"
	default_ammo = /datum/ammo/bullet/rifle/icc_confrontationrifle
	max_rounds = 25

//-------------------------------------------------------
//ML-41 Autoshotgun
/obj/item/ammo_magazine/rifle/icc_autoshotgun
	name = "\improper ML-41 Autoshotgun flechette drum magazine (12G)"
	desc = "A magazine filled with 12G flechette shells for the ML-41."
	caliber = CALIBER_12G
	icon_state = "ml41"
	default_ammo = /datum/ammo/bullet/shotgun/flechette
	max_rounds = 16
	icon_state_mini = "mag_rifle"

/obj/item/ammo_magazine/rifle/icc_autoshotgun/frag
	name = "\improper ML-41 Autoshotgun frag drum magazine (12G)"
	desc = "A magazine filled with 12G fragmentation shells for the ML-41."
	caliber = CALIBER_12G
	icon_state = "ml41_frag"
	default_ammo = /datum/ammo/bullet/shotgun/frag
	max_rounds = 12

//-------------------------------------------------------
//L-88 Assault Carbine
/obj/item/ammo_magazine/rifle/icc_assaultcarbine
	name = "\improper L-88 assault carbine magazine (5.56x45mm)"
	desc = "A magazine filled with 5.56x45mm rifle rounds for the L-88 series of firearms."
	caliber = CALIBER_556X45
	icon_state = "aug"
	icon_state_mini = "mag_rifle_olive"
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 30

/obj/item/ammo_magazine/rifle/icc_assaultcarbine/export
	name = "\improper EM-88 assault carbine magazine (5.56x45mm)"
	desc = "A magazine filled with 5.56x45mm rifle rounds for the EM-88 series of firearms."

//-------------------------------------------------------
//ML-41 Assault Machiengun
/obj/item/ammo_magazine/icc_mg
	name = "\improper ML-41 GPMG box magazine (10x26mm)"
	desc = "A belt box for the ML-41 assault machinegun."
	icon_state = "minimi"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_gpmg"
	caliber = CALIBER_10x26_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/machinegun
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 150
	reload_delay = 2 SECONDS

// This is a 'belt'.
/obj/item/ammo_magazine/icc_mg/belt
	name = "\improper ML-41 GPMG buttpack magazine (10x26mm)"
	desc = "A buttpack for the ML-41 which carries the ammo inside."
	icon_state = "minimi_belt"
	equip_slot_flags = ITEM_SLOT_BELT
	magazine_flags = MAGAZINE_WORN
	w_class = WEIGHT_CLASS_HUGE
	max_rounds = 750

/obj/item/ammo_magazine/icc_mg/packet
	name = "box of 10x26mm"
	desc = "A box containing 500 rounds of 10x26mm caseless."
	icon_state = "minimi"
	icon_state_mini = "ammo_packet"
	icon = 'icons/obj/items/ammo/packet.dmi'
	current_rounds = 500
	max_rounds = 500

// L26

/obj/item/ammo_magazine/rifle/vsd_mg
	name = "\improper L26 box mag (5.56x45mm)"
	desc = "A 200 round box mag for the L26."
	caliber = CALIBER_556X45
	default_ammo = /datum/ammo/bullet/rifle
	icon_state = "l26"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_drum_big_long"
	bonus_overlay = "l26_100"
	max_rounds = 200

//CC/67

/obj/item/ammo_magazine/rifle/vsd_rifle
	name = "\improper CC/67 magazine (10x27mm)"
	desc = "A 10x27mm rifle magazine."
	caliber = CALIBER_10x27_CASELESS
	icon_state = "c550"
	icon_state_mini = "mag_rifle_big"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr
	max_rounds = 30

//CC/74

/obj/item/ammo_magazine/rifle/vsd_mg_main
	name = "\improper CC/74 box mag (7.62x39mm)"
	desc = "A 150 round box mag for the CC/74."
	caliber = CALIBER_762X39
	default_ammo = /datum/ammo/bullet/rifle/heavy
	icon_state = "c74"
	icon = 'icons/obj/items/ammo/machinegun.dmi'
	icon_state_mini = "mag_gpmg"
	bonus_overlay = "c74_100"
	max_rounds = 150

//CC/67

/obj/item/ammo_magazine/rifle/vsd_carbine
	name = "\improper CC/67 magazine (10x24mm)"
	desc = "A 10x27mm rifle magazine."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "c67"
	icon_state_mini = "mag_rifle_big"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 45



/obj/item/ammo_magazine/rifle/cb31
	name = "\improper CC/B/31 breaching slug magazine (12 gauge)"
	desc = "A magazine of 16 gauge slugs, for the SH-15."
	caliber = CALIBER_16G
	icon_state = "cb31"
	icon_state_mini = "mag_tx15_slug"
	default_ammo = /datum/ammo/bullet/shotgun/breaching
	max_rounds = 25
	bonus_overlay = "cb31"

//.410 autoshotgun ammo

/obj/item/ammo_magazine/rifle/sh410_sabot
	name = "\improper SH-410 sabot magazine (.410 gauge)"
	desc = "A magazine of .410 gauge sabot rounds, for the SH-410."
	caliber = CALIBER_410_AUTOSHOTGUN
	icon_state = "sh410_sabot"
	icon_state_mini = "mag_sh410_sabot"
	default_ammo = /datum/ammo/bullet/shotgun/sh410_sabot
	max_rounds = 15
	bonus_overlay = "sh410_sabot"

/obj/item/ammo_magazine/rifle/sh410_buckshot
	name = "\improper SH-410 buckshot magazine (.410 gauge)"
	desc = "A magazine of .410 gauge buckshot rounds, for the SH-410."
	caliber = CALIBER_410_AUTOSHOTGUN
	icon_state = "sh410_buckshot"
	icon_state_mini = "mag_sh410_buckshot"
	default_ammo = /datum/ammo/bullet/shotgun/sh410_buckshot
	max_rounds = 15
	bonus_overlay = "sh410_buckshot"

/obj/item/ammo_magazine/rifle/sh410_tracker //fuck it why not
	name = "\improper SH-410 tracker magazine (.410 gauge)"
	desc = "A magazine of .410 gauge tracker rounds, for the SH-410...?"
	caliber = CALIBER_410_AUTOSHOTGUN
	icon_state = "sh410_tracker"
	icon_state_mini = "mag_sh410_tracker"
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_tracker
	max_rounds = 15
	bonus_overlay = "sh410_tracker"

/obj/item/ammo_magazine/rifle/sh410_ricochet //bounce
	name = "\improper SH-410 ricochet magazine (.410 gauge)"
	desc = "A magazine of .410 gauge ricochet rounds, for the SH-410. They bounce up to two times off of surfaces."
	caliber = CALIBER_410_AUTOSHOTGUN
	icon_state = "sh410_ricochet"
	icon_state_mini = "mag_sh410_ricochet"
	default_ammo = /datum/ammo/bullet/shotgun/sh410_ricochet/two
	max_rounds = 15
	bonus_overlay = "sh410_ricochet"

/obj/item/ammo_magazine/rifle/sh410_gas //gas base
	name = "\improper SH-410 gas magazine (.410 gauge)"
	desc = "A magazine of .410 gauge gas rounds, for the SH-410. These leave a trail of gas when fired."
	caliber = CALIBER_410_AUTOSHOTGUN
	icon_state = "sh410_gas"
	icon_state_mini = "mag_sh410_gas"
	default_ammo = /datum/ammo/bullet/shotgun/sh410_gas
	max_rounds = 15
	bonus_overlay = "sh410_gas"
