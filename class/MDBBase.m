classdef MDBBase 

    properties (SetAccess = public)
        Name
        ID
        ExternalID
        Metadata
        DBConnection
    end
    
    methods(Access = protected)
        % Record retrieval. There are differences based upon connection
        % type
        function out = getRecordset(o, sSQL)
            oConn = getDBConnection(o);
            switch class(oConn)
                case 'database.ODBCConnection'
                    %out = exec(o.DBConnection,sSQL);
                    out = exec(oConn,sSQL);
                    out = fetch(out); 
                    out = out.Data; 
                otherwise 
                    %out = fetch(o.DBConnection,sSQL);
                    out = fetch(oConn,sSQL);
            end
        end
        
        % Credentials to connect to the database
        function oConn = getDBConnection(o)
            javaaddpath('../SQL/jtds-1.3.1.jar');            
            oConn = database('ModelDB2','HAMMER','Athens2016THoR!',...
                'net.sourceforge.jtds.jdbc.Driver',...
                'jdbc:jtds:sqlserver://euler.math.uga.edu/ModelDB2'); 
            %javaaddpath('../SQLServer/sqljdbc4.jar');            
            %oConn = database.ODBCConnection('ModelDB-Local','sa','00#200'); % ,'portnumber',1433
        end
    end    
end