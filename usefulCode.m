% Make Movie
for ind=1:6005
    imagesc(b(:,:,ind)); 
    colormap('jet');
    axis(gca,'square');
    hold on;
    title(num2str(ind));
    drawnow;
end

%% plot movie of raw data HB and Fluor

data1 = hbData1All(:,:,:,1);
data2 = fluorData2All(:,:,:,1);

paramPath = what('bauerParams');
stdMask = load(fullfile(paramPath.path,'noVasculatureMask.mat'));
meanMask = stdMask.leftMask | stdMask.rightMask;

t = 125;
for ind=1:850
    hbMov = figure(1);
    set(hbMov,'Position',[50 50 400 800]);
    sgtitle(['181116-1-week0-fc1, t = ' sprintf('%.2f',t) ' s']);
    hbtMap = subplot(2,1,1);
    imagesc(data1(:,:,ind), 'AlphaData', meanMask, [-2e-3 2e-3]); 
    set(gca,'Visible','off');
    colorbar; colormap(hbtMap, 'jet');
    axis(gca,'square');
    titleObj = title('HbT');
    set(titleObj,'Visible','on');
    
    fluorMap = subplot(2,1,2);
    imagesc(data2(:,:,ind), 'AlphaData', meanMask, [-0.02 0.02]); 
    set(gca,'Visible','off');
    colorbar; colormap(fluorMap, 'gray');
    axis(gca,'square');
    titleObj = title('Fluor');
    set(titleObj,'Visible','on');
       
    
    F2(ind) = getframe(hbMov);
    drawnow;
    clf(hbMov);
    t = t + 0.0595;
end

disp('saving video');
writerObj = VideoWriter('D:\ProcessedData\AsherLag\TestLagSave\timeTraceMovies\1-week0-fc1-dataHb.avi');
writerObj.FrameRate = 16.8;

open(writerObj);
for i=1:length(F2)+
    frame = F2(i);
    writeVideo(writerObj, frame);
end
close(writerObj);
close(hbMov);
clear('F2');
