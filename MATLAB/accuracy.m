close all;
clear;

accss = [];

for people = 1:3
    name = ["jh", "yj", "mh"];
    hangul = ["gaa", "naa", "daa", "raa", "maa", "baa", "saa", "aaa", "jaa", "cha", "kaa", "taa", "faa", "haa"];
    txtFile = ["jhData.txt", "yjData.txt", "mhData.txt"];
    path = ['./data/', char(name(people)), '/'];
    fileID = fopen([path, char(txtFile(people))], 'r');
    C = textscan(fileID, '%s %d');

    z = zeros(length(C{1}), 1);
    amounts = 0;
    corrects = 0;
    for i = 1:14
%         figure;
%         count = 1;
        for j = 1:5 
            fileExt = char(hangul(i) + j);
            filename = [fileExt, '.wav'];
      
            try
                [x, fs] = audioread([path, filename]);
            catch
                continue;
            end
            offset = 50;
            offset = fs/1000 * offset;
            
%             [b, a] = butter(6, 1500 / fs * 2, 'high');
%             filterX = filtfilt(b, a, x);
%             [beginf, endf] = nonmun(x,20,5,fs);
%             [beginf, endf] = setup_endpoints(x,fs, 20, 5, 10, 30);
%             [beginf, endf] = findStartFinish(x);
             [beginf, endf] = findStartFinishSpectro(x,fs);
%             [beginf, endf] = findStartFinishSpectroCFAR(x,fs);
%             [beginf, endf] = findStartFinishCFAR(x);


            for k = 1:length(z)
                if strcmp(fileExt, C{1}(k)) == 1
                    break;
                end
            end

            if C{2}(k) > beginf && C{2}(k)-beginf < offset
                z(k) = 1;
            elseif C{2}(k) < beginf && beginf - C{2}(k) < offset
                z(k) = 1;
            elseif C{2}(k) == beginf
                z(k) = 1;
            else
                figure;
                plot(x);
                title(fileExt);
                xlabel(name(people))
                hold on
                stem(C{2}(k), 1, 'b');
                stem(beginf, 1, 'r');
                stem(endf, 1, 'r');
                hold off
            end


%             subplot(6,1,count);
%             plot(x)
%             xlabel('Time (seconds)')
%             ylabel('Amplitude')
%             title(fileExt);
%             hold on
%             stem(C{2}(k), 1, 'b');
%             stem(beginf, 1, 'r');
%             stem(endf, 1, 'r');
%             hold off
%             count = count+1;
        end

        correct = 0;
        amount = 0;

        for k = 1:length(z)
%             if strcmp(jhHangul(i), C{1}{k}(1:3)) == 1
%             if strcmp(ygHangul(i), C{1}{k}(1:11)) == 1
%             if strcmp(mhHangul(i), C{1}{k}(1:3)) == 1
            if strcmp(hangul(i), C{1}{k}(1:3)) == 1
                amount = amount + 1;
                if z(k) == 1
                    correct = correct + 1;
                end
            end
        end

        corrects = corrects + correct;
        amounts = amounts + amount;
        acc = correct / amount * 100;

%         subplot(6,1,count); 
%         plot(1);
%         xlabel(acc);
    end

    accs = corrects / amounts * 100;
    accss = [accss, accs];
end



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

function y = findSum(similarity, k)
sum = 0;
for i = 1:length(similarity)
    for j = k*(i-1/k)-1:k*(i-1/k)+1
        sum = sum + similarity(i,j);
    end
end
y = sum;
end
    
function [beginf, endf] = findStartFinishCFAR(audio)

cutSize = 20000;
[M, I] = max(audio);
audio = audio(I-cutSize:I+cutSize); 

beginf = 1;
endf = 1;
wSize = 880;
sSize = 220;

threshold = 0.999999999999999;
Ms = [];
Ss = [];
for t = 1:sSize:length(audio)-wSize-sSize
    data = audio(t:t + wSize - 1).^2;
    M = mean(data);
    Ms = [Ms, M];
    S = std(data, 1);
    Ss = [Ss, S];
    MMs = mean(Ms);
    SSs = std(Ms, 1);
%     SSs = mean(Ss);
    pData = audio(t+sSize:t+sSize+wSize-1).^2;
    M_pData = mean(pData);
    p = normcdf(M_pData, MMs, SSs);

    if t < 10000
        continue;
    end
    
    if p > threshold
        beginf = t + wSize;
        break;
    end
end

Ms = [];
Ss = [];
audio = fliplr(audio);
for t = 1:sSize:length(audio)-wSize-sSize
    data = audio(t:t + wSize - 1).^2;
    M = mean(data);
    Ms = [Ms, M];
    S = std(data, 1);
    Ss = [Ss, S];
    MMs = mean(Ms);
    SSs = std(Ms, 1);
