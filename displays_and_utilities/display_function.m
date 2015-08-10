function [h] = display_function(varargin)
% display_fonction
% This fonction displays the input arguments with variable numbers of
% subplots.

% input:
% structure containing numerous 3d/4d images (ex: different
% reconstructions). fieldnames will be used for the legend
% OR
% first input: 1st line to display
% second input: 2nd line to display
% ...
% nth input: nth line to display
% (n+1) input: 1st line legend
% (n+2) input: 2nd line legend
% ...
% (2*n)th input: nth line legend

%% Data and parameter extraction
nb_data=0;
data_pos=[];
nb_legend=0;
legend_pos=[];
if nargin<1
    error('Need something to display')
elseif nargin==1 && isstruct(varargin{1})
    input=varargin{1};
    leg = fieldnames(input);
    nb_data = length(leg);
    nb_legend = length(leg);
    for ii=1:nb_data
        data{ii} = getfield(input,leg{ii});
        data_size{ii} = size(data{ii});
        sz(ii) = length(data_size{ii});
    end
else
    for ii=1:nargin
        if isnumeric(varargin{ii}) || islogical (varargin{ii})
            nb_data=nb_data+1;
            data_pos=[data_pos ii];
        elseif ischar(varargin{ii})
            nb_legend=nb_legend+1;
            legend_pos=[legend_pos ii];
        end
    end
    for ii=1:nb_data
        data{ii} = varargin{data_pos(ii)};
        data_size{ii} = size(data{ii});
        sz(ii) = length(data_size{ii});
    end
    if nb_legend==nb_data
        for ii=1:nb_legend
            leg{ii} = varargin{legend_pos(ii)};
        end
    elseif nb_legend<nb_data
        if nb_legend>0
            for ii=1:nb_legend
                leg{ii} = varargin{legend_pos(ii)};
            end
        end
        for ii=nb_legend+1:nb_data
            leg{ii} = genvarname(['input' num2str(ii)]);
        end
    end
end

%% Display setup
nb_sz = min(sz);
switch nb_sz
    case 2
        nb_col = 1;
        nb_dis = 1;
        for kk=1:nb_data
            if sum(imag(data{kk}(:)))==0
                e_clims{kk,nb_dis} = double([min(min(data{kk})) max(max(data{kk}))]);
            else
                e_clims{kk,nb_dis} = double(abs([min(min(data{kk})) max(max(data{kk}))]));
            end
        end
    case 3
        for ii=1:nb_data
            nz(ii) = data_size{ii}(3);
        end
        nb_col = min(nz);
        nb_dis = 1;
        for kk=1:nb_data
            if sum(imag(data{kk}(:)))==0
                e_clims{kk,nb_dis} = double([min(min(min(data{kk}))) max(max(max(data{kk})))]);
            else
                e_clims{kk,nb_dis} = double(abs([min(min(min(data{kk}))) max(max(max(data{kk})))]));
            end        
        end
    case 4
        for ii=1:nb_data
            nz(ii) = data_size{ii}(3);
            nt(ii) = data_size{ii}(4);
        end
        nb_col = min(nz);
        nb_dis = min(nt);
        for kk=1:nb_data
            for tt=1:nb_dis
                if sum(imag(data{kk}(:)))==0
                    e_clims{kk,tt} = double([min(min(min(min(data{kk}(:,:,:,tt))))) max(max(max(max(data{kk}(:,:,:,tt)))))]);
                else
                    e_clims{kk,tt} = double(abs([min(min(min(min(data{kk}(:,:,:,tt))))) max(max(max(max(data{kk}(:,:,:,tt)))))]));
                end
            end
        end
    otherwise
        error('Data must range for 2D to 4D.')
