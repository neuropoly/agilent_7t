path0 = 'D:\Users\Philippe Pouliot\RabbitOx';
nameID = 'RabbitOx2_';
SB = 1; SW = 2; %bit or wave

K1 = load(fullfile(path0,[nameID 'C1.txt']),'-ascii'); %respiration
K2 = load(fullfile(path0,[nameID 'C2.txt']),'-ascii'); %ECG wave
K3 = load(fullfile(path0,[nameID 'C3.txt']),'-ascii'); %ECG wave
K4 = load(fullfile(path0,[nameID 'C4.txt']),'-ascii'); %ECG wave
nK1 = size(K1,1);
nK2 = size(K2,1);
nK3 = size(K3,1);
nK4 = size(K4,1);
TRK = 1/900; TRP = 4*TRK;
figure; plot(K3(:,SW));
figure; plot(K2(:,SB));
figure; plot(K3(:,SW));