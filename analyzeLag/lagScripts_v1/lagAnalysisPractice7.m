%% ISA Band Lag analysis 

disp('load');
tic;
maskData = load('C:\Users\Nischal\Documents\TestData\181116\181116-7-week0-LandmarksandMask.mat');
asherData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-7-week0-dataGCaMP-fc1.mat');
asherData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-7-week0-dataGCaMP-fc2.mat');
asherData3 = load('C:\Users\Nischal\Documents\TestData\181116\181116-7-week0-dataGCaMP-fc3.mat');
toc;

%% after loading
disp('----- processing -----');
parameters.lowpass = 0.5; % 4.0
parameters.highpass = 0.009;
parameters.startTime = 0;


edgeLen = 5;
tZone = 4;
corrThr = 0.3;
tLim = [0 2];
rLim = [0 1.5];


% load data
% hbData = load('D:\ProcessedData\AsherLag\180917\180917-422-week0-fc4-dataHb.mat');
% flourData = load('D:\ProcessedData\AsherLag\180917\180917-422-week0-fc4-dataFluor.mat');
asherData = [asherData1 asherData2 asherData3];
lagTimeTrialAll = [];
lagAmpTrialAll = [];
lagfig = figure(1);
set(lagfig,'Position',[100 100 1800 800]);
for ind=1:3
    dotLagFile = ['D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-7-week0-fc' num2str(ind) '.mat'];
    if exist(dotLagFile, 'file')
        disp('loading saved data');
        load(dotLagFile);
    else
        xform_datadeoxy = asherData(ind).deoxy;
        xform_dataoxy = asherData(ind).oxy;
        xform_datafluorCorr = asherData(ind).gcamp6corr;
        maskTrial = maskData.xform_mask;

        % resample data so they have same frequency
    %     disp('resample');
    %     fluor = mouse.freq.resampledata(xform_datafluorCorr,flourData.fluorTime,hbData.hbTime);
    %     xform_datafluorCorr = fluor;
    %     time = hbData.hbTime;
    %     fs = 1/(time(2)-time(1));
        % 
        % % remove first few seconds
        % xform_datahb = xform_datahb(:,:,:,time >= parameters.startTime);
        % xform_datafluorCorr = xform_datafluorCorr(:,:,time >= parameters.startTime);
        fs = 16.8;
        % filter data
        disp(['filter ' num2str(ind)]);
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
        disp(['compute lag ' num2str(ind)]);
        data1 = squeeze(xform_datadeoxy+xform_dataoxy);
        data2 = squeeze(xform_datafluorCorr);
        validRange = -edgeLen:round(tZone*fs);
        [lagTimeTrial,lagAmpTrial,covResult] = mouse.conn.dotLag(...
            data1,data2,edgeLen,validRange,corrThr,true,false);
        lagTimeTrial = lagTimeTrial./fs;

        % save lag data
        save(dotLagFile,'lagTimeTrial','lagAmpTrial','tZone','corrThr','edgeLen','covResult');
    end
    
    disp(['plot ' num2str(ind)]);
    subplot(2,4,ind);
    imagesc(lagTimeTrial,'AlphaData', maskTrial, tLim);
    set(gca,'Visible','off');
    titleObj = title(['lagTime fc' num2str(ind)]);
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');
    
    subplot(2,4,ind+4);
    imagesc(lagAmpTrial,'AlphaData',maskTrial,rLim);
    set(gca,'Visible','off');
    titleObj = title(['lagAmp fc' num2str(ind)]);
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');
    
    lagTimeTrialAll = cat(3,lagTimeTrialAll,lagTimeTrial);
    lagAmpTrialAll = cat(3,lagAmpTrialAll,lagAmpTrial);
end
%plot
disp('plot avg');
figure(1);
subplot(2,4,4);
imagesc(nanmean(lagTimeTrialAll,3),'AlphaData',maskTrial,tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');
figure(1);
subplot(2,4,8);
imagesc(nanmean(lagAmpTrialAll,3),'AlphaData',maskTrial,rLim);
set(gca,'Visible','off');
titleObj = title('lagAmpAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

sgtitle('181116-7-week0');

saveLagFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-7-week0-dotLag';
saveas(lagfig, [saveLagFig '.png']);
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