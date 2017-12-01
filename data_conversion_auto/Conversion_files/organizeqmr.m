function organizeqmr(copytype,datafolder,destfolder)
% Organize qMR data from agilent mri and merge them
% Let you preview and choose data you want
% extract desire parameters from proc par
%
% copytype = {'qMT',{'SIRFSE',{'keyword','*sirfse*','param',{'ti'}},...
%                      'SPGR',{'keyword','*sirfse*','param',{'ti'}},...
%                   },...
%       'fieldsmap',    {'B0',{'keyword','b0_mapping*','param',{'te1','te2'}},...
%                        'B1',{'keyword','*B1_DAM*'}
%                       },...
%            };
%
% todo: add postprocessing (e.g. moco)
if nargin<3, destfolder = pwd; end

for ff = 1:2:length(copytype) % loop over folders
    if exist(['.' filesep copytype{ff}],'dir'), disp(['Folder ' copytype{ff} 'already exist. Skipping... (delete manually directory)']); continue; end
    NewPath = ManageParentFolder(destfolder, copytype{ff});
    if max(strcmp(copytype{ff+1},'keyword'))
        %% I- PARSE INPUTS
        p=inputParser;
        p.addOptional('keyword','')
        p.addOptional('param',{},@iscell)
        p.addOptional('Gibbs',true,@islogical)
        p.addOptional('phase',false,@islogical)
        
        argin = copytype{ff+1};
        parse(p,[],argin{:});
        in = p.Results;
        if ~isempty(in.param)
            % parse param for AgilentName/Rename e.g. 'param','flip1/flipangle' --> AgilentName=flip1, NewName=flipangle
            procname = in.param;
            paramname = in.param;
            for ip = 1:length(in.param), if ~isempty(strfind(procname{ip},'/')), procname{ip} = procname{ip}(1:strfind(procname{ip},'/')-1); paramname{ip} = paramname{ip}(strfind(paramname{ip},'/')+1:end);  end; end
            
            % parse param for .scheme
            scheme = ~cellfun(@isempty,strfind(procname,'scheme'));
            if max(scheme), procname=procname(~scheme); scheme=true; else scheme=false; end
        end
        %% II- LIST NIFTI FILES AND REMOVE PROCESSED FILES
        list= sct_tools_ls(fullfile(datafolder,[in.keyword '.nii.gz']),1,1);
        list = list(cellfun(@isempty,strfind(list,'_Gibbs.nii'))); % remove _Gibbs
        list = list(cellfun(@isempty,strfind(list,'_phase.nii'))); % remove _phase
        list = list(cellfun(@isempty,strfind(list,'_PH.nii'))); % remove scanned phase (duplicated with _phase)
        list = list(cellfun(@isempty,strfind(list,'_pointwise'))); % remove _pointwise
        if isempty(list), msgbox(['no files associated with keyword ' in.keyword]); delete(copytype{ff}); continue; end
        
        
        %% III- LOOP OVER FILES, OPEN FIGURE, LOAD DATA AND DISPLAY
        % open figure
        dat = {}; h=[];
        scrsz = get(groot,'ScreenSize');
        figure('Name',copytype{ff},'Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)])
        clear param
        for ll = 1:length(list) % loop over files
            % read parameters from procpar
            if isempty(in.param)
            elseif exist(strrep(list{ll},'.nii.gz','_param.mat'),'file')
                paramfile  = strrep(list{ll},'.nii.gz','_param.mat');
                paramll = load(paramfile,'proc');
                paramll = paramll.proc;
                save('param_tmp','-struct', 'paramll')
                param(ll) = load('param_tmp',procname{:});
                %            elseif exist(strrep(list{ll},'.nii.gz','_param.scheme'),2)
                %                txt2mat()
            else
                error(['no parameters file associated with ' list{ll}])
            end
            
            % load data
            dat{ll} = load_nii_data(list{ll});
            
            % display and add checkbox
            hh = subplot(length(list),1,ll);
            if ll==1, hall = uicontrol('Style', 'checkbox','Units','normalized','Position',[hh.Position(1) 0.97 .1 .03],'Value',false,'String','Select all'); end
            h(ll) = uicontrol('Style', 'checkbox','Units','normalized','Position',[hh.Position(1:2) .03 .03],'Value',ll==1);
            set(hall,'Callback',@(x,y) set(h,'Value',get(hall,'Value')))
            imagesc(makeimagestack(dat{ll}(:,:,round(end/2),round(linspace(1,size(dat{ll},4),min(10,size(dat{ll},4))))),[],[],[1 10])); colormap gray; axis off; axis image;
            [~,seqname]=fileparts(list{ll});
            title([strrep(seqname,'_',' ') ' ' num2str(size(dat{ll},4)) ' volumes; ' num2str(size(dat{ll},3)) ' slices'])
        end
        
        %% IV - LET USER CHOOSE FILES
        good=false;
        while(~good)
            pause
            hcheck = get(h,'Value'); if length(h)>1, hcheck = cell2mat(hcheck); end;
            dat = dat(~~hcheck); % keep only selected
            try
                datdim=cell2mat(cellfun(@(vv) size(vv,4),dat,'UniformOutput',false));
                dat = cat(4,dat{:}); % merge nifti --> CRASH IF SELECTED IMAGES DONT HAVE CONSISTENT MATRIX SIZE
                good=true;
            catch
                warndlg('VOLUMES SELECTED DO NOT HAVE CONSISTENT SIZE...')
                good=false;
            end
        end
        close(gcf)
        
        %% V - MERGE DATA AND PARAM
        if ~isempty(in.param) % merge param
            param = param(~~hcheck);
            for ifield = 1:length(procname)
                if length(unique([param.(procname{ifield})]))>1 && length(param(1).(procname{ifield}))==1 % if this is a varying parameter
                    paramMerged.(paramname{ifield}) = [];
                    for ivol=1:length(param), paramMerged.(paramname{ifield}) = [paramMerged.(paramname{ifield}) repmat(param(ivol).(procname{ifield}),[1 datdim(ivol)])]; end
                elseif length(param(1).(procname{ifield}))==datdim(1) % if this is a array parameter
                    paramMerged.(paramname{ifield}) = [];
                    for ivol=1:length(param), paramMerged.(paramname{ifield}) = [paramMerged.(paramname{ifield}) param(ivol).(procname{ifield})(1:datdim(ivol))]; end
                else
                    paramMerged.(paramname{ifield}) = [param(1).(procname{ifield})]; % if this is a fix parameter
                end
            end
            
            save([NewPath filesep  'param'], '-struct', 'paramMerged')
            clear paramMerged
            if scheme
                schemefilelist = strrep(list(~~hcheck),'.nii.gz','.scheme')';
                sct_tools_merge_text_files(schemefilelist,[copytype{ff} '.scheme'],0)
            end
        end
        suffix  = '_merged';
        
        %% PHASE
        if in.phase
            datph=[];
            for iv=find(hcheck), datph =cat(4,datph,load_nii_data(strrep(list{iv},'.nii.gz','_phase.nii.gz'))); end
            save_nii_v2(datph,[NewPath filesep copytype{ff} '_phase.nii.gz'],list{find(hcheck,1,'first')})
        end
        
        
        %% GIBBS
        if in.Gibbs, dat = unring(dat); suffix = [suffix '_Gibbs']; end
        
        %% SAVE NIFTI
        save_nii_v2(dat,[NewPath filesep copytype{ff} suffix '.nii.gz'],list{find(hcheck,1,'first')})
        
        %% todo postprocessing
        
    else
        %% LAUNCH organizeqmr IN SUBFOLDER
        organizeqmr(copytype{ff+1},datafolder,NewPath)
    end
end

delete param_tmp
%--------------------------------------------------------------------------
% ManageParentFolder
%   Create folder (subfolder) under the parent folder (destfolder)
function NewPath = ManageParentFolder(destfolder, subfolder)
   % Manage parent folder 
   NewPath = [destfolder filesep char(subfolder)];
   mkdir(NewPath)
