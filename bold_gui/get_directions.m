function handles = get_directions(handles)
procpar = handles.AllData.procpar;
if strfind(procpar.seqfil{1},'epip')
    seq = 'epip';
else
    if strfind(procpar.seqfil{1},'sems')
        seq = 'sems';
    end
end
dro = procpar.dro;
dpe = procpar.dpe;
dsl = procpar.dsl;
switch seq
    case 'epip'
        SkipFirst = get(handles.SkipFirst,'Value');
        %Assuming triple reference scan
        dro = dro(5+2*SkipFirst:2:end);
        dpe = dpe(5+2*SkipFirst:2:end);
        dsl = dsl(5+2*SkipFirst:2:end);
        % dro1 = procpar.droSave;
        % dpe1 = procpar.dpeSave;
        % dsl1 = procpar.dslSave;
    case 'sems'
        dro = dro(2:end);
        dpe = dpe(2:end);
        dsl = dsl(2:end);
end
% if length(dro1) == 1
d.dro = dro;
d.dpe = dpe;
d.dsl = dsl;
% else
%     d = [];
% end
handles.AllData.directions = d;