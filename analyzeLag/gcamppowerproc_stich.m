database = 'E:\Week 0 Aged and Young Master.xlsx';  %filepath of Excel database
excelfiles=[40];


for line=excelfiles;
    tic
    [~, ~, raw]=xlsread(database,1, ['A',num2str(line),':K',num2str(line)]);
    Date=num2str(raw{1});
    Mouse=num2str(raw{2});
    rawdataloc=raw{3};
    saveloc=raw{4};
    system=raw{5};
    sessiontype='fc';
    directory=[saveloc, Date, '\'];
    
    
    run=1;
    
    clear gcamp6all xform_mask gcampx gcamp gcamp6corr
    gcamplong=[];
    
    load([directory, Date,'-', Mouse,'-LandmarksandMask.mat'],'xform_mask')
    %     if exist([directory, Date,'-', Mouse,'-dataGCaMP-',sessiontype,num2str(run),'.mat']) ==2
    
    for s=1:3 %Change to the number of runs you have for that mouse
        if exist([directory, Date,'-', Mouse,'-dataGCaMP-',sessiontype,num2str(s),'.mat']) ==2
            disp(['Loading mouse ',Mouse,' ',sessiontype,num2str(s)])
            load([directory, Date,'-', Mouse,'-dataGCaMP-',sessiontype,num2str(s),'.mat'],'gcamp6corr');
            gcampx = reshape(gcamp6corr, 128,128,1,[]);
            gcampx = gsr_stroke2(gcampx, xform_mask);
            gcampx = reshape(gcampx, 128^2,[]);
            gcamplong = cat(2,gcamplong, gcampx);
            
        end
    end
    
    length = size (gcamplong,2);
    gpower = zeros(128^2,ceil(length/2));
    
    for pp =1:128^2
        fft1=fft(gcamplong(pp,:));
        mags = abs(fft1);
        mags = mags(1:ceil(length/2));
        gpower(pp,:) =  mags;
        
        
    end
    
    gpower=reshape(gpower,128,128,ceil(length/2));
    
    
    save([directory, Date,'-', Mouse,sessiontype,'-gpower.mat'],'-v7.3','gpower');
    
    
    
    clearvars gcamp6corr length  gcampx  gpower mags fft1
    toc
    run=run+1;
end

clearvars xform_mask


disp('All Done!')

%%

