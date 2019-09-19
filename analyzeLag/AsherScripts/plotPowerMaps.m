[a,b,numEl] = size(gpower);

for ind=1:numEl
    imagesc(gpower(:,:,ind)); 
    colormap('jet');
    axis(gca,'square');
    drawnow; 
end