//FEB 2024 NOTE: some of these are missing loading_sounds, fix it before using these ingame
//Special ammo magazines for hardpoint modules. Some may not be here since you can use normal magazines on them
/obj/item/ammo_magazine/tank
	icon = 'icons/obj/items/ammo/tank.dmi'
	magazine_flags = NONE
	///loading sound to play when
	var/loading_sound

/obj/item/ammo_magazine/tank/ltb_cannon
	name = "LTB HE shell (105mm)"
	desc = "A 105mm high explosive shell filled with a deadly explosive payload."
	caliber = CALIBER_105MM
	icon_state = "ltb"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/rocket/ltb
	max_rounds = 1
	loading_sound = 'sound/vehicles/weapons/ltb_reload.ogg'

/obj/item/ammo_magazine/tank/ltb_cannon/heavy
	name = "LTB HE+ shell (105mm)"
	desc = "A 105mm high explosive shell filled with an incredibly explosive payload."
	default_ammo = /datum/ammo/rocket/ltb/heavy
	magazine_flags = MAGAZINE_NOT_FABRICABLE

/obj/item/ammo_magazine/tank/ltb_cannon/apfds
	name = "LTB APFDS round (105mm)"
	desc = "A 105mm armor piercing shell with exceptional velocity and penetrating characteristics. Will pierce through walls and targets."
	icon_state = "ltb_apfds"
	default_ammo = /datum/ammo/bullet/tank_apfds

/obj/item/ammo_magazine/tank/ltb_cannon/canister
	name = "LTB Canister round (105mm)"
	desc = "A 105mm canister shell for demolishing soft targets. The payload of hundreds of small metal balls imitates a shotgun blast in trajectory."
	icon_state = "ltb_canister"
	default_ammo = /datum/ammo/tx54/tank_cannister

/obj/item/ammo_magazine/tank/ltaap_chaingun
	name = "\improper LTA-AP chaingun Magazine"
	desc = "A primary armament chaingun magazine."
	caliber = CALIBER_762X51
	icon_state = "ltaap"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/bullet/minigun/ltaap
	max_rounds = 150
	loading_sound = 'sound/weapons/guns/interact/working_the_bolt.ogg'


/obj/item/ammo_magazine/tank/flamer
	name = "Flamer Magazine"
	desc = "A secondary armament flamethrower magazine"
	caliber = CALIBER_FUEL_THICK
	icon_state = "flametank_large"
	icon = 'icons/obj/items/ammo/flamer.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/flamethrower/tank_flamer
	max_rounds = 120

/obj/item/ammo_magazine/tank/towlauncher
	name = "TOW Launcher Magazine"
	desc = "A secondary armament rocket magazine"
	caliber = CALIBER_68MM
	icon_state = "quad_rocket"
	icon = 'icons/obj/items/ammo/rocket.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/rocket/ap //Fun fact, AP rockets seem to be a straight downgrade from normal rockets. Maybe I'm missing something...
	max_rounds = 5

/obj/item/ammo_magazine/tank/secondary_cupola
	name = "HSG-102 Cupola Magazine"
	desc = "A secondary armament MG magazine"
	caliber = CALIBER_10X28
	icon_state = "cupola"
	loading_sound = 'sound/weapons/guns/interact/working_the_bolt.ogg'
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/bullet/cupola
	max_rounds = 75

/obj/item/ammo_magazine/tank/tank_glauncher
	name = "Grenade Launcher Magazine"
	desc = "A secondary armament grenade magazine"
	caliber = CALIBER_40MM
	icon_state = "glauncher_2"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/grenade_container
	max_rounds = 10

/obj/item/ammo_magazine/tank/tank_glauncher/update_icon_state()
	if(current_rounds >= max_rounds)
		icon_state = "glauncher_2"
	else if(current_rounds <= 0)
		icon_state = "glauncher_0"
	else
		icon_state = "glauncher_1"

/obj/item/ammo_magazine/tank/tank_slauncher
	name = "Smoke Launcher Magazine"
	desc = "A support armament grenade magazine"
	caliber = CALIBER_40MM
	icon_state = "slauncher_1"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/grenade_container/smoke
	max_rounds = 6

/obj/item/ammo_magazine/tank/tank_slauncher/update_icon_state()
	icon_state = "slauncher_[current_rounds <= 0 ? "0" : "1"]"

//SOM tank
/obj/item/ammo_magazine/tank/volkite_carronade
	name = "volkite carronade cell"
	desc = "A heavy, disposable cell used for powering a volkite carronade."
	caliber = CALIBER_84MM
	icon_state = "som_tank_cell"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/energy/volkite/heavy
	max_rounds = 3

/obj/item/ammo_magazine/tank/particle_lance
	name = "particle lance energy cell"
	desc = "A heavy, disposable cell used for powering a tank mounted particle lance."
	caliber = CALIBER_84MM
	icon_state = "particle_lance_cell"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/energy/particle_lance
	max_rounds = 1
	loading_sound = 'sound/vehicles/weapons/ltb_reload.ogg'

/obj/item/ammo_magazine/tank/secondary_mlrs
	name = "\improper MLRS magazine"
	desc = "A secondary armament MLRS magazine. Loaded with homing HE rockets"
	caliber = CALIBER_40MM
	icon_state = "secondary_mlrs"
	w_class = WEIGHT_CLASS_GIGANTIC
	default_ammo = /datum/ammo/rocket/homing
	max_rounds = 12

/obj/item/ammo_magazine/tank/coilgun
	name = "coilgun projectiles"
	desc = "A set of extremely dense kinetic penetrator rounds for a tank mounted coilgun."
	caliber = CALIBER_84MM
	icon_state = "coilgun"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/rocket/coilgun/holder //this doesn't strictly matter since its overridden
	max_rounds = 1
	loading_sound = 'sound/vehicles/weapons/coilgun_cycle.ogg'

/obj/item/ammo_magazine/tank/secondary_flamer_tank
	name = "napalm stream tank"
	desc = "A fuel tank containing fuel for the secondary vehicle mounted flamer. This tank contains a more fluid mix that flows easier but flames less area at once."
	caliber = CALIBER_FUEL_THICK
	icon_state = "sflamer"
	max_rounds = 150
	default_ammo = /datum/ammo/flamethrower/armored_spray
