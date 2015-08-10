%make a film from 9 + 9 ciné frames
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\WhiteMouseAb_4ch01';
fd1 = 'tagcine27.dcm';
fd2 = 'tagcine28.dcm';
nE = 9;
for i = 1:nE
    fname = fullfile(path0,fd1,['slice002image001echo00' int2str(i) '.dcm']);
    X{i} = dicomread(fname);
end

fname_movie = fullfile(path0,['CineMouseHeart_9frames1.avi']);
vidObj = VideoWriter(fname_movie);
vidObj.FrameRate  = 2;
open(vidObj);
for i=1:nE
    if i==1
        clims = [min(X{1}(:)) max(X{1}(:))];
    end
    figure; imagesc(fliplr(X{i}),clims); colormap(gray); axis([60 200 25 205]); axis off; axis ij; 
    F(i) = getframe;
    writeVideo(vidObj,F(i));
end
close(vidObj);



for i = 1:nE
    fname = fullfile(path0,fd2,['slice001image001echo00' int2str(i) '.dcm']);
    X{i} = dicomread(fname);
end

fname_movie = fullfile(path0,['CineMouseHeart_9frames2.avi']);
vidObj = VideoWriter(fname_movie);
vidObj.FrameRate  = 2;
open(vidObj);
for i=1:nE
    if i==1
        clims = [min(X{1}(:)) max(X{1}(:))];
    end
    figure; imagesc(fliplr(X{i}),clims); colormap(gray); axis([60 200 25 205]); axis off; axis ij; 
    F(i) = getframe;
    writeVideo(vidObj,F(i));
end
close(vidObj);



path0 = 'D:\Users\Philippe Pouliot\IRM_scans\WhiteMouseAb_4ch01';
fd1 = 'tagcine27.dcm';
fd2 = 'tagcine28.dcm';
nE = 9;
for i = 1:nE
    fname = fullfile(path0,fd1,['slice003image001echo00' int2str(i) '.dcm']);
    X{i} = dicomread(fname);
end

fname_movie = fullfile(path0,['CineMouseHeart_9frames3.avi']);
vidObj = VideoWriter(fname_movie);
vidObj.FrameRate  = 2;
open(vidObj);
for i=1:nE
    if i==1
        clims = [min(X{1}(:)) max(X{1}(:))];
    end
    figure; imagesc(fliplr(X{i}),clims); colormap(gray); axis([60 200 25 205]); axis off; axis ij; 
    F(i) = getframe;
    writeVideo(vidObj,F(i));
end
close(vidObj);


path0 = 'D:\Users\Philippe Pouliot\IRM_scans\WhiteMouseAb_4ch01';
fd1 = 'tagcine27.dcm';
fd2 = 'tagcine28.dcm';
nE = 9;
for i = 1:nE
    fname = fullfile(path0,fd1,['slice001image001echo00' int2str(i) '.dcm']);
    X{i} = dicomread(fname);
end

fname_movie = fullfile(path0,['CineMouseHeart_9frames4.avi']);
vidObj = VideoWriter(fname_movie);
vidObj.FrameRate  = 2;
open(vidObj);
for i=1:nE
    if i==1
        clims = [min(X{1}(:)) max(X{1}(:))];
    end
    figure; imagesc(fliplr(X{i}),clims); colormap(gray); axis([60 200 25 205]); axis off; axis ij; 
    F(i) = getframe;
    writeVideo(vidObj,F(i));
end
close(vidObj);