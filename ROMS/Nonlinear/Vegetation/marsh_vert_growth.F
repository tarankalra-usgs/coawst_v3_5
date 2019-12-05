#include "cppdefs.h"

      MODULE marsh_vert_growth_mod
!
#if defined MARSH_VERT_GROWTH && defined MARSH_TIDAL_RANGE
!
!svn $Id: marsh_vert_growth.F 429 2015-04-20 17:30:26Z arango $
!======================================================================!
!  Copyright (c) 2002-2016 The ROMS/TOMS Group                         !
!    Licensed under a MIT/X style license           Hernan G. Arango   !
!    See License_ROMS.txt                   Alexander F. Shchepetkin   !
!==============================================Tarandeep S. Kalra======!
!==============================================Joel Carr===============!
!================================================Neil K. Ganju  =======!
!==============================================Alfredo Aretxabaleta====!
!==============================================John C. Warner==========!
!                                                                      !
!  Calculate vertical growth of marsh through biomass production       !
!  and calculate marsh vegetation growth.                              ! 
!  References:                                                         !
!                                                                      !
!======================================================================!
!  For marsh vertical growth and parabolic profile:                    !
!======================================================================!
!  Morris, J. T., P. V. Sundareshwar, C. T. Nietch, B. Kjerfve, and    !
!  D. R. Cahoon.: Responses of coastal wetlands to rising sea level,   !
!  Ecology, 83(10), 2869–2877, 2002.                                   !
!                                                                      !
!======================================================================!
!  For marsh vegetation parameters:                                    !
!======================================================================!
!  D'Alpaos, A.,  Lanzoni, S.,  Marani, M., Rinaldo, A.: Landscape     !
!  evolution in tidal embayments: Modeling the interplay of erosion,   !
!  sedimentation, and vegetation dynamics, Journal of Geophysical      !
!  Research,112, F01008, 2007.                                         !
!======================================================================!
!                                                                      !
      implicit none

      PRIVATE
      PUBLIC  :: marsh_vert_growth

      CONTAINS
!
!***********************************************************************
      SUBROUTINE marsh_vert_growth (ng,tile)
!***********************************************************************
      USE mod_param
      USE mod_grid
      USE mod_ocean
      USE mod_vegarr
!      USE mod_sedbed

      integer, intent(in) :: ng, tile

!  Local variable declarations.
!
# include "tile.h"
!
      CALL marsh_vert_growth_tile (ng, tile,                            &
     &                       LBi, UBi, LBj, UBj,                        &
     &                       IminS, ImaxS, JminS, JmaxS,                &
     &                       GRID(ng) % h,                              &
     &                       OCEAN(ng)  % zeta,                         &
!     &                       SEDBED(ng) % bed,                          &
     &                       VEG(ng) % marsh_mask,                      &
     &                       VEG(ng) % marsh_high_water,                &
     &                       VEG(ng) % marsh_tidal_range,               &
#  if defined MARSH_BIOMASS_VEG
     &                       VEG(ng) % plant,                           &
#  endif 
     &                       VEG(ng) % marsh_biomass_peak,              &
     &                       VEG(ng) % marsh_vert)

      END SUBROUTINE marsh_vert_growth

!***********************************************************************
      SUBROUTINE marsh_vert_growth_tile (ng, tile,                      &
     &                             LBi, UBi, LBj, UBj,                  &
     &                             IminS, ImaxS, JminS, JmaxS,          &
     &                             h,                                   &
     &                             zeta,                                &
!     &                             bed,                                 &
     &                             marsh_mask,                          &
     &                             marsh_high_water,                    &
     &                             marsh_tidal_range,                   &
#  if defined MARSH_BIOMASS_VEG
     &                             plant,                               &
#  endif 
     &                             marsh_biomass_peak,                  &
     &                             marsh_vert)
!***********************************************************************
!
      USE mod_grid
      USE mod_forces
      USE mod_param
      USE mod_scalars
      USE mod_vegetation
      USE mod_vegarr
!      USE mod_sediment
      USE bc_2d_mod, ONLY : bc_r2d_tile
      USE bc_3d_mod, ONLY : bc_r3d_tile
!      USE exchange_2d_mod
# ifdef DISTRIBUTE
      USE mp_exchange_mod, ONLY : mp_exchange2d, mp_exchange3d,         &
     &                            mp_exchange4d
# endif
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile
      integer, intent(in) :: LBi, UBi, LBj, UBj
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
!
# ifdef ASSUMED_SHAPE
!      real(r8), intent(in)    :: bed(LBi:,LBj:,:,:)
      real(r8), intent(in)    :: marsh_mask(LBi:,LBj:)
      real(r8), intent(inout) :: h(LBi:,LBj:)
      real(r8), intent(in)    :: zeta(LBi:,LBj:,:)
      real(r8), intent(in)    :: marsh_high_water(LBi:,LBj:)
      real(r8), intent(in)    :: marsh_tidal_range(LBi:,LBj:)
#  if defined MARSH_BIOMASS_VEG
      real(r8), intent(inout) :: plant(LBi:,LBj:,:,:)
#  endif
      real(r8), intent(inout) :: marsh_biomass_peak(LBi:,LBj:)
      real(r8), intent(inout) :: marsh_vert(LBi:,LBj:)
