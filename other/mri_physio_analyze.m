function mri_physio_analyze(D,OP)
lp = OP.lp; 
fs = OP.fs;
gch = OP.gch;
th = OP.th;
N = size(D,1);
lg = length(gch);
G = D(:,gch);
for g0=1:lg
    fG{g0} = 1+find(G(1:end-1,g0)<th & G(2:end,g0)>th); %find indices of gates exceeding threshold
    eG{g0} = 1+find(G(1:end-1,g0)>th & G(2:end,g0)<th); %end of ECG or pulse ox gates, beginning of resp gate 
    nD(g0) = length(fG{g0}); %number of detections for each gate
    dG{g0} = diff(fG{g0}); %intervals between gates, ignoring missed gates
    tm(g0) = median(dG{g0}); %approximate median interval in data points
    lG{g0} = find(dG{g0}>tm(g0)*(1+OP.med_up)); %long intervals, too high above median
    sG{g0} = find(dG{g0}<tm(g0)*(1-OP.med_dn)); %short intervals, too low below median    
    mG(g0) = min(dG{g0}); %min and max intervals, in data points
    MG(g0) = max(dG{g0});
end
if isempty(sG{OP.OxG == gch}) && isempty(lG{OP.OxG == gch})
    disp('Perfect pulse oxymeter gating!');
end
%histogram of pulse ox gates
figure; hist(dG{OP.OxG == gch}/fs); title('Histogram of intervals between pulseOx gates in ms, incl. respirations')
lG = dG{OP.OxG == gch}(dG{OP.OxG == gch}/fs<0.4)/fs;
mlG = mean(lG);
slG = std(lG);
%histogram of ECG gates, before repair
figure; hist(dG{OP.ECGG == gch}/fs); title('Histogram of intervals between ECG gates in ms')

co{1} = 'b'; co{2} = 'g'; co{3} = 'r'; co{4} = 'k';
figure; hold on
for g0=1:lg
    stem(fG{g0}/fs,ones(1,nD(g0)),co{g0}); title('Time course')
end
%Respirations
figure; hold on; g0 = OP.RespG == gch; stem(fG{g0}/fs,ones(1,nD(g0)),co{g0}); stem(eG{g0}/fs,ones(1,nD(g0)),co{4});
%title('Time course')

g0R = OP.RespG == gch;
if fG{g0R}(1) > eG{g0R}(1) %add a respiration gate as the first index
    fG{g0R} = [1; fG{g0R}];
end
%

%to exclude respirations
for g0 = [2 3]
     fR{g0} = []; %start gates during non-respiration periods
     dR{g0} = []; %intervals in data points following each gate
     for i0=1:nD(g0)
         for j0=1:nD(g0R)
            if fG{g0}(i0) <= eG{g0R}(j0) && fG{g0}(i0) > fG{g0R}(j0)
                 %keep it
                 fR{g0} = [fR{g0}; fG{g0}(i0)];
                 dR{g0} = [dR{g0}; dG{g0}(i0)];
            end
         end
     end
     tR(g0) = median(dR{g0});
     mR(g0) = min(dR{g0});
     MR(g0) = max(dR{g0});
     sR(g0) = std(dR{g0});
     nDR(g0) = length(dR{g0});
end
%histogram of pulse ox gates, during non-respiration
figure; hist(dR{OP.OxG == gch}/fs); title('Histogram of intervals between pulseOx gates in ms, ex. respirations')
%for rabbit:
lR = dR{OP.OxG == gch}(dR{OP.OxG == gch}/fs<0.4)/fs;
mlR = mean(lR);
slR = std(lR);

%Combine histograms
figure;
[h1, x1]=hist(dG{OP.OxG == gch}/fs);
[h2, x2]=hist(dR{OP.OxG == gch}/fs);
bar(x1, h1, 'r'); hold on; bar(x2, h2, 'b'); hold off;
h=findobj(gca, 'Type', 'patch');
set (h, 'FaceAlpha', 0.7);
%Repeat for ECG
figure;
[h1, x1]=hist(dG{OP.ECGG == gch}/fs);
[h2, x2]=hist(dR{OP.ECGG == gch}/fs);
bar(x1, h1, 'r'); hold on; bar(x2, h2, 'b'); hold off;
h=findobj(gca, 'Type', 'patch');
set (h, 'FaceAlpha', 0.7);

