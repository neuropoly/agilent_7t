function mri_load_rabbit_physiology(path0,nameID,suffixID)
try
    run = 9;
    
    %Look at physiology
    %Step1: load data from the 4 channels
    K1 = load(fullfile(path0,[nameID 'C1' suffixID '.txt']),'-ascii'); %respiration
    K2 = load(fullfile(path0,[nameID 'C2' suffixID '.txt']),'-ascii'); %ECG wave
    K3 = load(fullfile(path0,[nameID 'C3' suffixID '.txt']),'-ascii'); %Respiration
    K4 = load(fullfile(path0,[nameID 'C4' suffixID '.txt']),'-ascii'); %ECG wave
    nK1 = size(K1,1);
    nK2 = size(K2,1);
    nK3 = size(K3,1);
    nK4 = size(K4,1);
    TRK = 1/900; TRP = 4*TRK;
    SB = 1; SW = 2; %bit or wave
    %Correlation betwen ECG wave from K1 and from K3:
    %Using a 10 s sample
    si = 0; ei = 40;
    lpK = linspace(si,ei,(ei-si)/TRK);
    idxK = (si/TRK+1):(ei/TRK);
    W2 = K2(idxK,SW);
    W4 = K4(idxK,SW);
    A2 = K2(idxK,SB);
    A4 = K4(idxK,SB);
    % Find best lag by maximum of correlation
    %     MLAGS = 4/TRK;
    %     laglp = linspace(-MLAGS,MLAGS,2*MLAGS+1);
    %     xco23 = xcorr(W2,W3,MLAGS,'unbiased');
    %     [peak_value best_lag] = max(xco23);
    %     best_lag = MLAGS-best_lag+1;
    %     figure; plot(laglp,xco23);
    %
    %Step 1 -- find lag
    figure; plot(W2,'k'); hold on; plot(W4,'r');
    switch run
        case 1 %FR6
            lag4over2 = -(30222-25751); %6013-5639; %FR6
        case 2 %FR7
            lag4over2 = 1318-1160;
        case 3 %FR7b
            lag4over2 = -8;
        case 4 %FR7c
            lag4over2 = 11;
        case 5 %FR8
            lag4over2 = 0;
        case 6 %FR10
            lag4over2 = 164-79;
        case 8 %FR12
            lag4over2 = 567-1329;
        case 9 %FR13
            lag4over2 = 0;
            
    end
    %
    %Check that lagged series matches with other series
    if lag4over2 > 0
        figure; plot(W2,'k'); hold on; plot(W4(lag4over2+1:end),'r');
        %figure; plot(A2,'k'); hold on; plot(A4(lag4over2+1:end),'r');
        ECG0 = K2(:,SW);
        RCVG0 = K2(:,SB);
        EG0 = 1-K4(lag4over2+1:end,SB);
    else
        figure; plot(W2(-lag4over2+1:end),'k'); hold on; plot(W4,'r');
        %figure; plot(A2(-lag4over2+1:end),'k'); hold on; plot(1-A4,'r');
        ECG0 = K4(:,SW);
        RCVG0 = K2(-lag4over2+1:end,SB);
        EG0 = 1-K4(:,SB);
        %figure; plot(K2(-lag4over2+1:end,SB),'k'); hold on; plot(1-K4(:,SB),'r');
    end
    %Step 2: find sequences recorded in these files
    %figure; plot(ECG0); hold on; plot(RCVG0)
    figure; plot(RCVG0)
    %Extract sequences:
    switch run
        case 1
            seq{1} = (2.5e4+1):4e5; FR6
            seq{2} = (5.8e5+1):8e5; FR6
        case 2
            
            seq{1} = 1.2e4:4.1e5; %fsems 7
            seq{2} = 4.4e5:8.5e5; %fsems 8
            seq{3} = 9.2e5:1.03e6; %tagcine7
        case 3
            seq{1} = 1.7e4:2.1e5;
            seq{2} = 3.1e5:5e5;
            seq{3} = 5.5e5:7.5e5;
        case 4
            seq{1} = 2.6e4:1.4e5;
            seq{2} = 1.48e5:2.6e5;
        case 6
            seq{1} = 1.4e5:1e6;
            seq{2} = 1.7e6:2.6e6;
        case 8
            seq{1} = 2.73e6:3.46e6; %FSEMS7
            seq{2} = 3.47e6:4.15e6; %FSEMS8
    end
    
    seqN = 2;
    ECG = ECG0(seq{seqN});
    NK = length(ECG);
    RCVG = RCVG0(seq{seqN});
    EG = EG0(seq{seqN});
    fRCVG = find(RCVG)';
    dRCVG = diff(fRCVG);
    figure; plot(dRCVG)
    pe_RCVG = [fRCVG(1) dRCVG(dRCVG>20)]; %129 = almost 512/4 for seq1, 65 = almost 256/4 for seq2
    %pet_RCVG = cumsum(pe_RCVG);
    [dummy pet_RCVG] = findpeaks(RCVG,'MINPEAKDISTANCE',80);
    Nvs = length(pet_RCVG);
    lpK = linspace(0,NK*TRK,NK);
    
    figure; plot(RCVG,'k'); hold on; stem(pet_RCVG,ones(1,Nvs),'r');
    
    figure; plot(lpK,RCVG,'k'); hold on; stem(pet_RCVG*TRK,ones(1,Nvs),'r'); plot(lpK,0.001*ECG,'g');
    %add ECG gate:
    figure; plot(lpK,RCVG,'k'); hold on; stem(pet_RCVG*TRK,ones(1,Nvs),'r'); plot(lpK,0.001*ECG,'g'); plot(lpK,EG,'b');
    
    %find distribution of delays for 1st and 2nd slices
    fEG = find(EG);
    ddl = zeros(1,Nvs);
    for i0=1:Nvs
        tmp = pet_RCVG(i0)-fEG;
        tmp = tmp(tmp>0);
        ddl(i0) = min(tmp);
    end
    figure; hist(reshape(ddl,1,[])');
    figure; hist(reshape(ddl,4,[])',200);
    %Distribution of R-R intervals 
    dEG = diff(fEG);
    pEG = dEG(dEG>1);
    figure; hist(pEG,200)
    %Distribution of gated ECG curves
    nECG = 1000; %data points, size of ECG window before receiver gates
    bECG = zeros(nECG,Nvs);
    for i0=1:Nvs
        ei = pet_RCVG(i0);
        bECG(:,i0) = ECG(ei-nECG+1:ei);
    end
    figure; imagesc(bECG)
    figure; imagesc(bECG(800:1000,:))
     figure; plot(bECG(1:1000,:))
    %Lecture des images
    sl = 1; im = 1; ec = 1;
fname = ['slice' gen_num_str(sl,3) 'image' gen_num_str(im,3) 'echo' gen_num_str(ec,3)];
Y1 = dicomread([fname '.dcm']);
V1 = dicominfo([fname '.dcm']);
h = figure; imagesc(Y1); colormap(gray); axis off;
print(h,'-dpng',[fname '.png'],'-r300');
%Filter
F = fspecial('gaussian',[7 7],1.5);
Yg = imfilter(Y1,F,'replicate');
h2 = figure; imagesc(Yg); colormap(gray); axis off;
print(h2,'-dpng',[fname 'filt.png'],'-r300');

    %Lecture des fids:
    
f_path = 'D:\Users\Philippe Pouliot\IRM_scans\LapinFR10a01\fsems_RabbitClinical08.fid\';
[procpar,msg]=aedes_readprocpar([f_path,'procpar']);
    DATA=aedes_readfid([f_path,'fid'],...
        'procpar',procpar,...
        'wbar','on',...
        'Return',3,...
        'DCcorrection','off',...
        'Zeropadding','auto',...
        'sorting','on',...
        'FastRead','on',...
        'Precision','single',...
        'OrientImages','on',...
        'RemoveEPIphaseIm','off');
    ksp = squeeze(DATA.KSPACE(:,:,1));
    h = figure; imagesc(real(ksp)); colormap(gray); axis off;
    print(h,'-dpng',['k_real.png'],'-r300');
    h = figure; imagesc(imag(ksp)); colormap(gray); axis off;
    print(h,'-dpng',['k_imag.png'],'-r300');
     h = figure; imagesc(abs(ksp)); colormap(gray); axis off;
    print(h,'-dpng',['k_abs.png'],'-r300');
     h = figure; imagesc(angle(ksp)); colormap(gray); axis off;
    print(h,'-dpng',['k_phase.png'],'-r300');
    
    h = figure; imagesc(real(ksp),[-100 100]); 
    print(h,'-dpng',['k_real_th.png'],'-r300');
    h = figure; imagesc(imag(ksp),[-100 100]);
    print(h,'-dpng',['k_imag.png'],'-r300');
     h = figure; imagesc(abs(ksp),[-100 100]); 
    print(h,'-dpng',['k_abs.png'],'-r300');
     h = figure; imagesc(angle(ksp)); 
    print(h,'-dpng',['k_phase.png'],'-r300');
    
    
    data = ksp;
    data(:,301:304) = data(:,305:308);
    data=fftshift(fftshift(abs(fft(fft(data,[],1),[],2)),1),2);
    data = flipdim(flipdim(data,1),2);
    h = figure; imagesc(data); colormap(gray); axis off;
    print(h,'-dpng',[ 'replace.png'],'-r300');
    %Full signal:
    lpF = linspace(0,nK2*TRK,nK2);
    lpF3 = linspace(0,nK3*TRK,nK3);
    X2 = K2(:,SW);
    X3 = K3(:,SW);
    B2 = K2(:,SB); %only ones
    B1 = K1(:,SB); %also only ones
    B3 = K3(:,SB); %some info
    B4 = K4(:,SB); %also only ones
    
    B3 = B3(1:(nK2));
    figure; plot(lpF,X2,'k'); hold on; plot(lpF(lag3over2+1:end),800-200*B3(lag3over2+1:end),'r')
    figure; plot(lpF3,X3,'k'); hold on; plot(lpF3,900-200*B3,'r')
    
    %E-Resp signal is not working
    lpP = linspace(si,ei,(ei-si)/TRP);
    idxP = (si/TRP+1):(ei/TRP);
    W1 = K1(idxP,SW);
    W4 = K4(idxP,SW);
    figure; plot(W1,'k'); hold on; plot(W4,'r');
    
    %Now, K1, K3 and K4 are aligned
    figure; plot(W1(lag4over1+2:end),'k'); hold on; plot(W3(lag4over3+2:end),'r'); plot(W4,'b')
    figure; hold on;
    subplot(2,2,1); plot(K1(lag4over1+2:end,SB),'k');
    subplot(2,2,2); plot(K3(lag4over3+2:end,SB),'k');
    subplot(2,2,3); plot(K4(:,SB),'k'); subplot(2,2,4); plot(K4(:,SW),'k')
    
    %Upsample K2, = P:
    P1 = interp(K2(:,SW),4);
    P4 = interp(K4(:,SW),4);
    
    A1 = interp(K1(:,SB),4);
    A4 = interp(K4(:,SB),4);
    
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
    
%     sl = 1; im = 1; ec = 1;
%     fname = ['slice' gen_num_str(sl,3) 'image' gen_num_str(im,3) 'echo' gen_num_str(ec,3)];
%     Y1 = dicomread([fname '.dcm']);
%     V1 = dicominfo([fname '.dcm']);
%     h = figure; imagesc(Y1); colormap(gray); axis off; 
%     print(h,'-dpng',[fname '.png'],'-r300');
%     %filter
%     F = fspecial('gaussian',[7 7],1.5);
%     Yg = imfilter(Y1,F,'replicate');
%     h2 = figure; imagesc(Yg); colormap(gray); axis off; 
%     print(h2,'-dpng',[fname 'filt.png'],'-r300');
    
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
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    try
        disp(exception.stack(2))
        disp(exception.stack(3))
    end
end