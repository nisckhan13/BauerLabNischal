database = 'E:\Week 0 Aged and Young Master.xlsx'; %filepath of Excel database
excelfiles=[71:73]; %Rows from Excel database to actually process

for line=excelfiles;
    [~, ~, raw]=xlsread(database,1, ['A',num2str(line),':K',num2str(line)]);
    Date=num2str(raw{1});
    Mouse=num2str(raw{2});
    rawdataloc=raw{3};
    saveloc=raw{4};
    directory=[saveloc, Date, '\'];
    
    if exist([directory, Date,'-', Mouse,'-LandmarksandMask.mat'])
        disp(['Landmarks and mask file already exists for ', Date,'-', Mouse])
        continue
    else
        if ~exist(directory);
            mkdir(directory);
        end
        
        filename=[rawdataloc,Date,'\',Date,'-', Mouse,'-fc1.tif'];
        if ~exist(filename);
            filename=[rawdataloc,Date, '\',Date,'-', Mouse,'-stim1.tif'];
            if ~exist(filename);
                disp(['Data for ', rawdataloc,Date,'-', Mouse, ' not found'])
            end
        end
        
        
        WL=[];
        i=0;
        
        for k = [5, 6,7];    %make WL image optimized for sutures (g, r, y channels)
            i=i+1;
            WL(:,:,i) = imresize(fliplr(imread(filename,k)), [128 128]);
        end
        
        WL(:,:,1)=WL(:,:,1)/max(max(WL(:,:,1))); %scale the max m
        WL(:,:,2)=WL(:,:,2)/max(max(WL(:,:,2)));
        WL(:,:,3)=WL(:,:,3)/max(max(WL(:,:,3)));
        
        disp([Date,'-', Mouse])
        
        [I, seedcenter]=MakeSeedsMouseSpace(WL);
        
        
        
        WL=[];
        i=0;
        
        
        for k = [8,7,7];    %make WL image that actually looks good (g, r, y channels)
            i=i+1;
            WL(:,:,i) = imresize(fliplr(imread(filename,k)), [128 128]);
        end
        
        WL(:,:,1)=WL(:,:,1)/max(max(WL(:,:,1))); %scale the max m
        WL(:,:,2)=WL(:,:,2)/max(max(WL(:,:,2)));
        WL(:,:,3)=WL(:,:,3)/max(max(WL(:,:,3)));
        
        
        
        disp('Create mask')
        mask=roipoly(WL);
        
        if ~any(any(mask))
            load('C:\Users\rosenthalz\Box Sync\Lab (Zach)\Code\Inherited\Paxinos\AtlasandIsbrain.mat', 'parcelisbrainPS');
            isbrain=InvAffine(I, parcelisbrainPS, 'New');
            isbrain=single(uint8(isbrain));
            [xform_isbrain]=Affine(I, isbrain, 'New');
            xform_isbrain=single(uint8(xform_isbrain));
            
            [xform_WL]=Affine(I, WL, 'New');
            
            for j=1:3;
                xform_WLcrop(:,:,j)=xform_WL(:,:,j).*parcelisbrainPS; %make affine transform WL image
            end
            
            WLcrop=WL;
            for j=1:3;
                WLcrop(:,:,j)=WLcrop(:,:,j).*isbrain; %make WLcrop image
            end
            
        else
            
            mask=single(uint8(mask));
            [xform_mask]=Affine(I, mask, 'New');
            xform_mask=single(uint8(xform_mask));
            
            [xform_WL]=Affine(I, WL, 'New');
            
            for j=1:3;
                xform_WLcrop(:,:,j)=xform_WL(:,:,j).*xform_mask; %make affine transform WL image
            end
            
            WLcrop=WL;
            for j=1:3;
                WLcrop(:,:,j)=WLcrop(:,:,j).*mask; %make WLcrop image
            end
        end
        
        imagesc(xform_WLcrop);
        
        pause;
        
        save([directory, Date,'-', Mouse,'-LandmarksandMask.mat'], 'WLcrop', 'xform_WLcrop', 'xform_mask', 'mask', 'WL', 'xform_WL', 'I', 'seedcenter');
        
    end
    close all
end
%%

poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    parpool('local',4)
end
%%
dark=single(imread('Dark.tif'));
%%
for line=excelfiles;
    
    clearvars mask xform_mask WL xform_WL W AntSut Lambda Mouse sessiontype info; %in case you have variables carrying over from previous mice or runs%
    
    [~, ~, raw]=xlsread(database,1, ['A',num2str(line),':F',num2str(line)]);
    Date=num2str(raw{1});
    Mouse=num2str(raw{2});
    rawdatadir=raw{3};
    saveloc=raw{4};
    sessiontype=eval(raw{6});
    rawdataloc=[rawdatadir, Date, '\'];
    directory=[saveloc, Date, '\'];
    
    load([directory, Date,'-', Mouse,'-LandmarksandMask.mat'],'I', 'mask', 'WL');
    
    AntSut = I.OF;
    Lambda = I.tent;
    
    for t=1:numel(sessiontype);
        
        info.framerate=16.81;
        info.numled=4;
        info.lowpass=5;
        info.freqout = 1;
        
        tic
        
        WorkingGCAMP6_ProcessingForLindsey(mask,AntSut,Lambda,rawdataloc,Mouse, directory, Date, WL,sessiontype{t},dark, info)
        
        toc
    end
end
disp ('All done!')
