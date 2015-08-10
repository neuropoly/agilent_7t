function call_averaging(pathNii,handles)
%Work in scan units rather than seconds here
N = handles.AllData.Nt;
pathStat = handles.AllData.pathStat;
ons = handles.AllData.ons;
dur_eff = handles.AllData.dur_eff;
TR = handles.AllData.TR;
ons = round(ons/TR);
dur = round(dur_eff/TR);
startOffset = str2double(get(handles.editStartOffset,'String'));
startOffset = round(startOffset/TR);
baselineDuration = str2double(get(handles.editBaselineDuration,'String'));
baselineDuration = round(baselineDuration/TR);
stims = [];
baseline = [];
Idur = 1:dur;
Ibase = 1:baselineDuration;
%Regressors for bad scans
removeBadScans = get(handles.removeBadScans,'Value');
if removeBadScans
    BadScans = handles.AllData.BadScans;
    BadScans(BadScans<0) = [];
    BadScans(BadScans>N) = [];
end
Nstims = 0;
Nbaseline = 0;
%Identify good blocks
for i0=1:length(ons)
    Tstims = 0; %temp index to find at least one good onset
    Tbaseline = 0;
    for j0 = Idur
        Itmp = ons(i0)+startOffset+j0-1;
        if  Itmp > 0 && Itmp < N && ~any(Itmp==BadScans)
            Tstims = 1;
            stims = [stims Itmp];
        end
    end
    if Tstims
        Nstims = Nstims + 1;
    end
    for j0 = Ibase
        Itmp = ons(i0)-j0;
        if  Itmp > 0 && Itmp < N && ~any(Itmp==BadScans)
            Tbaseline = 1;
            baseline = [baseline Itmp];
        end
    end
    if Tbaseline
        Nbaseline = Nbaseline + 1;
    end
end
Fscans = {};
for i0=stims
    Fscans = [Fscans; fullfile(pathNii,['srvolume' gen_num_str(i0,3) '.nii,1'])];
end
Bscans = {};
for i0=baseline
    Bscans = [Bscans; fullfile(pathNii,['srvolume' gen_num_str(i0,3) '.nii,1'])];
end
if ~exist(pathStat,'dir'), mkdir(pathStat); end
%Load data
Y = get_4vol(Fscans);
B = get_4vol(Bscans);
Ym = mean(Y,4);
Bm = mean(B,4);
Ys = std(Y,[],4);
Bs = std(B,[],4);
%YsN = Ys/(Nstims).^0.5;
%M = (Ym-Bm)./YsN;
%Two sample t-test:
M = (Ym-Bm)./(Ys.^2/Nstims+Bs.^2/Nbaseline).^0.5;
%Approximate number of independent stims and baselines
handles.AllData.M = M;
%Do average

average_display(handles);
