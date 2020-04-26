
//external magazines

/obj/item/ammo_magazine/revolver
	name = "\improper M44 magnum speed loader (.44)"
	desc = "A revolver speed loader."
	default_ammo = /datum/ammo/bullet/revolver
	flags_equip_slot = NONE
	caliber = ".44"
	icon_state = "m44"
	w_class = WEIGHT_CLASS_SMALL
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/m44

/obj/item/ammo_magazine/revolver/marksman
	name = "\improper M44 marksman speed loader (.44)"
	default_ammo = /datum/ammo/bullet/revolver/marksman
	caliber = ".44"
	icon_state = "m_m44"

/obj/item/ammo_magazine/revolver/heavy
	name = "\improper M44 PW-MX speed loader (.44)"
	default_ammo = /datum/ammo/bullet/revolver/heavy
	caliber = ".44"
	icon_state = "h_m44"

/obj/item/ammo_magazine/revolver/standard_revolver
	name = "\improper TP-44 magnum speed loader (.44)"
	desc = "A revolver speed loader."
	default_ammo = /datum/ammo/bullet/revolver
	flags_equip_slot = NONE
	caliber = ".44"
	icon_state = "tp44"
	w_class = WEIGHT_CLASS_SMALL
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/standard_revolver

/obj/item/ammo_magazine/revolver/upp
	name = "\improper N-Y speed loader (7.62x38mmR)"
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = "7.62x38mmR"
	icon_state = "ny762"
	gun_type = /obj/item/weapon/gun/revolver/upp


/obj/item/ammo_magazine/revolver/small
	name = "\improper S&W speed loader (.357)"
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = ".357"
	icon_state = "sw357"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/small


/obj/item/ammo_magazine/revolver/mateba
	name = "\improper Mateba speed loader (.454)"
	default_ammo = /datum/ammo/bullet/revolver/highimpact
	caliber = ".454"
	icon_state = "mateba"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/mateba


/obj/item/ammo_magazine/revolver/cmb
	name = "\improper CMB revolver speed loader (.357)"
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = ".357"
	icon_state = "cmb"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/cmb

//a very literal box of ammunition.
/obj/item/ammo_magazine/magnum
	name = "Box of .44 magnum"
	icon_state = "box45" //Maybe change this
	default_ammo = /datum/ammo/bullet/revolver
	caliber = ".44"
	current_rounds = 50
	max_rounds = 50

//INTERNAL MAGAZINES

//---------------------------------------------------

/obj/item/ammo_magazine/internal/revolver
	name = "revolver cylinder"
	default_ammo = /datum/ammo/bullet/revolver
	max_rounds = 6

//-------------------------------------------------------

//TP-44 COMBAT REVOLVER //

/obj/item/ammo_magazine/internal/revolver/standard_revolver
	caliber = ".44"
	default_ammo = /datum/ammo/bullet/revolver
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/standard_revolver

//-------------------------------------------------------
//M44 MAGNUM REVOLVER //

/obj/item/ammo_magazine/internal/revolver/m44
	caliber = ".44"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/m44

//-------------------------------------------------------
//RUSSIAN REVOLVER //

/obj/item/ammo_magazine/internal/revolver/upp
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = "7.62x38mmR"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/upp

//-------------------------------------------------------
//357 REVOLVER //

/obj/item/ammo_magazine/internal/revolver/small
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = ".357"
	gun_type = /obj/item/weapon/gun/revolver/small

//-------------------------------------------------------
//BURST REVOLVER //
/obj/item/ammo_magazine/internal/revolver/mateba
	default_ammo = /datum/ammo/bullet/revolver/highimpact
	caliber = ".454"
	gun_type = /obj/item/weapon/gun/revolver/mateba

//-------------------------------------------------------
//MARSHALS REVOLVER //

/obj/item/ammo_magazine/internal/revolver/cmb
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = ".357"
	gun_type = /obj/item/weapon/gun/revolver/cmb

