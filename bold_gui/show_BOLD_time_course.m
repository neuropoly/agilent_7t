function handles = show_BOLD_time_course(handles)
try
    if ~isfield(handles.AllData,'ons')
        S.Nstim = str2double(get(handles.NumberOfStims,'String')); %Any large enough number -- the extra stims will not matter
        S.Delay = str2double(get(handles.Delay,'String'));
        S.DurationFirstStim = str2double(get(handles.DurationFirstStim,'String'));
        S.DurationOtherStims = str2double(get(handles.DurationOtherStims,'String'));
        S.StartFirstStim = str2double(get(handles.StartFirstStim,'String'));
        S.RestBetweenStims = str2double(get(handles.RestBetweenStims,'String'));
        S.BlockDuration = S.RestBetweenStims + S.DurationOtherStims;
        S.DelayFirstStim = S.Delay+S.StartFirstStim;
        handles.AllData.ons = [S.DelayFirstStim S.DelayFirstStim+S.DurationFirstStim+S.RestBetweenStims+...
            (0:S.BlockDuration:S.Nstim*S.BlockDuration)]; %onset times
        handles.AllData.dur_eff = [S.DurationFirstStim repmat(S.DurationOtherStims,[1 length(handles.AllData.ons)-1])];
        handles.AllData.S = S;
    end
    DP = handles.AllData.DP;
    axes(handles.TimeCourse1);
    B = handles.AllData.B;
    Bt = squeeze(B(DP(1),DP(2),:,DP(3)));
    TR = handles.AllData.TR;
    Nt = handles.AllData.Nt;
    lp = linspace(0,Nt*TR,Nt);
    handles.AllData.LengthCycle = handles.AllData.ons(2)-handles.AllData.ons(1);
    handles.AllData.NbCycle = round(Nt*TR/handles.AllData.LengthCycle);
    %plot(lp(1:442),Bt(1:442));
    plot(lp,Bt);
    xlabel('Time (seconds)')
    for i=1:handles.AllData.NbCycle
        Xmin=handles.AllData.ons(i);    Xmax=handles.AllData.ons(i)+handles.AllData.dur_eff(i);
        Ymin=0.9*min(Bt);               Ymax=1.1*max(Bt);
        X=[Xmin Xmin Xmax Xmax];
        Y=[Ymin Ymax Ymax Ymin];
        h=patch(X,Y,1);
%         h=rectangle('Position',[Xmin,Ymin,Xmax-Xmin,Ymax-Ymin],'FaceColor','r'); 
        alpha(h,0.15) 
    end
    %Show data point on anatomical and on sample BOLD image
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end