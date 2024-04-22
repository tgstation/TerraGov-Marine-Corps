#ifndef TESTING
//    #define FASTLOAD
//    #define DEPLOY_TEST
//    #define ROGUEWORLD
#endif

#ifdef FASTLOAD
    #define FORCE_MAP "_maps/roguetest.json"
#else
    #define FORCE_MAP "_maps/roguetown2.json"
#endif

//#define WARTIME