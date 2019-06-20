%% read data and prepare variables
% read in gene data from excel file and convert to long to avoid rounding
results = readtable('qPCR analysis_190530.xlsx','Sheet','results');
format long;

% initialize variables
foldChangeStim = [];
stanErrorStim = [];
pvals = [];
genes = [];
family = [];
angle = 45;

% parse through table and store relevant data into variables
for ind = 1:411
    if ~isnan(results{ind,'tTest'})
        foldChangeStim = [foldChangeStim, results{ind+1,'foldChange'}];
        stanErrorStim = [stanErrorStim, results{ind+1,'SE'}];
        pvals = [pvals, results{ind,'tTest'}];
        genes = [genes, string(results{ind,'gene'})];
        family = [family, string(results{ind, 'family'})];
    end
end

%% plot data

% iterate twice, once for left and once for right
for ind = 1:2
    %% prepare data and stars
    % pull only the data needed for current plot
    foldChangeStimCurrent = foldChangeStim(ind:2:end);
    stanErrorStimCurrent = stanErrorStim(ind:2:end);
    pvalsCurrent = pvals(ind:2:end);
    xtickCurrent = genes(ind:2:end);
    familyCurrent = family(ind:2:end);

    % get stars for each p val
    starTxt = cell(1,numel(pvalsCurrent));
    for i = 1:numel(pvalsCurrent)
        if pvalsCurrent(i) < 1E-3
            starTxt{i} = '***';
        elseif pvalsCurrent(i) < 0.01
            starTxt{i} = '**';
        elseif pvalsCurrent(i) < 0.05
            starTxt{i} = '*';
        else
            starTxt{i} = '';
        end
    end
    
    %% create figure
    figure(ind);
    % bar plot for current fold change data
    b = bar(foldChangeStimCurrent); 
    hold on;
    % overlay with error plot
    errorbar(foldChangeStimCurrent, stanErrorStimCurrent, 'o', 'LineWidth', 1, 'Color', 'red');
    % add reference plot at y = 1
    plot(0:numel(foldChangeStimCurrent)+1, ones(1,numel(foldChangeStimCurrent)+2), '--', 'LineWidth', 1.5, 'Color', 'b');
    % add stars (*) for the p values over significantly different comparisons
    for i = 1:numel(pvalsCurrent)
        y = foldChangeStimCurrent(i) + stanErrorStimCurrent(i) + 0.05;
        text(i,y,starTxt{i},'HorizontalAlignment','Center', 'FontSize', 20, 'Color', [0 .7 0]);
    end
    
    %% format figure
    colors = [[0 .44 .74]; [.85 .32 .1]; [.93 .69 .12]; [.47 .67 .19]; [.64 .08 .18]; [.3 .74 .93];...
        [0 .75 .75]; [1 .55 .69]; [0 .5 0]; [.93 .54 .99]; [.59 .19 1]; [0.6 0.6 0]; [.53 .55 .55]];
        
    xticks(1:numel(xtickCurrent));
    xticklabels(xtickCurrent);
    xtickangle(angle); % angle labels so they are legible
    ylabel('Fold Change');
    ylim([0,2.5]);
    % title based on current data
    if ind == 1
        title('Fold Change, Left Hemi, Stim')
    else
        title('Fold Change, Right Hemi, Stim')
    end
    
    %{
    % add color coded labels for each gene family 
    familyList = unique(familyCurrent,'stable'); % array of all gene families
    counts = [];
    loc = [];
    for i=1:numel(familyList)
        % calculate number of times a gene from each family is present
        counts = [counts, sum(count(familyCurrent, familyList(i)))];
        % find the midpoint of each family cluster
        loc = [loc, ceil((sum(counts(1:i))+sum(counts(1:i-1)))/2)];
        % label each cluster with the family name
        familyText = text(loc(i),-0.2,familyList(i));
        set(familyText,'HorizontalAlignment','Right', 'FontSize', 10,'Rotation',45, 'Color', colors(i,:));
    end
    set(gca,'position',[.05 .3 0.94 0.65]); %position graph so labels are in view
    %}
    
    % add manual legend to graph, color coded to each gene family
    % only add it to the Right Hemi plot
    if ind == 2
        familyList = unique(familyCurrent,'stable');
        vSpace = 9;
        vPos = 0.1;
        for i=1:numel(familyList)
            if i < 7
                rectangle('Position',[13.25,(2.365-vPos)-(i/vSpace),1,0.05],'FaceColor',colors(i,:),'EdgeColor',colors(i,:));
                text(14.5,(2.4-vPos)-(i/vSpace),familyList(i), 'Color', colors(i,:));
            elseif i < 13
                rectangle('Position',[27.25,(2.365-vPos)-((i-6)/vSpace),1,0.05],'FaceColor',colors(i,:),'EdgeColor',colors(i,:));
                text(28.5,(2.4-vPos)-((i-6)/vSpace),familyList(i), 'Color', colors(i,:));
            else
                rectangle('Position',[21.25,(2.365-vPos)-((i-6)/vSpace),1,0.05],'FaceColor',colors(i,:),'EdgeColor',colors(i,:));
                text(22.5,(2.4-vPos)-((i-6)/vSpace),familyList(i), 'Color', colors(i,:));    
            end
        end
    end
        
    % change color of each bar based on gene family
    b.FaceColor = 'flat';
    for i=1:numel(foldChangeStimCurrent)
        if familyCurrent(i) == "Activity dependent Neurotrophic/Vascular Factors"
            b.CData(i,:) = colors(1,:); % blue
        elseif familyCurrent(i) == "Activity dependent Transcription Factors"
            b.CData(i,:) = colors(2,:); % orange
        elseif familyCurrent(i) == "Sustained Plasticity Markers"
            b.CData(i,:) = colors(3,:); % yellow orange
        elseif familyCurrent(i) == "Sustained Growth Inhibitors"
            b.CData(i,:) = colors(4,:); % light green
        elseif familyCurrent(i) == "Extracellular Matrix Molecules"
            b.CData(i,:) = colors(5,:); % maroon 
        elseif familyCurrent(i) == "Inflammation"
            b.CData(i,:) = colors(6,:); % light blue
        elseif familyCurrent(i) == "Inhibitory Synapse/Neurons"
            b.CData(i,:) = colors(7,:); % teal
        elseif familyCurrent(i) == "Excitatory Synapse/Neurons"
            b.CData(i,:) = colors(8,:); % pink
        elseif familyCurrent(i) == "Neuromodulation"
            b.CData(i,:) = colors(9,:); % dark green
        elseif familyCurrent(i) == "Synaptogenesis"
            b.CData(i,:) = colors(10,:); % purple
        elseif familyCurrent(i) == "Dendrites"
            b.CData(i,:) = colors(11,:); % purple
        elseif familyCurrent(i) == "Transporter"
            b.CData(i,:) = colors(12,:); % dark yellow
        else
            b.CData(i,:) = colors(13,:); % gray
        end
    end
end

