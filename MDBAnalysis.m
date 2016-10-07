classdef MDBAnalysis
    properties
        Data % Cell array of tables where each element maps MBDData.Data
    end
    
    methods
        function out = plotTimeSeries(o,cGroups,cVariables)
            numVar = length(cVariables); 
            for i = 1:length(o.Data)
                mIDs(i) = o.Data{i}.ID; 
            end 
            figure(1);
            for i = 1:length(cVariables) 
                
                subplot(1,numVar,i) 
                hold on 
                for j = 1:length(cGroups) 
    
                    for k = 1:length(cGroups{j})
                        x = [];
                        y = [];
                        idx = find(mIDs == cGroups{j}(k));
                        
                        idx2 = find(strcmp(o.Data{idx}.Table.RowNames,cVariables{i})); 
                        for m = 1:length(o.Data{idx}.Table.ColNames)
                            x = [x datenum(o.Data{idx}.Table.ColNames(m))];
                        end
                        y = table2array(o.Data{idx}.Table.Data(idx2,2:end));
                        [a b] = sort(x); 
                        
                        plot(x(b),y(b),'o-');
                    end
                end
                title(cVariables{i})
                hold off 
            end
        end
    end
    
end

