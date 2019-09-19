%% input parameters
clear;

age = 'Aged'; % Young or Aged
allYoungMice = ["181116-1" "181116-2" "181116-4" "181116-6" "181116-7" "181116-8"...
    "181116-9" "181116-10" "181115-2046" "181115-2047" "181115-2048" "181115-2049"...
    "181115-2053" "181115-2055"];
allAgedMice = ["180917-422" "180917-424" "180917-425" "180917-426" "180917-427" "180917-450"...
    "180917-452" "180917-459" "180917-461" "180918-309"...
    "180918-442" "180918-446" "180918-447"];


%% Load in all of the masks

if strcmp(age,'Aged')
    allMice = allAgedMice;
    disp('----- AGED -----');
else
    allMice = allYoungMice;
    disp('----- YOUNG -----');
end

allMaskData = [];

tic;
for ind = 1:length(allMice)
    
    mouseInfo = split(char(allMice(ind)),'-');
    ds = mouseInfo{2}; % which mice dataset
    dateDS = mouseInfo{1}; % which date

    currRunLoc = ['E:\Data_for_Kenny\' age '_Animals\' age '_Week_0\' dateDS...
        '\Processed' dateDS '\' dateDS '-' ds '-week0-LandmarksandMask.mat'];      
    if exist(currRunLoc, 'file')
        disp(['- ' char(allMice(ind)) '-week0']);
        currRun = load(currRunLoc);
        allMaskData = [allMaskData currRun];
    end
    
end
toc;

%% compute average mask for Asher's data

% load our standard mask
paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

asherIntersect = 1;
% compute intersect of Asher's masks
for i=1:length(allMaskData)
    asherIntersect = asherIntersect.*allMaskData(i).xform_mask;
end

% multiply intersect with our mask
finalMask = asherIntersect.*meanMask;

% save the mask
saveFinalMask = ['D:\ProcessedData\AsherLag\finalDotLagSave\finalMask' age '.mat'];
save(saveFinalMask,'finalMask','age');




