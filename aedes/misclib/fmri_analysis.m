function [maps_out,fdrth,H] = fmri_analysis(DATA,varargin)
%
% This function does a quick fMRI analysis in SPM style. No motion
% correction or slice timing at this time...
%

% Defaults
TR = [];
contr = [1];
onset = [];
durat = [];
smooth_kernel = [];
d_cutoff = [];      % Don't temporally filter data by default
qFDR = 0.05;        % Default threshold for FDR correction
globalNorm = false; % Don't do global normalization by default
omitVols = [];      % Don't omit any volumes from the analysis by default
show_wbar = true;   % Show waitbar by default
mask = [];          % Don't mask by default
regr = [];          % Don't use additional regressors by default

if rem(length(varargin),2)~=0
  error('parameters/values missing!')
end

% Parse varargin
for ii=1:2:length(varargin)
  param = lower(varargin{ii});
  value = varargin{ii+1};
  switch param
    case 'tr'
      TR = value;
    case {'onset','onsets'}
      onset = value;
      onset = onset(:);
    case {'durat','durations','duration'}
      durat = value;
      durat = durat(:);
    case 'smooth'
      smooth_kernel = value;
    case 'contrast'
      contr = value;
    case 'fdrth'
      qFDR = value;
    case {'hipass','hicutoff'}
      d_cutoff = value;
    case 'omitvolumes'
      omitVols = value;
    case 'wbar'
      if value==1
        show_wbar = true;
      else
        show_wbar = false;
      end
    case 'mask'
      if isnumeric(value) || islogical(value)
        mask = value;
      else
        error('Invalid mask!')
      end
    case 'regressor'
      regr = value;
  end
end

% Check that we have something to fit...
if isempty(onset) && isempty(regr)
	warning('No onsets or regressors defined. Only mean will be fitted!')
end

% Check that TR has been given
if isempty(TR)
	error('Repetition time (TR) has not been defined!')
end

% Check onsets and durations
if ~isempty(onset)
	if isempty(durat)
		error('Durations for onsets have not been defined!')
	end
  if length(durat)==1
    durat = repmat(durat,1,length(onset));
    durat = durat(:);
  elseif length(durat)~=length(onset)
    error('Mismatch in the number of elements in onset and duration!')
  end
end

% Check data
if isstruct(DATA) && isfield(DATA,'FTDATA')
  data = DATA.FTDATA;
elseif isnumeric(DATA) && ndims(DATA)>2
  data=DATA;
else
  error('Input data has to be a 3D/4D numeric matrix or Aedes data structure!')
end

% Permute 3D matrix to 4D
if ndims(data)==3
  data = permute(data,[1 2 4 3]);
end

% Initialize mask
if isempty(mask)
  mask = true(size(data,1),size(data,2),size(data,3));
end

% Check regressors
if ~isempty(regr)
  if size(regr,1)~=size(data,4)
    error('The lengths of the regressors do not match data length!')
	end
  regr = detrend(regr);
end

% Load Rat HRF (8 seconds long) NOTE: DON'T USE FOR HUMAN DATA!!!
bf = [
0
   0.000008876945146
   0.000387621003097
   0.003012441669394
   0.011548214895067
   0.030056522080168
   0.061233628208021
   0.105349995559045
   0.160158500633323
   0.221528149631163
   0.284405279593501
   0.343761753554314
   0.395323573307322
   0.436002661868442
   0.464045998242252
   0.478965423658889
   0.481327079129854
   0.472473786978796
   0.454237528221769
   0.428680153860941
   0.397883140401152
   0.363793656845973
   0.328124931280142
   0.292303457117353
   0.257453130446147
   0.224406054242129
   0.193730677047637
   0.165769521647024
   0.140680556701329
   0.118477987483032
   0.099069734765398
   0.082290068881472
   0.067926763712502
   0.055742762013807
   0.045492744488986
   0.036935220196777
   0.029840852217657
   0.023997740489123
   0.019214335904674
   0.015320580887648
   0.012167779438633
   0.009627606069476
   0.007590575511228
   0.005964217696074
   0.004671136982604
   0.003647081075751
   0.002839102788446
   0.002203865389816
   0.001706118264261
   0.001317352436400
   0.001014633776781
   0.000779604140824
   0.000597636251764
   0.000457125954290
   0.000348904854607
   0.000265756797153
   0.000202022712087
   0.000153279812313
   0.000116082720651
   0.000087755728843
   0.000066226941806
   0.000049896490408
   0.000037532277385 
];

fprintf(1,'\n******************************************\n');
fprintf(1,'Starting fMRI analysis.\n');
if isstruct(DATA) && isfield(DATA,'HDR') && isfield(DATA.HDR,'fpath')
  filename = [DATA.HDR.fpath,DATA.HDR.fname];
  fprintf(1,'File: %s\n\n',filename)
else
  fprintf(1,'\n');
end

