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

parameters.lowpass = 2; % 4.0
parameters.highpass = 0.04;
parameters.startTime = 0;

edgeLen = 3;
tZone = 4; % 
corrThr = 0.3;
tLim = [-3.5 3.5];
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

% compute lag
validRange = -edgeLen:round(tZone*fs);
[lagTime,lagAmp,covResult] = mouse.conn.dotLag(...
    data1,data2,edgeLen,validRange,corrThr,true,false);
lagTime = lagTime./fs;
disp('DONE');

%% Plot Lag 

singleLag = figure;

sgtitle('181116-1-week0-DotLag-fc1-[0.04-2Hz]');
set(singleLag,'Position',[50 50 1000 550]);

disp('Plot Lag');
subplot(1,2,1);
imagesc(lagTime,tLim);
set(gca,'Visible','off');
titleObj = title('lagTime');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');
hold on;
% plot(43,27,'r*');
% plot(39,90,'r*');
lineX(1:31) = 22;
lineY = 60:90;
plot(lineX,lineY, 'Color','black','LineStyle','-');

subplot(1,2,2);
imagesc(lagAmp,rLim);
set(gca,'Visible','off');
titleObj = title('lagAmp');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');
hold on;
lineX(1:31) = 22;
lineY = 60:90;
plot(lineX,lineY, 'Color','black','LineStyle','-');


%% P2
tNull = lagTime(27,43); % if positive, hb lags behind gcamp
aNull = lagAmp(27,43);

tVal = lagTime(90,39); % if positive, hb lags behind gcamp
aVal = lagAmp(90,39);

for i=0:12
    coor = 	[78+i 14];
    matSize = [128 128];
    ind = mouse.math.matCoor2Ind(coor,matSize);
    figure(2);
    plot(validRange/16.8,covResult(ind, :));
    ylim([-0.5 1]);
    xlim([validRange(1) validRange(end)]./16.8);
    hold on;
    plot([validRange(1) validRange(end)]./16.8, [corrThr corrThr], '--');
    drawnow;
    ylabel('cross correlation');
    xlabel('time (s)');
    title('correlation at P2');
end
% figure(3);
% plot(validRange/16.8,covResult(ind+1, :));
% ylim([0 0.5]);
% hold on;
% plot([validRange(1) validRange(end)]./16.8, [corrThr corrThr], '--');

%% P2 raw data
  ttF = figure(1); 
for i=0:12
    disp('plot');
    d1 = data1(78+i,14,:);
    d2 = data2(78+i,14,:);
    time = (1:length(d1))/fs;
    % 
    set(ttF,'Position',[100 100 1000 300]);
    plot(time, smooth(squeeze(d1)));
    ylabel('\Delta[Hb]');
    hold on;
    yyaxis right;
    plot(time, smooth(squeeze(d2)));
    legend('hbT', 'fluor');
    xlim([0 time(end)]);
    xlabel('time(s)');
    ylabel('\DeltaF/F');
    title('Time trace at P2, smooth');
    pause;
    hold off;
end

%% P2 raw data MOVIE
    time = (1:length(d1))/fs;   
for i=0:30
    ttF = figure(1); 
    set(ttF,'Position',[100 100 1500 300]);
    disp(['plot ' num2str(i)]);
    d1 = data1(60+i,22,:);
    d2 = data2(60+i,22,:);     
    plot(time, smooth(squeeze(d1)));
    ylabel('\Delta[Hb]');
    ylim([-2e-3 2.5e-3]);
    hold on;
    yyaxis right;
    plot(time, smooth(squeeze(d2)));
    legend('hbT', 'fluor');
    xlim([0 time(end)]);
    xlabel('time(s)');
    ylabel('\DeltaF/F');
    title(['Time trace at [' num2str(60+i) ',22], smooth']);
    ylim([-0.02 0.03]);
    hold off;
    F(i+1) = getframe(ttF);
    drawnow;
    clf(ttF);
end

writerObj = VideoWriter('D:\ProcessedData\AsherLag\timeTrace.avi');
writerObj.FrameRate = 3;

