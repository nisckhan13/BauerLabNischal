var08 = load('D:\ProcessedData\AubreyGcAMP\190708\190708-variance.mat');
var10 = load('D:\ProcessedData\AubreyGcAMP\190710\190710-variance.mat');
var12 = load('D:\ProcessedData\AubreyGcAMP\190712\190712-variance.mat');
var19 = load('D:\ProcessedData\AubreyGcAMP\190719\190719-variance.mat');


for chInd = 1:4
    chPlot = figure(chInd);
    h1 = scatter([1;1;1;1],[-1;-2;-1;-2]);
    hold on;
    h2 = scatter([2;2;2;2],var08.storeRawStdPerCurrGroup(:,chInd),100, 'filled');
    h3 = scatter([3;3;3;3],var10.storeRawStdPerCurrGroup(:,chInd),100, 'filled');
    h4 = scatter([4;4;4;4],var12.storeRawStdPerCurrGroup(:,chInd),100, 'filled');
    h5 = scatter([1;1;1;1],[-1;-2;-1;-2]);
    
    set(gcf,'Position',[100 100 650 550]);
    xL = xlabel('Training Regiment');
    xticks([1 2 3 4 5]);
    xticklabels({'', 'Protocol 1','Protocol 2','Protocol 3', ''});
    ylabel('Standard Deviation (%)');
    ylim([0 1.8]);
    xlim([1 5]);
    title(['Variance in Channel ' num2str(chInd)]);
    set(findall(gcf,'-property','FontSize'),'FontSize',21);
    ax = ancestor(h5, 'axes');
    xRule = ax.XAxis;
    xRule.FontSize = 18;
    xL.FontSize = 21;
    
    saveVarianceFig = ['D:\ProcessedData\AubreyGcAMP\newVarianceInCh' num2str(chInd)];
    saveas(chPlot, [saveVarianceFig '.png']);
    close(chPlot);
    
end