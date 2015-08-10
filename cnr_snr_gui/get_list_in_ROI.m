function Ylist = get_list_in_ROI(Y,p,nV,nH)
Ylist = [];
[NV NH] = size(Y); 
for i0 = p(1)-nV:p(1)+nV
    for j0 = p(2)-nH:p(2)+nH
        if i0>0 && i0 <= NV && j0 > 0 && j0 <= NH
            Ylist = [Ylist Y(i0,j0)];
        end
    end
end