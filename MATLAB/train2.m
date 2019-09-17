clear;
close all;

fileExt = 'ha_1';
filename = [fileExt, '.wav'];

[x, fs] = audioread(filename);

[beginf, endf] = findStartFinishSpectro(x,fs);
figure;
plot(x);
hold on
stem(beginf, 1, 'r');
stem(endf, 1, 'r');
hold off

function [beginf, endf] = findStartFinishSpectro(x,fs)
window = ceil(fs/86);
noverlap = ceil(fs/172);
nfft = ceil(fs/86);
s = spectrogram(x, window, noverlap, nfft);
s = abs(s);

whatthe = round(2000/fs*512);
sumS = sum(s(1:whatthe, :));

[M, mIdx] = max(sumS);
leftThreshold = M/10;
rightThreshold = M/20;
cutLeftTimeSize = round(fs * 150 / 1000 / noverlap);
cutRightTimeSize = round(fs * 250 / 1000 / noverlap);
beginf = 1;
endf = 1;

idx = 1;
temp = find(sumS > leftThreshold);

while true
    if temp(idx) > mIdx - cutLeftTimeSize
        beginf = temp(idx);
        break;
    end
    idx = idx + 1;
end

temp = find(sumS > rightThreshold);
idx = length(temp);
while true
    if temp(idx) < mIdx + cutRightTimeSize
        endf = temp(idx);
        break;
    end
    idx = idx - 1;
end

beginf = beginf * noverlap;
endf = endf * noverlap;

end