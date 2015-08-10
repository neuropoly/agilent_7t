function resp = mri_load_rat_physiology_respirationOnly(path0,nameID)
vshort = 1; %short version
TRK = 1/900; TRP = 4*TRK;
SB = 1; SW = 2; %bit or wave
if vshort
    K1 = load(fullfile(path0,[nameID 'C1.txt']),'-ascii'); %respiration -- bit gives respiration gates
    K4 = load(fullfile(path0,[nameID 'C4.txt']),'-ascii'); %ECG wave -- bit gives beginning of scans
    K1 = K1(2:end,:);
    K4 = K4(2:end,:);
    nK1 = size(K1,1);
    nK4 = size(K4,1); 
    A4 = K4(:,SB);
    B4 = find(1-A4); 
    delay = B4(1)*TRK; %assume that 1st EPI scan started approximately at the second low value of A4.
    %Low pass filter the respiration signal
    W1 = K1(:,SW);
    %W1h = ButterHPF(1/TRP,0.1,2,W1);
    W1f = ButterLPF(1/TRP,3,2,W1);
    lpK1 = linspace(0,nK1*TRP,nK1);
    %figure; plot(lpK1,-W1f,'k');
    figure; plot(lpK1(2:end),-diff(W1f),'k');
    %[pks,locs] = findpeaks(-W1f,'MINPEAKDISTANCE',round(0.33/TRP),'MINPEAKHEIGHT',-550);
    [pks,locs] = findpeaks(-diff(W1f),'MINPEAKHEIGHT',0.5); %'MINPEAKDISTANCE',round(0.33/TRP)); %,
    rr = diff(locs)*TRP*60; %in respirations per minute
    %interpolate
    rri = interp1(locs(1:end-1)',rr',1:nK1,'spline');
    figure; plot(lpK1,rri)    
    resp.rri = rri;
    resp.delay = delay;
    resp.fs = 1/TRP; %in Hz
    %remove delay and truncate to 660 s 
    
else
    resp = [];
    %Look at physiology
    K1 = load(fullfile(path0,[nameID 'C1.txt']),'-ascii'); %respiration -- bit gives respiration gates
    K2 = load(fullfile(path0,[nameID 'C2.txt']),'-ascii'); %ECG wave --
    K3 = load(fullfile(path0,[nameID 'C3.txt']),'-ascii'); %ECG wave --
    K4 = load(fullfile(path0,[nameID 'C4.txt']),'-ascii'); %ECG wave -- bit gives beginning of scans
    nK1 = size(K1,1);
    nK2 = size(K2,1);
    nK3 = size(K3,1);
    nK4 = size(K4,1);    
    W1 = K1(:,SW);
    A1 = K1(:,SB);
    lpP = linspace(0,nK1*TRP,nK1);
    figure; plot(lpP,W1,'k'); hold on; plot(lpP,500*A1,'r');
    A2 = K2(:,SB); lpK2 = linspace(0,nK2*TRK,nK2); figure; plot(lpK2,A2,'k');
    A3 = K3(:,SB); lpK3 = linspace(0,nK3*TRK,nK3); figure; plot(lpK3,A3,'r');
    A4 = K4(:,SB); lpK4 = linspace(0,nK4*TRK,nK4); figure; plot(lpK4,A4,'g');
    %Using a 20 s sample
    si = 0; ei = 20;
    lpK = linspace(si,ei,(ei-si)/TRK);
    idxK = (si/TRK+1):(ei/TRK);
    a2 = K2(idxK,SB);
    a3 = K3(idxK,SB);
    a4 = K4(idxK,SB);
    figure; plot(lpK,a2,'k'); hold on; plot(lpK,a3,'r'); plot(lpK,a4,'g');
end