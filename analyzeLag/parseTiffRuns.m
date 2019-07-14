function runsInfo = parseTiffRuns(excelFile,excelRows)
%parseTiffRuns Parses information from excel sheet about tiff runs and
%outputs information about each run

runsInfo = [];

excelData = readtable(excelFile);
tableRows = excelRows - 1;

totalRunInd = 0;
for row = tableRows % for each row of excel file
    % required info for each excel row
    rawDataLoc = excelData{row,'RawDataLocation'}; rawDataLoc = rawDataLoc{1};
    recDate = num2str(excelData{row,'Date'});
    saveLoc = excelData{row,'SaveLocation'}; saveLoc = saveLoc{1};
    mouseName = excelData{row,'Mouse'}; mouseName = mouseName{1};
    sessionType = excelData{row,'Session'}; sessionType = sessionType{1}(3:end-2);
    system = excelData{row,'System'}; system = system{1};
    samplingRate = excelData{row,'SamplingRate'};
    
    dataLoc = fullfile(rawDataLoc,recDate); % where raw data is located
    D = dir(dataLoc); D(1:2) = [];
    
    % find out valid files
    validFile = false(1,numel(D));
    for file = 1:numel(D)
        validFile(file) = contains(D(file).name,'.tif') ...
            && contains(D(file).name,sessionType) ...
            && contains(D(file).name,['-' mouseName '-']);
    end
    validFiles = D(validFile);
    
    % find list of runs in this mouse
    runList = nan(1,numel(validFiles));
    for file = 1:numel(validFiles)
        runNumStart = strfind(validFiles(file).name,['-' sessionType]);
        runNumStart = runNumStart + numel(sessionType) + 1;
        
        runNumEnd = find(isstrprop(validFiles(file).name,'digit'));
        runNumEnd(runNumEnd < runNumStart) = [];
        runList(file) = str2double(validFiles(file).name(runNumStart:runNumEnd));
    end
    
    uniqueRuns = unique(runList);
    
    % only consider good runs
    goodRuns = uniqueRuns;
    if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'GoodRuns'))) > 0
        goodRuns = excelData{row,'GoodRuns'};
        goodRuns = cellfun(@str2double,strsplit(goodRuns{1},','));
        disp('GoodRuns overwritten with excel');
    end
    goodRunBool = false(1,numel(uniqueRuns));
    for ind = 1:numel(uniqueRuns)
        goodRunBool(ind) = sum(uniqueRuns(ind) == goodRuns) > 0;
    end
    uniqueRuns = uniqueRuns(goodRunBool);
    
    % for each run, create a listing on output
    for run = uniqueRuns
        totalRunInd = totalRunInd + 1;
        
        runFiles = validFiles(run == runList);
        
        runFilesList = cell(1,numel(runFiles));
        for file = 1:numel(runFiles)
            runFilesList{file} = fullfile(runFiles(file).folder,runFiles(file).name);
        end
        
        % default
        qc = true;
        saveQC = true;
        samplingRateHb = min([samplingRate,2]); % hb sampling rate
        samplingRateCbf = min([samplingRate,2]);
        stimRoiSeed = [63 30];
        stimStartTime = 5;
        stimEndTime = 10;
        blockLen = 60;
        affineTransform = true;
        window = [-5 5 -5 5]; % y min, y max, x min, x max (in mm)
        
        % get common file name for both mask and data files
        saveFolder = fullfile(saveLoc,recDate);
        runNumStart = strfind(runFiles(1).name,['-' sessionType]);
        saveFileName = runFiles(1).name; saveFileName = saveFileName(1:runNumStart-1);
        
        % get mask file name
        saveMaskFile = [saveFileName '-LandmarksAndMask.mat'];
        saveMaskFile = fullfile(saveLoc,recDate,saveMaskFile);
        
        % get data file name
        saveFilePrefix = [saveFileName '-' sessionType num2str(run)];
        saveFilePrefix = fullfile(saveLoc,recDate,saveFilePrefix);
        saveRawFile = [saveFileName '-' sessionType num2str(run) '-dataRaw.mat'];
        saveRawFile = fullfile(saveLoc,recDate,saveRawFile);
        saveHbFile = [saveFileName '-' sessionType num2str(run) '-dataHb.mat'];
        saveHbFile = fullfile(saveLoc,recDate,saveHbFile);
        saveFluorFile = [saveFileName '-' sessionType num2str(run) '-dataFluor.mat'];
        saveFluorFile = fullfile(saveLoc,recDate,saveFluorFile);
        saveCbfFile = [saveFileName '-' sessionType num2str(run) '-dataCbf.mat'];
        saveCbfFile = fullfile(saveLoc,recDate,saveCbfFile);
        
        % get qc file name
        saveRawQCFig = [saveFileName '-' sessionType num2str(run) '-rawQC'];
        saveRawQCFig = fullfile(saveLoc,recDate,saveRawQCFig);
        saveFCQCFig = [saveFileName '-' sessionType num2str(run) '-fcQC'];
        saveFCQCFig = fullfile(saveLoc,recDate,saveFCQCFig);
        saveStimQCFig = [saveFileName '-' sessionType num2str(run) '-stimQC'];
        saveStimQCFig = fullfile(saveLoc,recDate,saveStimQCFig);
        saveRawQCFile = [saveFileName '-' sessionType num2str(run) '-rawQC.mat'];
        saveRawQCFile = fullfile(saveLoc,recDate,saveRawQCFile);
        saveFCQCFile = [saveFileName '-' sessionType num2str(run) '-fcQC.mat'];
        saveFCQCFile = fullfile(saveLoc,recDate,saveFCQCFile);
        saveStimQCFile = [saveFileName '-' sessionType num2str(run) '-stimQC.mat'];
        saveStimQCFile = fullfile(saveLoc,recDate,saveStimQCFile);
        
        % get system info and values dependent on system
        systemInfo = mouse.expSpecific.sysInfo(system);
        numCh = systemInfo.numLEDs;
        lightSourceFiles = systemInfo.LEDFiles;
        fluorFiles = systemInfo.fluorFiles;
        rgbInd = systemInfo.rgb;
        gbox = systemInfo.gbox;
        gsigma = systemInfo.gsigma;
        validThr = systemInfo.validThr;
        numInvalidFrames = systemInfo.numInvalidFrames;
        invalidFramesInd = 1:numInvalidFrames;
        binFactor = systemInfo.binFactor;
        hbChInd = systemInfo.chHb;
        fluorChInd = systemInfo.chFluor;
        speckleChInd = systemInfo.chSpeckle;
        
        % check if these values are stated in excel. If so, override.
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'NumCh'))) > 0
            numCh = excelData{row,'NumCh'};
            disp('NumCh overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'HbChInd'))) > 0
            hbChInd = excelData{row,'HbChInd'};
            hbChInd = cellfun(@str2double,strsplit(hbChInd{1},','));
            disp('HbChInd overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'FluorChInd'))) > 0
            fluorChInd = excelData{row,'FluorChInd'};
            if iscell(fluorChInd)
                fluorChInd = cellfun(@str2double,strsplit(fluorChInd{1},','));
            end
            disp('FluorChInd overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SpeckleChInd'))) > 0
            speckleChInd = excelData{row,'SpeckleChInd'};
            if iscell(speckleChInd)
                speckleChInd = cellfun(@str2double,strsplit(speckleChInd{1},','));
            end
            disp('SpeckleChInd overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'RGBInd'))) > 0
            rgbInd = excelData{row,'RGBInd'};
            disp('RGBInd overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'GBox'))) > 0
            rgbInd = excelData{row,'GBox'};
            disp('GBox overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'GSigma'))) > 0
            rgbInd = excelData{row,'GSigma'};
            disp('GSigma overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'ValidThreshold'))) > 0
            validThr = excelData{row,'ValidThreshold'};
            disp('ValidThreshold overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'NumDarkFrames'))) > 0
            numDarkFrames = excelData{row,'NumDarkFrames'};
            disp('NumDarkFrames overwritten with excel');
        else
            numDarkFrames = 0;
            disp('NumDarkFrames default used');
        end
        darkFramesInd = 1:numDarkFrames;
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'NumInvalidFrames'))) > 0
            numInvalidFrames = excelData{row,'NumInvalidFrames'};
            invalidFramesInd = 1:numInvalidFrames;
            disp('NumInvalidFrames overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'DetrendHb'))) > 0
            detrendHb = excelData{row,'DetrendHb'};
            disp('DetrendHb overwritten with excel');
        else
            detrendHb = 1; % by default, detrend Hb
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'DetrendFluor'))) > 0
            detrendFluor = excelData{row,'DetrendFluor'};
             disp('DetrendFluor overwritten with excel');
        else
            detrendFluor = 1; % by default, detrend fluorescence
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SaveRaw'))) > 0
            saveRaw = excelData{row,'SaveRaw'};
             disp('SaveRaw overwritten with excel');
        else
            saveRaw = 0; % by default, do not save raw
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SaveMaskFile'))) > 0
            saveMaskFile = excelData{row,'SaveMaskFile'};
             disp('SaveMaskFile overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SaveRawFile'))) > 0
            saveRawFile = excelData{row,'SaveRawFile'};
             disp('SaveRawFile overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SaveHbFile'))) > 0
            saveHbFile = excelData{row,'SaveHbFile'};
             disp('SaveHbFile overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SaveFluorFile'))) > 0
            saveFluorFile = excelData{row,'SaveFluorFile'};
             disp('SaveFluorFile overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SaveCbfFile'))) > 0
            saveCbfFile = excelData{row,'SaveCbfFile'};
             disp('SaveCbfFile overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'QC'))) > 0
            qc = excelData{row,'QC'};
            disp('QC overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SaveQC'))) > 0
            saveQC = excelData{row,'SaveQC'};
            disp('SaveQC overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SamplingRateHb'))) > 0
            samplingRateHb = excelData{row,'SamplingRateHb'};
            disp('SamplingRateHb overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'SamplingRateCbf'))) > 0
            samplingRateCbf = excelData{row,'SamplingRateCbf'};
            disp('SamplingRateCbf overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'StimRoiSeed'))) > 0
            stimRoiSeed = excelData{row,'StimRoiSeed'};
            stimRoiSeedY = stimRoiSeed(1:strfind(stimRoiSeed,',')-1);
            stimRoiSeedX = stimRoiSeed(strfind(stimRoiSeed,',')+1:end);
            stimRoiSeed = [str2double(stimRoiSeedY) str2double(stimRoiSeedX)];
            disp('StimRoiSeed overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'StimStartTime'))) > 0
            stimStartTime = excelData{row,'StimStartTime'};
            disp('StimStartTime overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'StimEndTime'))) > 0
            stimEndTime = excelData{row,'StimEndTime'};
            disp('StimEndTime overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'BlockLen'))) > 0
            blockLen = excelData{row,'BlockLen'};
            disp('BlockLen overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'BinFactor'))) > 0
            binFactor = excelData{row,'BinFactor'};
            binFactor = cellfun(@str2double,strsplit(binFactor{1},','));
            disp('BinFactor overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'AffineTransform'))) > 0
            affineTransform = excelData{row,'AffineTransform'};
            disp('AffineTransform overwritten with excel');
        end
        if sum(~cellfun(@isempty,strfind(excelData.Properties.VariableNames,'Window'))) > 0
            window = excelData{row,'Window'};
            window = cellfun(@str2double,strsplit(window{1},','));
            disp('Window overwritten with excel');
        end
        
        % add to struct
        runsInfo(totalRunInd).mouseName = mouseName;
        runsInfo(totalRunInd).recDate = recDate;
        runsInfo(totalRunInd).run = run;
        runsInfo(totalRunInd).samplingRate = samplingRate;
        runsInfo(totalRunInd).samplingRateHb = samplingRateHb;
        runsInfo(totalRunInd).samplingRateCbf = samplingRateCbf;
        runsInfo(totalRunInd).darkFramesInd = darkFramesInd;
        runsInfo(totalRunInd).invalidFramesInd = invalidFramesInd;
        runsInfo(totalRunInd).rawFile = runFilesList;
        runsInfo(totalRunInd).lightSourceFiles = lightSourceFiles;
        runsInfo(totalRunInd).fluorFiles = fluorFiles;
        runsInfo(totalRunInd).numCh = numCh;
        runsInfo(totalRunInd).binFactor = binFactor;
        runsInfo(totalRunInd).rgbInd = rgbInd;
        runsInfo(totalRunInd).hbChInd = hbChInd;
        runsInfo(totalRunInd).fluorChInd = fluorChInd;
        runsInfo(totalRunInd).speckleChInd = speckleChInd;
        runsInfo(totalRunInd).window = window;
        runsInfo(totalRunInd).gbox = gbox;
        runsInfo(totalRunInd).gsigma = gsigma;
        runsInfo(totalRunInd).detrendHb = detrendHb;
        runsInfo(totalRunInd).detrendFluor = detrendFluor;
        runsInfo(totalRunInd).qc = qc;
        runsInfo(totalRunInd).stimRoiSeed = stimRoiSeed;
        runsInfo(totalRunInd).stimStartTime = stimStartTime;
        runsInfo(totalRunInd).stimEndTime = stimEndTime;
        runsInfo(totalRunInd).blockLen = blockLen;
        runsInfo(totalRunInd).validThr = validThr;
        runsInfo(totalRunInd).saveRaw = saveRaw;
        runsInfo(totalRunInd).saveFolder = saveFolder;
        runsInfo(totalRunInd).saveMaskFile = saveMaskFile;
        runsInfo(totalRunInd).saveFilePrefix = saveFilePrefix;
        runsInfo(totalRunInd).saveRawFile = saveRawFile;
        runsInfo(totalRunInd).saveHbFile = saveHbFile;
        runsInfo(totalRunInd).saveFluorFile = saveFluorFile;
        runsInfo(totalRunInd).saveCbfFile = saveCbfFile;
        runsInfo(totalRunInd).saveQC = saveQC;
        runsInfo(totalRunInd).saveRawQCFig = saveRawQCFig;
        runsInfo(totalRunInd).saveFCQCFig = saveFCQCFig;
        runsInfo(totalRunInd).saveStimQCFig = saveStimQCFig;
        runsInfo(totalRunInd).saveRawQCFile = saveRawQCFile;
        runsInfo(totalRunInd).saveFCQCFile = saveFCQCFile;
        runsInfo(totalRunInd).saveStimQCFile = saveStimQCFile;
        runsInfo(totalRunInd).system = system;
        runsInfo(totalRunInd).session = sessionType;
        runsInfo(totalRunInd).affineTransform = affineTransform;
    end
end
end

