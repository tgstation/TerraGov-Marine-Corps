/obj/item/mecha_ammo
	name = "generic ammo box"
	desc = "A box of ammo for an unknown weapon."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/mecha/mecha_ammo.dmi'
	icon_state = "empty"
	///how many rounds of ammo this box has left
	var/rounds = 0
	/// For weapons where we re-load the weapon itself rather than adding to the ammo storage.
	var/direct_load
	/// sound to play when we reload
	var/load_audio = 'sound/mecha/mag_bullet_insert.ogg'
	///ammo type define that tells the user the ammo type, and lets the ammo decide what weapon types it can refill
	var/ammo_type
	/// whether to qdel this mecha_ammo when it becomes empty
	var/qdel_on_empty = FALSE

/obj/item/mecha_ammo/update_icon_state()
	icon_state = rounds ? initial(icon_state) : "[initial(icon_state)]_e"
	return ..()

/obj/item/mecha_ammo/attack_self(mob/user)
	..()
	if(rounds)
		to_chat(user, span_warning("You cannot flatten the ammo box until it's empty!"))
		return

	to_chat(user, span_notice("You fold [src] flat."))
	var/trash = new /obj/item/stack/sheet/metal(user.loc)
	qdel(src)
	user.put_in_hands(trash)

/obj/item/mecha_ammo/examine(mob/user)
	. = ..()
	if(rounds)
		. += "There [rounds > 1?"are":"is"] [rounds] [ammo_type][rounds > 1?"s":""] left."
	else
		. += span_notice("Use in-hand to fold it into a sheet of metal.")

/obj/item/mecha_ammo/incendiary
	name = "incendiary ammo box"
	desc = "A box of incendiary ammunition for use with exosuit weapons."
	icon_state = "incendiary"
	rounds = 24
	ammo_type = MECHA_AMMO_INCENDIARY

/obj/item/mecha_ammo/scattershot
	name = "scattershot ammo box"
	desc = "A box of scaled-up buckshot, for use in exosuit shotguns."
	icon_state = "scattershot"
	rounds = 40
	ammo_type = MECHA_AMMO_BUCKSHOT

/obj/item/mecha_ammo/lmg
	name = "machine gun ammo box"
	desc = "A box of linked ammunition, designed for the Ultra AC 2 exosuit weapon."
	icon_state = "lmg"
	rounds = 300
	ammo_type = MECHA_AMMO_LMG

/obj/item/mecha_ammo/missiles_br
	name = "breaching missiles"
	desc = "A box of large missiles, ready for loading into a BRM-6 exosuit missile rack."
	icon_state = "missile_br"
	rounds = 6
	direct_load = TRUE
	load_audio = 'sound/mecha/mag_bullet_insert.ogg'
	ammo_type = MECHA_AMMO_MISSILE_HE

/obj/item/mecha_ammo/missiles_he
	name = "anti-armor missiles"
	desc = "A box of large missiles, ready for loading into an SRM-8 exosuit missile rack."
	icon_state = "missile_he"
	rounds = 8
	direct_load = TRUE
	load_audio = 'sound/mecha/mag_bullet_insert.ogg'
	ammo_type = MECHA_AMMO_MISSILE_AP


/obj/item/mecha_ammo/flashbang
	name = "launchable flashbangs"
	desc = "A box of smooth flashbangs, for use with a large exosuit launcher. Cannot be primed by hand."
	icon_state = "flashbang"
	rounds = 6
	ammo_type = MECHA_AMMO_FLASHBANG

/obj/item/mecha_ammo/clusterbang
	name = "launchable flashbang clusters"
	desc = "A box of clustered flashbangs, for use with a specialized exosuit cluster launcher. Cannot be primed by hand."
	icon_state = "clusterbang"
	rounds = 3
	direct_load = TRUE
	ammo_type = MECHA_AMMO_CLUSTERBANG



//greyscale mech stuff
/obj/item/mecha_ammo/vendable
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK

/obj/item/mecha_ammo/vendable/lmg
	name = "box of LMG bullets"
	desc = "A box of rather large LMG bullets."
	icon_state = "lmg_ammo"
	rounds = 300
	ammo_type = MECHA_AMMO_GREY_LMG

