function varargout = CNR_SNR_GUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CNR_SNR_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CNR_SNR_GUI_OutputFcn, ...
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

% --- Executes just before CNR_SNR_GUI is made visible.
function CNR_SNR_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.AllData = [];
%Addpath
[pdir dummy] = fileparts(which('CNR_SNR_GUI'));
%addpath(fullfile(pdir,'spm'));
guidata(hObject, handles);

% UIWAIT makes CNR_SNR_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% --- Outputs from this function are returned to the command line.
function varargout = CNR_SNR_GUI_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

function LoadDicom_Callback(hObject, eventdata, handles)
if isfield(handles.AllData,'dirDicom')
    cdir = handles.AllData.dirDicom;
else
    cdir = pwd;
end
[fimage sts] = spm_select(1,'any','Select one dicom image','',cdir,'.dcm*');
if sts
    handles.AllData.fimage = fimage;
    [cdir dummy] = fileparts(fimage);
    handles.AllData.dirDicom = cdir;
    handles = load_dicom(handles);
    handles = display_dicom(handles);
end
guidata(hObject, handles);

% --- Executes on button press in LoadFdf.
function LoadFdf_Callback(hObject, eventdata, handles)
if isfield(handles.AllData,'dirDicom')
    cdir = handles.AllData.dirDicom;
else
    cdir = pwd;
end
[fimage sts] = spm_select(1,'any','Select one fdf image','',cdir,'.fdf*');
if sts
    handles.AllData.fimage = fimage;
    [cdir dummy] = fileparts(fimage);
    handles.AllData.dirDicom = cdir;
    handles = load_fdf(handles);
    handles = display_fdf(handles);
end
guidata(hObject, handles);

function VertSize_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function VertSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function HorzSize_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function HorzSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BVertSize_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function BVertSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BHorzSize_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function BHorzSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editMainH_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function editMainH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editMainV_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function editMainV_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editNoiseH_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function editNoiseH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editNoiseV_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function editNoiseV_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editContrastH_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function editContrastH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editContrastV_Callback(hObject, eventdata, handles)
handles = calculate_SNR_CNR(handles);
guidata(hObject, handles);

function editContrastV_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
