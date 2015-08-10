%superpose 3 tagcine scans
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\B6heart601';
sc{1} = 'tagcine192mouse01.dcm';
sc{2} = 'tagcine192mouse02.dcm';
sc{3} = 'tagcine192mouse08.dcm';
%load data
Ne = 8; % number of cine frames
Ns = 9; % number of slices
NC = 3; %number of scans
scOut = 'tagcine192mouseSum3.dcm';
path2 = fullfile(path0,scOut);
if ~exist(path2,'dir'), mkdir(path2); end
for i0 = 1:Ns
    for j0 = 1:Ne
        for c0 = 1:NC
            path1 = fullfile(path0,sc{c0});
            fname0 = ['slice' gen_num_str(i0,3) 'image001echo' gen_num_str(j0,3) '.dcm'];
            fname = fullfile(path1,fname0);           
            Y0 = dicomread(fname);
            if c0 == 1
                V = dicominfo(fname);
                fout = fullfile(path2,fname0);
                Y = zeros(size(Y0));
            end
            Y = Y+double(Y0);
        end
        V.Filename = fout;
        Y = round(Y/NC);
        Y = int16(Y);
        dicomwrite(Y,fout,V);
    end
end