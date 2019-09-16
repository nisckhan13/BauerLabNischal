%% load data

disp('loading all young data');
tic;
allYoungMice = ["181116-1" "181116-2" "181116-4" "181116-6" "181116-7" "181116-8"];
allStimLagDataAged = [];
allPeakHbDataAged = [];

for ind = 1:length(allYoungMice)
    for run = 1:4
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagData\stimResponseDat\'...
            char(allYoungMice(ind)) '-week0-stim' num2str(run) '-stimLagDat.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allYoungMice(ind)) '-week0-fc' num2str(run) ' stimdat']);
            currRun = load(currRunLoc);
            allStimLagDataAged = [allStimLagDataAged currRun];
        end
        
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagData\peakHbDat\'...
            char(allYoungMice(ind)) '-week0-stim' num2str(run) '-peakHb_GSR_dat.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allYoungMice(ind)) '-week0-fc' num2str(run) ' peakhbdat']);
            currRun = load(currRunLoc);
            allPeakHbDataAged = [allPeakHbDataAged currRun];
        end
        
    end
end
toc;

%% process data
blockTimeHbAll = [];
blockTimeFluorAll = [];
ttraceHbAll = [];
ttraceFluorAll = [];
peakHbMapAll = [];
avgTTraceMask = 1;
rangeTime = 10;
fs = 16.8;

for ind = 1:length(allStimLagDataAged)
    blockTimeHbAll = cat(3,blockTimeHbAll,allStimLagDataAged(ind).blockTimeHb);
    blockTimeFluorAll = cat(3,blockTimeFluorAll,allStimLagDataAged(ind).blockTimeFluor);
    ttraceHbAll = cat(3,ttraceHbAll,allStimLagDataAged(ind).ttraceHb);
    ttraceFluorAll = cat(3,ttraceFluorAll,allStimLagDataAged(ind).ttraceFluor);
    avgTTraceMask = avgTTraceMask.*allStimLagDataAged(ind).ttraceMask;
    peakHbMapAll = cat(3,peakHbMapAll,allPeakHbDataAged(ind).peakHbMap);
end

disp('done 2');

%% avg data

avgBlockTimeHbAll = nanmean(blockTimeHbAll,3);
avgBlockTimeFluorAll = nanmean(blockTimeHbAll,3);
avgTtraceHbAll = nanmean(ttraceHbAll,3);
avgTtraceFluorAll = nanmean(ttraceFluorAll,3);

%% compute 10% lag
% For example, in the Hb trace, find the peak value and then find when the Hb curve rises to 10% of 
% that peak. Do the same for the calcium signal using the first spike. I bet the time delay between 
% the 10% rise in calcium vs 10% rise in Hb are very close between the new and old code

% find peak Hb value
[hbPeak, hbPeakInd] = max(avgTtraceHbAll);
hbPeak10Calc = 0.1 * hbPeak;
splitHb = avgTtraceHbAll(1:hbPeakInd);
splitHb(splitHb>hbPeak10Calc) = 0;
[hbPeak10, hbPeak10ind] = max(splitHb);
hbPeak10Time = avgBlockTimeHbAll(hbPeak10ind);

% find peak of first Fluor spike
[fluorPeaks, fluorInds] = findpeaks(avgTtraceFluorAll(81:110));
fluorPeak10Calc = 0.1 * fluorPeaks(1);
splitFluor = avgTtraceFluorAll(80:(fluorInds(1)+80));
splitFluor = abs(splitFluor - fluorPeak10Calc);
[fluorPeak10, fluorPeak10ind] = min(splitFluor);
fluorPeak10Time = avgBlockTimeFluorAll(79+fluorPeak10ind);

lag10Per = hbPeak10Time - fluorPeak10Time;

%% plot timetrace
timeTraceFig = figure(2);
set(timeTraceFig,'Position',[100 100 750 400]);
left_color = [0 0.6 0]; % green
right_color = [0 0 1]; % blue  
yyaxis left;
plot(avgBlockTimeHbAll,avgTtraceHbAll, 'color', left_color);
hold on;
set(gca,'FontSize',12);
title('Asher Young, avgTimeTrace, 10% Peak');
xlabel('Time (s)');
ylabel('\Delta Hb');
ylim([-5e-4 6e-4]);
set(gca,'YColor',left_color)
yyaxis right;
plot(avgBlockTimeFluorAll,avgTtraceFluorAll, 'color', right_color);
ylabel('GCaMP \Delta F/F');
ylim([-5e-3 6e-3]);
yyaxis left;
plot(hbPeak10Time,hbPeak10, 'g*', 'MarkerSize', 10);
yyaxis right;
plot(fluorPeak10Time,fluorPeak10, 'b*','MarkerSize', 10)
legend('hbt','hbt10','fluor','fluor10');

% xlim([maxLag 20]);
set(gca,'YColor',right_color);
