%% load data
filepath1 = 'E:\DLC-Working\Thy1-db-Bauer-2019-09-17\dlc-models\iteration-0\Thy1-dbSep17-trainset95shuffle1\train\learning_stats.csv';
filepath2 = 'E:\DLC-Working\Thy1-db-Bauer-2019-09-17\dlc-models\iteration-1\Thy1-dbSep17-trainset95shuffle1\train\learning_stats.csv';

data1 = xlsread(filepath1, 'learning_stats');
data2 = xlsread(filepath2, 'learning_stats');

%% plot data

figure(1);
set(figure(1),'Position',[300 300 600 400]);
plot(data1(:,1),data1(:,2));
hold on;
plot(data2(:,1),data2(:,2));
ylabel('Cross-entropy loss');
xlabel('Training iterations');
ylim([0 0.014]);
xlim([-25000 300000]);
ax = gca;
ax.XRuler.Exponent = 0;
set(gca, 'FontSize', 12);
legend('Gen0', 'Gen1');
set(figure(1),'color','w');
title('Loss');


%% quick plot

fileID = fopen('prahl_extinct_coef.txt');
A = textscan(fileID,'%f %f %f');

figure(1);
set(gcf,'Position',[300 100 1500 800]);
plot(A{1},A{2}, 'color', 'red');
hold on;
plot(A{1},A{3}, 'color', 'blue');
set(gcf,'color','w');
set(gca, 'FontSize', 16);
xlabel('wavelength (nm)');
set(gca, 'YScale', 'log')
ylabel('ext coeff (cm-1/M)');
legend('oxy', 'deoxy');