function John_generateHbImageSequence(Date,Mouse,saveloc,sessiontype,varargin)
% John_generateHbImageSequence will display the mouse averaged image
% sequence across Hb contrasts (oxy/deoxy/total). It will also display the
% peak hemoglobin map for the mouse. In the end, it saves data at the mouse
% level.
%
% You can separate trials by experimental condition but it otherwise 
% assumes that all trials have the same condition. 
%   inputs: 
%       Date -- date of experiment
%       Mouse -- Mouse name
%       saveloc -- save location to check if hemoglobin figures were
%       already created
%       varargin{1}//conditions -- user determined separation of conditions
%       otherwise assumes no separation (format = [1, 4, 7] for e.g. of
%       stim 1:3 being peripheral stim, 4:6 being photostimulation, and 7:9
%       being peripheral + photostimulation)
%       varargin{2}//condition names -- user determined names for each
%       experimental condition (format = {'....','.....','.....'}). Should
%       match the number of conditions inputted
%   outputs: 
%       None

close all

if ~isempty(varargin);
    conditions = varargin{1};
    conditionnames = varargin{2};
else
    conditions = [1];
    conditionnames = {'Stimulation'};
end

storeHb_mouse = [];
%% Output hemoglobin maps over each second averaged across experimental conditions
filename = [saveloc,Date,'\',Date,'-',Mouse];
% if ~exist([filename,'-PeakMap-',conditionnames{1},'.fig'])
    m = 1;
    while 1
        loopfile1 = [filename,'-',sessiontype{1},num2str(m),'-datahb.mat'];
        if ~exist(loopfile1,'file');
            m=m+1;
            loopfile1=[filename,num2str(m),'-datahb.mat'];
            if ~exist(loopfile1,'file');
                break
            end
        end
        load(loopfile1,'AvgOxy','AvgDeOxy','AvgTotal','xform_LaserFrameIndices');
        storeHb_trial = cat(4,AvgOxy,AvgDeOxy,AvgTotal);
        storeHb_mouse = cat(5,storeHb_mouse,storeHb_trial);
        LFI = mean(xform_LaserFrameIndices,1);
        clearvars AvgOxy AvgDeOxy AvgTotal storeHb_trial
        m = m+1;
    end
    loopfile2 = [filename,'-LandmarksandMask.mat'];
    load(loopfile2,'xform_isbrain');
    
    y_thresh = sum(xform_isbrain,1);
    y_thresh = find(y_thresh>0);
    x_thresh = sum(xform_isbrain,2);
    x_thresh = find(x_thresh>0);
    
    c = 1;
    AvgHb_mouse = [];
    
    % Separates trials by user inputted conditions
    for i = conditions;
        if c == length(conditions)
            meancondition = squeeze(mean(storeHb_mouse(:,:,:,:,i:end),5));
            AvgHb_mouse = cat(5,AvgHb_mouse,meancondition);
            disp(['Averaging trials for a condition: ', num2str(i),':',num2str(size(storeHb_mouse,5))]);
        elseif c < length(conditions)
            c = c+1;
            meancondition = squeeze(mean(storeHb_mouse(:,:,:,:,i:conditions(c)-1),5));
            AvgHb_mouse = cat(5,AvgHb_mouse,meancondition);
            disp(['Averaging trials for a condition: ', num2str(i),':',num2str(conditions(c)-1)]);
        end
    end
    
    [nVy, nVx, time, contrast, numcond] = size(AvgHb_mouse);

    %% Generate image sequence 
    threshold = [-7e-4,7e-4];
    contrastnames = {'HbO','HbR','HbT'};
    for j = 1:numcond
        for con = 1:contrast
            figure
            for t = 1:time
                subplot(6,10,t)
%                 imagesc(squeeze(AvgHb_mouse(y_thresh(1):y_thresh(end),x_thresh(1):x_thresh(end),t,con,j)),...
%                     'AlphaData',xform_isbrain(y_thresh(1):y_thresh(end),x_thresh(1):x_thresh(end)),threshold)
                imagesc(squeeze(AvgHb_mouse(:,:,t,con,j)),...
                    'AlphaData',xform_isbrain,threshold)
                colormap('jet')
                axis off
                daspect([1 1 1]);
                hold on
                plot(LFI(1),LFI(2),'k.','MarkerSize',5,'DisplayName','Laser on')
                if ismember(t,[6])
                    legend
                end
            end
            suptitle([Date,'-',Mouse,'-ImageSequence-',conditionnames{j},'-',contrastnames{con}]);
            savefig([filename,'-ImageSeq-',conditionnames{j},'-',contrastnames{con}]);
            close
        end
    end
    
    %% Peak hemoglobin maps
    peakrange = 9:11;
    PeakHb_mouse = squeeze(mean(AvgHb_mouse(:,:,peakrange,:,:),3));
    for j = 1:numcond
        figure
        for con = 1:contrast
            subplot(1,3,con);
            imagesc(squeeze(PeakHb_mouse(:,:,con,j)),threshold);
            colormap('jet')
            axis off
            daspect([1 1 1]);
        end
        suptitle([Date,'-',Mouse,'-PeakMap-',conditionnames{j}]);
        savefig([filename,'-PeakMap-',conditionnames{j}]);
        close
    end
    save([filename,'-datahb.mat'],'storeHb_mouse','AvgHb_mouse','PeakHb_mouse')
% else 
%     disp([Date,'-',Mouse,' Image sequences already saved']);
% end

end


