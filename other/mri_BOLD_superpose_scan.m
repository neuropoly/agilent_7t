function mri_BOLD_superpose_scan
runEPI = 1;
asl = 1;
if asl 
    nImage = 4;
else
    nImage = 3;
end
[rat_MRI_order rat_name path_rat path_epip path_fsems ...
    Nepip ons dur dur_eff ons_delay] = load_hypercapnia_rat_dat(runEPI);
subj = 1:18; %[9 11:20]; %4:19; %13; %[14:19]; %[7:12]; %
pathA = 'W:\Hypercapnia\Analysis';
ct = 0;
ns = length(subj);
all_old_rats = 0;
young_rats = 13:18;
young_rats = 24;
if all_old_rats
    old_rats = 1:12;
    old_rats = [1:10 12];
else
    old_rats = [1:3 5 7 10 12];
    %old_rats_bad = [4 6 8 9 11]; %11: HC12: really no response; HC7: also
    %very noisy; HC9, HC10: noisy, not clear if there is a response
    %old_rats_good = [1:3 5 7 10 12];
    
    %old_rats = [1:8 10 12]
end
if runEPI == 2
    old_rats = 1:9;
    young_rats = 10:15;
    subj = 4:18;
end
for su = subj
    ct = ct + 1;
    cr = rat_MRI_order(su); %current rat
    path0 = path_rat{cr};
    scan = path_epip{cr};
    N = Nepip{cr};
    %Get basic info from the EPIP files
    if ct == 1
        fname0 = fullfile(path0,[scan '.dcm'],['slice001image' gen_num_str(1,nImage) 'echo001.dcm']);
        Y0 = dicomread(fname0);
        V0 = dicominfo(fname0);
        [nx ny] = size(Y0);
        Nslice = V0.ImagesInAcquisition;
        D = zeros(ns,nx,ny,Nslice,N);
    end
    %fill D
    for iN = 1:N
        for iSlice = 1:Nslice
            fname = fullfile(path0,[scan '.dcm'],['slice' gen_num_str(iSlice,3) ...
                'image' gen_num_str(iN,nImage) 'echo001.dcm']);
            Y = dicomread(fname);
            D(ct,:,:,iSlice,iN) = double(Y);
        end
    end
