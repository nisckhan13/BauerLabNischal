function WorkingGCAMP6_ProcessingForLindsey(mask,AntSut,Lambda,rawdataloc,Mouse, directory, Date, WL,sessiontype,dark,info)

run=0;
while 1 %this loop will execute as long as a run is found
    run= run+1;
    
    
    while exist([directory, Date,'-', Mouse,'-dataGCaMP-',sessiontype,num2str(run),'.mat'],'file') ==2 %checks to see if the raw data were already processed
        disp([Mouse,'-',sessiontype,num2str(run),' Already processed'])
        run=run+1;
        assignin('base','run', run)
    end
    
    loopfile= [rawdataloc,'\',Date,'-', Mouse,'-',sessiontype,num2str(run),'.tif'];
    
    if ~exist(loopfile,'file') % increments run number if you skipped a run
        run=run+1;
        
        loopfile=[rawdataloc,'\',Date,'-', Mouse,'-',sessiontype,num2str(run),'.tif'];
        
        if exist  ([directory, Date,'-', Mouse,'-dataGCaMP-',sessiontype,num2str(run),'.mat'],'file') ==2
            run=run+1;
        end
            
        loopfile=[rawdataloc,'\',Date,'-', Mouse,'-',sessiontype,num2str(run),'.tif'];

        if ~exist(loopfile,'file') %stops executing loop if more than one  run was skipped.
            disp([' **** No more data found for ', Mouse, ' ',sessiontype,' ****'])
            clearvars xform_mask WL xform_WL W sessiontype;
            break
        end
        
    end
    
    
    disp(['Processing ',Mouse,' ',sessiontype,' Run ',num2str(run)]);
    
    close all;
    
    %Construct string associated with specific filenames. Update drive path
    
    filename=[rawdataloc,Date,'-', Mouse,'-',sessiontype,num2str(run),'.tif'];

    %This was the original filename locator with the '\' 
    %filename=[rawdataloc,'\',Date,'-',Mouse,'-',sessiontype,num2str(run),'.tif'];  
     
    %Get optical properties (Extinction/absorption coefficients, etc)
    disp('Getting Optical Properties')
    [op, E]=getop;
    
    
    %Load raw data (.tif)
    disp('Loading Data')
    disp(filename)
    
    [rawdata]=getoisdata(filename);
    
    
    if exist([filename(1:(end-4)),'_X2',filename((end-3):end)],'file')
        disp('Appending X2')
        
        [rawdata2]=getoisdata([filename(1:(end-4)),'_X2',filename((end-3):end)]);
        rawdata=cat(3,rawdata,rawdata2); clear rawdata2
    end
    
    if exist([filename(1:(end-4)),'_X3',filename((end-3):end)],'file')
        disp('Appending X3')
        
        [rawdata3]=getoisdata([filename(1:(end-4)),'_X3',filename((end-3):end)]);
        rawdata=cat(3,rawdata,rawdata3); clear rawdata3
    end
   
    
    rawdata=double(rawdata);
    
    
    [nVy, nVx, L]=size(rawdata);
    L2=L-rem(L,info.numled);
    rawdata=rawdata(:,:,1:L2);
    info.nVx=nVx;
    info.nVy=nVy;
    
    
    %Subtract dark/background frame (ie no lights). We upload dark
    %frame in the wrapper
    for z=1:L2;
        raw(:,:,z)=abs(rawdata(:,:,z)-dark);
    end
    
    
    %Reshape the data, adding a dimension for individiual LED channels
    rawdata=reshape(raw,info.nVy,info.nVx,info.numled,[]);
    
    % Cut off bad first set of frames
    rawdata=rawdata(:,:,:,2:end);
    [nVy,nVx,C,T]=size(rawdata); %nVx and nVy are 128 x * 128 y pixels, C is 4 color channels, T is time
    
    
    % New De-trending test: linear temporal de-trend by pixel, followed by spatial detrend
    
    rawdata_rs = reshape(rawdata,nVy*nVx*C,T); %Reshape to apply matlab detrend function
    
    warning('Off');
    
    timetrend = single(zeros(size(rawdata_rs))); %initializing
    
    for ii=1:size(rawdata_rs,1)
        timetrend(ii,:)=polyval(polyfit(1:T, rawdata_rs(ii,:), 4), 1:T); %This is doing a 4th order fit (polyfit), then evaluating at each time (polyval)
    end
    
    warning('On');
    timetrend = reshape(timetrend,nVy,nVx,C,T); %Pixel-wise fits
    timedetrend=bsxfun(@rdivide,rawdata,timetrend);
    
    spattrend=bsxfun(@rdivide,mean(timedetrend,4),mean(mean(mean(timedetrend,4))));
    fulldetrend=bsxfun(@rdivide,timedetrend,spattrend);
    
    [fulldetrend2, ~, xform_WL, xform_mask]=  WorkingAffine_gcamp6(fulldetrend, WL, mask, AntSut, Lambda);
    
    
    %Separate data into different channels. Rawdata is data from the green, yellow, and
    %red LEDs to be used to do oximetry. GCAMP6 is the raw fluorescence
    %emission channel. Green is the green channel on its own (used for the
    %ratiometric fluroescence correction to remove hemodynamic confound)
    
    rawdata=fulldetrend2(:,:,2:4,:);
    gcamp6=double(squeeze(fulldetrend2(:,:,1,:)));
    green=double(squeeze(fulldetrend2(:,:,2,:)));
    
    %Initializing
    data_dot=zeros(128,128,2,length(rawdata));
    %     gcamp6norm=zeros(128,128,length(gcamp6));
    %     greennorm=zeros(128,128,length(green));
    %
    
    
    %     Ratiometric correction (mean normalization first, then ratio of gcamp to
    %     green) RESHAPE
    %     for x=1:128
    %         for y=1:128
    %             gcamp6norm(x,y,:)=gcamp6(x,y,:)/mean(gcamp6(x,y,:)); %do mode instead? or no centering?
    %             greennorm(x,y,:)=green(x,y,:)/mean(green(x,y,:));
    %         end
    %     end
    
    %     gcamp6corr=gcamp6norm./greennorm;%gcamp6corr is the gcamp6 fluorescence signal corrected for the hemodynamic confound
    
    %    gcamp6corr=gcamp6./green;
    
    
    %"Process" the data--procPixel used for filtering and oximetry
    info.T1=size(rawdata,4);
    
    info.numled=3; %just decreasing this temporarily to 3 for oximetry, will revert back to 4 later
    
    xsize=info.nVx;
    ysize=info.nVy;
    
    for x=1:xsize
        for y=1:ysize
            [data_dot(y,x,:,:)]=procPixel(squeeze(rawdata(y,x,:,:)),op, E, info,sessiontype);
            
            bluemua_init(y,x,1,:)=op.blueLEDextcoeff(1)*data_dot(y,x,1,:);
            bluemua_init(y,x,2,:)=op.blueLEDextcoeff(2)*data_dot(y,x,2,:);
            bluemua_f(y,x,:)=bluemua_init(y,x,1,:)+bluemua_init(y,x,2,:);
            greenmua_init(y,x,1,:)=op.greenLEDextcoeff(1)*data_dot(y,x,1,:);
            greenmua_init(y,x,2,:)=op.greenLEDextcoeff(2)*data_dot(y,x,2,:);
            greenmua_f(y,x,:)=greenmua_init(y,x,1,:)+greenmua_init(y,x,2,:);
            %gcamp6corr(y,x,:)=(exp(-(bluemua_f(y,x,:).*(.56)+greenmua_f(y,x,:).*(.57)))).*gcamp6norm(y,x,:)./gcamp6(y,x,:);
            gcamp6corr(y,x,:)=gcamp6(y,x,:)./(exp(-(bluemua_f(y,x,:).*(.056)+greenmua_f(y,x,:).*(.057))));
            e(y,x,:)=(exp(-(bluemua_f(y,x,:).*(.056)+greenmua_f(y,x,:).*(.057))));
            
            gcamp6corr(y,x,:)=procPixel2(squeeze(gcamp6corr(y,x,:))',op,E,info,sessiontype);
            gcamp6(y,x,:)=procPixel2(squeeze(gcamp6(y,x,:))',op,E,info,sessiontype);
            green(y,x,:)=procPixel2(squeeze(green(y,x,:))',op,E,info,sessiontype);
            
        end
    end
    
    
    info.numled=4; %because we switched it to 3 for oximetry, back to 4 now for looping back through
    
    data_dot(isnan(data_dot))=0;
    gcamp6corr(isnan(gcamp6corr))=0;
    gcamp6(isnan(gcamp6))=0;
    green(isnan(green))=0;
    
    data_dot(isinf(data_dot))=0;
    gcamp6corr(isinf(gcamp6corr))=0;
    gcamp6(isinf(gcamp6))=0;
    green(isinf(green))=0;
    
    %Spatial smoothing
    disp('Spatial smoothing')
    
    data_dot=smoothimage(data_dot,5,1.2);
    gcamp6corr=smoothimage(gcamp6corr,5,1.2);
    gcamp6=smoothimage(gcamp6,5,1.2);
    green=smoothimage(green,5,1.2);
    
    %     gcamp6all=permute(cat(4,gcamp6corr, gcamp6), [1 2 4 3]);
    
    %Global signal regression (regress the mean time series across the brain from all time
    %series) SHOULD NOT BE PART OF THIS CODE
    
    %     if strcmp(sessiontype, 'fc')
    %         disp(['No GSR on this fc bad boy']);
    oxy=squeeze(data_dot(:,:,1,:));
    deoxy=squeeze(data_dot(:,:,2,:));
    %     elseif strcmp(sessiontype, 'stim')
    %         disp('GSR for stim')
    %         [oxy deoxy]=gsr_stroke3(data_dot, xform_mask);
    %         gcamp6all=gsr_stroke2(gcamp6all, xform_mask);
    %         green=gsr_strokegreen(green, xform_mask);
    %     end
    
    % Downsample here if you must
    %     oxy=resampledata(oxy,info.framerate,info. ,10^-5);
    %     deoxy=resampledata(deoxy,info.framerate,info.freqout,10^-5);
    
    %Save the data
    
    save([directory, Date,'-', Mouse,'-dataGCaMP-',sessiontype,num2str(run)],'-v7.3','oxy', 'deoxy','gcamp6','gcamp6corr','green','xform_mask','xform_WL','info');
    
    
    %%run QC
%                 assignin('base','rawdata_rs', rawdata_rs)
%             assignin('base','fulldetrend', fulldetrend)
%             assignin('base','mask', mask)
%             assignin('base','info', info)
%             assignin('base','Mouse', Mouse)
%             assignin('base','run', run)
%             assignin('base','xform_mask', xform_mask)
%             assignin('base','xform_WL', xform_WL)
%             assignin('base','gcamp6corr', gcamp6corr)
%             assignin('base','oxy', oxy)
%             assignin('base','directory', directory)
%             assignin('base','date', date)
%             assignin('base','sessiontype', sessiontype)

        warning('Off');

gcampqc(rawdata_rs,fulldetrend,mask,info,Mouse,sessiontype,run,xform_mask,xform_WL, gcamp6corr, oxy, directory, Date);
    warning('On');

clear oxy deoxy gcamp6all fulldetrend fulldetrend2 rawdata rawdata2 gcamp6all...
        green gcamp6 data_dot greennorm gcamp6norm timedetrend timetrend spattrend; close all;
end
end



%% getoisdata()
function [data]=getoisdata(fileall)

[filepath,filename,filetype]=interppathstr(fileall);
%assignin('base','path',filepath); assignin('base','name',filename); return

if ~isempty(filetype) && ~(strcmp(filetype,'tif') || strcmp(filetype,'sif') )
    error('** procOIS() only supports the loading of .tif and .sif files **')
else
    if exist([filepath,'/',filename,'.tif'])
        data=readtiff([filepath,'/',filename,'.tif']);
    elseif exist([filepath,'/',filename,'.sif'])
        data=readsif([filepath,'/',filename,'.sif']);
    end
end

end


%% readtiff()
function [data]=readtiff(filename)

info = imfinfo(filename);
numI = numel(info);
data=zeros(info(1).Width,info(1).Height,numI,'uint16');
fid=fopen(filename);

fseek(fid,info(1).Offset,'bof');
for k = 1:numI
    
    fseek(fid,[info(1,1).StripOffsets(1)-info(1).Offset],'cof');
    tempdata=fread(fid,info(1).Width*info(1).Height,'uint16');
    data(:,:,k) = rot90((reshape(tempdata,info(1).Width,info(1).Height)),-1); %% changed 3/2/11
end

fclose(fid);

end

%% smoothimage()
function [data2]=smoothimage(data,gbox,gsigma)

[nVy, nVx, cnum, T]=size(data);

%Gaussian box filter center
x0=ceil(gbox/2);
y0=ceil(gbox/2);

%Make Gaussian filter
G=zeros(gbox);
for x=1:gbox
    for y=1:gbox
        G(x,y)=exp((-(x-x0)^2-(y-y0)^2)/(2*gsigma^2));
    end
end

%Normalize Gaussian to 1
G=G/sum(sum(G));

%Initialize
data2=zeros(nVx,nVy,cnum,T);

%Convolve data with filter
for c=1:cnum
    for t=1:T
        data2(:,:,c,t)=conv2(squeeze(data(:,:,c,t)),G,'same');
    end
end

end


%% getop()
function [op, E, numled, led]=getop

[lambda1, Hb]=getHb;
[led,lambda2]=getLED;

op.HbT=76*10^-3; % uM concentration
op.sO2=0.71; % Oxygen saturation (%/100)
op.BV=0.1; % blood volume (%/100)

op.nin=1.4; % Internal Index of Refraction
op.nout=1; % External Index of Refraction
op.c=3e10/op.nin; % Speed of Light in the Medium
op.musp=10; % Reduced Scattering Coefficient

numled=size(led,2);


for n=1:numled
    
    % Interpolate from Spectrometer Wavelengths to Reference Wavelengths
    led{n}.ledpower=interp1(lambda2,led{n}.spectrum,lambda1,'pchip');
    
    % Normalize
    led{n}.ledpower=led{n}.ledpower/max(led{n}.ledpower);
    
    % Zero Out Noise
    led{n}.ledpower(led{n}.ledpower<0.01)=0;
    
    % Normalize
    led{n}.ledpower=led{n}.ledpower/sum(led{n}.ledpower);
    
    % Absorption Coeff.
    op.mua(n)=sum((Hb(:,1)*op.HbT*op.sO2+Hb(:,2)*op.HbT*(1-op.sO2)).*led{n}.ledpower);
    
    % Diffusion Coefficient
    op.gamma(n)=sqrt(op.c)/sqrt(3*(op.mua(n)+op.musp));
    op.dc(n)=1/(3*(op.mua(n)+op.musp));
    
    % Spectroscopy Matrix
    E(n,1)=sum(Hb(:,1).*led{n}.ledpower);
    E(n,2)=sum(Hb(:,2).*led{n}.ledpower);
    %assignin('base','E',E); return
    
    % Differential Pathlength Factors
    op.dpf(n)=(op.c/op.musp)*(1/(2*op.gamma(n)*sqrt(op.mua(n)*op.c)))*(1+(3/op.c)*op.mua(n)*op.gamma(n)^2);
end

op.blueLEDextcoeff(1)=Hb(103,1);%*led{n}.ledpower; 454nm
op.blueLEDextcoeff(2)=Hb(103,2);
op.greenLEDextcoeff(1)=Hb(132,1);%*led{n}.ledpower; 512nm
op.greenLEDextcoeff(2)=Hb(132,2);

end


function [lambda Hb]=getHb

data=dlmread('prahl_extinct_coef.txt');

lambda=data(:,1);
c=log(10)/10^3; % convert: (1) base-10 to base-e and (2) M^-1 to mM^-1
Hb=c*squeeze(data(:,2:3));

end

%% getLED()
function [led, lambda]=getLED


led{1}.name='131029_Mightex_530nm_NoBPFilter';
led{2}.name='140801_ThorLabs_590nm_NoPol';
led{3}.name='140801_ThorLabs_625nm_NoPol';

numled=size(led,2);

%Read in LED spectra data from included text files
for n=1:numled
    
    
    fid=fopen([led{n}.name, '.txt']);
    temp=textscan(fid,'%f %f','headerlines',17);
    fclose(fid);
    lambda=temp{1};
    led{n}.spectrum=temp{2};
    
end

end

%% procPixel()
function [data_dot]=procPixel(data,op,E,info,sessiontype)


% disp('Rytov and DPFs')

data=logmean(data);

data=double(data);


for c=1:info.numled
    data(c,:)=squeeze(data(c,:))/op.dpf(c);
end

%     if strcmp(sessiontype, 'fc')
%         [data]=highpass(data,info.highpass,info.framerate);
%         [data]=lowpass(data,info.lowpass,info.framerate);
%     elseif strcmp(sessiontype, 'stim')
[data]=lowpass(data,info.lowpass,info.framerate);
%     end

data_dot=dotspect(data,E);

end


function [data2]=procPixel2(data,op,E,info,sessiontype)

%  %disp('Rytov and DPFs')
data=logmean_gcamp3(data);
data=double(data);


%     if strcmp(sessiontype, 'fc')
%         [data]=highpass(data,info.highpass,info.framerate);
%         [data2]=lowpass(data,info.lowpass,info.framerate);

%     elseif strcmp(sessiontype, 'stim')
[data2]=lowpass(data,info.lowpass,info.framerate);
%     end
% data2=data;

end




%% gsr_OIS
function [datahb2]=gsr_stroke2(datahb,bimask)

[nVx nVy hb T]=size(datahb);

datahb=reshape(datahb,nVx*nVy,hb,T);
gs=squeeze(mean(datahb(bimask==1,:,:),1));
[datahb2 Rgs]=regcorr(datahb,gs);
datahb2=reshape(datahb2,nVx, nVy, hb, T);

end


%% gsr_OIS
function [datahb2]=gsr_strokegreen(datahb,bimask)

[nVx nVy T]=size(datahb);

datahb=reshape(datahb,nVx*nVy,1,T);
gs=squeeze(mean(datahb(bimask==1,:,:),1));
[datahb2 Rgs]=regcorr(datahb,gs);
datahb2=reshape(datahb2,nVx, nVy, T);

end


function [Oxy_gsr DeOxy_gsr]=gsr_stroke3(datahb,bimask)

[nVx nVy hb T]=size(datahb);

datahb=reshape(datahb,nVx*nVy,hb,T);
gs=squeeze(mean(datahb(bimask==1,:,:),1));
[datahb2 Rgs]=regcorr(datahb,gs);
datahb2=reshape(datahb2,nVx, nVy, hb, T);
Oxy_gsr=squeeze(datahb2(:,:,1,:));
DeOxy_gsr=squeeze(datahb2(:,:,2,:));

end

%% gsr_OIS
function [datahb2]=gsr_stroke4(datahb,bimask)

[nVx nVy T]=size(datahb);

datahb=reshape(datahb,nVx*nVy,T);
gs=squeeze(mean(datahb(bimask==1,:),1));
[datahb2 Rgs]=regcorr(datahb,gs);
datahb2=reshape(datahb2,nVx, nVy, T);

end