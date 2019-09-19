function [ROI,AvgOxy_stim, AvgDeOxy_stim, AvgTotal_stim,Avgjrgeco1aCorr_stim,AvggcampCorr_stim] = ...
    generatePeakMapandROI(oxy_blocks_downsampled,deoxy_blocks_downsampled,total_blocks_downsampled,...
    temp_oxy_max,temp_deoxy_max,temp_total_max,stimStartTime,stimEndTime,varargin)

load('D:\OIS_Process\atlas.mat','AtlasSeeds')
barrel = AtlasSeeds == 9;
ROI_barrel =  bwperim(barrel);
p = inputParser;

addParameter(p,'jrgeco1aCorr_blocks_downsampled',[],@isnumeric);
addParameter(p,'temp_jrgeco1aCorr_max',[],@isnumeric);


addParameter(p,'gcampCorr_blocks_downsampled',[],@isnumeric);
addParameter(p,'temp_gcampCorr_max',[],@isnumeric);
parse(p,varargin{:});


jrgeco1aCorr_blocks_downsampled = p.Results.jrgeco1aCorr_blocks_downsampled;
temp_jrgeco1aCorr_max = p.Results.temp_jrgeco1aCorr_max;

gcampCorr_blocks_downsampled = p.Results.gcampCorr_blocks_downsampled;
temp_gcampCorr_max = p.Results.temp_gcampCorr_max;


% baseline substraction
MeanFrame_oxy_downsampled=mean(oxy_blocks_downsampled(:,:,1:stimStartTime),3);
oxy_goodLocalizedblocks_baseline_downsampled = oxy_blocks_downsampled-MeanFrame_oxy_downsampled;

MeanFrame_deoxy_downsampled=mean(deoxy_blocks_downsampled(:,:,1:stimStartTime),3);
deoxy_goodLocalizedblocks_baseline_downsampled = deoxy_blocks_downsampled-MeanFrame_deoxy_downsampled;

MeanFrame_total_downsampled=mean(total_blocks_downsampled(:,:,1:stimStartTime),3);
total_goodLocalizedblocks_baseline_downsampled = total_blocks_downsampled-MeanFrame_total_downsampled;

AvgOxy_stim = mean(oxy_goodLocalizedblocks_baseline_downsampled(:,:,stimEndTime-1:stimEndTime+1),3);
AvgDeOxy_stim = mean(deoxy_goodLocalizedblocks_baseline_downsampled(:,:,stimEndTime-1:stimEndTime+1),3);
AvgTotal_stim = mean(total_goodLocalizedblocks_baseline_downsampled(:,:,stimEndTime-1:stimEndTime+1),3);

Avgjrgeco1aCorr_stim = [];
if ~isempty(jrgeco1aCorr_blocks_downsampled)
    MeanFrame_jrgeco1aCorr_downsampled=mean(jrgeco1aCorr_blocks_downsampled(:,:,1:stimStartTime),3);
    jrgeco1aCorr_goodLocalizedblocks_baseline_downsampled = jrgeco1aCorr_blocks_downsampled-MeanFrame_jrgeco1aCorr_downsampled;
    Avgjrgeco1aCorr_stim = mean(jrgeco1aCorr_goodLocalizedblocks_baseline_downsampled(:,:,stimEndTime-2:stimEndTime+2),3);
    
end

AvggcampCorr_stim = [];
if ~isempty(gcampCorr_blocks_downsampled)
    MeanFrame_gcampCorr_downsampled=mean(gcampCorr_blocks_downsampled(:,:,1:stimStartTime),3);
    gcampCorr_goodLocalizedblocks_baseline_downsampled = gcampCorr_blocks_downsampled-MeanFrame_gcampCorr_downsampled;
    AvggcampCorr_stim = mean(gcampCorr_goodLocalizedblocks_baseline_downsampled(:,:,stimEndTime),3);
end
[X,Y] = meshgrid(1:128,1:128);
ROI_total  = [];
if isempty(gcampCorr_blocks_downsampled)&& isempty(jrgeco1aCorr_blocks_downsampled)
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(1,3,1)
    imagesc(AvgOxy_stim,[-temp_oxy_max temp_oxy_max])
    colorbar
    axis image off
    title('1. oxy');
    subplot(1,3,2)
    
    imagesc(AvgDeOxy_stim,[-temp_deoxy_max temp_deoxy_max])
    colorbar
    axis image off
    title('2. deoxy');
    subplot(1,3,3)
    imagesc(AvgTotal_stim,[-temp_total_max temp_total_max])
    colorbar
    axis image off
    title('3. total');
    colormap jet
    hold on
    contour(ROI_barrel,'k')
    
    
    [x1_total,y1_total] = ginput(1);
    [x2_total,y2_total] = ginput(1);
    
    
    
    
    radius_total = sqrt((x1_total-x2_total)^2+(y1_total-y2_total)^2);
    ROI_total = sqrt((X-x1_total).^2+(Y-y1_total).^2)<radius_total;
    
    max_total = prctile(AvgTotal_stim(ROI_total),99);
    temp = AvgTotal_stim.*ROI_total;
    ROI_total = temp>0.9*max_total;
