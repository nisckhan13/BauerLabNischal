%% 5 young mice
dsIn = ["8"];
dateDSIn = ["181116" "181116" "181116" "181116" "181116"];
useGSR = true;

for mouse=1:length(dsIn)
    stimBlockAvg_young(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end


%% 5 aged mice

dsIn = ["442" "443" "446" "447" "578"];
dateDSIn = ["180918" "180918" "180918" "180918" "180918"];
useGSR = true;

for mouse=1:length(dsIn)
    stimBlockAvg_aged(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end


%% 5 young mice bauer
dsIn = ["8"];
dateDSIn = ["181116" "181116" "181116" "181116" "181116"];
useGSR = true;

for mouse=1:length(dsIn)
    stimBlockAvg_young_bauer(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end


%% 5 aged mice bauer

dsIn = ["442" "443" "446" "447" "578"];
dateDSIn = ["180918" "180918" "180918" "180918" "180918"];
useGSR = true;

for mouse=1:length(dsIn)
    stimBlockAvg_aged_bauer(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end

%% process 5 aged mic bauer 

excelFile='C:\Users\Nischal\Documents\GitHub\BauerLabNischal\excelFile.xlsx';
excelRows = 49:58;

exampleTiff(excelFile,excelRows);