function handles = call_DTI(handles)
try
    % Example of the DTI.m Diffusion Tension Imaging (DTI) function.
    % Adapted for the ATX11b scan
    % Make a struct to store all DTI data
    DTIdata=struct();
    
    %  The test data used is from the opensource QT Fiber-Tracking, NLM insight registration & Segmentation Toolkit)
    
    % Magnetic Gradients of data volumes
    % Jones30
    dro = handles.AllData.directions.dro;
    dpe = handles.AllData.directions.dpe;
    dsl = handles.AllData.directions.dsl;
    
    H=[[0 0 0];[dro' dpe' dsl']];
    
    D = handles.AllData.D;
    [Nx Ny Nd Ns] = size(D);
    %  Read the MRI (DTI) voxeldata volumes
    for i=1:Nd,
        DTIdata(i).VoxelData = squeeze(D(:,:,i,:));
        DTIdata(i).Gradient = H(i,:);
        DTIdata(i).Bvalue=1000;
    end
    
    % Constants DTI
    parametersDTI=[];
    parametersDTI.BackgroundTreshold=150;
    parametersDTI.WhiteMatterExtractionThreshold=0.10;
    parametersDTI.textdisplay=true;
    
    % Perform DTI calculation
    [ADC,FA,VectorF,DifT]=DTI(DTIdata,parametersDTI);
    %get root directory
    %image1 = handles.AllData.fileAnatfdf(1,:);
    image1 = handles.AllData.dicomlist{1};
    [dir0 fil0] = fileparts(image1);
    %[dir1 fil1] = fileparts(dir0);
    dirDiff = fullfile(dir0,'Diffusion');
    if ~exist(dirDiff,'dir'), mkdir(dirDiff); end
    fname = fullfile(dirDiff,'Diff_');
    %s0 = round(Ns/2)-1; %slice to show
    ADC = abs(ADC);
    FA = abs(FA);
    VectorF = abs(VectorF);
    DifT = abs(DifT);
    for s0=1:Ns
        minD = min(abs(DifT(:)));
        maxD = max(abs(DifT(:)));
        DifT_offdiag = DifT(:,:,:,2);
        minDoffdiag = min(abs(DifT_offdiag(:)));
        maxDoffdiag = max(abs(DifT_offdiag(:)));
        use_off_diag_minmax = 1;
        if use_off_diag_minmax
            minD2 = minDoffdiag;
            maxD2 = maxDoffdiag;
        else
            minD2 = minD;
            maxD2 = maxD;
        end
        % Show the DiffusionTensor
        h = figure('units','normalized','outerposition',[0 0 1 1]);
        subplot(3,3,1), imshow(squeeze(DifT(:,:,s0,1)),[minD maxD]); title('Dxx');
        subplot(3,3,5), imshow(squeeze(DifT(:,:,s0,4)),[minD maxD]); title('Dyy');
        subplot(3,3,9), imshow(squeeze(DifT(:,:,s0,6)),[minD maxD]); title('Dzz');
        subplot(3,3,8), title(['Slice ' int2str(s0)]); axis off
        subplot(3,3,4), title('Note: Dxy, Dxz, Dyz scaled up for display'); axis off
        subplot(3,3,2), imshow(squeeze(DifT(:,:,s0,2)),[minD2 maxD2]); title('Dxy');
        subplot(3,3,3), imshow(squeeze(DifT(:,:,s0,3)),[minD2 maxD2]); title('Dxz');
        subplot(3,3,6), imshow(squeeze(DifT(:,:,s0,5)),[minD2 maxD2]); title('Dyz');
        subplot(3,3,7), imagesc(squeeze(ADC(:,:,s0))); title('ADC'); axis off; axis equal        
        print(h, '-dpng', [fname 'DT_ADC_Slice' gen_num_str(s0,2) '.png'], '-r300');
        close(h)
        % Show the Fractional Anistropy, overlayed with the anistropy vector field.
        resize = 6;
        h = figure('units','normalized','outerposition',[0 0 1 1]);
        imshow(imresize(FA(:,:,s0),resize),[]); hold on;
        VectorPlotZ=squeeze(VectorF(:,:,s0,1:2));
        [VectorPlotX,VectorPlotY]=meshgrid(1:size(VectorPlotZ,1),1:size(VectorPlotZ,2));
        quiver(VectorPlotX*resize,VectorPlotY*resize,VectorPlotZ(:,:,2),VectorPlotZ(:,:,1));
        title(['Fractional Anistropy, and Vector Field, slice ' int2str(s0)]);
        print(h, '-dpng', [fname 'FA_VF_Slice' gen_num_str(s0,2) '.png'], '-r300');
        close(h)               
        
        %     figure;
        %     imshow(squeeze(double(ADC(:,:,s0))));
        %     title(['Apparent diffusion coefficient, slice ' int2str(s0)]);
        %     % Save the resulting data for the FT_test.m script.
    end
    save(fullfile(dirDiff,'FT_data'),'FA','VectorF','ADC','DifT');
    
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end