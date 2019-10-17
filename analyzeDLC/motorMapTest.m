figure;
for i=1:238
    currDat = a(:,i);
    if max(currDat) <= 2.5 && min(currDat) >= -2.5
        plot(currDat);
        hold on;
    end
end

%% 
figure;
imagesc(b, [-2.5 2.5]);
colormap('jet'); colorbar;