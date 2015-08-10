function str_out = gen_num_str(num_in,str_len)
%utility to pad with zeros in front, so that files are listed in
%consecutive image frame order in Windows Explorer
%string length desired
if num_in > 0
    num_dig = floor(log10(num_in));
else
    num_dig = 0;
end
str = repmat('0',[1 str_len-num_dig-1]);
str_out = [str int2str(num_in)];