%% load data
disp('load');
tic;
maskData = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-LandmarksandMask.mat');
asherData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc1.mat');
asherData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc2.mat');
asherData3 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc3.mat');
toc;

%% analyze data
xform_datadeoxy = asherData1.deoxy;
xform_dataoxy = asherData1.oxy;
xform_datafluorCorr = asherData1.gcamp6corr;
maskTrial = maskData.xform_mask;

parameters.lowpass = 4;
parameters.highpass = 0.04;
parameters.startTime = 0;

edgeLen = 3;
tZone = 4;
corrThr = 0.3;
tLim = [0 2];
rLim = [0 1.5];
fs = 16.8;

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

data1 = squeeze(xform_datadeoxy+xform_dataoxy);
data2 = squeeze(xform_datafluorCorr);


%% plot time course

time = (1:length(data1))/fs;

region1HbT = squeeze(mean(data1(82:90,22:30,:), [1 2]));
region1gCorr = squeeze(mean(data2(82:90,22:30,:), [1 2]));
rg1HbTSmooth = smooth(region1HbT);
rg1CorrSmooth = smooth(region1gCorr);

region2HbT = squeeze(mean(data1(26:34,35:43,:), [1 2]));
region2gCorr = squeeze(mean(data2(26:34,35:43,:), [1 2]));
rg2HbTSmooth = smooth(region2HbT);
rg2CorrSmooth = smooth(region2gCorr);

fig2 = figure(2);
set(fig2,'Position',[100 100 900 550]);
sgtitle('181116-1-week0-fc1');

subplot(2,1,1);
plot(time,region1HbT);
hold on;
ylabel('\Delta[Hb]');
yyaxis right
plot(time,region1gCorr);
legend('HbT', 'gCorr');
title('Time Trace: Region 1');
xlabel('Time (s)');
ylabel('\DeltaF/F');

subplot(2,1,2);
plot(time,region2HbT);
hold on;
ylabel('\Delta[Hb]');
yyaxis right
plot(time,region2gCorr);
legend('HbT', 'gCorr');
title('Time Trace: Region 2');
xlabel('Time (s)');
ylabel('\DeltaF/F');

% fig3 = figure(3);
% set(fig3,'Position',[100 100 900 550]);
% sgtitle('181116-1-week0-fc1, Smooth');
% 
% subplot(2,1,1);
% plot(time,rg1HbTSmooth);
% hold on;
% ylabel('\Delta[Hb]');
% yyaxis right
% plot(time,rg1CorrSmooth);
% legend('HbT', 'gCorr');
% title('Time Trace: Region 1, Smooth');
% xlabel('Time (s)');
% ylabel('\DeltaF/F');
% 
% subplot(2,1,2);
% plot(time,rg2HbTSmooth);
% hold on;
% ylabel('\Delta[Hb]');
% yyaxis right
% plot(time,rg2CorrSmooth);
% legend('HbT', 'gCorr');
% title('Time Trace: Region 2, Smooth');
% xlabel('Time (s)');
% ylabel('\DeltaF/F');


