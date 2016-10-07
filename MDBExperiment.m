classdef MDBExperiment < MDBBase
    %------------------------------
    properties (SetAccess = public)
        Subject
    end
    %------------------------------
    methods 
        % Constructor class
        function o = MDBExperiment(s)
            %o.DBConnection = getDBConnection(o);
            % Create instance and assign external ID
            o.ExternalID = s;
            o.Name = s;
            % getRecordset internal ID and load it in the class
            o.ID = cell2mat(getExperimentID(o));
            % getRecordset subjects per experiment
            cSubjectIDs = getSubjectIDs(o); 
            for i = 1:length(cSubjectIDs)
                o.Subject{i} = MDBSubject(cSubjectIDs{i},o);
            end
        end           
        %------------------------------
        %get metadata as an independent task
        
        function o = getMetadata(o)
           sSQL = ['exec getExperimentMetaData ' num2str(o.ID)];
           temp = getRecordset(o,sSQL); %fetch(getDBConnection(o),sSQL);
           idx = strcmp(temp(:,3),'NAME'); 
           temp = temp(idx ==0,:); 
           o.Metadata = temp; 
        end
        %get experiment id 
        
    end
    
    methods(Access = private)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function cData = getExperimentID(o)
            sSQL = ['exec dbo.getExperiment @Experiment = ''',o.Name,''''];
            cData = getRecordset(o,sSQL);
        end
        %get subjectids 
        function cData = getSubjectIDs(o)
            sSQL = ['exec dbo.getSubjectIDs @ExperimentID = ''',num2str(o.ID),''''];
            cData = getRecordset(o,sSQL);
        end
    end
        
end