classdef MDBData < MDBBase
    properties (SetAccess = public)
        DataType % String, e.g. 'FXGN'
        VarNames
        DataAssociations % cell of viable unique combination of metadata
        ExperimentID   
        Table
    end
     
     methods
         function o = MDBData(oSubject,cDataType)
             %o.DBConnection = oSubject.DBConnection;
             o.ID = oSubject.ID; 
             o.Name = oSubject.Name; 
             o.ExperimentID = oSubject.ExperimentID;
             o.DataType = cDataType; 
             cTemp = getDataAssociations(o); 
             idx = strcmp(cTemp(:,3),'NAME');
             o.VarNames = cTemp(idx==1,:);
             o.DataAssociations = cTemp(idx==0,:);             
         end

         function o = getSparseTimeSeries(o,cMetaData,n)
           switch n
                case 1
                   Value = 'am_value1'; 
                case 2
                   Value = 'am_value2'; 
                case 3
                   Value = 'am_value3'; 
                case 4
                   Value = 'am_value4'; 
            end
           cMetaData = cMetaData(:,1:3); 
           cMetaData = vertcat(o.DataType,cMetaData);
           numMetaData = size(cMetaData,1);

           sMetaData =[];
           for i = 1:numMetaData 
               if i > 1 
                   sMetaData = [sMetaData,' or ','(id_metadata = ',...
                       num2str(cMetaData{i,1}),')'];
               else
                   sMetaData = ['(id_metadata = ',...
                       num2str(cMetaData{i,1}),')'];
               end
           end
            

           sSQL = [
               'EXEC dbo.getTimeSeriesDates @SubjectID = ''',...
               num2str(o.ID),''', @NumParameters = ''',...
               num2str(numMetaData),''', @Parameters = ''',...
               sMetaData,'''',',@ExperimentID = ',num2str(o.ExperimentID)];
           cDates = getRecordset(o,sSQL); %fetch(getDBConnection(o),sSQL);
           
           if isempty(cDates) == 1 
                error('Error. Impossible MetaData Combination')
           end
           
           sDates = [];
           for i = 1:size(cDates,1)
               if i > 1
                   sDates = [sDates ',[' cDates{i} ']'];
               else
                   sDates = [sDates '[' cDates{i} ']'];
               end
           end
           sSQL = [
               'EXEC dbo.getTimeSeries @SubjectID = N''',...
               num2str(o.ID),''', @NumParameters = N''',...
               num2str(numMetaData),''', @Parameters = N''',...
               sMetaData,''',@Dates = N''',...
               sDates,''',@Value = N''',...
               Value,'''',',@ExperimentID = ',num2str(o.ExperimentID)];
           cData = getRecordset(o,sSQL); %fetch(getDBConnection(o),sSQL);
           
           T.Data = cell2mat(cData(:,2:end));
           T.ColNames = cDates;
           T.RowNames = cData(:,1);
           
           % Now convert the data into a table, which is substantially
           % friendlier to use. 
           s = 'table(T.RowNames'; 
           sComma=',';  
           for i=1:size(T.Data,2)
               s = [s sComma 'T.Data(:,' num2str(i) ')']; 
           end
           s = [s ',''VariableNames'',[''Variable''; cellfun(@(x)datestr(x,''mmm_dd_yyyy''),T.ColNames,''UniformOutput'',false)]'')'];
           eval(['T.Data=' s]);
           
           o.Table  = T; 
         end
         
        function [cData] = getList(o)
            numMetaData = size(o.Metadata,1);
           sMetaData =[];
           for i = 1:numMetaData 
               if i > 1 
                   sMetaData = [sMetaData,' or ','(id_metadata = ',...
                       num2str(o.Metadata{i,1}),')'];
               else
                   sMetaData = ['(id_metadata = ',...
                       num2str(o.Metadata{i,1}),')'];
               end
           end           
           sSQL = ['EXEC dbo.getList @SubjectID = N''',...
               num2str(o.ID),''', @NumParameters = N''',...
               num2str(numMetaData),''', @Parameters = N''',...
               sMetaData,'''',',@Value = N''',...
               o.Value,'''',',@ExperimentID = ',num2str(o.ExperimentID)];
           cData = getRecordset(o,sSQL); %fetch(getDBConnection(o),sSQL);
        end
        
        function [cData] = getDataAssociations(o)
            sSQL = ['exec dbo.getDataTypeAssociation @SubjectID = ',num2str(o.ID),...
                ',@ExperimentID = ', num2str(o.ExperimentID),',@DataTypeID = ',...
                num2str(o.DataType{1})];
            cData = getRecordset(o,sSQL); %fetch(getDBConnection(o),sSQL);
        end
     end
end