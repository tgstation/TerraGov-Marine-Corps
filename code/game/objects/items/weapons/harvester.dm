//All the harvester weapons go in here

#define VALI_CODEX "<b>Reagent info:</b><BR>\
	All chems will do 60% armor-piercing damage, and also:<BR>\
	Bicaridine - Heals brute and stamina. Channel the heal for a larger heal, works better with medical skill.<BR>\
	Kelotane - Set your target aflame and sunder their armor<BR>\
	Tramadol - Slow your target for 1 second<BR>\
	Tricordrazine - Shatter your targets armor for 3 seconds<BR>\
	<BR>\
	<b>Tips:</b><BR>\
	> Needs to be connected to the Vali system to collect green blood. You can connect it though the Vali system's configurations menu.<BR>\
	> Filled by liquid reagent containers or pills. Emptied by using an empty liquid reagent container.<BR>\
	> Press your unique action key (SPACE by default) to load a single-use of the reagent effect after the blade has been filled up."


//Vali Sword
/obj/item/weapon/claymore/harvester
	name = "\improper HP-S Harvester blade"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' blade. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "energy_sword"
	item_state = "energy_katana"
	force = 60
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY

	var/codex_info = VALI_CODEX

/obj/item/weapon/claymore/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)

/obj/item/weapon/claymore/harvester/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/claymore/harvester/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/claymore/harvester/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

//Vali Knife
/obj/item/weapon/combat_knife/harvester
	name = "\improper HP-S Harvester knife"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' knife. An advanced version of the HP-S Harvester blade, shrunken down to the size of the standard issue boot knife. It trades the harvester blades size and power for a smaller form, with the side effect of a miniscule chemical storage, yet it still keeps its ability to apply debilitating effects to its targets. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "vali_knife_icon"
	item_state = "vali_knife"
	force = 25
	throwforce = 15
	var/codex_info = VALI_CODEX

/obj/item/weapon/combat_knife/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester, 5)

/obj/item/weapon/combat_knife/harvester/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/combat_knife/harvester/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/combat_knife/harvester/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

//Vali Spear
/obj/item/weapon/twohanded/spear/tactical/harvester
	name = "\improper HP-S Harvester spear"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' spear. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "vali_spear"
	item_state = "vali_spear"
	force = 32
	force_wielded = 60
	throwforce = 60
	flags_item = TWOHANDED
	var/codex_info = VALI_CODEX

/obj/item/weapon/twohanded/spear/tactical/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)

//Vali Claymore (That thing was too big to be called a sword. Too big, too thick, too heavy, and too rough, it was more like a large hunk of iron.)
/obj/item/weapon/twohanded/glaive/harvester
	name = "\improper HP-S Harvester claymore"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' blade. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system. This specific version is enlarged to fit the design of an old world claymore. Simply squeeze the hilt to activate."
	icon_state = "vali_claymore"
	item_state = "vali_claymore"
	force = 28
	force_wielded = 90
	throwforce = 65
	throw_speed = 3
	edge = 1
	attack_speed = 24
	sharp = IS_SHARP_ITEM_BIG
	w_class = WEIGHT_CLASS_BULKY
	flags_item = TWOHANDED
	resistance_flags = NONE
	var/codex_info = VALI_CODEX

/obj/item/weapon/twohanded/glaive/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester, 60, TRUE)

/obj/item/weapon/twohanded/glaive/harvester/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/glaive/harvester/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/twohanded/glaive/harvester/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

/obj/item/weapon/twohanded/glaive/harvester/update_overlays()
	. = ..()
	mutable_appearance()

#undef VALI_CODEX
