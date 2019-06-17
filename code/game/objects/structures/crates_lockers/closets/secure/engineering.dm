/obj/structure/closet/secure_closet/engineering_chief
	name = "\improper Chief Engineer's locker"
	req_access = list(ACCESS_MARINE_CE)
	icon_state = "securece1"
	icon_closed = "securece"
	icon_locked = "securece1"
	icon_opened = "secureceopen"
	icon_broken = "securecebroken"
	icon_off = "secureceoff"


/obj/structure/closet/secure_closet/engineering_chief/Initialize()
	. = ..()
	new /obj/item/clothing/tie/storage/webbing(src)
	new /obj/item/clothing/tie/storage/brown_vest(src)
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/gloves/yellow(src)
	if(is_mainship_level(z))
		new /obj/item/radio/headset/almayer/mcom(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/multitool(src)
	new /obj/item/flash(src)
	new /obj/item/tool/taperoll/engineering(src)
	new /obj/item/flashlight(src)
	new /obj/item/storage/pouch/electronics(src)
	new /obj/item/storage/pouch/general/medium(src)
	new /obj/item/storage/pouch/construction(src)
	new /obj/item/storage/pouch/tools(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/white(src)
	new /obj/item/clothing/under/whites(src)
	new /obj/item/clothing/head/white_dress(src)


/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies"
	req_access = list(ACCESS_MARINE_ENGINEERING)
	icon_state = "secureengelec1"
	icon_closed = "secureengelec"
	icon_locked = "secureengelec1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengelecbroken"
	icon_off = "secureengelecoff"


/obj/structure/closet/secure_closet/engineering_electrical/Initialize()
	. = ..()
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/circuitboard/apc(src)
	new /obj/item/circuitboard/apc(src)
	new /obj/item/circuitboard/apc(src)
	new /obj/item/multitool(src)
	new /obj/item/multitool(src)
	new /obj/item/multitool(src)

/obj/structure/closet/secure_closet/engineering_welding
	name = "welding supplies"
	req_access = list(ACCESS_MARINE_ENGINEERING)
	icon_state = "secureengweld1"
	icon_closed = "secureengweld"
	icon_locked = "secureengweld1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengweldbroken"
	icon_off = "secureengweldoff"


/obj/structure/closet/secure_closet/engineering_welding/Initialize()
	. = ..()
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/tool/weldingtool/largetank(src)
	new /obj/item/tool/weldingtool/largetank(src)
	new /obj/item/tool/weldingtool/largetank(src)
	new /obj/item/tool/weldpack(src)
	new /obj/item/tool/weldpack(src)
	new /obj/item/tool/weldpack(src)

/obj/structure/closet/secure_closet/engineering_personal
	name = "engineer's locker"
	req_access = list(ACCESS_MARINE_ENGINEERING)
	icon_state = "secureeng1"
	icon_closed = "secureeng"
	icon_locked = "secureeng1"
	icon_opened = "secureengopen"
	icon_broken = "secureengbroken"
	icon_off = "secureengoff"

/obj/structure/closet/secure_closet/engineering_personal/Initialize()
	. = ..()
	if (prob(70)) 
		new /obj/item/clothing/tie/storage/brown_vest(src)
	else 
		new /obj/item/clothing/tie/storage/webbing(src)
	new /obj/item/storage/toolbox/mechanical(src)
	if(!is_ground_level(z)) 
		new /obj/item/radio/headset/almayer/mt(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/tool/taperoll/engineering(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/storage/pouch/general(src)
	new /obj/item/storage/pouch/electronics(src)
	new /obj/item/storage/pouch/construction(src)
	new /obj/item/storage/pouch/medkit(src)
	new /obj/item/storage/pouch/tools(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/flashlight(src)
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/white(src)
	new /obj/item/clothing/under/whites(src)
	new /obj/item/clothing/head/white_dress(src)
	switch(SSmapping.config.map_name)
		if(MAP_ICE_COLONY)
			new /obj/item/clothing/suit/storage/snow_suit(src)
			new /obj/item/clothing/mask/rebreather/scarf(src)
			new /obj/item/clothing/mask/rebreather(src)	

/obj/structure/closet/secure_closet/atmos_personal
	name = "technician's locker"
	req_access = list(ACCESS_MARINE_ENGINEERING)
	icon_state = "secureatm1"
	icon_closed = "secureatm"
	icon_locked = "secureatm1"
	icon_opened = "secureatmopen"
	icon_broken = "secureatmbroken"
	icon_off = "secureatmoff"


/obj/structure/closet/secure_closet/atmos_personal/Initialize()
	. = ..()
	if (prob(70))
		new /obj/item/clothing/tie/storage/brown_vest(src)
	else
		new /obj/item/clothing/tie/storage/webbing(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/flashlight(src)
	new /obj/item/tool/extinguisher(src)
	if(is_mainship_level(z))
		new /obj/item/radio/headset/almayer/mt(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tool/taperoll/engineering(src)

