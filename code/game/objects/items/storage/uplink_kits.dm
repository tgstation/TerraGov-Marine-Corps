/obj/item/storage/box/syndicate/
	New()
		..()
		switch (pickweight(list("bloodyspai" = 1, "stealth" = 1, "screwed" = 1, "guns" = 1, "murder" = 1, "freedom" = 1, "hacker" = 1, "smoothoperator" = 1)))
			if("bloodyspai")
				new /obj/item/clothing/mask/gas/voice(src)
				new /obj/item/card/id/syndicate(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)
				return

			if("stealth")
				new /obj/item/tool/pen/paralysis(src)
				new /obj/item/chameleon(src)
				return

			if("screwed")
				new /obj/effect/spawner/newbomb/timer/syndicate(src)
				new /obj/effect/spawner/newbomb/timer/syndicate(src)
				new /obj/item/powersink(src)
				new /obj/item/clothing/suit/space/syndicate(src)
				new /obj/item/clothing/head/helmet/space/syndicate(src)
				return

			if("guns")
				new /obj/item/card/emag(src)
				new /obj/item/explosive/plastique(src)
				return

			if("murder")
				new /obj/item/weapon/energy/sword(src)
				new /obj/item/clothing/glasses/thermal/syndi(src)
				new /obj/item/card/emag(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)
				return

			if("freedom")
				new /obj/item/implanter/freedom(src)

			if("hacker")
				new /obj/item/circuitboard/ai_module/syndicate(src)
				new /obj/item/card/emag(src)
				new /obj/item/encryptionkey/binary(src)
				return

			if("smoothoperator")
				new /obj/item/tool/soap/syndie(src)
				new /obj/item/storage/bag/trash(src)
				new /obj/item/bodybag(src)
				new /obj/item/clothing/under/suit_jacket(src)
				new /obj/item/clothing/shoes/laceup(src)
				return

/obj/item/storage/box/syndie_kit
	name = "box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"

/obj/item/storage/box/syndie_kit/imp_freedom
	name = "boxed freedom implant (with injector)"
	spawn_type = /obj/item/implanter/freedom
	spawn_number = 1

/obj/item/storage/box/syndie_kit/imp_compress
	name = "box (C)"
	spawn_type = /obj/item/implanter/compressed
	spawn_number = 1

/obj/item/storage/box/syndie_kit/imp_explosive
	name = "box (E)"
	spawn_type = /obj/item/implanter/explosive
	spawn_number = 1

/obj/item/storage/box/syndie_kit/space
	name = "boxed space suit and helmet"

/obj/item/storage/box/syndie_kit/space/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/space/syndicate(src)
	new /obj/item/clothing/head/helmet/space/syndicate(src)

/obj/item/storage/box/syndie_kit/chameleon
	name = "Chameleon Kit"
	desc = "Comes with all the clothes you need to impersonate most people.  Acting lessons sold seperately."
	storage_slots = 10
