function [powerSpectra, powerMap] = plotPower(fRange,runFreq,runSpectra,runMeanSpectra,meanMask,speciesList,currentTrialName)
% plotPower returns figures for the power spectrum and the power maps of
% the input data
%
% Inputs:
%   fRange: frequency range over which to compute the power maps
%   runFreq: matrix containing the frequencies corresponding to the spectra
%   runSpectra: matrix corresponding to the spectra for each of the species
%   runMeanSpectra: mean spectra after brain mask has been applied to data
%   meanMask: standard mask to be used for power map plots
%   speciesList: list of the different species being analyzed
%   currentTrialName: name of the mouse or run being analyzed
%
% Outputs:
%   powerSpectra: plot of power density spectrum over the frequencies
%   powerMap: power map for each of the listed species

%% power spectra plot

powerSpectra = figure;

for ind=1:length(speciesList)
    % plot HB on a seperate axis from Gcamp6
    if contains(speciesList(ind), 'Fluor')
        yyaxis right;
        % plot frequencies and spectra over a log scale
        loglog(runFreq{ind}, runMeanSpectra{ind});
        ylim([-inf 1.1*max(runMeanSpectra{ind})]);
        set(gca, 'YScale', 'log');
    else
        yyaxis left;
        loglog(runFreq{ind}, runMeanSpectra{ind});
    end 
    hold on;
end

% adjust the visuals of the final plot
xlim([10^-2 10]);
xlabel('Frequency (Hz)','FontSize',13);
legend(speciesList,'FontSize',13);
pbaspect([1 1 1]); % make the plot square
title([currentTrialName ', Power Density Spectrum'],'FontSize',13); %also add name of mouse here
yyaxis left;
ylabel('HB (M^2/Hz)','FontSize',13);
yyaxis right;
ylabel('Fluor ((\DeltaF/F)^2/Hz)','FontSize',13);


%% power map plots

powerMap = {};

% generate a different plot for each frequency
for ind=1:length(fRange)
    
    currentMap = figure;
    sgtitle([currentTrialName ', ' num2str(fRange(ind,1)) ' - ' num2str(fRange(ind,2)) 'Hz Power Map']);
    freqRange = [fRange(ind,1) fRange(ind,2)];
    
    % iterate through each species
    for ind2=1:length(speciesList)       
        subplot(2,2,ind2); % adapt this for varying number of species 
        bandFreq = runFreq{ind2} >= freqRange(1) & runFreq{ind2} <= freqRange(2);
        spectraLog10 = log10(runSpectra{ind2});
        spectraLogBand = spectraLog10(:,:,bandFreq);
        meanSpectraLogBand = mean(spectraLogBand,3);
        imagesc(meanSpectraLogBand,'AlphaData',meanMask); % plot figure
        
        % adjust visuals of the final plot
        cb = colorbar();
        axis(gca,'square');
        set(gca,'Visible','off');
        colormap jet;
        titleObj = title(speciesList(ind2),'FontSize',13);
        set(titleObj,'Visible','on');
        % different label for gcamp6
        if contains(speciesList(ind2), 'Fluor')
            ylabelObj = ylabel(cb,'log10 ((\DeltaF/F)^2)','FontSize',13);
        else
            ylabelObj = ylabel(cb,'log10 (M^2)','FontSize',13);
        end
        set(ylabelObj,'Visible','on');
    end
    
    powerMap = [powerMap, currentMap];
    
end
end
