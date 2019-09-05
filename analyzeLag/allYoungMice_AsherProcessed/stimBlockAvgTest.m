%% load data

disp('loading...');
stimDataLoc = ['E:\Data_for_Kenny\Young_Animals\Young_Week_0\181116\Processed181116'...
    '\181116-8-week0-dataGCaMP-stim2.mat'];
tic;
stimData = load(stimDataLoc);

trialMask = stimData.xform_mask;
dataHb = squeeze(stimData.deoxy + stimData.oxy);
dataFluor = squeeze(stimData.gcamp6corr);
fs = 16.8;
blockLenTime = 30;
baselineInd = 1:floor(fs*5);
% parameters.startTime = 30;
time = 0:0.0595:299.7620;


% % crop the desired portion of the data
% startFrame = round(parameters.startTime * fs);
% dataHb = dataHb(:,:,startFrame:end);
% dataFluor = dataFluor(:,:,startFrame:end);

toc;

%% use block avg code

% use gsr
disp('gsr');
dataHb = mouse.process.gsr(dataHb, trialMask);
dataFluor = mouse.process.gsr(dataFluor, trialMask);

[blockDataHb, blockTimeHb] = mouse.expSpecific.blockAvg(dataHb,time,blockLenTime,fs*blockLenTime);
blockDataHb = bsxfun(@minus,blockDataHb,mean(blockDataHb(:,:,baselineInd),3));

[blockDataFluor, blockTimeFluor] = mouse.expSpecific.blockAvg(dataFluor,time,blockLenTime,...
    fs*blockLenTime);
blockDataFluor = bsxfun(@minus,blockDataFluor,mean(blockDataFluor(:,:,baselineInd),3)); 
disp('DONE');

%% generate time trace of peak activation region
timeRangePeakRegion = 9:0.0595:11;
indRangePeakRegion = round(timeRangePeakRegion * 16.8);

peakHbMap = nanmean(blockDataHb(:,:,indRangePeakRegion),3);
peakHbMapFig = figure(1);
imagesc(peakHbMap,'AlphaData', trialMask, [-3e-4 3e-4]);
set(gca,'Visible','off');
colorbar; colormap('jet');
axis(gca,'square');
saveFigLoc = 'D:\ProcessedData\AsherLag\stimResponse\181116-8-week0-stim2-peakHb_GSR.fig';
savefig(peakHbMapFig,saveFigLoc);

% display peak hb map to base ROI off of
tracefig = openfig(saveFigLoc);
pause(0.5);
disp('Please click the ROI center.');
[xc, yc]=ginput(1);
centerX = xc;
centerY = yc;
disp('Please click the outside edge of circular ROI.');
[xc, yc]=ginput(1);
edgeX = xc;
edgeY = yc;
radius = pdist([centerX,centerY;edgeX,edgeY]);
close(tracefig);

[nVy,nVx] = size(peakHbMap);
ttraceMask = false(nVy, nVx);

 for x = 1:nVx
    for y = 1:nVy
        if pdist([centerX,centerY;x,y])<= radius
            ttraceMask(y,x) = true;
        end
    end
 end

 threshold = 0.5;
 
 thresholdVal = threshold*max(max(peakHbMap.*ttraceMask));

for x = 1:nVx
    for y = 1:nVy
        if peakHbMap(y,x)<thresholdVal
            ttraceMask(y,x) = false;
        end
    end
end

figure(peakHbMapFig);
pause(0.5);
hold on;
imagesc(ones(128)*-1,'AlphaData',ttraceMask*0.5);

%% 
% Average points in ROI and output linear time trace
blockDataFluorMask = blockDataFluor.*ttraceMask;
blockDataFluorMask(blockDataFluorMask==0) = NaN;
ttraceFluor = squeeze(nanmean(blockDataFluorMask,[1 2]));

blockDataHbMask = blockDataHb.*ttraceMask;
blockDataHbMask(blockDataHbMask==0) = NaN;
ttraceHb = squeeze(nanmean(blockDataHbMask,[1 2]));

