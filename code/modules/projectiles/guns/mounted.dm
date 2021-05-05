
//I didnt know where else to put this, so Im bringing it from the deleted smartgun_mount.dm
/obj/item/coin/marine/engineer
	name = "marine engineer support token"
	desc = "Insert this into a engineer vendor in order to access a support artillery weapon."
	flags_token = TOKEN_ENGI

//box for storage of ammo and gun
/obj/item/storage/box/standard_hmg 
	name = "\improper TL-102 crate"
	desc = "A large metal case with Japanese writing on the top. However it also comes with English text to the side. This is a TL-102 heavy smartgun, it clearly has various labeled warnings."
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "crate"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 7
	bypass_w_limit = list(
		/obj/item/weapon/gun/mounted,
		/obj/item/ammo_magazine/mounted,
	)

/obj/item/storage/box/standard_hmg/Initialize()
	. = ..()
	new /obj/item/weapon/gun/mounted(src) //gun itself
	new /obj/item/ammo_magazine/mounted(src) //ammo for the gun
	new /obj/item/ammo_magazine/mounted(src)

//TL-102, now with full auto. It is not a superclass of deployed guns, however there are a few varients.
/obj/item/weapon/gun/mounted
    name = "\improper TL-102 mounted heavy smartgun"
    desc = "The TL-102 heavy machinegun, it's too heavy to be wielded or operated without the tripod. IFF capable. No extra work required, just deploy it. Can be repaired with a blowtorch once deployed."

    w_class = WEIGHT_CLASS_HUGE
    flags_equip_slot = ITEM_SLOT_BACK
    icon = 'icons/Marine/marine-hmg.dmi'
    icon_state = "turret_icon"

    fire_sound = 'sound/weapons/guns/fire/hmg2.ogg'
    reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'

    current_mag = /obj/item/ammo_magazine/mounted

    gun_iff_signal = list(ACCESS_IFF_MARINE)

    scatter = 20
    fire_delay = 2

    burst_amount = 3
    burst_delay = 1
    extra_delay = 1
    
    flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_IS_DEPLOYABLE|GUN_NO_WIELDING|GUN_WIELDED_FIRING_ONLY
    gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC)

    deploy_time = 5 SECONDS

    deploy_integrity = 300
    deploy_max_integrity = 300

    deploy_name = "\improper TL-102 mounted heavy smartgun"
    deploy_desc = "A deployed and mounted heavy smartgun, ready to rock. It fires specialized tungsten rounds for increased armor penetration. Can be repaired with a blowtorch."
    deploy_icon = 'icons/Marine/marine-hmg.dmi'
    deploy_icon_state = "turret"

    deploy_icon_full = "turret"
    deploy_icon_empty = "turret_e"

///This and get_ammo_count is to make sure the ammo counter functions.
/obj/item/weapon/gun/mounted/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/mounted/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	else
		return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

///Unmovable ship mounted version.
/obj/item/weapon/gun/mounted/hsg_nest
    name = "\improper TL-102 heavy smartgun nest"
    desc = "A TL-102 heavy smartgun mounted upon a small reinforced post with sandbags to provide a small machinegun nest for all your defense purpose needs.</span>"
    icon = 'icons/Marine/marine-hmg.dmi'

    current_mag = /obj/item/ammo_magazine/mounted/hsg_nest

    pickup_disabled = TRUE

    deployed_view_offset = 6

    deploy_name = "\improper TL-102 heavy smartgun nest"
    deploy_desc = "A TL-102 heavy smartgun mounted upon a small reinforced post with sandbags to provide a small machinegun nest for all your defense purpose needs.</span>"

    deploy_icon_state = "entrenched"
    deploy_icon_full = "entrenched"
    deploy_icon_empty = "entrenched_e"

//This is my meme version, the first version of the TL-102 to have auto-fire, revel in its presence.
/obj/item/weapon/gun/mounted/death
    name = "\improper Death incarnate"
    desc = "It looks like a regular TL-102, however glowing archaeic writing glows faintly on its sides and top. It beckons for blood."
    icon = 'icons/Marine/marine-hmg.dmi'


    gun_iff_signal = list()

    aim_slowdown = 3
    scatter = 30

    fire_delay = 0.1
    burst_amount = 3
    burst_delay = 0.1

    aim_slowdown = 3
    wield_delay = 5 SECONDS

    flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_IS_DEPLOYABLE

    deploy_name = "\improper Death incarnate"
    deploy_desc = "It looks like a regular TL-102, however glowing archaeic writing glows faintly on its sides and top. It beckons for blood."
