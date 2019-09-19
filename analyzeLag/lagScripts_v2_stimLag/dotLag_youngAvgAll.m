%% load data

% n = 16

disp('loading all young data');
tic;
% allYoungMice = ["181116-1" "181116-2" "181116-4" "181116-6" "181116-7" "181116-8"...
%     "181116-9" "181116-10" "181115-2046" "181115-2047" "181115-2048" "181115-2049"...
%     "181115-2052" "181115-2053" "181115-2054" "181115-2055"];
allYoungMice = ["181116-1" "181116-2" "181116-4" "181116-6" "181116-7" "181116-8"...
    "181116-9" "181116-10" "181115-2046" "181115-2047" "181115-2048" "181115-2049"...
    "181115-2053" "181115-2055"];
allDLData = [];

for ind = 1:length(allYoungMice)
    for run = 1:4
        currRunLoc = ['D:\ProcessedData\AsherLag\finalDotLagSave\young\dotLag-'...
            char(allYoungMice(ind)) '-week0-fc' num2str(run) '.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allYoungMice(ind)) '-week0-fc' num2str(run)]);
            currRun = load(currRunLoc);
            allDLData = [allDLData currRun];
        end
    end
end
toc;

%% process data

disp('computing avg all young data');
lagAmpTrialAllY = [];
lagTimeTrialAllY = [];

tLim = [0 4];
rLim = [-1 1];

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

for ind = 1:length(allDLData)
    lagAmpTrialAllY = cat(3,lagAmpTrialAllY,allDLData(ind).lagAmpTrial);
    lagTimeTrialAllY = cat(3,lagTimeTrialAllY,allDLData(ind).lagTimeTrial);
end

disp('DONE');

%% generate average across whole brain 

lagTimeAllAvg = nanmean(lagTimeTrialAllY,3);
lagAmpAllAvg = nanmean(lagAmpTrialAllY,3);

imagesc(lagTimeAllAvg); colormap('jet'); axis(gca, 'square');

asherMask = load('D:\ProcessedData\AsherLag\finalDotLagSave\finalMaskYoung.mat');
asherMask = asherMask.finalMask;

lagTimeMask = lagTimeAllAvg.*asherMask;
imagesc(lagTimeMask); colormap('jet'); axis(gca, 'square');

lagTimeMask(lagTimeMask==0) = NaN;
avgAcrossBrain = nanmean(lagTimeMask,'all');



%% plot data 
lagfig = figure(1);
set(lagfig,'Position',[100 100 650 900]);
subplot(2,1,1);
imagesc(nanmean(lagTimeTrialAllY,3),'AlphaData',meanMask,tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

figure(1);
subplot(2,1,2);
imagesc(nanmean(lagAmpTrialAllY,3),'AlphaData',meanMask,rLim);
set(gca,'Visible','off');
titleObj = title('lagCorrAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

sgtitle(d);

saveLagFig = 'D:\ProcessedData\AsherLag\finalDotLagSave\dotLagFig-young-avgAllMice';
saveas(lagfig, [saveLagFig '.png']);