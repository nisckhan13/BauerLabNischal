load('G:\OISProjects\CulverLab\Stroke\TMCAO\SeedsUsed_121217.mat', 'SeedsUsed', 'symisbrainall');

length=size(SeedsUsed,1);
map=[(1:2:length-1) (2:2:length)];

idx=zeros(size(SeedsUsed,1),1);  %Left/Right Indices
for s=1:size(SeedsUsed, 1);
    idx(s)=sub2ind([128,128], SeedsUsed(s,2), SeedsUsed(s,1));
end
brainidx=find(symisbrainall==1);

for n=[3:75];
    
    [junk dir]=xlsread('G:\OISProjects\CulverLab\Stroke\TMCAO\StrokeMasterList.xlsx',1, ['A',num2str(n),':G',num2str(n)]);

    Group=dir{4};
    
    AllBound=zeros(128,128,size(SeedsUsed,1));
    R_brain=zeros(size(SeedsUsed,1));
    tempR=zeros(size(SeedsUsed,1));
    
    if  strcmp(Group,'Base')
        tic
        disp(['Processing ' num2str(s), ' = ', dir{2}])
        load([dir{1},'\',dir{2}],'R_seed_VM');
        
        tempR=normr(R_seed_VM)*normr(R_seed_VM)';
        R_brain(map,map)=tempR;
        
        for s=1:size(SeedsUsed,1);
            tempedge=zeros(128);
            tempedge(idx)=R_brain(s,:);
            AllBound(:,:,s) = edge(tempedge,'canny');
        end
        
        MeanFuncBound_VM=mean(AllBound, 3);
        save([dir{1},'\',dir{2}],'MeanFuncBound_VM','-append');
        toc
    else
        disp(['Skipped ' num2str(n), ' = ', dir{2}])
    end
    
end


%%To Visualize
% for n=2:2:size(SeedsUsed);
%     test=zeros(128);
%     test(idx)=R_bound(n,:);
%     imagesc(test, [-.1 .1]);
%     hold on;
%     plot(SeedsUsed(n,1),SeedsUsed(n,2),'ko','MarkerFaceColor','w'); pause(0.01);
%     hold off
% end

% for n=1:8910;
%
%      temp=R_new(n,:);
%      test=zeros(128);
%      test(idx)=temp;
%
%
%     temp1=Rgrad(n,:);
%     test1=zeros(128);
%     test1(idx)=temp1;
%     subplot(1,2,1); imagesc(test, [-1 1]); axis image off; title('Spatial Correlation');
%     subplot(1,2,2); imagesc(test1, [-.1 .1]); axis image off; title('Gradient of Spatial Correlation');
%     pause(0.01);
% end