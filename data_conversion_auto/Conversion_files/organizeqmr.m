
%--------------------------------------------------------------------------
% organizeqmr
%   Organize qMR data from agilent mri and merge them
%   Let you preview and choose data you want
%   extract desire parameters from proc par
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
function organizeqmr(copytype, datafolder, destfolder)
Msg = 'No parameter files associated with: ';

for ff = 1:2:length(copytype) % loop over folders    
    
    NewPath = ManageParentFolder(destfolder, copytype{ff});
   
   % Manage subfolders
   if max(strcmp(copytype{ff+1},'keyword'))
       
       % PARSE INPUTS
       p=inputParser;
       p.addOptional('keyword','')
       p.addOptional('param',{},@iscell)
       p.addOptional('Gibbs',true,@islogical)
       
       argin = copytype{ff+1};
       parse(p,[],argin{:});
       in = p.Results;
       if ~isempty(in.param)
           procname = in.param;
           paramname = in.param;
           for ip = 1:length(in.param), if ~isempty(strfind(procname{ip},'/')), procname{ip} = procname{ip}(1:strfind(procname{ip},'/')-1); paramname{ip} = paramname{ip}(strfind(paramname{ip},'/')+1:end);  end; end
       end
       % LIST NIFTI FILES
       list= sct_tools_ls(fullfile(datafolder,[in.keyword '.nii.gz']),1,1);
       list = list(cellfun(@isempty,strfind(list,'_Gibbs.nii'))); % remove _Gibbs
       list = list(cellfun(@isempty,strfind(list,'_phase.nii'))); % remove _phase
       
       if length(list) % if files were found
           
           % open figure for image selection
           dat = {}; h=[];
           scrsz = get(groot,'ScreenSize');
           figure('Name',copytype{ff},'Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)])
           clear param
           
           for ll = 1:length(list) % loop over files
               % READ PARAMETERS
               if isempty(in.param)
               elseif exist(strrep(list{ll},'.nii.gz','_param.mat'),'file')
                   paramfile  = strrep(list{ll},'.nii.gz','_param.mat');
                   paramll = load(paramfile,'proc');
                   paramll = paramll.proc;
                   save param -struct paramll
                   param(ll) = load('param',procname{:});
    %            elseif exist(strrep(list{ll},'.nii.gz','_param.scheme'),2)
    %                txt2mat()
               else
                   Msg = [Msg; list{ll}]
               end

               % READ DATA
               dat{ll} = load_nii_data(list{ll});

               % DISPLAY AND ADD CHECKBOX
               hh = subplot(length(list),1,ll);
               if ll==1, hall = uicontrol('Style', 'checkbox','Units','normalized','Position',[hh.Position(1) 0.97 .1 .03],'Value',false,'String','Select all'); end
               h(ll) = uicontrol('Style', 'checkbox','Units','normalized','Position',[hh.Position(1:2) .03 .03],'Value',ll==1);
               set(hall,'Callback',@(x,y) set(h,'Value',get(hall,'Value')))
               imagesc(makeimagestack(dat{ll}(:,:,round(end/2),round(linspace(1,size(dat{ll},4),min(10,size(dat{ll},4))))),[],[],[1 10])); colormap gray; axis off; axis image;
               [~,seqname]=fileparts(list{ll});
               title([strrep(seqname,'_',' ') ' ' num2str(size(dat{ll},4)) ' volumes'])
           end

           % LET USER CHOOSE AND MERGE DATA AND PARAM
           pause
           hcheck = get(h,'Value'); if length(h)>1, hcheck = cell2mat(hcheck); end
           close(gcf)
           dat = dat(~~hcheck); % keep only selected
           dat = cat(4,dat{:}); % merge nifti --> CRASH IF SELECTED IMAGES DONT HAVE CONSISTENT MATRIX SIZE
           if ~isempty(in.param) % merge param
               param = param(~~hcheck);
               for ifield = 1:length(procname) 
                   paramMerged.(paramname{ifield}) = [param.(procname{ifield})]
               end
               save param -struct paramMerged
               clear paramMerged
           end
           prefix  = '_merged';
           % GIBBS
           if in.Gibbs, dat = unring(dat); prefix = [prefix '_Gibbs']; end
           
           % SAVE NIFTI
           save_nii_v2(dat,[NewPath prefix '.nii.gz'],list{find(hcheck,1,'first')})
       else
           % error(['no files associated with keyword ' in.keyword])
           Msg = [Msg, cellstr(in.keyword)];
       end
       
   else
       % LAUNCH organizeqmr IN SUBFOLDER
       organizeqmr(copytype{ff+1}, datafolder, NewPath)
   end

end

   l = msgbox(Msg);
   
end

%--------------------------------------------------------------------------
% ManageParentFolder
%   Create folder (subfolder) under the parent folder (destfolder)
function NewPath = ManageParentFolder(destfolder, subfolder)
   % Manage parent folder 
   if destfolder 
       NewPath = [destfolder '/' char(subfolder)];
   else
       NewPath = subfolder;
   end
   mkdir(NewPath)
end