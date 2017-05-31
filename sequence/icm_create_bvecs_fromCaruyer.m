fname = '3shells.txt';
bmin = 300;
bmax = 2000;
mat = txt2mat('samples.txt');
bvecs=mat(:,[2 3 4]);
Gnorm = sqrt(bvals/max(bvals));
shellnumber=mat(:,1);
Sh = unique(shellnumber);

Sh_bvalues = round(linspace(sqrt(bmin),sqrt(bmax),max(Sh)).^2);

Sh_qvalues = linspace(sqrt(bmin),sqrt(bmax),max(Sh));
Sh_qvalues = Sh_qvalues./max(Sh_qvalues);
bvecs_unorm = bvecs;
for i=Sh(:)'
    bvecs_unorm(shellnumber==i,:) = bvecs_unorm(shellnumber==i,:)*Sh_qvalues(i);
end
scd_scheme_display(bvecs_unorm)

%% create ICM scanfile
dro = [0 0 0 bvecs_unorm(:,1)'];
dpe = [0 0 0 bvecs_unorm(:,2)'];
dsl = [0 0 0 bvecs_unorm(:,3)'];

% add virgule
fid = fopen(fname,'w+');
fprintf(fid, '%s\n\n%s\n%s\n\n%s\n\n',...
    'zero_gf',...
    '// Use temporary variables $dro, $dpe, $dsl to avoid',...
    '// errors about unequal array sizes for dro, dpe, dsl',...
    '// Start with a b=0');

dir_str={'dro','dpe','dsl'};
dir = [dro;dpe;dsl];
for i_dir=1:length(dir_str)
    dro_string = ['$' dir_str{i_dir} ' = $' dir_str{i_dir} ', ' num2str(dir(i_dir,1))];
    fprintf(fid, '\n\n%s',['$' dir_str{i_dir} ' = ' num2str(dir(i_dir,1))]);
    for i=2:length(dro)
        if mod(i-1,6)==0
            dro_string = ['$' dir_str{i_dir} ' = $' dir_str{i_dir} ', ' num2str(dir(i_dir,i))];
            fprintf(fid, '\n%s',dro_string);
        else
            dro_string = [', ' num2str(dir(i_dir,i))];
            fprintf(fid, '%s',dro_string);
        end
    end
end
fprintf(fid, '\n%s\n%s\n%s\n%s\n%s\n\n%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',... 
    'dro = $dro',...
    'dpe = $dpe',...
    'dsl = $dsl',...
    'set_gf_array',...
    'create(''nbval'',''real'',''current'',0)',...
    'create(''nbzero'',''real'',''current'',0)',...
    'create(''nbdirs'',''real'',''current'',0)',...
    'create(''dstart'',''real'',''current'',0)',...
    ['nbval=' num2str(length(dro)-3)],...
    ['nbzero= 3'],...
    ['nbdirs='  num2str(length(dro))]);

fclose(fid);


