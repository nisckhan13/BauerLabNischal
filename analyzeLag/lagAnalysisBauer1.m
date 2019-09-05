%% load data
disp('load');
tic;
dataFluor1 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-1-week0-fc1-dataFluor.mat');
dataHb1 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-1-week0-fc1-dataHb.mat');
dataFluor2 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-1-week0-fc2-dataFluor.mat');
dataHb2 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-1-week0-fc2-dataHb.mat');
dataFluor3 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-1-week0-fc3-dataFluor.mat');
dataHb3 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-1-week0-fc3-dataHb.mat');
toc;

%% process

disp('----- processing -----');
parameters.lowpass = 2;
parameters.highpass = 0.04;
parameters.startTime = 30;

edgeLen = 3;
tZone = 4;
corrThr = 0.3;
tLim = [0 4];
rLim = [-1 1];

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

% load data
datasFluor = [dataFluor1 dataFluor2 dataFluor3];
datasHb = [dataHb1 dataHb2 dataHb3];
lagTimeTrialAll = [];
lagAmpTrialAll = [];
covResAll = [];

hbData1All = [];
fluorData2All = [];

lagfig = figure(1);
set(lagfig,'Position',[100 100 1800 800]);
for ind=1:3
    dotLagFile = ['D:\ProcessedData\AsherLag\TestLagSaveBauer\TestLagFile-181116-1-week0-fc' num2str(ind) '.mat'];
    if exist(dotLagFile, 'file')
        disp('loading saved data');
        load(dotLagFile);
    else
        xform_dataHb = datasHb(ind).xform_datahb;
        xform_datafluorCorr = datasFluor(ind).xform_datafluorCorr;
        maskTrial = datasHb(ind).xform_isbrain;        
        fs = 16.8;
        
        % filter data
        disp(['filter ' num2str(ind)]);
        if ~isempty(parameters.highpass)
            xform_dataHb = mouse.freq.highpass(xform_dataHb,parameters.highpass,fs);
            xform_datafluorCorr = mouse.freq.highpass(xform_datafluorCorr,parameters.highpass,fs);
        end
        if ~isempty(parameters.lowpass) && parameters.lowpass < fs/2
            xform_dataHb = mouse.freq.lowpass(xform_dataHb,parameters.lowpass,fs);
            xform_datafluorCorr = mouse.freq.lowpass(xform_datafluorCorr,parameters.lowpass,fs);
        end

        % compute lag
        disp(['compute lag ' num2str(ind)]);
        data1 = squeeze(sum(xform_dataHb,3));
        data2 = squeeze(xform_datafluorCorr);
        
        % crop the desired portion of the data
        startFrame = round(parameters.startTime * fs);
        data1 = data1(:,:,startFrame:end);
        data2 = data2(:,:,startFrame:end);
        
        % store the data for later use
        hbData1All = cat(4,hbData1All,data1);
        fluorData2All = cat(4,fluorData2All,data2);

%         validRange = -round(tZone*fs):round(tZone*fs);
        validRange = -edgeLen:round(tZone*fs);
        [lagTimeTrial,lagAmpTrial,covResult] = mouse.conn.dotLag(...
            data1,data2,edgeLen,validRange,corrThr,true,false);
        lagTimeTrial = lagTimeTrial./fs;

        % save lag data
        save(dotLagFile,'lagTimeTrial','lagAmpTrial','tZone','corrThr','edgeLen','covResult');
    end
    
    disp(['plot ' num2str(ind)]);
    subplot(2,4,ind);
    imagesc(lagTimeTrial,'AlphaData',meanMask,tLim);
    set(gca,'Visible','off');
    titleObj = title(['lagTime fc' num2str(ind)]);
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');
    
%     hold on;
%     lineX(1:57) = 28;
%     lineY = 34:90;
%     plot(lineX,lineY, 'Color','white','LineStyle','-','LineWidth',2);
    
    subplot(2,4,ind+4);
    imagesc(lagAmpTrial,'AlphaData',meanMask,rLim);
    set(gca,'Visible','off');
    titleObj = title(['lagCorr fc' num2str(ind)]);
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');
    
    lagTimeTrialAll = cat(3,lagTimeTrialAll,lagTimeTrial);
    lagAmpTrialAll = cat(3,lagAmpTrialAll,lagAmpTrial);
    covResAll = cat(3,covResAll,covResult);
   
