function [  ] = SaveLinks(  )

    NET.addAssembly('System.Data');
    import System.Data.SqlClient.*;

    warning off;

    connDB = SqlConnection(['Data Source=128.196.93.131;'...
    'Initial Catalog=MoDOTRealtime;'...
    'User ID = shu; password = Sql.slu2012']);
    connDB.Open();
    
    load('Preload\\Freeways.mat');
    
    Links = cell(0,6);
    
    for i = 1: length(Freeways)
        [links_eachDirection] = Street_Direction(connDB, Freeways{i, 1}.StreetName, Freeways{i, 1}.Direction);
        
        Links = [Links; links_eachDirection];
    end
    
    connDB.Close();
    
    for i =1: length(Links)
        Links{i, 1} = i;
    end
    
    save('Preload\\Links.mat', 'Links');

end


function [links] = Street_Direction(connDB, streetName, direction)
    import System.Data.SqlClient.*;

    OrderBy = 'asc';
    if strcmp(direction, 'east') || strcmp(direction, 'north') || strcmp(direction, 'East') || strcmp(direction, 'North')
        OrderBy = 'asc';
    else
        OrderBy = 'desc';
    end
    sql_select_command = sprintf(['SELECT [DetectorID], [AbsLogmile]'...
    'FROM [MoDOTRealtime].[dbo].[MetaData-Single] '...
    'where  StreetName = ''%s'' and Direction = ''%s'' and LaneTypeList like ''%%ML%%''  '... 
    'order by [AbsLogmile] %s'], streetName, direction, OrderBy);

    q = SqlCommand(sql_select_command, connDB);

    r = q.ExecuteReader();
    
    i = 1;
    
    %links = cell(0, 2);
    ResultTable = cell(0, 2);
    
    while r.Read()
        ResultTable{i, 1} = char(r.GetString(0));
        ResultTable{i, 2} = r.GetDouble(1);
        i = i + 1;
    end
    
    r.Close();
    
    links = cell(length(ResultTable) - 1, 6);
    
    for i = 1: size(links, 1)
        links{i, 1} = 0; %make it as default value here, will change it later
        links{i, 2} = ResultTable{i, 1}; % from_node
        links{i, 3} = ResultTable{i + 1, 1};% to_node
        links{i, 4} = abs(ResultTable{i + 1, 2} - ResultTable{i, 2}); %link length
        links{i, 5} = 'link'; % type
        links{i, 6} = 1; %factor
    end
end