%% plot
stimfig = figure(3);
set(stimfig,'Position',[100 100 800 300]);
left_color = [0 0.6 0]; % green
right_color = [0 0 1]; % blue  
set(stimfig,'defaultAxesColorOrder',[left_color; right_color]);
yyaxis left;
plot(blockTimeHb,ttraceHb, 'color', left_color);
title('Time trace block avg Fluor and Hb over peak activation region, 181116-8-week0-dataGCaMP-stim2');
xlabel('Time(s)');
ylabel('Hb');
ylim([-5e-4 5e-4]);
hold on;
yyaxis right
plot(blockTimeFluor,ttraceFluor, 'color', right_color);
ylabel('Fluor');
ylim([-5e-3 5e-3]);
legend('hbt', 'fluor');

%% test full data

dataFluor = squeeze(asherData(2).gcamp6corr);
dataFluor = mouse.process.gsr(dataFluor, trialMask);
dataFluor = bsxfun(@minus,dataFluor,mean(dataFluor(:,:,baselineInd),3)); 
dataFluorMask = dataFluor.*ttraceMask;
dataFluorMask(dataFluorMask==0) = NaN;
ttraceFluorFull = squeeze(nanmean(dataFluorMask,[1 2]));

dataHb = squeeze(asherData(2).deoxy + asherData(2).oxy);
dataHb = mouse.process.gsr(dataHb, trialMask);
dataFluor = bsxfun(@minus,dataFluor,mean(dataFluor(:,:,baselineInd),3)); 
dataHbMask = dataHb.*ttraceMask;
dataHbMask(dataHbMask==0) = NaN;
ttraceHbFull = squeeze(nanmean(dataHbMask,[1 2]));

disp('Plotting...');
stimfig = figure(4);
set(stimfig,'Position',[100 100 800 300]);
left_color = [0 0.6 0]; % green
right_color = [0 0 1]; % blue  
set(stimfig,'defaultAxesColorOrder',[left_color; right_color]);
yyaxis left;
plot(time,ttraceHbFull, 'color', left_color);
title(['Time trace over peak activation region, '...
    dateDS '-' ds '-week0-stim' num2str(ind)]);
xlabel('Time(s)');
ylabel('Hb');
ylim([-5e-4 5e-4]);
hold on;
yyaxis right
plot(time,ttraceFluorFull, 'color', right_color);
ylabel('Fluor');
ylim([-5e-3 5e-3]);
legend('hbt', 'fluor');

%% test asher data
data = bsxfun(@minus,a.meanindivmouse,mean(a.meanindivmouse(:,:,baselineInd),3)); 
dataMask = data.*ttraceMask;
dataMask(dataMask==0) = NaN;
ttraceData = squeeze(nanmean(dataMask,[1 2]));
time = 1:336;
time = time/16.8;
plot(time, ttraceData)

%% blockData movie
% 1:504
% 126:210
for ind=1:504
    movFig = figure(1);
    set(movFig,'Position',[500 100 600 600]);
    t = ind/fs;
%     sgtitle(['181116-2-week0-stim3, t = ' sprintf('%.2f',t) ' s']);
%     hbtMap = subplot(2,1,1);
%     ax = imagesc(blockDataHb(:,:,ind), 'AlphaData', meanMask, [-5e-4 5e-4]); 
%     set(gca,'Visible','off');
%     colorbar; colormap(hbtMap, 'jet');
%     axis(gca,'square');
%     titleObj = title('HbT');
%     set(titleObj,'Visible','on');
%     hold on;
%     contour(stimROI);
    
%     fluorMap = subplot(2,1,2);
    imagesc(blockDataFluor(:,:,ind), 'AlphaData', trialMask, [-1e-3 3e-3]); 
    set(gca,'Visible','off');
    colorbar; colormap(movFig, 'gray');
    axis(gca,'square');
    titleObj = title(['181116-8-week0-stim2, gsr, t = ' sprintf('%.2f',t) ' s, fluor']);
    set(titleObj,'Visible','on');  
    hold on;
    
