function [description] = SeasonalOutburst(md, lake_x, outburst_day, buildup_duration, noise_amplitude)

% Simulate a seasonal cycle in an idealized glacier 
% Neosha Narayanan, November 2026

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
md.timestepping.time_step=1800/md.constants.yts; % Time step (in years)
md.timestepping.final_time=365/365;
md.settings.output_frequency=48;
timevec=md.timestepping.start_time:md.timestepping.time_step:md.timestepping.final_time;

md.transient.requested_outputs={'HydrologyMeltRate', 'HydrologyFrictionHeat', 'HydrologyDissipation'};


% Seasonal SMB gradient (from Thota et al. 2025)
iag=0.62/100; % Ice ablation gradient (Azam et al 2025)
smb=iag.*(md.geometry.surface-ELA).*5/1000*365; % convert from mm/d to m/yr
surface_melt=max(-smb,0);
md.hydrology.englacial_input=zeros(md.mesh.numberofvertices+1,length(timevec));
md.hydrology.englacial_input(end,:)=timevec;
Y=normpdf(timevec,167/365,30/365); % Normal distribution 

% Add Gaussian noise
sigma = noise_amplitude; % amplitude of noise
noise = randn(md.mesh.numberofvertices, numel(timevec)).*sigma; % nxm vector of random noise

for tt=1:length(timevec)
 md.hydrology.englacial_input((1:end-1),tt)=surface_melt./max(Y).*Y(tt) + noise(:, tt);
end


% ADD OUTBURST AT A SPECIFIC TIME!
% 1. find flood location
segx = md.mesh.x(md.mesh.segments(:, 1));
segy = md.mesh.y(md.mesh.segments(:, 1));

lake_pos = md.mesh.segments(find(segy>300 & segx>=lake_x & segx<= lake_x+75), 3);
buildupDuration = buildup_duration/365;
buildupStartDay = outburst_day/365;
buildupEndDay = buildupStartDay + buildupDuration;
buildupTimeSteps = buildupStartDay:md.timestepping.time_step:buildupEndDay;

buildupStart_timestep = length(md.timestepping.start_time:md.timestepping.time_step:buildupStartDay);
buildupEnd_timestep = buildupStart_timestep + length(buildupTimeSteps);
floodtime_indices = buildupStart_timestep:buildupEnd_timestep-1;

% flood size specification
maxFlux = 1;
a = maxFlux/length(buildupTimeSteps); % slope of linear curve
hydrograph = a*(1:length(buildupTimeSteps));

% format for adding
hydrograph = repmat(hydrograph, numel(lake_pos), 1);
md.hydrology.neumannflux = zeros(md.mesh.numberofelements+1, length(timevec));
md.hydrology.neumannflux(lake_pos, floodtime_indices) = hydrograph;
md.hydrology.neumannflux(end, :) = timevec;

md.hydrology.gap_height_max = 100;

% Run simulation
md.cluster = generic('np', 40);
md = solve(md, 'Transient');

description = 'seasonal cycle with noise plus outburst flood';
directory = "~/cos-lab-wchu38/neosha/outburst_outputs/ParamSweep2_Seasonal/";
filename = "seasonal_NOISE10.mat";
save(directory+filename, 'md', 'description', 'outburst_day', '-v7.3')

disp('saved')

end 
