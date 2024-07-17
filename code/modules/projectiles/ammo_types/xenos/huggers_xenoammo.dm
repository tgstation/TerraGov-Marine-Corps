/*
//================================================
					Projectile Huggers
					Used by hugger turrets
//================================================
*/

/datum/ammo/xeno/hugger
	name = "hugger ammo"
	ping = ""
	ammo_behavior_flags = AMMO_XENO
	damage = 0
	max_range = 6
	shell_speed = 1
	bullet_color = ""
	icon_state = "facehugger"
	///The type of hugger thrown
	var/obj/item/clothing/mask/facehugger/hugger_type = /obj/item/clothing/mask/facehugger

/datum/ammo/xeno/hugger/on_hit_mob(mob/M, obj/projectile/proj)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(get_turf(M), hivenumber)
	hugger.go_idle()

/datum/ammo/xeno/hugger/on_hit_obj(obj/O, obj/projectile/proj)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(get_turf(O), hivenumber)
	hugger.go_idle()

/datum/ammo/xeno/hugger/on_hit_turf(turf/T, obj/projectile/P)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(T.density ? P.loc : T, hivenumber)
	hugger.go_idle()

/datum/ammo/xeno/hugger/do_at_max_range(turf/T, obj/projectile/P)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(T.density ? P.loc : T, hivenumber)
	hugger.go_idle()

/datum/ammo/xeno/hugger/slash
	hugger_type = /obj/item/clothing/mask/facehugger/combat/slash

/datum/ammo/xeno/hugger/neuro
	hugger_type = /obj/item/clothing/mask/facehugger/combat/chem_injector/neuro

/datum/ammo/xeno/hugger/ozelomelyn
	hugger_type = /obj/item/clothing/mask/facehugger/combat/chem_injector/ozelomelyn

/datum/ammo/xeno/hugger/resin
	hugger_type = /obj/item/clothing/mask/facehugger/combat/resin

/datum/ammo/xeno/hugger/acid
	hugger_type = /obj/item/clothing/mask/facehugger/combat/acid