%     SSs = mean(Ss);
    pData = audio(t+sSize:t+sSize+wSize-1).^2;
    M_pData = mean(pData);
    p = normcdf(M_pData, MMs, SSs);

    if t < 10000
        continue;
    end
    
    if p > threshold
        endf = length(audio) - t - wSize;
        break;
    end
end

beginf = beginf + I - 20000;
endf = endf + I - 20000;

end

function [beginf, endf] = setup_endpoints(xin,fs,Lm,Rm,ethresh,zcthresh)
% analysis parameters; 
% Lmsec is analysis frame window duration in msec (40); L is analysis frame
% window duration in samples (computed from sampling rate)
% Rmsec is analysis frame window shift in msec (10); R is analysis frame
% window shift in samples (computed from sampling rate)
    L=round(Lm*fs/1000);
    R=round(Rm*fs/1000);
    
% compute log energy and zero crossings contours
    [loge,zc,nfrm]=analysis(xin,L,R,fs);
    
% compute endpoints
    [beginf,endf]=endpoints(nfrm,loge,zc,xin,fs,R,L,ethresh,zcthresh);
end

function [beginf,endf]=endpoints(nfrm,loge,zc,y,fs,R,L,ethresh,zcthresh)
%
% function to find endpoints of a speech utterance
%
% Inputs
%   nfrm: number of frames in log energy and zero crossings parameters
%   loge: log energy contour (1:nfrm)
%   zc: zero crossing rate contour (1:nfrm)
%   fullPAth: full path to current speech file
%   y: input speech (highpass filtered)
%   fs: sampling rate in Hz
%   R=frame shift in samples
%   L=frame duration in samples
%   ethresh=initial threshold on log energy contour
%   zcthresh=threshold on zero crossing rate contour
%
% Outputs
%   beginf: estimate of initial frame
%   endf: estimate of final frame

% clear peak1 and peak2 arrays
    clear peak1 peak2;

% normalize log energy contour so that peak is at 0 db
    logem=max(loge);
    loge(find(loge < logem - 60))=logem-60;
    logen=loge-logem;
    
% force first frame to be below threshold
    if (logen(1) > -ethresh-1) logen(1)=-ethresh-1;
    end
    
% force last frame to be below threshold
    if (logen(nfrm) > -ethresh-1) logen(nfrm)=-ethresh-1;
    end
    
% using threshold of 0 (dB) -thresh, find the strongest centroid and zero
% out the region for future checks
% peak1 is the lower peak, peak2 is the higher peak
    peak=find(logen == 0);
    peaklow=find(logen(1:peak(1)-1) < -ethresh);
    peak1(1)=peaklow(length(peaklow));
    peakhi=find(logen(peak(1)+1:nfrm) < -ethresh);
    peak2(1)=peakhi(1)+peak(1);
    
% zero out the energy pulse region
    logen(peak1(1):peak2(1))=-100;
    
% save regions in terms of peak1 and peak2
    isav=1;
    iend=0;
    
% iterate search for additional energy centroids
    while (iend == 0)
        logem=max(logen);
        if (logem < -ethresh) iend=1;
        else
            isav=isav+1;
            peak=find(logen == logem);
            peaklow=find(logen(1:peak(1)-1) < -ethresh);
            peak1(isav)=peaklow(length(peaklow));
            
            peakhi=find(logen(peak(1)+1:nfrm) < -ethresh);
            peak2(isav)=peakhi(1)+peak(1);
            
            if (peak2(isav)-peak1(isav) < 5)
                peak1(isav)=0;
                peak2(isav)=0;
                isav=isav-1;
                iend=1;
            else
                logen(peak1(isav):peak2(isav))=-100;
            end
        end
    end
    
% search for high zero crossings regions
    iend=0;
    isav1=isav;
    zcs=zc;
    while (iend == 0)
        zcm=max(zcs);
        peak=find(zcs == zcm);
        if (zcm < zcthresh || peak(1) < 5 || peak(1) > nfrm-5) 
            iend=1;
        else
            isav=isav+1;
            peaklow=find(zcs(1:peak(1)-1) < zcthresh);
            peak1(isav)=peaklow(length(peaklow));
            peakhi=find(zcs(peak(1)+1:nfrm) < zcthresh);
            peak2(isav)=peakhi(1)+peak(1);
            if (peak2(isav)-peak1(isav) < 5)
                peak1(isav)=0;
                peak2(isav)=0;
                isav=isav-1;
                iend=1;
            else
                zcs(peak1(isav):peak2(isav))=0;
            end
        end
    end
    
