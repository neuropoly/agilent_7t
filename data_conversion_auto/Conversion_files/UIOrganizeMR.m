function varargout = UIOrganizeMR(varargin)
% UIORGANIZEMR MATLAB code for UIOrganizeMR.fig
%      UIORGANIZEMR, by itself, creates a new UIORGANIZEMR or raises the existing
%      singleton*.
%
%      H = UIORGANIZEMR returns the handle to a new UIORGANIZEMR or the handle to
%      the existing singleton*.
%
%      UIORGANIZEMR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UIORGANIZEMR.M with the given input arguments.
%
%      UIORGANIZEMR('Property','Value',...) creates a new UIORGANIZEMR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UIOrganizeMR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UIOrganizeMR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UIOrganizeMR

% Last Modified by GUIDE v2.5 27-Oct-2017 14:21:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UIOrganizeMR_OpeningFcn, ...
                   'gui_OutputFcn',  @UIOrganizeMR_OutputFcn, ...
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


% --- Executes just before UIOrganizeMR is made visible.
function UIOrganizeMR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UIOrganizeMR (see VARARGIN)

handles.SourceDirectory = '';
handles.DestinationDirectory = '';
handles.DataStructureFile = '';
handles.ProjectID = '';
handles.SpecimenType = '';
handles.Region = '';
handles.StudyDate = '';

% Choose default command line output for UIOrganizeMR
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UIOrganizeMR wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UIOrganizeMR_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function EditTextSourceFolder_Callback(hObject, eventdata, handles)
% hObject    handle to EditTextSourceFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTextSourceFolder as text
%        str2double(get(hObject,'String')) returns contents of EditTextSourceFolder as a double
data = guidata(hObject);

guidata(hObject, data);

% --- Executes during object creation, after setting all properties.
function EditTextSourceFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTextSourceFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditTextDestinationFolder_Callback(hObject, eventdata, handles)
% hObject    handle to EditTextDestinationFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTextDestinationFolder as text
%        str2double(get(hObject,'String')) returns contents of EditTextDestinationFolder as a double


% --- Executes during object creation, after setting all properties.
function EditTextDestinationFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTextDestinationFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ------------------------------------------------------------------------
% --- Executes on button press in SourceBrowse.
function SourceBrowse_Callback(hObject, eventdata, handles)
SrcDir = uigetdir;
data = guidata(hObject);
data.SourceDirectory = SrcDir;
guidata(hObject, data);

% also set the folder name in the display box
h = findobj('Tag', 'EditTextSourceFolder');
h.String = data.SourceDirectory;

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over SourceBrowse.
function SourceBrowse_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SourceBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DestinationBrowse.
function DestinationBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to DestinationBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DestDir = uigetdir;
data = guidata(hObject);
data.DestinationDirectory = DestDir;
guidata(hObject, data);
% also set the folder name in the display box
h = findobj('Tag', 'EditTextDestinationFolder');
h.String = data.DestinationDirectory ;


function EditTextDataStructureFile_Callback(hObject, eventdata, handles)
% hObject    handle to EditTextDataStructureFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTextDataStructureFile as text
%        str2double(get(hObject,'String')) returns contents of EditTextDataStructureFile as a double


% --- Executes during object creation, after setting all properties.
function EditTextDataStructureFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTextDataStructureFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DataStructureFileBrowse.
function DataStructureFileBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to DataStructureFileBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DataStructFile = uigetdir;
data = guidata(hObject);
data.DataStructureFile = DataStructFile;
guidata(hObject, data);
% also set the folder name in the display box
h = findobj('Tag', 'EditTextDataStructureFile');
h.String = data.DataStructureFile ;


% --- Executes on button press in OrganizeButton.
function OrganizeButton_Callback(hObject, eventdata, handles)
data = guidata(hObject);

