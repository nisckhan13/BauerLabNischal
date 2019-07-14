%% ISA Band Lag analysis 

parameters.lowpass = 0.5;
parameters.highpass = 0.009;
parameters.startTime = 30;


edgeLen = 3;
tZone = 4;
corrThr = 0.3;
tLim = [0 2];


% load data
disp('load');
maskData = load('D:\ProcessedData\AsherLag\180917\180917-422-week0-LandmarksAndMask.mat');
hbData = load('D:\ProcessedData\AsherLag\180917\180917-422-week0-fc4-dataHb.mat');
flourData = load('D:\ProcessedData\AsherLag\180917\180917-422-week0-fc4-dataFluor.mat');

xform_datahb = hbData.xform_datahb;
xform_datafluorCorr = flourData.xform_datafluorCorr;
maskTrial = maskData.xform_isbrain;

% resample data so they have same frequency
disp('resample');
fluor = mouse.freq.resampledata(xform_datafluorCorr,flourData.fluorTime,hbData.hbTime);
xform_datafluorCorr = fluor;
time = hbData.hbTime;
fs = 1/(time(2)-time(1));

% remove first few seconds
xform_datahb = xform_datahb(:,:,:,time >= parameters.startTime);
xform_datafluorCorr = xform_datafluorCorr(:,:,time >= parameters.startTime);

% filter data
disp('filter');
if ~isempty(parameters.highpass)
    xform_datahb = mouse.freq.highpass(xform_datahb,parameters.highpass,fs);
    xform_datafluorCorr = mouse.freq.highpass(xform_datafluorCorr,parameters.highpass,fs);
end
if ~isempty(parameters.lowpass) && parameters.lowpass < fs/2
    xform_datahb = mouse.freq.lowpass(xform_datahb,parameters.lowpass,fs);
    xform_datafluorCorr = mouse.freq.lowpass(xform_datafluorCorr,parameters.lowpass,fs);
end

% compute lag
disp('compute lag');
data1 = squeeze(sum(xform_datahb,3));
data2 = squeeze(xform_datafluorCorr);
validRange = -edgeLen:round(tZone*fs);
[lagTimeTrial,lagAmpTrial,covResult] = mouse.conn.dotLag(...
    data1,data2,edgeLen,validRange,corrThr,true,false);
lagTimeTrial = lagTimeTrial./fs;

% save lag data
dotLagFile = 'D:\ProcessedData\AsherLag\TestLagFile-180917-422-week0-fc4.mat';
save(dotLagFile,'lagTimeTrial','lagAmpTrial','tZone','corrThr','edgeLen','covResult');

%plot
disp('plot');
figure;
imagesc(lagTimeTrial,'AlphaData',maskTrial,tLim);
figure;
imagesc(lagAmpTrial,'AlphaData',maskTrial,[0 1]);

%how to make movie
%for ind=1:size(sumHb,4); imagesc(squeeze(sumHb(:,:,1,ind)), [-5e-6 5e-6]); 
%colormap('jet'); axis(gca,'square'); drawnow; end