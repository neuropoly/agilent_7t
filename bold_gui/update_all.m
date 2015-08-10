function handles = update_all(handles)
if handles.AllData.AnatLoaded
    handles = display_Anat(handles);
end
if handles.AllData.BOLDLoaded
    handles = display_BOLD(handles);
    handles = show_BOLD_time_course(handles);
end
if ~isfield(handles.AllData,'DiffusionLoaded')
    handles.AllData.DiffusionLoaded = 0;
end
if handles.AllData.DiffusionLoaded
    handles = display_Diffusion(handles);
    handles = show_Diffusion(handles);
end