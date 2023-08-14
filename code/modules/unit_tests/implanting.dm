///Implants a human to make sure it effectively is inserted and deleted.
/datum/unit_test/implanting

/datum/unit_test/implanting/Run()
	var/mob/living/carbon/human/implanted_guy = allocate(/mob/living/carbon/human)
	var/obj/item/implanter/implanter_to_inject = allocate(/obj/item/implanter/cloak)

	var/obj/item/implant/implant_in_planter = implanter_to_inject.imp

	implanted_guy.put_in_active_hand(implanter_to_inject)

	TEST_ASSERT(implanter_to_inject.attack(implanted_guy, implanted_guy), "[implanted_guy] failed to inject himself with [implanter_to_inject]")
	TEST_ASSERT(!implanter_to_inject.imp, "[implanter_to_inject] still has an implant in its implanter, despite being injected into [implanted_guy]")

	qdel(implanted_guy)
	TEST_ASSERT(QDELETED(implant_in_planter), "[implant_in_planter] has been injected into [implanted_guy], who has been deleted, but the implant still exists.")
