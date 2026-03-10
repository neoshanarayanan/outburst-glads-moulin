% Plot timeseries of coupled GLaDS run
% February 2026

load kyagar14_coupled_outburst_newsb.mat
%% Plot non-channel params
for tt = 1:length(md.results.TransientSolution)
    nmean(tt) = mean(md.results.TransientSolution(tt).EffectivePressure);
    nmin(tt) = min(md.results.TransientSolution(tt).EffectivePressure);
    nmax(tt) = max(md.results.TransientSolution(tt).EffectivePressure);

    phimean(tt) = mean(md.results.TransientSolution(tt).HydraulicPotential);
    phimin(tt) = min(md.results.TransientSolution(tt).HydraulicPotential);
    phimax(tt) = max(md.results.TransientSolution(tt).HydraulicPotential);

    stmean(tt) = mean(md.results.TransientSolution(tt).HydrologySheetThickness);
    stmin(tt) = min(md.results.TransientSolution(tt).HydrologySheetThickness);
    stmax(tt) = max(md.results.TransientSolution(tt).HydrologySheetThickness);

    velmean(tt) = mean(md.results.TransientSolution(tt).Vel);
    velmin(tt) = min(md.results.TransientSolution(tt).Vel);
    velmax(tt) = max(md.results.TransientSolution(tt).Vel);


end



linewidth = 1.5;
subplot(4, 1, 1)
plot(1:tt,nmean,1:tt,nmin,1:tt,nmax, 'LineWidth',linewidth)
ylabel("Effective Pressure (Pa)")

subplot(4, 1, 2)
plot(1:tt,phimean,1:tt,phimin,1:tt,phimax, 'LineWidth',linewidth)
ylabel("Hydraulic Potential (\phi)")

subplot(4, 1, 3)
plot(1:tt,stmean,1:tt,stmin,1:tt,stmax, 'LineWidth',linewidth)
ylabel("Sheet Thickness")

subplot(4, 1, 4)
plot(1:tt,velmean,1:tt,velmin,1:tt,velmax, 'LineWidth',linewidth)
ylabel("Velocity (m/a)")

%%  Some spatial plots

%plotmodel(md, 'data', md.results.TransientSolution(end).EffectivePressure)
%plotmodel(md, 'data', md.results.TransientSolution(end).HydraulicPotential)
plotmodel(md, 'data', md.results.TransientSolution(end).HydrologySheetThickness)
