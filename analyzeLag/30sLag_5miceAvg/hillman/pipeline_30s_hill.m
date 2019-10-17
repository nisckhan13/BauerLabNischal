%% young mice hillman
dsIn = ["1" "2" "4" "6" "7"];
dateDSIn = ["181116" "181116" "181116" "181116" "181116"];
useGSR = false;
corrThresh = 0.3;

for mouse=1:length(dsIn)
    dotLag_young_30s_noGSR_th_hill(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR,corrThresh);
end


%% aged mice hillman
dsIn = ["442" "443" "446" "447" "578"];
dateDSIn = ["180918" "180918" "180918" "180918" "180918"];
useGSR = false;
corrThresh = 0.3;

for mouse=1:length(dsIn)
    dotLag_aged_30s_noGSR_th_hill(char(dsIn(mouse)),char(dateDSIn(mouse)),useGSR, corrThresh);
end