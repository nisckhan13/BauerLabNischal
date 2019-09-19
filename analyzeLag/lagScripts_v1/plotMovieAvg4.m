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
asherData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-4-week0-dataGCaMP-fc1.mat');
asherData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-4-week0-dataGCaMP-fc2.mat');
asherData3 = load('C:\Users\Nischal\Documents\TestData\181116\181116-4-week0-dataGCaMP-fc3.mat');
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

%% plot movie avg 1-week0 - MOVIES

data1 = nanmean(hbData1All,4);
data2 = nanmean(fluorData2All,4);

for i=0:40
    ttF = figure(1); 
    set(ttF,'Position',[100 100 1500 300]);
    disp(['plot ' num2str(i)]);
    d1 = data1(42+i,30,:);
    d2 = data2(42+i,30,:);
    time = (1:length(d1))/fs + 30; 
    plot(time, smooth(squeeze(d1)));
    ylabel('\Delta[Hb]');
    ylim([-2.5e-3 3.0e-3]);
    hold on;
    yyaxis right;
    plot(time, smooth(squeeze(d2)));
    legend('hbT', 'fluor');
    xlim([30 time(end)]);
    xlabel('time(s)');
    ylabel('\DeltaF/F');
    title(['[30,' num2str(42+i) ']']);
    ylim([-0.02 0.03]);
    hold off;
    F(i+1) = getframe(ttF);
    drawnow;
    clf(ttF);
end

disp(['saving video ' num2str(ind)]);
writerObj = VideoWriter('D:\ProcessedData\AsherLag\TestLagSave\timeTraceMovies\timeTrace-4-week0-AVG.avi');
writerObj.FrameRate = 3;

open(writerObj);
for i=1:length(F)
    frame = F(i);
    writeVideo(writerObj, frame);
end
close(writerObj);
close(ttF);

