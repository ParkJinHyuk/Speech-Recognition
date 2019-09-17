freqRange = [1, 2000];

max = 0;


% for t = 10:100:610
%     for l = 1000:500:6000
%         for r = 2000:1000:15000
            freqData = zeros(2000, 35);

            for i = 1:35
                fileExt = char("train.ga" + i);
                filename = [fileExt, '.wav'];
                try
                    [x, fs] = audioread(filename);
                catch
                    continue;
                end
                energy = findEnergy(x);
                plot(x)
%                 startFinish = findStartFinish(energy, 10, l, r);
%                 syllable = x(startFinish(1):startFinish(2));
%                 y = fft(syllable);  
%                 freqData(:, i) = abs(y(freqRange(1):freqRange(2)));
            end
            
%             similarity = corrcoef(freqData);
%             similaritySum = sum(similarity, 'all');
%             if max < similaritySum
%                 max = similaritySum;
%                 key = [t, l];
%                 disp(key);

%             end
%         end
%     end
% end

function y = findEnergy(audio)
wSize = 1500;
energy = zeros(1, length(audio)-wSize + 1);
for t = 1:length(audio)-wSize+1
    tmp = 0;
    for w = 0:wSize-1
        tmp = tmp + audio(t+w)^2;
    end
    energy(t) = tmp;
end
y = energy;
end

function y = findStartFinish(energy, t, l, r)
[M, mIdx] = max(energy);
threshold = t/M;
cutLeftTimeSize = l;
cutRightTimeSize = r;

start = 0;
finish = 0;
temp = find(energy > threshold);

idx = 1;
while true
    if temp(idx) > mIdx - cutLeftTimeSize
        start = temp(idx);
        break;
    end
    idx = idx + 1;
end

idx = length(temp);
while true
    if temp(idx) < mIdx + cutRightTimeSize
        finish = temp(idx);
        break;
    end
    idx = idx - 1;
end

y = [start finish];
end