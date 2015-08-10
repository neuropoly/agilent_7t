function varargout = BOLD_GUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BOLD_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @BOLD_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before BOLD_GUI is made visible.
function BOLD_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for BOLD_GUI
handles.output = hObject;
handles.AllData.AnatLoaded = 0;
handles.AllData.BOLDLoaded = 0;
handles.AllData.TP = 1; %First time point
handles.AllData.Amode = 1; %BOLD mode by default
%Addpath
[pdir dummy] = fileparts(which('BOLD_GUI'));
% addpath(fullfile(pdir,'aedes'));
% addpath(fullfile(pdir,'spm'));
guidata(hObject, handles);

% UIWAIT makes BOLD_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure_BOLD_GUI);

% --- Outputs from this function are returned to the command line.
function varargout = BOLD_GUI_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadAnat_Callback(hObject, eventdata, handles)
switch handles.AllData.Amode
    case 1
        [dirAnatdicom sts] = spm_select(1,'dir','Select folder containing anatomical Dicoms','',pwd,'.dcm*');
        handles.AllData.dirAnatdicom = dirAnatdicom;
    case 2
        [fileAnatdicom sts] = spm_select(Inf,'any','Select all Dicom images','',pwd,'.dcm*');
        handles.AllData.fileAnatdicom = fileAnatdicom;
end
if sts
    handles = Anat_load_dicom(handles);
    handles.AllData.AnatLoaded = 1;
    handles.AllData.sA = round(handles.AllData.NsA/2);
    set(handles.SliceSlider,'SliderStep',[1/handles.AllData.NsA 1/handles.AllData.NsA]);
    set(handles.SliceSlider,'Min',1/handles.AllData.NsA);
    handles = update_slice(handles);
    handles = display_Anat(handles);
end
guidata(hObject, handles);

function loadAnat_fdf_Callback(hObject, eventdata, handles)
switch handles.AllData.Amode
    case 1
        [dirAnatfdf sts] = spm_select(1,'dir','Select folder containing anatomical fdf','',pwd,'.img*');
        handles.AllData.dirAnatfdf = dirAnatfdf;
    case 2
        [fileAnatfdf sts] = spm_select(Inf,'any','Select all fdf images','',pwd,'.img*');
        handles.AllData.fileAnatfdf = fileAnatfdf;
end
if sts
    handles = Anat_load_fdf(handles);
    handles.AllData.AnatLoaded = 1;
    handles.AllData.sA = round(handles.AllData.NsA/2);
    set(handles.SliceSlider,'SliderStep',[1/handles.AllData.NsA 1/handles.AllData.NsA]);
    set(handles.SliceSlider,'Min',1/handles.AllData.NsA);
    handles = update_slice(handles);
    handles = display_Anat(handles);
end
guidata(hObject, handles);

function LoadFID_Callback(hObject, eventdata, handles)
[dirBOLDfid sts] = spm_select(1,'dir','Select folder containing BOLD Fid','',pwd,'.fid*');
if sts %It takes about 45 seconds to load 1800 EPI slices of 64 x 64 pixels
    handles.AllData.dirBOLDfid = dirBOLDfid;
    handles = BOLD_load_fid(handles);
    handles.AllData.BOLDLoaded = 1;
    handles = BOLD_initialize(handles);
    guidata(hObject, handles);
end

function Loadfdf_Callback(hObject, eventdata, handles)
[dirBOLDfdf sts] = spm_select(1,'dir','Select folder containing BOLD fdf images','',pwd,'.img*');
if sts
    handles.AllData.dirBOLDfdf = dirBOLDfdf;
    handles = BOLD_load_fdf(handles); %48 seconds to read 330 volumes of 16 64x64 slices.
    handles.AllData.BOLDLoaded = 1;
    handles = BOLD_initialize(handles);
    guidata(hObject, handles);
end

function LoadNifti_Callback(hObject, eventdata, handles)
switch handles.AllData.Amode
    case 1
        [BOLDnii sts] = spm_select(1,'image','Select 4D BOLD Nifti','',pwd,'.nii*');
        handles.AllData.BOLDnii = BOLDnii;
        if sts %It takes about 10 seconds to load 1800 EPI slices of 64 x 64 pixels
            handles = BOLD_load_nii(handles);
            handles.AllData.BOLDLoaded = 1;
            handles = BOLD_initialize(handles);
        end
    case 2
        [fileDiffusiondicom sts] = spm_select(Inf,'any','Select all Dicom images','',pwd,'.dcm*');
        handles.AllData.fileDiffusiondicom = fileDiffusiondicom;
        if sts 
            handles = Diffusion_load_dicom(handles);
            handles.AllData.DiffusionLoaded = 1;
            handles = Diffusion_initialize(handles);
        end
end
guidata(hObject, handles);

function Reload_Callback(hObject, eventdata, handles)
handles = display_Anat(handles);
handles = show_BOLD_time_course(handles);
guidata(hObject, handles);

function GetROI_Callback(hObject, eventdata, handles)
h = impoly(handles.FigAnat);
position = wait(h);
mask=createMask(h);
handles.AllData.ROI.mask = mask;
handles.AllData.ROI.position = position;
handles.AllData.ROI.h = h;
handles = updateROI(handles);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Various sliders and edit boxes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SliceSlider_Callback(hObject, eventdata, handles)
handles.AllData.sA = round(handles.AllData.NsA*get(hObject,'Value'));
handles = update_slice(handles);
handles = update_all(handles);
guidata(hObject, handles);

function SliceSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function SliceNumber_Callback(hObject, eventdata, handles)
handles.AllData.sA = str2double(get(hObject,'String'));
handles = update_slice(handles);
handles = update_all(handles);
guidata(hObject, handles);

function SliceNumber_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SliderContrastMax_Callback(hObject, eventdata, handles)
handles.AllData.ContrastMax = get(hObject,'Value');
set(handles.ContrastMax,'string',int2str(round(100*handles.AllData.ContrastMax/handles.AllData.ContrastMax0)));
handles = update_all(handles);
guidata(hObject, handles);

function SliderContrastMax_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function ContrastMax_Callback(hObject, eventdata, handles) %Not used

function ContrastMax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Various filters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpatialFilter_Callback(hObject, eventdata, handles)
gaussian_width = str2double(get(handles.FilterWidth,'String'));
sigma = gaussian_width/2;
if sigma > 0
    F = fspecial('gaussian',[gaussian_width,gaussian_width],sigma);
    handles.AllData.F = F;
    handles.AllData.gaussian_width = gaussian_width;
else
    if isfield(handles.AllData,'F')
        handles.AllData = rmfield(handles.AllData,'F');
        handles.AllData = rmfield(handles.AllData,'gaussian_width');
    end
end
switch handles.AllData.Amode
    case 1
        handles = spatial_filter_BOLD(handles);
        handles = display_BOLD(handles);
    case 2
        handles = spatial_filter_Diffusion(handles);
        handles = display_Diffusion(handles);
end
guidata(hObject, handles);

function FilterWidth_Callback(hObject, eventdata, handles) %Not used

function FilterWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Positions - space and time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function VertPos_Callback(hObject, eventdata, handles) %Not used

function VertPos_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function HorzPos_Callback(hObject, eventdata, handles) %Not used

function HorzPos_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SliderTime_Callback(hObject, eventdata, handles)
switch handles.AllData.Amode
    case 1
        handles.AllData.TP = round(handles.AllData.Nt*get(hObject,'Value'));
        set(handles.TimePoint,'string',handles.AllData.TP);
        TR=handles.AllData.TR;
        set(handles.TimeTextUpdate,'string',handles.AllData.TP*TR); %Assume TR=2 for now
        handles = display_BOLD_quick(handles);
    case 2
        handles.AllData.TP = round(handles.AllData.Nd*get(hObject,'Value'));
        set(handles.TimePoint,'string',handles.AllData.TP);
        set(handles.TimeTextUpdate,'string',handles.AllData.TP); 
        handles = display_Diffusion_quick(handles);
end
guidata(hObject, handles);

function SliderTime_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function TimePoint_Callback(hObject, eventdata, handles)
handles.AllData.TP = get(hObject,'Value');
set(handles.SliderTime,'Value',handles.AllData.TP/handles.AllData.Nt);
TR = 1;
set(handles.TimeTextUpdate,'string',handles.AllData.TP*TR); %Assume TR=2 for now
handles = display_BOLD_quick(handles);
guidata(hObject, handles);

function TimePoint_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GLMbutton_Callback(hObject, eventdata, handles)
handles = do_glm(handles);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specification of stimulation protocol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StartFirstStim_Callback(hObject, eventdata, handles)

function StartFirstStim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DurationFirstStim_Callback(hObject, eventdata, handles)

function DurationFirstStim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Delay_Callback(hObject, eventdata, handles)

function Delay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RestBetweenStims_Callback(hObject, eventdata, handles)

function RestBetweenStims_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DurationOtherStims_Callback(hObject, eventdata, handles)

function DurationOtherStims_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NumberOfStims_Callback(hObject, eventdata, handles)

function NumberOfStims_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function displayGLM_Callback(hObject, eventdata, handles)
glm_display(handles);

function Threshold_Callback(hObject, eventdata, handles)

function Threshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diffusion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Amode_Callback(hObject, eventdata, handles)
%Toggle between BOLD and Diffusion data modes (Boolean called Amode)
handles.AllData.Amode = get(hObject,'Value');
%Amode = 1: BOLD mode
%Amode = 2: Diffusion mode
Amode_update_GUI(handles);
guidata(hObject, handles);

function Amode_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function procparButton_Callback(hObject, eventdata, handles)
[procparFile sts] = spm_select(1,'any','Select procpar file for the diffusion scan','',pwd,'procpar');
if sts
    %handles.AllData.procparFile = procparFile;
    procpar = aedes_readprocpar(procparFile);
    handles.AllData.procpar = procpar;
    handles = get_directions(handles);
    set(handles.textProcpar,'visible','on');
end
guidata(hObject, handles);

function SkipFirst_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Treatment of bad scans -- in GLM 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removeBadScans_Callback(hObject, eventdata, handles)

function selectBadScans_Callback(hObject, eventdata, handles)
handles = select_bad_scans(handles);
guidata(hObject, handles);

function doAveraging_Callback(hObject, eventdata, handles)
handles = doAveraging(handles);
guidata(hObject, handles);

function editStartOffset_Callback(hObject, eventdata, handles)

function editStartOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editBaselineDuration_Callback(hObject, eventdata, handles)

function editBaselineDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function callKroon_Callback(hObject, eventdata, handles)
handles = call_Kroon(handles);
guidata(hObject, handles);

function fc_button_Callback(hObject, eventdata, handles)
handles = call_functional_connectivity(handles);
guidata(hObject, handles);

function select_seed_button_Callback(hObject, eventdata, handles)
handles = call_select_seed(handles);
guidata(hObject, handles);

function selectConfounds_Callback(hObject, eventdata, handles)
handles = call_select_confounds(handles);
guidata(hObject, handles);
