function makeCardiacCine_fromFile_ROI
%make a film from ciné frames
[t sts] = spm_select(Inf,'any','Select DICOM files of the cine','',pwd);
if sts
    N = size(t,1);
    first_pass = 1;
    %keep_going = 1;
    for i = 1:N
        fname = t(i,:);
        V = dicominfo(fname);
        tmp = dicomread(fname);
        tmp = imresize(tmp,2*size(tmp),'bicubic');
        cF = V.EchoNumber;
        [dir0 fil0] = fileparts(fname);
        cS = str2double(fil0(6:8));
        if i==1
            %Choose ROI
            h = figure; imagesc(tmp); colormap(gray);
            H = imrect;
            BW = createMask(H); %roipoly;
            %pos = getPosition(H);
            for j0=1:size(BW,1);
                t1 = find(BW(j0,:));
                if ~isempty(t1)
                    v1 = length(t1); %t1(end)-t1(1);
                    break
                end
            end
            BW1 = find(BW);
            %v2 = length(BW1);
            tmp0 = reshape(tmp(BW),[],v1);
            [nx ny] = size(tmp0);
        end
        tmp = reshape(tmp(BW),[],v1);
        X{cF,cS} = tmp; 
    end
    nF = cF;
    nS = cS;
    %while keep_going
    if first_pass
        clims = [min(X{1,1}(:)) max(X{1,1}(:))];
    end
    %         for s1 = 1:nS
    %             for f1=1:nF
    %                 ct = ct+1;
    %                 h(ct) = figure; imagesc(fliplr(X{f1,s1}),clims); colormap(gray); axis off; axis ij;
    %                 if ~first_pass
    %                     axis([60 200 25 205]);
    %                 end
    %             end
    %         end
    %end
    %clims = [clims(1) clims(2)/2];
    nameOut = spm_input('Enter output name',0,'s');
    disp(['clims = ' num2str(clims(1)) ', ' num2str(clims(2))]);
    colorbar
    clims2 = spm_input('Enter clims2',0,'s');
    clims = [clims(1) str2double(clims2)];
    close(h);
    use_subplot = spm_input('Use Subplot',0,'y/n');
    if use_subplot == 'y'
        use_subplot = 1;
    else
        use_subplot = 0;
    end
    
    fname_movie = fullfile(dir0,[nameOut '.avi']);
    vidObj = VideoWriter(fname_movie);
    vidObj.FrameRate  = 2;
    open(vidObj);
    ct  = 0;
    if use_subplot
        for f1=1:nF
            ct = ct+1;
            h = figure;
            for s1 = 1:nS
                switch nS
                    case 1
                    case 2
                        subplot(1,2,s1);
                    case 3
                        subplot(1,3,s1);
                    case 4
                        subplot(2,2,s1);
                    case {5,6}
                        subplot(2,3,s1);
                    case {7,8,9}
                        subplot(3,3,s1);
                end
                imagesc(fliplr(X{f1,s1}),clims); colormap(gray); axis ij;
                axis off;
            end
            F(ct) = getframe(h);
            writeVideo(vidObj,F(ct));
            close(h)
        end
    else
        for s1 = 1:nS
            for f1=1:nF
                ct = ct+1;
                h = figure; imagesc(fliplr(X{f1,s1}),clims); colormap(gray); axis ij;
                axis off;
                F(ct) = getframe;
                writeVideo(vidObj,F(ct));
                close(h)
            end
        end
    end
    close(vidObj);
end



