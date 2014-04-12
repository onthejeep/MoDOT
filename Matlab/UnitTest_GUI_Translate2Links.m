
% startNode = 'MI064W000.7U';
% endNode = 'MI064W040.4U';


% startNode = 'MI064W040.4U';
% % endNode = 'MI064W000.7U';


% startNode = 'MI064W002.0U';
% endNode = 'MI064W029.7U';


startNode = 'MI064W029.7U';
endNode = 'MI064W029.7U';

[ chain ] = GUI_Translate2Links( startNode, endNode );

if (isempty(chain))
    disp('XXXXXXX');
end

disp(chain);