classdef MDBSubject < MDBBase 
    %------------------------------
    properties (SetAccess = public)
        ExperimentID
        Data % container having a hash and a Data object
        DataTypes 
    end
    %------------------------------
    methods
        % Constructor class
        function o = MDBSubject(nSubjectID,oExp)
            %o.DBConnection = oExp.DBConnection;
            o.ID = nSubjectID; 
            cData = getSubject(o,oExp.ID); 
            o.Name = cData{3};
            o.ExternalID = cData{3};
            o.ExperimentID = oExp.ID;
            o = getMetadata(o);
            o.DataTypes = getDataTypes(o);
            o.Data = containers.Map; 
            for i = 1:size(o.DataTypes,1)
                o.Data(o.DataTypes{i,2}) = MDBData(o,o.DataTypes(i,:));
            end
        end
        %------------------------------
        % Load metadata as an independent task
        
    end
    
    methods(Access = private)
         
        function o = getMetadata(o)
           sSQL = ['exec getSubjectMetaData ' '@SubjectID = ',num2str(o.ID),...
               ',@ExperimentID = ',num2str(o.ExperimentID)];
           temp = getRecordset(o,sSQL); %fetch(getDBConnection(o),sSQL);
           idx = strcmp(temp(:,3),'NAME'); 
           temp = temp(idx ==0,:); 
           o.Metadata = temp; 
        end
       
        function cData = getSubject(o,nExpID)
            sSQL = ['exec dbo.getSubject @SubjectID = N''',num2str(o.ID),...
                '''',',@ExperimentID = ''',num2str(nExpID),''''];
            cData = getRecordset(o,sSQL); %fetch(getDBConnection(o),sSQL);
        end
        
        function cData = getDataTypes(o)
            sSQL = ['exec dbo.getDataType @SubjectID = ',num2str(o.ID),...
               ',@ExperimentID = ',num2str(o.ExperimentID)];
           cData = getRecordset(o,sSQL); %fetch(getDBConnection(o),sSQL);
        end
    end
end
      