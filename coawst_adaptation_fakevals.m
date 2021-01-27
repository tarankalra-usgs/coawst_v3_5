clear all ; close all ; clc ; 
% iterate through time

% Adaptation of growth curve to COAWST model ..
% test with some fake values .. 

need to read a mat file
% with information of mean high water and a marsh elevation
% TSK Added
%Depth=0.5 ; 
MHW=0.75; 
mtr=0.25; 

Dmin=MHW; 
Dmax=-0.737*2*MHW+0.092+MHW; 

Depth=(Dmax+Dmin)*0.5; 
Depth=0.2;
%Dm=linspace(Dmax,Dmin,30); 

%Dmin=MHW ;    % #NOTE THIS IS MHW

%AA=.25*(-Dmin-Dmax)*(Dmax-3*Dmin)  % #scales parabola from 0 to 1 in next line

AA=0.25*(Dmin-Dmax)*(Dmax-Dmin); 

sec2day=1.0/86400; 
dt=2080; 
por=.9; % #rough estimate of 1-porosity
dens=2650; 
chiref=0.158; %# recalcitrant carbon
po=(1-por)*dens ; % 300; % *(1-por)*density ;% 

nlength=12000   ; 
bedmass(1:nlength)   =250; % Initial bedmass of organic matter in kg/sq-m
marsh_grow(1:nlength)=0.0 ; 
marsh_mask=1 ;
marsh_grow_old =0.0; 


marsh_vert=0.0  ; 

for iic=1:nlength  ; % length(Dmin)
  %disp('dt in days')
  BMax=2.500; %# kg/m2
  Bpeak=BMax*(Depth-Dmax)*(Depth-Dmin)/AA  ;% #peak biomass as a function of depth
  
  Bpeak(Bpeak<=1e-9)=0  ;
  Bfrac=(Bpeak/BMax);  % #quick fraction for plotting
  
  nuGp=.0138 ; % accordign to Joel units of 1/day #below ground  fraction 
% % 
  dt_indays(iic)=iic*dt*sec2day ;

  if(dt_indays(iic)<180)
%   AMC then has units kg/[s m^2 ] % Bpeak is in kg/(sq.m-year) and nugp is in
%   1/day , *dt_indays = kg/(m^2)

% why should rate of growht depend on time physically but if Joel is
% correct then dimensionally nugp =1/days Bpeak is kg/(m2-year) so AMC is
% kg/(m2-year)
% Originally i had dt in days multipleid 
%   AMC(iic)=dt_indays(iic)*Bpeak*(nuGp);  %180 growing days
   
   AMC(iic)=Bpeak*nuGp ; 
   AMC(iic)=AMC(iic)*marsh_mask  ;
  else
   AMC(iic)=0.0; 
  end 
    
  Rref(iic)      =AMC(iic)*chiref  ;%#what material remains % kg*/(m^2)
 % elevation change due to accretion 
 % then rate is kg/(m^2-year)/kg/m^3 = m/year
 
   marsh_vert_rate(iic)=Rref(iic)/po  ; % so this actually in meters or new thinking says m/year 
   
% then convert this to m/s 
   marsh_vert_rate_insec(iic)= marsh_vert_rate(iic)/(365*86400)       ; 
   
   % then convert the rate of m/s to actual accretion m/s*dt in s to get m 
   slope_in_meter=marsh_vert_rate_insec(iic)*dt ; % each time step adds to accretion  
   marsh_grow(iic)=marsh_grow_old+slope_in_meter  ;
   
   marsh_grow_old=marsh_grow(iic);

  % convert slope in meter to kg/sq.m
   mo(iic)=slope_in_meter*po ; % added organic mass per time step  ; 
   bedmass(iic)=bedmass(iic)+mo(iic) ; 
 %  just for plotting save bpeak  
 Bpeak_save(iic)=Bpeak; 
end  

 
x_fac=dt_indays./dt_indays ; 
figure(1)
subplot(3,1,1)
plot(dt_indays, squeeze(Dmin).*x_fac,'r')
hold on 
plot(dt_indays, squeeze(Dmax).*x_fac, 'k')
hold on 
plot(dt_indays, squeeze(Depth).*x_fac, 'g')
legend('dmin','dmax','Depth')
% 
% subplot(4,1,2)
% plot(dt_indays, squeeze(mtr2))
% xlabel('in days')
% ylabel('tidal range')

%figure(2)
subplot(3,1,2)
plot(dt_indays, squeeze(marsh_vert_rate)*1000)
xlabel('in days')
ylabel('Vertical growth rate in mm/year')

subplot(3,1,3)
plot(dt_indays,marsh_grow*1000) 
xlabel('in days')
ylabel('vertical growth in mm')    
    
% Joel s email responses 
% I have to double check but I recall nuGp has units [1/day] 
%AMC then has units kg/[s m^2 ]  (e.g. the total growth for 180 days, is resealed to a yearly rate in seconds)
%then (kg/[s m^2]) /( kg/[m^3]) = m/s  which is the vertical accretion rate as appropriate
%As for the scaling factor, this was a simple math excercise.
%It will take me time to recreate but basically, when the 
%derivative of the parabola is zero you want the function to evaluate at 
%1 given the two roots Dmax and Dmin of the parabola

%Double check the rates as the bathymetric change seems a 
%little low for 118 days. (365/118)* (2.5*10^-5) for annual rate m/yr is ~7.7 *10^-5  
%I am expecting a max change of ~3 mm (with no sediment) so the rate 
%seems off a few orders of magnitude.  Ill look through the code here this weekend. 
%rate in mm/s    2.4417e-07
% rate in m/s 2.4417e-10

% 
% irate=0; 
% if(irate==1)
% % rate in m/s 2.4417e-10
%     rate=2.4417e-10 ;
%     mv1(1)=0.0; 
%     for iic=1:nlength
%         dt_indays(iic)=dt*iic*sec2day ; 
%         if(dt_indays(iic)>180)
%             rate=0.0;
%         else
%             rate=rate;
%         end 
%     end 
%     mv1(iic+1)=dt*rate+mv1(iic) ;
% end 
