/obj/item/attachable/stock //Generic stock parent and related things.
	name = "default stock"
	desc = "Default parent object, not meant for use."
	icon = 'icons/obj/items/guns/attachments/stock.dmi'
	slot = ATTACHMENT_SLOT_STOCK
	attach_features_flags = NONE //most stocks are not removable
	size_mod = 2
	pixel_shift_x = 30
	pixel_shift_y = 14

/obj/item/attachable/stock/mosin
	name = "mosin wooden stock"
	desc = "A non-standard long wooden stock for Slavic firearms."
	icon_state = "mosin"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/ppsh
	name = "PPSh-17b submachinegun wooden stock"
	desc = "A long wooden stock for a PPSh-17b submachinegun"
	icon_state = "ppsh"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t27
	name = "MG-27 Body"
	desc = "A stock for a MG-27 MMG."
	icon_state = "t27"
	pixel_shift_x = 15
	pixel_shift_y = 0

/obj/item/attachable/stock/pal12
	name = "Paladin-12 pump shotgun stock"
	desc = "A standard light stock for the Paladin-12 shotgun."
	icon_state = "pal12"

/obj/item/attachable/stock/mpi_km
	name = "MPi-KM wooden stock"
	desc = "A metallic stock with a wooden paint coating, made to fit the MPi-KM."
	icon_state = "ak47"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/mpi_km/black
	name = "MPi-KM polymer stock"
	desc = "A black polymer stock, made to fit the MPi-KM."
	icon_state = "ak47_black"

/obj/item/attachable/stock/lmg_d
	name = "lMG-D wooden stock"
	desc = "A metallic stock with a wooden paint coating, made to fit lMG-D."
	icon_state = "ak47"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/tx15
	name = "\improper SH-15 stock"
	desc = "The standard stock for the SH-15. Cannot be removed."
	icon_state = "tx15"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/sgstock
	name = "SG-29 stock"
	desc = "A standard machinegun stock."
	icon_state = "sg29"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/strstock
	name = "SG-62 stock"
	desc = "A standard rifle stock."
	icon_state = "sg62"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/lasgun
	name = "\improper M43 Sunfury lasgun stock"
	desc = "The standard stock for the M43 Sunfury lasgun."
	icon_state = "laser"
	pixel_shift_x = 41
	pixel_shift_y = 10

/obj/item/attachable/stock/lasgun/practice
	name = "\improper M43-P Sunfury lasgun stock"
	desc = "The standard stock for the M43-P Sunfury lasgun, seems the stock is made out of plastic."
	icon_state = "laser"
	pixel_shift_x = 41
	pixel_shift_y = 10

/obj/item/attachable/stock/tl127stock
	name = "\improper SR-127 stock"
	desc = "A irremovable SR-127 sniper rifle stock."
	icon_state = "tl127"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/garand
	name = "\improper C1 stock"
	desc = "A irremovable C1 stock."
	icon_state = "garand"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/trenchgun
	name = "\improper L-4043 stock"
	desc = "A irremovable L-4043 stock."
	icon_state = "trench"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/icc_heavyshotgun
	name = "\improper ML-101 stock"
	desc = "A irremovable ML-101 stock."
	icon_state = "ml101"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/icc_pdw
	name = "\improper L-40 stock"
	desc = "A irremovable L-40 stock."
	icon_state = "l40"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/icc_sharpshooter
	name = "\improper L-1 stock"
	desc = "A irremovable L-11 stock."
	icon_state = "l11"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/clf_heavyrifle
	name = "PTR-41/1785 body"
	desc = "A stock for a PTR-41/1785 A-MR."
	icon_state = "ptrs"
	pixel_shift_x = 15
	pixel_shift_y = 0

/obj/item/attachable/stock/dpm
	name = "\improper DP-27 stock"
	desc = "A irremovable DP stock."
	icon_state = "dp"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t39stock
	name = "\improper SH-39 stock"
	desc = "A specialized stock for the SH-39."
	icon_state = "t39"
	pixel_shift_x = 32
	pixel_shift_y = 13
	size_mod = 1
	attach_features_flags = ATTACH_REMOVABLE
	wield_delay_mod = 0.2 SECONDS
	accuracy_mod = 0.15
	recoil_mod = -2
	scatter_mod = -2

/obj/item/attachable/stock/t60stock
	name = "MG-60 stock"
	desc = "A irremovable MG-60 general purpose machinegun stock."
	icon_state = "t60"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t70stock
	name = "\improper GL-70 stock"
	desc = "A irremovable GL-70 grenade launcher stock."
	icon_state = "t70"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t84stock
	name = "\improper FL-84 stock"
	desc = "A irremovable FL-84 flamer stock."
	icon_state = "tl84"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/m41a
	name = "PR-11 stock"
	icon_state = "m41a"

/obj/item/attachable/stock/tx11
	name = "AR-11 stock"
	icon_state = "tx11"

/obj/item/attachable/stock/som_mg_stock
	name = "\improper V-41 stock"
	desc = "A irremovable V-41 machine gun stock."
	icon_state = "v41"
	pixel_shift_x = 0
	pixel_shift_y = 0

/obj/item/attachable/stock/t18stock
	name = "\improper AR-18 stock"
	desc = "A specialized stock for the AR-18."
	icon_state = "t18"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t12stock
	name = "\improper AR-12 stock"
	desc = "A specialized stock for the AR-12."
	icon_state = "t12"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t42stock
	name = "\improper MG-42 stock"
	desc = "A specialized stock for the MG-42."
	icon_state = "t42"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t64stock
	name = "\improper BR-64 stock"
	desc = "A specialized stock for the BR-64."
	icon_state = "t64"

//You can remove the stock on the Magnum. So it has stats and is removeable.
/obj/item/attachable/stock/t76
	name = "T-76 magnum stock"
	desc = "A R-76 magnum stock. Makes about all your handling better outside of making it harder to wield. Recommended to be kept on the R-76 at all times if you value your shoulder."
	icon_state = "t76"
	attach_features_flags = ATTACH_REMOVABLE
	melee_mod = 5
	scatter_mod = -1
	size_mod = 2
	aim_speed_mod = 0.05
	recoil_mod = -2
	pixel_shift_x = 30
	pixel_shift_y = 14

/obj/item/attachable/stock/at45stock
	name = "\improper CC/AT45 stock"
	desc = "A stock for a CC/AT45."
	icon_state = "at45"
	pixel_shift_x = 0
	pixel_shift_y = 0
