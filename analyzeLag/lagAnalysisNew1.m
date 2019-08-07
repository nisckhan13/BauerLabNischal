%% load data
disp('load');
tic;
maskData = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-LandmarksandMask.mat');
asherData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc1.mat');
asherData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc2.mat');
asherData3 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc3.mat');
toc;

%% after loading
disp('----- processing -----');
parameters.lowpass = 2;
parameters.highpass = 0.04;
parameters.startTime = 30;

edgeLen = 5;
tZone = 6;
corrThr = 0.3;
tLim = [0 4];
rLim = [-1 1];

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

% load data
asherData = [asherData1 asherData2 asherData3];
lagTimeTrialAll = [];
lagAmpTrialAll = [];
covResAll = [];
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
        
        % crop the desired portion of the data
        startFrame = round(parameters.startTime * fs);
        data1 = data1(:,:,startFrame:end);
        data2 = data2(:,:,startFrame:end);

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

saveLagFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-1-week0-dotLag';
saveas(lagfig, [saveLagFig '.png']);

%% plot cross correlation
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