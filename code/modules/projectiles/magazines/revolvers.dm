
//external magazines

/obj/item/ammo_magazine/revolver
	name = "\improper M-44 magnum speed loader (.44)"
	desc = "A revolver speed loader."
	default_ammo = /datum/ammo/bullet/revolver
	flags_equip_slot = NONE
	caliber = CALIBER_44
	icon_state = "m44"
	w_class = WEIGHT_CLASS_SMALL
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/single_action/m44
	icon_state_mini = "mag_revolver"

/obj/item/ammo_magazine/revolver/marksman
	name = "\improper M-44 marksman speed loader (.44)"
	default_ammo = /datum/ammo/bullet/revolver/marksman
	caliber = CALIBER_44
	icon_state = "m_m44"

/obj/item/ammo_magazine/revolver/heavy
	name = "\improper M-44 PW-MX speed loader (.44)"
	default_ammo = /datum/ammo/bullet/revolver/heavy
	caliber = CALIBER_44
	icon_state = "h_m44"

/obj/item/ammo_magazine/revolver/standard_revolver
	name = "\improper TP-44 magnum speed loader (.44)"
	desc = "A revolver speed loader."
	default_ammo = /datum/ammo/bullet/revolver/tp44
	flags_equip_slot = NONE
	caliber = CALIBER_44
	icon_state = "tp44"
	w_class = WEIGHT_CLASS_SMALL
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/standard_revolver

/obj/item/ammo_magazine/revolver/upp
	name = "\improper N-Y speed loader (7.62x38mmR)"
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = CALIBER_762X38
	icon_state = "ny762"
	gun_type = /obj/item/weapon/gun/revolver/upp


/obj/item/ammo_magazine/revolver/small
	name = "\improper 'Bote' .357 speed loader (.357)"
	desc = "A revolver speed loader loaded with special 357 rounds that bounce on impact. Be careful around friends and family!"
	default_ammo = /datum/ammo/bullet/revolver/ricochet/four
	caliber = CALIBER_357
	icon_state = "sw357"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/small


/obj/item/ammo_magazine/revolver/mateba
	name = "\improper Mateba speed loader (.454)"
	default_ammo = /datum/ammo/bullet/revolver/highimpact
	caliber = CALIBER_454
	icon_state = "mateba"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/mateba


/obj/item/ammo_magazine/revolver/cmb
	name = "\improper CMB revolver speed loader (.357)"
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = CALIBER_357
	icon_state = "cmb"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/cmb

/obj/item/ammo_magazine/revolver/judge
	name = "\improper Judge speed loader (.45L)"
	desc = "A revolver speed loader for the Judge, these rounds have a high velocity propellant, leading to next to no scatter and falloff."
	default_ammo = /datum/ammo/bullet/revolver/marksman
	caliber = CALIBER_45L
	gun_type = /obj/item/weapon/gun/revolver/judge
	max_rounds = 5
	icon_state = "m_m44"

/obj/item/ammo_magazine/revolver/judge/buckshot
	name = "\improper Judge buckshot speed loader (.45L)"
	desc = "A revolver speed loader for the Judge, this is filled with tiny pellets inside, with high scatter but large CQC damage."
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_buckshot
	caliber = CALIBER_45L
	icon_state = "h_m44"



//INTERNAL MAGAZINES

//---------------------------------------------------

/obj/item/ammo_magazine/internal/revolver
	name = "revolver cylinder"
	default_ammo = /datum/ammo/bullet/revolver
	max_rounds = 6

//-------------------------------------------------------

//TP-44 COMBAT REVOLVER //

/obj/item/ammo_magazine/internal/revolver/standard_revolver
	caliber = CALIBER_44
	default_ammo = /datum/ammo/bullet/revolver/tp44
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/standard_revolver

//-------------------------------------------------------
//M44 MAGNUM REVOLVER //

/obj/item/ammo_magazine/internal/revolver/m44
	caliber = CALIBER_44
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/single_action/m44

//-------------------------------------------------------
//RUSSIAN REVOLVER //

/obj/item/ammo_magazine/internal/revolver/upp
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = CALIBER_762X38
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/upp

//-------------------------------------------------------
//357 REVOLVER //

/obj/item/ammo_magazine/internal/revolver/small
	default_ammo = /datum/ammo/bullet/revolver/ricochet/four
	caliber = CALIBER_357
	gun_type = /obj/item/weapon/gun/revolver/small

//-------------------------------------------------------
//BURST REVOLVER //
/obj/item/ammo_magazine/internal/revolver/mateba
	default_ammo = /datum/ammo/bullet/revolver/highimpact
	caliber = CALIBER_454
	gun_type = /obj/item/weapon/gun/revolver/mateba

//-------------------------------------------------------
//MARSHALS REVOLVER //

/obj/item/ammo_magazine/internal/revolver/cmb
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = CALIBER_357
	gun_type = /obj/item/weapon/gun/revolver/cmb

//-------------------------------------------------------
//JUDGE REVOLVER //

/obj/item/ammo_magazine/internal/revolver/judge
	default_ammo = /datum/ammo/bullet/revolver/marksman
	caliber = CALIBER_45L
	gun_type = /obj/item/weapon/gun/revolver/judge
	max_rounds = 5