end
%plot
disp('plot avg');
figure(1);
subplot(2,4,4);
imagesc(nanmean(lagTimeTrialAll,3),'AlphaData',meanMask,tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');


figure(1);
subplot(2,4,8);
imagesc(nanmean(lagAmpTrialAll,3),'AlphaData',meanMask,rLim);
set(gca,'Visible','off');
titleObj = title('lagCorrAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

sgtitle('181116-1-week0');

saveLagFig = 'D:\ProcessedData\AsherLag\TestLagSaveBauer\TestLagFig-181116-1-week0-dotLag';
saveas(lagfig, [saveLagFig '.png']);


%% plot cross correlation 1-week0 fc1
% 28,34 28,90
% 35, 77
for i = 0:56
    coor = 	[34+i 28];
    matSize = [128 128];
    covResult = covResAll(:,:,1);
    ind = mouse.math.matCoor2Ind(coor,matSize);
    corrPlot = figure(2);
    set(corrPlot,'Position',[100 100 900 850]);
    validRange = -edgeLen:round(tZone*fs);
    a = 0 + i/56;
    plot(validRange/16.8,covResult(ind, :), 'color', [1-a 0 a]);
    ylim([-1 1]);
    xlim([validRange(1) validRange(end)]./16.8);
    hold on;
%     plot([validRange(1) validRange(end)]./16.8, [corrThr corrThr], '--', 'color', 'black');
    ylabel('cross correlation');
    xlabel('time (s)');
    title('181116-1-week0-fc1 [28,34]-[28,90]');
    set(gca,'FontSize',18)
%     hold off;
    F(i+1) = getframe(corrPlot);
    drawnow;
%     clf(corrPlot);
end

% disp('saving video');
% writerObj = VideoWriter('D:\ProcessedData\AsherLag\TestLagSave\timeTraceMovies\corrPlot-1-week0-fc1.avi');
% writerObj.FrameRate = 6;
% 
% open(writerObj);
% for ind=1:length(F)
%     frame = F(ind);
%     writeVideo(writerObj, frame);
% end
% close(writerObj);
% close(corrPlot);

%% plot movie of raw data HB and Fluor fc1 1-week0

data1 = hbData1All(:,:,:,1);
data2 = fluorData2All(:,:,:,1);

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

t = 125;
for ind=1:850
    hbMov = figure(1);
    set(hbMov,'Position',[50 50 400 800]);
    sgtitle(['181116-1-week0-fc1, t = ' sprintf('%.2f',t) ' s']);
    hbtMap = subplot(2,1,1);
    imagesc(data1(:,:,ind), 'AlphaData', meanMask, [-6e-6 6e-6]); 
    set(gca,'Visible','off');
    colorbar; colormap(hbtMap, 'jet');
    axis(gca,'square');
    titleObj = title('HbT');
    set(titleObj,'Visible','on');
    
    fluorMap = subplot(2,1,2);
    imagesc(data2(:,:,ind), 'AlphaData', meanMask, [-0.02 0.02]); 
    set(gca,'Visible','off');
    colorbar; colormap(fluorMap, 'gray');
    axis(gca,'square');
    titleObj = title('Fluor');
    set(titleObj,'Visible','on');
       
    
    F2(ind) = getframe(hbMov);
    drawnow;
    clf(hbMov);
    t = t + 0.0595;
end

disp('saving video');
writerObj = VideoWriter('D:\ProcessedData\AsherLag\TestLagSaveBauer\timeTraceMovies\1-week0-fc1-dataHb.avi');
writerObj.FrameRate = 16.8;

open(writerObj);
for i=1:length(F2)
    frame = F2(i);
    writeVideo(writerObj, frame);
end
close(writerObj);
close(hbMov);
clear('F2');

%% plot movie 1-week0 fc1 - MOVIES

data1 = hbData1All(:,:,:,1);
data2 = fluorData2All(:,:,:,1);

for i=0:56
    ttF = figure(1); 
    set(ttF,'Position',[100 100 1500 300]);
    disp(['plot ' num2str(i)]);
    d1 = data1(34+i,28,:);
    d2 = data2(34+i,28,:);
    time = (1:length(d1))/fs + 30; 
    plot(time, smooth(squeeze(d1)), 'color', 'green');
    ylabel('\Delta[Hb]');
    ylim([-6e-6 6e-6]);
    hold on;
    yyaxis right;
    plot(time, smooth(squeeze(d2)), 'color', 'blue');
    legend('hbT', 'fluor');
    xlim([30 time(end)]);
    xlabel('time(s)');
    ylabel('\DeltaF/F');
    title(['Time Trace, 181116-1-week0-fc1, [28,' num2str(34+i) ']']);
    ylim([-0.02 0.02]);
    hold off;
    F(i+1) = getframe(ttF);
    drawnow;
    clf(ttF);
end

disp(['saving video ' num2str(ind)]);
writerObj = VideoWriter('D:\ProcessedData\AsherLag\TestLagSaveBauer\timeTraceMovies\timeTrace-1-week0-fc1.avi');
writerObj.FrameRate = 7;

open(writerObj);
for i=1:length(F)
    frame = F(i);
    writeVideo(writerObj, frame);
end
close(writerObj);
close(ttF);