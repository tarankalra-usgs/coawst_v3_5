/*
** svn $Id: sed_toy.h 2232 2019-01-03 18:55:20Z arango $
*******************************************************************************
** Copyright (c) 2002-2019 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**
** Options for One-Dimensional (vertical) Sediment Toy.
**
** Application flag:   SEDBIO_TOY
** Input scripts:      ocean_sedbio_toy.in
**                     sediment_sedbio_toy.in
*/


#define ROMS_MODEL

#undef  BODYFORCE
#undef  LOG_PROFILE
#define DJ_GRADPS
#undef  TS_U3HADVECTION
#undef  TS_C2VADVECTION
#define TS_MPDATA
#define  SALINITY
#define SPLINES_VVISC
#define SPLINES_VDIFF
#define OUT_DOUBLE

#define ANA_GRID
#define  ANA_SMFLUX
#define SOLVE3D
#ifdef SOLVE3D
# define ANA_BPFLUX
# define ANA_BSFLUX
# define ANA_BTFLUX
# define ANA_SPFLUX
# define ANA_SRFLUX
# define ANA_SSFLUX
# define ANA_STFLUX
#endif
#undef  ANA_VMIX

/* select one of six bottom stress methods */
#undef UV_LOGDRAG
#undef  UV_LDRAG
#undef  UV_QDRAG
#undef  SG_BBL
#undef  MB_BBL
#define SSW_BBL

#ifdef SG_BBL
# undef  SG_CALC_ZNOT
# undef  SG_LOGINT
#endif
#ifdef MB_BBL
# undef  MB_CALC_ZNOT
# undef  MB_Z0BIO
# undef  MB_Z0BL
# undef  MB_Z0RIP
#endif
#ifdef SSW_BBL
# define SSW_CALC_ZNOT
# define  SSW_LOGINT
# define WAVES_HEIGHT
# define WAVES_BOT_PERIOD
# define SSW_CALC_UB
#endif

/* turb closure */
#define GLS_MIXING
#ifdef GLS_MIXING
# define KANTHA_CLAYSON
# define N2S2_HORAVG
# define RI_SPLINES
# undef  CRAIG_BANNER
# undef  CHARNOK
# undef  ZOS_HSIG
# undef  TKE_WAVEDISS
#endif

/* sediment choices */
#define SEDIMENT
#ifdef SEDIMENT
# define SUSPLOAD
# undef  BEDLOAD_SOULSBY
# undef  BEDLOAD_MPM
# define SED_DENS
# undef SED_MORPH
# define  SED_BIODIFF
# undef  NONCOHESIVE_BED1
# define  NONCOHESIVE_BED2
# undef COHESIVE_BED
# undef  MIXED_BED
# define ANA_SEDIMENT
#endif

/* water column biogeochemistry (Fennel model) choices */
#define BIO_FENNEL
#ifdef BIO_FENNEL
# undef CARBON
# define OXYGEN
# define ODU
# undef DENITRIFICATION
# define BIO_SEDIMENT
# define ANA_BIOLOGY
#endif

/* Coupled sediment-water column biogeochemistry choices */
/* Note that OXYGEN and ODU have to be defined in biology model */
#define SEDBIO_COUP
#ifdef SEDBIO_COUP
# define SEDTR_REACTIONS
# define OXYGEN
# define ODU
# define SEDBED_BIO
# define BIO_TRACK_REACTIONS
#endif

/* Define these for testing coupled model */
#define RHONE
#ifdef RHONE
# define DB_PROFILE
# define INSTANT_DIFFUSION
# undef  INSTANTREMIN
# undef  SORPTION
# define REPARTITION
# define WC_FAST_REMIN
# define DIAGNOSTICS_BIO
# define NUDGE_SEDBIO_STRATIFIED
# define EMINUSP
# define ANA_CLOUD
# define ANA_INITIAL
# define OUT_DOUBLE
# define ANA_TCLIMA
# define ANA_NUDGCOEF
# define  ANA_WWAVE
# define ANA_INITIAL
#else
# undef  ANA_TCLIMA
# undef  ANA_NUDGCOEF
# define ANA_WWAVE
# define ANA_INITIAL
#endif
