%% load data
disp('load');
tic;
maskData = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-LandmarksandMask.mat');
asherData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc1.mat');
% asherData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc2.mat');
% asherData3 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc3.mat');
toc;

%% analyze data
xform_datadeoxy = asherData1.deoxy;
xform_dataoxy = asherData1.oxy;
xform_datafluorCorr = asherData1.gcamp6corr;
maskTrial = maskData.xform_mask;

parameters.lowpass = 0.5; % 4.0
parameters.highpass = 0.009;
parameters.startTime = 0;

edgeLen = 3;
tZone = 4; % 
corrThr = 0.3;
tLim = [0 2];
rLim = [0 1.5];
fs = 16.8;

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
validRange = -edgeLen:round(tZone*fs);
[lagTime,lagAmp,covResult] = mouse.conn.dotLag(...
    data1,data2,edgeLen,validRange,corrThr,true,false);
lagTime = lagTime./fs;
disp('DONE');

%% post analysis
tNull = lagTime(56,36); % if positive, hb lags behind gcamp
aNull = lagAmp(56,36);

tVal = lagTime(57,36); % if positive, hb lags behind gcamp
aVal = lagAmp(57,36);

coor = 	[53 35];
matSize = [128 128];
ind = mouse.math.matCoor2Ind(coor,matSize);
figure(1);
plot(validRange/16.8,covResult(ind, :));
% ylim([0 0.5]);
hold on;
plot([validRange(1) validRange(end)]./16.8, [corrThr corrThr], '--');
figure(2);
plot(validRange/16.8,covResult(ind+1, :));
ylim([0 0.5]);
hold on;
plot([validRange(1) validRange(end)]./16.8, [corrThr corrThr], '--');

d1 = data1(56,36,:);
d2 = data2(56,36,:);

figure(3);
plot(squeeze(d1));
hold on;
plot(squeeze(d2));
legend('hbT', 'fluor');


%% plot analysis

disp('plot');
figure(4);
subplot(2,1,1);
imagesc(lagTime,'AlphaData', maskTrial, tLim);
set(gca,'Visible','off');
titleObj = title('lagTime');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

subplot(2,1,2);
imagesc(lagAmp,'AlphaData',maskTrial,rLim);
set(gca,'Visible','off');
titleObj = title('lagAmp');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');


% look at two inputs in that time window
% look at the output within that time window
% two maps for postive and negative corr
% open time window and look at traces
% take off mask for now
% reglate analysis to band in hillman 0.04-4Hz 
% line profile across sharp transitions 
% perhaps less than 0.05Hz

