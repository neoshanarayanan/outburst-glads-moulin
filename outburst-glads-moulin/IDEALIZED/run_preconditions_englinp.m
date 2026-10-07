% Author: Neosha Narayanan
% Date: October 2026
% Run englacial inputs by calling RunEnglacialInputPrecondition


% Load spinup
load Spinups/idealized.mat
pos = pos;
clear('md', 'description')
load Spinups/idealized_coupled_outflow75.mat
md_input = md;

% Define parameters over which to run the parameter sweep
englinps = 0.5:0.5:15;

for e = 1:length(englinps)
    englinp = englinps(e);
    md, description, pos = RunEnglacialInputPrecondition(md_input, englinp, 500);
    disp('saved')
end