end
%look at center
Slice = 6;
dSlice = 2;
cX = 32;
cY = 32;
dX = 6;
dY = 6;
lpX = cX-dX:cX+dX;
lpY = cY-dY:cY+dY;
lpZ = Slice-dSlice:Slice+dSlice;
E = D(:,lpX,lpY,lpZ,:);
F = mean(mean(mean(E,4),3),2);
F = squeeze(F);
figure; imagesc(F)
figure; plot(F')
figure; plot(F(10:15,:)')
%Load anatomical data
ct = 0;
ns = length(subj);
for su = subj
    ct = ct + 1;
    cr = rat_MRI_order(su); %current rat
    path0 = path_rat{cr};
    fsems_scan = path_fsems{cr};
    %Get basic info from the EPIP files
    if ct == 1
        fname0 = fullfile(path0,[fsems_scan '.dcm'],['slice001image' gen_num_str(1,3) 'echo001.dcm']);
        Y0 = dicomread(fname0);
        V0 = dicominfo(fname0);
        [nxA nyA] = size(Y0);
        Nslice = V0.ImagesInAcquisition;
        A = zeros(ns,nxA,nyA,Nslice);
    end
    %fill A
    for iSlice = 1:Nslice
        fname = fullfile(path0,[fsems_scan '.dcm'],['slice' gen_num_str(iSlice,3) ...
            'image001echo001.dcm']);
        Y = dicomread(fname);
        A(ct,:,:,iSlice) = double(Y);
    end
end
%12 plots
figure; rat = 14; for i=1:Nslice
    subplot(3,4,i);
    imagesc(squeeze(A(rat,:,:,i)));
    colormap(gray)
end;
figure; imagesc(squeeze(A(13,:,:,12)),[0 1.5e4]); colormap(gray)

%extraction specific to each rat
coord = mri_BOLD_get_each_rat_coordinates;
coord_choice = 1;
switch coord_choice
    case 1
        ratc = coord.rcgcc;
        %Choice for rcgcc
        dX = 2; %4;
        dY = 3; %6;
        dZneg = 2; %4;
        dZpos = -1; %0;        
    case 2
        ratc = coord.rlssc;
        dX = 1; %4;
        dY = 1; %6;
        dZneg = 1; %4;
        dZpos = 1; %0;
        
    case 3
        ratc = coord.rrssc;
        dX = 1; %4;
        dY = 1; %6;
        dZneg = 1; %4;
        dZpos = 1; %0;
end


ct = 0;
ns = length(subj);
Fs = zeros(ns,N);
for su = subj
    ct = ct + 1;
    cr = rat_MRI_order(su);
    cc = ratc{cr}; %current coordinates
    lpX = cc(1)-dX:cc(1)+dX;
    lpY = cc(2)-dY:cc(2)+dY;
    lpZ = cc(3)-dZneg:cc(3)+dZpos;
    tE = D(ct,lpX,lpY,lpZ,:); %or D
    tFs = mean(mean(mean(tE,4),3),2);
    Fs(ct,:) = squeeze(tFs);
end
if runEPI == 1
%Fix some jumps in Fs manually
rat = 7; k = 117; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 7; k = 230; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 7; k = 237; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 13; k = 313; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 13; k = 291; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 13; k = 140; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
%rat HC15: the worst
rat = 14; k = 217; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 14; k = 182; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 14; k = 293; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 15; k = 69; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 16; k = 11; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 16; k = 109; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 16; k = 177; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 17; k = 295; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 17; k = 172; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 17; k = 78; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 17; k = 54; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 18; k = 61; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 18; k = 78; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 18; k = 120; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
rat = 18; k = 251; Fs(rat,k) = (Fs(rat,k-1)+Fs(rat,k+1))/2;
else
    
end


if N == 330
    lp = linspace(0,330/30,330);
else
    lp = linspace(0,195/15,195);
end
%figure; imagesc(Fs)
%figure; plot(lp,Fs'); xlabel('time (minutes)');
figure; plot(lp,Fs(young_rats,:)'); xlabel('time (minutes)');
figure; plot(lp,Fs(old_rats,:)'); xlabel('time (minutes)');
%correlation
YOcor = corr(Fs');
%means
OF = mean(Fs(old_rats,:),1);
YF = mean(Fs(young_rats,:),1);
figure; plot(lp,YF,'b'); hold on; plot(lp,OF,'r'); xlabel('time (minutes)'); legend('Young','Old');
%normalize by baseline over first 60 seconds
Fb = Fs./repmat(mean(Fs(:,1:30),2),[1 N]);
OFb = mean(Fb(old_rats,:),1);
YFb = mean(Fb(young_rats,:),1);
figure; plot(lp,YFb,'b'); hold on; plot(lp,OFb,'r'); xlabel('time (minutes)'); legend('Young','Old');
%add standard deviations
nO = length(old_rats);
nY = length(young_rats);
OFs = std(Fb(old_rats,:),[],1)/nO^0.5;
YFs = std(Fb(young_rats,:),[],1)/nY^0.5;
figure; errorbar(lp,YFb,YFs,'b'); hold on; errorbar(lp,OFb,OFs,'r'); xlabel('time (minutes)'); legend('Young','Old');
%add low pass filtering
if N == 330, fs = 0.5; else fs = 0.25; end
Ff = ButterLPF(fs,0.1,4,Fb')';
OFf = mean(Ff(old_rats,:),1);
YFf = mean(Ff(young_rats,:),1);
figure; plot(lp,YFf,'b'); hold on; plot(lp,OFf,'r'); xlabel('time (minutes)'); legend('Young','Old');
OFsf = std(Ff(old_rats,:),[],1)/nO^0.5;
YFsf = std(Ff(young_rats,:),[],1)/nY^0.5;
figure; errorbar(lp,YFf,YFsf,'b'); hold on; errorbar(lp,OFf,OFsf,'r'); xlabel('time (minutes)'); legend('Young','Old');
%add high pass filtering
Fh = ButterHPF(fs,1/240,2,Ff')';
OFh = mean(Fh(old_rats,:),1);
YFh = mean(Fh(young_rats,:),1);
figure; plot(lp,YFh,'b'); hold on; plot(lp,OFh,'r'); xlabel('time (minutes)'); legend('Young','Old');
OFsh = std(Fh(old_rats,:),[],1)/nO^0.5;
YFsh = std(Fh(young_rats,:),[],1)/nY^0.5;
figure; errorbar(lp,YFh,YFsh,'b'); hold on; errorbar(lp,OFh,OFsh,'r'); xlabel('time (minutes)'); legend('Young','Old');
%best responding rats

Fh = ButterHPF(fs,1/240,2,Ff')';
OFhg = mean(Fh(old_rats_good,:),1);
OFhb = mean(Fh(old_rats_bad,:),1);
YFh = mean(Fh(young_rats,:),1);
figure; plot(lp,YFh,'k'); hold on; plot(lp,OFhg,'b'); plot(lp,OFhb,'r'); xlabel('time (minutes)'); legend('Young','Old - cognitively normal','Old - cognitively impaired');
OFshg = std(Fh(old_rats,:),[],1)/length(old_rats_good)^0.5;
OFshb = std(Fh(old_rats,:),[],1)/length(old_rats_bad)^0.5;
YFsh = std(Fh(young_rats,:),[],1)/nY^0.5;
%figure; errorbar(lp,YFh,YFsh,'k'); hold on; errorbar(lp,OFhg,OFshg,'b'); errorbar(lp,OFhb,OFshb,'r'); xlabel('time (minutes)'); legend('Young','Old - cognitively normal','Old - cognitively impaired');
figure; errorbar(lp(5:3:end),YFh(5:3:end),YFsh(5:3:end),'k'); hold on; errorbar(lp(6:3:end),OFhg(6:3:end),OFshg(6:3:end),'b'); errorbar(lp(7:3:end),OFhb(7:3:end),OFshb(7:3:end),'r'); xlabel('time (minutes)'); legend('Young','Old - cognitively normal','Old - cognitively impaired');
figure; errorbar(lp(5:6:end),YFh(5:6:end),YFsh(5:6:end),'k'); hold on; errorbar(lp(6:6:end),OFhg(6:6:end),OFshg(6:6:end),'b'); errorbar(lp(7:6:end),OFhb(7:6:end),OFshb(7:6:end),'r'); xlabel('time (minutes)'); legend('Young','Old - cognitively normal','Old - cognitively impaired');

%
figure; set(gca,'FontSize',14); errorbar(lp(5:6:end),100*YFh(5:6:end),100*YFsh(5:6:end),'k'); hold on; 
errorbar(lp(6:6:end),100*OFhg(6:6:end),100*OFshg(6:6:end),'b'); 
errorbar(lp(7:6:end),100*OFhb(7:6:end),100*OFshb(7:6:end),'r'); 
xlabel('Time (minutes)'); ylabel('BOLD (% change)'); legend('Young','Old - good response','Old - poor response');
plot([(46:60)/30 (60+(46:60))/30 (120+(46:60))/30  (180+(46:60))/30 (240+(46:60))/30],2.25,'k-s','LineWidth',2)
xlim([0 11]);
xlhand = get(gca,'xlabel');
set(xlhand,'string','X','fontsize',14); xlabel('time (minutes)'); 
ylhand = get(gca,'ylabel');
set(ylhand,'string','X','fontsize',14); ylabel('BOLD (% change)'); 

%Average over the 5 stimulations, from 90 s, for 90 s. -- this is only good
%for protocol 1 (epip_01)
Fhr = [Fh(:,46:end) zeros(ns,15)]; %restricted to the start of the first stimulation, adding 30 seconds of zeros to complete last stimulation block
Fhr = reshape(Fhr,[ns 60 5]);
%plot all the curves
figure; lpA = linspace(0,120,60);
for i=1:ns
    subplot(3,6,i);
    plot(lpA,squeeze(Fhr(i,:,:))); xlim([0 120]);
end
%Mean curves
figure; lpA = linspace(0,120,60);
for i=1:ns
    subplot(3,6,i);
    m1 = [mean(squeeze(Fhr(i,1:45,:)),2); mean(squeeze(Fhr(i,46:60,1:4)),2)];
    m1a(i,:) = m1;
    s1 = [std(squeeze(Fhr(i,1:45,:)),[],2); std(squeeze(Fhr(i,46:60,1:4)),[],2)];
    s1a(i,:) = s1;
    errorbar(lpA,m1,s1); xlim([0 120]);
end
%Average over animals
Om = mean(m1a(old_rats,:),1);
Ym = mean(m1a(young_rats,:),1);
figure; plot(lpA,100*Ym,'b'); hold on; plot(lpA,100*Om,'r'); xlabel('time (seconds)'); legend('Young','Old');
Os = std(s1a(old_rats,:),[],1)/nO^0.5;
Ys = std(s1a(young_rats,:),[],1)/nY^0.5;
figure; errorbar(lpA,100*Ym,100*Ys,'b'); hold on; errorbar(lpA,100*Om,100*Os,'r'); xlabel('time (seconds)'); legend('Young','Old');
xlim([0 120])
%respiration
for su = subj
    cr = rat_MRI_order(su); %current rat
    nameID = [gen_num_str(cr,2) '_' gen_num_str(rat_name{cr},2)];
    resp{su} = mri_load_rat_physiology_respirationOnly('W:\Hypercapnia\Respiration',['HC' nameID]);
end
%remove baseline of 30 seconds; starting after 1 minute
Fhb = Fh(:,31:end); 
Fhb = reshape(Fhb,[ns 60 5]);
FhB = squeeze(mean(Fhb(:,1:15,:),2));
FhrB = Fhr - reshape(repmat(FhB,[1 60 1]),[ns 60 5]);
%Mean curves again
figure; lpA = linspace(0,120,60);
for i=1:ns
    subplot(3,6,i);
    m2 = [mean(squeeze(FhrB(i,1:45,:)),2); mean(squeeze(FhrB(i,46:60,1:4)),2)];
    m2a(i,:) = m2;
    s2 = [std(squeeze(FhrB(i,1:45,:)),[],2); std(squeeze(FhrB(i,46:60,1:4)),[],2)];
    s2a(i,:) = s2;
    errorbar(lpA,m2,s2); xlim([0 120]);
end

Om2 = mean(m2a(old_rats,:),1);
Ym2 = mean(m2a(young_rats,:),1);
figure; set(gca,'FontSize',14); plot(lpA,100*Ym2,'b'); hold on; plot(lpA,100*Om2,'r'); xlabel('time (seconds)'); legend('Young','Old');
Os2 = std(s2a(old_rats,:),[],1)/nO^0.5;
Ys2 = std(s2a(young_rats,:),[],1)/nY^0.5;
figure; errorbar(lpA,100*Ym2,100*Ys2,'b'); hold on; errorbar(lpA,100*Om2,100*Os2,'r');  legend('Young','Old');
xlim([0 120]); hold on; set(gca,'FontSize',14)
xlhand = get(gca,'xlabel');
set(xlhand,'string','X','fontsize',14); xlabel('time (seconds)'); 

%figures for respiration
ct = 0;
for su = subj
    ct = ct + 1;
    if ct == 1
        fs = resp{su}.fs;
        R = zeros(ns,fs*N);
        Rsc = zeros(ns,fs*N);
    end
    %ct
    delay = resp{su}.delay; %rat 14: very long delay, of 281 s
    R(ct,:) = resp{su}.rri(round(delay*fs):(round(delay*fs) + N*fs-1)); 
    Rsc(ct,:) = resp{su}.rri(round(delay*fs):(round(delay*fs) + N*fs-1)) + 100 *(ct-1); 
end
if N == 330
    lpP = linspace(0,330/30,330*fs);
else
    lpP = linspace(0,195/15,195*fs);
end
figure; plot(lpP,R(13:17,:)'); xlabel('time (minutes)');
figure; plot(lpP,R(old_rats,:)'); xlabel('time (minutes)');
%LPF
Rf = ButterLPF(fs,0.1,2,R')';
figure; plot(lpP,Rf(13:17,:)'); xlabel('time (minutes)');
figure; plot(lpP,Rf(old_rats,:)'); xlabel('time (minutes)');

figure; plot(lpP,Rsc(13:17,:)'); xlabel('time (minutes)');
figure; plot(lpP,Rsc(old_rats,:)'); xlabel('time (minutes)');
