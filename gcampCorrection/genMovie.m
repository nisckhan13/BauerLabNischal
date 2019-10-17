%% load data
hillmanFluor = load("E:\TestData\CompareDP\hillman\190523-G11M1-awake-stim2-dataFluor.mat");
hillmanHb = load("E:\TestData\CompareDP\hillman\190523-G11M1-awake-stim2-dataHb.mat");

kennyFluor = load("E:\TestData\CompareDP\kenny\190523-G11M1-awake-stim2-dataFluor.mat");
kennyHb = load("E:\TestData\CompareDP\kenny\190523-G11M1-awake-stim2-dataHb.mat");

%% plot Fluor
lim = [-0.04 0.04];

nFrames = 80;
% Frames(1:nFrames) = struct('cdata',[], 'colormap',[]);
saveDest = 'D:\ProcessedData\corrFix\corrFluor-test2.avi';
writerObj = VideoWriter(saveDest);
writerObj.FrameRate = 20;

fig1 = figure(1);
set(fig1, 'Position', [50 50 1100 275], 'Visible', 'off', 'Color', 'white');

disp('Running...');
for i=1:80
    disp(num2str(i));
    sgtitle(['Corrected Fluor, t=' sprintf('%.2f',hillmanFluor.fluorTime(i)) 's']);
    
    subplot(1,3,1);
    imagesc(kennyFluor.xform_datafluorCorr(:,:,i), lim);
    set(gca,'Visible','off');
    colorbar; colormap('jet');
    axis(gca,'square');
    titleObj = title('Kenny');
    set(titleObj,'Visible','on');
    

    set(titleObj,'Visible','on');
    
    subplot(1,3,2);
    imagesc(hillmanFluor.xform_datafluorCorr(:,:,i), lim);
    set(gca,'Visible','off');
    colorbar; colormap('jet');
    axis(gca,'square');
    titleObj = title('Hillman');
    set(titleObj,'Visible','on');
    
    subplot(1,3,3);
    imagesc(kennyFluor.xform_datafluorCorr(:,:,i)-hillmanFluor.xform_datafluorCorr(:,:,i), lim/10);
    set(gca,'Visible','off');
    colorbar; colormap('jet');
    axis(gca,'square');
    titleObj = title('Difference');
    set(titleObj,'Visible','on');
    
    Frames(i) = getframe(fig1);
    drawnow;
    
end

% save video at desired framerate
% disp('Saving video...');
open(writerObj);
for i=1:length(Frames)
   frame = Frames(i);
   writeVideo(writerObj,frame);
end
close(writerObj);
close(fig1);
clear('Frames');
disp('Finished!');

%% plot Fluor - alternate method
tic;
lim = [-0.04 0.04];

fig1 = figure(1); set(fig1, 'Color', 'white','Position', [50 50 1100 275]);

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

subplot(1,3,1);
imagesc(zeros(128), lim);
set(gca,'Visible','off','NextPlot','replacechildren');
colorbar; colormap('jet');
axis(gca,'square');
titleObj = title('Kenny');
set(titleObj,'Visible','on');

subplot(1,3,2);
imagesc(zeros(128), lim);
set(gca,'Visible','off','NextPlot','replacechildren');
colorbar; colormap('jet');
axis(gca,'square');
titleObj = title('Hillman');
set(titleObj,'Visible','on');

subplot(1,3,3);
imagesc(zeros(128), lim);
set(gca,'Visible','off','NextPlot','replacechildren');
colorbar; colormap('jet');
axis(gca,'square');
titleObj = title('Difference');
set(titleObj,'Visible','on');

nFrames = 80;
vidObj = VideoWriter('D:\ProcessedData\corrFix\corrFluor-stimBlock_nomask.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 20;
open(vidObj);
toc;

for k=1200:2400
    
    disp(num2str(k));
    
    sgtitle(['Corrected Fluor, t=' sprintf('%.2f',hillmanFluor.fluorTime(k)) 's']);
    subplot(1,3,1);
    imagesc(kennyFluor.xform_datafluorCorr(:,:,k), lim);
    subplot(1,3,2);
    imagesc(hillmanFluor.xform_datafluorCorr(:,:,k), lim);
    subplot(1,3,3);
    imagesc(kennyFluor.xform_datafluorCorr(:,:,k)-hillmanFluor.xform_datafluorCorr(:,:,k),...
        lim/10);
        
    writeVideo(vidObj, getframe(fig1));
    
end

close(fig1);
close(vidObj);
disp('Finished');