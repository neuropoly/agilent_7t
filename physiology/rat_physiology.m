%Look at physiology
%Step1: load data from the 4 channels
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\LE6HC01\Physio_Epip02_LE6HC';
K1 = load(fullfile(path0,'LE6HCsr1.txt'),'-ascii'); %ECG wave
K2 = load(fullfile(path0,'LE6HCsr2bis.txt'),'-ascii'); %Respiration
K3 = load(fullfile(path0,'LE6HCsr3.txt'),'-ascii'); %ECG wave
K4 = load(fullfile(path0,'LE6HCsr4.txt'),'-ascii'); %ECG wave
nK1 = size(K1,1);
nK2 = size(K2,1);
nK3 = size(K3,1);
nK4 = size(K4,1);
TRK = 1/900; TRP = 4*TRK;
SB = 1; SW = 2; %bit or wave
%Correlation betwen ECG wave from K1 and from K3:
%Using a 10 s sample
si = 0; ei = 20;
lpK = linspace(si,ei,(ei-si)/TRK); 
idxK = (si/TRK+1):(ei/TRK);
W1 = K1(idxK,SW);
W3 = K3(idxK,SW);
W4 = K4(idxK,SW);
% MLAGS = 3/TRK;
% laglp = linspace(-MLAGS,MLAGS,2*MLAGS+1);
% xco13 = xcorr(W1,W3,MLAGS,'unbiased');
% figure; plot(laglp,xco13);
% [p13 i13] = findpeaks(xco13,'MINPEAKDISTANCE',1/(2*TRK));
% for i0=1:min(length(i13),5)
%     ci = i13(i0);
%     endi = idxK(end);
%     if ci < MLAGS
%         idx1 = 1:(endi-ci);
%         idx3 = ci:endi;
%     else
%         ci = MLAGS - ci;
%         idx3 = 1:(endi-ci);
%         idx1 = ci:endi;
%     end
%     figure; plot(W1(idx1),'k'); hold on; plot(W3(idx3),'r');
% end
figure; plot(W1,'k'); hold on; plot(W3,'r');
lag3over1 = 13143-8134;
lag4over3 = 8134-5842-1;
lag4over1 = lag4over3+lag3over1;
%Now, K1, K3 and K4 are aligned
figure; plot(W1(lag4over1+2:end),'k'); hold on; plot(W3(lag4over3+2:end),'r'); plot(W4,'b')
figure; hold on;
subplot(2,2,1); plot(K1(lag4over1+2:end,SB),'k'); 
subplot(2,2,2); plot(K3(lag4over3+2:end,SB),'k'); 
subplot(2,2,3); plot(K4(:,SB),'k'); subplot(2,2,4); plot(K4(:,SW),'k')

%Upsample K2, = P:
P = interp(K2(:,SW),4);
A1 = interp(K2(:,SB),4);

figure; hold on;
% subplot(1,2,1); 
% lp1 = linspace((lag4over1+2)*TRK,n1*TRK,n1-lag4over1-1); plot(lp1,K1(lag4over1+2:end,SB),'k'); 
% title('Aux In')
% subplot(2,2,2); 
% title('ECG gate')
%subplot(2,2,3); 
n4 = size(K4,1); lp4 = linspace(0,n4*TRK,n4); 
%ECG gate
plot(lp4,650+ 10*(1-K4(:,SB)),'r'); 
%ECG wave
plot(lp4,K4(:,SW),'k'); 
n3 = size(K3,1); 
lp3 = linspace(-(lag4over3+1)*TRK,(n3-(lag4over3+1))*TRK,n3); 
%Respiration gate
plot(lp3,670+10*(K3(:,SB)),'b');
%ECG wave for resp.gate -- test synchronization
%plot(lp3,K3(:,SW),'g');
%Aux In
n1 = size(K1,1); 
lp1 = linspace(-(lag4over1+1)*TRK,(n1-(lag4over1+1))*TRK,n1); 
plot(lp1,690+10*K1(:,SB),'g'); 
%ECG wave for Aux In -- test synchronization
%plot(lp1,K1(:,SW),'y'); 
n2 = size(P,1);
lp2 = linspace(0,n2*TRK,n2);
plot(lp2,P+500,'b')
title('ECG wave, resp. wave, ECG gate, resp. gate and Aux In')
%subplot(2,2,4);





%Display Aux In from K1 and P: -- EPI pas une bonne séquence pour ça...
A1 = 1-K1(idxK,SB);
A2 = 1-P(idxK,SB);
F1 = find(1-K1(:,SB));
F2 = find(1-P(:,SB));
p1 = length(F1)/size(K1,1);
p2 = length(F2)/size(P,1);

figure; plot(P(:,SB))

figure; plot(1-A1,'k'); hold on; plot(1-A2,'r');

figure; plot(lpK,K(idxK,2),'k'); hold on; stem(lpK, 800*(1-K(idxK,1)),'r')
plot(lpP,P(idxP,2),'b');  stem(lpP, 800*(1-P(idxP,1)),'g')
%Upsample P:
Pu = upsample(P,4);
Pu = Pu(1:nK,:);
MLAGS = 3/TRK;
laglp = linspace(-MLAGS,MLAGS,2*MLAGS+1);
figure; plot(laglp,xcorr(1-Pu(:,2),1-K(:,2),MLAGS,'unbiased')) %2132; 2004

figure; plot(laglp,xcorr(1-Pu(idxK,2),1-K(idxK,2),MLAGS,'unbiased')) %2132; 2004