/obj/item/mecha_ammo/vendable/rifle
	name = "box of rifle bullets"
	desc = "A box of large rocket-assisted rifle bullets. it has \"DO NOT USE AS FIRECRACKERS\" written on the side."
	icon_state = "assaultrifle_ammo"
	rounds = 250
	ammo_type = MECHA_AMMO_RIFLE

/obj/item/mecha_ammo/vendable/burstrifle
	name = "box of burstrifle bullets"
	desc = "A box of large rocket-assisted burstrifle bullets. it has \"DO NOT USE AS FIRECRACKERS\" written on the side."
	icon_state = "burstrifle_ammo"
	rounds = 250
	ammo_type = MECHA_AMMO_BURSTRIFLE

/obj/item/mecha_ammo/vendable/shotgun
	name = "box of shotgun shells"
	desc = "A box of large shotgun shells. Sadly they only fit into mech-sized weapons."
	icon_state = "shotgun_ammo"
	rounds = 20
	ammo_type = MECHA_AMMO_SHOTGUN

/obj/item/mecha_ammo/vendable/lightcannon
	name = "box of light cannon bullets"
	desc = "A box of light cannon shells. For being light the box is rather heavy."
	icon_state = "lightcannon_ammo"
	rounds = 100
	ammo_type = MECHA_AMMO_LIGHTCANNON

/obj/item/mecha_ammo/vendable/heavycannon
	name = "heavy cannon shell"
	desc = "A massive tank shell for loading into mech cannons."
	icon_state = "heavycannon_ammo"
	rounds = 5
	ammo_type = MECHA_AMMO_HEAVYCANNON
	direct_load = TRUE
	qdel_on_empty = TRUE

/obj/item/mecha_ammo/vendable/smg
	name = "box of SMG bullets"
	desc = "A box of normal SMG bullets, but bigger!"
	icon_state = "smg_ammo"
	rounds = 320
	ammo_type = MECHA_AMMO_SMG

/obj/item/mecha_ammo/vendable/burstpistol
	name = "box of burstpistol bullets"
	desc = "A box of burstpistol bullets."
	icon_state = "burstpistol_ammo"
	rounds = 200
	ammo_type = MECHA_AMMO_BURSTPISTOL

/obj/item/mecha_ammo/vendable/pistol
	name = "box of pistol bullets"
	desc = "Bigger version of the small pistol bullets most marines use."
	icon_state = "pistol_ammo"
	rounds = 200
	ammo_type = MECHA_AMMO_PISTOL

/obj/item/mecha_ammo/vendable/rpg
	name = "high explosive missile"
	desc = "A TGMC mech missile. You probably shouldnt hit the pointy end with anything."
	icon_state = "rpg_ammo"
	rounds = 1
	ammo_type = MECHA_AMMO_RPG
	direct_load = TRUE
	qdel_on_empty = TRUE

/obj/item/mecha_ammo/vendable/minigun
	name = "box of vulcan cannon bullets"
	desc = "Unfortunately for you, every bullet that comes out of the vulcan cannon must also be loaded into it."
	icon_state = "minigun_ammo"
	rounds = 200
	ammo_type = MECHA_AMMO_MINIGUN

/obj/item/mecha_ammo/vendable/sniper
	name = "box of sniper bullets"
	desc = "A box of anti-tank bullets for shooting at small armored vehicles, and small armored creatures."
	icon_state = "sniper_ammo"
	rounds = 30
	ammo_type = MECHA_AMMO_SNIPER

/obj/item/mecha_ammo/vendable/grenade
	name = "grenade rack"
	desc = "A rack filled with rows of grenades secured with plastic."
	icon_state = "grenadelauncher_ammo"
	rounds = 20
	direct_load = TRUE
	ammo_type = MECHA_AMMO_GRENADE

/obj/item/mecha_ammo/vendable/flamer
	name = "flamer napalm tank"
	desc = "A specialized fuel tank designed for refilling TGMC standard issue mech flamers."
	icon_state = "flamer_ammo"
	rounds = 10
	ammo_type = MECHA_AMMO_FLAMER
