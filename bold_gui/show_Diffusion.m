function handles = show_Diffusion(handles)
try
    DP = handles.AllData.DP;
    D = handles.AllData.D;
    Dt = squeeze(D(DP(1),DP(2),2:end,DP(3)));
    NdL1 = handles.AllData.Nd-1;
    %plot(Dt);
    %Better plot: get directions
    dro = handles.AllData.directions.dro;
    dpe = handles.AllData.directions.dpe;
    dsl = handles.AllData.directions.dsl;
    dro = dro(1:NdL1);
    dpe = dpe(1:NdL1);
    dsl = dsl(1:NdL1);
    %axes(handles.GLMresults)
    X = zeros(1,NdL1);
    Y = X;
    Z = X;
    for i0=1:NdL1
        X(i0) = Dt(i0)*dro(i0);
        Y(i0) = Dt(i0)*dpe(i0);
        Z(i0) = Dt(i0)*dsl(i0);        
    end
    S = 5*ones(1,numel(X));
    C = ones(1,numel(X));
    M = max(Dt);
    %scatter3(X,Y,Z,S,'g'); hold on
    %scatter3(M*dro,M*dpe,M*dsl,S,'r'); hold off
    
    %Projection along X axis: 
    axes(handles.axesX);
    scatter(dro,Dt/M,S,'g');
    axis([-1 1 0 1]);
    %Projection along Y axis: 
    axes(handles.axesY);
    scatter(dpe,Dt/M,S,'g');
    axis([-1 1 0 1]);
    %Projection along Z axis: 
    axes(handles.axesZ);
    scatter(dsl,Dt/M,S,'g');
    axis([-1 1 0 1]);
    
    axes(handles.axesYZ);
    %axes('Units', 'normalized', 'Position', [0,0,1,1]);
    %2D projection along 3 axes
    %Projection in YZ plane
    %subplot(1,3,1)    
    scatter(Y/M,Z/M,S,'g'); hold on
    scatter(dpe,dsl,S,'r'); hold off
    axis([-1 1 -1 1]);
    %Projection in ZX plane
    %subplot(1,3,2) 
    axes(handles.axesZX);
    scatter(Z/M,X/M,S,'g'); hold on
    scatter(dsl,dro,S,'r'); hold off
    axis([-1 1 -1 1]);
    %Projection in XY plane
    axes(handles.axesXY);
    %subplot(1,3,3)    
    scatter(X/M,Y/M,S,'g'); hold on
    scatter(dro,dpe,S,'r'); hold off
    axis([-1 1 -1 1]);
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end