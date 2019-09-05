%% input parameters
clear;

ds = '2052'; % which mice dataset
dateDS = '181115'; % which date

%% load data
disp(['----- LOADING ' dateDS '-' ds '-week0 -----']);
tic;

maskData = load(['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-LandmarksandMask.mat']);
asherData1 = load(['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-fc1.mat']);
asherData2 = load(['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-fc2.mat']);
asherData3 = load(['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-fc3.mat']);

data4Loc = ['E:\Data_for_Kenny\Young_Animals\Young_Week_0\' dateDS '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-fc4.mat'];

if exist(data4Loc, 'file')
    disp('run 4 found');
    asherData4 = load(data4Loc);
    asherData = [asherData1 asherData2 asherData3 asherData4];
    subVar = 5;
else
    disp('run 4 NOT found');
    asherData = [asherData1 asherData2 asherData3];
    subVar = 4;
end


toc;

%% after loading
disp('--- processing ---');
parameters.lowpass = 2;
parameters.highpass = 0.04;
parameters.startTime = 30;

edgeLen = 4;
tZone = 5;
corrThr = 0.3;
tLim = [0 4];
rLim = [-1 1];

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

lagTimeTrialAll = [];
lagAmpTrialAll = [];
lagfig = figure(1);
set(lagfig,'Position',[100 100 1800 800]);

tic;    
for ind=1:length(asherData)
    dotLagFile = ['D:\ProcessedData\AsherLag\finalDotLagSave\young\dotLag-' dateDS '-' ds '-week0-fc' num2str(ind) '.mat'];
    if exist(dotLagFile, 'file')
        disp('loading saved data');
        load(dotLagFile);
    else
        xform_datadeoxy = asherData(ind).deoxy;
        xform_dataoxy = asherData(ind).oxy;
        xform_datafluorCorr = asherData(ind).gcamp6corr;
        maskTrial = maskData.xform_mask;        
        fs = 16.8;
        
        % filter data
        disp(['filter run #' num2str(ind)]);
        if ~isempty(parameters.highpass)
            xform_datadeoxy = mouse.freq.highpass(xform_datadeoxy,parameters.highpass,fs);
            xform_dataoxy = mouse.freq.highpass(xform_dataoxy,parameters.highpass,fs);
            xform_datafluorCorr = mouse.freq.highpass(xform_datafluorCorr,parameters.highpass,fs);
        end
        if ~isempty(parameters.lowpass) && parameters.lowpass < fs/2
            xform_datadeoxy = mouse.freq.lowpass(xform_datadeoxy,parameters.lowpass,fs);
            xform_dataoxy = mouse.freq.lowpass(xform_dataoxy,parameters.lowpass,fs);
            xform_datafluorCorr = mouse.freq.lowpass(xform_datafluorCorr,parameters.lowpass,fs);
        end

        % compute lag
        disp(['compute and save lag run #' num2str(ind)]);
        data1 = squeeze(xform_datadeoxy+xform_dataoxy);
        data2 = squeeze(xform_datafluorCorr);
        
        % crop the desired portion of the data
        startFrame = round(parameters.startTime * fs);
        data1 = data1(:,:,startFrame:end);
        data2 = data2(:,:,startFrame:end);

        validRange = -edgeLen:round(tZone*fs);
        [lagTimeTrial,lagAmpTrial,covResult] = mouse.conn.dotLag(...
            data1,data2,edgeLen,validRange,corrThr,true,false);
        lagTimeTrial = lagTimeTrial./fs;

        % save lag data
        save(dotLagFile,'lagTimeTrial','lagAmpTrial','tZone','corrThr','edgeLen','covResult');
    end
    
    disp(['plot run #' num2str(ind)]);
    subplot(2,subVar,ind);
    imagesc(lagTimeTrial,'AlphaData',meanMask,tLim);
    set(gca,'Visible','off');
    titleObj = title(['lagTime fc' num2str(ind)]);
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');
    
    subplot(2,subVar,ind+subVar);
    imagesc(lagAmpTrial,'AlphaData',meanMask,rLim);
    set(gca,'Visible','off');
    titleObj = title(['lagCorr fc' num2str(ind)]);
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');
    
    lagTimeTrialAll = cat(3,lagTimeTrialAll,lagTimeTrial);
    lagAmpTrialAll = cat(3,lagAmpTrialAll,lagAmpTrial);
end

%plot
disp('plot avg and save');
figure(1);
subplot(2,subVar,subVar);
imagesc(nanmean(lagTimeTrialAll,3),'AlphaData',meanMask,tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');


figure(1);
subplot(2,subVar,subVar*2);
imagesc(nanmean(lagAmpTrialAll,3),'AlphaData',meanMask,rLim);
set(gca,'Visible','off');
titleObj = title('lagCorrAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

sgtitle([dateDS '-' num2str(ds) '-week0']);

saveLagFig = ['D:\ProcessedData\AsherLag\finalDotLagSave\young\dotLagFig-' dateDS '-' num2str(ds) '-week0'];
saveas(lagfig, [saveLagFig '.png']);
disp('DONE');
toc;