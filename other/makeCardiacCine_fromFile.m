%make a film from ciné frames
function makeCardiacCine_fromFile
[t sts] = spm_select(Inf,'any','Select DICOM files of the cine','',pwd);
if sts
    N = size(t,1);
    first_pass = 1;
    keep_going = 1;
    for i = 1:N
        fname = t(i,:);
        V = dicominfo(fname);
        tmp = dicomread(fname);
        cF = V.EchoNumber;
        [dir0 fil0] = fileparts(fname);
        cS = str2double(fil0(6:8));
        if i==1 
            [nx ny] = size(tmp);
        end       
        X{cF,cS} = imresize(tmp,[2*nx 2*ny],'bicubic');
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
    clims = [clims(1) clims(2)/2];
    nameOut = spm_input('Enter output name',0,'s');
    fname_movie = fullfile(dir0,[nameOut '.avi']);
    vidObj = VideoWriter(fname_movie);
    vidObj.FrameRate  = 2;
    open(vidObj);
    ct  = 0;
    for s1 = 1:nS
        for f1=1:nF
            ct = ct+1;
            h = figure; imagesc(fliplr(X{f1,s1}),clims); colormap(gray); axis ij;            
            %axis([50 160 120 210]); %Rabbit higher res 
            %axis([35 95 40 95]); %Rabbit lower res 
            %axis([65 175 65 175]); %Rat higher res6
            %axis([90 190 100 190]); %Rat higher res4
            axis([140 340 300 500]); %p12 SA
            %axis([120 320 300 500]); %p26 SA
            %axis([140 340 300 500]); %p16 SA
            %axis([80 280 300 500]); %p15 SA
            %axis([180 380 300 500]); %p34 SA
            %axis([90*2 190*2 100*2 190*2]); %Rat higher res3 512x512
            %axis([150 400 210 370]); %Rat higher res3 512x512
            %axis([60 200 25 205]); %mouse
            axis off;            
            F(ct) = getframe;
            writeVideo(vidObj,F(ct));
            close(h)
        end
    end    
    close(vidObj);
end



