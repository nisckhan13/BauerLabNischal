 function dotLag_young_30s_bauer(dsInput, dateDSInput, useGSR)   
    %% input parameters
    ds = dsInput; % which mice dataset
    dateDS = dateDSInput; % which date
    
    %% load data
    disp(['----- LOADING ' dateDS '-' ds '-week0 -----']);
    tic;

    maskData = load(['D:\ProcessedData\AsherLag\BauerProcessed\'...
        dateDS '\' dateDS '-' ds '-week0-LandmarksAndMask.mat']);
    bauerData1F = load(['D:\ProcessedData\AsherLag\BauerProcessed\'...
        dateDS '\' dateDS '-' ds '-week0-fc1-dataFluor.mat']);
    bauerData1H = load(['D:\ProcessedData\AsherLag\BauerProcessed\'...
        dateDS '\' dateDS '-' ds '-week0-fc1-dataHb.mat']);
    bauerData2F = load(['D:\ProcessedData\AsherLag\BauerProcessed\'...
        dateDS '\' dateDS '-' ds '-week0-fc2-dataFluor.mat']);
    bauerData2H = load(['D:\ProcessedData\AsherLag\BauerProcessed\'...
        dateDS '\' dateDS '-' ds '-week0-fc2-dataHb.mat']);
    bauerData3F = load(['D:\ProcessedData\AsherLag\BauerProcessed\'...
        dateDS '\' dateDS '-' ds '-week0-fc3-dataFluor.mat']);
    bauerData3H = load(['D:\ProcessedData\AsherLag\BauerProcessed\'...
        dateDS '\' dateDS '-' ds '-week0-fc3-dataHb.mat']);

    data4LocF = ['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\'...
        dateDS '-' ds '-week0-fc4-dataFluor.mat'];
    data4LocH = ['D:\ProcessedData\AsherLag\BauerProcessed\' dateDS '\'...
        dateDS '-' ds '-week0-fc4-dataHb.mat'];

    if exist(data4LocF, 'file')
        disp('run 4 found');
        bauerData4F = load(data4LocF);
        bauerData4H = load(data4LocH);
        bauerDataF = [bauerData1F bauerData2F bauerData3F bauerData4F];
        bauerDataH = [bauerData1H bauerData2H bauerData3H bauerData4H];
        subVar = 5;
    else
        disp('run 4 NOT found');
        bauerDataF = [bauerData1F bauerData2F bauerData3F];
        bauerDataH = [bauerData1H bauerData2H bauerData3H];
        subVar = 4;
    end

    toc;

    %% after loading
    parameters.lowpass = 2;
    parameters.highpass = 0.04;

    edgeLen = 4;
    tZone = 5;
    corrThr = 0.3;
    tLim = [0 4];
    rLim = [-1 1];
    fs = 16.8;
    numBlock = 9;

    paramPath = what('bauerParams');
    stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
    meanMask = stdMask.leftMask | stdMask.rightMask;

    lagTimeTrialAll = [];
    lagAmpTrialAll = [];

    lagfigTrialAll = figure(1);
    set(lagfigTrialAll,'Position',[100 100 1800 800]);

    for ind=1:length(bauerDataF)
        disp(['----- Processing fc' num2str(ind) ' -----']);
        tic;
        lagTimeTrialCurr = [];
        lagAmpTrialCurr = [];
        covResultCurr = [];

        lagfigTrialCurr = figure(ind+1);
        set(lagfigTrialCurr,'Position',[100 100 3400 500]);

        dotLagFile = ['D:\ProcessedData\AsherLag\finalDotLagSave30sBauer\young\dotLagTrial30sCat-'...
                dateDS '-' ds '-week0-fc' num2str(ind) '.mat'];
        if exist(dotLagFile, 'file')
                disp('Loading saved data...');
                load(dotLagFile);
        else
            parameters.startTime = 30;
            for block=1:numBlock
                disp(['--- dotLag, Trial ' num2str(ind) ', block ' num2str(block) ' ---']);

                tic;

                parameters.endTime = parameters.startTime + 30;
                
                xform_datadeoxy = squeeze((bauerDataH(ind).xform_datahb(:,:,2,:)));
                xform_dataoxy = squeeze((bauerDataH(ind).xform_datahb(:,:,1,:)));
                xform_datafluorCorr = squeeze(bauerDataF(ind).xform_datafluorCorr);
                maskTrial = maskData.xform_isbrain; 

                startFrame = round(parameters.startTime * fs);
                endFrame = round(parameters.endTime * fs);
                if startFrame == 0
                    startFrame = 1;
                end
                if endFrame > length(xform_datadeoxy)
                    endFrame = length(xform_datadeoxy);
                end       

                % crop the desired portion of the data
                xform_datadeoxy = xform_datadeoxy(:,:,startFrame:endFrame);
                xform_dataoxy = xform_dataoxy(:,:,startFrame:endFrame);
                xform_datafluorCorr = xform_datafluorCorr(:,:,startFrame:endFrame);
                
                % gsr
                if (useGSR)
                    disp('GSR...');
                    xform_datadeoxy = mouse.process.gsr(xform_datadeoxy, maskTrial);
                    xform_dataoxy = mouse.process.gsr(xform_dataoxy, maskTrial);
                    xform_datafluorCorr = mouse.process.gsr(xform_datafluorCorr, maskTrial);
                end

                % filter data
                disp(['Filter run ' num2str(ind) ' block ' num2str(block)]);
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

                disp(['Compute and save lag run ' num2str(ind) ' block ' num2str(block)]);
                data1 = squeeze(xform_datadeoxy+xform_dataoxy);
                data2 = squeeze(xform_datafluorCorr);

                validRange = -edgeLen:round(tZone*fs);
                [lagTimeTrial,lagAmpTrial,covResult] = mouse.conn.dotLag(...
                    data1,data2,edgeLen,validRange,corrThr,true,false);
                lagTimeTrial = lagTimeTrial./fs;

                lagTimeTrialCurr = cat(3,lagTimeTrialCurr,lagTimeTrial);
                lagAmpTrialCurr = cat(3,lagAmpTrialCurr,lagAmpTrial);
                covResultCurr = cat(3,covResultCurr,covResult);

                parameters.startTime = parameters.endTime; 

                toc;
            end 
            % save lag data
            save(dotLagFile,'lagTimeTrialCurr','lagAmpTrialCurr','tZone','corrThr','edgeLen','covResultCurr');
        end

        % plot figure for each block of current run along with run avg
        disp(['Plot data and avg for run ' num2str(ind)]);

        for block=1:numBlock
            lagfigTrialCurr = figure(ind+1);
            subplot(2,numBlock+1,block);
            imagesc(lagTimeTrialCurr(:,:,block),'AlphaData',meanMask,tLim);
            set(gca,'Visible','off');
            titleObj = title(['lagTime fc' num2str(ind) ' block ' num2str(block)]);
            axis(gca,'square');
            colorbar; colormap('jet');
            set(titleObj,'Visible','on');

            subplot(2,numBlock+1,block+numBlock+1);
            imagesc(lagAmpTrialCurr(:,:,block),'AlphaData',meanMask,rLim);
            set(gca,'Visible','off');
            titleObj = title(['lagCorr fc' num2str(ind) ' block ' num2str(block)]);
            axis(gca,'square');
            colorbar; colormap('jet');
            set(titleObj,'Visible','on');
        end

        figure(ind+1);
        subplot(2,numBlock+1,block+1);
        imagesc(nanmean(lagTimeTrialCurr,3),'AlphaData',meanMask,tLim);
        set(gca,'Visible','off');
        titleObj = title(['lagTime avg fc' num2str(ind)]);
        axis(gca,'square');
        colorbar; colormap('jet');
        set(titleObj,'Visible','on');

        subplot(2,numBlock+1,block+numBlock+2);
        imagesc(nanmean(lagAmpTrialCurr,3),'AlphaData',meanMask,rLim);
        set(gca,'Visible','off');
        titleObj = title(['lagCorr avg fc' num2str(ind)]);
        axis(gca,'square');
        colorbar; colormap('jet');
        set(titleObj,'Visible','on');

        sgtitle([dateDS '-' num2str(ds) '-week0-fc' num2str(ind)]);

        saveLagCurrFig = ['D:\ProcessedData\AsherLag\finalDotLagSave30sBauer\young\dotLagTrialAvgFig-'...
            dateDS '-' num2str(ds) '-week0-fc' num2str(ind)];
        saveas(lagfigTrialCurr, [saveLagCurrFig '.png']);

        close(figure(ind+1));

        % cat avg of entire trial and plot overall mouse figure
        lagTimeTrialAll = cat(3,lagTimeTrialAll,nanmean(lagTimeTrialCurr,3));
        lagAmpTrialAll = cat(3,lagAmpTrialAll,nanmean(lagAmpTrialCurr,3));

        figure(1);
        subplot(2,subVar,ind);
        imagesc(nanmean(lagTimeTrialCurr,3),'AlphaData',meanMask,tLim);
        set(gca,'Visible','off');
        titleObj = title(['lagTimeAvg fc' num2str(ind)]);
        axis(gca,'square');
        colorbar; colormap('jet');
        set(titleObj,'Visible','on');


        figure(1);
        subplot(2,subVar,ind+subVar);
        imagesc(nanmean(lagAmpTrialCurr,3),'AlphaData',meanMask,rLim);
        set(gca,'Visible','off');
        titleObj = title(['lagCorrAvg fc' num2str(ind)]);
        axis(gca,'square');
        colorbar; colormap('jet');
        set(titleObj,'Visible','on');

        toc;

    end

    %plot
    disp('Plot mouse avg and save...');
    figure(1);
    subplot(2,subVar,subVar);
    imagesc(nanmean(lagTimeTrialAll,3),'AlphaData',meanMask,tLim);
    set(gca,'Visible','off');
    titleObj = title('lagTimeAvg Mouse');
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');


    figure(1);
    subplot(2,subVar,subVar*2);
    imagesc(nanmean(lagAmpTrialAll,3),'AlphaData',meanMask,rLim);
    set(gca,'Visible','off');
    titleObj = title('lagCorrAvg Mouse');
    axis(gca,'square');
    colorbar; colormap('jet');
    set(titleObj,'Visible','on');

    sgtitle([dateDS '-' num2str(ds) '-week0']);

    saveLagFig = ['D:\ProcessedData\AsherLag\finalDotLagSave30sBauer\young\dotLagMouseAvgFig-' dateDS '-'...
        num2str(ds) '-week0'];
    saveas(lagfigTrialAll, [saveLagFig '.png']);

    close(figure(1));
    disp('DONE');
 end