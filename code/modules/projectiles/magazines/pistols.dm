
//-------------------------------------------------------
//M4A3 PISTOL

/obj/item/ammo_magazine/pistol/standard_pistol
	name = "\improper P-14 magazine (9mm)"
	desc = "A pistol magazine."
	caliber = CALIBER_9X19
	icon_state = "tp14"
	icon_state_mini = "mag_pistol"
	max_rounds = 21
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/bullet/pistol

//-------------------------------------------------------
//PP-7 Plasma Pistol
/obj/item/ammo_magazine/pistol/plasma_pistol
	name = "\improper PP-7 plasma cell"
	desc = "An energy cell for the PP-7 plasma pistol."
	caliber = CALIBER_PLASMA
	icon_state = "tx7"
	max_rounds = 10
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/energy/plasma_pistol
	flags_magazine = NONE
	icon_state_mini = "mag_tx7"

//-------------------------------------------------------
//RT-3 PISTOL

/obj/item/ammo_magazine/pistol
	name = "\improper RT-3 magazine (9mm)"
	desc = "A pistol magazine."
	caliber = CALIBER_9X19
	icon_state = "m4a3"
	max_rounds = 14
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/bullet/pistol
	icon_state_mini = "mag_pistol_orange"

/obj/item/ammo_magazine/pistol/hp
	name = "\improper M4A3 hollowpoint magazine (9mm)"
	icon_state = "m4a3_hp"
	default_ammo = /datum/ammo/bullet/pistol/hollow
	icon_state_mini = "mag_pistol_blue"

/obj/item/ammo_magazine/pistol/ap
	name = "\improper M4A3 AP magazine (9mm)"
	icon_state = "m4a3_ap"
	default_ammo = /datum/ammo/bullet/pistol/ap
	icon_state_mini = "mag_pistol_green"

/obj/item/ammo_magazine/pistol/incendiary
	name = "\improper M4A3 incendiary magazine (9mm)"
	icon_state = "m4a3_incendiary"
	default_ammo = /datum/ammo/bullet/pistol/incendiary
	icon_state_mini = "mag_pistol_red"

/obj/item/ammo_magazine/pistol/extended
	name = "\improper M4A3 extended magazine (9mm)"
	max_rounds = 24
	icon_state = "m4a3_ext"
	icon_state_mini = "mag_pistol_yellow"

//-------------------------------------------------------
//P-1911

/obj/item/ammo_magazine/pistol/m1911
	name = "\improper P-1911 magazine (.45)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = CALIBER_45ACP
	icon_state = "1911"
	icon_state_mini = "mag_pistol_normal"
	max_rounds = 10



//-------------------------------------------------------
//P-23

/obj/item/ammo_magazine/pistol/standard_heavypistol
	name = "\improper P-23 magazine (.45)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = CALIBER_45ACP
	icon_state = ".45"
	icon_state_mini = "mag_pistol"
	max_rounds = 14


//-------------------------------------------------------
//Beretta 92FS, the gun McClane carries around in Die Hard. Very similar to the service pistol, all around.

/obj/item/ammo_magazine/pistol/g22
	name = "\improper P-22 magazine (9mm)"
	caliber = CALIBER_9X19
	icon_state = "g22"
	icon_state_mini = "mag_pistol_normal"
	max_rounds = 15
	default_ammo = /datum/ammo/bullet/pistol

/obj/item/ammo_magazine/pistol/g22tranq
	name = "\improper G22 tranq magazine (9mm)"
	caliber = CALIBER_9X19_TRANQUILIZER
	icon_state = "g22"
	icon_state_mini = "mag_pistol_normal"
	max_rounds = 12
	default_ammo = /datum/ammo/bullet/pistol/tranq


//-------------------------------------------------------
//DEAGLE //DEAGLE BRAND DEAGLE

/obj/item/ammo_magazine/pistol/heavy
	name = "\improper Desert Eagle magazine (.50)"
	default_ammo = /datum/ammo/bullet/pistol/superheavy
	caliber = CALIBER_50AE
	icon_state = "50ae"
	max_rounds = 7



//-------------------------------------------------------
//MAUSER MERC PISTOL //Inspired by the Makarov.

/obj/item/ammo_magazine/pistol/c99t
	name = "\improper PK-9 tranq magazine (.22)"
	default_ammo = /datum/ammo/bullet/pistol/tranq
	caliber = CALIBER_22LR
	icon_state = "pk-9_tranq"
	max_rounds = 8
	icon_state_mini = "mag_pistol_green"

/obj/item/ammo_magazine/pistol/c99
	name = "\improper PK-9 hollowpoint magazine (.22)"
	default_ammo = /datum/ammo/bullet/pistol/hollow
	caliber = CALIBER_22LR
	icon_state = "pk-9"
	icon_state_mini = "mag_pistol_orange"
	max_rounds = 12

