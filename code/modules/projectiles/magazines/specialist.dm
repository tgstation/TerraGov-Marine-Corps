//-------------------------------------------------------
//SNIPER RIFLES
//Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.

/obj/item/ammo_magazine/sniper
	name = "\improper SR-26 magazine (10x28mm)"
	desc = "A magazine of antimaterial rifle ammo."
	caliber = CALIBER_10X28
	icon_state = "t26"
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 15
	default_ammo = /datum/ammo/bullet/sniper
	reload_delay = 3
	icon_state_mini = "mag_sniper"


/obj/item/ammo_magazine/sniper/incendiary
	name = "\improper SR-26 incendiary magazine (10x28mm)"
	default_ammo = /datum/ammo/bullet/sniper/incendiary
	icon_state = "t26_inc"
	icon_state_mini = "mag_sniper_red"
	bonus_overlay = "t26_incend"

/obj/item/ammo_magazine/sniper/flak
	name = "\improper SR-26 flak magazine (10x28mm)"
	default_ammo = /datum/ammo/bullet/sniper/flak
	icon_state = "t26_flak"
	icon_state_mini = "mag_sniper_blue"
	bonus_overlay = "t26_flak"

//SR-42 magazine

/obj/item/ammo_magazine/sniper/elite
	name = "\improper SR-42 marksman magazine (10x99mm)"
	default_ammo = /datum/ammo/bullet/sniper/elite
	caliber = CALIBER_10X99
	icon_state = "m42c"
	icon_state_mini = "mag_rifle_big_white"
	max_rounds = 6


//SVD //Based on the actual Dragunov sniper rifle.

/obj/item/ammo_magazine/sniper/svd
	name = "\improper SVD magazine (7.62x54mmR)"
	desc = "A large caliber magazine for the SVD sniper rifle."
	caliber = CALIBER_762X54
	icon_state = "svd"
	default_ammo = /datum/ammo/bullet/sniper/svd
	max_rounds = 10
	icon_state_mini = "mag_rifle"



//tx8 magazines

/obj/item/ammo_magazine/rifle/tx8
	name = "\improper high velocity magazine (10x28mm)"
	desc = "A magazine of overpressuered high velocity rounds for use in the BR-8 battle rifle. The BR-8 battle rifle is the only gun that can chamber these rounds."
	icon_state = "tx8"
	caliber = CALIBER_10X28_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/tx8
	max_rounds = 25
	icon_state_mini = "mag_rifle_big"

/obj/item/ammo_magazine/rifle/tx8/incendiary
	name = "\improper high velocity incendiary magazine (10x28mm)"
	desc = "A magazine of overpressuered high velocity incendiary rounds for use in the BR-8 battle rifle. The BR-8 battle rifle is the only gun that can chamber these rounds."
	caliber = CALIBER_10X28_CASELESS
	icon_state = "tx8_incend"
	default_ammo = /datum/ammo/bullet/rifle/tx8/incendiary
	icon_state_mini = "mag_rifle_big_red"
	bonus_overlay = "tx8_incend"

/obj/item/ammo_magazine/rifle/tx8/impact
	name = "\improper high velocity impact magazine (10x28mm)"
	desc = "A magazine of overpressuered high velocity impact rounds for use in the BR-8 battle rifle. The BR-8 battle rifle is the only gun that can chamber these rounds."
	icon_state = "tx8_impact"
	default_ammo = /datum/ammo/bullet/rifle/tx8/impact
	icon_state_mini = "mag_rifle_big_blue"
	bonus_overlay = "tx8_impact"


//-------------------------------------------------------
//M5 RPG

/obj/item/ammo_magazine/rocket
	name = "\improper generic high-explosive rocket"
	desc = "A precursor to all kinds of rocket ammo unfit for normal use. How did you get this anyway?"
	caliber = CALIBER_84MM
	icon_state = "rocket"
	w_class = WEIGHT_CLASS_NORMAL
	flags_magazine = MAGAZINE_REFUND_IN_CHAMBER
	max_rounds = 1
	default_ammo = /datum/ammo/rocket
	reload_delay = 60