% Hard coding copytype for now
copytype = {...
    'qMT',{...
        'SIRFSE',{'keyword','*sirfse*'   ,'param',{'ti'}},...
        'SPGR',{'keyword','qMT_*'      ,'param',{'mtfrq','flipmt/mtflip','tr','te'}},...
        },...
    'fieldsmap',{...
        'B0',{'keyword','b0_mapping*','param',{'te/te1','te2'}},...
        'B1',{'keyword','*b1map_MFA*','param',{'flip1/flipangle'}}...
        },...
	'T1', {...
        'keyword','*t1map*'    ,'param',{'ti'}},...
        'ProtonDensity',          {'keyword','*MTV*'      ,'param',{'flip1/flipangle','tr','te'}},...
        'T2',          {'keyword','*MWF*'      ,'param',{'flip1/flipangle','tr','te','ne/nechos','nt/averages'}},...
        };

% create top level folder structure
TopProj = data.DestinationDirectory;
if ~isempty(data.ProjectID)    
    mkdir(TopProj, data.ProjectID);
    TopProj = [data.DestinationDirectory '/' data.ProjectID];
end
if ~isempty(data.SpecimenType) 
    mkdir(TopProj, data.SpecimenType);
    TopProj = [TopProj '/' data.SpecimenType];
end
if ~isempty(data.Region) 
    mkdir(TopProj, data.Region);
    TopProj = [TopProj '/' data.Region];
end
if ~isempty(data.StudyDate) 
    mkdir(TopProj, data.StudyDate);
    TopProj = [TopProj '/' data.StudyDate];
end

organizeqmr(copytype, data.SourceDirectory, TopProj);
guidata(hObject, data);



function EditProjectName_Callback(hObject, eventdata, handles)
data = guidata(hObject);
data.ProjectID = get(hObject,'String');
guidata(hObject, data);
UpdateFolderStructure(hObject);

% --- Executes during object creation, after setting all properties.
function EditProjectName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditProjectName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditSpecimenType_Callback(hObject, eventdata, handles)
data = guidata(hObject);
data.SpecimenType = get(hObject,'String');
guidata(hObject, data);
UpdateFolderStructure(hObject);

% --- Executes during object creation, after setting all properties.
function EditSpecimenType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSpecimenType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditStudyDate_Callback(hObject, eventdata, handles)
    data = guidata(hObject);
    data.StudyDate = get(hObject,'String');
    guidata(hObject, data);
    UpdateFolderStructure(hObject);


% --- Executes during object creation, after setting all properties.
function EditStudyDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditStudyDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditRegionAnalyzed_Callback(hObject, eventdata, handles)
data = guidata(hObject);
data.Region = get(hObject,'String');
guidata(hObject, data);
UpdateFolderStructure(hObject);

% --- Executes during object creation, after setting all properties.
function EditRegionAnalyzed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditRegionAnalyzed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function UpdateFolderStructure(hObject)
data = guidata(hObject);
h = findobj('Tag', 'FolderStructureDisplay');

TopProj = data.DestinationDirectory;
if ~isempty(data.ProjectID)    
    TopProj = [data.DestinationDirectory '/' data.ProjectID];
end
if ~isempty(data.SpecimenType) 
    TopProj = [TopProj '/' data.SpecimenType];
end
if ~isempty(data.Region) 
    TopProj = [TopProj '/' data.Region];
end
if ~isempty(data.StudyDate) 
    TopProj = [TopProj '/' data.StudyDate];
end
h.String = ['Folder Structure: ' TopProj];

%--------------------------------------------------------------------------
% B1 map - Double Angle Method
%--------------------------------------------------------------------------
% --- Executes on button press in B1MapButton.
function B1MapButton_Callback(hObject, eventdata, handles)
dataGUI = guidata(hObject);

% only proceed if source and destination exist
% TO DO 

% look for required files under the source directory
FilesNFolders = dir(dataGUI.SourceDirectory);
Files = FilesNFolders(~([FilesNFolders.isdir]));

Dim = size(Files);
NbFiles = Dim(1);

