function [MRI_order subj_name path_subj path_epip path_fsems ...
    Nepip ons dur dur_eff ons_delay HPF scans_to_remove] = load_BOLD_generic
%list of MRI experiments 
MRI_order = [1 2]; 
subj_name{1} = 1;
subj_name{2} = 2;
%file folders:
for su=1:length(MRI_order)
    cr = MRI_order(su); %current rat
    switch cr
        case 1
        path_subj{cr} = ['D:\Users\Philippe Pouliot\IRM_scans\Cong2301'];
        path_epip{cr} = 'epip01';
        path_fsems{cr} = 'fsems01';
        Nepip{cr} = 300; %number of
        ons{cr} = []; %onset times
        dur{cr} = 0; %actual duration of stimulus
        dur_eff{cr} = 0; %45; %effective duration of stimulus, used for the GLM
        ons_delay{cr} = 0; %2 seconds because of removal of first volume  
        scans_to_remove{cr} = 10;
        HPF{cr} = 480;
        case 2
        path_subj{cr} = ['D:\Users\Philippe Pouliot\IRM_scans\Cong2301'];
        path_epip{cr} = 'epip02';
        path_fsems{cr} = 'fsems01';
        Nepip{cr} = 300; %number of
        ons{cr} = []; %onset times
        dur{cr} = 0; %actual duration of stimulus
        dur_eff{cr} = 0; %45; %effective duration of stimulus, used for the GLM
        ons_delay{cr} = 0; %2 seconds because of removal of first volume        
        scans_to_remove{cr} = 10;
        HPF{cr} = 480;
    end
end