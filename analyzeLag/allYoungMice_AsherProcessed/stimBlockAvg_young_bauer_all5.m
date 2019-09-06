%% load data

% n = 16

disp('loading 5 young data');
tic;
allYoungMice = ["181116-1" "181116-2" "181116-4" "181116-6" "181116-7" "181116-8"];
% allYoungMice = ["181116-1" "181116-2" "181116-4" "181116-6" "181116-7" "181116-8"...
%     "181116-9" "181116-10" "181115-2046" "181115-2047" "181115-2048" "181115-2049"...
%     "181115-2053" "181115-2055"];
allStimLagData = [];
allPeakHbData = [];

for ind = 1:length(allYoungMice)
    for run = 1:4
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\'...
            char(allYoungMice(ind)) '-week0-stim' num2str(run) '-stimLagDat.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allYoungMice(ind)) '-week0-fc' num2str(run) ' stimdat']);
            currRun = load(currRunLoc);
            allStimLagData = [allStimLagData currRun];
        end
        
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\peakHbDat\'...
            char(allYoungMice(ind)) '-week0-stim' num2str(run) '-peakHb_GSR.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allYoungMice(ind)) '-week0-fc' num2str(run) ' peakhbdat']);
            currRun = load(currRunLoc);
            allPeakHbData = [allPeakHbData currRun];
        end
        
    end
end
toc;

% n = 5;

%% process data
% process data
maxCorrAll = [];
maxLagAll = [];
corrAll = [];
lagTimeAll = [];
blockTimeHbAll = [];
blockTimeFluorAll = [];
ttraceHbAll = [];
ttraceFluorAll = [];
peakHbMapAll = [];
avgTTraceMask = 1;
rangeTime = 10;
fs = 16.8;

for ind = 1:length(allStimLagData)
    maxCorrAll = cat(2,maxCorrAll,allStimLagData(ind).maxCorr);
    maxLagAll = cat(2,maxLagAll,allStimLagData(ind).maxLag);
    blockTimeHbAll = cat(3,blockTimeHbAll,allStimLagData(ind).blockTimeHb);
    blockTimeFluorAll = cat(3,blockTimeFluorAll,allStimLagData(ind).blockTimeFluor);
    ttraceHbAll = cat(3,ttraceHbAll,allStimLagData(ind).ttraceHb);
    ttraceFluorAll = cat(3,ttraceFluorAll,allStimLagData(ind).ttraceFluor);
    avgTTraceMask = avgTTraceMask.*allStimLagData(ind).ttraceMask;
    corrAll = cat(3,corrAll,allStimLagData(ind).corr);
    lagTimeAll = cat(3,lagTimeAll,allStimLagData(ind).lagTime);
    peakHbMapAll = cat(3,peakHbMapAll,allPeakHbData(ind).peakHbMap);
end

disp('done 2');

%% method 1 - avg data then find lag

avgBlockTimeHbAll = nanmean(blockTimeHbAll,3);
avgBlockTimeFluorAll = nanmean(blockTimeHbAll,3);
avgTtraceHbAll = nanmean(ttraceHbAll,3);
avgTtraceFluorAll = nanmean(ttraceFluorAll,3);
avgPeakHbMapAll = nanmean(peakHbMapAll,3);

% scale factor
avgTtraceHbAll = 0.41 * avgTtraceHbAll;
avgTtraceFluorAll = 0.76 * avgTtraceFluorAll;

[corr, lagTime] = xcorr(avgTtraceHbAll,avgTtraceFluorAll,rangeTime*fs, 'normalized');
lagTime = lagTime/fs;
[maxCorr, maxInd] = max(corr);
maxLag = (lagTime(maxInd));
peakMapLim = [-1e-6 1.2e-6];

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

disp('done calc');

