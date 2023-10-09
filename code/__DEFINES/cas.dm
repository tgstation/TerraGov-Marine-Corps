#define PLANE_STATE_ACTIVATED 0
#define PLANE_STATE_DEACTIVATED 1
#define PLANE_STATE_PREPARED 2
#define PLANE_STATE_FLYING 3

#define LOW_FUEL_THRESHOLD 5
#define CAS_FUEL_PER_CAN_POUR 3

#define LOW_FUEL_LANDING_THRESHOLD 4

#ifdef TESTING
#define CAS_USABLE TRUE
#else
#define CAS_USABLE FALSE
#endif

///Provide a link for CAS users to click to jump to.
#define CAS_JUMP_LINK(location) "(<a href='?_src_=usr;cas_jump=[text_ref(location)];'>JUMP</a>)"