LI = [];
for k=1:NbFiles
    if strfind(Files(k).name, 'B1')
        if strfind(Files(k).name, '.nii')
            % Load images
            FullFile = [dataGUI.SourceDirectory, '/', Files(k).name];
            SFImages = load_nii_data(FullFile);
            file = struct;
            file.SF60 = FullFile;
            file.SF120 = FullFile;
            
            data.SF60  = double(SFImages(:,:,1,1));
            data.SF120 = double(SFImages(:,:,1,2));
            
            % create B1 map (qMRLab)
            load('B1_DAMParameters.mat');
            %qMRLab(Model,file);            
            FitResults = FitData(data,Model,1);
            
            % save results
            B1Dir = [dataGUI.DestinationDirectory, '/B1map_results'];
            mkdir(B1Dir);
            FitResultsSave_nii(FitResults, FullFile, B1Dir);
        end
    end     
end
 
guidata(hObject, dataGUI);


%--------------------------------------------------------------------------
% B0 map - Dual Echo Method
%--------------------------------------------------------------------------
% --- Executes on button press in B0MapButton.
function B0MapButton_Callback(hObject, eventdata, handles)
dataGUI = guidata(hObject);

% look for required files under the source directory
FilesNFolders = dir(dataGUI.SourceDirectory);
Files = FilesNFolders(~([FilesNFolders.isdir]));

Dim = size(Files);
NbFiles = Dim(1);

LI = [];
for k=1:NbFiles
    if strfind(Files(k).name, 'B0')
        if strfind(Files(k).name, '.nii')
            % Load images
            FullFile = [dataGUI.SourceDirectory, '/', Files(k).name];
            PMImages = load_nii_data(FullFile);
            file = struct;
            file.Phase = FullFile;
            file.Magn = FullFile;
            
            % This has to be fixed
            % TO DO
            data.Phase = (real(fft(double(PMImages(:,:,1,[1:2])))));
            data.Magn  = (angle(fft(double(PMImages(:,:,1,[1:2])))));

            % create B0 map (qMRLab)
            Model = B0_DEM;
            qMRLab(Model,file); 
            load([dataGUI.SourceDirectory, '/B0_DEMParameters.mat']);
            dTE = param.te2 - param.te1; 
            Model.Prot.Time.Mat = dTE;
            FitResults = FitData(data,Model,1);
            
            % save results
            % B0Dir
            B0Dir = [dataGUI.DestinationDirectory, '/B0map_results'];
            mkdir(B0Dir);
            FitResultsSave_nii(FitResults, FullFile, B0Dir);
        end
    end     
end
 
guidata(hObject, dataGUI);

%--------------------------------------------------------------------------
% T1-map - Variable Flip Angle Method
%--------------------------------------------------------------------------
% --- Executes on button press in T1map_VFA_Button.
function T1map_VFA_Button_Callback(hObject, eventdata, handles)
% TO DO



%--------------------------------------------------------------------------
% T1-map - Inversion Recovery Method
%--------------------------------------------------------------------------
% --- Executes on button press in T1map_IR_Button.
function T1map_IR_Button_Callback(hObject, eventdata, handles)
dataGUI = guidata(hObject);

% look for required files under the source directory
FilesNFolders = dir(dataGUI.SourceDirectory);
Files = FilesNFolders(~([FilesNFolders.isdir]));

Dim = size(Files);
NbFiles = Dim(1);

LI = [];
for k=1:NbFiles
    if strfind(Files(k).name, 'IR')
        if strfind(Files(k).name, '.nii')
            % Load images
            FullFile = [dataGUI.SourceDirectory, '/', Files(k).name];            
            data = struct;
            data.IRData = load_nii_data(FullFile);
           
            % create T1-map (qMRLab)
            Model = InversionRecovery; % initial model
            load([dataGUI.SourceDirectory, '/T1_IR_Parameters.mat']); % get specific parameters from file
            Model.Prot.IRData.Mat = param.ti;
            
            voxel = [70 60]; % plot fit in one voxel
            datavox.IRData = squeeze(data.IRData(voxel(1),voxel(2),:,:));
            FitResults = Model.fit(datavox);
            
            figure
            Model.plotmodel(FitResults,datavox);
            FitResults = FitData(data,Model);
            
            % save results
            T1Dir = [dataGUI.DestinationDirectory, '/T1map_results'];
            mkdir(T1Dir);
            FitResultsSave_nii(FitResults, FullFile, T1Dir);
        end
    end     
