%% input parameters
clear;

ds = '7'; % which mice dataset
dateDS = '181116'; % which date
pickRun = '1'; % which run
age = 'Young'; % Young or Aged

%% load data
disp(['----- LOADING ' dateDS '-' ds '-week0-fc' pickRun ' -----']);
tic;

maskData = load(['E:\Data_for_Kenny\' age '_Animals\' age '_Week_0\' dateDS...
    '\Processed' dateDS '\' dateDS '-' ds '-week0-LandmarksandMask.mat']);
asherData = load(['E:\Data_for_Kenny\' age '_Animals\' age '_Week_0\' dateDS...
    '\Processed' dateDS '\' dateDS '-' ds '-week0-dataGCaMP-fc' pickRun '.mat']);

toc;

%% analyze data

disp('--- PROCESSING ---');

% static parameters
edgeLen = 4;
tZone = 5;
corrThr = 0.3;
tLim = [0 4];
rLim = [-1 1];
fs = 16.8;
parameters.startTime = 270; 
freqWin = 0.035:0.035:5.2;

storeTime = [];
storeAmp = [];

xform_datadeoxy = asherData.deoxy;
xform_dataoxy = asherData.oxy;
xform_datafluorCorr = asherData.gcamp6corr;

% crop the desired portion of the data
startFrame = round(parameters.startTime * fs);
xform_datadeoxy = xform_datadeoxy(:,:,startFrame:end);
xform_dataoxy = xform_dataoxy(:,:,startFrame:end);
xform_datafluorCorr = xform_datafluorCorr(:,:,startFrame:end);

for ind=freqWin
    
    parameters.lowpass = ind+0.35;
    parameters.highpass = ind; 

    % filter data
    tic;
    disp(['- filtering HP ' num2str(ind) 'hz']);
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

    % compute lag
    disp('- computing lag');
    validRange = -edgeLen:round(tZone*fs);
    [lagTime,lagAmp,covResult] = mouse.conn.dotLag(...
        data1,data2,edgeLen,validRange,corrThr,true,false);
    lagTime = lagTime./fs;
    
    peakTime = nanmean(lagTime(70:80,90:100), 'all');
    peakAmp = nanmean(lagAmp(70:80,90:100), 'all');
    
    storeTime = [storeTime, peakTime];
    storeAmp = [storeAmp, peakAmp];
    toc;
    
end

disp('Saving...');
freqDepFile = ['D:\ProcessedData\AsherLag\finalDotLagSave\freqDep\' age '\freqDep-'...
    dateDS '-' ds '-week0-fc' pickRun '.mat'];
save(freqDepFile,'storeTime','storeAmp','tZone','corrThr','edgeLen','covResult', 'freqWin');

disp('DONE');

%% plot data

disp('--- PLOTTING ---');

freqDep = figure(1);
set(freqDep,'Position',[100 100 1000 400]);
sgtitle('Frequency dependence of correlations');

subplot(1,2,1);
plot(freqWin,storeTime);
xlabel('Frequency (Hz)');
ylabel('Delay (s)');
xlim([freqWin(1) freqWin(end)]);

subplot(1,2,2);
plot(freqWin,storeAmp);
xlabel('Frequency (Hz)');
ylabel('Cross-correlation');
xlim([freqWin(1) freqWin(end)]);