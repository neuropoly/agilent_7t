function [rat_MRI_order rat_name path_rat path_epip path_fsems ...
    Nepip ons dur dur_eff ons_delay] = load_hypercapnia_rat_dat(runEPI,mainPath)

strEPI = int2str(runEPI);
%[rat_MRI_order rat_name path_rat path_epip path_fsems ...
%    TR Nepip Nsl ons dur dur_eff FOV mtx_size thk] = load_hypercapnia_rat_dat
%list of MRI experiments -- low numbers for old rats, high numbers for young rats
rat_MRI_order = [1 3:13 14:25 51 52]; %experiment 2 (rat 3) failed; use 50+rat number for young rats
rat_name{1} = 1;
rat_name{3} = 4;
rat_name{4} = 5;
rat_name{5} = 12;
rat_name{6} = 10;
rat_name{7} = 11;
rat_name{8} = 6;
rat_name{9} = 7;
rat_name{10} = 8;
rat_name{11} = 18;
rat_name{12} = 15;
rat_name{13} = 17;
rat_name{14} = 101;
rat_name{15} = 102;
rat_name{16} = 103;
rat_name{17} = 104;
rat_name{18} = 105;
rat_name{19} = 106;
rat_name{20} = 109;
rat_name{21} = 110;
rat_name{22} = 111;
rat_name{23} = 112;
rat_name{24} = 113;
rat_name{25} = 114;
rat_name{51} = 51;
rat_name{52} = 52;

%file folders:
for su=1:length(rat_MRI_order)
    cr = rat_MRI_order(su); %current rat    
    if cr < 50
        path_rat{cr} = [fullfile(mainPath,'HC') gen_num_str(cr,2) '_' gen_num_str(rat_name{cr},2) '01'];
        path_epip{cr} = ['epip0' strEPI];
        path_fsems{cr} = 'fsems_ratHC01';
        %TR{cr} = 2; %repetition time in seconds
        Nepip{cr} = 330; %number of
        %Nsl{cr} = 12; %number of slices, for epip and for fsems -- we assume that they match
        ons{cr} = [90 210 330 450 570]; %onset times
        dur{cr} = 30; %actual duration of stimulus
        dur_eff{cr} = 50; %45; %effective duration of stimulus, used for the GLM
        ons_delay{cr} = 2+13; %2 seconds because of removal of first volume
        %and 4 additional seconds for propagation delay of CO2 along the conduit
        %FOV{cr} = [32 32]; %in millimeters
        %mtx_size{cr} = [64 64]; %matrix size
        %thk{cr} = 1; %thickness, in millimeters
        switch cr 
            case 5
                dur{cr} = [30 30 60 30 30];
            dur_eff{cr} = [50 50 80 50 50];
                path_epip{cr} = ['epip_ratHC0' strEPI];
            case {6,7,14,15,16,17,18,19,20,21,22,23,24, 25}
                 path_epip{cr} = ['epip_ratHC0' strEPI];
%             case 25
%                  path_epip{cr} = ['asl0' strEPI];
%                  path_fsems{cr} = 'fsems_ratHC02';
%                  Nepip{cr} = 660;
                 
            otherwise
        end
    else
        switch cr
            case 51
                path_rat{cr} = 'W:\Hypercapnia\LE5HC02';
            case 52
                path_rat{cr} = 'W:\Hypercapnia\LE6HC01';
                path_epip{cr} = 'epip02';
                Nepip{cr} = 660;
                %Nsl{cr} = 9;
                %T = 660; %11 minutes approximately
                %TR{cr} = 1;
                %FOV{cr} = [25 25]; %field of view, in millimeters
            otherwise
                %generic young rat
        end
    end
    switch runEPI
        case 1
        case 2
            ons{cr} = [60 420];
            dur{cr} = [120 120];
            ons_delay{cr} = 2+13;
            dur_eff{cr} = [140 140];
            Nepip{cr} = 195;
    end
end