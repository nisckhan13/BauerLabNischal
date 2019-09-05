%% five bauer mice
dsIn = ["1" "2" "4" "6" "7" "8"];
dateDSIn = ["181116" "181116" "181116" "181116" "181116" "181116"];
useGSR = true;

for mouse=6:length(dsIn)
    stimBlockAvg_young_bauer(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end

%% run mouse 8

excelFile = 'C:\Users\Nischal\Documents\GitHub\BauerLabNischal\excelFile.xlsx';
excelRows = 47:48;

exampleTiff(excelFile,excelRows)

%% five bauer mice, aged
dsIn = ["442" "443" "446" "447" "578"];
dateDSIn = ["180918" "180918" "180918" "180918" "180918"];
useGSR = true;

for mouse=1:length(dsIn)
    stimBlockAvg_aged_bauer(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end