% Omit volumes from data and stimulus function if requested
if ~isempty(omitVols)
 
  fprintf(1,'Skipping requested volumes...\n');
  if ~isempty(onset)
    % Calculate new onsets and durations
    ton = onset;
    tof = onset+durat+1;
    tmp=zeros(1,size(data,4));
    tmp(ton)=1;tmp(tof)=-1;
    sf=cumsum(tmp);
    sf(omitVols)=[];
    tmp=diff([0 sf]);
    onset = find(tmp==1);
    durat = find(tmp==-1);
    if isempty(durat)
      % Block stays up...
      durat=length(tmp)-onset(end)-1;
    elseif length(durat) < length(onset)
      durat(1:end-1) = durat(1:end-1)-onset(1:end-1)-1;
      durat(end) = length(tmp)-onset(end)-1;
    else
      durat = durat-onset-1;
    end
    onset=onset(:);
    durat=durat(:);
    
    fprintf(1,['New onsets: ',num2str(onset(:)'),'\n']);
    fprintf(1,['New duration: ',num2str(durat(:)'),'\n']);
  end
  
  if ~isempty(regr)
    regr(omitVols,:)=[];
  end
  data(:,:,:,omitVols) = [];
    
end

% Create stimulus function (32 bin offset)
k = size(data,4); % Number of scans
T     = 16;
dt    = TR/T;
if ~isempty(onset)
  u     = onset.^0;
  if ~any(durat)
    u  = u/dt;
  end
  ton       = round(onset*TR/dt) + 32;			% onsets
  tof       = round(durat*TR/dt) + ton + 1;			% offset
  sf        = zeros((k*T + 128),size(u,2));
  ton       = max(ton,1);
  tof       = max(tof,1);
  for j = 1:length(ton)
    if numel(sf)>ton(j),
      sf(ton(j),:) = sf(ton(j),:) + u(j,:);
    end;
    if numel(sf)>tof(j),
      sf(tof(j),:) = sf(tof(j),:) - u(j,:);
    end;
  end
  sf        = cumsum(sf);					% integrate
  
  % Convolve stimulus with the HRF
  conv_sf = conv(sf,bf);
  
  % Resample the convolved stimulus
  RR = conv_sf([0:(k-1)]*16+1+32);
  RR=RR(:);
else
  RR=[];
end


% Smooth data if requested
if ~isempty(smooth_kernel) && ~ismember(smooth_kernel,[1 1 1],'rows')
	if show_wbar
		wbh = aedes_calc_wait('Smoothing data...');
		drawnow
	end
	if all(smooth_kernel)
		tic
		smooth_data = fmri_smooth(data,smooth_kernel);
		toc
	else
		fprintf(1,'fMRI analysis warning: Could not smooth data!\n');
		smooth_data = data;
	end
	if show_wbar
		close(wbh);
	end
else
	smooth_data = data;
end


if ~isempty(d_cutoff)
  % Create filtering matrix
  nCosine = ceil((2*k*TR)/(d_cutoff + 1));
  S = sqrt(2/k)*cos([1:nCosine]'*pi*([1:k]/k)).';
  KKT = eye(size(S,1))-2*S*S'+S*S'*S*S';
else
  KKT = eye(k);
  S = 0;
end
H = [RR regr ones(k,1)];
H = H-S*(S'*H); % Filter design matrix
nParam = size(H,2);
maps_out = struct('pmap',[],'tmap',[]);
maps_out.pmap = zeros(size(smooth_data,1),size(smooth_data,2),size(smooth_data,3),nParam);
maps_out.tmap = zeros(size(smooth_data,1),size(smooth_data,2),size(smooth_data,3));

% Calculate parametric map(s)
nPlanes = size(smooth_data,3);
nCols = size(smooth_data,2);
nRows = size(smooth_data,1);
if length(contr)<nParam
	contr(nParam)=0; % Pad with zeros
end
c = repmat(contr,nRows,1);
HTH = pinv(H'*H);
R = eye(size(H,1))-H*HTH*H';

if show_wbar
  wbh = aedes_wbar(0,sprintf('Estimating parameters. Processing plane 0/%d',nPlanes));
  drawnow
end

% Process data in columns
for ii=1:nPlanes
  
  %fprintf(1,'Processing plane %d/%d\n',ii,nPlanes);
  for kk=1:nCols
    if show_wbar
      aedes_wbar(ii/nPlanes,wbh,sprintf('Estimating parameters. Processing plane %d/%d, column %d/%d',ii,nPlanes,kk,nCols));
    end
    col_data = squeeze(smooth_data(:,kk,ii,:)).';
    col_data = col_data-S*(S'*col_data);
    th=H\col_data;
    r = col_data-H*th;
    rr=diag(r'*r);
    rr=rr(:);
    sig2 = rr./trace(R*KKT);
    sig2 = repmat(sig2,1,nParam);
    T = diag(c*th)./sqrt(c.*sig2*HTH*H'*KKT*H*HTH*contr');
    T(find(mask(:,kk,ii)==0))=0;
		maps_out.pmap(:,kk,ii,:) = th.';
		maps_out.tmap(:,kk,ii)=T.';
	end
end
if show_wbar
  close(wbh);
end

if show_wbar
  wbh = aedes_calc_wait('Calculating threshold...');
  drawnow
end

% Set NaN:s to zeros
maps_out.tmap(isnan(maps_out.tmap)) = 0;

% Calculate effective degrees of freedom
dof = (trace(R*KKT).^2)/trace(R*KKT*R*KKT);

% p-values
pval_map = 1-tdist(maps_out.tmap,dof);

% Perform FDR (False Discovery Rate) correction
cV = 1;

pValues = pval_map(:);
tValues = maps_out.tmap(:);

[pValuesSorted,sortInd] = sort(pValues);
tValuesSorted = tValues(sortInd);
nP = length(pValues);

pFDR = [1:nP]'/nP*qFDR/cV; % FDR-correction
thresFDRind = find(pValuesSorted<=pFDR,1,'last');
if ~isempty(thresFDRind)
  thresFDR = tValuesSorted(thresFDRind);
else
  thresFDR = [];
end

if show_wbar
  close(wbh);
end

if nargout>=2
  fdrth = thresFDR;
end

if ~isempty(thresFDR)
  fprintf(1,['FDR threshold at p<',num2str(qFDR),': %.3f\n'],thresFDR)
else
  fprintf(1,['No significant voxels over FDR threshold at p<',num2str(qFDR),'!\n'])
end

fprintf(1,'******************************************\n');


