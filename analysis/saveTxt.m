function saveTxt(fileName,txt)
if contains(fileName,'.txt')
    fid = fopen(fileName,'wt');
    fprint(fid,txt);
    fclose(fid);
else
    fileName = [fileName '.txt'];
    fid = fopen(fileName,'wt');
    fprintf(fid,txt);
    fclose(fid);
end