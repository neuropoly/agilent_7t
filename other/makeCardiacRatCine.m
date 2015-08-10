%make a film from 8 ciné frames
path0 = 'D:\Users\Philippe Pouliot\IRM_scans';
fd1 = 'tagcine03.dcm';
nE = 8;
for i = 1:nE
    fname = fullfile(path0,fd1,['slice001image001echo00' int2str(i) '.dcm']);
    X{i} = dicomread(fname);
end

fname_movie = fullfile(path0,['CineRatHeart_8frames1.avi']);
vidObj = VideoWriter(fname_movie);
vidObj.FrameRate  = 1;
open(vidObj);
for i=1:nE
    if i==1
        clims = [min(X{1}(:)) max(X{1}(:))];
    end
    figure; imagesc(fliplr(X{i}),clims); colormap(gray); axis off; axis ij; %axis([60 200 25 205]);
    F(i) = getframe;
    writeVideo(vidObj,F(i));
end
close(vidObj);