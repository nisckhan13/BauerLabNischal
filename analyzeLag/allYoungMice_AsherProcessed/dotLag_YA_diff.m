tLim = [0 2];
rLim = [-1 1];

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

lagfig = figure(1);
set(lagfig,'Position',[100 100 650 900]);
subplot(2,1,1);
imagesc(nanmean(lagTimeTrialAllY,3)-nanmean(lagTimeTrialAllA,3),'AlphaData',meanMask,tLim);
set(gca,'Visible','off');
titleObj = title('lagTimeAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

figure(1);
subplot(2,1,2);
imagesc(nanmean(lagAmpTrialAllY,3)-nanmean(lagAmpTrialAllA,3),'AlphaData',meanMask,rLim);
set(gca,'Visible','off');
titleObj = title('lagCorrAvg');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

sgtitle('Difference between average of young and aged mice');

saveLagFig = 'D:\ProcessedData\AsherLag\finalDotLagSave\dotLagFig-aged-YADiff';
saveas(lagfig, [saveLagFig '.png']);