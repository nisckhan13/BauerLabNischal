%% load data
ds = ["1" "2" "4" "6" "7"];

cat30sData = [];

for i = 1:length(ds)
    for ind=1:4
        dsCurr = char(ds(i));
        dataLoc = ['D:\ProcessedData\AsherLag\dotLag30sNewBauer\young\dotLagTrial30sCat-181116-'...
            dsCurr '-week0-fc' num2str(ind) '.mat'];
        if exist(dataLoc, 'file')
            disp(['Loading ' dsCurr '-week0-fc' num2str(ind)]);
            loadData = load(dataLoc);
            cat30sData = [cat30sData loadData];
        end
    end
end

%% process data
lagTimeAll = [];
lagAmpAll = [];
for i=1:length(cat30sData)
    lagTimeAll = cat(3,lagTimeAll,cat30sData(i).lagTimeTrialCurr);
    lagAmpAll = cat(3,lagAmpAll,cat30sData(i).lagAmpTrialCurr);
end

disp('done');

%% plot graphs
paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

tLim = [0 1];
rLim = [-1 1];

finalAvgFig = figure(1);
set(finalAvgFig,'Position', [550 150 400 750]);
sgtitle('5 mouse avg 30s dotLag, Young, Bauer');
subplot(2,1,1);
imagesc(nanmean(lagTimeAll,3),'AlphaData',meanMask,tLim);
set(gca,'Visible','off');
titleObj = title('lagTime');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

subplot(2,1,2);
imagesc(nanmean(lagAmpAll,3),'AlphaData',meanMask,rLim);
set(gca,'Visible','off');
titleObj = title('lagCorr');
axis(gca,'square');
colorbar; colormap('jet');
set(titleObj,'Visible','on');

saveLagFig = 'D:\ProcessedData\AsherLag\dotLag30sNewBauer\avgFigs\dotLag5AvgFig-young_1';
saveas(finalAvgFig, [saveLagFig '.png']);