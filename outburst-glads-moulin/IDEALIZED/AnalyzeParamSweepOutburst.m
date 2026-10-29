function [mean_deltaN, maxVelDrop, maxVelDrop_x] = AnalyzeParamSweepOutburst(md, flood_start_day, flood_end_day)
% Neosha Narayanan
% October 2026, for use on moulin


% Inputs:
% md: a single outburst flood result from a .mat file
% flood_start_day: day the flood started 
% flood_end_day: day the flood ended 

% Outputs:


% Things we want to grab: 
% magnitude of slowdown, location of slowdown, change in effective pressure

% 1. Get change in effective pressure
N_before = mean(md.results.TransientSolution(flood_start_day-1).EffectivePressure, 'all');
N_after = mean(md.results.TransientSolution(flood_end_day+3).EffectivePressure, 'all');
mean_deltaN = N_after-N_before;

% 2. Get magnitude and location of slowdown

vel_before = md.results.TransientSolution(flood_start_day-1).Vel;
vel_after = md.results.TransientSolution(flood_start_day+3).Vel;
[max_val, max_idx] = max(vel_after - vel_before);
maxVelDrop_x = md.mesh.x(max_idx); % this assumes that the max value is where the slowdown happens
maxVelDrop = max_val;




end
