function stimBlockAvg_young_justMaps(dsInput, dateDSInput, useGSR)    
%% input parameters
ds = dsInput; % which mice dataset
dateDS = dateDSInput; % which date

%% load data
disp(['----- LOADING ' dateDS '-' ds '-week0 -----']);
tic;

maskData = load(['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-LandmarksandMask.mat']);
asherData1 = load(['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-stim1.mat']);
asherData2 = load(['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-stim2.mat']);
asherData3 = load(['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-stim3.mat']);

data4Loc = ['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-stim4.mat'];

if exist(data4Loc, 'file')
    disp('run 4 found');
    asherData4 = load(data4Loc);
    asherData = [asherData1 asherData2 asherData3 asherData4];
else
    disp('run 4 NOT found');
    asherData = [asherData1 asherData2 asherData3];
end
toc;

%% after loading

trialMask = maskData.xform_mask;
fs = 16.8;
blockLenTime = 20;
baselineInd = 1:(floor(fs*5)-1);
time = 0:0.0595:299.7620;

timeRangePeakRegion = 9:0.0595:11;
indRangePeakRegion = round(timeRangePeakRegion * 16.8);

for ind=1:length(asherData)
    tic;
    disp(['--- Stim Run ' num2str(ind) ' ---']);
    dataHb = squeeze(asherData(ind).deoxy + asherData(ind).oxy);
    dataFluor = squeeze(asherData(ind).gcamp6corr);

    % gsr
    if (useGSR)
        disp('GSR...');
        dataHb = mouse.process.gsr(dataHb, trialMask);
        dataFluor = mouse.process.gsr(dataFluor, trialMask);
    end

    % compute block avg
    disp('Block avg...')
    [blockDataHb, blockTimeHb] = mouse.expSpecific.blockAvg(dataHb,time,blockLenTime,fs*blockLenTime);
    blockDataHb = bsxfun(@minus,blockDataHb,nanmean(blockDataHb(:,:,baselineInd),3));

    [blockDataFluor, blockTimeFluor] = mouse.expSpecific.blockAvg(dataFluor,time,blockLenTime,...
        fs*blockLenTime);
    blockDataFluor = bsxfun(@minus,blockDataFluor,nanmean(blockDataFluor(:,:,baselineInd),3)); 

    % generate peak map  
    disp('Generating and saving peak map...');
    peakHbMap = nanmean(blockDataHb(:,:,indRangePeakRegion),3);
    savePeakDataLoc = ['D:\ProcessedData\AsherLag\stimResponse\stimLagData\peakHbDat\'...
        dateDS '-' ds '-week0-stim' num2str(ind) '-peakHb_GSR_dat.mat'];
    
    save(savePeakDataLoc, 'peakHbMap', 'blockDataHb', 'blockDataFluor', 'blockTimeHb', 'blockTimeFluor');

end
