%% load data
filepath1 = "E:\DLC-Working\Thy1_Side-Bauer-2019-09-26\dlc-models\iteration-0\Thy1_SideSep26-trainset95shuffle1\train\learning_stats.csv";
filepath2 = "E:\DLC-Working\Thy1_Side-Bauer-2019-09-26\dlc-models\iteration-1\Thy1_SideSep26-trainset95shuffle1\train\learning_stats.csv";
filepath3 = "E:\DLC-Working\Thy1_Side-Bauer-2019-09-26\dlc-models\iteration-2\Thy1_SideSep26-trainset95shuffle1\train\learning_stats.csv";
filepath4 = "E:\DLC-Working\Thy1_Side-Bauer-2019-09-26\dlc-models\iteration-3\Thy1_SideSep26-trainset95shuffle1\train\learning_stats.csv";

data1 = xlsread(filepath1, 'learning_stats');
data2 = xlsread(filepath2, 'learning_stats');
data3 = xlsread(filepath3, 'learning_stats');
data4 = xlsread(filepath4, 'learning_stats');

data = [data1 data2 data3 data4];
disp('done');

%% plot data

figure(1);
set(figure(1),'Position',[300 300 600 400]);
ind = 1;
for i = 1:1
    currDat = data(:,ind:ind+2);
    plot(currDat(:,1),currDat(:,2));
    ind = ind + 3;
    hold on;
end

ylabel('Cross-entropy loss');
xlabel('Training iterations');
ylim([0 0.014]);
xlim([-25000 300000]);
ax = gca;
ax.XRuler.Exponent = 0;
set(gca, 'FontSize', 12);
% legend('Gen0', 'Gen1', 'Gen2', 'Gen3');
set(figure(1),'color','w');
title('Loss');


%% quick plot

fileID = fopen('prahl_extinct_coef.txt');
A = textscan(fileID,'%f %f %f');

figure(1);
set(gcf,'Position',[300 100 1500 800]);
plot(A{1},A{2}, 'color', 'red');
hold on;
plot(A{1},A{3}, 'color', 'blue');
set(gcf,'color','w');
set(gca, 'FontSize', 16);
xlabel('wavelength (nm)');
set(gca, 'YScale', 'log')
ylabel('ext coeff (cm-1/M)');
legend('oxy', 'deoxy');

%% make movie anes org
vidFile = 'E:\DLC-Working\Thy1_RightPaw-Bauer-2019-09-19\processed-data\generation-8\A14_M3_Front_0001_anesDeepCut_resnet50_Thy1_RightPawSep19shuffle1_300000_labeled.mp4';
startPoint = 25200;
endPoint = 25800;
secOrFrame = 1;
outputFR = 50;
saveDest = 'D:\ProcessedData\DLC_Data\movies_9_26';
saveName = 'A14_M3_anes_crop';

videos.cropMovie(vidFile,startPoint,endPoint,secOrFrame,outputFR,saveDest, saveName);

%% make movie awake org
vidFile = 'E:\DLC-Working\Thy1_RightPaw-Bauer-2019-09-19\processed-data\generation-8\A14_M3_Front_0001_awakeDeepCut_resnet50_Thy1_RightPawSep19shuffle1_300000_labeled.mp4';
startPoint = 10000;
endPoint = 10300;
secOrFrame = 1;
outputFR = 20;
saveDest = 'D:\ProcessedData\DLC_Data\movies_9_26';
saveName = 'A14_M3_awake_crop';

videos.cropMovie(vidFile,startPoint,endPoint,secOrFrame,outputFR,saveDest, saveName);

%% make movie anes novel
vidFile = 'E:\DLC-Working\Thy1_RightPaw-Bauer-2019-09-19\processed-data\generation-8\A15_M2_Front_0001_anesDeepCut_resnet50_Thy1_RightPawSep19shuffle1_300000_labeled.mp4';
startPoint = 13500;
endPoint = 13800;
secOrFrame = 1;
outputFR = 50;
saveDest = 'D:\ProcessedData\DLC_Data\movies_9_26';
saveName = 'A15_M2_anes_crop';

videos.cropMovie(vidFile,startPoint,endPoint,secOrFrame,outputFR,saveDest, saveName);

%% make movie awake novel
vidFile = 'E:\DLC-Working\Thy1_RightPaw-Bauer-2019-09-19\processed-data\generation-8\A15_M2_Front_0001_awakeDeepCut_resnet50_Thy1_RightPawSep19shuffle1_300000_labeled.mp4';
startPoint = 13100;
endPoint = 13450;
secOrFrame = 1;
outputFR = 20;
saveDest = 'D:\ProcessedData\DLC_Data\movies_9_26';
saveName = 'A15_M2_awake_crop';

videos.cropMovie(vidFile,startPoint,endPoint,secOrFrame,outputFR,saveDest, saveName);

%% make movie anes novel
vidFile = 'E:\DLC-Working\Thy1_RightPaw-Bauer-2019-09-19\processed-data\generation-8\A15_M1_Front_0001_anesDeepCut_resnet50_Thy1_RightPawSep19shuffle1_300000_labeled.mp4';
startPoint = 15600;
endPoint = 15900;
secOrFrame = 1;
outputFR = 50;
saveDest = 'D:\ProcessedData\DLC_Data\movies_9_26';
saveName = 'A15_M1_anes_crop';

videos.cropMovie(vidFile,startPoint,endPoint,secOrFrame,outputFR,saveDest, saveName);

%% make movie awake novel
vidFile = 'E:\DLC-Working\Thy1_RightPaw-Bauer-2019-09-19\processed-data\generation-8\A15_M1_Front_0001_awakeDeepCut_resnet50_Thy1_RightPawSep19shuffle1_300000_labeled.mp4';
startPoint = 10800;
endPoint = 11100;
secOrFrame = 1;
outputFR = 20;
saveDest = 'D:\ProcessedData\DLC_Data\movies_9_26';
saveName = 'A15_M1_awake_crop';

videos.cropMovie(vidFile,startPoint,endPoint,secOrFrame,outputFR,saveDest, saveName);
