/obj/item/ammo_magazine/rocket/attack_self(mob/user)
	if(current_rounds > 0)
		to_chat(user, span_notice("Not with a missile inside!"))
		return
	to_chat(user, span_notice("You begin taking apart the empty tube frame..."))
	if(!do_after(user, 10, NONE, src))
		return
	user.visible_message("[user] deconstructs the rocket tube frame.",span_notice("You take apart the empty frame."))
	var/obj/item/stack/sheet/metal/metal = new(get_turf(user))
	metal.amount = 2
	user.drop_held_item()
	qdel(src)

/obj/item/ammo_magazine/rocket/update_icon()
	overlays.Cut()
	if(current_rounds > 0)
		return
	name = "empty rocket frame"
	desc = "A spent rocket rube. Activate it to deconstruct it and receive some materials."
	icon_state = istype(src, /obj/item/ammo_magazine/rocket/m57a4) ? "quad_rocket_e" : "rocket_e"

//-------------------------------------------------------
//RL-152

/obj/item/ammo_magazine/rocket/sadar
	name = "\improper 84mm 'L-G' high-explosive rocket"
	desc = "A warhead for the RL-152 rocket launcher. Carries a bogstandard HE warhead that explodes. Due to being laser-guided, it will hit exactly where you aim, however the payload is smaller due to the internal space required for this.  When empty, use this frame to deconstruct it."
	caliber = CALIBER_84MM
	icon_state = "rocket_he"
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 1
	default_ammo = /datum/ammo/rocket/he
	reload_delay = 60
	bonus_overlay = "rocket_he"

/obj/item/ammo_magazine/rocket/sadar/unguided
	name = "\improper 84mm 'Unguided' high-explosive rocket"
	desc = "A warhead for the RL-152 rocket launcher. Carries a bogstandard HE warhead that explodes. It is entirely unguided, and thus 'Dumb', this allows for a larger payload, and a skilled operator can hit longer ranged hits that a laser-guided rocket could not reach at all.  When empty, use this frame to deconstruct it."
	icon_state = "rocket_he_unguided"
	default_ammo = /datum/ammo/rocket/he/unguided

/obj/item/ammo_magazine/rocket/sadar/ap
	name = "\improper 84mm 'L-G' anti-armor rocket"
	desc = "A tube for an AP rocket, the warhead of which inside is a missile assisted kinetic penetrator that will devastate just about anything that it hits internally, but will do nothing to the surrounding armor. When empty, use this frame to deconstruct it."
	icon_state = "rocket_ap"
	default_ammo = /datum/ammo/rocket/ap
	bonus_overlay = "rocket_ap"

/obj/item/ammo_magazine/rocket/sadar/wp
	name = "\improper 84mm 'L-G' white-phosphorus rocket"
	desc = "A highly destructive warhead that bursts into deadly flames on impact. Due to being laser-guided, it will hit exactly where you aim, however the payload is smaller due to the internal space required for this. Use this in hand to deconstruct it."
	icon_state = "rocket_wp"
	default_ammo = /datum/ammo/rocket/wp
	bonus_overlay = "rocket_wp"

/obj/item/ammo_magazine/rocket/sadar/wp/unguided
	name = "\improper 84mm 'Unguided' white-phosphorus rocket"
	desc = "A highly destructive warhead that bursts into deadly flames on impact. It is entirely unguided, and thus 'Dumb', the benefit of this is a bigger overall payload, and a skilled operator can hit longer ranged hits that a laser-guided rocket could not reach at all. Use this in hand to deconstruct it."
	icon_state = "rocket_wp_unguided"
	default_ammo = /datum/ammo/rocket/wp/unguided

//-------------------------------------------------------
//RL-160 recoilless rifle

/obj/item/ammo_magazine/rocket/recoilless
	name = "\improper 67mm high-explosive shell"
	desc = "A high explosive shell for the RL-160 recoilless rifle. Causes a heavy explosion over a small area. Requires specialized storage to carry."
	caliber = CALIBER_67MM
	icon_state = "shell"
	w_class = WEIGHT_CLASS_BULKY
	max_rounds = 1
	default_ammo = /datum/ammo/rocket/recoilless
	reload_delay = 30

/obj/item/ammo_magazine/rocket/recoilless/light
	name = "\improper 67mm light-explosive shell"
	desc = "A light explosive shell for the RL-160 recoilless rifle. Causes a light explosion over a large area. Can go farther than other shells of its type due to the light payload. Requires specialized storage to carry."
	icon_state = "shell_le"
	default_ammo = /datum/ammo/rocket/recoilless/light
	reload_delay = 10