%     F(ind-83)=getframe(movFig);
    drawnow;
%     clf(movFig);
end
% 
% disp('saving video');
% writerObj = VideoWriter('D:\ProcessedData\AsherLag\stimResponse\181116-8-week0-stim2-new-gsr.avi');
% writerObj.FrameRate = 8.4;
% 
% open(writerObj);
% for i=1:length(F)
%     frame = F(i);
%     writeVideo(writerObj, frame);
% end
% close(writerObj);
% close(movFig);
% clear('F');


%% determine ROI for block avg
stimROIHb = mouse.expSpecific.getROI(nanmean(blockDataHb(:,:,126:210),3), [50 30]);
stimROIFluor = mouse.expSpecific.getROI(nanmean(blockDataFluor(:,:,126:210),3), [50 30]);

%% movie 

t = 30;
for ind=504:5039
    movFig = figure(1);
    set(movFig,'Position',[500 100 400 800]);
    sgtitle(['181116-2-week0-stim3, t = ' sprintf('%.2f',t) ' s']);
    hbtMap = subplot(2,1,1);
    imagesc(dataHb(:,:,ind), 'AlphaData', trialMask, [-2e-3 2e-3]); 
    set(gca,'Visible','off');
    colorbar; colormap(hbtMap, 'jet');
    axis(gca,'square');
    titleObj = title('HbT');
    set(titleObj,'Visible','on');
    
    fluorMap = subplot(2,1,2);
    imagesc(dataFluor(:,:,ind), 'AlphaData', trialMask, [-0.02 0.02]); 
    set(gca,'Visible','off');
    colorbar; colormap(fluorMap, 'gray');
    axis(gca,'square');
    titleObj = title('Fluor');
    set(titleObj,'Visible','on');      
    
    drawnow;
    t = t + 0.0595;
end

%% seperate into blocks
figure(1);
plot(time,squeeze(dataHb(30,40,:)));
hold on;
yyaxis right;
plot(time,squeeze(dataFluor(30,40,:)));
legend('dataHb','dataFluor');

blocksHb = [];
blocksFluor = [];
i = 505;
for ind=1:9
    blocksHb = cat(4, blocksHb, dataHb(:,:,i:i+503));
    blocksFluor = cat(4, blocksFluor, dataFluor(:,:,i:i+503));
    i = i + 503;
    disp(num2str(i));
end

blockAvgHb = nanmean(blocksHb, 4);
blockAvgFluor = nanmean(blocksFluor, 4);

%% movie block avg
t = 0;
for ind=1:504
    movFig = figure(1);
    set(movFig,'Position',[500 100 400 800]);
    sgtitle(['181116-2-week0-stim3, t = ' sprintf('%.2f',t) ' s']);
    hbtMap = subplot(2,1,1);
    imagesc(blockAvgHb(:,:,ind), 'AlphaData', trialMask); 
    set(gca,'Visible','off');
    colorbar; colormap(hbtMap, 'jet');
    axis(gca,'square');
    titleObj = title('HbT');
    set(titleObj,'Visible','on');
    
    fluorMap = subplot(2,1,2);
    imagesc(blockAvgFluor(:,:,ind), 'AlphaData', trialMask, [-0.02 0.02]); 
    set(gca,'Visible','off');
    colorbar; colormap(fluorMap, 'gray');
    axis(gca,'square');
    titleObj = title('Fluor');
    set(titleObj,'Visible','on');      
    
    drawnow;
    t = t + 0.0595;
end

%% cross corr

figure(2);
timeBlock = 0:0.0595:29.9405;
plot(timeBlock,squeeze(blockAvgHb(30,40,:)));
hold on;
yyaxis right;
plot(timeBlock,squeeze(blockAvgFluor(30,40,:)));
legend('avgDataHb','avgDataFluor');

data1 = squeeze(blockAvgFluor(30,40,:));
data2 = squeeze(blockAvgHb(30,40,:));
figure(3);
[corr,lags] = xcorr(data1, data2);

plot(lags,corr)