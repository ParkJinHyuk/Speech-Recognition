fileExt = 'daa1';
filename = [fileExt, '.wav']; 
[x,fs] = audioread(filename);
figure;
% 저주파 필터를 한 것 tmp에 담김
[b, a] = butter(6, 1000 / fs * 2, 'high');
tmp = filtfilt(b, a, x);
% 이렇게하면 필터적용한거랑, 본래 주파수를 동시에 볼수 있음.
subplot(2,1,1);
plot([x,tmp])


tsize = length(tmp);


wsize = fs/100; 
%  //window size
msize = tsize -wsize +1; 
%  // overlapsize
result = zeros(1,msize);
%  //결과물 저장할것

for cnt = 1 :wsize :msize
    cortemp = corrcoef(tmp(1:cnt + wsize-1),x(1:cnt+wsize-1));
    result(cnt) = cortemp(1,2);
end


subplot(2,1,2);
plot(result)