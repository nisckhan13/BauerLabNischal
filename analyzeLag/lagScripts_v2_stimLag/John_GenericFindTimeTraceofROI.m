function [ttrace,ttrace_mask] = John_GenericFindTimeTraceofROI(hemdata,peakmap,threshold,maxormin,varargin)
% John_GenericFindTimeTraceofROI will output the time trace of hemoglobin
% data
%   inputs: 
%       hemdata -- Hemoglobin data, should be in the format of
%       [nVy,nVx,time]
%       peakmap -- Name of the peak hemoglobin figure to base ROI off of
%       threshold -- Thresholding of ROI
%       maxormin -- Threshold ROI off of the max value or min value;
%       should be max for peripheral stimulation or Thy1 photostimulation 
%       varargin{1}//ttrace mask -- can base ROI to generate time trace off
%       of from a user inputted ROI without analyzing peak maps, useful for
%       comparing hemoglobin data across trials with the same ROI 
%   outputs: 
%       ttrace -- Time trace of ROI 
%       ttrace_mask -- ROI

[nVy,nVx,time] = size(hemdata);
if size(varargin) == 1;
    ttrace_mask = varargin{1};
else
    % Display peak hemoglobin map to base ROI off of
    tracefig = openfig(peakmap);
    pause(0.5)
    disp('Please click region of interest. 1st point: ROI center/2nd point: outside edge of circular ROI');
    [xc yc]=ginput(2);
    center_x = xc(1);
    edge_x = xc(2);
    center_y = yc(1);
    edge_y = yc(2);
    radius = pdist([center_x,center_y;edge_x,edge_y]);
    

    % Use peak hemoglobin data to determine the max or min Hb concentration value
    peakdata = mean(hemdata(:,:,9:11),3);

    % Initialize matrix to store data points to be included in time trace
    ttrace_mask = false(nVy,nVx);
        
    % Run through points in the image plane and see which points are in ROI
    for x = 1:nVx
        for y = 1:nVy
            if pdist([center_x,center_y;x,y])<= radius
                ttrace_mask(y,x) = true;
            end
        end
    end
    if strcmp(maxormin,'max')
        threshold_value = threshold*max(max(peakdata.*ttrace_mask));
    else
        threshold_value = threshold*min(min(peakdata.*ttrace_mask));
    end
    
    for x = 1:nVx
        for y = 1:nVy
            if strcmp(maxormin,'max')
                if peakdata(y,x)<threshold_value
                    ttrace_mask(y,x) = false;
                end
            else
                if peakdata(y,x)>threshold_value
                    ttrace_mask(y,x) = false;
                end
            end
        end
    end
figure(tracefig);
pause(0.5)
hold on
imagesc(ones(128)*-1,'AlphaData',ttrace_mask*0.5);
pause(2)
savefig([peakmap,'-ROI'])
close(tracefig);    
end
hemdata = reshape(hemdata,[nVy*nVx,time]);

% Average points in ROI and output linear time trace
ttrace = mean(hemdata(ttrace_mask,:),1);
end