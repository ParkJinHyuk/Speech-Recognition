clear;
clc;

fileExt = 'ha_5';
filename = [fileExt, '.wav'];

[x, fs] = audioread(filename);
[beginf, endf] = nonmun(x,20,5,fs);

plot(x);
hold on
stem(beginf, 1, 'r');
stem(endf, 1, 'r');
hold off

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

silence = round(10*fs/1000);
IMX = max(xin);
IMN = sum(abs(xin(1:silence)))/silence;
I1 = 0.3 * (IMX-IMN) + IMN;
I2 = 5.0 * IMN;
ITL = min(I1, I2);
ITU = 3.0 * ITL;
IZC = zc(xin,1,silence,ITL,ITU);
IF = 10;
oIZC = std(IZC);
IZCT = min(IF, IZC+3*oIZC+10);

while (ss+L-1 <= nsamples)
    
    frame=xin(ss:ss+L-1);
    energy=[energy sum(abs(frame))/L];
    zerocrossings=[zerocrossings zc(xin,ss,L,ITL,ITU)];
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

function y = zc(xin, ss, L, ITL, ITU)

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