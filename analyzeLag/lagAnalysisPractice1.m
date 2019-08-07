%% ISA Band Lag analysis 

disp('load');
tic;
maskData = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-LandmarksandMask.mat');
asherData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc1.mat');
asherData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc2.mat');
asherData3 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc3.mat');
toc;

%% after loading
disp('----- processing -----');
parameters.lowpass = 2; % 4.0
parameters.highpass = 0.04;
parameters.startTime = 0;


edgeLen = 3;
tZone = 4;
corrThr = 0.3;
tLim = [0 2];
rLim = [0 1.5];

asherData = [asherData1 asherData2 asherData3];
lagTimeTrialAll = [];
lagAmpTrialAll = [];

saveHbO = [];
saveHbR = [];
saveHbT = [];
saveFluorCorr = [];

lagfig = figure(1);
set(lagfig,'Position',[100 100 1800 800]);

for ind=1:3
    dotLagFile = ['D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-1-week0-fc' num2str(ind) '.mat'];
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
        
        saveHbO = cat(4,saveHbO,squeeze(xform_dataoxy));
        saveHbR = cat(4,saveHbR,squeeze(xform_datadeoxy));
        saveHbT = cat(4,saveHbT,data1);
        saveFluorCorr = cat(4,saveFluorCorr,data2);
                
        validRange = -edgeLen:round(tZone*fs);
        [lagTimeTrial,lagAmpTrial,covResult] = mouse.conn.dotLag(...
            data1,data2,edgeLen,validRange,corrThr,true,false);
        lagTimeTrial = lagTimeTrial./fs;

        % save lag data
        save(dotLagFile,'lagTimeTrial','lagAmpTrial','tZone','corrThr','edgeLen','covResult');
    end
    
    disp(['plot ' num2str(ind)]);
    subplot(2,4,ind);
    imagesc(lagTimeTrial,tLim);
    set(gca,'Visible','off');
    titleObj = title(['lagTime fc' num2str(ind)]);
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');
    
    subplot(2,4,ind+4);
    imagesc(lagAmpTrial,rLim);
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
imagesc(nanmean(lagTimeTrialAll,3),tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');
hold on;
rectangle('Position',[22,82,8,8],...
  'EdgeColor', 'r',...
  'LineWidth', 2,...
  'LineStyle','-');
rectangle('Position',[35,26,8,8],...
  'EdgeColor', 'r',...
  'LineWidth', 2,...
  'LineStyle','-');

figure(1);
subplot(2,4,8);
imagesc(nanmean(lagAmpTrialAll,3),rLim);
set(gca,'Visible','off');
titleObj = title('lagAmpAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');
hold on;
rectangle('Position',[22,82,8,8],...
  'EdgeColor', 'r',...
  'LineWidth', 2,...
  'LineStyle','-');
rectangle('Position',[35,26,8,8],...
  'EdgeColor', 'r',...
  'LineWidth', 2,...
  'LineStyle','-');

sgtitle('181116-1-week0-[0.04-2Hz]');

saveLagFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-dotLag';
saveas(lagfig, [saveLagFig '.png']);
%how to make movie
%for ind=1:size(sumHb,4); imagesc(squeeze(sumHb(:,:,1,ind)), [-5e-6 5e-6]); 
%colormap('jet'); axis(gca,'square'); drawnow; end

%% save time trace data

% filteredData ='D:\ProcessedData\AsherLag\TestLagSave\filtDat-181116-1-week0-fc.mat';
% save(filteredData,'saveHbO','saveHbR','saveHbT','saveFluorCorr');

%% get time course data 1

time = (1:length(saveHbT(:,:,:,1)))/fs;

region1HbT = squeeze(mean(saveHbT(82:90,22:30,:,1), [1 2]));
region1HbO = squeeze(mean(saveHbO(82:90,22:30,:,1), [1 2]));
region1HbR = squeeze(mean(saveHbR(82:90,22:30,:,1), [1 2]));
region1gCorr = squeeze(mean(saveFluorCorr(82:90,22:30,:,1), [1 2]));
rg1HbTSmooth = smooth(region1HbT);
rg1HbOSmooth = smooth(region1HbO);
rg1HbRSmooth = smooth(region1HbR);
rg1CorrSmooth = smooth(region1gCorr);

region2HbT = squeeze(mean(saveHbT(26:34,35:43,:,1), [1 2]));
region2HbO = squeeze(mean(saveHbO(26:34,35:43,:,1), [1 2]));
region2HbR = squeeze(mean(saveHbR(26:34,35:43,:,1), [1 2]));
region2gCorr = squeeze(mean(saveFluorCorr(26:34,35:43,:,1), [1 2]));
rg2HbTSmooth = smooth(region2HbT);
rg2HbOSmooth = smooth(region2HbO);
rg2HbRSmooth = smooth(region2HbR);
rg2CorrSmooth = smooth(region2gCorr);
disp('DONE 1');

%% plot time course data 1

timeCoursefc1 = figure(2);
set(timeCoursefc1,'Position',[100 100 1000 550]);
sgtitle('181116-1-week0-fc1');

subplot(2,1,1);
plot(time,region1HbT);
hold on;
plot(time,region1HbO);
plot(time,region1HbR);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,region1gCorr);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time,region2HbT);
hold on;
plot(time,region2HbO);
plot(time,region2HbR);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,region2gCorr);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

saveTTFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-fc1-timeTrace';
saveas(timeCoursefc1, [saveTTFig '.png']);

%% plot time course data 1 smooth

timeCourseSmfc1 = figure(3);
set(timeCourseSmfc1,'Position',[100 100 1000 550]);
sgtitle('181116-1-week0-fc1-smooth');

subplot(2,1,1);
plot(time,rg1HbTSmooth);
hold on;
plot(time,rg1HbOSmooth);
plot(time,rg1HbRSmooth);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,rg1CorrSmooth);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time,rg2HbTSmooth);
hold on;
plot(time,rg2HbOSmooth);
plot(time,rg2HbRSmooth);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,rg2CorrSmooth);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

saveTTFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-fc1-timeTraceSmooth';
saveas(timeCourseSmfc1, [saveTTFig '.png']);


%% plot time course data 1 smooth - zoomed

timeRange = 1680:2520;

timeCourseSmfc1Z = figure(8);
set(timeCourseSmfc1Z,'Position',[100 100 1000 550]);
sgtitle('181116-1-week0-fc1-smooth-zoomed');

subplot(2,1,1);
plot(time(timeRange),rg1HbTSmooth(timeRange));
hold on;
plot(time(timeRange),rg1HbOSmooth(timeRange));
plot(time(timeRange),rg1HbRSmooth(timeRange));
ylabel('\Delta[Hb]');
yyaxis right
plot(time(timeRange),rg1CorrSmooth(timeRange));
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time(timeRange),rg2HbTSmooth(timeRange));
hold on;
plot(time(timeRange),rg2HbOSmooth(timeRange));
plot(time(timeRange),rg2HbRSmooth(timeRange));
ylabel('\Delta[Hb]');
yyaxis right
plot(time(timeRange),rg2CorrSmooth(timeRange));
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

saveTTFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-fc1-timeTraceSmooth100-150';
saveas(timeCourseSmfc1Z, [saveTTFig '.png']);
%% get time course data 2

time = (1:length(saveHbT(:,:,:,1)))/fs;

region1HbT = squeeze(mean(saveHbT(82:90,22:30,:,2), [1 2]));
region1HbO = squeeze(mean(saveHbO(82:90,22:30,:,2), [1 2]));
region1HbR = squeeze(mean(saveHbR(82:90,22:30,:,2), [1 2]));
region1gCorr = squeeze(mean(saveFluorCorr(82:90,22:30,:,2), [1 2]));
rg1HbTSmooth = smooth(region1HbT);
rg1HbOSmooth = smooth(region1HbO);
rg1HbRSmooth = smooth(region1HbR);
rg1CorrSmooth = smooth(region1gCorr);

region2HbT = squeeze(mean(saveHbT(26:34,35:43,:,2), [1 2]));
region2HbO = squeeze(mean(saveHbO(26:34,35:43,:,2), [1 2]));
region2HbR = squeeze(mean(saveHbR(26:34,35:43,:,2), [1 2]));
region2gCorr = squeeze(mean(saveFluorCorr(26:34,35:43,:,2), [1 2]));
rg2HbTSmooth = smooth(region2HbT);
rg2HbOSmooth = smooth(region2HbO);
rg2HbRSmooth = smooth(region2HbR);
rg2CorrSmooth = smooth(region2gCorr);
disp('DONE 2');
%% plot time course data 2

timeCoursefc2 = figure(4);
set(timeCoursefc2,'Position',[100 100 1000 550]);
sgtitle('181116-1-week0-fc2');

subplot(2,1,1);
plot(time,region1HbT);
hold on;
plot(time,region1HbO);
plot(time,region1HbR);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,region1gCorr);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time,region2HbT);
hold on;
plot(time,region2HbO);
plot(time,region2HbR);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,region2gCorr);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

saveTTFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-fc2-timeTrace';
saveas(timeCoursefc2, [saveTTFig '.png']);

%% plot time course data 2 smooth

timeCourseSmfc2 = figure(5);
set(timeCourseSmfc2,'Position',[100 100 1000 550]);
sgtitle('181116-1-week0-fc2-smooth');

subplot(2,1,1);
plot(time,rg1HbTSmooth);
hold on;
plot(time,rg1HbOSmooth);
plot(time,rg1HbRSmooth);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,rg1CorrSmooth);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time,rg2HbTSmooth);
hold on;
plot(time,rg2HbOSmooth);
plot(time,rg2HbRSmooth);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,rg2CorrSmooth);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

saveTTFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-fc2-timeTraceSmooth';
saveas(timeCourseSmfc2, [saveTTFig '.png']);

