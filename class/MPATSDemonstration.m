if (exist('E04SevereMild.mat','file') == 0)

    oExp = clsExperiment('get','E04');
    cMetaData = oExp.cExpMetaData([40 47],:);
    mSevere = [1 6]; 
    mMild = [2 7]; 

    for i = 1:2
        cSevereTimeSeries{i} = clsDataPrimitive('get',oExp.cSubjects{mSevere(i)},'TimeSeries',cMetaData,'am_value1',oExp.sExpName);
        cMildTimeSeries{i} = clsDataPrimitive('get',oExp.cSubjects{mMild(i)},'TimeSeries',cMetaData,'am_value1',oExp.sExpName);

    end

    save('E04SevereMild.mat','cSevereTimeSeries','cMildTimeSeries');
    else 

        load('E04SevereMild.mat'); 
end

%%%%%%%%%%%%%%%%Check for Genes That are detected across all Subject and
%%%%%%%%%%%%%%%%Time points %%%%%%%%%%%%%
for i = 1:2
    cGenes{i} = cSevereTimeSeries{i}.cData(:,1);
    cGenes{i+2} = cMildTimeSeries{i}.cData(:,1); 
end

cIntersectGenes = intersect(cGenes{1},cGenes{2});
for i = 3:4
    cIntersectGenes = intersect(cIntersectGenes,cGenes{i});
end

cIdx = {};
cTimeSeries = {}; 

for i = 1:4 
    [a b c] = intersect(cIntersectGenes,cGenes{i});
    if i < 3
        cTimeSeries{i} = cell2mat(cSevereTimeSeries{i}.cData(c,2:end));
    else
        cTimeSeries{i} = cell2mat(cMildTimeSeries{i-2}.cData(c,2:end));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%Hodrick Prescott Filter%%%%%%%%%%%%%%%%%%%%%
lambda = 30; 
numP = 30;

cTimePoints = {}; 
for i = 1:2
    cTimePoints{i} = datenum(cSevereTimeSeries{i}.cDates);
    cTimePoints{i+2} = datenum(cMildTimeSeries{i}.cDates);
end

cHPTS = {}; 

for i = 1:4 
    x = cTimePoints{i};
    x = x - min(x); 
    cHPTS{i} = funHPTimeSeriesPL(cTimeSeries{i},lambda,x',numP);
end
%%%%%%%%%%%%%%%%%%%%%Select Top 100 Gene%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:4 
    cHPTS{i} = cHPTS{i}(1:100,:);
end

cIntersectGenes = cIntersectGenes(1:100); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Run MPATS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mTemporalRelation = [];

for i = 1:4
    cTempDist = pdist(cHPTS{i},'cityblock'); 
    TemporalRelation(i,:) = cTempDist';
end

Pvalue = zeros(1,size(TemporalRelation,2));

parfor i = 1:size(TemporalRelation,2)
    temp = TemporalRelation(:,i);
    [h p] = ttest2(temp(1:2),temp(3:4),'Vartype','unequal');
    Pvalue(i) = p;
                  
end


adjSigPidx = zeros(1,length(Pvalue)); 

adjSigPidx(Pvalue<0.05) = 1;


adjAll = adjSigPidx == 1; 

mAdjAll = squareform(adjAll);

%%%%%%%%%%%%%%%%%%%%%%%Display Result%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[a b] = sort(sum(mAdjAll),'descend');
TopGene = cIntersectGenes(b); 

for i = 1:size(TopGene,1)
     display([TopGene{i} '          ' num2str(a(i))]);
end

%%%%%%%%%%%%%%%%%%%%%%%Plot Top 2 Time Series %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)
subplot(1,2,1)
plot(cHPTS{1}(b(1),:),'ro-')
hold on 
plot(cHPTS{2}(b(1),:),'rx-')
plot(cHPTS{3}(b(1),:),'bo-')
plot(cHPTS{4}(b(1),:),'bx-')
title(TopGene{1})
ylabel('Normalized Expression');
xlabel('Time'); 
legend({'Severe','Severe','Mild','Mild'});
subplot(1,2,2)
plot(cHPTS{1}(b(2),:),'ro-')
hold on 
plot(cHPTS{2}(b(2),:),'rx-')
plot(cHPTS{3}(b(2),:),'bo-')
plot(cHPTS{4}(b(2),:),'bx-')
title(TopGene{2})
ylabel('Normalized Expression');
xlabel('Time'); 
legend({'Severe','Severe','Mild','Mild'});
