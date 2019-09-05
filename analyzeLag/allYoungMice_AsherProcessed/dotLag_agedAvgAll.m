%% load data

% n = 17

disp('loading all aged data');
tic;
% allAgedMice = ["180917-422" "180917-424" "180917-425" "180917-426" "180917-427" "180917-450"...
%     "180917-452" "180917-459" "180917-461" "180918-307" "180918-309" "180918-421"...
%     "180918-442" "180918-443" "180918-446" "180918-447" "180918-578"];
allAgedMice = ["180917-422" "180917-424" "180917-425" "180917-426" "180917-427" "180917-450"...
    "180917-452" "180917-459" "180917-461" "180918-309"...
    "180918-442" "180918-446" "180918-447"];
allDLData = [];

for ind = 1:length(allAgedMice)
    for run = 1:4
        currRunLoc = ['D:\ProcessedData\AsherLag\finalDotLagSave\aged\dotLag-' char(allAgedMice(ind)) '-week0-fc' num2str(run) '.mat'];        
        if exist(currRunLoc, 'file')
            disp([char(allAgedMice(ind)) '-week0-fc' num2str(run)]);
            currRun = load(currRunLoc);
            allDLData = [allDLData currRun];
        end
    end
end
toc;

%% process and plot data

disp('plotting avg all aged data');
lagAmpTrialAllA = [];
lagTimeTrialAllA = [];

tLim = [0 4];
rLim = [-1 1];

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

for ind = 1:length(allDLData)
    lagAmpTrialAllA = cat(3,lagAmpTrialAllA,allDLData(ind).lagAmpTrial);
    lagTimeTrialAllA = cat(3,lagTimeTrialAllA,allDLData(ind).lagTimeTrial);
end

disp('DONE');

%% generate average across whole brain 

lagTimeAllAvg = nanmean(lagTimeTrialAllA,3);
lagAmpAllAvg = nanmean(lagAmpTrialAllA,3);

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
imagesc(nanmean(lagTimeTrialAllA,3),'AlphaData',meanMask,tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

figure(1);
subplot(2,1,2);
imagesc(nanmean(lagAmpTrialAllA,3),'AlphaData',meanMask,rLim);
set(gca,'Visible','off');
titleObj = title('lagCorrAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

sgtitle(['Average across all aged mice data, n=' num2str(length(allAgedMice))]);

saveLagFig = 'D:\ProcessedData\AsherLag\finalDotLagSave\dotLagFig-aged-avgAllMice';
saveas(lagfig, [saveLagFig '.png']);