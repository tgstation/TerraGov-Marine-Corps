//===========================//HEADGEAR\\================================\\
//=======================================================================\\

/*Hats should go in here whether they have armor or not. If they don't have
hugger protection, they will usually belong in here. Everything else can go
into helmets.dm*/

//=======================================================================\\
//=======================================================================\\

//==========================//SOFT CAPS\\================================\\
//=======================================================================\\

/obj/item/clothing/head/cmbandana
	name = "USCM Bandana (Green)"
	desc = "Typically worn by heavy-weapon operators, mercenaries and scouts, the bandana serves as a lightweight and comfortable hat. Comes in two stylish colors."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "band"
	item_state = "band"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "band"
	flags = FPRINT|TABLEPASS|BLOCKHEADHAIR

/obj/item/clothing/head/cmbandana/tan
	name = "USCM Bandana (Tan)"
	icon_state = "band2"
	item_state = "band2"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "band2"
	flags = FPRINT|TABLEPASS|BLOCKHEADHAIR

/obj/item/clothing/head/cmberet
	name = "USCM Beret"
	desc = "A hat typically worn by the field-officers of the USCM. Occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "beret"
	item_state = "beret"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "beret"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/cmberet/tan
	icon_state = "berettan"
	item_state = "berettan"
	item_color = "berettan"

/obj/item/clothing/head/cmberet/red
	icon_state = "beretred"
	item_state = "beretred"
	item_color = "beretred"

/obj/item/clothing/head/headband
	name = "USCM Headband"
	desc = "A rag typically worn by the less-orthodox weapons operators in the USCM. While it offers no protection, it is certainly comfortable to wear compared to the standard helmet. Comes in two stylish colors."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "headband"
	item_state = "headband"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "headband"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/headband/red
	icon_state = "headbandred"
	item_state = "headbandred"
	item_color = "headbandred"

/obj/item/clothing/head/headset
	name = "USCM Headset"
	desc = "A headset typically found in use by radio-operators and officers. This one appears to be malfunctioning."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "headset"
	item_state = "headset"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "headset"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/cmcap
	name = "USCM Cap"
	desc = "A casual cap occasionally  worn by Squad-leaders and Combat-Engineers. While it has limited combat functionality, some prefer to wear it over the standard issue helmet."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "cap"
	item_state = "cap"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "cap"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/cmcap/ro
	name = "USCM Officer Cap"
	desc = "A hat usually worn by officers in the USCM. While it has limited combat functionality, some prefer to wear it over the standard issue helmet."
	icon_state = "rocap"
	item_state = "rocap"
	item_color = "rocap"

/obj/item/clothing/head/cmcap/req
	name = "USCM Requisition Cap"
	desc = "A hat usually worn by officers in the USCM. While it has limited combat functionality, some prefer to wear it over the standard issue helmet."
	icon_state = "cargocap"
	item_state = "cargocap"
	item_color = "cargocap"

/obj/item/clothing/head/soft/ro_cap
	name = "Requisition officer cap"
	desc = "It's a fancy hat for a not-so-fancy military supply clerk."
	icon_state = "cargocap"
	item_state = "cargocap"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "cargocap"

/obj/item/clothing/head/soft/marine
	name = "marine sergeant cap"
	desc = "It's a soft cap made from advanced ballistic-resistant fibres. Fails to prevent lumps in the head."
	armor = list(melee = 35, bullet = 35, laser = 35,energy = 15, bomb = 10, bio = 0, rad = 0)
	icon_state = "greysoft"
	item_color = "grey"

/obj/item/clothing/head/soft/marine/alpha
	name = "alpha squad sergeant cap"
	icon_state = "redsoft"
	item_color = "red"

/obj/item/clothing/head/soft/marine/beta
	name = "beta squad sergeant cap"
	icon_state = "yellowsoft"
	item_color = "yellow"

/obj/item/clothing/head/soft/marine/charlie
	name = "charlie squad sergeant cap"
	icon_state = "purplesoft"
	item_color = "purple"

/obj/item/clothing/head/soft/marine/delta
	name = "delta squad sergeant cap"
	icon_state = "bluesoft"
	item_color = "blue"

/obj/item/clothing/head/soft/marine/mp
	name = "marine police sergeant cap"
	icon_state = "greensoft"
	item_color = "green"

//============================//BERETS\\=================================\\
//=======================================================================\\
//Berets have armor, so they have their own category. PMC caps are helmets, so they're in helmets.dm.
/obj/item/clothing/head/beret/marine
	name = "marine officer beret"
	desc = "A beret with the ensign insignia emblazoned on it. It radiates respect and authority."
	armor = list(melee = 40, bullet = 40, laser = 40,energy = 20, bomb = 10, bio = 0, rad = 0)
	icon_state = "beret_badge"

/obj/item/clothing/head/beret/marine/commander
	name = "marine commander beret"
	desc = "A beret with the commander insignia emblazoned on it. Wearer may suffer the heavy weight of responsibility upon his head and shoulders."
	icon_state = "centcomcaptain"

/obj/item/clothing/head/beret/marine/chiefofficer
	name = "chief officer beret"
	desc = "A beret with the lieutenant-commander insignia emblazoned on it. It emits a dark aura and may corrupt the soul."
	icon_state = "hosberet"

/obj/item/clothing/head/beret/marine/techofficer
	name = "technical officer beret"
	desc = "A beret with the lieutenant insignia emblazoned on it. There's something inexplicably efficient about it..."
	icon_state = "e_beret_badge"

/obj/item/clothing/head/beret/marine/logisticsofficer
	name = "logistics officer beret"
	desc = "A beret with the lieutenant insignia emblazoned on it. It inspires a feeling of respect."
	icon_state = "hosberet"