end
clims=e_clims;
%% Display
global clims_sliders t
clims_sliders = [0 100];
t=1;
h=figure;
for jj=1:nb_col
    for kk=1:nb_data
        subplot(nb_data,nb_col,jj+(kk-1)*nb_col); imagesc(abs(data{kk}(:,:,jj,t)),clims{kk,t}); axis image; title([leg{kk} ' z=' num2str(jj) ' t=' num2str(t)],'fontsize',12);
        colormap jet
        if jj==nb_col
            colorbar('location','EastOutside')
        end
    end
end
if nb_dis>1
    % Add a slider uicontrol to control the shown time
    uicontrol('Style', 'slider','Min',1,'Max',nb_dis,'Value',t,'SliderStep',[1/(nb_dis-1) 1/(nb_dis-1)],...
        'units','normalized','Position', [0.7 0.01 0.2 0.04],'Callback', ...
        {@sliderZ_callback,data,nb_col,nb_data,nb_dis,leg,e_clims});
    % Add texts uicontrol to label the slider.
    uicontrol('Style','text','units','normalized','Position', [0.7 0.05 2/30 0.03],'String',round(t))
    uicontrol('Style','text','units','normalized','Position', [0.7+2/30 0.05 2/30 0.03],'String','over')
    uicontrol('Style','text','units','normalized','Position', [0.7+4/30 0.05 2/30 0.03],'String',nb_dis)
end
% Add 2 slider uicontrols to control clims
uicontrol('Style', 'slider','Min',0,'Max',100,'Value',clims_sliders(1),'SliderStep',[1/100 1/100],...
    'units','normalized','Position', [0.2 0.01 0.15 0.04],'Callback',...
    {@clims_min_callback,data,nb_col,nb_data,nb_dis,leg,e_clims});
uicontrol('Style', 'slider','Min',0,'Max',100,'Value',clims_sliders(2),'SliderStep',[1/100 1/100],...
    'units','normalized','Position', [0.35 0.01 0.15 0.04],'Callback',...
    {@clims_max_callback,data,nb_col,nb_data,nb_dis,leg,e_clims});
% Add a text uicontrol to label the sliders.
uicontrol('Style','text','units','normalized','Position', [0.2 0.05 2/30 0.03],'String','clims: ')
uicontrol('Style','text','units','normalized','Position', [0.2+2/30 0.05 2/30 0.03],'String',clims_sliders(1))
uicontrol('Style','text','units','normalized','Position', [0.2+4/30 0.05 2/30 0.03],'String','to')
uicontrol('Style','text','units','normalized','Position', [0.2+6/30 0.05 2/30 0.03],'String',clims_sliders(2))

% Add a popup to control the colormap
uicontrol('Style', 'popup', 'String', 'jet|hsv|hot|cool|gray', 'Position', [0.95 0.05 0.02 0.02],...
    'Callback', @setmap);
end

%%
function sliderZ_callback(hObj,event,data,nb_col,nb_data,nb_dis,leg,e_clims)
% Called to set the current slice
% when user moves the slider control
global clims_sliders t
t = round(get(hObj,'value'));
% Image display
for jj=1:nb_col
    for kk=1:nb_data
        clims{kk,t}(1) = e_clims{kk,t}(1) + clims_sliders(1)*(e_clims{kk,t}(2)-e_clims{kk,t}(1))/100;
        clims{kk,t}(2) = e_clims{kk,t}(1) + clims_sliders(2)*(e_clims{kk,t}(2)-e_clims{kk,t}(1))/100;  
        if clims{kk,t}(2)<=clims{kk,t}(1)
            clims{kk,t}(2)=clims{kk,t}(1)+(e_clims{kk,t}(2)-e_clims{kk,t}(1))/100;
        end
        subplot(nb_data,nb_col,jj+(kk-1)*nb_col); imagesc(abs(data{kk}(:,:,jj,t)),clims{kk,t}); axis image; title([leg{kk} ' z=' num2str(jj) ' t=' num2str(t)],'fontsize',12);
        colormap jet
        if jj==nb_col
            colorbar('delete')
            colorbar('location','EastOutside')
        end
    end
