function cropMovie(vidFile, startPoint, endPoint, secOrFrame, outputFR, saveDest)
% This function will crop a given video at the specified start/end
% timepoints and save the cropped video at the specified directory.
%
% Inputs:
%   vidFile: location of original video
%   startPoint: where to begin cropping (either in frames or secs, be
%   consistent)
%   endPoint: where to stop cropping (either in frames or secs, be
%   consistent)
%   secOrFrame: 0 if start/endPoints are in seconds, 1 if they're in frames
%   outputFR: desired framerate of cropped video (in Hz/fps)
%   saveDest: directory where cropped video should be saved (don't include
%   the video name; ex. 'D:\ProcessedData\CroppedVideos')
disp('Reading video file...');
MOV = VideoReader(vidFile);

% convert seconds to frame number if input is in seconds
if secOrFrame == 0
    startPoint = startPoint*MOV.FrameRate;
    endPoint = endPoint*MOV.FrameRate;
end

% set currentTime of movie to first frame
MOV.CurrentTime = (startPoint-1)/MOV.FrameRate;
textY = round(0.95*MOV.Height);
tic;
fprintf('Cropping Frame: ');
for i=startPoint:endPoint

    % provide output in command window of current frame
    if i>startPoint
      for j=0:log10(i-1)
          fprintf('\b');
      end
    end
    fprintf('%d', i);
    pause(.05);

    % create figure for each frame that needs to be cropped
    cropMov = figure('color','w', 'Visible', 'off');
    set(gca,'position',[0 0 1 1],'units','normalized');
    curImg = readFrame(MOV);
    image(curImg);
    set(gca,'Visible','off')
    if secOrFrame == 0
        frameCount = ['Time: ' num2str(i/MOV.FrameRate)];
    else
        frameCount = ['Frame: ' num2str(i)];
    end    
    % add timestamp of current frame
    text(0,textY,frameCount,'Color', 'w', 'FontSize', 11);

    % store each frame
    Frames(i-startPoint+1) = getframe(cropMov);
    drawnow;
    clf(cropMov);

    % iterate to next timepoint (next frame)
    MOV.CurrentTime = i/MOV.FrameRate;
end
fprintf('\n');

% save video at desired framerate
disp('Saving video...');
saveDest = [saveDest '\croppedVideo.avi'];
writerObj = VideoWriter(saveDest);
writerObj.FrameRate = outputFR;

open(writerObj);
for i=1:length(Frames)
    frame = Frames(i);
    writeVideo(writerObj,frame);
end
close(writerObj);
close(cropMov);
clear('Frames');
disp('Finished!');
toc;
end