%Remove gate artefacts on respiration, ECG and Pulse Ox
ch = OP.ch;
C = D(:,ch);
C = C + G;
for g0=1:lg  
    for i0=1:N
        if i0 > 1
            if C(i0,g0) > OP.thg_max(g0) || C(i0,g0) < OP.thg_min(g0) 
                C(i0,g0) = C(i0-1,g0);
            end
        else
            if C(i0,g0) > OP.thg_max(g0) || C(i0,g0) < OP.thg_min(g0) 
                C(1,g0) = C(2,g0); %first point
            end
        end
    end
end
C = C - ones(N,1)*OP.offsets;

%Figure of Resp, ECG, Pulse Ox combined with their gates
figure; plot(lp,C); hold on
for g0=[2 3]
    stem(fG{g0}/fs,OP.stm_l*ones(1,nD(g0)),co{g0})
end
g0 = OP.RespG == gch; stem(fG{g0}/fs,OP.stm_l*ones(1,length(fG{g0})),co{g0}); stem(eG{g0}/fs,OP.stm_l*ones(1,nD(g0)),co{4});
legend('Resp','ECG','Pulse Ox')

%check on number of detections
if nD(OP.ECGG == gch) < nD(OP.OxG == gch)
    disp('Fewer ECG gates than pulse ox gates');
end

%Find minima of Pulse Ox and ECG occurring before the gates
for g0=[2 3]
    mI{g0} = []; %distance in data points from min signal to gate
    MI{g0} = []; %distance in data points from max signal to gate
    mS{g0} = []; %min signal
    MS{g0} = []; %max signal
    for i0=1:nD(g0)
        v0 = fG{g0}(i0);
        win = round(OP.win0_frac*tR(g0));
        if v0>win
            iv = (v0-win+1):v0;
            [min0 idx_min] = min(C(iv,g0));
            [max0 idx_max] = max(C(iv,g0));
            mI{g0} = [mI{g0}; win-idx_min];
            MI{g0} = [MI{g0}; win-idx_max];
            mS{g0} = [mS{g0}; min0];
            MS{g0} = [MS{g0}; max0];
        else
            disp(['Interval ' int2str(v0) ' skipped']);
        end
    end
    tmI(g0) = median(mI{g0});
    mmI(g0) = min(mI{g0});
    MmI(g0) = max(mI{g0});
    smI(g0) = std(mI{g0});
end

figure; hist(mI{OP.OxG == gch}/fs); title('Pulse Ox -- Min to Gate, incl. respirations'); xlabel('Interval in ms'); %Min to gate
figure; hist(MI{OP.OxG == gch}/fs); title('Pulse Ox -- Max to Gate, incl. respirations'); xlabel('Interval in ms'); %%Max to gate

figure; hist(mI{OP.ECGG == gch}/fs); title('ECG -- Min to Gate, incl. respirations'); xlabel('Interval in ms'); %%Min to gate
figure; hist(MI{OP.ECGG == gch}/fs); title('ECG -- Max to Gate, incl. respirations'); xlabel('Interval in ms'); %%Max to gate

%Repeat, excluding respirations
for g0=[2 3]
    mIR{g0} = []; %distance in data points from min signal to gate
    MIR{g0} = []; %distance in data points from max signal to gate
    mSR{g0} = []; %min signal
    MSR{g0} = []; %max signal
    for i0=1:nDR(g0)
        v0 = fR{g0}(i0);
        win = round(OP.win0_frac*tR(g0));
        if v0>win
            iv = (v0-win+1):v0;
            [min0 idx_min] = min(C(iv,g0));
            [max0 idx_max] = max(C(iv,g0));
            mIR{g0} = [mIR{g0}; win-idx_min];
            MIR{g0} = [MIR{g0}; win-idx_max];
            mSR{g0} = [mSR{g0}; min0];
            MSR{g0} = [MSR{g0}; max0];
        else
            disp(['Interval ' int2str(i0) ' skipped for g0 = ' int2str(g0)]);
        end
    end
end

figure; hist(mIR{OP.OxG == gch}/fs); title('Pulse Ox -- Min to Gate, ex. respirations'); xlabel('Interval in ms'); %Min to gate
figure; hist(MIR{OP.OxG == gch}/fs); title('Pulse Ox -- Max to Gate, ex. respirations'); xlabel('Interval in ms'); %Max to gate

figure; hist(mIR{OP.ECGG == gch}/fs); title('ECG -- Min to Gate, ex. respirations'); xlabel('Interval in ms'); %Min to gate
figure; hist(MIR{OP.ECGG == gch}/fs); title('ECG -- Max to Gate, ex. respirations'); xlabel('Interval in ms'); %Max to gate

