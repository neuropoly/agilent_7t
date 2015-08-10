function su = mri_unwrap_phase(s,c)
%s: series of phases, c: cutoff in radians
n = length(s);
su = zeros(1,n);
su(1) = s(1);
cum = 0;
if n>1
    for i0=2:n
        if s(i0) < s(i0-1)-c
            cum = cum + 2*pi;
        else
            if s(i0) > s(i0-1)+c
                cum = cum - 2*pi;
            end
        end
        su(i0) = s(i0) + cum;
    end
end
