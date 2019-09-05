%% load data
disp('load');
tic;
dataFluor1 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-4-week0-fc1-dataFluor.mat');
dataHb1 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-4-week0-fc1-dataHb.mat');
dataFluor2 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-4-week0-fc2-dataFluor.mat');
dataHb2 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-4-week0-fc2-dataHb.mat');
dataFluor3 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-4-week0-fc3-dataFluor.mat');
dataHb3 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-4-week0-fc3-dataHb.mat');
dataFluor4 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-4-week0-fc4-dataFluor.mat');
dataHb4 = load('D:\ProcessedData\AsherLag\BauerScripts\181116\181116-4-week0-fc4-dataHb.mat');
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
datasFluor = [dataFluor1 dataFluor2 dataFluor3 dataFluor4];
datasHb = [dataHb1 dataHb2 dataHb3 dataHb4];
lagTimeTrialAll = [];
lagAmpTrialAll = [];
covResAll = [];

hbData1All = [];
fluorData2All = [];

lagfig = figure(1);
set(lagfig,'Position',[100 100 1800 800]);
for ind=1:4
    dotLagFile = ['D:\ProcessedData\AsherLag\TestLagSaveBauer\TestLagFile-181116-4-week0-fc' num2str(ind) '.mat'];
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
    subplot(2,5,ind);
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
    
    subplot(2,5,ind+5);
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
subplot(2,5,5);
imagesc(nanmean(lagTimeTrialAll,3),'AlphaData',meanMask,tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');


figure(1);
subplot(2,5,10);
imagesc(nanmean(lagAmpTrialAll,3),'AlphaData',meanMask,rLim);
set(gca,'Visible','off');
titleObj = title('lagCorrAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

sgtitle('181116-4-week0');

saveLagFig = 'D:\ProcessedData\AsherLag\TestLagSaveBauer\TestLagFig-181116-4-week0-dotLag';
saveas(lagfig, [saveLagFig '.png']);
