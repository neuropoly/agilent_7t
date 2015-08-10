function mri_readTDMS_Rabbit
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
        figure; plot(lp,D(tp,6)); legend('ECGG');
        figure; plot(lp,D(tp,7)); legend('AuxIn');
        figure; plot(lp,D(tp,[3 7])); legend('Stim','AuxIn');
        figure; plot(lp,D(tp,[1 3:5 7 8]))
        legend('Resp','Stim','Oxym','RespG','AuxIn','OxymG');
        figure; plot(lp,D(tp,[1 5]))
        legend('Resp','RespG');
        figure; plot(lp,D(tp,[4 8]))
        legend('Oxym','OxymG');
        a=1;
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