end
 
guidata(hObject, dataGUI);

%--------------------------------------------------------------------------
% MWF - Myelin Water Fraction with MET2 images
%--------------------------------------------------------------------------
% --- Executes on button press in MWF_Button.
function MWF_Button_Callback(hObject, eventdata, handles)
dataGUI = guidata(hObject);

% look for required files under the source directory
FilesNFolders = dir(dataGUI.SourceDirectory);
Files = FilesNFolders(~([FilesNFolders.isdir]));

Dim = size(Files);
NbFiles = Dim(1);

LI = [];
for k=1:NbFiles
    if strfind(Files(k).name, 'MWF')
        if strfind(Files(k).name, '.nii')
            % Load images
            FullFile = [dataGUI.SourceDirectory, '/', Files(k).name];            
            data = struct;
            data.MET2data = load_nii_data(FullFile);
            
            % for now create mask for all image, use real mask later on
            % TO DO
            
            data.Mask = (data.MET2data(:,:,1,1)./data.MET2data(:,:,1,1)); 
           
            % create T1-map (qMRLab)
            Model = MWF; % initial model
            load([dataGUI.SourceDirectory, '/MWF_Parameters.mat']); % get specific parameters from file
                        
            Model.Prot.Echo.Mat = proc.TE; % number of echoes = proc.ne
            
            FitResults = FitData(data,Model,1);
            
            figure % verify fit in figure
            voxel           = [37, 40, 1];
            FitResultsVox   = extractvoxel(FitResults,voxel,FitResults.fields);
            dataVox         = extractvoxel(data,voxel);
            Model.plotmodel(FitResultsVox,dataVox)
            
            % save results
            MWFDir = [dataGUI.DestinationDirectory, '/MWF_results'];
            mkdir(MWFDir);
            FitResultsSave_nii(FitResults, FullFile, MWFDir);
        end
    end     
end
 
guidata(hObject, dataGUI);


% --- Executes on button press in MTV_Button.
function MTV_Button_Callback(hObject, eventdata, handles)
dataGUI = guidata(hObject);

% look for required files under the source directory
FilesNFolders = dir(dataGUI.SourceDirectory);
Files = FilesNFolders(~([FilesNFolders.isdir]));

Dim = size(Files);
NbFiles = Dim(1);

LI = [];
for k=1:NbFiles
    if strfind(Files(k).name, 'MTV')
        if strfind(Files(k).name, '.nii')
            % Load images
            FullFile = [dataGUI.SourceDirectory, '/', Files(k).name];  
            
            % Do not execute if B1 folder does not exist. B1 map should be
            % processed prior to MTV execution
            % TO DO
            load([dataGUI.SourceDirectory, '/Processed/B1map_results/FitResults.mat']);
            data.B1map = double(B1map);

% NOTE: CSF mask should be drawn around the water phantom that will be created and present during scans.       
%             load('CSFMask.mat');
%             data.CSFMask = double(CSFMask);
            
%             load([dataGUI.SourceDirectory, '/SPGR.mat']);
%             data.SPGR    = double(SPGR);
            
            % create T1-map (qMRLab)
            Model = MTV;
            load([dataGUI.SourceDirectory, '/MTV_Parameters.mat']); % get specific parameters from file
            FlipAngle = proc.fliplist;
            TR        = param.tr * ones(length(FlipAngle),1);
            Model.Prot.MTV.Mat = [ FlipAngle , TR ];

            FitResults       = FitData(data,Model);
            
            % save results
            MTVDir = [dataGUI.DestinationDirectory, '/MTV_results'];
            mkdir(MTVDir);
            FitResultsSave_nii(FitResults, FullFile, MTVDir);
        end
    end     
end
 
guidata(hObject, dataGUI);
