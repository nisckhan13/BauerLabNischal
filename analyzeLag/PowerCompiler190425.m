% Power Data Processing Stream
% Choose Mask to use or make new one using Mask Maker
% Run "gcamppowerproc_stich" to generate 15 minute GPOWER file (use "oxypowerproc" if generating oxypower file)
% Run "PowerCompiler190425"-->Use this script to make structure "Week7" etc
% Run "IndivPower" to show powermaps of individual mice
% Adjust master spreadsheet column for "Yes" or "No"
% Re-run "PowerCompiler190425" now with the good animals selected
% Run SNPM_Maris_compare2groups_050319 to statistically compare groups and
Hz = linspace(0,16.81/2,7559);
database = 'C:\Users\albertsona\Box\Aged Backup\Aging Study Master EXCEL.xlsx';  %filepath of Excel database
excelfiles=[3:35];

Week12Power=[]; %Find/replace this structure name throughout
groupz ={'Young','Aged'}; %Find/replace these group names within said structure

outdir= 'H:\Paper Parts\Matlaboutdirectory\';
group1outname='Young';
group2outname='Old';

for qq=1:size(groupz,2)
    group= groupz{qq};
    Week12Power.(group).gpower=[];
    Week12Power.(group).masks=[];
    Week12Power.(group).names =[];
end


for line=excelfiles;
    [~, ~, raw]=xlsread(database,1, ['A',num2str(line),':O',num2str(line)]);
    Date=num2str(raw{1});
    Mouse=num2str(raw{2});
    rawdataloc=raw{3};
    saveloc=raw{4};
    system=raw{5};
    sessiontype='fc';
    group=raw{8};
    keep=raw{10};
    directory=[saveloc, Date, '\'];
    tic
    if strcmp(keep,'No')==1
        continue
    elseif exist([directory, Date,'-', Mouse,sessiontype,'-oxypower.mat'])==2; %Control F and replace with oxypower.mat if doing oxypower or gpower.mat if doing GCAMP
        
        disp(['Loading mouse ',Mouse,' ',sessiontype,' into group ',group])
        load([directory, Date,'-', Mouse,'-LandmarksandMask.mat'],'xform_mask')
        
        Week12Power.(group).masks= cat(3,Week12Power.(group).masks,xform_mask);
        Week12Power.(group).names= cat(2,Week12Power.(group).names,{Mouse});
        
        xform_mask(xform_mask==0)=NaN;
        
        load([directory, Date,'-', Mouse,sessiontype,'-oxypower.mat'],'gpower');
        
        gpower=gpower.*xform_mask;
        gpower(gpower>4)=NaN; %everything about a power of 4 is set to NaN
        Week12Power.(group).gpower = cat(4, Week12Power.(group).gpower, gpower);
        clearvars gpower
        
    else
        disp(['Data not found for  mouse ', Mouse,' ',sessiontype,num2str(run)]);
        
    end
    toc
end;

disp('All Done!')



%%
% POWER MAPS
close all
load(['C:\Users\albertsona\Box\Lab (Zach)\Code for Asher\week0allmask.mat'],'papermask2');
maskx=papermask2;
%uiopen('C:\Users\albertsona\Box\Lab (Zach)\Code for Asher\6. ROIs\White_Background.tiff',1);


for z=1:2 %delta and infraslow loop
    
 
    if z==1 %delta
%         a=0.1; % for delta GCAMP
%         b=0.25; % for delta GCAMP
        a=0.01; % for delta OXY
        b=0.05; % for delta OXY
        range=find(Hz>1&Hz<4); % delta
        outrange='delta';
    elseif z==2 %infraslow
        
%         a=0.2; % for infraslow GCAMP
%         b=2.4; % for infraslow GCAMP
        a=0.0; % for Infraslow OXY
        b=1.2; % for Infraslow OXY
        range=find(Hz>0.02&Hz<0.1); % infraslow
        outrange='infraslow';
    end
  
    
    Hz = linspace(0,16.81/2,7559);
    
    
    
    
    for pp=1:2 %number of groups
        figure
        set(gcf,'units','inches','position',[0 0 3 3]);
        set(gca,'units','inches','position',[0.1 0.1 2.5 2.5]);
        group= groupz{pp};
        
        topopower_individual= squeeze(nanmean(Week12Power.(group).gpower(:,:,range,:),3)); %this generates a 128x128xnumbsubjects array in the specified 'range'
        Groupmasks=Week12Power.(group).masks;
        Groupnames=Week12Power.(group).names;
        %save this to a file for output
        save ([outdir group 'WholeBrainPower' outrange], 'topopower_individual','Groupmasks','Groupnames');
        
        brain= nanmean(nanmean(Week12Power.(group).gpower(:,:,range,:),3),4);
        brain(isnan(brain))=0;
        unicorn = overlaymouse(brain,White_Background,maskx,inferno,a,b);
        imshow(unicorn); caxis([a b]); colormap inferno;
        title(group);
        colorbar ;
        hold on
        
    end;

end %end of delta and infraslow loop

%% Power Traces



figure;
    set(gcf,'units','inches','position',[0 0 5 5]);
    set(gca,'units','inches','position',[0.4 0.5 4.5 4.5]);


Hz = linspace(0,16.81/2,7559);

ROIx= papermask2;
linecolorz={'b','g'};


for pp=1:size(groupz,2)
    group= groupz{pp};

    ROI2 = reshape(ROIx,128*128,1);
    ROImask = find(ROI2);
    brain = squeeze(nanmean(Week12Power.(group).gpower(:,:,:,:),4));
    brain = reshape(brain,128^2,[]);
    brain = brain(ROImask,:);
    brain = squeeze(mean(brain,1));
    %         brain = log(brain);
%     tittle= group;
                color=linecolorz{pp};

    loglog(Hz,brain,'linewidth',1,'color',[color]); ylabel('Power (A.U.)'); xlabel('Freq (Hz)'); title(tittle);
    axis square
    xlim([0.01,3.8]);
    xticks([0.01,0.1,1,2,5,8]);
    ylim([0.05, 5]);
    
    
    
    hold on
    
end;