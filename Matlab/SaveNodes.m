function [  ] = SaveNodes( )

    NET.addAssembly('System.Data');
    import System.Data.SqlClient.*;

    warning off;

    connDB = SqlConnection(['Data Source=128.196.93.131;'...
    'Initial Catalog=MoDOTRealtime;'...
    'User ID = shu; password = Sql.slu2012']);
    connDB.Open();
    
    load('Preload\\Links.mat');


    [Nodes] = Street_Direction(connDB, Links);

    
    connDB.Close();
    
    save('Preload\\Nodes.mat', 'Nodes');

end


function [nodes] = Street_Direction(connDB, Links)
    import System.Data.SqlClient.*;

    sql_select_command = sprintf(['SELECT [DetectorID], [StreetName] ,[Direction], [CrossStreet], [AbsLogmile], ((LEN([LaneConfigurationList])+1)/2) as LaneNumber '...
    'FROM [MoDOTRealtime].[dbo].[MetaData-Single] '...
    'where  LaneTypeList like ''%%ML%%''  '... 
    'order by [StreetName], [Direction]']);

    q = SqlCommand(sql_select_command, connDB);

    r = q.ExecuteReader();
    
    i = 1;
    
    ResultTable = cell(0, 6);
    
    while r.Read()
        ResultTable{i, 1} = char(r.GetString(0)); % detector ID
        ResultTable{i, 2} = char(r.GetString(1)); % streetName
        ResultTable{i, 3} = char(r.GetString(2)); % direction
        ResultTable{i, 4} = char(r.GetString(3)); % crossStreet
        ResultTable{i, 5} = r.GetDouble(4); % abslogmile
        ResultTable{i, 6} = r.GetInt32(5); % laneNumber
        i = i + 1;
    end
    
    r.Close();
    
    nodes = containers.Map;
    
    for i = 1: length(ResultTable)
        
        node.ID = ResultTable{i, 1};
        node.StreetName = ResultTable{i, 2};
        node.Direction = ResultTable{i, 3};
        node.CrossStreet = ResultTable{i, 4};
        
        ParenthesisIndex = strfind(node.CrossStreet, '(');
        if(ParenthesisIndex)
            node.CrossStreet_Short = node.CrossStreet(1: ParenthesisIndex-2);
        else
            node.CrossStreet_Short = node.CrossStreet;
        end
        
        node.AbsLogMile = ResultTable{i, 5};
        node.LaneNumber = ResultTable{i, 6};
        
        [PreviousNode, PreviousLink, NextNode, NextLink] = FindConsecutiveNode(node.ID, Links);
        
        node.PreviousNode = PreviousNode;
        node.PreviousLink = PreviousLink;
        node.NextNode = NextNode;
        node.NextLink = NextLink;
        
        nodes(ResultTable{i, 1}) = node;

    end
end

function [PreviousNode, PreviousLink, NextNode, NextLink] = FindConsecutiveNode(detectorID, Links)
    PreviousNode = cell(0, 1);
    NextNode = cell(0, 1);
    PreviousLink = zeros(0, 1);
    NextLink = zeros(0, 1);
    
    m = 1;
    n = 1;
    
    for i = 1: length(Links)
        if strcmp(Links{i, 2}, detectorID) % detectorID as from_node
            NextNode{m, 1} = Links{i, 3};
            NextLink(m, 1) = i;
            m = m + 1;
            
            %----duplication test---------
            if(m == 3)
                disp(detectorID);
            end
            %----duplication test end---------
        end
        
        if strcmp(Links{i, 3}, detectorID) % detectorID as to_node
            PreviousNode{n, 1} = Links{i, 2};
            PreviousLink{n, 1} = i;
            n = n + 1;
            
            %----duplication test---------
            if(n == 3)
                disp(detectorID);
            end
            %----duplication test end---------
        end
    end
    
    if isempty(PreviousNode)
        PreviousNode{1,1} = 'Start';
        PreviousLink(1,1) = -1;
    end
    
    if isempty(NextNode)
        NextNode{1,1} = 'End';
        NextLink(1,1) = -1;
    end
end

