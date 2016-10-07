sExpName = 'E04';
sFileName = [sExpName '.mat'];
if exist(sFileName,'file') 
    load(sFileName);
else
    oExperiment = MDBExperiment(sExpName); 
    save(sFileName, 'oExperiment');
end
oExplorer = MDBAnalysis();
cMetaData = oExperiment.Subject{1}.Data('FXGN').DataAssociations(1,1:3);
n = 1;
vars = whos('-file',sFileName);
if ismember('oExplorer', {vars.name})
    load(sFileName, 'oExplorer');
else
    for i =1:4
        x = oExperiment.Subject{i};
        T = x.Data('FXGN').getSparseTimeSeries(cMetaData,n);
        oExplorer.Data{i} = T; 
    end
    save(sFileName, 'oExplorer', '-append');
end
mSevere = [112 125]; % IDs mapping MDBSubject.ID
mMild = [130 135];
%mLethal = [156];
cGroups = {mSevere, mMild};
cVariables = {'LAMA1','BRCA1'};
oExplorer.plotTimeSeries(cGroups,cVariables); 


