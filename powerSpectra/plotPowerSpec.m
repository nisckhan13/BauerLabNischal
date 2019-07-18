function powerSpectra = plotPowerSpec(freq, runMeanSpectra, dataLegend, currentTrialName)

powerSpectra = figure;

for ind=1:length(dataLegend)
    if contains(dataLegend(ind), 'Fluor')
        yyaxis right;
        loglog(freq{ind}, runMeanSpectra{ind});
        ylim([-inf 1.1*max(runMeanSpectra{ind})]);
        set(gca, 'YScale', 'log');
    else
        yyaxis left;
        loglog(freq{ind}, runMeanSpectra{ind});
    end 
    hold on;
end

xlim([10^-2 10]);
xlabel('Frequency (Hz)','FontSize',13);
legend(dataLegend,'FontSize',13);
pbaspect([1 1 1]); % make the plot square
title([currentTrialName ', Power Density Spectrum'],'FontSize',13); %also add name of mouse here
yyaxis left;
ylabel('HB (M^2/Hz)','FontSize',13);
yyaxis right;
ylabel('Fluor ((\DeltaF/F)^2/Hz)','FontSize',13);
    
end