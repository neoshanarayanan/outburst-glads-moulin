% November 9, 2026

load Spinups/idealized_coupled_outflow75.mat
md_input = md;

outburst_days = 1:15:365;

lakex = 500;
duration = 45;

for d = 1:length(outburst_days)
	md, description = SeasonalOutburst(md_input, lakex, outburst_days(d), duration, 5);
	disp('one outburst run')
end
