function powerMap = plotPowerMap(fRange, runFreq, runSpectra, meanMask, speciesList, currentTrialName)

powerMap = {};

for ind=1:length(fRange)
    
    currentMap = figure;
    sgtitle([currentTrialName ', ' num2str(fRange(ind,1)) ' - ' num2str(fRange(ind,2)) 'Hz Power Map']);
    freqRange = [fRange(ind,1) fRange(ind,2)];
        
    for ind2=1:length(speciesList)       
        subplot(2,2,ind2); % adapt this for varying number of species 
        bandFreq = runFreq{ind2} >= freqRange(1) & runFreq{ind2} <= freqRange(2);
        spectraLog10 = log10(runSpectra{ind2});
        spectraLogBand = spectraLog10(:,:,bandFreq);
        meanSpectraLogBand = mean(spectraLogBand,3);
        imagesc(meanSpectraLogBand,'AlphaData',meanMask); % plot figure
        
        cb = colorbar();
        axis(gca,'square');
        set(gca,'Visible','off');
        colormap jet;
        titleObj = title(speciesList(ind2),'FontSize',13);
        set(titleObj,'Visible','on');
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