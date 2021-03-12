clear all ; close all ; clc ; 
% iterate through time
% Adaptation of growht curve to COAWST model ..need to read a mat file
% with information of mean high water and a marsh elevation (or bathy that
% would be the depth % 
% currently the mat file has information on two points 

%
% 
sec2day=1.0/86400; 
dt=3600; 
por=.9; % #rough estimate of 1-porosity
dens=2650; 
chiref=0.158; %# recalcitrant carbon
po=(1-por)*dens ; % 300; % *(1-por)*density ;% 
bedmass(1:721)=250; % Initial bedmass of organic matter in kg/sq-m
marsh_grow(1:721)=0.0 ; 
marsh_mask=1 ;


% I have to double check but I recall nuGp has units [1/day] 
%AMC then has units kg/[s m^2 ]  (e.g. the total growth for 180 days, is resealed to a yearly rate in seconds)
%then (kg/[s m^2]) /( kg/[m^3]) = m/s  which is the vertical accretion rate as appropriate
%As for the scaling factor, this was a simple math excercise.
%It will take me time to recreate but basically, when the 
%derivative of the parabola is zero you want the function to evaluate at 
%1 given the two roots Dmax and Dmin of the parabola
% 
% 
% 
load('point12_data_mvt','zeta1','dmin1','mvt1',.....
                        'mbp1','mtr1','h1',........
                        'zeta2','dmin2','mvt2',.....
                        'mbp2','mtr2','h2'); 
 marsh_grow_old = 0.0 ; 
 for iic=1:length(dmin1)  ; % length(Dmin)
%   %disp('dt in days')
   dt_indays(iic)=iic*dt*sec2day ;
   BMax=2.500; %# kg/m2
   
   Dmin=dmin1(iic)     ; % Read in MHW)
   
   Dmax=-0.73*2.0*Dmin+0.092+Dmin; % 
   
   dmax1(iic)=Dmax     ;

   Depth=h1            ; 
   %Depth=-0.05 ;%zeta1(iic)    ; % you know i wrote my thoughts about our onr work, but nobody talks science together so i kept that as a note.. because like you said John was borderline weird to me that pissed me off .. in order to fill him with neils work , i showed him reedy creek sims and wave thrust. now the waves there are 0.001 mm in height ..� 
   
   Depth=abs(Depth); 
   AA=0.25*(Dmin-Dmax)*(Dmax-Dmin)          ; 
   Bpeak=BMax*(Depth-Dmax)*(Depth-Dmin)/AA  ;% #peak biomass as a function of depth
%   
   Bpeak(Bpeak<=1e-9)=0  ;
%   Bfrac=(Bpeak/BMax);  % #quick fraction for plotting
%   
   Bpeak=max(Bpeak,0.0) ; 
   nuGp=.0138 ; % accordign to Joel units of 1/day #below ground  fraction 
% % % 
   if(dt_indays(iic)<180)
% %   AMC then has units kg/[year m^2 ] % Bpeak is in kg/sq.m and nugp is in
% %   1/day , *dt_indays = kg/(m^2-year)
 % integrated rate for 180 days of growth 
    AMC(iic)=(180*Bpeak*(nuGp));  %its an yearly rate for 180 days 

%    % only do this for marsh cells 
    AMC(iic)=AMC(iic)*marsh_mask  ;
   else
    AMC(iic)=0.0; 
   end 
   
   Rref(iic)=AMC(iic)*chiref  ;%#what material remains % kg*/(m^2-year)
   marsh_rate_vert(iic)=(Rref(iic)/po);%  #vertical accretion rate in m/year
   
   % if this the rate per year, then convert it to seconds first m/s
   marsh_vert_rate_insec(iic)= marsh_rate_vert(iic)/(365*86400)       ; 
   
   % marsh accretion , keep adding to previous amount of accretion  
   % then convert the rate of m/s to actual accretion m/s*dt in s to get m 
   slope_in_meter=marsh_vert_rate_insec(iic)*dt ; % each time step adds to accretion  
   marsh_grow(iic)=marsh_grow_old+slope_in_meter  ;
   
   marsh_grow_old=marsh_grow(iic);

  % convert slope in meter to kg/sq.m
   mo(iic)=slope_in_meter*po ; % added organic mass per time step  ; 
   bedmass(iic)=bedmass(iic)+mo(iic) ;
   
 end  
% %

figure(1)
subplot(4,1,1)
plot(dt_indays, squeeze(dmin1),'r')
hold on 
plot(dt_indays, squeeze(dmax1), 'k')
hold on 
plot(dt_indays, squeeze(h1).*(dt_indays./dt_indays), 'g')
legend('dmin','dmax','bathy')
title('at point1')

% subplot(4,1,2)
% plot(dt_indays, squeeze(mtr1))
% xlabel('in days')
% ylabel('tidal range')
% title('at point1')

%figure(2)
subplot(4,1,2)
plot(dt_indays, squeeze(marsh_rate_vert)*1000)
xlabel('in days')
ylabel('Vertical growth rate in mm/year')
%title('at point1')

subplot(4,1,3)
plot(dt_indays, squeeze(marsh_vert_rate_insec)*1000)
xlabel('in days')
ylabel('Vertical growth rate in mm/s')
%title('at point1')

subplot(4,1,4)
plot(dt_indays,marsh_grow(1:721)*1000) 
xlabel('in days')
ylabel('vertical growth in mm')
%title('at point 1')

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 11 10])
print('-dpng','-r100','png/figures_pt1_matlabcode.png')

 figure(5)
 subplot(2,1,1)
 plot(dt_indays, squeeze(mvt1)*1000)
 xlabel('in days')
 ylabel('vertical growth in (mm/s)')
 title('point 1-from coawst run previously')
%  hold on  

 subplot(2,1,2)
 plot(dt_indays, marsh_vert_rate_insec*1000)
 xlabel('in days')
 ylabel('vertical growth from new matlab code in mm/s')
  title('point 1- from new matlab code change')

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 11 10])
print('-dpng','-r100','png/figures_pt1_matlab_COAWST.png')
 % plot(dt_indays, squeeze(mo))
% legend('model prediction','new matlab code')
% title('at point 1')