end

ROI_total_contour = bwperim(ROI_total);

ROI_jrgeco1aCorr  = [];
if ~isempty(jrgeco1aCorr_blocks_downsampled)
    imagesc(Avgjrgeco1aCorr_stim,[-temp_jrgeco1aCorr_max temp_jrgeco1aCorr_max])
    colorbar
    axis image off
    title('jrgeco1aCorr');
    colormap jet
        hold on
    contour(ROI_barrel,'k')
    [x1_jrgeco1aCorr,y1_jrgeco1aCorr] = ginput(1);
    [x2_jrgeco1aCorr,y2_jrgeco1aCorr] = ginput(1);
    
    radius_jrgeco1aCorr = sqrt((x1_jrgeco1aCorr-x2_jrgeco1aCorr)^2+(y1_jrgeco1aCorr-y2_jrgeco1aCorr)^2);
    ROI_jrgeco1aCorr = sqrt((X-x1_jrgeco1aCorr).^2+(Y-y1_jrgeco1aCorr).^2)<radius_jrgeco1aCorr;
    
    max_jrgeco1aCorr = prctile(Avgjrgeco1aCorr_stim(ROI_jrgeco1aCorr),99);
    temp = Avgjrgeco1aCorr_stim.*ROI_jrgeco1aCorr;
    ROI_jrgeco1aCorr = temp>0.5*max_jrgeco1aCorr;
    
    %     figure;
    %     imagesc(ROI_jrgeco1aCorr);
    %     axis image off;
    %     ROI_holes = roipoly;
    %     ROI_smallarea = roipoly;
    %
    %     ROI_jrgeco1aCorr(ROI_holes)= 1;
    %     ROI_jrgeco1aCorr(ROI_smallarea) = 0;
    ROI_jrgeco1aCorr_contour = bwperim(ROI_jrgeco1aCorr);
end
ROI_gcampCorr  = [];
if ~isempty(gcampCorr_blocks_downsampled)
    figure
    imagesc(AvggcampCorr_stim,[-temp_gcampCorr_max temp_gcampCorr_max])
    colorbar
    axis image off
    title('gcampCorr');
    colormap jet
    hold on
    contour(ROI_barrel,'k')
    [x1_gcampCorr,y1_gcampCorr] = ginput(1);
    [x2_gcampCorr,y2_gcampCorr] = ginput(1);
    
    radius_gcampCorr = sqrt((x1_gcampCorr-x2_gcampCorr)^2+(y1_gcampCorr-y2_gcampCorr)^2);
    ROI_gcampCorr = sqrt((X-x1_gcampCorr).^2+(Y-y1_gcampCorr).^2)<radius_gcampCorr;
    
    max_gcampCorr = prctile(AvggcampCorr_stim(ROI_gcampCorr),99);
    temp = AvggcampCorr_stim.*ROI_gcampCorr;
    ROI_gcampCorr = temp>0.5*max_gcampCorr;
    
    %     figure;
    %     imagesc(ROI_gcampCorr);
    %     axis image off;
    %     ROI_holes = roipoly;
    %     ROI_smallarea = roipoly;
    %
    %     ROI_gcampCorr(ROI_holes)= 1;
    %     ROI_gcampCorr(ROI_smallarea) = 0;
    ROI_gcampCorr_contour = bwperim(ROI_gcampCorr);
end

figure;
subplot(2,2,1)

imagesc(AvgOxy_stim,[-temp_oxy_max  temp_oxy_max])
hold on
contour(ROI_total_contour,'k')
axis image off
title('1. oxy');

subplot(2,2,2)
imagesc(AvgDeOxy_stim,[-temp_deoxy_max temp_deoxy_max])
hold on
contour(ROI_total_contour,'k')
axis image off
title('2. deoxy');

subplot(2,2,3)
imagesc(AvgTotal_stim,[-temp_total_max temp_total_max])
hold on
contour(ROI_total_contour,'k')
axis image off
title('3. total');

if ~isempty(jrgeco1aCorr_blocks_downsampled)
    subplot(2,2,4)
    imagesc(Avgjrgeco1aCorr_stim,[-temp_jrgeco1aCorr_max temp_jrgeco1aCorr_max])
    hold on
    contour(ROI_jrgeco1aCorr_contour,'k')
    axis image off
    title('4. jrgeco1aCorr');
end

if ~isempty(gcampCorr_blocks_downsampled)
    subplot(2,2,4)
    imagesc(AvggcampCorr_stim,[-temp_gcampCorr_max temp_gcampCorr_max])
    hold on
    contour(ROI_gcampCorr_contour,'k')
    axis image off
    title('4. gcampCorr');
end

colormap jet
