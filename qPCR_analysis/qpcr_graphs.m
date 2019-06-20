results = readtable('qPCR analysis_190530.xlsx','Sheet','results');
exp1 = readtable('qPCR analysis_190530.xlsx','Sheet','exp1');

format long;

foldChangeData = {};
stanErrorData = {};
leftRight = {};
pvals = {};

for ind = 1:75
    if ~isnan(results{ind,'tTest'})
        foldChangeData = [foldChangeData, [results{ind,'foldChange'} results{ind+1,'foldChange'}]];
        stanErrorData = [stanErrorData, [results{ind,'SE'} results{ind+1,'SE'}]];
        leftRight = [leftRight, char(results{ind,'hemi'})];
        pvals = [pvals, results{ind,'tTest'}];
    end
end

titles = ["BDNF" "BDNF" "NGF" "NGF" "NTF3" "NTF3" "VEGFA" "VEGFA" "FGF1" "FGF1" "IGF1" "IGF1" "GDNF" "GDNF"];
titles2 = "ATRX";
titles3 = ["GAP43" "GAP43" "CAP23" "CAP23" "ARC" "ARC"];

figure(1);

for ind = 1:1:14
    if mod(ind,2) == 1
        subplot(2,7,((ind/2)+(1/2)))
    else
        subplot(2,7,((ind/2)+7))
    end   
    
    b = bar(foldChangeData{ind});
    if leftRight{ind} == 'L'
        %disp(titles(ind) + 'L')
        groups = {{'Left', 'Stim Left'}};
        set(gca,'XTickLabel',{'Left', 'Stim Left'});
    else
        %disp(titles(ind) + 'R')
        groups = {{'Right', 'Stim Right'}};
        set(gca,'XTickLabel',{'Right', 'Stim Right'});
    end
    hold on 
    errorbar(foldChangeData{ind}, stanErrorData{ind}, 'o', 'LineWidth', 1, 'Color', 'red');
    star=sigstar(groups,pvals{ind});
    set(star,'Color','b')
    set(star(2), 'FontSize', 20)
    ylim([0,2.35])
    title(titles(ind))
    ylabel('Fold Change')
end

sgtitle('Activity dependent Neurotrophic/Vascular Factors')
set(gcf,'color','w')

figure(2)
for ind = 15:1:16
    subplot(2,1,ind-14)
    b = bar(foldChangeData{ind});
    if leftRight{ind} == 'L'
        %disp(titles(ind) + 'L')
        groups = {{'Left', 'Stim Left'}};
        set(gca,'XTickLabel',{'Left', 'Stim Left'});
    else
        %disp(titles(ind) + 'R')
        groups = {{'Right', 'Stim Right'}};
        set(gca,'XTickLabel',{'Right', 'Stim Right'});
    end
    hold on 
    errorbar(foldChangeData{ind}, stanErrorData{ind}, 'o', 'LineWidth', 1, 'Color', 'red');
    star=sigstar(groups,pvals{ind});
    set(star,'Color','b')
    set(star(2), 'FontSize', 20)
    ylim([0,2.35])
    title(titles2)
    ylabel('Fold Change')
end

sgtitle('Activity dependent transcription factors')
set(gcf,'color','w')

figure(3)
for ind = 17:1:22
    subplot(3,2,ind-16)
    b = bar(foldChangeData{ind});
    if leftRight{ind} == 'L'
        %disp(titles(ind) + 'L')
        groups = {{'Left', 'Stim Left'}};
        set(gca,'XTickLabel',{'Left', 'Stim Left'});
    else
        %disp(titles(ind) + 'R')
        groups = {{'Right', 'Stim Right'}};
        set(gca,'XTickLabel',{'Right', 'Stim Right'});
    end
    hold on 
    errorbar(foldChangeData{ind}, stanErrorData{ind}, 'o', 'LineWidth', 1, 'Color', 'red');
    star=sigstar(groups,pvals{ind});
    set(star,'Color','b')
    set(star(2), 'FontSize', 20)
    ylim([0,2.35])
    title(titles3(ind-16))
    ylabel('Fold Change')
end

sgtitle('Activity dependent transcription factors')
set(gcf,'color','w')