
close all
figure; %Tell Matlab to make a figure
% set(gcf,'units','inches','position',[.1 .1  12  2]);
% set(gca,'units','inches','position',[0.1 0.1 5 5],'fontsize',24);
% set(gcf,'color','white')

%--SELECT SCALE Below-----------------------------------------------------
%  a=0.01; % for delta OXY
%  b=0.05; % for delta OXY

 a=0.0; % for Infraslow OXY
 b=1.2; % for Infraslow OXY

%  a=0.3; % for infraslow GCAMP
%  b=3.5; % for infraslow GCAMP

%  a=0.1; % for delta GCAMP
%  b=0.25; % for delta GCAMP

%---------------------------------------------
Hz = linspace(0,16.81/2,7559);%Create a line of the data

%--SELECT FREQUENCY Below------------------------
% range=find(Hz>1&Hz<4); % Delta Frequency
 range=find(Hz>0.02&Hz<0.1); % Infraslow Frequency

group='Aged';  %Selet the Group created in Power compiler

pp=0;
% lengthz= size(rightpaw1.(group).gpower,4);

for q =1:20;
    pp=pp+1;
    brain = squeeze(nanmean(Week12Power.(group).gpower(:,:,range,q),3));%Control F the Name of the Structure here
   brain(isnan(brain))=0.0;

    mask = Week12Power.(group).masks(:,:,q);
    mask(isnan(mask))=0; %Turns all Nan to 0
    tittle= [Week12Power.(group).names{q}];
    unicorn = overlaymouse(brain,White_Background,papermask2,jet,a,b);
    subplot(5, 5,pp); imshow(unicorn); 
    title([tittle]); 
    caxis([a b]); colormap  jet;
%     colorbar
%     caxis([ a b]);
%     hold on
%     visboundaries(roi,'LineWidth', 0.2, 'Color', 'w');
%     
end;