/*******************************************************************************
Imports
*******************************************************************************/
/datum/supply_packs/imports
	group = "Imports"
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/imports/m41a
	name = "PR-11 pulse rifle"
	contains = list(/obj/item/weapon/gun/rifle/m41a)
	cost = 50

/datum/supply_packs/imports/m41a/ammo
	name = "PR-11 pulse rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/m41a)
	cost = 3

/datum/supply_packs/imports/m412
	name = "PR-412 pulse rifle"
	contains = list(/obj/item/weapon/gun/rifle/m412)
	cost = 50

/datum/supply_packs/imports/m41a2/ammo
	name = "PR-412 pulse rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle)
	cost = 3

/datum/supply_packs/imports/m412l1
	name = "PR-412L1 heavy pulse rifle"
	contains = list(/obj/item/weapon/gun/rifle/m412l1_hpr)
	cost = 300

/datum/supply_packs/imports/m412l1/ammo
	name = "PR-412L1 HPR heavy pulse rifle Ammo"
	contains = list(/obj/item/ammo_magazine/m412l1_hpr)
	cost = 25

/datum/supply_packs/imports/type71	//Moff gun
	name = "Type 71 pulse rifle"
	contains = list(/obj/item/weapon/gun/rifle/type71/seasonal)
	cost = 50

/datum/supply_packs/imports/type71/ammo
	name = "Type 71 pulse rifle Ammo"
	contains = list(/obj/item/ammo_magazine/rifle/type71)
	cost = 3

/datum/supply_packs/imports/mp7
	name = "SMG-27 SMG"
	contains = list(/obj/item/weapon/gun/smg/mp7)
	cost = 50

/datum/supply_packs/imports/mp7/ammo
	name = "SMG-27 SMG ammo"
	contains = list(/obj/item/ammo_magazine/smg/mp7)
	cost = 3

/datum/supply_packs/imports/m25
	name = "SMG-25 SMG"
	contains = list(/obj/item/weapon/gun/smg/m25)
	cost = 50

/datum/supply_packs/imports/m25/ammo
	name = "SMG-25 SMG ammo"
	contains = list(/obj/item/ammo_magazine/smg/m25)
	cost = 3

/datum/supply_packs/imports/alf
	name = "ALF-51B Kauser machinecarbine"
	contains = list(/obj/item/weapon/gun/rifle/alf_machinecarbine)
	cost = 50

/datum/supply_packs/imports/alf/ammo
	name = "ALF-51B Kauser machinecarbine ammo"
	contains = list(/obj/item/ammo_magazine/rifle/alf_machinecarbine)
	cost = 3

/datum/supply_packs/imports/skorpion
	name = "CZ-81 Skorpion SMG"
	contains = list(/obj/item/weapon/gun/smg/skorpion)
	cost = 30

/datum/supply_packs/imports/skorpion/ammo
	name = "CZ-81 Skorpion SMG ammo"
	contains = list(/obj/item/ammo_magazine/smg/skorpion)
	cost = 3

/datum/supply_packs/imports/uzi
	name = "SMG-2 Uzi SMG"
	contains = list(/obj/item/weapon/gun/smg/uzi)
	cost = 50

/datum/supply_packs/imports/uzi/ammo
	name = "SMG-2 Uzi SMG ammo"
	contains = list(/obj/item/ammo_magazine/smg/uzi)
	cost = 3

/datum/supply_packs/imports/ppsh
	name = "PPSh-17b SMG"
	contains = list(/obj/item/weapon/gun/smg/ppsh)
	cost = 50

/datum/supply_packs/imports/ppsh/ammo
	name = "PPSh-17b SMG ammo drum"
	contains = list(/obj/item/ammo_magazine/smg/ppsh/extended)
	cost = 3

/datum/supply_packs/imports/leveraction
	name = "Lever action rifle"
	contains = list(/obj/item/weapon/gun/shotgun/pump/lever)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/mbx900
	name = "MBX-900 lever action shotgun"
	contains = list(/obj/item/weapon/gun/shotgun/pump/lever/mbx900)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/mbx900/buckshot
	name = "MBX-900 .410 buckshot shells"
	contains = list(/obj/item/ammo_magazine/shotgun/mbx900/buckshot)
	cost = 10
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/dragunov
	name = "SVD Dragunov sniper"
	contains = list(/obj/item/weapon/gun/rifle/sniper/svd)
	cost = 300
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/dragunov/ammo
	name = "SVD Dragunov sniper ammo"
	contains = list(/obj/item/ammo_magazine/sniper/svd)
	cost = 10
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/mpi_km
	name = "MPi-KM assault rifle"
	contains = list(/obj/item/weapon/gun/rifle/mpi_km)
	cost = 50

/datum/supply_packs/imports/mpi_km/ammo
	name = "MPi-KM assault rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/mpi_km/plum)
	cost = 3

/datum/supply_packs/imports/mpi_km/ammo_packet
	name = "7.62x39mm ammo box"
	contains = list(/obj/item/ammo_magazine/packet/pwarsaw)
	cost = 15

/datum/supply_packs/imports/mkh
	name = "MKH-98 storm rifle"
	contains = list(/obj/item/weapon/gun/rifle/mkh)
	cost = 50

/datum/supply_packs/imports/mkh/ammo
	name = "MKH-98 assault rifle ammo"
	contains = list(/obj/item/ammo_magazine/rifle/mkh)
	cost = 3

