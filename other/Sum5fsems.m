%Sum 5 fsems scans 
Nsl = 23;
Nsc = 5;
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\Rabbit01_VarianVol01';

for i0=1:Nsc
    switch i0
        case 1
            image = 1;
            scan = 'fsems04';
        case 2
            image = 1;
            scan = 'fsems05';
        case 3
            image = 2;
            scan = 'fsems05';
        case 4
            image = 1;
            scan = 'fsems06';
        case 5
            image = 2;
            scan = 'fsems06';
    end
    for j0 = 1:Nsl
        fname = ['slice' gen_num_str(j0,3) 'image' gen_num_str(image,3) 'echo001.dcm'];
        Fname = fullfile(path0,[scan '.dcm'],fname);
        Y{i0,j0} = dicomread(Fname);
        if i0 == 1 
            Z{j0} = zeros(size(Y{i0,j0}));
        end
        Z{j0} = Z{j0} + double(Y{i0,j0});
    end
end
figure; imagesc(imresize(Z{12},2)); colormap(gray); axis off;
figure; imagesc(imresize(Y{1,12},2)); colormap(gray); axis off;


for i0=1:Nsl
    slice = ['slice' gen_num_str(i0,3)];
    fname = fullfile(path0,slice);
    h = figure; imagesc(imresize(Z{i0},2),[0 1.1e5]); colormap(gray); axis off;
    print(h, '-dpng', [fname '.png'], '-r300');
    close(h);
end

a=1;
        