function saveMat(fileName,par1,par2,par3,par4,par5,par6,par7,par8,par9,par10,par11,par12,par13,par14,par15,par16)
parNum = nargin-1;
savePar = ['''' fileName ''''];
for i = 1:parNum
    savePar = [savePar ',''par' num2str(i) ''''];
end
% until here savePar = [path,'par1','par2'...]

eval(['save(' savePar ')']);