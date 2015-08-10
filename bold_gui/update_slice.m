function handles = update_slice(handles)
%Slider position and SliceNumber edit field:
set(handles.SliceNumber,'string',handles.AllData.sA);
set(handles.SliceSlider,'Value',handles.AllData.sA/handles.AllData.NsA);