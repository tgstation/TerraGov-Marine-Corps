#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

// trait accessor defines
#define ADD_TRAIT(target, trait, source) \
	do { \
		var/list/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
			_L = target.status_traits; \
			_L[trait] = list(source); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait)); \
		} else { \
			_L = target.status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
				SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait)); \
			} \
		} \
	} while (0)
#define REMOVE_TRAIT(target, trait, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L && _L[trait]) { \
			for (var/_T in _L[trait]) { \
				if ((!_S && (_T != ROUNDSTART_TRAIT)) || (_T in _S)) { \
					_L[trait] -= _T \
				} \
			};\
			if (!length(_L[trait])) { \
				_L -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait)); \
			}; \
			if (!length(_L)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T)); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)
#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (source in target.status_traits[trait]) : FALSE) : FALSE)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (\
	target.status_traits ?\
		(target.status_traits[trait] ?\
			((source in target.status_traits[trait]) && (length(target.status_traits) == 1))\
			: FALSE)\
		: FALSE)
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (length(target.status_traits[trait] - source) > 0) : FALSE) : FALSE)

//Traits
#define TRAIT_STASIS "stasis"

// common trait
#define INNATE_TRAIT "innate"
#define ROUNDSTART_TRAIT "roundstart" //cannot be removed without admin intervention
#define SLEEPER_TRAIT "sleeper"
#define STASIS_BAG_TRAIT "stasis_bag"
#define CRYOPOD_TRAIT "cryopod"
#define TRAIT_XENO "xeno"
#define STAT_TRAIT "stat"
#define NECKGRAB_TRAIT "neckgrab"
#define RESTING_TRAIT "resting"
#define BUCKLE_TRAIT "buckle"
#define THROW_TRAIT "throw"
#define FORTIFY_TRAIT "fortify" //Defender fortify ability.

//mob traits
#define TRAIT_KNOCKEDOUT		"knockedout" //Forces the user to stay unconscious.
#define TRAIT_INCAPACITATED		"incapacitated"
#define TRAIT_FLOORED			"floored" //User is forced to the ground on a prone position.
#define TRAIT_IMMOBILE			"immobile" //User is unable to move by its own volition.
#define TRAIT_STUNIMMUNE		"stun_immunity"
#define TRAIT_BATONIMMUNE		"baton_immunity"
#define TRAIT_SLEEPIMMUNE		"sleep_immunity"
#define TRAIT_FLASHBANGIMMUNE	"flashbang_immunity"
#define TRAIT_FAKEDEATH			"fakedeath" //Makes the owner appear as dead to most forms of medical examination
#define TRAIT_LEGLESS			"legless" //Has lost all the appendages needed to stay standing up.
