function gcampqc(rawdata_rs,fulldetrend,mask,info,Mouse,sessiontype,run,xform_mask,xform_WL, gcamp6corr, oxy, directory, Date)

seedcenter=cell2mat(struct2cell(load('C:\Users\albertsona\Box\Lab (Zach)\Code for Asher\Seeds-R01-RevisedL.mat', 'seedcenter')));
seedcenter=seedcenter([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16],:);                          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change seeds


disp(['Running QC for ',Mouse,'-',sessiontype,num2str(run)])
info.T1=size(gcamp6corr,3);
ibiz= find(mask);

        rawdata=double(reshape(rawdata_rs,info.nVx*info.nVy,info.numled,[]));
        rawdata_dt=double(reshape(fulldetrend,info.nVx*info.nVy,info.numled,[]));

mdata=squeeze(mean(rawdata(ibiz,:,:),1));
mdata_dt=squeeze(mean(rawdata_dt(ibiz,:,:),1));
%normalize raw data (before detrending)
for c=1:info.numled;
    mdatanorm(c,:)=mdata(c,:)./(squeeze(mean(mdata(c,:),2)));
    mdatanorm_dt(c,:)=mdata_dt(c,:)./(squeeze(mean(mdata_dt(c,:),2)));
end
%std of data after detrending
for c=1:info.numled;
    stddatanorm(c,:)=std(mdatanorm_dt(c,:),0,2);
end

time=linspace(1,info.T1,info.T1)/info.framerate;

fhraw=figure('Units','inches','Position',[15 3 10 7], 'PaperPositionMode','auto','PaperOrientation','Landscape');
set(fhraw,'Units','normalized','visible','on');

plotedit on

%% Raw Data Check plot

