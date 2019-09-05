%% input parameters
clear;

ds = '578'; % which mice dataset
dateDS = '180918'; % which date
pickRun = '1'; % which run
age = 'Aged'; % Young or Aged


%% load data
disp(['----- LOADING ' dateDS '-' ds '-week0-fc' pickRun ' -----']);
tic;

maskData = load(['E:\Data_for_Kenny\' age '_Animals\' age '_Week_0\' dateDS...
    '\Processed' dateDS '\' dateDS '-' ds '-week0-LandmarksandMask.mat']);
asherData = load(['E:\Data_for_Kenny\' age '_Animals\' age '_Week_0\' dateDS...
    '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-fc' pickRun '.mat']);

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

tic;
    
xform_datadeoxy = asherData.deoxy;
xform_dataoxy = asherData.oxy;
xform_datafluorCorr = asherData.gcamp6corr;
maskTrial = maskData.xform_mask;        
fs = 16.8;

% filter data
disp('filtering...');
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
disp('cropping data...');
data1 = squeeze(xform_datadeoxy+xform_dataoxy);
data2 = squeeze(xform_datafluorCorr);

% crop the desired portion of the data
startFrame = round(parameters.startTime * fs);
dataHb = data1(:,:,startFrame:end);
dataFluor = data2(:,:,startFrame:end);

toc;

%% plot time trace

time = (1:length(dataHb))/fs + 30;

region1HbT = squeeze(mean(dataHb(82:90,22:30,:), [1 2]));
region1Fluor = squeeze(mean(dataFluor(82:90,22:30,:), [1 2]));

timeTrace = figure(2);
set(timeTrace,'Position',[100 100 1000 450]);
plot(time,region1HbT);
hold on;
ylabel('\Delta[Hb]');
yyaxis right
plot(time,region1Fluor);
legend('HbT', 'gCorr');
title(['Time Trace, ' dateDS '-' ds '-week0']);
xlabel('Time (s)');
ylabel('\DeltaF/F');
xlim([30 300]);


%% plot brain movie

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

t = 125;
for ind=1:850
    hbMov = figure(1);
    set(hbMov,'Position',[50 50 400 800]);
   
    sgtitle([dateDS '-' ds '-week0-fc' pickRun ', t = ' sprintf('%.2f',t) ' s']);
    
    hbtMap = subplot(2,1,1);
    imagesc(dataHb(:,:,ind), 'AlphaData', meanMask, [-2e-3 2e-3]); 
    set(gca,'Visible','off');
    colorbar; colormap(hbtMap, 'jet');
    axis(gca,'square');
    titleObj = title('HbT');
    set(titleObj,'Visible','on');
    
    fluorMap = subplot(2,1,2);
    imagesc(real(dataFluor(:,:,ind)), 'AlphaData', meanMask, [-0.02 0.02]); 
    set(gca,'Visible','off');
    colorbar; colormap(fluorMap, 'gray');
    axis(gca,'square');
    titleObj = title('Fluor');
    set(titleObj,'Visible','on');
           
    F(ind) = getframe(hbMov);
    drawnow;
    clf(hbMov);
    t = t + 0.0595;
end

disp('saving video...');
writerObj = VideoWriter(['D:\ProcessedData\AsherLag\finalDotLagSave\oddData\'...
    dateDS '-' ds '-week0-fc' pickRun '-rawMovie.avi']);
writerObj.FrameRate = 16.8;

open(writerObj);
for i=1:length(F)
    frame = F(i);
    writeVideo(writerObj, frame);
end
close(writerObj);
close(hbMov);
clear('F2');






