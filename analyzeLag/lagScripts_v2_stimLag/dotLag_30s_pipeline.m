%% young mice - asher processed
dsIn = ["1" "2" "4" "6" "7" "8"...
"9" "10" "2046" "2047" "2048" "2049"...
"2052" "2053" "2054" "2055"];
dateDSIn = ["181116" "181116" "181116" "181116" "181116" "181116"...
"181116" "181116" "181115" "181115" "181115" "181115"...
"181115" "181115" "181115" "181115"];
useGSR = false;

for mouse=1:length(dsIn)
    dotLag_young_30s(char(dsIn(mouse)),char(dateDSIn(mouse)), useGSR);
end

%% young mice - bauer processed