function hoverCallback(figure_BOLD_GUI, evt)
% Grab the x & y axes coordinate where the mouse is
mousePoint = get(figure_BOLD_GUI, 'CurrentPoint');
mouseX = mousePoint(1,1);
mouseY = mousePoint(1,2);

if mouseX