//-------------------------------------------------------
//PIZZACHIMP PROTECTION

/obj/item/ammo_magazine/pistol/holdout
	name = "tiny pistol magazine (.22)"
	desc = "A surprisingly small magazine, holding .22 bullets. No Kolibri, but it's getting there."
	default_ammo = /datum/ammo/bullet/pistol/tiny
	caliber = CALIBER_22LR
	icon_state = ".22"
	icon_state_mini = "mag_pistol_normal"
	max_rounds = 5
	w_class = WEIGHT_CLASS_TINY

//-------------------------------------------------------
//P-17.

/obj/item/ammo_magazine/pistol/standard_pocketpistol
	name = "\improper P-17 pocket pistol AP magazine (.380)"
	desc = "A surprisingly small magazine used by the P-17 pistol holding .380 ACP bullets."
	default_ammo = /datum/ammo/bullet/pistol/tiny/ap
	caliber = CALIBER_380ACP
	icon_state = "tp17"
	icon_state_mini = "mag_pistol"
	max_rounds = 8
	w_class = WEIGHT_CLASS_TINY

//-------------------------------------------------------
//Automag. .50.

/obj/item/ammo_magazine/pistol/highpower
	name = "\improper Highpower magazine (.50 AE)"
	default_ammo = /datum/ammo/bullet/pistol/superheavy
	caliber = CALIBER_50AE
	icon_state = "m4a3" //PLACEHOLDER
	icon_state_mini = "mag_pistol_normal"
	max_rounds = 13

//-------------------------------------------------------
//VP70 //Not actually the VP70, but it's more or less the same thing. VP70 was the standard sidearm in Aliens though.

/obj/item/ammo_magazine/pistol/vp70
	name = "\improper 88M4 AP magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/ap
	caliber = CALIBER_9X19
	icon_state = "88m4"
	icon_state_mini = "mag_pistol"
	max_rounds = 18

//-------------------------------------------------------
//VP78

/obj/item/ammo_magazine/pistol/vp78
	name = "\improper VP78 magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/squash
	caliber = CALIBER_9X19
	icon_state = "50ae"
	max_rounds = 18

//-------------------------------------------------------
//SOM pistol

/obj/item/ammo_magazine/pistol/som
	name = "\improper V-11 AP magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/ap
	caliber = CALIBER_9X19
	icon_state = "v11"
	icon_state_mini = "mag_pistol_normal"
	max_rounds = 18

/obj/item/ammo_magazine/pistol/som/incendiary
	name = "\improper V-11 incendiary magazine (9mm)"
	icon_state = "v11_incend"
	default_ammo = /datum/ammo/bullet/pistol/incendiary
	icon_state_mini = "mag_pistol_red"

/obj/item/ammo_magazine/pistol/som/extended
	name = "\improper V-11 extended magazine (9mm)"
	max_rounds = 30
	icon_state = "v11_extended"
	icon_state_mini = "mag_pistol_yellow"

//-------------------------------------------------------
//PL-5

/obj/item/ammo_magazine/pistol/icc_dpistol
	name = "\improper PL-5 magazine (.45)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = CALIBER_45ACP
	icon_state = "pl5"
	icon_state_mini = "mag_pistol"
	max_rounds = 18

//-------------------------------------------------------

//A better version of the VP78, with more rounds per magazine. Probably the best pistol around, but takes no attachments.


/obj/item/ammo_magazine/pistol/auto9
	name = "\improper Auto-9 magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/squash
	caliber = CALIBER_9X19
	icon_state = "tp17"
	icon_state_mini = "mag_pistol"
	max_rounds = 50


//-------------------------------------------------------
//The first rule of monkey pistol is we don't talk about monkey pistol.
/obj/item/ammo_magazine/pistol/chimp
	name = "\improper CHIMP70 magazine (.70M)"
	default_ammo = /datum/ammo/bullet/pistol/mankey
	caliber = CALIBER_70MANKEY
	icon_state = "c70"
	icon_state_mini = "Rule One: donotspeakofthis"
	max_rounds = 300

//SP-13 (Calico)
/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol
	name = "\improper SP-13 magazine (9mm AP)"
	caliber = CALIBER_9X19
	icon_state = "tx13"
	icon_state_mini = "mag_pistol_tube"
	max_rounds = 30
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/bullet/pistol/ap

//-------------------------------------------------------
// knife
/obj/item/ammo_magazine/pistol/knife
	name = "\improper ballistic knife head (Blade)"
	default_ammo = /datum/ammo/bullet/pistol
	caliber = CALIBER_ALIEN
	icon_state = "knife"
	max_rounds = 1
