%% ISA Band Lag analysis 

% disp('load');
% maskData = load('D:\ProcessedData\AsherLag\AsherProcessed\180917-422-week0-LandmarksandMask.mat');
% asherData1 = load('D:\ProcessedData\AsherLag\AsherProcessed\180917-422-week0-dataGCaMP-fc1.mat');
% asherData2 = load('D:\ProcessedData\AsherLag\AsherProcessed\180917-422-week0-dataGCaMP-fc2.mat');
% asherData3 = load('D:\ProcessedData\AsherLag\AsherProcessed\180917-422-week0-dataGCaMP-fc3.mat');
% asherData4 = load('D:\ProcessedData\AsherLag\AsherProcessed\180917-422-week0-dataGCaMP-fc4.mat');

%% after loading

parameters.lowpass = 0.5;
parameters.highpass = 0.009;
parameters.startTime = 0;


edgeLen = 3;
tZone = 4;
corrThr = 0.3;
tLim = [0 2];


% load data
% hbData = load('D:\ProcessedData\AsherLag\180917\180917-422-week0-fc4-dataHb.mat');
% flourData = load('D:\ProcessedData\AsherLag\180917\180917-422-week0-fc4-dataFluor.mat');
asherData = [asherData1 asherData2 asherData3 asherData4];
lagTimeTrialAll = [];
lagAmpTrialAll = [];
for ind=1:4
    xform_datadeoxy = asherData(ind).deoxy;
    xform_dataoxy = asherData(ind).oxy;
    xform_datafluorCorr = asherData(ind).gcamp6corr;
    maskTrial = maskData.xform_mask;

    % % resample data so they have same frequency
    % disp('resample');
    % fluor = mouse.freq.resampledata(xform_datafluorCorr,flourData.fluorTime,hbData.hbTime);
    % xform_datafluorCorr = fluor;
    % time = hbData.hbTime;
    % fs = 1/(time(2)-time(1));
    % 
    % % remove first few seconds
    % xform_datahb = xform_datahb(:,:,:,time >= parameters.startTime);
    % xform_datafluorCorr = xform_datafluorCorr(:,:,time >= parameters.startTime);
    fs = 16.8;
    % filter data
    disp('filter');
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
    disp('compute lag');
    data1 = squeeze(xform_datadeoxy+xform_dataoxy);
    data2 = squeeze(xform_datafluorCorr);
    validRange = -edgeLen:round(tZone*fs);
    [lagTimeTrial,lagAmpTrial,covResult] = mouse.conn.dotLag(...
        data1,data2,edgeLen,validRange,corrThr,true,false);
    lagTimeTrial = lagTimeTrial./fs;

    % save lag data
    dotLagFile = ['D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-180917-422-week0-fc' num2str(ind) '.mat'];
    save(dotLagFile,'lagTimeTrial','lagAmpTrial','tZone','corrThr','edgeLen','covResult');
    
    lagTimeTrialAll = cat(3,lagTimeTrialAll,lagTimeTrial);
    lagAmpTrialAll = cat(3,lagAmpTrialAll,lagAmpTrial);
end
%plot
disp('plot');
figure;
imagesc(nanmean(lagTimeTrialAll,3),'AlphaData',maskTrial,tLim);
set(gca,'Visible','off');
titleObj = title('lagTime');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');
figure;
imagesc(nanmean(lagAmpTrialAll,3),'AlphaData',maskTrial,[0 1]);
set(gca,'Visible','off');
titleObj = title('lagAmp');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

%how to make movie
%for ind=1:size(sumHb,4); imagesc(squeeze(sumHb(:,:,1,ind)), [-5e-6 5e-6]); 
%colormap('jet'); axis(gca,'square'); drawnow; end




%% Notes
% look at processed data Oxy, deoxy, corrGcamp at different ROIs
% look at young mice (fc maps, power maps), flat maps are better (uniform
% variance is better), look at full band
% 3 trials per mouse
% 2x3 figures lagTime and lagAmp per mouse (3 trials)
% or 2x4 where fourth is avg
% time window needs to be wide enough
% big sharp transitions that are grabbing most of the features (don't
% include those)
% pick 5 mice, 3 trial per mice, full band, ISA, delta
% pick pixel for gcamp and oxy on top of each other (before lag analysis)
% ask asher about which mice are better 
% make sure cross correlation looks good
% should be seeing lags around 1 second