/datum/voicepack/female/elf/get_sound(soundin, modifiers)
	var/used
	switch(modifiers)
		if("old")
			used = getfold(soundin)
		if("young")
			used = getfyoung(soundin)
		if("silenced")
			used = getfsilenced(soundin)
	if(!used)
		switch(soundin)
			if("breathgasp")
				used = list('sound/vo/female/elf/breathgasp (1).ogg','sound/vo/female/elf/breathgasp (2).ogg')
			if("fatigue")
				used = 'sound/vo/female/elf/fatigue.ogg'
			if("firescream")
				used = 'sound/vo/female/elf/fatigue.ogg'
			if("gasp")
				used = list('sound/vo/female/elf/gasp (1).ogg','sound/vo/female/elf/gasp (2).ogg','sound/vo/female/elf/gasp (3).ogg')
			if("groan")
				used = 'sound/vo/female/elf/groan.ogg'
			if("haltyell")
				used = 'sound/vo/female/elf/haltyell.ogg'
			if("hmm")
				used = list('sound/vo/female/elf/hmm (1).ogg','sound/vo/female/elf/hmm (2).ogg')
			if("pain")
				used = list('sound/vo/female/elf/pain (1).ogg','sound/vo/female/elf/pain (2).ogg','sound/vo/female/elf/pain (3).ogg','sound/vo/female/elf/pain (4).ogg')
			if("embed")
				used = list('sound/vo/female/elf/pain (1).ogg','sound/vo/female/elf/pain (2).ogg','sound/vo/female/elf/pain (3).ogg','sound/vo/female/elf/pain (4).ogg')
			if("paincrit")
				used = 'sound/vo/female/elf/paincrit.ogg'
			if("painscream")
				used = list('sound/vo/female/elf/painscream (1).ogg','sound/vo/female/elf/painscream (2).ogg')
			if("scream")
				used = list('sound/vo/female/elf/scream (1).ogg','sound/vo/female/elf/scream (2).ogg','sound/vo/female/elf/scream (3).ogg','sound/vo/female/elf/scream (4).ogg')

	if(!used) //we haven't found a racial specific sound so use generic
		used = ..(soundin)
	return used