/mob/living/carbon/xenomorph/beetle/ai

/mob/living/carbon/xenomorph/beetle/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/suicidal)

/mob/living/carbon/xenomorph/baneling/ai

/mob/living/carbon/xenomorph/baneling/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/suicidal)

/mob/living/carbon/xenomorph/crusher/ai

/mob/living/carbon/xenomorph/crusher/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/defender/ai

/mob/living/carbon/xenomorph/defender/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/drone/ai

/mob/living/carbon/xenomorph/drone/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/hivelord/ai

/mob/living/carbon/xenomorph/hivelord/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/hunter/ai

/mob/living/carbon/xenomorph/hunter/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/praetorian/ai

/mob/living/carbon/xenomorph/praetorian/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/ranged)

/mob/living/carbon/xenomorph/queen/ai

/mob/living/carbon/xenomorph/queen/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/mantis/ai

/mob/living/carbon/xenomorph/mantis/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/suicidal)

/mob/living/carbon/xenomorph/ravager/ai

/mob/living/carbon/xenomorph/ravager/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/runner/ai

/mob/living/carbon/xenomorph/runner/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/scorpion/ai

/mob/living/carbon/xenomorph/scorpion/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/ranged)

/mob/living/carbon/xenomorph/sentinel/ai

/mob/living/carbon/xenomorph/sentinel/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/ranged)

/mob/living/carbon/xenomorph/spitter/ai

/mob/living/carbon/xenomorph/spitter/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/ranged)

/mob/living/carbon/xenomorph/warrior/ai

/mob/living/carbon/xenomorph/warrior/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/boiler/ai

/mob/living/carbon/xenomorph/boiler/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/boiler/sizzler/ai

/mob/living/carbon/xenomorph/boiler/sizzler/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/nymph/ai

/mob/living/carbon/xenomorph/nymph/ai/Initialize(mapload, _hivenumber)
	hivenumber = _hivenumber || hivenumber
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)
