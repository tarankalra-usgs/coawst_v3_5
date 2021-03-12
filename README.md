README
==========

This software is COAWST version 3.5. The user is recommended to read the User Manual for a full description of the procedures for installation, compilation, running, and visualization of the model. There have been several Trainings for the model, and instructions for downloading the tutorials are included in the manual.

```
# define MARSH_DYNAMICS 
-> Switch on marsh dynamics module

# define MARSH_WAVE_THRUST
-> Lateral wave thrust 
# define MARSH_SED_EROSION 
-> Sediment released due to wave lateral wave thrust. 
# define MARSH_RETREAT
-> Retreat of marsh due to lateral wave thrust. 
 
# define MARSH_VERT_GROWTH
/** If want internal calculation of MHW**/
# define MARSH_TIDAL_RANGE_CALC

/** Choose one of the two formulation **/
#  define MARSH_KIRWAN_FORMULATION
#  undef MARSH_MCKEE_FORMULATION

/** Growth of marsh vegetation based on biomass**/
#  define MARSH_BIOMASS_VEG 

# define MARSH_COLONIZE
-> Colonize marsh if sufficient biomass adds up
```

***Matlab codes to test or understand the vertical growth formulations:***
1. check_max_Bpeak_parabola.m 

-> Function of parabola with a simple matlab code. The parabola determines the range of growth for marsh cells. 

2. coawst_adaptation_Kirwan_fixedMHW.m

-> Check Kirwan's formulation with fixed MHW and fixed MLW. 

3. coawst_adaptation_Kirwan.m  

-> Check Kirwan's formulation with 2 output marsh cells from COAWST output that provide
MHW from model. Matfile is "point12_data_mvt.mat" for getting the COAWST data. 

4. coawst_adaptation_Mckee.m

-> Check Mckee's formulation with 2 output marsh cells from COAWST output that provide 
MHW from model. Matfile is "point12_data_mvt.mat" for getting the COAWST data. 
