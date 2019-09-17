fileExt = 'na_2';
filename = [fileExt, '.wav'];

[x, fs] = audioread(filename);




% ga = [zeros(fs*1,1);x(37321:60000);zeros(fs*1,1)];
% audiowrite("hatest.wav",ga,fs);

% [b, a] = butter(6, 300 / fs * 2, 'low');
% tmp = filtfilt(b, a, x);
% 
% tsize = length(tmp);
% wsize = fs/100; 
% msize = tsize -wsize +1; 
% result = zeros(1,msize);
% 
% for cnt = 1 :wsize :msize
%     cortemp = corrcoef(tmp(1:cnt + wsize-1),x(1:cnt+wsize-1));
%     result(cnt) = cortemp(1,2);
% end
% 
% envel = envelope(result,wsize,'peak');
% envel = 1 - envel;

% [beginf, endf] = findStartFinishSpectroCFAR(x,fs);
% [beginf, endf] = findStartFinishCFAR(x);
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

whatthe = round(6500/fs*window);
sumS = sum(s(1:whatthe, :));

[M, mIdx] = max(sumS);
leftThreshold = 0.115 * M;
rightThreshold = 0.1 * M;
cutLeftTimeSize = round(fs * 200 / 1000 / noverlap);
cutRightTimeSize = round(fs * 400 / 1000 / noverlap);
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

sumS = fliplr(sumS);
idx = 1;
temp = find(sumS > rightThreshold);

while true
    if temp(idx) > mIdx - cutRightTimeSize
        endf = length(sumS) - temp(idx);
        break;
    end
    idx = idx + 1;
end

beginf = beginf * noverlap;
endf = endf * noverlap;

end

function [beginf, endf] = findStartFinishSpectroCFAR(x,fs)
window = ceil(fs/86);
noverlap = ceil(fs/172);
nfft = ceil(fs/86);
s = spectrogram(x, window, noverlap, nfft);
s = abs(s);

whatthe = round(2000/fs*512);
sumS = sum(s(1:whatthe, :));

[M, I] = max(sumS);
cutLeftTimeSize = round(fs * 200 / 1000 / noverlap);
cutRightTimeSize = round(fs * 250 / 1000 / noverlap);

sumS = sumS(I-cutLeftTimeSize:I+cutRightTimeSize); 
% leftThreshold = M/10;
% rightThreshold = M/20;
beginf = 1;
endf = 1;



% idx = 1;
% temp = find(sumS > leftThreshold);
% 
% while true
%     if temp(idx) > mIdx - cutLeftTimeSize
%         beginf = temp(idx);
%         break;
%     end
%     idx = idx + 1;
% end
% 
% temp = find(sumS > rightThreshold);
% idx = length(temp);
% while true
%     if temp(idx) < mIdx + cutRightTimeSize
%         endf = temp(idx);
%         break;
%     end
%     idx = idx - 1;
% end
% 
% beginf = beginf * noverlap;
% endf = endf * noverlap;
wSize = 4;
sSize = 1;

threshold = 0.9;
Ms = [];
Ss = [];
for t = 1:sSize:length(sumS)-wSize-sSize
    data = sumS(t:t + wSize - 1).^2;
    M = mean(data);
    Ms = [Ms, M];
    S = std(data, 1);
    Ss = [Ss, S];
    MMs = mean(Ms);
    SSs = std(Ms, 1);
%     SSs = mean(Ss);
    pData = sumS(t+sSize:t+sSize+wSize-1).^2;
    M_pData = mean(pData);
    p = normcdf(M_pData, MMs, SSs);

    if t < 10
        continue;
    end
    
    if p > threshold
        beginf = t + wSize;
        break;
    end
end

Ms = [];
Ss = [];
sumS = fliplr(sumS);
for t = 1:sSize:length(sumS)-wSize-sSize
    data = sumS(t:t + wSize - 1).^2;
    M = mean(data);
    Ms = [Ms, M];
    S = std(data, 1);
    Ss = [Ss, S];
    MMs = mean(Ms);
    SSs = std(Ms, 1);
%     SSs = mean(Ss);
    pData = x(t+sSize:t+sSize+wSize-1).^2;
    M_pData = mean(pData);
    p = normcdf(M_pData, MMs, SSs);

    if t < 10
        continue;
    end
    
    if p > threshold
        endf = length(sumS) - t - wSize;
        break;
    end
end
beginf = (beginf + I - cutLeftTimeSize) * noverlap;
endf = (endf + I - cutRightTimeSize) * noverlap;
end

