function findVariance(excelFile, excelRows)

excelRows(excelRows == 1) = [];

%% read excel file to get information about each mouse run
runsInfo = parseTiffRuns(excelFile,excelRows);

%% get the raw data

runInd = 0;
runNum = numel(runsInfo);
currentExcelRow = runsInfo(1).excelRow;
storeRawSpatialAvg = [];
storeRawStd = [];
storeRawStdPer = [];
storeRunName = [];

storeRawSpatialAvgCurrGroup = [];
storeRawStdCurrGroup = [];
storeRawStdPerCurrGroup = [];
storeRunNameCurrGroup = [];

storeRawSpatialAvgGroup = [];
storeRawStdGroup = [];
storeRawStdPerGroup = [];
storeRunNameGroup = [];

for runInfo = runsInfo % for each run
    runInd = runInd + 1;
    disp(['----- Trial ' num2str(runInd) '/' num2str(runNum) ' -----']);
    
    runName = [runInfo.recDate, '-', runInfo.mouseName, '-', runInfo.session,...
        num2str(runInfo.run)];
    saveFileVariance = [runInfo.saveFolder '\' runName '-variance.mat'];
    
    if exist(saveFileVariance, 'file')
        disp('Loading saved variance data file...');
        load(saveFileVariance, 'meanRawSpatialAvg', 'rawStd', 'rawStdPer', 'runName');
    else
        disp('Reading raw data...');
        t1 = tic;

        % instantiate VideosReader
        reader = mouse.read.VideosReader();
        reader.ReaderObject = mouse.read.TiffVideoReader; % which raw file reader should be used? (tiff, dat)
        reader.BinFactor = runInfo.binFactor;
        reader.ChNum = runInfo.numCh; % how many channels?
        reader.DarkFrameInd = runInfo.darkFramesInd; % which time frames are dark?
        reader.InvalidInd = runInfo.invalidFramesInd; % which time frames are invalid?
        reader.FreqIn = runInfo.samplingRate; % what is the sampling rate of raw data?
        reader.FreqOut = runInfo.samplingRate; % what should be the output sampling rate?
        [raw,rawTime] = reader.read(runInfo.rawFile); % read the files
        toc(t1);

        %% compute variance    
    
        disp('Calculating variance...');
        rawSpatialAvg = zeros(numel(raw),numel(rawTime));
        for ch = 1:numel(raw)
            rawSpatialAvg(ch,:) = squeeze(nanmean(nanmean(raw{ch},1),2));
        end
        
        % detrend the fluor channel
        disp('Detrend fluor...')
        
        sR = runInfo.samplingRate;
        rawDataFluor = double(rawSpatialAvg(1,:));
        rawDataFluor = mouse.process.temporalDetrend(rawDataFluor, sR);
        rawSpatialAvg(1,:) = rawDataFluor;
        
        % compute mean values
        meanRawSpatialAvg = mean(rawSpatialAvg,2);
        rawStd = std(rawSpatialAvg,[],2);
        rawStdPer = 100*rawStd./meanRawSpatialAvg;

        disp('Saving variance...');
        % save the variance data per run
        if ~exist(runInfo.saveFolder, 'dir')
            mkdir(runInfo.saveFolder)
        end
        save(saveFileVariance, 'meanRawSpatialAvg', 'rawStd', 'rawStdPer', 'runName', '-v7.3');
    end
    
    % check if current run is last one for mouse
    if runInd == numel(runsInfo)
        lastRunInMouse = true;
    elseif currentExcelRow ~= runsInfo(runInd+1).excelRow
        lastRunInMouse = true;
    else
        lastRunInMouse = false;
    end
        
    % average the variance across for all runs of each mouse
    if lastRunInMouse
        currRunName = split(runName, '-');
        currRunName = [currRunName{1} '-' currRunName{2}];
        disp(['Calcuating average for all runs of ' currRunName '...']);
        storeRawSpatialAvg = [storeRawSpatialAvg; meanRawSpatialAvg'];
        storeRawStd = [storeRawStd; rawStd'];
        storeRawStdPer = [storeRawStdPer; rawStdPer'];
        storeRunName = [storeRunName; runName];
        
        [~,numCh] = size(storeRawStd);
        avgRawSpatialAvg = [];
        avgRawStd = [];
        avgRawStdPer = [];
        for chInd = 1:numCh
            avgRawSpatialAvg = [avgRawSpatialAvg, mean(storeRawSpatialAvg(:,chInd))];
            avgRawStd = [avgRawStd, mean(storeRawStd(:,chInd))];
        end
        
        avgRawStdPer = [avgRawStdPer 100*avgRawStd./mean(avgRawSpatialAvg,2)];
        
        storeRawSpatialAvgCurrGroup = [storeRawSpatialAvgCurrGroup; avgRawSpatialAvg];
        storeRawStdCurrGroup = [storeRawStdCurrGroup; avgRawStd];
        storeRawStdPerCurrGroup = [storeRawStdPerCurrGroup; avgRawStdPer];
        mouseName = strsplit(storeRunName(1,:),'-');
        storeRunNameCurrGroup = [storeRunNameCurrGroup; [mouseName{1} '-' mouseName{2}]];
        
        storeRawSpatialAvg = [];
        storeRawStd = [];
        storeRawStdPer = [];
        storeRunName = [];
        
        if runInd ~= numel(runsInfo)
                currentExcelRow = runsInfo(runInd+1).excelRow;
        end
    else
        storeRawSpatialAvg = [storeRawSpatialAvg; meanRawSpatialAvg'];
        storeRawStd = [storeRawStd; rawStd'];
        storeRawStdPer = [storeRawStdPer; rawStdPer'];
        storeRunName = [storeRunName; runName];
    end
    %% Average and gather the data for the current group
    
    % Check to see if current excel row is last one for current group
    lastRunInGroup = false;
    if runInd == numel(runsInfo)
        lastRunInGroup = true;
    elseif convertCharsToStrings(runInfo.mouseName(1:3)) ~= convertCharsToStrings(runsInfo(runInd+1).mouseName(1:3))
        lastRunInGroup = true;
    elseif convertCharsToStrings(runInfo.recDate) ~= convertCharsToStrings(runsInfo(runInd+1).recDate)
        lastRunInGroup = true;
    else
        lastRunInGroup = false;
    end
            
    if lastRunInGroup
        % Plot average across current group
        mouseName = strsplit(storeRunNameCurrGroup(1,:),'-');
        groupName = mouseName{1};

        disp(['Plotting data for ' groupName '...']);
        [numMice,numCh] = size(storeRawStdCurrGroup);

        variancePlot = figure(1);

        for plotInd = 1:numMice
            h1 = plot(storeRawStdPerCurrGroup(plotInd,:), '-o','MarkerSize', 8, 'LineWidth',2);
            set(h1, 'markerfacecolor', get(h1, 'color'));
            hold on;
            %scatter(1:numCh,storeRawStdPerAllMice(plotInd,:),'filled', 'k');    
        end

        legend(storeRunNameCurrGroup, 'Location', 'southoutside');
        set(gcf,'Position',[100 100 750 500]);
        xlabel('Channel');
        xticks([1 2 3 4]);
        ylabel('% Standard Deviation');
        title([groupName, ', Average Variance Across 3 Runs']);
        set(findall(gcf,'-property','FontSize'),'FontSize',13);

        saveVarianceFig = [runInfo.saveFolder '\' groupName '-varianceAVG'];
        saveas(variancePlot, [saveVarianceFig '.png']);
        close(variancePlot);

        %% compute average across mice in group
        saveFileVarianceGroup = [runInfo.saveFolder '\' groupName '-varianceAVG.mat'];

        if exist(saveFileVarianceGroup, 'file')
            disp(['Loading saved average group variance data file for ' groupName '...']);
            load(saveFileVarianceGroup, 'avgRawSpatialAvgGroup', 'avgRawStdGroup', 'avgRawStdPerGroup', 'groupName');
        else
            disp(['Calculating average for all mice in group ' groupName '...']);   
            avgRawSpatialAvgGroup = [];
            avgRawStdGroup = [];
            avgRawStdPerGroup = [];
            for chInd = 1:numCh
                avgRawSpatialAvgGroup = [avgRawSpatialAvgGroup, mean(storeRawSpatialAvgCurrGroup(:,chInd))];
                avgRawStdGroup = [avgRawStdGroup, mean(storeRawStdCurrGroup(:,chInd))];
            end

            avgRawStdPerGroup = [avgRawStdPerGroup, 100*avgRawStdGroup./mean(avgRawSpatialAvgGroup,2)];

            % save average across mice
            disp('Saving group average data...');
            save(saveFileVarianceGroup, 'avgRawSpatialAvgGroup', 'avgRawStdGroup', 'avgRawStdPerGroup', 'groupName', '-v7.3');
        end
        
        storeRawSpatialAvgGroup = [storeRawSpatialAvgGroup; avgRawSpatialAvgGroup];
        storeRawStdGroup = [storeRawStdGroup; avgRawStdGroup];
        storeRawStdPerGroup = [storeRawStdPerGroup; avgRawStdPerGroup];
        storeRunNameGroup = [storeRunNameGroup; groupName];
        
        saveFileVarianceGroup = [runInfo.saveFolder '\' [mouseName{1} '-variance.mat']];
        save(saveFileVarianceGroup, 'storeRawSpatialAvgCurrGroup', 'storeRawStdCurrGroup', 'storeRawStdPerCurrGroup', 'storeRunNameCurrGroup', '-v7.3');
        
        disp(['======= GROUP ' groupName ' COMPLETE =======']);
        
        storeRawSpatialAvgCurrGroup = [];
        storeRawStdCurrGroup = [];
        storeRawStdPerCurrGroup = [];
        storeRunNameCurrGroup = [];
    end
    
end

%% plot data across groups
disp('Plotting data across different groups...');
[numMice,numCh] = size(storeRawStdGroup);

variancePlot = figure(1);

for plotInd = 1:numMice
    h1 = plot(storeRawStdPerGroup(plotInd,:), '-o','MarkerSize', 8, 'LineWidth',2);
    set(h1, 'markerfacecolor', get(h1, 'color'));
    hold on;
    %scatter(1:numCh,storeRawStdPerAllMice(plotInd,:),'filled', 'k');    
end

legend(storeRunNameGroup, 'Location', 'southoutside', 'Orientation','horizontal');
set(gcf,'Position',[100 100 650 500]);
xlabel('Channel');
xticks([1 2 3 4]);
ylabel('% Standard Deviation');
title('Average Variance Across Training Regiments');
set(findall(gcf,'-property','FontSize'),'FontSize',13);

saveFolderLoc = split(runInfo.saveFolder, '\');
saveFolderLoc = join(saveFolderLoc(1:3), '\');
saveVarianceFig = [saveFolderLoc{1} '\varianceAcrossGroups'];
saveas(variancePlot, [saveVarianceFig '.png']);
close(variancePlot);

variancePlotAcrossGroups = figure(2);
storeRawStdPerGroupCh = storeRawStdPerGroup';

for plotInd = 1:numCh
    h2 = plot(storeRawStdPerGroupCh(plotInd,:), '-o','MarkerSize', 8, 'LineWidth',2);
    set(h2, 'markerfacecolor', get(h2, 'color'));
    hold on;
end
legendKey = ["Ch 1", "Ch 2", "Ch 3", "Ch 4"];
legend(legendKey, 'Location', 'southoutside', 'Orientation','horizontal');
set(gcf,'Position',[100 100 650 500]);
xlabel('Training Regiment');
xticks([1 2 3 4]);
xticklabels(storeRunNameGroup);
ylabel('% Standard Deviation');
title('Average Variance Across Training Regiments');
set(findall(gcf,'-property','FontSize'),'FontSize',13);

saveVarianceFig = [saveFolderLoc{1} '\varianceAcrossGroupsCh'];
saveas(variancePlotAcrossGroups, [saveVarianceFig '.png']);
close(variancePlotAcrossGroups);

end