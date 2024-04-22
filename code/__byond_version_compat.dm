// This file contains defines allowing targeting byond versions newer than the supported
// TODO: Remove the 514 versions once we move completely over to 515
#if DM_VERSION < 515
// 514 version
#define PROC_REF(X) (.proc/##X)
#define VERB_REF(X) (.verb/##X)
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
#define TYPE_VERB_REF(TYPE, X) (##TYPE.verb/##X)
#define GLOBAL_PROC_REF(X) (.proc/##X)
#else
// 515 versions
#define PROC_REF(X) (nameof(.proc/##X))
#define VERB_REF(X) (nameof(.verb/##X))
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
#define TYPE_VERB_REF(TYPE, X) (nameof(##TYPE.verb/##X))
#define GLOBAL_PROC_REF(X) (/proc/##X)
#endif
