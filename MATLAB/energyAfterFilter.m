fileExt = 'naa1';
filename = [fileExt, '.wav'];

[x, fs] = audioread(filename);


[b, a] = butter(6, 300 / fs * 2, 'low');
tmp = filtfilt(b, a, x);


tsize = length(tmp);
wsize = fs/100; 
msize = tsize -wsize +1; 
result = zeros(1,msize);

for cnt = 1 :wsize :msize
    cortemp = corrcoef(tmp(1:cnt + wsize-1),x(1:cnt+wsize-1));
    result(cnt) = cortemp(1,2);
end
envel = envelope(result,wsize,'peak');
envel = 1 - envel;



[beginf] = findBeginf(envel);

figure;
plot(x);
hold on
stem(beginf, 1, 'r');
% stem(endf, 1, 'r');
hold off



function [beginf] = findBeginf(energy)
[M, mIdx] = max(energy);
threshold = M/5;
cutLeftTimeSize = 15000;
beginf = 1;

idx = 1;
temp = find(energy > threshold);

while true
    if temp(idx) > mIdx - cutLeftTimeSize
        beginf = temp(idx);
        break;
    end
    idx = idx + 1;
end

end