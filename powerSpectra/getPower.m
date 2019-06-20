%{
function getPower(excelFile, rows, varargin)

%acquire freq range if specified, if not, use ISA
if numel(varargin) > 0
    fRange = varargin{1};
else
    fRange = [0.009 0.08];
end

%store freq range as string for naming output file
fStr = [num2str(fRange(1)) '-' num2str(fRange(2))];
fStr(strfind(fStr,'.')) = 'p';

%parse the runs listed in excel file
runsInfo = parseTiffRuns(excelFile,rows);
if isempty(runsInfo)
    runsInfo = parseDatRuns(excelFile,rows);
end

end
%}
nfft = 4096;
fs = 20;

loadData = load('C:\Users\Nischal\Documents\matlabItems\nischalScripts\PowerSpectra\exampleData\190530-R3M2368-fc1-dataHb.mat');
data = loadData.xform_datahb;
mask = loadData.xform_isbrain;
data = squeeze(data(:,:,1,:));
data = mouse.process.gsr(data,mask);

spectra = nan(128,128,numel(pwelch(rand(1,size(data,3)),[],[],nfft,fs)));
for y = 1:128
    for x = 1:128
        [spectra(y,x,:),freq] = pwelch(squeeze(data(y,x,:)),[],[],nfft,fs);
    end
end
%% across mask
figure(1);
plot(freq,squeeze(spectra(100,100,:)));

%log before taking mean (to normalize)
spectraLog = log(spectra);
spectraLogVector = reshape(spectraLog,16384,[]);
maskVector = reshape(mask,numel(mask),1);
%apply the mask to spectra
spectraLogMask = spectraLogVector(maskVector,:);
%take mean of first dimension
meanSpectraLog = mean(spectraLogMask,1);
meanSpectra = exp(meanSpectraLog);
loglog(freq, meanSpectra);
xlim([10^-2 10]);
xlabel('Frequency (log scale)')
ylabel('Mean Power Spectra (log scale)')

%% across frequencies
figure(2)
ISARange = [0.009 0.08];
ISAFreq = freq >= ISARange(1) & freq <= ISARange(2);
spectraLogISA = spectraLog(:,:,ISAFreq);
meanSpectraLogISA = mean(spectraLogISA,3);
imagesc(meanSpectraLogISA);
colorbar;
axis(gca,'square');

%collapse figures on a dimension that is meaningful