/datum/supply_packs/imports/garand
	name = "CAU C1 rifle"
	contains = list(/obj/item/weapon/gun/rifle/garand)
	cost = 50

/datum/supply_packs/imports/garand/ammo
	name = "CAU C1 ammo"
	contains = list(/obj/item/ammo_magazine/rifle/garand)
	cost = 3

/datum/supply_packs/imports/judge
	name = "Judge revolver"
	contains = list(/obj/item/weapon/gun/revolver/judge)
	cost = 35

/datum/supply_packs/imports/judge/ammo
	name = "Judge speed loader"
	contains = list(/obj/item/ammo_magazine/revolver/judge)
	cost = 3

/datum/supply_packs/imports/judge/buck_ammo
	name = "Judge .45L buckshot ammo"
	contains = list(/obj/item/ammo_magazine/revolver/judge/buckshot)
	cost = 3

/datum/supply_packs/imports/m16	//Vietnam time
	name = "FN M16A4 assault rifle"
	contains = list(/obj/item/weapon/gun/rifle/m16)
	cost = 50

/datum/supply_packs/imports/m16/ammo
	name = "FN M16A4 Assault Rifle Ammo"
	contains = list(/obj/item/ammo_magazine/rifle/m16)
	cost = 3

/datum/supply_packs/imports/famas //bread joke here
	name = "FAMAS assault rifle"
	contains = list(/obj/item/weapon/gun/rifle/famas)
	cost = 120

/datum/supply_packs/imports/famas/ammo
	name = "FAMAS assault rifle Ammo"
	contains = list(/obj/item/ammo_magazine/rifle/famas)
	cost = 5

/datum/supply_packs/imports/m16/ammo_packet
	name = "5.56x45mm Ammo Box"
	contains = list(/obj/item/ammo_magazine/packet/pnato)
	cost = 15

/datum/supply_packs/imports/aug	//Vietnam time
	name = "L&S EM-88 assault carbine"
	contains = list(/obj/item/weapon/gun/rifle/icc_assaultcarbine/export)
	cost = 120

/datum/supply_packs/imports/aug/ammo
	name = "L&S EM-88 assault carbine ammo"
	contains = list(/obj/item/ammo_magazine/rifle/icc_assaultcarbine/export)
	cost = 5

/datum/supply_packs/imports/rev357
	name = "'Rebota' revolver"
	contains = list(/obj/item/weapon/gun/revolver/small)
	cost = 35

/datum/supply_packs/imports/rev357/ammo
	name = "Rebota' revolver speed loader"
	contains = list(/obj/item/ammo_magazine/revolver/small)
	cost = 3

/datum/supply_packs/imports/rev44
	name = "R-44 SAA revolver"
	contains = list(/obj/item/weapon/gun/revolver/single_action/m44)
	cost = 35

/datum/supply_packs/imports/rev357/ammo
	name = "R-44 SAA revolver speed loader"
	contains = list(/obj/item/ammo_magazine/revolver/single_action/m44)
	cost = 3

/datum/supply_packs/imports/g22
	name = "P-22 handgun"
	contains = list(/obj/item/weapon/gun/pistol/g22)
	cost = 35

/datum/supply_packs/imports/beretta92fs/ammo
	name = "P-22 handgun ammo"
	contains = list(/obj/item/ammo_magazine/pistol/g22)
	cost = 3

/datum/supply_packs/imports/deagle
	name = "Desert Eagle handgun"
	contains = list(/obj/item/weapon/gun/pistol/heavy)
	cost = 35

/datum/supply_packs/imports/deagle/ammo
	name = "Desert Eagle handgun ammo"
	contains = list(/obj/item/ammo_magazine/pistol/heavy)
	cost = 3

/datum/supply_packs/imports/vp78
	name = "VP78 handgun"
	contains = list(/obj/item/weapon/gun/pistol/vp78)
	cost = 35

/datum/supply_packs/imports/vp78/ammo
	name = "VP78 handgun ammo"
	contains = list(/obj/item/ammo_magazine/pistol/vp78)
	cost = 3

/datum/supply_packs/imports/highpower
	name = "Highpower automag"
	contains = list(/obj/item/weapon/gun/pistol/highpower)
	cost = 35

/datum/supply_packs/imports/highpower/ammo
	name = "Highpower automag ammo"
	contains = list(/obj/item/ammo_magazine/pistol/highpower)
	cost = 3

/datum/supply_packs/imports/m1911
	name = "P-1911 service pistol"
	contains = list(/obj/item/weapon/gun/pistol/m1911)
	cost = 35

/datum/supply_packs/imports/m1911/ammo
	name = "P-1911 service pistol ammo"
	contains = list(/obj/item/ammo_magazine/pistol/m1911)
	cost = 3

/datum/supply_packs/imports/strawhat
	name = "Straw hat"
	contains = list(/obj/item/clothing/head/strawhat)
	cost = 10

/datum/supply_packs/imports/loot_pack
	name = "TGMC loot pack"
	notes = "Contains a random, but curated set of items, these packs are valued around 150 to 200 points. Some items can only be acquired from these. Spend responsibly."
	contains = list(/obj/item/loot_box/tgmclootbox)
	cost = 1000

/datum/supply_packs/imports/loot_box
	name = "Loot box"
	contains = list(/obj/item/loot_box/marine)
	cost = 500
