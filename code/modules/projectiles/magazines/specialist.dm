//-------------------------------------------------------
//SNIPER RIFLES
//Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.

/obj/item/ammo_magazine/sniper
	name = "\improper T-26 magazine (10x28mm)"
	desc = "A magazine of antimaterial rifle ammo."
	caliber = "10x28mm"
	icon_state = "t26"
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 15
	default_ammo = /datum/ammo/bullet/sniper
	gun_type = /obj/item/weapon/gun/rifle/sniper/antimaterial
	reload_delay = 3


/obj/item/ammo_magazine/sniper/incendiary
	name = "\improper T-26 incendiary magazine (10x28mm)"
	default_ammo = /datum/ammo/bullet/sniper/incendiary
	icon_state = "t26_inc"

/obj/item/ammo_magazine/sniper/flak
	name = "\improper T-26 flak magazine (10x28mm)"
	default_ammo = /datum/ammo/bullet/sniper/flak
	icon_state = "t26_flak"


//M42C magazine

/obj/item/ammo_magazine/sniper/elite
	name = "\improper M42C marksman magazine (10x99mm)"
	default_ammo = /datum/ammo/bullet/sniper/elite
	gun_type = /obj/item/weapon/gun/rifle/sniper/elite
	caliber = "10x99mm"
	icon_state = "m42c"
	max_rounds = 6


//SVD //Based on the actual Dragunov sniper rifle.

/obj/item/ammo_magazine/sniper/svd
	name = "\improper SVD magazine (7.62x54mmR)"
	desc = "A large caliber magazine for the SVD sniper rifle."
	caliber = "7.62x54mmR"
	icon_state = "svd"
	default_ammo = /datum/ammo/bullet/sniper/svd
	max_rounds = 10
	gun_type = /obj/item/weapon/gun/rifle/sniper/svd



//M4RA magazines

/obj/item/ammo_magazine/rifle/m4ra
	name = "\improper A19 high velocity magazine (10x28mm)"
	desc = "A magazine of A19 high velocity rounds for use in the T-45 battle rifle. The T-45 battle rifle is the only gun that can chamber these rounds."
	icon_state = "m4ra"
	caliber = "10x28mm caseless"
	default_ammo = /datum/ammo/bullet/rifle/m4ra
	max_rounds = 20
	gun_type = /obj/item/weapon/gun/rifle/m4ra

/obj/item/ammo_magazine/rifle/m4ra/incendiary
	name = "\improper A19 high velocity incendiary magazine (10x28mm)"
	desc = "A magazine of A19 high velocity incendiary rounds for use in the T-45 battle rifle. The T-45 battle rifle is the only gun that can chamber these rounds."
	caliber = "10x28mm caseless"
	icon_state = "m4ra_incendiary"
	default_ammo = /datum/ammo/bullet/rifle/m4ra/incendiary
	max_rounds = 20
	gun_type = /obj/item/weapon/gun/rifle/m4ra

/obj/item/ammo_magazine/rifle/m4ra/impact
	name = "\improper A19 high velocity impact magazine (10x28mm)"
	desc = "A magazine of A19 high velocity impact rounds for use in the T-45 battle rifle. The T-45 battle rifle is the only gun that can chamber these rounds."
	icon_state = "m4ra_impact"
	default_ammo = /datum/ammo/bullet/rifle/m4ra/impact
	max_rounds = 20
	gun_type = /obj/item/weapon/gun/rifle/m4ra

obj/item/ammo_magazine/rifle/m4ra/smart
	name = "\improper A19 high velocity smart magazine (10x28mm)"
	desc = "A magazine of A19 high velocity smart rounds for use in the T-45 battle rifle. The T-45 battle rifle is the only gun that can chamber these rounds."
	icon_state = "m4ra_iff"
	default_ammo = /datum/ammo/bullet/rifle/m4ra/smart
	max_rounds = 20
	gun_type = /obj/item/weapon/gun/rifle/m4ra


