%% load data

% n = 17

disp('loading all aged data');
tic;
allAgedMice = ["180918-442" "180918-443" "180918-446" "180918-447" "180918-578"];
% allAgedMice = ["180917-422" "180917-424" "180917-425" "180917-426" "180917-427" "180917-450"...
%     "180917-452" "180917-459" "180917-461" "180918-307" "180918-309" "180918-421"...
%     "180918-442" "180918-443" "180918-446" "180918-447" "180918-578"];
% allAgedMice = ["180917-422" "180917-424" "180917-425" "180917-426" "180917-427" "180917-450"...
%     "180917-452" "180917-459" "180917-461" "180918-309"...
%     "180918-442" "180918-446" "180918-447"];
allStimLagDataAged = [];
allPeakHbDataAged = [];

for ind = 1:length(allAgedMice)
    for run = 1:4
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagData\stimResponseDat\'...
            char(allAgedMice(ind)) '-week0-stim' num2str(run) '-stimLagDat.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allAgedMice(ind)) '-week0-fc' num2str(run) ' stimdat']);
            currRun = load(currRunLoc);
            allStimLagDataAged = [allStimLagDataAged currRun];
        end
        
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagData\peakHbDat\'...
            char(allAgedMice(ind)) '-week0-stim' num2str(run) '-peakHb_GSR_dat.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allAgedMice(ind)) '-week0-fc' num2str(run) ' peakhbdat']);
            currRun = load(currRunLoc);
            allPeakHbDataAged = [allPeakHbDataAged currRun];
        end
        
    end
end
toc;

% n = 14;

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

for ind = 1:length(allStimLagDataAged)
    maxCorrAll = cat(2,maxCorrAll,allStimLagDataAged(ind).maxCorr);
    maxLagAll = cat(2,maxLagAll,allStimLagDataAged(ind).maxLag);
    blockTimeHbAll = cat(3,blockTimeHbAll,allStimLagDataAged(ind).blockTimeHb);
    blockTimeFluorAll = cat(3,blockTimeFluorAll,allStimLagDataAged(ind).blockTimeFluor);
    ttraceHbAll = cat(3,ttraceHbAll,allStimLagDataAged(ind).ttraceHb);
    ttraceFluorAll = cat(3,ttraceFluorAll,allStimLagDataAged(ind).ttraceFluor);
    avgTTraceMask = avgTTraceMask.*allStimLagDataAged(ind).ttraceMask;
    corrAll = cat(3,corrAll,allStimLagDataAged(ind).corr);
    lagTimeAll = cat(3,lagTimeAll,allStimLagDataAged(ind).lagTime);
    peakHbMapAll = cat(3,peakHbMapAll,allPeakHbDataAged(ind).peakHbMap);
end

disp('done 2');

%% method 1 - avg data then find lag

avgBlockTimeHbAll = nanmean(blockTimeHbAll,3);
avgBlockTimeFluorAll = nanmean(blockTimeHbAll,3);
avgTtraceHbAll = nanmean(ttraceHbAll,3);
avgTtraceFluorAll = nanmean(ttraceFluorAll,3);
avgPeakHbMapAll = nanmean(peakHbMapAll,3);
[corr, lagTime] = xcorr(avgTtraceHbAll,avgTtraceFluorAll,rangeTime*fs, 'normalized');
lagTime = lagTime/fs;
[maxCorr, maxInd] = max(corr);
maxLag = (lagTime(maxInd));
peakMapLim = [-5e-4 5e-4];

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

disp('done data');

%% plot lag
lagCorrFig = figure(1);
set(lagCorrFig,'Position',[100 100 500 400]);
plot(lagTime, corr);
set(gca,'FontSize',11)
hold on;
plot(maxLag, maxCorr, 'r.', 'MarkerSize', 20);
xlabel('LagTime (s)');
ylabel('Correlation');
title(['lagCorr 5 mice Aged || lag: ' sprintf('%.2f',maxLag) ...
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
title('All Aged, avgTimeTrace');
xlabel('Time (s)');
ylabel('\Delta Hb');
ylim([-5e-4 6e-4]);
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
titleObj = title('activation region aged mice avg, HbT');
set(titleObj,'Visible','on');

%% save
saveLagFig = 'D:\ProcessedData\AsherLag\stimResponse\stimLagData\stimResponseDat\avgFigures\agedLag';
saveas(lagCorrFig, [saveLagFig '.png']);
close(lagCorrFig);

saveTTFig = 'D:\ProcessedData\AsherLag\stimResponse\stimLagData\stimResponseDat\avgFigures\agedTT';
saveas(timeTraceFig, [saveTTFig '.png']);
close(timeTraceFig);

savePeakFig = 'D:\ProcessedData\AsherLag\stimResponse\stimLagData\stimResponseDat\avgFigures\agedPeak';
saveas(actPeakFig, [savePeakFig '.png']);
close(actPeakFig);

disp('done 3');

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



