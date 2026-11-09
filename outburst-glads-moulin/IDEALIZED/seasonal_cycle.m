% Seasonal cycle for idealized SHMIP outburst
% November 9, 2026
% Author: Neosha Narayanan
clear
%load Spinups/idealized_coupled75.mat
load('/home/nnarayanan38/outburst-glads-moulin/IDEALIZED/Spinups/idealized_coupled_outflow75.mat');
ELA = 3000; % km

% Starting hydrology conditions
md.hydrology.head=md.results.TransientSolution(end).HydrologyHead;
md.hydrology.gap_height=md.results.TransientSolution(end).HydrologyGapHeight;
md.hydrology.reynolds=md.results.TransientSolution(end).HydrologyBasalFlux./1.787e-6;
md.friction.effective_pressure=md.results.TransientSolution(end).EffectivePressure;


md.transient.isstressbalance = 1;
md.transient.ishydrology = 1;
md.friction.coupling = 4;

% Starting velocity conditions
md.initialization.vx=md.results.TransientSolution(end).Vx;
md.initialization.vy=md.results.TransientSolution(end).Vy;
md.initialization.vel=md.results.TransientSolution(end).Vel;

% Time-stepping
md.timestepping.start_time=0;
md.timestepping.time_step=3*3600/md.constants.yts; % Time step (in years)
md.timestepping.final_time=365/365;
md.settings.output_frequency=8;
timevec=md.timestepping.start_time:md.timestepping.time_step:md.timestepping.final_time;


%% Seasonal SMB gradient (from Thota et al. 2025)
iag=0.62/100; % Ice ablation gradient (Azam et al 2025)
smb=iag.*(md.geometry.surface-ELA).*5/1000*365; % convert from mm/d to m/yr
surface_melt=max(-smb,0);
md.hydrology.englacial_input=zeros(md.mesh.numberofvertices+1,length(timevec));
md.hydrology.englacial_input(end,:)=timevec;
Y=normpdf(timevec,167/365,30/365); % Normal distribution 

for tt=1:length(timevec)
 md.hydrology.englacial_input((1:end-1),tt)=surface_melt./max(Y).*Y(tt);
end

%% Run simulation
md.cluster = generic('np', 40);
md = solve(md, 'Transient');

description = 'seasonal_cycle.m, starting from idealized_coupled75.mat with seasonal cycle *5';
directory = "~/cos-lab-wchu38/neosha/outburst_outputs/ParamSweep2_Seasonal/";
filename = "seasonal_try1.mat";
save(directory+filename, 'md', 'description', '-v7.3')


