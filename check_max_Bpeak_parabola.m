clear all ; close all ; clc; 
% Code to find the parabolic variation of organic biomass with changing
% changing marsh depth similar to figure 2 of morris et al. 
%RESPONSES OF COASTAL WETLANDS TO RISING SEA LEVEL
% Morris, J. T., P. V. Sundareshwar, C. T. Nietch, B. Kjerfve, and    !
%!  D. R. Cahoon.: Responses of coastal wetlands to rising sea level,   !
%!  Ecology, 83(10), 2869�2877, 2002. 
clear all ; close all ; clc ; 
% iterate through time

% TSK Added
%Depth=0.5 ; 
MHW=0.75; 
mtr=0.5; 

%2*MHW=MTR rougly
Dmax=-0.737*2*MHW+0.092+MHW; 

Dmin=MHW; 
Depth=(Dmax+Dmin)*0.5; 
Dm=linspace(Dmax,Dmin,30); 

%Dmin=MHW ;    % #NOTE THIS IS MHW

%AA=.25*(-Dmin-Dmax)*(Dmax-3*Dmin)  % #scales parabola from 0 to 1 in next line

AA=0.25*(Dmin-Dmax)*(Dmax-Dmin); 

sec2day=1.0/86400; 
dt=2080; 
por=.3; % #rough estimate of 1-porosity 
chiref=0.158; %# recalcitrant carbon
po=300; % *(1-por)*density ;% 

for iic=1:length(Dm)
  %disp('dt in days')
 % dt_indays(iic)=iic*dt*sec2day ;
  %Depth=0.5; % Dm(d)
  Depth=Dm(iic); 
  BMax=2.500; %# kg/m2
  Bpeak=BMax*(Depth-Dmax)*(Depth-Dmin)/AA  ;% #peak biomass as a function of depth
  
  Bpeak(Bpeak<=1e-9)=0  ;
  Bfrac=(Bpeak/BMax);  % #quick fraction for plotting
  
  nuGp=.0138 ; % #below ground  fraction
% % 
  %if(dt_indays(iic)<180)
  
  % in kg/(sq.m-year) 
   AMC=180*Bpeak*nuGp ; % Integrated amount of below ground biomass 
   % in a growing year converted kg/(sq-m year) 
  
  Rref(iic)=AMC*chiref  ;%#what material remains 
  
  % Rref is units of kg/(sq.m-year) po is units of kg/m^3 
 
 % this makes sense should be a max of 3mm / year corresponding to peak
%  % biomass. 
  marsh_vert_rate_inyear(iic)=(Rref(iic)/po);%  #vertical accretion rate in m/year
  marsh_vert_rate_insec(iic)=(Rref(iic)/po)/(365*86400) ;% in m/s
 %  vertical accretion rate in m/year. 
%   marsh_vert_rate_inyear(iic)=(Rref(iic)/po)*365*86400
 
  Bpeak_save(iic)=Bpeak; 
 %marsh_vert_rate_inyear(iic)=marsh_vert_rate_insec(iic)*(365*86400) ; % vertical accretion in mm.s
 %plot(Depth,Bpeak,'r*')
%hold on
end 

figure(1)
 plot( marsh_vert_rate_inyear*1000,Dm*100)
 xlabel('in mm/year')
 ylabel('depth below MHW in cm')
 
 
 
 figure(2)
 plot(Dm*100, Bpeak_save*1000)
 ylabel('g/(m^2*year')
 xlabel('depth ')
 title('figure 2 / morris et al.')
 
% %
% figure(1)
% plot(dt_indays, O) 
% xlabel('in days')
% ylabel('in mm') 

% 
% figure(2)
% plot(
% figure(2)
% plot(O*30*10^6,Dm)
% 
% ylabel('number of days')
% xlabel('vertical growth rate (m/s)')
% 
