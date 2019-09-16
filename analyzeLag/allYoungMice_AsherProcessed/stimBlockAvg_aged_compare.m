%% load data
% load asher data
disp('loading Asher aged data');
tic;
allAgedMice = ["180918-442" "180918-443" "180918-446" "180918-447" "180918-578"];
% allAgedMice = ["180917-422" "180917-424" "180917-425" "180917-426" "180917-427" "180917-450"...
%     "180917-452" "180917-459" "180917-461" "180918-307" "180918-309" "180918-421"...
%     "180918-442" "180918-443" "180918-446" "180918-447" "180918-578"];
allStimLagData = [];
allPeakHbData = [];

% load asher data
for ind = 1:length(allAgedMice)
    for run = 1:4
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagData\stimResponseDat\'...
            char(allAgedMice(ind)) '-week0-stim' num2str(run) '-stimLagDat.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allAgedMice(ind)) '-week0-fc' num2str(run) ' stimdat']);
            currRun = load(currRunLoc);
            allStimLagData = [allStimLagData currRun];
        end
        
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagData\peakHbDat\'...
            char(allAgedMice(ind)) '-week0-stim' num2str(run) '-peakHb_GSR_dat.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allAgedMice(ind)) '-week0-fc' num2str(run) ' peakhbdat']);
            currRun = load(currRunLoc);
            allPeakHbData = [allPeakHbData currRun];
        end
        
    end
end

% load bauer data
disp('loading Bauer aged data');
allAgedMiceB = ["180918-442" "180918-443" "180918-446" "180918-447" "180918-578"];
allStimLagDataB = [];
allPeakHbDataB = [];

for ind = 1:length(allAgedMiceB)
    for run = 1:4
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\stimResponseDat\'...
            char(allAgedMiceB(ind)) '-week0-stim' num2str(run) '-stimLagDat.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allAgedMiceB(ind)) '-week0-fc' num2str(run) ' stimdat']);
            currRun = load(currRunLoc);
            allStimLagDataB = [allStimLagDataB currRun];
        end
        
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagDataBauer\peakHbDat\'...
            char(allAgedMiceB(ind)) '-week0-stim' num2str(run) '-peakHb_GSR.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allAgedMiceB(ind)) '-week0-fc' num2str(run) ' peakhbdat']);
            currRun = load(currRunLoc);
            allPeakHbDataB = [allPeakHbDataB currRun];
        end
        
    end
end
toc;

disp('done 1');

%% process data
% asher
disp('process asher');
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

% bauer
disp('process bauer');
maxCorrAllB = [];
maxLagAllB = [];
corrAllB = [];
lagTimeAllB = [];
blockTimeHbAllB = [];
blockTimeFluorAllB = [];
ttraceHbAllB = [];
ttraceFluorAllB = [];
peakHbMapAllB = [];
avgTTraceMaskB = 1;
rangeTime = 10;
fs = 16.8;

for ind = 1:length(allStimLagDataB)
    maxCorrAllB = cat(2,maxCorrAllB,allStimLagDataB(ind).maxCorr);
    maxLagAllB = cat(2,maxLagAllB,allStimLagDataB(ind).maxLag);
    blockTimeHbAllB = cat(3,blockTimeHbAllB,allStimLagDataB(ind).blockTimeHb);
    blockTimeFluorAllB = cat(3,blockTimeFluorAllB,allStimLagDataB(ind).blockTimeFluor);
    ttraceHbAllB = cat(3,ttraceHbAllB,allStimLagDataB(ind).ttraceHb);
    ttraceFluorAllB = cat(3,ttraceFluorAllB,allStimLagDataB(ind).ttraceFluor);
    avgTTraceMaskB = avgTTraceMaskB.*allStimLagDataB(ind).ttraceMask;
    corrAllB = cat(3,corrAllB,allStimLagDataB(ind).corr);
    lagTimeAllB = cat(3,lagTimeAllB,allStimLagDataB(ind).lagTime);
    peakHbMapAllB = cat(3,peakHbMapAllB,allPeakHbDataB(ind).peakHbMap);
end

disp('done 2');

%% compute data for map

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

% asher
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

% bauer
avgBlockTimeHbAllB = nanmean(blockTimeHbAllB,3);
avgBlockTimeFluorAllB = nanmean(blockTimeHbAllB,3);
avgTtraceHbAllB = nanmean(ttraceHbAllB,3);
avgTtraceFluorAllB = nanmean(ttraceFluorAllB,3);
avgPeakHbMapAllB = nanmean(peakHbMapAllB,3);

% scale factor
avgTtraceHbAllB = 0.4008 * avgTtraceHbAllB;
avgTtraceFluorAllB = 0.7174 * avgTtraceFluorAllB;

[corrB, lagTimeB] = xcorr(avgTtraceHbAllB,avgTtraceFluorAllB,rangeTime*fs, 'normalized');
lagTimeB = lagTimeB/fs;
[maxCorrB, maxIndB] = max(corrB);
maxLagB = (lagTime(maxIndB));
peakMapLimB = [-1e-6 1.2e-6];

disp('done 3');

%% plot hb map

% plot timetrace
timeTraceFig = figure(1);
set(timeTraceFig,'Position',[100 100 800 425]);
first_color = [1 0 0]; % asher
second_color = [0 0.6 0]; % bauer
plot(avgBlockTimeHbAll,avgTtraceHbAll/1000, 'color', first_color);
set(gca,'FontSize',12);
title('Aged, avgTimeTrace, Hb');
xlabel('Time (s)');
ylabel('\Delta Hb');
% ylim([-1e-6 1.2e-6]);
hold on;
plot(avgBlockTimeHbAllB,avgTtraceHbAllB, 'color', second_color);
% yyaxis right
% plot(avgBlockTimeFluorAll,avgTtraceFluorAll, 'color', right_color);
% ylabel('GCaMP \Delta F/F');
% ylim([-5e-3 6e-3]);
legend('Asher', 'Bauer');
% set(gca,'YColor',second_color);

%% plot fluor map

% plot timetrace
timeTraceFigFluor = figure(2);
set(timeTraceFigFluor,'Position',[100 100 800 425]);
first_color = [1 0 0]; % asher
second_color = [0 0.6 0]; % bauer  
plot(avgBlockTimeFluorAll,avgTtraceFluorAll, 'color', first_color);
set(gca,'FontSize',12);
title('Aged, avgTimeTrace, Fluor');
xlabel('Time (s)');
ylabel('GCaMP \Delta F/F');
% ylim([-1e-6 1.2e-6]);
hold on;
plot(avgBlockTimeFluorAllB,avgTtraceFluorAllB, 'color', second_color);
% yyaxis right
% plot(avgBlockTimeFluorAll,avgTtraceFluorAll, 'color', right_color);
% ylabel('GCaMP \Delta F/F');
% ylim([-5e-3 6e-3]);
legend('Asher', 'Bauer');
% set(gca,'YColor',second_color);



