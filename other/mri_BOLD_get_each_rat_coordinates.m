function coord = mri_BOLD_get_each_rat_coordinates
%cgcc: center of genu corpus callosum: indicating nx, ny, nz
cgcc{1} = [99 127 9];
cgcc{3} = [77 148 12];
cgcc{4} = [75 138 12];
cgcc{5} = [87 151 8];
cgcc{6} = [74 146 11];
cgcc{7} = [73 114 12];
cgcc{8} = [72 126 10];
cgcc{9} = [76 128 10];
cgcc{10} = [70 126 11];
cgcc{11} = [67 132 11];
cgcc{12} = [89 133 12];
cgcc{13} = [69 130 11];
cgcc{14} = [82 142 11];
cgcc{15} = [87 124 10];
cgcc{16} = [77 136 10];
cgcc{17} = [74 137 11];
cgcc{18} = [81 143 11];
cgcc{19} = [93 115 10];
coord.cgcc = cgcc;
lssc{1} = [75 147 7]; %careful, left is right on figure
lssc{3} = [68 174 10];
lssc{4} = [61 165 10];
lssc{5} = [78 178 6];
lssc{6} = [55 172 9];
lssc{7} = [52 132 10];
lssc{8} = [56 145 8];
lssc{9} = [58 147 8];
lssc{10} = [50 143 9];
lssc{11} = [52 153 9];
lssc{12} = [74 150 10];
lssc{13} = [54 148 9];
lssc{14} = [74 166 9];
lssc{15} = [70 144 8];
lssc{16} = [62 159 8];
lssc{17} = [60 157 9];
lssc{18} = [70 165 9];
lssc{19} = [75 132 8];
coord.lssc = lssc;
rssc{1} = [78 103 7];
rssc{3} = [58 126 10];
rssc{4} = [59 115 10];
rssc{5} = [63 132 6];
rssc{6} = [51 124 9];
rssc{7} = [60 86 10];
rssc{8} = [56 107 8];
rssc{9} = [56 112 8];
rssc{10} = [54 105 9];
rssc{11} = [51 107 9];
rssc{12} = [76 109 10];
rssc{13} = [56 106 9];
rssc{14} = [64 127 9];
rssc{15} = [75 105 8];
rssc{16} = [58 115 8];
rssc{17} = [55 117 9];
rssc{18} = [62 122 9];
rssc{19} = [83 92 8];
coord.rssc = rssc;
%round coordinates
for i=1:length(cgcc)
    if ~isempty(cgcc{i}) 
        rcgcc{i} = [round(cgcc{i}(1)/4) round(cgcc{i}(2)/4) cgcc{i}(3)];
        rlssc{i} = [round(lssc{i}(1)/4) round(lssc{i}(2)/4) lssc{i}(3)];
        rrssc{i} = [round(rssc{i}(1)/4) round(rssc{i}(2)/4) rssc{i}(3)];
    end
end
rlssc{25} = [40 21 2];
coord.rcgcc = rcgcc;
coord.rlssc = rlssc;
coord.rrssc = rrssc;

% rat = 1;
% for i=1:Nslice
% subplot(3,4,i);
% imagesc(squeeze(A(rat,:,:,i)));
% colormap(gray)
% end;
