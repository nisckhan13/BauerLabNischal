%% all young mice
dsIn = ["1" "2" "4" "6" "7" "8"...
"9" "10" "2046" "2047" "2048" "2049"...
"2052" "2053" "2054" "2055"];
dateDSIn = ["181116" "181116" "181116" "181116" "181116" "181116"...
"181116" "181116" "181115" "181115" "181115" "181115"...
"181115" "181115" "181115" "181115"];
useGSR = true;

for mouse=1:length(dsIn)
    stimBlockAvg_young_justMaps(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
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
    stimBlockAvg_aged_justMaps(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end

%% 5 young mice 30s bauer processed

dsIn = ["1" "2" "4" "6" "7"];
dateDSIn = ["181116" "181116" "181116" "181116" "181116"];
useGSR = true;

for mouse=1:length(dsIn)
     dotLag_young_30s_bauer(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end

%% 5 aged mice 30s bauer processed

dsIn = ["1" "2" "4" "6" "7"];
dateDSIn = ["181116" "181116" "181116" "181116" "181116"];
useGSR = true;

for mouse=1:length(dsIn)
     dotLag_young_30s_bauer(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR);
end