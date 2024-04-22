/obj/item/mecha_ammo
	name = "generic ammo box"
	desc = ""
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/mecha/mecha_ammo.dmi'
	icon_state = "empty"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	var/rounds = 0
	var/round_term = "round"
	var/direct_load //For weapons where we re-load the weapon itself rather than adding to the ammo storage.
	var/load_audio = "sound/weapons/gun_magazine_insert_empty_1.ogg"
	var/ammo_type

/obj/item/mecha_ammo/proc/update_name()
	if(!rounds)
		name = "empty ammo box"
		desc = ""
		icon_state = "empty"

/obj/item/mecha_ammo/attack_self(mob/user)
	..()
	if(rounds)
		to_chat(user, "<span class='warning'>I cannot flatten the ammo box until it's empty!</span>")
		return

	to_chat(user, "<span class='notice'>I fold [src] flat.</span>")
	var/I = new /obj/item/stack/sheet/metal(user.loc)
	qdel(src)
	user.put_in_hands(I)

/obj/item/mecha_ammo/examine(mob/user)
	. = ..()
	if(rounds)
		. += "There [rounds > 1?"are":"is"] [rounds] [round_term][rounds > 1?"s":""] left."

/obj/item/mecha_ammo/incendiary
	name = "incendiary ammo"
	desc = ""
	icon_state = "incendiary"
	rounds = 24
	ammo_type = "incendiary"

/obj/item/mecha_ammo/scattershot
	name = "scattershot ammo"
	desc = ""
	icon_state = "scattershot"
	rounds = 40
	ammo_type = "scattershot"

/obj/item/mecha_ammo/lmg
	name = "machine gun ammo"
	desc = ""
	icon_state = "lmg"
	rounds = 300
	ammo_type = "lmg"

/obj/item/mecha_ammo/missiles_br
	name = "breaching missiles"
	desc = ""
	icon_state = "missile_br"
	rounds = 6
	round_term = "missile"
	direct_load = TRUE
	load_audio = "sound/weapons/bulletinsert.ogg"
	ammo_type = "missiles_br"

/obj/item/mecha_ammo/missiles_he
	name = "anti-armor missiles"
	desc = ""
	icon_state = "missile_he"
	rounds = 8
	round_term = "missile"
	direct_load = TRUE
	load_audio = "sound/weapons/bulletinsert.ogg"
	ammo_type = "missiles_he"


/obj/item/mecha_ammo/flashbang
	name = "launchable flashbangs"
	desc = ""
	icon_state = "flashbang"
	rounds = 6
	round_term = "grenade"
	ammo_type = "flashbang"

/obj/item/mecha_ammo/clusterbang
	name = "launchable flashbang clusters"
	desc = ""
	icon_state = "clusterbang"
	rounds = 3
	round_term = "cluster"
	direct_load = TRUE
	ammo_type = "clusterbang"
