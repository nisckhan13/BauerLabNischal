%% parameters
disp('parameters');
parameters.lowpass = 2;
parameters.highpass = 0.04;
parameters.startTime = 30;

edgeLen = 3;
tZone = 4;
corrThr = 0.3;
tLim = [0 3];
rLim = [0 2];
fs = 16.8;

%% plot movie avg 1 - DATA
disp('load');
tic;
asherData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc1.mat');
asherData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc2.mat');
asherData3 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-dataGCaMP-fc3.mat');
toc;

asherData = [asherData1 asherData2 asherData3];

%% plot movie avg 1 - PROCESS DATA
hbData1All = [];
fluorData2All = [];

for ind=1:3
    
    xform_datadeoxy = asherData(ind).deoxy;
    xform_dataoxy = asherData(ind).oxy;
    xform_datafluorCorr = asherData(ind).gcamp6corr;
    
     disp(['filter ' num2str(ind)]);
     tic;
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
    toc;
    
    % crop the desired portion of the data
    data1 = squeeze(xform_datadeoxy+xform_dataoxy);
    data2 = squeeze(xform_datafluorCorr);
    startFrame = round(parameters.startTime * fs);
    data1 = data1(:,:,startFrame:end);
    data2 = data2(:,:,startFrame:end);
    
    % store the data for later use
    hbData1All = cat(4,hbData1All,data1);
    fluorData2All = cat(4,fluorData2All,data2);
end

%% plot movie of raw data HB and Fluor

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
    imagesc(data1(:,:,ind), 'AlphaData', meanMask, [-2e-3 2e-3]); 
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
writerObj = VideoWriter('D:\ProcessedData\AsherLag\TestLagSave\timeTraceMovies\1-week0-fc1-dataHb.avi');
writerObj.FrameRate = 16.8;

open(writerObj);
for i=1:length(F2)
    frame = F2(i);
    writeVideo(writerObj, frame);
end
close(writerObj);
close(hbMov);
clear('F2');


%% plot movie avg 1-week0 - MOVIES

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
    ylim([-2.5e-3 3.0e-3]);
    hold on;
    yyaxis right;
    plot(time, smooth(squeeze(d2)), 'color', 'blue');
    legend('hbT', 'fluor');
    xlim([30 time(end)]);
    xlabel('time(s)');
    ylabel('\DeltaF/F');
    title(['Time Trace, 181116-1-week0-fc1, [28,' num2str(34+i) ']']);
    ylim([-0.02 0.03]);
    hold off;
    F(i+1) = getframe(ttF);
    drawnow;
    clf(ttF);
end

disp(['saving video ' num2str(ind)]);
writerObj = VideoWriter('D:\ProcessedData\AsherLag\TestLagSave\timeTraceMovies\timeTrace-1-week0-fc1.avi');
writerObj.FrameRate = 7;

open(writerObj);
for i=1:length(F)
    frame = F(i);
    writeVideo(writerObj, frame);
end
close(writerObj);
close(ttF);