//-------------------------------------------------------
//SMARTGUN
/obj/item/ammo_magazine/internal/smartgun
	name = "integrated smartgun belt"
	caliber = "10x28mm"
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/smartgun


/obj/item/ammo_magazine/internal/smartgun/dirty
	default_ammo = /datum/ammo/bullet/smartgun/dirty
	gun_type = /obj/item/weapon/gun/smartgun/dirty


//-------------------------------------------------------
//M5 RPG

/obj/item/ammo_magazine/rocket
	name = "\improper generic high-explosive rocket"
	desc = "A precursor to all kinds of rocket ammo unfit for normal use. How did you get this anyway?"
	caliber = "rocket"
	icon_state = "rocket"
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 1
	default_ammo = /datum/ammo/rocket
	gun_type = /obj/item/weapon/gun/launcher/rocket
	flags_magazine = NONE
	reload_delay = 60

	attack_self(mob/user)
		if(current_rounds <= 0)
			to_chat(user, "<span class='notice'>You begin taking apart the empty tube frame...</span>")
			if(do_after(user, 10, TRUE, src))
				user.visible_message("[user] deconstructs the rocket tube frame.","<span class='notice'>You take apart the empty frame.</span>")
				var/obj/item/stack/sheet/metal/M = new(get_turf(user))
				M.amount = 2
				user.drop_held_item()
				qdel(src)
		else
			to_chat(user, "Not with a missile inside!")

	update_icon()
		overlays.Cut()
		if(current_rounds <= 0)
			name = "empty rocket frame"
			desc = "A spent rocket rube. Activate it to deconstruct it and receive some materials."
			icon_state = type == /obj/item/ammo_magazine/rocket/m57a4? "quad_rocket_e" : "rocket_e"

//-------------------------------------------------------
//T-152

/obj/item/ammo_magazine/rocket/sadar
	name = "\improper 84mm high-explosive rocket"
	desc = "A rocket tube for the T-152 rocket launcher."
	caliber = "rocket"
	icon_state = "rocket"
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 1
	default_ammo = /datum/ammo/rocket
	gun_type = /obj/item/weapon/gun/launcher/rocket/sadar
	flags_magazine = NONE
	reload_delay = 60

/obj/item/ammo_magazine/rocket/sadar/ap
	name = "\improper 84mm anti-armor rocket"
	icon_state = "ap_rocket"
	default_ammo = /datum/ammo/rocket/ap
	desc = "A tube for an AP rocket, the warhead of which is extremely dense and turns molten on impact. When empty, use this frame to deconstruct it."

/obj/item/ammo_magazine/rocket/sadar/wp
	name = "\improper 84mm white-phosphorus rocket"
	icon_state = "wp_rocket"
	default_ammo = /datum/ammo/rocket/wp
	desc = "A highly destructive warhead that bursts into deadly flames on impact. Use this in hand to deconstruct it."

/obj/item/ammo_magazine/internal/launcher/rocket/sadar
	name = "\improper 84mm internal tube"
	desc = "The internal tube of a T-152 rocket launcher."
	caliber = "rocket"
	default_ammo = /datum/ammo/rocket
	gun_type = /obj/item/weapon/gun/launcher/rocket/sadar
	max_rounds = 1
	current_rounds = 0
	reload_delay = 60

//-------------------------------------------------------
//T-160 recoilless rifle

/obj/item/ammo_magazine/rocket/recoilless
	name = "\improper 67mm high-explosive shell"
	desc = "A high explosive shell for the T-160 recoilless rifle. Causes a heavy explosion over a small area. Requires specialized storage to carry."
	caliber = "67mm shell"
	icon_state = "shell"
	w_class = WEIGHT_CLASS_BULKY
	max_rounds = 1
	default_ammo = /datum/ammo/rocket/recoilless
	gun_type = /obj/item/weapon/gun/launcher/rocket/recoillessrifle
	flags_magazine = NONE
	reload_delay = 30

