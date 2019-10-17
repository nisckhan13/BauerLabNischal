%% set paramteres anes

vidFile = "E:\DLC-Working\Thy1_Front-Bauer-2019-09-29\processed-data\novel\A15_M2_Front_0001_anesDeepCut_resnet50_Thy1_FrontSep29shuffle1_300000_labeled.mp4";
startPoint = 25200;
endPoint = 25800;
secOrFrame = 1; % 0 if start/endPoints are in seconds, 1 if they're in frames 
outputFR = 100;
saveDest = 'D:\ProcessedData\DLC_Data\movies_novel';
saveName = 'A15_M2_Front_0001_anes_novel';

videos.cropMovie(vidFile,startPoint,endPoint,secOrFrame,outputFR,saveDest,saveName);

%% set paramteres anes

vidFile = "E:\DLC-Working\Thy1_Front-Bauer-2019-09-29\processed-data\novel\A20_M2_Front_0002_anesDeepCut_resnet50_Thy1_FrontSep29shuffle1_300000_labeled.mp4";
startPoint = 25200;
endPoint = 25800;
secOrFrame = 1; % 0 if start/endPoints are in seconds, 1 if they're in frames 
outputFR = 100;
saveDest = 'D:\ProcessedData\DLC_Data\movies_novel';
saveName = 'A20_M2_Front_0002_anes_novel';

videos.cropMovie(vidFile,startPoint,endPoint,secOrFrame,outputFR,saveDest,saveName);


%% set paramteres awake

vidFile = "E:\DLC-Working\Thy1_Side-Bauer-2019-09-26\processed-data\novel_A15_M2\A15_M2_Side_0001_awakeDeepCut_resnet50_Thy1_SideSep26shuffle1_300000_labeled.mp4";
startPoint = 10000;
endPoint = 10300;
secOrFrame = 1; % 0 if start/endPoints are in seconds, 1 if they're in frames 
outputFR = 20;
saveDest = 'D:\ProcessedData\DLC_Data\movies_Sidedb';
saveName = 'A15_M2_Side_0001_awake_gen1';

videos.cropMovie(vidFile,startPoint,endPoint,secOrFrame,outputFR,saveDest,saveName);