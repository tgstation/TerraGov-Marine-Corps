/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/mob/screen/generic.dmi'
	icon_state = "x"
	var/btype = 0 // 0=radio, 1=prox, 2=time

	timer
		btype = 2

		syndicate

	proximity
		btype = 1

	radio
		btype = 0


/obj/effect/spawner/newbomb/Initialize()
	. = ..()

	var/obj/item/transfer_valve/V = new(src.loc)
	var/obj/item/tank/phoron/PT = new(V)
	var/obj/item/tank/oxygen/OT = new(V)

	V.tank_one = PT
	V.tank_two = OT

	PT.master = V
	OT.master = V

	var/obj/item/assembly/S

	switch (src.btype)
		// radio
		if (0)

			S = new/obj/item/assembly/signaler(V)

		// proximity
		if (1)

			S = new/obj/item/assembly/prox_sensor(V)

		// timer
		if (2)

			S = new/obj/item/assembly/timer(V)


	V.attached_device = S

	S.holder = V
	S.toggle_secure()

	V.update_icon()

	return INITIALIZE_HINT_QDEL
