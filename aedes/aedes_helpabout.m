function aedes_helpabout()
% AEDES_HELPABOUT - Show Aedes About dialog
%   
%
% Synopsis: 
%
% Description:
%
% Examples:
%
% See also:
%        AEDES

% This function is a part of Aedes - A graphical tool for analyzing 
% medical images
%
% Copyright (C) 2006 Juha-Pekka Niskanen <Juha-Pekka.Niskanen@uku.fi>
% 
% Department of Physics, Department of Neurobiology
% University of Kuopio, FINLAND
%
% This program may be used under the terms of the GNU General Public
% License version 2.0 as published by the Free Software Foundation
% and appearing in the file LICENSE.TXT included in the packaging of
% this program.
%
% This program is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
% WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.


%% Load default font and colors
GD=aedes_gui_defaults;

fig_w = 310;
fig_h = 395;
fig_location = aedes_dialoglocation([fig_w,fig_h]);
fig_pos = [fig_location(1) fig_location(2) fig_w fig_h];

%% Main Figure ----------------------------
fh = figure('Units','Pixel', ...
            'position',fig_pos,...
            'Name',['About Aedes'],...
            'Numbertitle','off', ...
            'Tag','aedes_about_figure', ...
            'Color','w',...%GD.col.mainfig, ...
            'Toolbar','none', ...
            'Menubar','none', ...
            'DoubleBuffer','on', ... 
            'DockControls','off',...
            'renderer','painters',...
            'Handlevisibility','off',...
            'windowstyle','modal',...
            'colormap',gray(256));
set(fh,'resize','off')

%% Background axes
bgax = axes('parent',fh,...
            'units','normal',...
            'position',[0 0 1 1],...
            'xlim',[0 1],...
            'ylim',[0 1],...
            'visible','off');

%% Image axes
imax = axes('parent',fh,...
            'units','pixel',...
            'position',[(fig_w-256)/2 0.65*fig_h 256 130],...
            'visible','off',...
            'ydir','reverse',...
            'clim',[0 500]);
uistack(imax,'bottom')

%% Show head image
fpath=which('aedes');
[fp,fn,fe]=fileparts(fpath);
try
  imdata = imread([fp,filesep,'aedes_logo.png']);
  %imdata = imdata(:,:,1);
catch
  delete(fh);
  hh=errordlg('Cannot find file "aedes_logo.png"!','Error!',...
              'modal');
  return
end

sz=size(imdata);
im=image('parent',imax,'cdata',imdata,...
  'cdatamapping','scaled');
set(imax,'xlim',[0.5 sz(2)+0.5],...
  'ylim',[0.5 sz(1)+0.5])

% %% Title text
% shadow_tx = text('parent',bgax,...
%                  'horizontalalign','left',...
%                  'units','normal',...
%                  'position',[0.054 0.976],...
%                  'verticalalign','top',...
%                  'string','Aedes 1.0',...
%                  'fontsize',22,...
%                  'fontweig','bold',...
%                  'color',[0 0 0]);
% title_tx = text('parent',bgax,...
%                 'horizontalalign','left',...
%                 'units','normal',...
%                 'position',[0.05 0.98],...
%                 'verticalalign','top',...
%                 'string','Aedes 1.0',...
%                 'fontsize',22,...
%                 'fontweig','bold',...
%                 'color',[0 0 0.85]);

% Version text
[rev,repo,wc_dir] = aedes_revision;
version_tx = text('parent',bgax,...
                  'horizontalalign','left',...
                  'units','normal',...
                  'position',[0.10 0.63],...
                  'verticalalign','top',...
                  'string',...
				  sprintf(['version 1.0 rev %d\n%s'],rev,'http://aedes.uku.fi'),...
                  'fontsize',10,...
                  'fontweig','bold',...
                  'color',[0 0 0]);
				
% Licence notise text
tmp = get(version_tx,'position');
lic_tx = text('parent',bgax,...
  'horizontalalign','left',...
  'units','normal',...
  'position',[tmp(1) tmp(2)-0.1],...
  'verticalalign','top',...
  'string',{'Aedes comes with ABSOLUTELY NO WARRANTY!',...
  'This is free software, and you are welcome to',...
  'redistribute it under certain conditions. Please ',...
  'see the file "license.txt" for details.'},...
  'fontsize',8,...
  'fontweig','bold',...
  'color',[0 0 0]);

% Copyright text
tmp=get(imax,'position');
copyright_tx = text('parent',bgax,...
                    'horizontalalign','left',...
                    'units','pixel',...
                    'position',[0.05*fig_w 25],...%[tmp(1) tmp(2)],...
                    'verticalalign','bottom',...
                    'string',[char(169),' 2006 Juha-Pekka Niskanen'],...
                    'fontsize',8,...
                    'fontweig','bold',...
                    'color',[0 0 0]);

% Horizontal line
ln = line('parent',bgax,...
          'xdata',[0.05 0.95],...
          'ydata',[0.1 0.1],...
          'color',[0.8 0.8 0.8]);

% Contact info
contact_shadow = text('parent',bgax,...
                      'horizontalalign','left',...
                      'units','normal',...
                      'position',[0.1 0.117],...
                      'verticalalign','bottom',...
                      'string',{'Contact information:','',...
                    'Juha-Pekka Niskanen,',...
                    'Biomedical NMR Group,',...
                    'A. I. Virtanen Institute for Molecular Sciences,',...
                    'University of Eastern Finland, Finland'...
                    'Email: Juha-Pekka.Niskanen@uef.fi'},...
                      'fontsize',8,...
                      'fontweig','bold',...
                      'color',[1 1 1]);
contact_tx = text('parent',bgax,...
                  'horizontalalign','left',...
                  'units','normal',...
                  'position',[0.1 0.12],...
                  'verticalalign','bottom',...
                  'string',{'Contact information:','',...
                    'Juha-Pekka Niskanen,',...
                    'Biomedical NMR Group,',...
                    'A. I. Virtanen Institute for Molecular Sciences,',...
                    'University of Eastern Finland, Finland'...
                    'Email: Juha-Pekka.Niskanen@uef.fi'},...
                  'fontsize',8,...
                  'fontweig','bold',...
                  'color',[0 0 0]);

% Close button
close_btn = uicontrol('parent',fh,...
                      'units','normal',...
                      'position',[0.7 0.01 0.25 0.075],...
                      'style','pushbutton',...
                      'string','Close',...
                      'callback','delete(gcbf)');