/obj/item/ammo_magazine/rocket/recoilless/low_impact
	name = "\improper 67mm light-explosive shell"
	desc = "A light explosive shell for the RL-160 recoilless rifle. Causes a light explosion over a large area but low impact damage. Can go farther than other shells of its type due to the light payload. Requires specialized storage to carry."
	icon_state = "shell_le"
	default_ammo = /datum/ammo/rocket/recoilless/low_impact
	reload_delay = 10

/obj/item/ammo_magazine/rocket/recoilless/heat
	name = "\improper 67mm HEAT shell"
	desc = "A high explosive-anti tank shell for the RL-160 recoilless rifle. Fires a penetrating shot with no explosion. It will do moderate damage to all types of enemies, but does not sunder their armor. Requires specialized storage to carry."
	icon_state = "shell_heat"
	default_ammo = /datum/ammo/rocket/recoilless/heat

/obj/item/ammo_magazine/rocket/recoilless/heam
	name = "\improper 67mm HEAM shell"
	desc = "A high explosive-anti mechg shell for the RL-160 recoilless rifle. Fires a penetrating shot designed specifically to penetrate mech armor, but suffers from poor accuracy against other targets. Requires specialized storage to carry."
	icon_state = "shell_heat"
	default_ammo = /datum/ammo/rocket/recoilless/heat/mech

/obj/item/ammo_magazine/rocket/recoilless/smoke
	name = "\improper 67mm Chemical (Smoke) shell"
	desc = "A chemical shell for the RL-160 recoilless rifle. Fires a low velocity shell for close quarters application of chemical gas, friendlies will be able to easily dodge it due to low velocity. This warhead contains thick concealing smoke. Requires specialized storage to carry."
	icon_state = "shell_smoke"
	default_ammo = /datum/ammo/rocket/recoilless/chemical

/obj/item/ammo_magazine/rocket/recoilless/cloak
	name = "\improper 67mm Chemical (Cloak) shell"
	desc = "A chemical shell for the RL-160 recoilless rifle. Fires a low velocity shell for close quarters application of chemical gas, friendlies will be able to easily dodge it due to low velocity. This warhead contains advanced cloaking smoke. Requires specialized storage to carry."
	icon_state = "shell_cloak"
	default_ammo = /datum/ammo/rocket/recoilless/chemical/cloak

/obj/item/ammo_magazine/rocket/recoilless/plasmaloss
	name = "\improper 67mm Chemical (Tanglefoot) shell"
	desc = "A chemical shell for the RL-160 recoilless rifle. Fires a low velocity shell for close quarters application of chemical gas, friendlies will be able to easily dodge it due to low velocity. This warhead contains plasma-draining Tanglefoot smoke. Requires specialized storage to carry."
	icon_state = "shell_tanglefoot"
	default_ammo = /datum/ammo/rocket/recoilless/chemical/plasmaloss


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
	desc = "A thermobaric rocket tube for a RL-57 quad launcher. Activate in hand to receive some metal when it's used up. The Rockets don't do much damage on a direct hit, but the fire effect is strong.."
	caliber = CALIBER_ROCKETARRAY
	icon_state = "quad_rocket"
	max_rounds = 4
	default_ammo = /datum/ammo/rocket/wp/quad
	reload_delay = 10 SECONDS

/obj/item/ammo_magazine/rocket/m57a4/ds
	name = "\improper 84mm thermobaric rocket array"
	desc = "A thermobaric rocket tube for a RL-57 quad launcher. Activate in hand to receive some metal when it's used up. Has huge red markings..."
	caliber = CALIBER_ROCKETARRAY
	icon_state = "quad_rocket"
	max_rounds = 4
	default_ammo = /datum/ammo/rocket/wp/quad/ds
	reload_delay = 2 SECONDS

/obj/item/ammo_magazine/internal/launcher/rocket/m57a4
	desc = "The internal tube of an RL-57 thermobaric launcher."
	caliber = CALIBER_ROCKETARRAY
	default_ammo = /datum/ammo/rocket/wp/quad
	max_rounds = 4

