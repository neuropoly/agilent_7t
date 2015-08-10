%make a film from 8 ciné frames
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\RatLE4a01';
fd1 = 'tagcine23.dcm';
nE = 12;
nS = 1;

for s1=1:nS
    clear X
    for i = 1:nE
        fname = fullfile(path0,fd1,['slice00' int2str(s1) 'image001echo0' gen_num_str(i,2) '.dcm']);
        X{i} = dicomread(fname);
    end
    
    fname_movie = fullfile(path0,['CineRatLE4_tagcine23_Heart_sl' int2str(s1) '.avi']);
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
end