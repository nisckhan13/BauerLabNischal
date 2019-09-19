function stimBlockAvg_aged_bauer(dsInput, dateDSInput, useGSR)    
%% input parameters
ds = dsInput; % which mice dataset
dateDS = dateDSInput; % which date

%% load data
disp(['----- LOADING ' dateDS '-' ds '-week0 -----']);
tic;

maskData = load(['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\' dateDS '-' ds '-week0-LandmarksAndMask.mat']);
bauerData1F = load(['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\' dateDS '-' ds '-week0-stim1-dataFluor.mat']);
bauerData1H = load(['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\' dateDS '-' ds '-week0-stim1-dataHb.mat']);
bauerData2F = load(['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\' dateDS '-' ds '-week0-stim2-dataFluor.mat']);
bauerData2H = load(['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\' dateDS '-' ds '-week0-stim2-dataHb.mat']);
bauerData3F = load(['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\' dateDS '-' ds '-week0-stim3-dataFluor.mat']);
bauerData3H = load(['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\' dateDS '-' ds '-week0-stim3-dataHb.mat']);

data4LocF = ['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\' dateDS '-' ds '-week0-stim4-dataFluor.mat'];
data4LocH = ['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\' dateDS '-' ds '-week0-stim4-dataHb.mat'];

if exist(data4LocF, 'file')
    disp('run 4 found');
    bauerData4F = load(data4LocF);
    bauerData4H = load(data4LocH);
    bauerDataF = [bauerData1F bauerData2F bauerData3F bauerData4F];
    bauerDataH = [bauerData1H bauerData2H bauerData3H bauerData4H];
else
    disp('run 4 NOT found');
    bauerDataF = [bauerData1F bauerData2F bauerData3F];
    bauerDataH = [bauerData1H bauerData2H bauerData3H];
end
toc;

%% after loading

trialMask = maskData.xform_isbrain;
fs = 16.8;
blockLenTime = 20;
baselineInd = 1:(floor(fs*5)-1);
time = 0:0.0595:299.7620;

timeRangePeakRegion = 9:0.0595:11;
indRangePeakRegion = round(timeRangePeakRegion * 16.8);

peakThreshold = 0.5;

peakMapLim = [-5e-4 5e-4];
findPeakMask = zeros(128,128);
findPeakMask(45:75,25:50) = 1;
radius = 7;
matSize = [128 128];

for ind=1:length(bauerDataF)
    tic;
    disp(['--- Stim Run ' num2str(ind) ' ---']);
    dataHb = squeeze(sum(bauerDataH(ind).xform_datahb,3));
    dataHbTemp = bauerDataH(ind).xform_datahb;
    dataHbO = squeeze(dataHbTemp(:,:,1,:));
    dataHbR = squeeze(dataHbTemp(:,:,2,:));
    dataFluor = squeeze(bauerDataF(ind).xform_datafluorCorr);

    % gsr
    if (useGSR)
        disp('GSR...');
        dataHb = mouse.process.gsr(dataHb, trialMask);
        dataHbO = mouse.process.gsr(dataHbO, trialMask);
        dataHbR = mouse.process.gsr(dataHbR, trialMask);
        dataFluor = mouse.process.gsr(dataFluor, trialMask);
    end

    % compute block avg
    disp('Block avg...')
    [blockDataHb, blockTimeHb] = mouse.expSpecific.blockAvg(dataHb,time,blockLenTime,fs*blockLenTime);
    blockDataHb = bsxfun(@minus,blockDataHb,nanmean(blockDataHb(:,:,baselineInd),3));

    [blockDataFluor, blockTimeFluor] = mouse.expSpecific.blockAvg(dataFluor,time,blockLenTime,...
        fs*blockLenTime);
    blockDataFluor = bsxfun(@minus,blockDataFluor,nanmean(blockDataFluor(:,:,baselineInd),3)); 
    
    [blockDataHbO, blockTimeHbO] = mouse.expSpecific.blockAvg(dataHbO,time,blockLenTime,fs*blockLenTime);
    blockDataHbO = bsxfun(@minus,blockDataHbO,nanmean(blockDataHbO(:,:,baselineInd),3));
    
    [blockDataHbR, blockTimeHbR] = mouse.expSpecific.blockAvg(dataHbR,time,blockLenTime,fs*blockLenTime);
    blockDataHbR = bsxfun(@minus,blockDataHbR,nanmean(blockDataHbR(:,:,baselineInd),3));

    % generate peak map  
    disp('Generating peak map...');
    peakHbMap = nanmean(blockDataHb(:,:,indRangePeakRegion),3);
    peakHbMapMasked = peakHbMap.*findPeakMask;
    saveFigLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\peakHbMapFigs\'...
        dateDS '-' ds '-week0-stim' num2str(ind) '-peakHb_GSR.fig'];
    savePeakDataLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\peakHbDat\'...
        dateDS '-' ds '-week0-stim' num2str(ind) '-peakHb_GSR.mat'];
    if exist(saveFigLoc, 'file')
        disp('Found saved peak map figure');
    else
        peakHbMapFig = figure(1);
        imagesc(peakHbMap,'AlphaData', trialMask);
        caxis(peakMapLim);
        set(gca,'Visible','off');
        colorbar; colormap('jet');
        axis(gca,'square');
        savefig(peakHbMapFig,saveFigLoc);
        save(savePeakDataLoc, 'peakHbMap','blockDataHb');
        close(peakHbMapFig);
    end

    % display peak hb map to base ROI off of
    saveMaskLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\ttraceMasks\'...
        dateDS '-' ds '-week0-stim' num2str(ind) '-ttraceMask_GSR.mat'];
    if exist(saveMaskLoc, 'file')
        disp('Found saved ttraceMask');
        ttraceMask = load(saveMaskLoc);
        ttraceMask = ttraceMask.ttraceMask;
    else
        disp('Computing time trace over peak region...');
        [~,indMax] = max(peakHbMapMasked,[], 'all', 'linear');
        [centerY,centerX] = mouse.math.ind2D(indMax,matSize);
        [nVy,nVx] = size(peakHbMap);
        ttraceMask = false(nVy, nVx);

        for x = 1:nVx
            for y = 1:nVy
                if pdist([centerX,centerY;x,y])<= radius
                    ttraceMask(y,x) = true;
                end
            end
        end

        thresholdVal = peakThreshold*max(max(peakHbMap.*ttraceMask));

        for x = 1:nVx
            for y = 1:nVy
                if peakHbMap(y,x)<thresholdVal
                    ttraceMask(y,x) = false;
                end
            end
        end

        save(saveMaskLoc, 'ttraceMask');
    end

    % save the activation region mask figure
    disp('Saving data and generating figures...');
    actvReg = figure(2);
    sgtitle([dateDS '-' ds '-week0-actvRegImg']);
    subplot(2,2,ind);
    % peak map fig
    imagesc(peakHbMap,'AlphaData', trialMask);
    caxis(peakMapLim);
    set(gca,'Visible','off');
    colorbar; colormap('jet');
    axis(gca,'square');
    hold on;
    imagesc(ones(128)*-1,'AlphaData',ttraceMask*0.5);
    titleObj = title(['stim' num2str(ind)]);
    set(titleObj,'Visible','on');

    % Average points in ROI and output linear time trace
    blockDataFluorMask = blockDataFluor.*ttraceMask;
    blockDataFluorMask(blockDataFluorMask==0) = NaN;
    ttraceFluor = squeeze(nanmean(blockDataFluorMask,[1 2]));

    blockDataHbMask = blockDataHb.*ttraceMask;
    blockDataHbMask(blockDataHbMask==0) = NaN;
    ttraceHb = squeeze(nanmean(blockDataHbMask,[1 2]));
    
    blockDataHbOMask = blockDataHbO.*ttraceMask;
    blockDataHbOMask(blockDataHbOMask==0) = NaN;
    ttraceHbO = squeeze(nanmean(blockDataHbOMask,[1 2]));
    
    blockDataHbRMask = blockDataHbR.*ttraceMask;
    blockDataHbRMask(blockDataHbRMask==0) = NaN;
    ttraceHbR = squeeze(nanmean(blockDataHbRMask,[1 2]));

    rangeTime = 10;
    [corr, lagTime] = xcorr(ttraceHb, ttraceFluor, rangeTime*fs, 'normalized');
    lagTime = lagTime/fs;
    [maxCorr, maxInd] = max(corr);
    maxLag = lagTime(maxInd);

    lagfigStim = figure(3);
    sgtitle([dateDS '-' ds '-week0-lag-corr']);
    set(lagfigStim,'Position',[100 100 800 800]);
    subplot(2,2,ind);
    plot(lagTime, corr);
    set(gca,'FontSize',12)
    hold on;
    plot(maxLag, maxCorr, 'r.', 'MarkerSize', 20);
    xlabel('LagTime (s)');
    ylabel('Correlation');
    title(['stim' num2str(ind) ' || lag: ' sprintf('%.2f',maxLag) ...
        's corr: ' sprintf('%.2f',maxCorr)]);
    ylim([0 1]);
    xlim([-rangeTime rangeTime]);

    % save data
    saveDatLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\'...
        dateDS '-' ds '-week0-stim' num2str(ind) '-stimLagDat_GSR.mat'];
    save(saveDatLoc, 'ttraceFluor', 'ttraceHb', 'blockTimeHb', 'blockTimeFluor', 'ttraceMask',...
        'corr', 'lagTime', 'maxCorr', 'maxLag', 'ttraceHbO', 'ttraceHbR', 'blockTimeHbO', 'blockTimeHbR');

    stimfig = figure(4);
    sgtitle([dateDS '-' ds '-week0-TimeTrace']);
    set(stimfig,'Position',[100 100 500 900]);
    subplot(length(bauerDataF),1,ind); 
    left_color = [0 0.6 0]; % green
    right_color = [0 0 1]; % blue  
    yyaxis left;
    plot(blockTimeHb,ttraceHb, 'color', left_color);
    title(['stim' num2str(ind)]);
    xlabel('Time(s)');
    ylabel('Hb');
    ylim([-4e-4 8e-4]);
    set(gca,'YColor',left_color)
    hold on;
    yyaxis right
    plot(blockTimeFluor,ttraceFluor, 'color', right_color);
    ylabel('Fluor');
    ylim([-4e-3 8e-3]);
    legend('hbt', 'fluor');
    set(gca,'YColor',right_color);


end

disp('Saving final figures...');
saveRegFig = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\'...
        dateDS '-' ds '-week0-actvRegImg_GSR'];
saveas(actvReg, [saveRegFig '.png']);

close(actvReg);

saveLagFig = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\'...
        dateDS '-' ds '-week0-stim-LagFig_GSR'];
saveas(lagfigStim, [saveLagFig '.png']);

close(lagfigStim);

saveStimFig = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\'...
    dateDS '-' ds '-week0-stim-timeTrace_GSR'];
saveas(stimfig, [saveStimFig '.png']);

close(stimfig);
toc;
end
