%% load data gen-0
excelDataLocAnes = 'E:\DLC-Working\Thy1_Front-Bauer-2019-09-29\processed-data\generation-0\A14_M3_Front_0001_anesDeepCut_resnet50_Thy1_FrontSep29shuffle1_300000.csv';
excelDataLocAwake = 'E:\DLC-Working\Thy1_Front-Bauer-2019-09-29\processed-data\generation-0\A14_M3_Front_0001_awakeDeepCut_resnet50_Thy1_FrontSep29shuffle1_300000.csv';

dataAnes = xlsread(excelDataLocAnes);
dataAwake = xlsread(excelDataLocAwake);

totalFramesAnes = length(dataAnes(:,1));
totalFramesAwake = length(dataAwake(:,1));

disp('done 1');

%% load data gen-1
excelDataLocAnes = 'E:\DLC-Working\Thy1_Front-Bauer-2019-09-29\processed-data\generation-1\A14_M3_Front_0001_anesDeepCut_resnet50_Thy1_FrontSep29shuffle1_300000.csv';
excelDataLocAwake = 'E:\DLC-Working\Thy1_Front-Bauer-2019-09-29\processed-data\generation-1\A14_M3_Front_0001_awakeDeepCut_resnet50_Thy1_FrontSep29shuffle1_300000.csv';

dataAnes = xlsread(excelDataLocAnes);
dataAwake = xlsread(excelDataLocAwake);

totalFramesAnes = length(dataAnes(:,1));
totalFramesAwake = length(dataAwake(:,1));

disp('done 2');


%% choose Anes Awake

mouse = 1; %0=anes, 1=awake
threshold = 0.95;

if mouse == 1
    disp('awake');
    data = dataAwake;
    totalFrames = totalFramesAwake;
else
    disp('anes');
    data = dataAnes;
    totalFrames = totalFramesAnes;
end

disp('done choice');

%% compute left
currCol = 4;
currDig = 1;
countFramesL = zeros(7,1);
while currCol <= 22
    for ind=1:totalFrames
        if data(ind,currCol) < threshold
            countFramesL(currDig,1) = countFramesL(currDig,1)+1;
        end
    end
    currCol = currCol + 3;
    currDig = currDig + 1;
end

percFramesL = (countFramesL/totalFrames)*100;

disp('done 2');

%% compute Right
currCol = 19;
currDig = 1;
countFramesR = zeros(5,1);
while currCol <= 31
    for ind=1:totalFrames
        if data(ind,currCol) < threshold
            countFramesR(currDig,1) = countFramesR(currDig,1)+1;
        end
    end
    currCol = currCol + 3;
    currDig = currDig + 1;
end

percFramesR = (countFramesR/totalFrames)*100;

disp('done 2');


%% plot Left
% color = [];

% for ind=1:5
%     if ind==5
%         color = cat(4,color,[0.7 1 0]);
%     else
%         color = cat(4,color,[1 ind/4 0]);
%     end
% end

% for ind=1:5
%     if ind==5
%         color = cat(4,color,[0 1 0.7]);
%     else
%         color = cat(4,color,[0 ind/4 1]);
%     end
% end

LFig = figure(1);
set(LFig,'Position',[300 100 1500 800]);
plot(data(:,1),ones(totalFrames,1)*threshold,'color','black','linewidth',2);
hold on;
currCol = 4;
for ind=1:5
    
%     scatter(dataL(:,1),dataL(:,currCol), [], color(:,:,:,ind), 'filled');
    scatter(data(:,1),data(:,currCol), 'filled');
    currCol = currCol + 3;

end

ylim([0 1.2]);
xlim([0 totalFrames]);
ax = gca;
ax.XRuler.Exponent = 0;
legend({'Threshold', 'Wrist', 'Dig1Med', 'Dig2', 'Dig3', 'Dig4Lat'},'Position',[0.9077 0.5 0.09 0.15]);
xlabel('Frame');
ylabel('Network Confidence Likelihood');
set(LFig,'color','w');
set(gca, 'FontSize', 16);

disp('done 3');

%% plot right
% color = [];

% for ind=1:5
%     if ind==5
%         color = cat(4,color,[0.7 1 0]);
%     else
%         color = cat(4,color,[1 ind/4 0]);
%     end
% end

% for ind=1:5
%     if ind==5
%         color = cat(4,color,[0 1 0.7]);
%     else
%         color = cat(4,color,[0 ind/4 1]);
%     end
% end

RFig = figure(1);
set(RFig,'Position',[300 100 1500 800]);
plot(data(:,1),ones(totalFrames,1)*threshold,'color','black','linewidth',2);
hold on;
currCol = 19;
for ind=1:5
    
%     scatter(dataL(:,1),dataL(:,currCol), [], color(:,:,:,ind), 'filled');
    scatter(data(:,1),data(:,currCol), 'filled');
    currCol = currCol + 3;

end

ylim([0 1.2]);
xlim([0 totalFrames]);
ax = gca;
ax.XRuler.Exponent = 0;
legend({'Threshold', 'RWrist', 'RDig1Med', 'RDig2', 'RDig3', 'RDig4Lat'},'Position',[0.9077 0.5 0.089 0.15]);
xlabel('Frame');
ylabel('Network Confidence Likelihood');
set(RFig,'color','w');
set(gca, 'FontSize', 16);

disp('done 3');

%% plot per gen
figure('Position', [100 100 1500 400], 'color','w');
gens = [0 1];
digits = {'elbow', 'hand', 'wrist', 'dig1Med', 'dig2', 'dig3', 'dig4Lat'};
for i=1:length(gen0anes)
    subplot(1, length(gen0anes),i);
    vals = [gen0anes(i) gen1anes(i)];
    plot(gens,vals,'-o');
    xlabel('Generation');
    ylabel('Frames Below Thresh');
    title([digits{i} ' 95% Thresh']);
    xlim([-1 2]);
    ylim([0 150]);
end

%% plot per gen
figure('Position', [100 100 1500 400], 'color','w');
gens = [0 1];
digits = {'elbow', 'hand', 'wrist', 'dig1Med', 'dig2', 'dig3', 'dig4Lat'};
for i=1:length(gen0anes)
    subplot(1, length(gen0anes),i);
    vals = [gen0awake(i) gen1awake(i)];
    plot(gens,vals,'-o');
    xlabel('Generation');
    ylabel('Frames Below Thresh');
    title([digits{i} ' 95% Thresh']);
    xlim([-1 2]);
    ylim([400 5800]);
end