%% plot time course data 2 smooth - zoomed

timeRange = 1680:2520;

timeCourseSmfc2Z = figure(9);
set(timeCourseSmfc2Z,'Position',[100 100 1000 550]);
sgtitle('181116-1-week0-fc2-smooth-zoomed');

subplot(2,1,1);
plot(time(timeRange),rg1HbTSmooth(timeRange));
hold on;
plot(time(timeRange),rg1HbOSmooth(timeRange));
plot(time(timeRange),rg1HbRSmooth(timeRange));
ylabel('\Delta[Hb]');
yyaxis right
plot(time(timeRange),rg1CorrSmooth(timeRange));
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time(timeRange),rg2HbTSmooth(timeRange));
hold on;
plot(time(timeRange),rg2HbOSmooth(timeRange));
plot(time(timeRange),rg2HbRSmooth(timeRange));
ylabel('\Delta[Hb]');
yyaxis right
plot(time(timeRange),rg2CorrSmooth(timeRange));
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

saveTTFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-fc2-timeTraceSmooth100-150';
saveas(timeCourseSmfc2Z, [saveTTFig '.png']);

%% get time course data 3

time = (1:length(saveHbT(:,:,:,1)))/fs;

region1HbT = squeeze(mean(saveHbT(82:90,22:30,:,3), [1 2]));
region1HbO = squeeze(mean(saveHbO(82:90,22:30,:,3), [1 2]));
region1HbR = squeeze(mean(saveHbR(82:90,22:30,:,3), [1 2]));
region1gCorr = squeeze(mean(saveFluorCorr(82:90,22:30,:,3), [1 2]));
rg1HbTSmooth = smooth(region1HbT);
rg1HbOSmooth = smooth(region1HbO);
rg1HbRSmooth = smooth(region1HbR);
rg1CorrSmooth = smooth(region1gCorr);

region2HbT = squeeze(mean(saveHbT(26:34,35:43,:,3), [1 2]));
region2HbO = squeeze(mean(saveHbO(26:34,35:43,:,3), [1 2]));
region2HbR = squeeze(mean(saveHbR(26:34,35:43,:,3), [1 2]));
region2gCorr = squeeze(mean(saveFluorCorr(26:34,35:43,:,3), [1 2]));
rg2HbTSmooth = smooth(region2HbT);
rg2HbOSmooth = smooth(region2HbO);
rg2HbRSmooth = smooth(region2HbR);
rg2CorrSmooth = smooth(region2gCorr);
disp('DONE 3');
%% plot time course data 3

timeCoursefc3 = figure(6);
set(timeCoursefc3,'Position',[100 100 1000 550]);
sgtitle('181116-1-week0-fc3');

subplot(2,1,1);
plot(time,region1HbT);
hold on;
plot(time,region1HbO);
plot(time,region1HbR);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,region1gCorr);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time,region2HbT);
hold on;
plot(time,region2HbO);
plot(time,region2HbR);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,region2gCorr);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

saveTTFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-fc3-timeTrace';
saveas(timeCoursefc3, [saveTTFig '.png']);

%% plot time course data 3 smooth

timeCourseSmfc3 = figure(7);
set(timeCourseSmfc3,'Position',[100 100 1000 550]);
sgtitle('181116-1-week0-fc3-smooth');

subplot(2,1,1);
plot(time,rg1HbTSmooth);
hold on;
plot(time,rg1HbOSmooth);
plot(time,rg1HbRSmooth);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,rg1CorrSmooth);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time,rg2HbTSmooth);
hold on;
plot(time,rg2HbOSmooth);
plot(time,rg2HbRSmooth);
ylabel('\Delta[Hb]');
yyaxis right
plot(time,rg2CorrSmooth);
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

saveTTFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-fc3-timeTraceSmooth';
saveas(timeCourseSmfc3, [saveTTFig '.png']);

%% plot time course data 1 smooth - zoomed

timeRange = 1680:2520;

timeCourseSmfc3Z = figure(10);
set(timeCourseSmfc3Z,'Position',[100 100 1000 550]);
sgtitle('181116-1-week0-fc3-smooth-zoomed');

subplot(2,1,1);
plot(time(timeRange),rg1HbTSmooth(timeRange));
hold on;
plot(time(timeRange),rg1HbOSmooth(timeRange));
plot(time(timeRange),rg1HbRSmooth(timeRange));
ylabel('\Delta[Hb]');
yyaxis right
plot(time(timeRange),rg1CorrSmooth(timeRange));
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time(timeRange),rg2HbTSmooth(timeRange));
hold on;
plot(time(timeRange),rg2HbOSmooth(timeRange));
plot(time(timeRange),rg2HbRSmooth(timeRange));
ylabel('\Delta[Hb]');
yyaxis right
plot(time(timeRange),rg2CorrSmooth(timeRange));
legend('HbT','HbO','HbR', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

saveTTFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-fc3-timeTraceSmooth100-150';
saveas(timeCourseSmfc3Z, [saveTTFig '.png']);
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