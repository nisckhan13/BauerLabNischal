%% load data
maskData1 = load('C:\Users\Nischal\Documents\TestData\181116\181116-1-week0-LandmarksandMask.mat');
maskData2 = load('C:\Users\Nischal\Documents\TestData\181116\181116-2-week0-LandmarksandMask.mat');
maskData4 = load('C:\Users\Nischal\Documents\TestData\181116\181116-4-week0-LandmarksandMask.mat');
maskData6 = load('C:\Users\Nischal\Documents\TestData\181116\181116-6-week0-LandmarksandMask.mat');
maskData7 = load('C:\Users\Nischal\Documents\TestData\181116\181116-7-week0-LandmarksandMask.mat');

m1fc1 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-1-week0-fc1.mat');
m1fc2 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-1-week0-fc2.mat');
m1fc3 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-1-week0-fc3.mat');

m2fc1 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-2-week0-fc1.mat');
m2fc2 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-2-week0-fc2.mat');
m2fc3 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-2-week0-fc3.mat');

m4fc1 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-4-week0-fc1.mat');
m4fc2 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-4-week0-fc2.mat');
m4fc3 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-4-week0-fc3.mat');

m6fc1 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-6-week0-fc1.mat');
m6fc2 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-6-week0-fc2.mat');
m6fc3 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-6-week0-fc3.mat');

m7fc1 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-7-week0-fc1.mat');
m7fc2 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-7-week0-fc2.mat');
m7fc3 = load('D:\ProcessedData\AsherLag\TestLagSave\TestLagFile-181116-7-week0-fc3.mat');

mFCData = [m1fc1 m1fc2 m1fc3 m2fc1 m2fc2 m2fc3 m4fc1 m4fc2 m4fc3 m6fc1 m6fc2 m6fc3 m7fc1 m7fc2 m7fc3];


%% process data
lagAmpTrialAll = [];
lagTimeTrialAll = [];

tLim = [0 4];
rLim = [-1 1];

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

for ind = 1:15
    lagAmpTrialAll = cat(3,lagAmpTrialAll,mFCData(ind).lagAmpTrial);
    lagTimeTrialAll = cat(3,lagTimeTrialAll,mFCData(ind).lagTimeTrial);
end

%% generate average across whole brain 

lagTimeAllAvg = nanmean(lagTimeTrialAll,3);
lagAmpAllAvg = nanmean(lagAmpTrialAll,3);

imagesc(lagTimeAllAvg); colormap('jet'); axis(gca, 'square');

asherMask = load('D:\ProcessedData\AsherLag\finalDotLagSave\finalMaskYoung.mat');
asherMask = asherMask.finalMask;

lagTimeMask = lagTimeAllAvg.*asherMask;
imagesc(lagTimeMask); colormap('jet'); axis(gca, 'square');

lagTimeMask(lagTimeMask==0) = NaN;
avgAcrossBrain = nanmean(lagTimeMask,'all');

%% plot
disp('plot avg');
lagfig = figure(1);
set(lagfig,'Position',[100 100 650 900]);
subplot(2,1,1);
imagesc(nanmean(lagTimeTrialAll,3),'AlphaData',meanMask,tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');
% hold on;
% lineX(1:41) = 30;
% lineY = 42:82;
% plot(lineX,lineY, 'Color','black','LineStyle','-','LineWidth',2);

figure(1);
subplot(2,1,2);
imagesc(nanmean(lagAmpTrialAll,3),'AlphaData',meanMask,rLim);
set(gca,'Visible','off');
titleObj = title('lagCorrAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');
% hold on;
% lineX(1:41) = 30;
% lineY = 42:82;
% plot(lineX,lineY, 'Color','black','LineStyle','-','LineWidth',2);

sgtitle('Average across 5 mice with 3 runs each');

% change name as needed
saveLagFig = 'D:\ProcessedData\AsherLag\TestLagSave\TestLagFig-181116-avg5Mice-dotLagMaskLine';
saveas(lagfig, [saveLagFig '.png']);