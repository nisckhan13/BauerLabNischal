%% all young mice
dsIn = ["1" "2" "4" "6" "7" "8"...
"9" "10" "2046" "2047" "2048" "2049"...
"2052" "2053" "2054" "2055"];
dateDSIn = ["181116" "181116" "181116" "181116" "181116" "181116"...
"181116" "181116" "181115" "181115" "181115" "181115"...
"181115" "181115" "181115" "181115"];
useGSR = true;

for mouse=1:length(dsIn)
    stimBlockAvg_young(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end


%% all aged mice

dsIn = ["422" "424" "425" "426" "427" "450"...
"452" "459" "461" "307" "309" "421"...
"442" "443" "446" "447" "578"];
dateDSIn = ["180917" "180917" "180917" "180917" "180917" "180917"...
"180917" "180917" "180917" "180918" "180918" "180918"...
"180918" "180918" "180918" "180918" "180918"];
useGSR = true;

for mouse=1:length(dsIn)
    stimBlockAvg_aged(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end


%% process 5 aged mic bauer 

excelFile='C:\Users\Nischal\Documents\GitHub\BauerLabNischal\excelFile.xlsx';
excelRows = 49:58;

exampleTiff(excelFile,excelRows);