% determine final endpoints
    peak1s=sort(peak1(1:isav));
    peak2s=sort(peak2(1:isav));
    beginf=peak1s(1);
    endf=peak2s(isav);
    
    beginf=(beginf-1)*R+1;
    endf=(endf-1)*R+L-1;
end

function [energy,zerocrossings,nfrm]=analysis(xin,L,R,fs)
%
% function to compute log energy and zero crossing contours of speech file
%
% Inputs:
%   xin=input speech array
%   L=size of analysis frame in samples
%   R=size of analysis frame shift in samples
%   fs=speech signal sampling frequency in Hertz
%
% Outputs:
%   energy=log energy contour of full utterance
%   zerocrossings = normalized (per 10 msec) zero crossings contour for utterance
%   nfrm=number of frames in original utterance
% perform computation of short-time log energy and zero crossing rate
    nsamples=length(xin);
    ss=1;
    energy=[];
    zerocrossings=[];
    while (ss+L-1 <= nsamples)
        frame=xin(ss:ss+L-1).*hamming(L);
        energy=[energy 10*log10(sum(frame.^2))];
        zerocrossings=[zerocrossings sum(abs(diff(sign(frame))))];
        ss=ss+R;
    end
    nfrm=length(energy);
    zerocrossings=zerocrossings*fs/(200*L);
end

function [beginf, endf] = nonmun(xin,Lm,Rm,fs)

% Inputs:
%   xin=input speech array
%   Lm=analysis frame window duration in msec
%   Rm=analysis frame window shift in msec
%   fs=speech signal sampling frequency in Hertz

L=round(Lm*fs/1000);
R=round(Rm*fs/1000);

nsamples=length(xin);
ss=1;
energy=[];
zerocrossings=[];

silence = round(120*fs/1000);
IMX = max(xin);
IMN = sum(abs(xin(1:silence)))/silence;
I1 = 0.3 * (IMX-IMN) + IMN;
I2 = 5.0 * IMN;
ITL = min(I1, I2);
ITU = 3.0 * ITL;
IZC = findZC(xin,1,silence,ITL,ITU);
IF = 10;
oIZC = std(IZC);
IZCT = min(IF, IZC+3*oIZC+10);

while (ss+L-1 <= nsamples)
    
    frame=xin(ss:ss+L-1);
    energy=[energy sum(abs(frame))/L];
    zerocrossings=[zerocrossings findZC(xin,ss,L,ITL,ITU)];
    ss=ss+R;
end

tmp = find(xin > ITL);
check = 0;
count = 0;
tmpF = 0;
for i = 1:length(tmp)
    tmpF = tmp(i);
    if tmpF < count
        continue;
    end
    
    for j = tmpF:tmpF+2000
       if xin(j) >= ITU
           check = 1;
           break;
       elseif xin(j) >= ITL
           continue;
       else
           check = -1;
           break;
       end
    end
    
    if check == 1
           beginf = tmpF;
           break;
    else
        count = j;
        continue;
    end
end

check = 0;
count = length(xin);
tmpF = 0;
for i = length(tmp):-1:1
    tmpF = tmp(i);
    if tmpF > count
        continue;
    end
    
    for j = tmpF:-1:tmpF-2000
       if xin(j) >= ITU
           check = 1;
           break;
       elseif xin(j) >= ITL
           continue;
       else
           check = -1;
           break;
       end
    end
    
    if check == 1
        endf = tmpF;
        break;
    else
        count = j;
        continue;
    end
end

% N = round(beginf/R);
% T = round(fs/4/R);
% for i = N-T:N
%     if zerocrossings(i) > 9
%         break;
%     end
% end
% tmp = i*R;
% beginf = find(xin > tmp


end

function y = findZC(xin, ss, L, ITL, ITU)

    z=[];
    
    for idx = ss:ss+L-2
        
        if xin(idx+1) >= ITU
            s1 = 1;
        elseif xin(idx+1) <= ITL
            s1 = -1;
        else
            s1 = 0;
        end
        
        if xin(idx) >= ITU
            s2 = 1;
        elseif xin(idx) <= ITL
            s2 = -1;
        else
            s2 = 0;
        end
        
        z = [z abs(s1-s2)];
    end
    
    y = sum(z)/2;
    
end

function [beginf, endf] = findStartFinish(energy)
[M, mIdx] = max(energy);
threshold = M/10;
cutLeftTimeSize = 15000;
cutRightTimeSize = 15000;
beginf = 1;
endf = 1;

idx = 1;
temp = find(energy > threshold);

while true
    if temp(idx) > mIdx - cutLeftTimeSize
        beginf = temp(idx);
        break;
    end
    idx = idx + 1;
end

idx = length(temp);
while true
    if temp(idx) < mIdx + cutRightTimeSize
        endf = temp(idx);
        break;
    end
    idx = idx - 1;
end

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

threshold = 0.99;
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