subplot('position', [0.12 0.71 0.17 0.2])
p=plot(time,mdata'); title('Raw Data');
set(p(1),'Color',[0 0 1]);
set(p(2),'Color',[0 1 0]);
set(p(3),'Color',[1 1 0]);
set(p(4),'Color',[1 0 0]);
title('Raw Data');
xlabel('Time (sec)')
ylabel('Counts');
ylim([0 10000])

subplot('position', [0.35 0.71 0.17 0.2])
p=plot(time,mdatanorm'); title('Normalized Raw Data');
set(p(1),'Color',[0 0 1]);
set(p(2),'Color',[0 1 0]);
set(p(3),'Color',[1 1 0]);
set(p(4),'Color',[1 0 0]);
xlabel('Time (sec)')
ylabel('Mean Counts')
ylim([0.95 1.05])

subplot('position', [0.6 0.71 0.1 0.2])
plot(stddatanorm*100');
set(gca,'XTick',(1:4));
set(gca,'XTickLabel',{'B', 'G', 'Y', 'R'})
title('Std Deviation');
ylabel('% Deviation')


%% FFT Check plot
fdata=abs(fft(logmean(mdata),[],2));
hz=linspace(0,info.framerate,info.T1);
subplot('position', [0.77 0.71 0.2 0.2])
p=loglog(hz(1:ceil(info.T1/2)),fdata(:,1:ceil(info.T1/2))'); title('FFT Raw Data');
set(p(1),'Color',[0 0 1]);
set(p(2),'Color',[0 1 0]);
set(p(3),'Color',[1 1 0]);
set(p(4),'Color',[1 0 0]);
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0.01 15]);


%% Check Evoked Responses

if strcmp(sessiontype, 'stim')
    
    
    AC = 84:168;                                                                            %%%%%%%%%%%%%%%%%%%%%%%%change frames stim is present
    info.stimlength=336;                                                                    %%%%%%%%%%%%%%%%%%%%%%%%change length of a block
    info.hzstim=1;                                                                          %%%%%%%%%%%%%%%%%%%%%%%%change freq of stims
    %reshape data
    gcamp=real(gcamp6corr);
    gcamp(:,:,length(gcamp)+1)=zeros(info.nVy,info.nVx);
    gcamp=reshape(gcamp,info.nVy,info.nVx,info.stimlength,length(gcamp)/info.stimlength);
    
    oxy(:,:,length(oxy)+1)=zeros(info.nVy,info.nVx);
    Oxy=real(reshape(oxy,info.nVy,info.nVx,info.stimlength,length(oxy)/info.stimlength));
    
    
    %subtract mean from data
    for b=1:size(Oxy,4)
        MeanFrame=squeeze(mean(Oxy(:,:,[1:(min(AC)-1) (max(AC)+1):end],b),3));
        for t=1:size(Oxy, 3);
            Oxy(:,:,t,b)=squeeze(Oxy(:,:,t,b))-MeanFrame;
        end
    end
    
    
    for b=1:size(gcamp,4)
        MeanFrame=squeeze(mean(gcamp(:,:,[1:(min(AC)-1) (max(AC)+1):end],b),3));
        for t=1:size(gcamp, 3);
            gcamp(:,:,t,b)=squeeze(gcamp(:,:,t,b))-MeanFrame;
        end
    end
    
    AvgOxy=mean(Oxy,4);
    Avggcamp=mean(gcamp,4);
    %subtract mean from average
    MeanFrame=squeeze(mean(AvgOxy(:,:,[1:(min(AC)-1) (max(AC)+1):end]),3));
    for t=1:size(AvgOxy, 3);
        AvgOxy(:,:,t)=squeeze(AvgOxy(:,:,t))-MeanFrame;
    end
    
    MeanFrame=squeeze(mean(Avggcamp(:,:,[1:(min(AC)-1) (max(AC)+1):end]),3));
    for t=1:size(Avggcamp, 3);
        Avggcamp(:,:,t)=squeeze(Avggcamp(:,:,t))-MeanFrame;
    end
    %plot activation areas
    subplot('position', [0.05 0.05 0.095 0.095]);
    imagesc(mean(AvgOxy(:,:,AC),3), [-1e-2 1e-2]);
    axis image off;
    title('Avg Oxy')
    
    subplot('position', [0.20 0.05 0.095 0.095]);
    imagesc(mean(Avggcamp(:,:,AC),3), [-1e-2 1e-2]);
    axis image off;
    title('Avg GCaMP')
    %find activation trace
    Actmean=mean(Avggcamp(:,:,AC),3);
    Actmeano=mean(AvgOxy(:,:,AC),3);
    
    for p=1:info.nVx
        for j=1:info.nVy
            
            Actnew(p,j)=xform_mask(p,j)*Actmean(p,j);
            Actnewo(p,j)=xform_mask(p,j)*Actmeano(p,j);
            
        end
    end
    
    linemap = reshape(Actnew,info.nVx*info.nVy,1);
    %find ROI
    maxforroi = max(linemap);
    disp(['max is ',num2str(maxforroi)]);
    thresh= 0.75*maxforroi;
    
    Act2 = Actnew;
    Act2(Act2<thresh)=0;
    
    Act2 = logical(Act2);
    
    gcamp= reshape(Avggcamp,info.nVx*info.nVy,info.stimlength);
    oxystim=reshape(AvgOxy,info.nVx*info.nVy,info.stimlength);
    
    ROIx= Act2;
    ROI2 = reshape(ROIx,info.nVx*info.nVy,1);
    ROImask = find(ROI2);
    indivROI = gcamp(ROImask,:);
    indivROIo = oxystim(ROImask,:);
    gcampROI=(mean(indivROI,1));
    gcampROIo=(mean(indivROIo,1));
    %plot response curve
    framelines= min(AC)/info.framerate:1/info.hzstim:max(AC)/info.framerate;
    seconds= linspace(0,info.stimlength/info.framerate,info.stimlength);
    subplot('position', [0.075 0.25 0.3 0.3]);
    yyaxis left
    plot(seconds,gcampROI,'k','linewidth',2); ylabel('GCaMP \DeltaF/F'); xlabel('Time (s)'); title('Avg stim block within ROI'); hold on
    
    yyaxis right
    plot(seconds,gcampROIo,'r','linewidth',2); ylabel('\Delta Oxy');
    
    vline(framelines,'b'); legend('GCaMP','Oxy');
    
    
    
    %% Check functional connectivty
elseif strcmp(sessiontype, 'fc')
    
    gcamp3c=real(gcamp6corr);
    oxy=real(oxy);
    seednames={'Par','Fr','Cg','M','SS','Rs','V','Au'};
    sides={'L','R'};
    %set seed diameter
    mm=10;
    mpp=mm/info.nVx;
    seedradmm=0.25;
    seedradpix=seedradmm/mpp;
    
    numseeds=numel(seednames);
    numsides=numel(sides);
    %make seed traces
    P=(burnseeds(seedcenter,seedradpix,xform_mask));
    strace=P2strace(P,gcamp3c);
    R=strace2R(strace,gcamp3c);
    Rs=normr(strace)*normr(strace)';
    Ostrace=P2strace(P,oxy);
    OR=strace2R(Ostrace,oxy);
    ORs=normr(Ostrace)*normr(Ostrace)';
    %plot FC
    for s=1:numseeds
        
        subplot('position', [s*0.1 0.35 0.1 0.1]);
        Im2=overlaymouse(R(:,:,2*(s-1)+2),xform_WL, xform_mask,'jet',-1,1);
        image(Im2);
        hold on;
        plot(seedcenter(2*(s-1)+1,1),seedcenter(2*(s-1)+1,2),'ko');
        axis image off
        title([seednames{s},'L'])
        hold off;
        
    end
    
    for s=1:numseeds
        
        subplot('position', [s*0.1 0.1 0.1 0.1]);
        Im2=overlaymouse(OR(:,:,2*(s-1)+2),xform_WL, xform_mask,'jet',-1,1);
        image(Im2);
        hold on;
        plot(seedcenter(2*(s-1)+1,1),seedcenter(2*(s-1)+1,2),'ko');
        axis image off
        title([seednames{s},'L'])
        hold off;
        
    end
    
    annotation('textbox', [0.205 0.48 1 0.1], ...
        'String', 'GcaMP FC', ...
        'EdgeColor', 'none',...
        'FontSize', 12,...
        'FontWeight','bold')
    
    annotation('textbox', [0.205 0.24 1 0.1], ...
        'String', 'Oxy FC', ...
        'EdgeColor', 'none',...
        'FontSize', 12,...
        'FontWeight','bold')
    
end



output=[directory, Date,'-', Mouse,' ',sessiontype,num2str(run) '-DataVis.jpg'];
orient portrait
print ('-djpeg', '-r300', output);

close all



fhraw=figure('Units','inches','Position',[15 3 10 7], 'PaperPositionMode','auto','PaperOrientation','Landscape');
set(fhraw,'Units','normalized','visible','off');

plotedit on

%% pixels by time
t=linspace(0,length(gcamp6corr),length(gcamp6corr)/50);
gcampc=gcamp6corr;
gcampc=reshape(gcampc,128*128,[]);
oxy=reshape(oxy,128*128,[]);
iz=reshape(xform_mask,128*128,[]);
%subtract mean
gcamp=gcampc-mean(gcampc,2);
oxyc=oxy-mean(oxy,2);
%subtract frame by frame
for i=1:size(gcampc,2)-1
    diff_g(:,i)=gcampc(:,i+1)-gcampc(:,i);
    diff_o(:,i)=oxy(:,i+1)-oxy(:,i); %SHOULD THIS BE OXYC?
end
%take power of frame by frame subtraction
diff_gp=power(diff_g,2);
diff_op=power(diff_o,2);
%figure;
subplot('position', [0.15 0.8 0.35 0.1]);
imagesc(squeeze(gcamp(:,:)).*iz,[-5E-3 5E-3]); colorbar;
xticks([t]); xlabel('Time(s) [GCaMP6-mean]'); ylabel('Pixels'); colormap gray;

subplot('position', [0.55 0.8 0.35 0.1]);
imagesc(squeeze(oxyc(:,:)).*iz,[-5E-4 5E-4]); colorbar;
xticks([t]); xlabel('Time(s) [Oxy-mean]'); ylabel('Pixels'); colormap gray;

subplot('position', [0.15 0.6 0.35 0.1]);
imagesc(squeeze(diff_g(:,:)).*iz,[-5E-3 5E-3]); colorbar;
xticks([t]); xlabel('Time(s) [diff GCaMP6]'); ylabel('Pixels'); colormap gray;

subplot('position', [0.55 0.6 0.35 0.1]);
imagesc(squeeze(diff_o(:,:)).*iz,[-5E-4 5E-4]); colorbar;
xticks([t]); xlabel('Time(s) [diff Oxy]'); ylabel('Pixels'); colormap gray;

subplot('position', [0.15 0.4 0.35 0.1]);
imagesc(squeeze(diff_gp(:,:)).*iz,[-5E-6 5E-6]); colorbar;
xticks([t]); xlabel('Time(s) [diff GCaMP6]^2'); ylabel('Pixels'); colormap gray;

subplot('position', [0.55 0.4 0.35 0.1]);
imagesc(squeeze(diff_op(:,:)).*iz,[-5E-7 5E-7]); colorbar;
xticks([t]); xlabel('Time(s) [diff Oxy]^2'); ylabel('Pixels'); colormap gray;

annotation('textbox',[0.125 0.95 0.75 0.05],'HorizontalAlignment','center','LineStyle','none','String',[directory, Date,'-', Mouse,' ',sessiontype,num2str(run) ' Data Visualization'],'FontWeight','bold','Color',[0 0 1]);

%% Movement Check
rawdata=reshape(rawdata, info.nVy, info.nVx,info.numled, []);
Im1=single(squeeze(rawdata(:,:,4,1)));
F1 = fft2(Im1); % reference image

InstMvMt=zeros(size(rawdata,4),1);
LTMvMt=zeros(size(rawdata,4),1);
Shift=zeros(2,size(rawdata,4),1);

for t=1:size(rawdata,4)-1;
    LTMvMt(t)=sum(sum(abs(squeeze(rawdata(:,:,4,t+1))-Im1)));
    InstMvMt(t)=sum(sum(abs(squeeze(rawdata(:,:,4,t+1))-squeeze(rawdata(:,:,4,t)))));
end

for t=1:size(rawdata,4);
    Im2=single(squeeze(rawdata(:,:,4,t)));
    F2 = fft2(Im2); % subsequent image to translate
    
    pdm = exp(1i.*(angle(F1)-angle(F2))); % Create phase difference matrix
    pcf = real(ifft2(pdm)); % Solve for phase correlation function
    pcf2(1:size(Im1,1)/2,1:size(Im1,1)/2)=pcf(size(Im1,1)/2+1:size(Im1,1),size(Im1,1)/2+1:size(Im1,1));
    pcf2(size(Im1,1)/2+1:size(Im1,1),size(Im1,1)/2+1:size(Im1,1))=pcf(1:size(Im1,1)/2,1:size(Im1,1)/2);
    pcf2(1:size(Im1,1)/2,size(Im1,1)/2+1:size(Im1,1))=pcf(size(Im1,1)/2+1:size(Im1,1),1:size(Im1,1)/2);
    pcf2(size(Im1,1)/2+1:size(Im1,1),1:size(Im1,1)/2)=pcf(1:size(Im1,1)/2,size(Im1,1)/2+1:size(Im1,1));
    
    [~, imax] = max(pcf2(:));
    [ypeak, xpeak] = ind2sub(size(Im1,1),imax(1));
    offset = [ypeak-(size(Im1,1)/2+1) xpeak-(size(Im1,2)/2+1)];
    
    Shift(1,t)=offset(1);
    Shift(2,t)=offset(2);
    
end

subplot('position', [0.1 0.1 0.35 0.2]);
[AX, H1, H2]=plotyy(time, InstMvMt/1e6,time, LTMvMt/1e6);
set(AX(1),'ylim',[0 2]);
set(AX(1), 'ytick',[0,1,2])
set(AX(2),'ylim',[0 3]);
set(AX(2), 'ytick',[0,1,2,3])
set(get(AX(1), 'YLabel'), 'String', {'Sum Abs Diff Frame to Frame,'; '(Counts x 10^6)'});
set(get(AX(2),'YLabel'), 'String', {'Sum Abs Diff WRT First Frame,'; '(Counts x 10^6)'});
xlabel('Time  (sec)');
legend('Instantaneous Change','Change over Run');

subplot('position', [0.6 0.1 0.35 0.2]);
plot(time, Shift(1,:),'m');
hold on;
plot(time, Shift(2,:),'k');
ylim([-1*(max(Shift(:))+1) max(Shift(:)+1)]);
xlabel('Time  (sec)');
ylabel('Offset (pixels)');
legend('Vertical','Horizontal');

annotation('textbox',[0.125 0.95 0.75 0.05],'HorizontalAlignment','center','LineStyle','none','String',[directory, Date,'-', Mouse,' ',sessiontype,num2str(run) ' Data Visualization'],'FontWeight','bold','Color',[0 0 1]);
output=[directory, Date,'-', Mouse,' ',sessiontype,num2str(run) '-MovementCheck.jpg'];
orient portrait
print ('-djpeg', '-r300', output);

close all
clear info
end