/obj/item/ammo_magazine/rocket/recoilless/light
	name = "\improper 67mm light-explosive shell"
	desc = "A light explosive shell for the T-160 recoilless rifle. Causes a light explosion over a large area. Can go farther than other shells of its type due to the light payload. Requires specialized storage to carry."
	caliber = "67mm shell"
	icon_state = "shell_le"
	w_class = WEIGHT_CLASS_BULKY
	max_rounds = 1
	default_ammo = /datum/ammo/rocket/recoilless/light
	gun_type = /obj/item/weapon/gun/launcher/rocket/recoillessrifle
	flags_magazine = NONE
	reload_delay = 10

/obj/item/ammo_magazine/rocket/recoilless/heat
	name = "\improper 67mm HEAT shell"
	desc = "A high explosive-anti tank shell for the T-160 recoilless rifle. Causes a medium explosion over a small area after impacting. Requires specialized storage to carry."
	caliber = "67mm shell"
	icon_state = "shell_heat"
	w_class = WEIGHT_CLASS_BULKY
	max_rounds = 1
	default_ammo = /datum/ammo/rocket/recoilless/heat
	gun_type = /obj/item/weapon/gun/launcher/rocket/recoillessrifle
	flags_magazine = NONE
	reload_delay = 30


/obj/item/ammo_magazine/internal/launcher/rocket/recoilless
	name = "\improper 67mm internal tube"
	desc = "The internal tube of a T-TBD recoilless rifle."
	caliber = "rocket"
	default_ammo = /datum/ammo/rocket/recoilless
	max_rounds = 1
	current_rounds = 0
	reload_delay = 30


//-------------------------------------------------------
//one use rpg

/obj/item/ammo_magazine/rocket/oneuse
	name = "\improper 68mm high-explosive shell"
	desc = "A rocket used to reload a one use rocket once returned to an armory."
	caliber = "rocket"
	icon_state = "rocket"
	w_class = WEIGHT_CLASS_BULKY
	max_rounds = 1
	default_ammo = /datum/ammo/rocket/oneuse
	gun_type = /obj/item/weapon/gun/launcher/rocket/oneuse
	flags_magazine = NONE
	reload_delay = 30

/obj/item/ammo_magazine/internal/launcher/rocket/oneuse
	name = "\improper 67mm internal tube"
	desc = "The internal tube of a one use rpg."
	caliber = "rocket"
	default_ammo = /datum/ammo/rocket/recoilless
	max_rounds = 1
	current_rounds = 0
	reload_delay = 30

//-------------------------------------------------------
//M5 RPG'S MEAN FUCKING COUSIN

/obj/item/ammo_magazine/rocket/m57a4
	name = "\improper 84mm thermobaric rocket array"
	desc = "A thermobaric rocket tube for a M57A4 quad launcher. Activate in hand to receive some metal when it's used up."
	caliber = "rocket array"
	icon_state = "quad_rocket"
	max_rounds = 4
	default_ammo = /datum/ammo/rocket/wp/quad
	gun_type = /obj/item/weapon/gun/launcher/rocket/m57a4
	reload_delay = 200

/obj/item/ammo_magazine/internal/launcher/rocket/m57a4
	desc = "The internal tube of an M57A4 thermobaric launcher."
	caliber = "rocket array"
	default_ammo = /datum/ammo/rocket/wp/quad
	max_rounds = 4

//-------------------------------------------------------
//Minigun

/obj/item/ammo_magazine/minigun
	name = "rotating ammo drum (7.62x51mm)"
	desc = "A huge ammo drum for a huge gun."
	caliber = "7.62x51mm"
	icon_state = "minigun"
	default_ammo = /datum/ammo/bullet/minigun
	max_rounds = 300
	reload_delay = 50 //Hard to reload.
	w_class = WEIGHT_CLASS_NORMAL
	gun_type = /obj/item/weapon/gun/minigun