# else
!      real(r8), intent(in)    :: bed(LBi:UBi,LBj:UBj,Nbed,MBEDP)
      real(r8), intent(in)    :: marsh_mask(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: h(LBi:UBi,LBj:UBj)
      real(r8), intent(in)    :: zeta(LBi:UBi,LBj:UBj,3)
      real(r8), intent(in)    :: marsh_high_water(LBi:UBi,LBj:UBj)
      real(r8), intent(in)    :: marsh_tidal_range(LBi:UBi,LBj:UBj)
#  if defined MARSH_BIOMASS_VEG
      real(r8), intent(inout) :: plant(LBi:UBi,LBj:UBj,NVEG,NVEGP)
#  endif
      real(r8), intent(inout) :: marsh_biomass_peak(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: marsh_vert(LBi:UBi,LBj:UBj)
# endif
!
!  Local variable declarations.
!
      integer  :: i, j, k, ised
      real(r8) :: Dmin, Dmax, depth
      real(r8) :: Bpeak, Rref, AMC
      real(r8) :: ramp, cff 
      real(r8), parameter :: lower_lev=1.0e-9 ! 800-1000 kg/m3 
      real(r8), parameter ::                                            &
     &                  one_over_year2sec=1.0_r8/(365.0_r8*86400.0_r8)
!
#  if defined MARSH_BIOMASS_VEG
      integer :: ivpr, iveg
#  endif 
!
# include "set_bounds.h"
!          
      ramp=MIN(tdays(ng)/NTIMES_MARSH,1.0_r8)
!
      J_LOOP: DO j=Jstr,Jend
        DO i=Istr,Iend
!
          Dmin=marsh_high_water(i,j)
!          Dmax=-0.7372_r8*2.0_r8*Dmin+0.092_r8+Dmin
          Dmax=Par_fac1(ng)*2.0_r8*Dmin+Par_fac2(ng)+Dmin
!
          depth=ABS(h(i,j))
!
          IF(tdays(ng).lt.tdays_marsh_growth) THEN 
!
! scales parabola from 0 to 1 in next line.
!
            cff=0.25_r8*(Dmin-Dmax)*(Dmax-Dmin)
!
! peak biomass as a function of depth.
! 
            Bpeak=BMax(ng)*(Depth-Dmax)*(Depth-Dmin)/cff
!
            IF (Bpeak.lt.lower_lev) THEN
              Bpeak=0.0_r8
            ENDIF
!
! Amount of below ground biomass. 
!
            AMC=tdays(ng)*Bpeak*nuGp(ng)*one_over_year2sec
          ELSE
! 
! 180 growing days, after 180 days make AMC=0, Bpeak=0.0.
! 
            Bpeak=0.0_r8
            AMC=0.0_r8
          ENDIF
!       
! Masking the amount of marsh biomass and saving in 2D array for I/O.
! 
          marsh_biomass_peak(i,j)=Bpeak*marsh_mask(i,j)
!
! what material remains after accounting for recalitrant Carbon.
!
          Rref=AMC*chiref(ng)
!
! vertical accretion in m. 
!
          marsh_vert(i,j)=(Rref/marsh_bulk_dens(ng))*ramp*dt(ng)*       &
     &                          marsh_mask(i,j)      
! 
#  ifdef MARSH_BIOMASS_MORPH
          h(i,j)=h(i,j)-marsh_vert(i,j)
#  endif
! 
#  if defined MARSH_BIOMASS_VEG
          IF(tdays(ng).gt.NTIMES_MARSH) THEN
            DO iveg=1,NVEG
! 
! Inside veg loop to change veg properties based on Bpeak
!
              cff=( (Bpeak*1000.0_r8)**beta_pdens(ng) )*marsh_mask(i,j)
              plant(i,j,iveg,pdens)=alpha_pdens(ng)*cff
! 
              cff=( (Bpeak*1000.0_r8)**beta_phght(ng) )*marsh_mask(i,j)
              plant(i,j,iveg,phght)=alpha_phght(ng)*cff
! 
              cff=( (Bpeak*1000.0_r8)**beta_pdiam(ng) )*marsh_mask(i,j)
              plant(i,j,iveg,pdiam)=alpha_pdiam(ng)*cff
!
!              plant(i,j,iveg,pthck)=plant(i,j,iveg,pthck)*
!              &                              marsh_mask(i,j)
            END DO
          END IF
#  endif
        END DO
      END DO J_LOOP
!
!---------------------------------------------------------------------
!  Apply periodic or gradient boundary conditions for output
!  purposes only.
!---------------------------------------------------------------------
!
! Exchange boundary data 
!
#  if defined MARSH_BIOMASS_VEG
      DO ivpr=1,NVEGP
        CALL bc_r3d_tile (ng, tile,                                     &
     &                    LBi, UBi, LBj, UBj, 1, NVEG,                  &
     &                    plant(:,:,:,ivpr))
      END DO
#  endif 
!
      CALL bc_r2d_tile (ng, tile,                                       &
     &                  LBi, UBi, LBj, UBj,                             &
     &                  marsh_biomass_peak)
      CALL bc_r2d_tile (ng, tile,                                       &
     &                  LBi, UBi, LBj, UBj,                             &
     &                  marsh_vert)
!
# ifdef DISTRIBUTE
!
#  if defined MARSH_BIOMASS_VEG
      CALL mp_exchange4d (ng, tile, iNLM, 1,                            &
     &                    LBi, UBi, LBj, UBj, 1, NVEG, 1, NVEGP,        &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    plant(:,:,:,:))         
#  endif
!
      CALL mp_exchange2d (ng, tile, iNLM, 2,                            &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        NghostPoints,                             &
     &                        EWperiodic(ng), NSperiodic(ng),           &
     &                        marsh_biomass_peak, marsh_vert)
# endif
!

      END SUBROUTINE marsh_vert_growth_tile
!
!***********************************************************************
#endif

      END MODULE marsh_vert_growth_mod