/obj/item/ammo_magazine/internal/launcher/rocket/m57a4/ds
	default_ammo = /datum/ammo/rocket/wp/quad/ds

//SOM RPG
/obj/item/ammo_magazine/rocket/som
	name = "\improper 84mm high-explosive RPG"
	desc = "A high explosive warhead for the V-71 rocket launcher. Causes a strong explosion over a respectable area."
	icon_state = "rpg_he"
	default_ammo = /datum/ammo/rocket/som
	reload_delay = 2 SECONDS
	bonus_overlay = "rpg_he"

/obj/item/ammo_magazine/rocket/som/light
	name = "\improper 84mm light-explosive RPG"
	desc = "A light explosive warhead for the V-71 rocket launcher. Causes a light explosion over a large area but low impact damage."
	icon_state = "rpg_le"
	default_ammo = /datum/ammo/rocket/som/light
	reload_delay = 1 SECONDS
	bonus_overlay = "rpg_le"

/obj/item/ammo_magazine/rocket/som/heat
	name = "\improper 84mm HEAT RPG"
	desc = "A high explosive anti armor warhead for the V-71 rocket launcher. Designed to punch through the toughest armor."
	icon_state = "rpg_heat"
	default_ammo = /datum/ammo/rocket/som/heat
	bonus_overlay = "rpg_heat"

/obj/item/ammo_magazine/rocket/som/thermobaric
	name = "\improper 84mm thermobaric RPG"
	desc = "A thermobaric warhead for the V-71 rocket launcher. Causes a powerful fuel air explosion over a moderate area."
	icon_state = "rpg_thermobaric"
	default_ammo = /datum/ammo/rocket/som/thermobaric
	bonus_overlay = "rpg_thermobaric"

/obj/item/ammo_magazine/rocket/som/rad
	name = "\improper 84mm  irrad RPG"
	desc = "A irrad warhead for the V-71 rocket launcher. Releases a devastating milisecond burst of radiation, debilitating anything caught in the blast radius."
	icon_state = "rpg_rad"
	default_ammo = /datum/ammo/rocket/som/rad
	bonus_overlay = "rpg_rad"

/obj/item/ammo_magazine/rocket/som/incendiary
	name = "\improper 84mm incendiary RPG"
	desc = "An incendiary warhead for the V-71 rocket launcher. Releases a white phosphorus payload, burning anything in a moderate blast radius."
	icon_state = "rpg_incendiary"
	default_ammo = /datum/ammo/rocket/wp/quad/som
	bonus_overlay = "rpg_incendiary"

//ICC RPG
/obj/item/ammo_magazine/rocket/icc
	name = "\improper 84mm high-explosive tube"
	desc = "A high explosive warhead for MP-IRL rocket launcher. Causes a strong explosion over a respectable area."
	icon_state = "iccrpg_he"
	default_ammo = /datum/ammo/rocket/som
	reload_delay = 2 SECONDS
	bonus_overlay = "iccrpg_he"

/obj/item/ammo_magazine/rocket/icc/light
	name = "\improper 84mm light-explosive tube"
	desc = "A light explosive warhead for the MP-IRL rocket launcher. Causes a light explosion over a large area but low impact damage."
	icon_state = "iccrpg_le"
	default_ammo = /datum/ammo/rocket/som/light
	reload_delay = 1 SECONDS
	bonus_overlay = "iccrpg_le"

/obj/item/ammo_magazine/rocket/icc/heat
	name = "\improper 84mm HEAT tube"
	desc = "A high explosive anti armor warhead for the MP-IRL rocket launcher. Designed to punch through the toughest armor."
	icon_state = "iccrpg_heat"
	default_ammo = /datum/ammo/rocket/som/heat
	bonus_overlay = "iccrpg_heat"

/obj/item/ammo_magazine/rocket/icc/thermobaric
	name = "\improper 84mm thermobaric tube"
	desc = "A thermobaric warhead for the MP-IRL rocket launcher. Causes a powerful fuel air explosion over a moderate area."
	icon_state = "iccrpg_thermobaric"
	default_ammo = /datum/ammo/rocket/som/thermobaric
	bonus_overlay = "iccrpg_thermobaric"

// railgun