open(writerObj);
for i=1:length(F)
    frame = F(i);
    writeVideo(writerObj, frame);
end
close(writerObj);

%% P2 raw data MOVIE ZOOM
    time = (1:length(d1))/fs;  
    timeRange = 1680:2520;
for i=0:30
    ttF = figure(1); 
    set(ttF,'Position',[100 100 1500 300]);
    disp(['plot ' num2str(i)]);
    d1 = data1(60+i,22,:);
    d2 = data2(60+i,22,:);     
    plot(time(timeRange), smooth(squeeze(d1(timeRange))));
    ylabel('\Delta[Hb]');
    ylim([-2e-3 3.5e-3]);
    hold on;
    yyaxis right;
    plot(time(timeRange), smooth(squeeze(d2(timeRange))));
    legend('hbT', 'fluor');
    xlim([timeRange(1)/16.8 timeRange(end)/16.8]);
    xlabel('time(s)');
    ylabel('\DeltaF/F');
    title(['Time trace at [' num2str(60+i) ',22], smooth']);
    ylim([-0.02 0.03]);
    hold off;
    F(i+1) = getframe(ttF);
    drawnow;
    clf(ttF);
end

writerObj = VideoWriter('D:\ProcessedData\AsherLag\timeTraceZoom.avi');
writerObj.FrameRate = 3;

open(writerObj);
for i=1:length(F)
    frame = F(i);
    writeVideo(writerObj, frame);
end
close(writerObj);

%% P2 raw data - zoom
timeRange = 1680:2520;

d1 = data1(27,43,:);
d2 = data2(27,43,:);

time = (1:length(d1))/fs;
% 
ttF = figure(4);
set(ttF,'Position',[100 100 1000 300]);
plot(time(timeRange), smooth(squeeze(d1(timeRange))));
ylabel('\Delta[Hb]');
hold on;
yyaxis right;
plot(time(timeRange), smooth(squeeze(d2(timeRange))));
legend('hbT', 'fluor');
xlim([timeRange(1)/16.8 timeRange(end)/16.8]);
xlabel('time(s)');
ylabel('\DeltaF/F');
title('Time trace at P2, smooth, zoomed');


%% P1 
coor = 	[90 39];
matSize = [128 128];
ind = mouse.math.matCoor2Ind(coor,matSize);
figure(2);
plot(validRange/16.8,covResult(ind, :));
ylim([-0.5 1]);
xlim([validRange(1) validRange(end)]./16.8);
hold on;
plot([validRange(1) validRange(end)]./16.8, [corrThr corrThr], '--');

ylabel('cross covariance');
xlabel('validRange');
title('covariance at P1');

%% P1 raw data

d1 = data1(90,39,:);
d2 = data2(90,39,:);

time = (1:length(d1))/fs;
% 
ttF = figure(4);
set(ttF,'Position',[100 100 1000 300]);
plot(time, smooth(squeeze(d1)));
ylabel('\Delta[Hb]');
hold on;
yyaxis right;
plot(time, smooth(squeeze(d2)));
legend('hbT', 'fluor');
xlim([0 time(end)]);
xlabel('time(s)');
ylabel('\DeltaF/F');
title('Time trace at P1, smooth');

%% P1 raw data - zoom
timeRange = 1680:2520;

d1 = data1(90,39,:);
d2 = data2(90,39,:);

time = (1:length(d1))/fs;
% 
ttF = figure(4);
set(ttF,'Position',[100 100 1000 300]);
plot(time(timeRange), smooth(squeeze(d1(timeRange))));
ylabel('\Delta[Hb]');
hold on;
yyaxis right;
plot(time(timeRange), smooth(squeeze(d2(timeRange))));
legend('hbT', 'fluor');
xlim([timeRange(1)/16.8 timeRange(end)/16.8]);
xlabel('time(s)');
ylabel('\DeltaF/F');
title('Time trace at P1, smooth, zoomed');

%% line profile

I = imread('D:\ProcessedData\AsherLag\TestLagSave\week0-fc1-lagTime.png');
imshow(I,[]);