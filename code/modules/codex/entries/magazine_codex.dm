/obj/item/ammo_magazine/get_mechanics_info()
	. = ..()
	var/list/traits = list()

	traits += "<U>Basic statistics for this magazine is as follows</U>:<br>"

	traits += "<br>Caliber: [caliber]"

	traits += "It can normally hold [max_rounds] rounds."

	if(reload_delay)
		traits += "it has a [reload_delay] second reload delay."

	if(fill_delay)
		traits += "it has a [fill_delay] second fill delay."

	if(scatter_mod)
		traits += "it has a [scatter_mod] wielded scatter modifier."

	if(scatter_unwielded_mod)
		traits += "it has a [scatter_unwielded_mod] unwielded scatter modifier."

	if(aim_speed_mod)
		traits += "it has a [aim_speed_mod] wielded movement speed modifier."

	if(wield_delay_mod)
		traits += "it has a [wield_delay_mod] second wield delay modifier."

	if(flags_magazine & MAGAZINE_WORN)
		traits += "This magazine is worn instead of inserted into a gun."

	traits += "<br>"

	traits += "<U>Basic statistics for ammunition in this magazine are as follows</U>:<br>"
	if(default_ammo.damage)
		traits += "Damage: [default_ammo.damage]<br>"

	if(default_ammo.damage_type)
		traits += "Damage type: [default_ammo.damage_type]<br>"

	if(default_ammo.penetration)
		traits += "Armor penetration: [default_ammo.penetration]<br>"

	if(default_ammo.armor_type)
		traits += "Armor type: [default_ammo.armor_type]<br>"

	if(default_ammo.sundering)
		traits += "Sundering amount: [default_ammo.sundering]"

	if(default_ammo.damage_falloff)
		traits += "Damage falloff: [default_ammo.damage_falloff] per tile<br>"

	if(default_ammo.accurate_range_min)
		traits += "Effective range: [default_ammo.accurate_range_min] to [default_ammo.accurate_range]<br>"
	else if(default_ammo.accurate_range)
		traits += "Effective range: [default_ammo.accurate_range]<br>"

	if(default_ammo.max_range)
		traits += "Maximum range: [default_ammo.max_range]<br>"

	if(default_ammo.flags_ammo_behavior & AMMO_INCENDIARY)
		traits += "Secondary effect: Set target on fire<br>"

	if(default_ammo.flags_ammo_behavior & AMMO_EXPLOSIVE)
		traits += "Secondary effect: Explosive<br>"

	if(default_ammo.flags_ammo_behavior & AMMO_SPECIAL_PROCESS)
		traits += "Secondary effect: Hits nearby targets in-flight<br>"

	if(default_ammo.flags_ammo_behavior & AMMO_LEAVE_TURF)
		traits += "Secondary effect: Affects tiles travelled through<br>"

	if(default_ammo.accuracy)
		traits += "Accuracy: [default_ammo.accuracy > 0 ? "+[default_ammo.accuracy]" : "[default_ammo.accuracy]"]%<br>"

	if(default_ammo.scatter)
		traits += "Burst mode scatter chance: [default_ammo.scatter > 0 ? "+[default_ammo.scatter]" : "[default_ammo.scatter]"]%<br>"

	if(default_ammo.bonus_projectiles_amount)
		traits += "Fires [default_ammo.bonus_projectiles_amount] additional projectiles<br>"
		traits += "Additional projectiles have a scatter of [default_ammo.bonus_projectiles_scatter]<br>"

	traits += "<br>"
	traits += "<U>Special behavior</U>:"
	traits += get_additional_codex_info()

	. += jointext(traits, "<br>")

///Any additional mechanic info specific to this magazine or the ammo in it
/obj/item/ammo_magazine/proc/get_additional_codex_info()
	return

/obj/item/ammo_magazine/shotgun/get_additional_codex_info()
	. += "<br>Slugs applies stun, knockback, slowdown and stagger against mobs on hit, up to 5 tiles away.<br>"

/obj/item/ammo_magazine/shotgun/buckshot/get_additional_codex_info()
	. += "<br>Buckshot applies stun, knockback, slowdown and stagger against mobs on hit, up to 3 tiles away.<br>"

/obj/item/ammo_magazine/shotgun/incendiary/get_additional_codex_info()
	. += "<br>Incendiary slugs applies knockback and slowdown against mobs on hit, up to 5 tiles away.<br>"

/obj/item/ammo_magazine/rifle/tx54/get_additional_codex_info()
	. += "<br>20mm airburst grenades release a number of piercing sub munitions when they detonate. Submunitions inflict damage, sunder, stagger and slow.<br>"

/obj/item/ammo_magazine/rifle/tx54/he/get_additional_codex_info()
	. += "<br>20mm high explosive grenades instantly detonate on impact on the turf targeted, creating a small explosion.<br>"

/obj/item/ammo_magazine/rifle/tx54/incendiary/get_additional_codex_info()
	. += "<br>20mm incendiary grenades release a number of piercing sub munitions when they detonate. Submunitions burn any mob they hit, and leave fire in turfs crossed.<br>"

/obj/item/ammo_magazine/rifle/tx54/smoke/get_additional_codex_info()
	. += "<br>20mm tactical smoke grenades release a number of piercing sub munitions when they detonate. Submunitions release smoke on turfs crossed, creating a smokescreen.<br>"

/obj/item/ammo_magazine/rifle/tx54/smoke/dense/get_additional_codex_info()
	. += "<br>20mm dense smoke grenades release a number of piercing sub munitions when they detonate. Submunitions release smoke on turfs crossed, creating a dense smokescreen.<br>"

/obj/item/ammo_magazine/rifle/tx54/smoke/tangle/get_additional_codex_info()
	. += "<br>20mm tanglefoor smoke grenades release a number of piercing sub munitions when they detonate. Submunitions release smoke on turfs crossed, creating a smokescreen of plasma draining Tanglefoot gas.<br>"

/obj/item/ammo_magazine/rifle/tx54/razor/get_additional_codex_info()
	. += "<br>20mm razorburn grenades release a number of piercing sub munitions when they detonate. Submunitions release razorburn foam on turfs crossed, creating areas of razorwire after a short delay.<br>"

/obj/item/ammo_magazine/smg/som/rad/get_additional_codex_info()
	. += "<br>Contains radioactive ammunition. Has a chance to irradiate mobs on hit, scaling with bio armour.<br>"

/obj/item/ammo_magazine/rocket/som/rad/get_additional_codex_info()
	. += "<br>Releases a large radioactive as well as high explosive blast on impact. Irradiates all mobs caught in the radius. Effects scale with distance to the blast.<br>"
