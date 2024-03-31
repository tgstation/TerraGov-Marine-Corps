/obj/item/gun/magic/staff
	slot_flags = ITEM_SLOT_BACK
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	item_flags = NEEDS_PERMIT | NO_MAT_REDEMPTION

/obj/item/gun/magic/staff/change
	name = "staff of change"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/magic/staff/animate
	name = "staff of animation"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"

/obj/item/gun/magic/staff/healing
	name = "staff of healing"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon_state = "staffofhealing"
	item_state = "staffofhealing"

/obj/item/gun/magic/staff/healing/handle_suicide() //Stops people trying to commit suicide to heal themselves
	return

/obj/item/gun/magic/staff/chaos
	name = "staff of chaos"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/chaos
	icon_state = "staffofchaos"
	item_state = "staffofchaos"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1
	var/allowed_projectile_types = list(/obj/projectile/magic/change, /obj/projectile/magic/animate, /obj/projectile/magic/resurrection,
	/obj/projectile/magic/death, /obj/projectile/magic/teleport, /obj/projectile/magic/door, /obj/projectile/magic/aoe/fireball,
	/obj/projectile/magic/spellblade, /obj/projectile/magic/arcane_barrage, /obj/projectile/magic/locker, /obj/projectile/magic/flying,
	/obj/projectile/magic/bounty, /obj/projectile/magic/antimagic, /obj/projectile/magic/fetch, /obj/projectile/magic/sapping,
	/obj/projectile/magic/necropotence, /obj/projectile/magic, /obj/projectile/temp/chill, /obj/projectile/magic/wipe)

/obj/item/gun/magic/staff/chaos/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	chambered.projectile_type = pick(allowed_projectile_types)
	. = ..()

/obj/item/gun/magic/staff/door
	name = "staff of door creation"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1

/obj/item/gun/magic/staff/honk
	name = "staff of the honkmother"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/honk
	icon_state = "honker"
	item_state = "honker"
	max_charges = 4
	recharge_rate = 8

/obj/item/gun/magic/staff/spellblade
	name = "spellblade"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/spellblade
	icon_state = "spellblade"
	item_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/blank.ogg'
	force = 20
	armor_penetration = 75
	block_chance = 50
	sharpness = IS_SHARP
	max_charges = 4

/obj/item/gun/magic/staff/spellblade/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 15, 125, 0, hitsound)

/obj/item/gun/magic/staff/spellblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0
	return ..()

/obj/item/gun/magic/staff/locker
	name = "staff of the locker"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/locker
	icon_state = "locker"
	item_state = "locker"
	max_charges = 6
	recharge_rate = 4

//yes, they don't have sounds. they're admin staves, and their projectiles will play the chaos bolt sound anyway so why bother?

/obj/item/gun/magic/staff/flying
	name = "staff of flying"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/flying
	icon_state = "staffofflight"
	item_state = "staffofflight"

/obj/item/gun/magic/staff/sapping
	name = "staff of sapping"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/sapping
	icon_state = "staffofsapping"
	item_state = "staffofsapping"

/obj/item/gun/magic/staff/necropotence
	name = "staff of necropotence"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/necropotence
	icon_state = "staffofnecropotence"
	item_state = "staffofnecropotence"

/obj/item/gun/magic/staff/wipe
	name = "staff of possession"
	desc = ""
	fire_sound = 'sound/blank.ogg'
	ammo_type = /obj/item/ammo_casing/magic/wipe
	icon_state = "staffofwipe"
	item_state = "staffofwipe"
