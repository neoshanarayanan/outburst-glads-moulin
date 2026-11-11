% November 9, 2026

%load Spinups/idealized_coupled_outflow75.mat
load('~/cos-lab-wchu38/neosha/outburst_outputs/ParamSweep2_Seasonal/seasonal_try1_NOISE2.mat')
md_input = md;

outburst_days = 6:15:365;

lakex = 500;
duration = 45;

for d = 1:length(outburst_days)
	md, description = SeasonalOutburst_Efficient(md_input, lakex, outburst_days(d), duration, 5);
	disp('one outburst run')
end
