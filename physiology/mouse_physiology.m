%Look at physiology
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\B6heart202\PhysioB6Heart202mouse';
P = load(fullfile(path0,'B6heart2a.txt'),'-ascii');
K = load(fullfile(path0,'B6heart2b.txt'),'-ascii');
figure; n = size(K,1); lp = linspace(1,n/900,n); plot(lp,...
K(:,2),'k'); hold on; stem(lp, 800*(K(:,1)),'r')
figure; n = size(P,1); lp = linspace(1,4*n/900,n); plot(lp,...
P(:,2),'k'); hold on; stem(lp, 800*(1-P(:,1)),'r')

nK = size(K,1);
nP = size(P,1);
%Reduce size
TRK = 1/900; TRP = 4*TRK;
si = 4000; ei = 4500;
lpK = linspace(si,ei,(ei-si)/TRK); 
lpP = linspace(si,ei,(ei-si)/TRP);
idxK = (si/TRK+1):(ei/TRK);
idxP = (si/TRP+1):(ei/TRP);
figure; plot(lpK,K(idxK,2),'k'); hold on; stem(lpK, 800*(1-K(idxK,1)),'r')
plot(lpP,P(idxP,2),'b');  stem(lpP, 800*(1-P(idxP,1)),'g')
%Upsample P:
Pu = upsample(P,4);
Pu = Pu(1:nK,:);
MLAGS = 3/TRK;
laglp = linspace(-MLAGS,MLAGS,2*MLAGS+1);
figure; plot(laglp,xcorr(1-Pu(:,2),1-K(:,2),MLAGS,'unbiased')) %2132; 2004

figure; plot(laglp,xcorr(1-Pu(idxK,2),1-K(idxK,2),MLAGS,'unbiased')) %2132; 2004