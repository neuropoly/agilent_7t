function mri_average_scans
%Average scans
%W:\BruceAllen\AllenP2901\cine_higher_res_FA40_5avg05.dcm
[dir_list sts] = spm_select(Inf,'dir','Select folders of scans to average','',pwd);
Nt  = size(dir_list,1);
if sts
    for n1 = 1:Nt
        cdir = dir_list(n1,:);
        [files dummy] = spm_select('FPList',cdir,'.*');
        N = size(files,1);
        for i1 = 1:N
            fname = files(i1,:);
            tmp = dicomread(fname);
            if n1==1 && i1==1
                [nx ny] = size(tmp);               
            end
            if n1==1
                V{i1} = dicominfo(fname);
                [dir0 fil0] = fileparts(V{i1}.Filename);
                if i1==1
                    [path0 file0] = fileparts(dir0);
                    path0 = fullfile(path0,'Average');
                    if ~exist(path0,'dir'), mkdir(path0); end
                end
                V{i1}.Filename = fullfile(path0,[fil0 '.dcm']);
                X{i1} = zeros(nx,ny);
            end
            %tmp = imfilter(tmp,hF);
            %tmp = imresize(tmp,2*size(tmp),'bicubic');
            Y{i1,n1} = double(tmp);
            X{i1} = X{i1}+double(tmp);     
            if n1 == Nt
                %Return to int16
                Z{i1} = int16(round(X{i1}/Nt));
                dicomwrite(Z{i1},V{i1}.Filename,V{i1});
            end
        end
    end 
end
