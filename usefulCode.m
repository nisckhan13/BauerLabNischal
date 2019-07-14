% Make Movie
for ind=1:size(sumHb,4)
    imagesc(squeeze(sumHb(:,:,1,ind)), [-5e-6 5e-6]); 
    colormap('jet');
    axis(gca,'square');
    drawnow; 
end