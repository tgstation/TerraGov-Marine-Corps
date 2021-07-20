//-------------------------------------------------------
//SNIPER RIFLES
//Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.

/obj/item/ammo_magazine/sniper
	name = "\improper T-26 magazine (10x28mm)"
	desc = "A magazine of antimaterial rifle ammo."
	caliber = CALIBER_10X28
	icon_state = "t26"
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 15
	default_ammo = /datum/ammo/bullet/sniper
	gun_type = /obj/item/weapon/gun/rifle/sniper/antimaterial
	reload_delay = 3
	icon_state_mini = "mag_sniper"


/obj/item/ammo_magazine/sniper/incendiary
	name = "\improper T-26 incendiary magazine (10x28mm)"
	default_ammo = /datum/ammo/bullet/sniper/incendiary
	icon_state = "t26_inc"
	icon_state_mini = "mag_sniper_red"

/obj/item/ammo_magazine/sniper/flak
	name = "\improper T-26 flak magazine (10x28mm)"
	default_ammo = /datum/ammo/bullet/sniper/flak
	icon_state = "t26_flak"
	icon_state_mini = "mag_sniper_blue"


//M42C magazine

/obj/item/ammo_magazine/sniper/elite
	name = "\improper M42C marksman magazine (10x99mm)"
	default_ammo = /datum/ammo/bullet/sniper/elite
	gun_type = /obj/item/weapon/gun/rifle/sniper/elite
	caliber = CALIBER_10X99
	icon_state = "m42c"
	max_rounds = 6


//SVD //Based on the actual Dragunov sniper rifle.

/obj/item/ammo_magazine/sniper/svd
	name = "\improper SVD magazine (7.62x54mmR)"
	desc = "A large caliber magazine for the SVD sniper rifle."
	caliber = CALIBER_762X54
	icon_state = "svd"
	default_ammo = /datum/ammo/bullet/sniper/svd
	max_rounds = 10
	gun_type = /obj/item/weapon/gun/rifle/sniper/svd
	icon_state_mini = "mag_rifle"



//tx8 magazines

/obj/item/ammo_magazine/rifle/tx8
	name = "\improper high velocity magazine (10x28mm)"
	desc = "A magazine of overpressuered high velocity rounds for use in the TX-8 battle rifle. The TX-8 battle rifle is the only gun that can chamber these rounds."
	icon_state = "tx8"
	caliber = CALIBER_10X28_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/tx8
	max_rounds = 25
	gun_type = /obj/item/weapon/gun/rifle/tx8
	icon_state_mini = "mag_rifle_big"

/obj/item/ammo_magazine/rifle/tx8/incendiary
	name = "\improper high velocity incendiary magazine (10x28mm)"
	desc = "A magazine of overpressuered high velocity incendiary rounds for use in the TX-8 battle rifle. The TX-8 battle rifle is the only gun that can chamber these rounds."
	caliber = CALIBER_10X28_CASELESS
	icon_state = "tx8_incend"
	default_ammo = /datum/ammo/bullet/rifle/tx8/incendiary
	gun_type = /obj/item/weapon/gun/rifle/tx8
	icon_state_mini = "mag_rifle_big_red"

/obj/item/ammo_magazine/rifle/tx8/impact
	name = "\improper high velocity impact magazine (10x28mm)"
	desc = "A magazine of overpressuered high velocity impact rounds for use in the TX-8 battle rifle. The TX-8 battle rifle is the only gun that can chamber these rounds."
	icon_state = "tx8_impact"
	default_ammo = /datum/ammo/bullet/rifle/tx8/impact
	gun_type = /obj/item/weapon/gun/rifle/tx8
	icon_state_mini = "mag_rifle_big_blue"

//-------------------------------------------------------
//MINIGUN-Powerpack edition
/obj/item/ammo_magazine/internal/minigun
	name = "integrated minigun belt"
	icon_state = "minigun"
	caliber = CALIBER_762X51
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/minigun

//-------------------------------------------------------
//M5 RPG

/obj/item/ammo_magazine/rocket
	name = "\improper generic high-explosive rocket"
	desc = "A precursor to all kinds of rocket ammo unfit for normal use. How did you get this anyway?"
	caliber = CALIBER_84MM
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
	caliber = CALIBER_84MM
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
	caliber = CALIBER_84MM
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
	caliber = CALIBER_67MM
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
	caliber = CALIBER_67MM
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
	caliber = CALIBER_67MM
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
	caliber = CALIBER_67MM
	default_ammo = /datum/ammo/rocket/recoilless
	max_rounds = 1
	current_rounds = 0
	reload_delay = 30


//-------------------------------------------------------
//one use rpg

/obj/item/ammo_magazine/rocket/oneuse
	name = "\improper 68mm high-explosive shell"
	desc = "A rocket used to reload a one use rocket once returned to an armory."
	caliber = CALIBER_68MM
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
	caliber = CALIBER_68MM
	default_ammo = /datum/ammo/rocket/recoilless
	max_rounds = 1
	current_rounds = 0
	reload_delay = 30

//-------------------------------------------------------
//M5 RPG'S MEAN FUCKING COUSIN

/obj/item/ammo_magazine/rocket/m57a4
	name = "\improper 84mm thermobaric rocket array"
	desc = "A thermobaric rocket tube for a T-57 quad launcher. Activate in hand to receive some metal when it's used up. The Rockets don't do much damage on a direct hit, but the fire effect is strong.."
	caliber = CALIBER_ROCKETARRAY
	icon_state = "quad_rocket"
	max_rounds = 4
	default_ammo = /datum/ammo/rocket/wp/quad
	gun_type = /obj/item/weapon/gun/launcher/rocket/m57a4
	reload_delay = 200

/obj/item/ammo_magazine/rocket/m57a4/ds
	name = "\improper 84mm thermobaric rocket array"
	desc = "A thermobaric rocket tube for a M57A4 quad launcher. Activate in hand to receive some metal when it's used up. Has huge red markings..."
	caliber = CALIBER_ROCKETARRAY
	icon_state = "quad_rocket"
	max_rounds = 4
	default_ammo = /datum/ammo/rocket/wp/quad/ds

/obj/item/ammo_magazine/internal/launcher/rocket/m57a4
	desc = "The internal tube of an M57A4 thermobaric launcher."
	caliber = CALIBER_ROCKETARRAY
	default_ammo = /datum/ammo/rocket/wp/quad
	max_rounds = 4

/obj/item/ammo_magazine/internal/launcher/rocket/m57a4/ds
	default_ammo = /datum/ammo/rocket/wp/quad/ds

// railgun

/obj/item/ammo_magazine/railgun
	name = "railgun canister (rail projectile)"
	desc = "A canister holding a projectile to be used inside a railgun."
	caliber = CALIBER_RAILGUN
	icon_state = "railgun"
	default_ammo = /datum/ammo/bullet/railgun
	max_rounds = 1
	reload_delay = 20 //Hard to reload.
	w_class = WEIGHT_CLASS_NORMAL
	gun_type = /obj/item/weapon/gun/rifle/railgun
	icon_state_mini = "mag_railgun"

// pepperball

/obj/item/ammo_magazine/rifle/pepperball
	name = "pepperball canister (SAN balls)"
	desc = "A canister holding a projectile to be used inside a pepperball gun."
	caliber = CALIBER_PEPPERBALL
	icon_state = "pepperball"
	default_ammo = /datum/ammo/bullet/pepperball
	max_rounds = 70
	w_class = WEIGHT_CLASS_NORMAL
	gun_type = /obj/item/weapon/gun/rifle/pepperball
	icon_state_mini = "mag_rifle"