%% plot lag
lagCorrFig = figure(1);
set(lagCorrFig,'Position',[100 100 500 400]);
plot(lagTime, corr);
set(gca,'FontSize',11)
hold on;
plot(maxLag, maxCorr, 'r.', 'MarkerSize', 20);
xlabel('LagTime (s)');
ylabel('Correlation');
title(['lagCorr All Young || lag: ' sprintf('%.2f',maxLag) ...
    's corr: ' sprintf('%.2f',maxCorr)]);
ylim([0 1]);
xlim([-rangeTime rangeTime]);

%% plot timetrace
timeTraceFig = figure(2);
set(timeTraceFig,'Position',[100 100 750 400]);
left_color = [0 0.6 0]; % green
right_color = [0 0 1]; % blue  
yyaxis left;
plot(avgBlockTimeHbAll,avgTtraceHbAll, 'color', left_color);
set(gca,'FontSize',11);
title('All Young, avgTimeTrace');
xlabel('Time (s)');
ylabel('\Delta Hb');
ylim([-1e-6 1.2e-6]);
set(gca,'YColor',left_color)
hold on;
yyaxis right
plot(avgBlockTimeFluorAll,avgTtraceFluorAll, 'color', right_color);
ylabel('GCaMP \Delta F/F');
ylim([-5e-3 6e-3]);
legend('hbt', 'fluor');
% xlim([maxLag 20]);
set(gca,'YColor',right_color);

%% plot activation peak
actPeakFig = figure(3);
imagesc(avgPeakHbMapAll,'AlphaData', meanMask);
caxis(peakMapLim);
set(gca,'Visible','off');
colorbar; colormap('jet');
axis(gca,'square');
titleObj = title('activation region young mice avg, HbT');
set(titleObj,'Visible','on');

%%
saveLagFig = 'D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\avgFigures\youngLag';
saveas(lagCorrFig, [saveLagFig '.png']);
close(lagCorrFig);

saveTTFig = 'D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\avgFigures\youngTT';
saveas(timeTraceFig, [saveTTFig '.png']);
close(timeTraceFig);

savePeakFig = 'D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\avgFigures\youngPeak';
saveas(actPeakFig, [savePeakFig '.png']);


% %% method 2 - avg lag
% 
% % calc avg
% avgMaxCorrAll = nanmean(maxCorrAll,2);
% avgMaxLagAll = nanmean(maxLagAll,2);
% avgCorrAll = nanmean(corrAll,3);
% avgLagTimeAll = nanmean(lagTimeAll,3);
% 
% % plot lag
% lagCorrFig = figure(4);
% set(lagCorrFig,'Position',[100 100 500 500]);
% plot(avgLagTimeAll, avgCorrAll);
% set(gca,'FontSize',12)
% hold on;
% plot(avgMaxLagAll, avgMaxCorrAll, 'r.', 'MarkerSize', 20);
% xlabel('LagTime (s)');
% ylabel('Correlation');
% title(['stimAvg All Young || lag: ' sprintf('%.2f',avgMaxLagAll) ...
%     's corr: ' sprintf('%.2f',avgMaxCorrAll)]);
% ylim([0 1]);
% xlim([-rangeTime rangeTime]);
% 
% % plot timetrace
% timeTraceFig = figure(5);
% set(timeTraceFig,'Position',[100 100 600 450]);
% left_color = [0 0.6 0]; % green
% right_color = [0 0 1]; % blue  
% yyaxis left;
% plot(nanmean(blockTimeHbAll,3),nanmean(ttraceHbAll,3), 'color', left_color);
% title('All Young, avgTimeTrace');
% xlabel('Time(s)');
% ylabel('Hb');
% ylim([-4e-4 8e-4]);
% set(gca,'YColor',left_color)
% hold on;
% yyaxis right
% plot(nanmean(blockTimeFluorAll,3),nanmean(ttraceFluorAll,3), 'color', right_color);
% ylabel('Fluor');
% ylim([-4e-3 8e-3]);
% legend('hbt', 'fluor');
% set(gca,'YColor',right_color);