/obj/item/ammo_magazine/railgun
	name = "railgun canister (Armor Piercing Discarding Sabot)"
	desc = "A canister holding a tungsten projectile to be used inside a railgun. APDS is written across the canister, this round will penetrate through most armor, but will not leave much of a hole."
	caliber = CALIBER_RAILGUN
	icon_state = "railgun"
	default_ammo = /datum/ammo/bullet/railgun
	max_rounds = 3
	reload_delay = 20 //Hard to reload.
	w_class = WEIGHT_CLASS_NORMAL
	icon_state_mini = "mag_railgun"

/obj/item/ammo_magazine/railgun/hvap
	name = "railgun canister (High Velocity Armor Piericing)"
	desc = "A canister holding a tungsten projectile to be used inside a railgun. HVAP is written across the canister. This round has less punching power than other railgun canister types, but will leave a sizeable hole in the targets armor."
	icon_state = "railgun_hvap"
	icon_state_mini = "mag_railgun_blue"
	default_ammo = /datum/ammo/bullet/railgun/hvap

/obj/item/ammo_magazine/railgun/smart
	name = "railgun canister (Smart Armor Piericing)"
	desc = "A canister holding a tungsten projectile to be used inside a railgun. SAP is written across the canister. This round has poor punching power due to low velocity for the smart ammunition, but will leave a target significantly staggered and stunned due to the impact."
	icon_state = "railgun_smart"
	icon_state_mini = "mag_railgun_green"
	default_ammo = /datum/ammo/bullet/railgun/smart

// pepperball

/obj/item/ammo_magazine/rifle/pepperball
	name = "pepperball canister (SAN balls)"
	desc = "A canister holding a projectile to be used inside a pepperball gun."
	caliber = CALIBER_PEPPERBALL
	icon_state = "pepperball"
	default_ammo = /datum/ammo/bullet/pepperball
	max_rounds = 100
	w_class = WEIGHT_CLASS_NORMAL
	icon_state_mini = "mag_pepperball"

/obj/item/ammo_magazine/rifle/pepperball/pepperball_mini
	name = "small pepperball canister (SAN balls)"
	desc = "A small canister for use with the miniature pepperball gun."
	icon_state = "pepperball_mini"
	default_ammo = /datum/ammo/bullet/pepperball/pepperball_mini
	max_rounds = 20
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_magazine/minigun_powerpack
	name = "\improper MG-100 Vindicator powerpack"
	desc = "A heavy reinforced backpack with support equipment, power cells, and spare rounds for the MG-100 Minigun System.\nClick the icon in the top left to reload your M56."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "powerpack"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BACK
	flags_magazine = MAGAZINE_WORN
	w_class = WEIGHT_CLASS_HUGE
	default_ammo = /datum/ammo/bullet/minigun
	current_rounds = 500
	max_rounds = 500
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_PRISON_VARIANT)

/obj/item/ammo_magazine/minigun_powerpack/snow
	icon_state = "s_powerpack"
	flags_item_map_variant = null

/obj/item/ammo_magazine/minigun_powerpack/fancy
	icon_state = "powerpackw"
	flags_item_map_variant = null

/obj/item/ammo_magazine/minigun_powerpack/merc
	icon_state = "powerpackp"
	flags_item_map_variant = null

/obj/item/ammo_magazine/minigun_powerpack/smartgun
	name = "\improper SG-85 powerpack"
	desc = "A reinforced backpack heavy with the IFF altered ammunition, onboard micro generator, and extensive cooling system which enables the SG-85 gatling gun to operate. \nUse the SG-85 on the backpack itself to connect them."
	icon_state = "powerpacksg"
	flags_magazine = MAGAZINE_WORN|MAGAZINE_REFILLABLE
	default_ammo = /datum/ammo/bullet/smart_minigun
	current_rounds = 1000
	max_rounds = 1000
	caliber = CALIBER_10x26_CASELESS
	flags_item_map_variant = null


// ICC coilgun

/obj/item/ammo_magazine/rifle/icc_coilgun
	name = "coilgun canister"
	desc = "A canister holding tungsten projectiles for a coilgun. Will probably penetrate through just about everything."
	caliber = CALIBER_RAILGUN
	icon_state = "coilgun"
	default_ammo = /datum/ammo/bullet/coilgun
	max_rounds = 5
	reload_delay = 10
	icon_state_mini = "mag_dmr"

