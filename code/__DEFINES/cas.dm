#define PLANE_STATE_ACTIVATED 0
#define PLANE_STATE_DEACTIVATED 1
#define PLANE_STATE_PREPARED 2
#define PLANE_STATE_FLYING 3

#define CAS_FUEL_PER_CAN_POUR 3

///fuel count at which to forbid pilot from taking off
#define LOW_FUEL_TAKEOFF_THRESHOLD 10
///fuel count at which to force plane to land due to low fuel
#define LOW_FUEL_LANDING_THRESHOLD 4
///% at which to warn pilot that there is low fuel
#define LOW_FUEL_WARNING_THRESHOLD 0.2

#ifdef TESTING
#define CAS_USABLE TRUE
#else
#define CAS_USABLE FALSE
#endif

///Provide a link for CAS users to click to jump to.
#define CAS_JUMP_LINK(location) "(<a href='byond://?_src_=usr;cas_jump=[text_ref(location)];'>JUMP</a>)"
