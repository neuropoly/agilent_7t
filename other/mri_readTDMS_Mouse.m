function mri_readTDMS_Mouse %Rabbits too
%read TDMS
try
    [t sts] = spm_select(1,'any','Select TDMS file','',pwd);
    if sts
        addpath(genpath(fullfile(spm('dir'),'toolbox','mri12','v2p5')));
        %T = TDMS_getStruct('W:\RabbitMRI\RabbitOx101\Logged Data_2013_03_27_11_50_22.tdms'); %RabbitOx1
        T = TDMS_getStruct(t);
        Nc = 8;
        fs = 2000;
        N = length(T.Untitled.Dev1_ai0.data);
        D = zeros(N,Nc);
        tp = 1:N;
        for i=1:Nc
            D(tp,i) = T.Untitled.(['Dev1_ai' int2str(i-1)]).data;
        end
        lp = linspace(0,N/fs,N);
%         figure; plot(lp,D(tp,2)); legend('ECG');
%         figure; plot(lp,D(tp,6)); legend('ECGG');
%         figure; plot(lp,D(tp,7)); legend('AuxIn');
        figure; plot(lp,D(tp,[3 7])); legend('Stim','AuxIn');
        figure; plot(lp,D(tp,[1 3:5 7 8]))
        legend('Resp','Stim','Oxym','RespG','AuxIn','OxymG');
        figure; plot(lp,D(tp,[1 5]))
        legend('Resp','RespG');
        figure; plot(lp,D(tp,[4 8]))
        legend('Oxym','OxymG');
        
        figure; plot(lp,D(tp,[6 8]))
        legend('ECGG','OxymG');
        figure; plot(lp,D(tp,[2 6]))
        legend('ECG','ECGG');
        figure; plot(lp,D(tp,[2 4]))
        legend('ECG','Oxym');
        figure; plot(lp,D(tp,[2 4 6 8 1 5]))
        legend('ECG','Oxym','ECGG','OxymG','Resp','RespG');
        %mouse P33: no acquisition between 715 and 920 s
        %tp = fs*715:(fs*915-1); %400000 points
        %lp = linspace(0,400000/fs,400000);
        %RabbitOx3
        tp = fs*2010:(fs*2155-1); %400000 points
        lp = linspace(0,290000/fs,290000);
        a=1;
        %Physiology analysis
        D0 = D;
        D = D0(tp,:);
        OP.fs = fs;
        OP.lp = lp;
        
        OP.th = 4; %threshold in Volts
        OP.gap = 2;
        OP.Resp = 1;
        OP.ECG = 2;
        OP.Ox = 4;
        OP.ECGG = 6; %ECG gate index
        OP.RespG = 5; %Resp gate index
        OP.OxG = 8; %Pulse ox gate index
        OP.ch = [OP.Resp OP.ECG OP.Ox]; %channels
        OP.gch = [OP.RespG OP.ECGG OP.OxG]; %gate channels
        OP.med_up = 0.1;
        OP.med_dn = 0.1;
        OP.thg_max = [4 4 4];
        OP.thg_min = [1 1 -0.5];
        OP.stm_l = 0.5;
        OP.offsets = [2.5 2.5 1]; %DC offsets to remove for channels in OP.ch 
        OP.win0_frac = 0.66;
        mri_physio_analyze(D,OP);
    end
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    try
        disp(exception.stack(2))
        disp(exception.stack(3))
    end
end
% %Plot AuxIn
% figure; plot(lp,D(tp,1)); legend('Resp');
% figure; plot(lp,D(tp,2)); legend('ECG');
% figure; plot(lp,D(tp,3)); legend('Stim');
% figure; plot(lp,D(tp,4)); legend('Oxym');
% figure; plot(lp,D(tp,5)); legend('RespG');
% figure; plot(lp,D(tp,6)); legend('ECGG');
% figure; plot(lp,D(tp,7)); legend('AuxIn');
% figure; plot(lp,D(tp,8)); legend('OxymG');
% figure; plot(lp,D(tp,[2 4 6 8])); legend('ECG','Oxym','ECGG','OxymG');

