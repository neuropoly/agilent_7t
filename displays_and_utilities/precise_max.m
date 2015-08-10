function [p_max] = precise_max(dat,param)
% precise_max
% Finds the precise maximum of a fonction by interpolating with a spline.

%%

[~,rough_max] = max(dat);
roi_begin = rough_max-10;
if roi_begin<1, roi_begin=1; end
roi_end = rough_max+10;
if roi_end>length(dat), roi_end=length(dat); end
roi_corr = roi_begin:roi_end;
interest_corr = dat(roi_corr);
roi_spline = roi_begin:param.inc:roi_end;
spline_corr = spline(roi_corr,interest_corr,roi_spline);
[~,p_max] = max(spline_corr);
p_max = p_max*param.inc+roi_begin;

end

