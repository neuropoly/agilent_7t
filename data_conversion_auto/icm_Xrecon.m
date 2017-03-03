% prepare folder
mkdir acqfil
movefile fid acqfil
fileID = fopen('procpar','r');
s = fread(fileID,'*char')';
fclose(fileID);
s = strrep(s,'pointwise','off');
fileID = fopen('curpar','w');
fwrite(fileID,s);
fclose(fileID);

% launch Xrecon
unix('Xrecon -v ./')

% copy back
