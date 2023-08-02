//Implant meant for admin ERTs that will gib a body upon death. In order to prevent Marines from looting things they should not ever have

/obj/item/implant/selfgib
	name = "self-gib implant"

/obj/item/implant/selfgib/on_death()
	activate()

/obj/item/implant/selfgib/activate()
	implant_owner.gib()





