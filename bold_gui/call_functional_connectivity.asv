function handles = call_functional_connectivity(handles)
handles.AllData.fc_pValue = 0.001; %0.05;
%BOLD data
B = handles.AllData.B;
TR = handles.AllData.TR;
Nt = handles.AllData.Nt;
%lp = linspace(0,Nt*TR,Nt);
[Nx Ny Nt Nz] = size(B);

%Step 1: select seeds
if ~isfield(handles.AllData,'seeds')
    disp('Select seeds first by pressing the button!');
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 1a: Convert raw BOLD images to nifti format
    %Write nifti and realign and smooth unless it has been done before
    %Get path
    if isfield(handles.AllData,'dirBOLDdicom')
        [dirTmp dummy] = fileparts(handles.AllData.dirBOLDdicom);
    else
        if isfield(handles.AllData,'dirBOLDfdf')
            [dirTmp dummy] = fileparts(handles.AllData.dirBOLDfdf);
        end
    end
    dirBOLDfcnii = [dirTmp(1:end-4) 'fc.nii'];
    handles.AllData.dirBOLDfcnii = dirBOLDfcnii;
    %Write nifti
    B0 = handles.AllData.B0;
    write_nifti(B0,dirBOLDfcnii);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 1b: Realign and smooth the raw images
    %Realign and smooth
    realign_smooth(dirBOLDfcnii,handles); %Spatial filter -- now done through the smooth module
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 1c: remove regressors with GLM
    %Now regress out confound regressors
    handles.AllData.Regress_time = '0';
    handles.AllData.pathRegressRoot = dirTmp(1:end-4);
    handles.AllData.pathRegress = [dirTmp(1:end-4) '.regress'];
    if exist(handles.AllData.pathRegress,'dir') %avoid overwriting results
        strnow = datestr(now);
        strnow = strrep(strnow, ':', '_');
        handles.AllData.Regress_time = strnow;
        handles.AllData.pathRegressRoot = dirTmp(1:end-4);
        handles.AllData.pathRegress = [dirTmp(1:end-4) strnow '.regress'];
    end
    handles = glm_regress_fc(dirBOLDfcnii,handles);    
    
    R = handles.AllData.R;
    %Step 1e: interpolate and smooth(?) the residuals
    F = handles.AllData.F;   
    for j0=1:Nz
        for i0=1:Nt
            B1 = R(:,:,i0,j0);
            B1 = imresize(B1,2);
            B1 = imfilter(B1,F);
            B(:,:,i0,j0) = B1;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 1ef Define brain mask
    M0 = mean(B,3); %Time average
    M0max = max(M0(:));
    MaskThreshold = 0.1;
    brainMask = squeeze(M0>MaskThreshold*M0max);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 2: Extract ROI (seeds) time courses
    seeds = handles.AllData.seeds;
    Nseeds = length(seeds);
    handles.AllData.Nseeds = Nseeds;
    %Extract ROI time courses
    roi_radius = 2; %ROI radius in BOLD pixels
    %pos(1): x coordinate, horizontal, with 0 at left of figure
    %pos(2): y coordinate, vertical, with 0 at top of figure
    for s1=1:Nseeds
        tmp = zeros(1,Nt);
        ct = 0;
        for x0 = -roi_radius:roi_radius
            for y0 = -roi_radius:roi_radius
                if x0^2+y0^2 <= roi_radius^2
                    ct = ct + 1;
                    tmp = tmp+squeeze(B(round(seeds{s1}.pos(2))+x0,round(seeds{s1}.pos(1))+y0,:,seeds{s1}.slice))';
                end
            end
        end
        roi{s1}.roi_tc = tmp/ct;
        roi{s1}.name = seeds{s1}.name; %copy name
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 2: temporal bandpass filter
    fs = 1/TR;
    %downFreq = 1; %
    % Filter order
    filterOrder = 4;
    % Band-pass cut-off frequencies
    BPFfreq = [0.008 0.09];
    % Filter type
    fType = 'butter';
    % Passband/Stopband ripple in dB
    Rp_Rs = [.5 80];
    % Band-pass filter configuration
    [z, p, k] = temporalBPFconfig(fType, fs, BPFfreq, filterOrder, Rp_Rs);
    % Filtering & -- NOT DONE: Downsampling whole images (y)
    %Remove first volumes
    rem_vol = 10; %Remove first 10 volumes for system stability issue
    for s1=1:Nseeds
        roi{s1}.filt_roi = temporalBPFrun(roi{s1}.roi_tc, z, p, k);
        roi{s1}.filt_roi = roi{s1}.filt_roi(rem_vol+1:end);
    end
    y = B(:,:,rem_vol+1:end,:);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 4: functional connectivity
    for s1=1:Nseeds
        ROI = squeeze(roi{s1}.filt_roi);        
        % Preallocate
        corrMap = zeros([Nx Ny Nz]);
        pValueMap = ones([Nx Ny Nz]);        
        % Find Pearson's correlation coefficient
        for iX = 1:Nx
            for iY = 1:Ny
                for iZ = 1:Nz
                    if brainMask(iX,iY,iZ)
                        [corrMap(iX,iY,iZ) pValueMap(iX,iY,iZ)] = corr(ROI', squeeze(y(iX,iY,:,iZ)));
                    end
                end
            end
        end
        roi{s1}.corrMap = corrMap;
        roi{s1}.pValueMap = pValueMap;
    end
    handles.AllData.roi = roi;
    handles.AllData.current_seed = 1;
    handles.AllData.current_fc_slice = seeds{1}.slice;
    handles.AllData.roi_radius = roi_radius;
    %Display with a slider
    handles = display_connectivity(handles);
end




