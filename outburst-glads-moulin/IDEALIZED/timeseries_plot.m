% Plot timeseries
%load kyagar62_standalone_wsu.mat

for tt=1:length(md.results.TransientSolution)
    bmean(tt)=mean(md.results.TransientSolution(tt).HydrologyGapHeight);
    bmin(tt)=min(md.results.TransientSolution(tt).HydrologyGapHeight);
    bmax(tt)=max(md.results.TransientSolution(tt).HydrologyGapHeight);
    
    hmean(tt)=mean(md.results.TransientSolution(tt).HydrologyHead);
    hmin(tt)=min(md.results.TransientSolution(tt).HydrologyHead);
    hmax(tt)=max(md.results.TransientSolution(tt).HydrologyHead);
    
    qmean(tt)=mean(md.results.TransientSolution(tt).HydrologyBasalFlux);
    qmin(tt)=min(md.results.TransientSolution(tt).HydrologyBasalFlux);
    qmax(tt)=max(md.results.TransientSolution(tt).HydrologyBasalFlux);
    
    Nmean(tt)=mean(md.results.TransientSolution(tt).EffectivePressure);
    Nmin(tt)=min(md.results.TransientSolution(tt).EffectivePressure);
    Nmax(tt)=max(md.results.TransientSolution(tt).EffectivePressure);

    Vmean(tt)=mean(md.results.TransientSolution(tt).Vel);
    Vmin(tt)=min(md.results.TransientSolution(tt).Vel);
    Vmax(tt)=max(md.results.TransientSolution(tt).Vel);
    
    f=md.materials.rho_freshwater./(md.materials.rho_ice.*md.geometry.thickness).*(md.results.TransientSolution(tt).HydrologyHead-md.geometry.base); % Fraction of overburden
    f(f<0)=0;
    fmean(tt)=mean(f);
    fmin(tt)=min(f);
    fmax(tt)=max(f);
    
end

linewidth = 0.5;
subplot(5,1,1)
plot(1:tt,hmean,1:tt,hmin,1:tt,hmax, 'LineWidth',linewidth)
%plot(1:tt,hmean,1:tt,hmin, 'LineWidth',linewidth)
%xlim([0 366])
%xticks(1:31:365)
%dateaxis('x', 3, datetime(2017,1,1))
ylabel('Head (m)')

subplot(5,1,2)
plot(1:tt,bmean,1:tt,bmin,1:tt,bmax, 'LineWidth',linewidth)
%plot(1:tt,hmean,1:tt,hmin, 'LineWidth',linewidth)
%xlim([0 366])
%xticks(1:31:365)
%dateaxis('x', 3, datetime(2017,1,1))
ylabel('Gap Height (m)')

subplot(5,1,3)
plot(1:tt,qmean,1:tt,qmin,1:tt,qmax, 'LineWidth',linewidth)
%plot(1:tt,hmean,1:tt,hmin, 'LineWidth',linewidth)
%xlim([0 366])
%xticks(1:31:365)
%dateaxis('x', 3, datetime(2017,1,1))
ylabel('Basal flux (m^2 s^{-1})')

subplot(5,1,4)
plot(1:tt,Nmean,1:tt,Nmin,1:tt,Nmax, 'LineWidth',linewidth)
%plot(1:tt,hmean,1:tt,hmin, 'LineWidth',linewidth)
%xlim([0 366])
%xticks(1:31:365)
%dateaxis('x', 3, datetime(2017,1,1))
ylabel('Effective Pressure (Pa)')

subplot(5,1,5)
plot(1:tt,Vmean,1:tt,Vmin,1:tt,Vmax, 'LineWidth',linewidth)
%plot(1:tt,hmean,1:tt,hmin, 'LineWidth',linewidth)
%xlim([0 366])
%xticks(1:31:365)
%dateaxis('x', 3, datetime(2017,1,1))
ylabel('Velocity (m/a)')

