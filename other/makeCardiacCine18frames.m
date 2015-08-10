%make a film from 9 + 9 ciné frames
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\WM503';
fd1 = 'tagcine03.dcm';
fd2 = 'tagcine04.dcm';
nE = 8;
for i = 1:nE
    fname = fullfile(path0,fd1,['slice001image001echo00' int2str(i) '.dcm']);
    X{2*i-1} = dicomread(fname);
end
for i = 1:nE
    fname = fullfile(path0,fd2,['slice001image001echo00' int2str(i) '.dcm']);
    X{2*i} = dicomread(fname);
end


fname_movie = fullfile(path0,['CineMouseHeart_16frames_zoom.avi']);
vidObj = VideoWriter(fname_movie);
vidObj.FrameRate  = 1;
open(vidObj);
for i=1:2*nE
    if i==1
        clims = [min(X{1}(:)) max(X{1}(:))];
        m1 = mean(X{1}(:)); m2 = mean(X{2}(:));
    end
    if mod(i,2) == 0
        c = m1/m2;
    else
        c = 1;
    end
    h = figure; imagesc(fliplr(X{i}*c),clims); colormap(gray); axis([ 50 175 125 225 ]); 
    axis off; axis ij; 
    F(i) = getframe;
    writeVideo(vidObj,F(i));
    close(h);
end
close(vidObj);