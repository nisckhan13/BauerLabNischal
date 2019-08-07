%% load data
disp('load');
tic;
maskData = load('C:\Users\Nischal\Documents\TestData\181116\181116-4-week0-LandmarksandMask.mat');
asherData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-4-week0-dataGCaMP-fc1.mat');
asherData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-4-week0-dataGCaMP-fc2.mat');
asherData3 = load('C:\Users\Nischal\Documents\TestData\181116\181116-4-week0-dataGCaMP-fc3.mat');
toc;

%% after loading
disp('----- processing -----');
parameters.lowpass = 2;
parameters.highpass = 0.04;
parameters.startTime = 30;

edgeLen = 3;
tZone = 4;
corrThr = 0.3;
tLim = [0 3];
rLim = [0 2];

% load data
asherData = [asherData1 asherData2 asherData3];
lagTimeTrialAll = [];
lagAmpTrialAll = [];
lagfig = figure(1);
set(lagfig,'Position',[100 100 1800 800]);
for ind=1:3
    dotLagFile = ['D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-4-week0-fc' num2str(ind) '.mat'];
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

        validRange = -edgeLen:round(tZone*fs);
        [lagTimeTrial,lagAmpTrial,covResult] = mouse.conn.dotLag(...
            data1,data2,edgeLen,validRange,corrThr,true,false);
        lagTimeTrial = lagTimeTrial./fs;

        % save lag data
        save(dotLagFile,'lagTimeTrial','lagAmpTrial','tZone','corrThr','edgeLen','covResult');
    end
    
    disp(['plot ' num2str(ind)]);
    subplot(2,4,ind);
    imagesc(lagTimeTrial,tLim);
    set(gca,'Visible','off');
    titleObj = title(['lagTime fc' num2str(ind)]);
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');
    
    subplot(2,4,ind+4);
    imagesc(lagAmpTrial,rLim);
    set(gca,'Visible','off');
    titleObj = title(['lagAmp fc' num2str(ind)]);
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');
    
    lagTimeTrialAll = cat(3,lagTimeTrialAll,lagTimeTrial);
    lagAmpTrialAll = cat(3,lagAmpTrialAll,lagAmpTrial);
end
%plot
disp('plot avg');
figure(1);
subplot(2,4,4);
imagesc(nanmean(lagTimeTrialAll,3),tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');
figure(1);
subplot(2,4,8);
imagesc(nanmean(lagAmpTrialAll,3),rLim);
set(gca,'Visible','off');
titleObj = title('lagAmpAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

sgtitle('181116-4-week0');

saveLagFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-4-week0-dotLag';
saveas(lagfig, [saveLagFig '.png']);