end
% Slider label
uicontrol('Style','text','units','normalized','Position', [0.7 0.05 2/30 0.03],'String',round(t))
uicontrol('Style','text','units','normalized','Position', [0.7+2/30 0.05 2/30 0.03],'String','over')
uicontrol('Style','text','units','normalized','Position', [0.7+4/30 0.05 2/30 0.03],'String',nb_dis)
end

function clims_min_callback(hObj,event,data,nb_col,nb_data,nb_dis,leg,e_clims)
% Called to set the current slice
% when user moves the slider control
% Image display
global clims_sliders t
clims_sliders(1) = round(get(hObj,'value'));
for jj=1:nb_col
    for kk=1:nb_data
        clims{kk,t}(1) = e_clims{kk,t}(1) + clims_sliders(1)*(e_clims{kk,t}(2)-e_clims{kk,t}(1))/100;
        clims{kk,t}(2) = e_clims{kk,t}(1) + clims_sliders(2)*(e_clims{kk,t}(2)-e_clims{kk,t}(1))/100;  
        if clims{kk,t}(2)<=clims{kk,t}(1)
            clims{kk,t}(2)=clims{kk,t}(1)+(e_clims{kk,t}(2)-e_clims{kk,t}(1))/100;
        end
        subplot(nb_data,nb_col,jj+(kk-1)*nb_col); imagesc(abs(data{kk}(:,:,jj,t)),clims{kk,t}); axis image; title([leg{kk} ' z=' num2str(jj) ' t=' num2str(t)],'fontsize',12);
        colormap jet
        if jj==nb_col
            colorbar('delete')
            colorbar('location','EastOutside')
        end
    end
end
% Slider label
uicontrol('Style','text','units','normalized','Position', [0.2 0.05 2/30 0.03],'String','clims: ')
uicontrol('Style','text','units','normalized','Position', [0.2+2/30 0.05 2/30 0.03],'String',clims_sliders(1))
uicontrol('Style','text','units','normalized','Position', [0.2+4/30 0.05 2/30 0.03],'String','to')
uicontrol('Style','text','units','normalized','Position', [0.2+6/30 0.05 2/30 0.03],'String',clims_sliders(2))
end

function clims_max_callback(hObj,event,data,nb_col,nb_data,nb_dis,leg,e_clims)
% Called to set the current slice
% when user moves the slider control
global clims_sliders t
clims_sliders(2) = round(get(hObj,'value'));
% Image display
for jj=1:nb_col
    for kk=1:nb_data
        clims{kk,t}(1) = e_clims{kk,t}(1) + clims_sliders(1)*(e_clims{kk,t}(2)-e_clims{kk,t}(1))/100;
        clims{kk,t}(2) = e_clims{kk,t}(1) + clims_sliders(2)*(e_clims{kk,t}(2)-e_clims{kk,t}(1))/100;  
        if clims{kk,t}(2)<=clims{kk,t}(1)
            clims{kk,t}(2)=clims{kk,t}(1)+(e_clims{kk,t}(2)-e_clims{kk,t}(1))/100;
        end
        subplot(nb_data,nb_col,jj+(kk-1)*nb_col); imagesc(abs(data{kk}(:,:,jj,t)),clims{kk,t}); axis image; title([leg{kk} ' z=' num2str(jj) ' t=' num2str(t)],'fontsize',12);
        colormap jet
        if jj==nb_col
            colorbar('delete')
            colorbar('location','EastOutside')
        end
    end
end
% Slider label
uicontrol('Style','text','units','normalized','Position', [0.2 0.05 2/30 0.03],'String','clims: ')
uicontrol('Style','text','units','normalized','Position', [0.2+2/30 0.05 2/30 0.03],'String',clims_sliders(1))
uicontrol('Style','text','units','normalized','Position', [0.2+4/30 0.05 2/30 0.03],'String','to')
uicontrol('Style','text','units','normalized','Position', [0.2+6/30 0.05 2/30 0.03],'String',clims_sliders(2))
end