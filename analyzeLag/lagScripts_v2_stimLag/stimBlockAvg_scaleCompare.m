%% load data
% load asher data
disp('loading Asher young data');
tic;
allYoungMice = ["181116-1" "181116-8"];
allStimLagData = [];

% load asher data
for ind = 1:length(allYoungMice)
    for run = 1:4
        currRunLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagData\stimResponseDat\'...
            char(allYoungMice(ind)) '-week0-stim' num2str(run) '-stimLagDat.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allYoungMice(ind)) '-week0-fc' num2str(run) ' stimdat']);
            currRun = load(currRunLoc);
            allStimLagData = [allStimLagData currRun];
        end
    end
end

% load bauer data
disp('loading Bauer young data');
allYoungMiceB = ["181116-1" "181116-8"];
scale = '1_log(10)';
allStimLagDataB = [];


for ind = 1:length(allYoungMiceB)
    for run = 1:4
        currRunLoc = ['D:\ProcessedData\TestData\181116\scale' scale '\stimLagDataBauer\stimResponseDat\'...
            char(allYoungMiceB(ind)) '-week0-stim' num2str(run) '-stimLagDat_GSR.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allYoungMiceB(ind)) '-week0-fc' num2str(run) ' stimdat']);
            currRun = load(currRunLoc);
            allStimLagDataB = [allStimLagDataB currRun];
        end
    end
end
toc;

disp('done 1');

%% process data
% asher
disp('process asher');
blockTimeHbAll = [];
blockTimeFluorAll = [];
ttraceHbAll = [];
ttraceFluorAll = [];
rangeTime = 10;
fs = 16.8;

for ind = 1:length(allStimLagData)
    blockTimeHbAll = cat(3,blockTimeHbAll,allStimLagData(ind).blockTimeHb);
    blockTimeFluorAll = cat(3,blockTimeFluorAll,allStimLagData(ind).blockTimeFluor);
    ttraceHbAll = cat(3,ttraceHbAll,allStimLagData(ind).ttraceHb);
    ttraceFluorAll = cat(3,ttraceFluorAll,allStimLagData(ind).ttraceFluor);
end

% bauer
disp('process bauer');
lagTimeAllB = [];
blockTimeHbAllB = [];
blockTimeFluorAllB = [];
ttraceHbAllB = [];
ttraceFluorAllB = [];
rangeTime = 10;
fs = 16.8;

for ind = 1:length(allStimLagDataB)
    blockTimeHbAllB = cat(3,blockTimeHbAllB,allStimLagDataB(ind).blockTimeHb);
    blockTimeFluorAllB = cat(3,blockTimeFluorAllB,allStimLagDataB(ind).blockTimeFluor);
    ttraceHbAllB = cat(3,ttraceHbAllB,allStimLagDataB(ind).ttraceHb);
    ttraceFluorAllB = cat(3,ttraceFluorAllB,allStimLagDataB(ind).ttraceFluor);
end

disp('done 2');

%% compute data method 2 
paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

% asher
avgBlockTimeHbAll = nanmean(blockTimeHbAll,3);
avgBlockTimeFluorAll = nanmean(blockTimeHbAll,3);
avgTtraceHbAll = nanmean(ttraceHbAll,3);
avgTtraceFluorAll = nanmean(ttraceFluorAll,3);

% bauer
avgBlockTimeHbAllB = nanmean(blockTimeHbAllB,3);
avgBlockTimeFluorAllB = nanmean(blockTimeHbAllB,3);
avgTtraceHbAllB = nanmean(ttraceHbAllB,3);
avgTtraceFluorAllB = nanmean(ttraceFluorAllB,3);

disp('done 3');

%% plot fluor map

% plot timetrace
timeTraceFigFluor = figure(2);
set(timeTraceFigFluor,'Position',[100 100 800 425]);
first_color = [0 0 1]; % asher
second_color = [0 0.5 .5]; % bauer   
plot(avgBlockTimeFluorAll,avgTtraceFluorAll, 'color', first_color);
set(gca,'FontSize',12);
title('avgTimeTrace, Fluor');
xlabel('Time (s)');
ylabel('GCaMP \Delta F/F');
hold on;
plot(avgBlockTimeFluorAllB,avgTtraceFluorAllB, 'color', second_color);
ylim([-3e-3 6e-3]);
legend('Asher', 'Bauer');
set(figure(2),'color','w');



