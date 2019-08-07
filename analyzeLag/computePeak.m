%% load data
disp('load');
tic;
maskData = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-LandmarksandMask.mat');
asherData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc1.mat');
% asherData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc2.mat');
% asherData3 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc3.mat');
toc;

%% analyze data
xform_datadeoxy_full = asherData1.deoxy;
xform_dataoxy_full = asherData1.oxy;
xform_datafluorCorr_full = asherData1.gcamp6corr;
maskTrial = maskData.xform_mask;

storeLagTime = [];
storeLagAmp = [];
storeCovResult = [];

edgeLen = 3;
tZone = 4;
corrThr = 0.3;
tLim = [-3.5 3.5];
rLim = [0 1.5];
fs = 16.8;

for ind = 0.035:0.035:0.35
    
    parameters.lowpass = ind+0.35;
    parameters.highpass = ind;
    parameters.startTime = 0;

    disp(['----- filter ' num2str(ind) ' -----']);
    if ~isempty(parameters.highpass)
        xform_datadeoxy = mouse.freq.highpass(xform_datadeoxy_full,parameters.highpass,fs);
        xform_dataoxy = mouse.freq.highpass(xform_dataoxy_full,parameters.highpass,fs);
        xform_datafluorCorr = mouse.freq.highpass(xform_datafluorCorr_full,parameters.highpass,fs);
    end
    if ~isempty(parameters.lowpass) && parameters.lowpass < fs/2
        xform_datadeoxy = mouse.freq.lowpass(xform_datadeoxy_full,parameters.lowpass,fs);
        xform_dataoxy = mouse.freq.lowpass(xform_dataoxy_full,parameters.lowpass,fs);
        xform_datafluorCorr = mouse.freq.lowpass(xform_datafluorCorr_full,parameters.lowpass,fs);
    end

    data1 = squeeze(xform_datadeoxy+xform_dataoxy);
    data2 = squeeze(xform_datafluorCorr);

    % compute lag
    validRange = -edgeLen:round(tZone*fs);
    [lagTime,lagAmp,covResult] = mouse.conn.dotLag(...
        data1,data2,edgeLen,validRange,corrThr,true,false);
    lagTime = lagTime./fs;

    % store in local array

    storeLagTime = [storeLagTime; lagTime];
    storeLagAmp = [storeLagAmp; lagAmp];
    storeCovResult = [storeCovResult; covResult];
end

disp('DONE');

%% store values