function varargout = GUI(varargin)


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)

    % Choose default command line output for GUI
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
    
    load('Detectors\\Freeways.mat');
    ListString  = cell(length(Freeways),1);

    for i = 1: length(ListString)
        StreetName = Freeways{i,1}.StreetName;
        Direction = Freeways{i,1}.Direction;

        ListString{i, 1} = sprintf('   %s   ---   %s', StreetName, Direction);
    end

    set(handles.Freeways, 'String', ListString);
    set(handles.Freeways, 'Value', 1);
    
    obj_Freeways = handles.Freeways;
    obj_StartDetector = handles.StartDetector;
    obj_EndDetector = handles.EndDetector;
    
    [SelectedFreeway] = ClickonListbox(obj_Freeways);
    FillDroplist(obj_StartDetector, SelectedFreeway.StreetName, SelectedFreeway.Direction);
    FillDroplist(obj_EndDetector, SelectedFreeway.StreetName, SelectedFreeway.Direction);
    
    
%     load('Preload\\Turning.mat');
%     ListString  = cell(length(Turning),1);
%     ListString(:,1) = Turning(:,1);
%     set(handles.Turning, 'String', ListString);
%     set(handles.Turning, 'Value', 1);
    

function [] = FillDroplist(handle, streetName, direction)
    DetectorFileName = sprintf('Detectors\\Detectors-%s-%s.mat', streetName, direction);
    load(DetectorFileName);
    LocationList = cell(0,1);

    for i = 1: length(Detectors)
        LocationList{i,1} = sprintf('   %s   -CrossStreet-   %s', Detectors{i,1}.ID, Detectors{i,1}.CrossStreet);
    end

    set(handle, 'String', LocationList);


% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
    
    load('Preload\\Nodes.mat');
    load('Preload\\Links.mat');
    NET.addAssembly('System.Data');
    import System.Data.SqlClient.*;
    
    %Date selection mode
    obj_txtConsecutiveDays = handles.txtConsecutiveDays;
    obj_rdbConsectuive = handles.rdbConsectuive;
    obj_rdbEveryWeekday = handles.rdbEveryWeekday;

    %Time period
    obj_txtStartTime = handles.txtStartTime;
    obj_txtStartHour = handles.txtStartHour;
    obj_txtEndHour = handles.txtEndHour;

    %Street & Direction
    obj_Freeway = handles.Freeways;
    
    %Detectors
    obj_StartDectecor = handles.StartDetector;
    obj_EndDectecor = handles.EndDetector;

    %Date selection mode
    val_txtConsecutiveDays = get(obj_txtConsecutiveDays, 'String');
    %disp(val_txtConsecutiveDays);
    val_rdbConsectuive = get(obj_rdbConsectuive, 'Value');
    %disp(val_rdbConsectuive);
    val_rdbEveryWeekday = get(obj_rdbEveryWeekday, 'Value');
    %disp(val_rdbEveryWeekday);

    %Time period
    val_txtStartTime = get(obj_txtStartTime, 'String');
    %disp(val_txtStartTime);
    val_txtStartHour = get(obj_txtStartHour, 'String');
    %disp(val_txtStartHour);
    val_txtEndHour = get(obj_txtEndHour, 'String');
    %disp(val_txtEndHour);

    txtMode = 1;
    if val_rdbConsectuive == 1
        txtMode = 1;
    else
        txtMode = 2;
    end

    SelectedFreeway = ClickonListbox(obj_Freeway);
    
    StartDetector = ExtractDetectorID(obj_StartDectecor);
    EndDetector = ExtractDetectorID(obj_EndDectecor);
    
    [ Chain ] = GUI_Translate2Links( StartDetector, EndDetector );
    if (isempty(Chain))
        disp('Links are empty!');
        return;
    end

    MainEntry(str2num(val_txtConsecutiveDays), txtMode, ...
    val_txtStartTime, str2num(val_txtStartHour), str2num(val_txtEndHour), Chain);

function [DetectorID] = ExtractDetectorID(handle)
    
    DroplistSelected = get(handle, 'Value');
    stringValue = get(handle, 'String');
    stringValue = stringValue{DroplistSelected, 1};
    Index = strfind(stringValue, '-CrossStreet-');
    DetectorID = stringValue(4:Index-4);


function [SelectedFreeway] = ClickonListbox(handle)
    ListboxSelected = get(handle,'Value');
    Freeways = get(handle,'String');
    String_Selected = Freeways{ListboxSelected, 1};
    %String_Selected = String_Selected{1,1};

    DashIndex = strfind(String_Selected, '---');

    StreetName = String_Selected(4:DashIndex-4);
    Direction = String_Selected(DashIndex+6: length(String_Selected));
    
    SelectedFreeway.StreetName = StreetName;
    SelectedFreeway.Direction = Direction;
    
% function [Chain] = ClickonTurningList(handle)
%     load('Preload\\Turning.mat');
%     ListboxSelected = get(handle,'Value');
%     Chain = Turning{ListboxSelected, 2};
    

% --- Executes when selected object is changed in btnGroupDateSelection.
function btnGroupDateSelection_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in btnGroupDateSelection 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
    set(eventdata.NewValue, 'Value', 1);
    set(eventdata.OldValue, 'Value', 0);


% --- Executes when selected object is changed in uipanel4.
function uipanel4_SelectionChangeFcn(hObject, eventdata, handles)
    set(eventdata.NewValue, 'Value', 1);
    set(eventdata.OldValue, 'Value', 0);


% --- Executes on selection change in Freeways.
function Freeways_Callback(hObject, eventdata, handles)

    obj_Freeways = handles.Freeways;
    obj_StartDetector = handles.StartDetector;
    obj_EndDetector = handles.EndDetector;
    
    [SelectedFreeway] = ClickonListbox(obj_Freeways);
    FillDroplist(obj_StartDetector, SelectedFreeway.StreetName, SelectedFreeway.Direction);
    FillDroplist(obj_EndDetector, SelectedFreeway.StreetName, SelectedFreeway.Direction);

% Hints: contents = cellstr(get(hObject,'String')) returns Freeways contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Freeways



% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in EndDetector.
function EndDetector_Callback(hObject, eventdata, handles)
% hObject    handle to EndDetector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EndDetector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EndDetector


% --- Executes during object creation, after setting all properties.
function Freeways_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Freeways (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in StartDetector.
function StartDetector_Callback(hObject, eventdata, handles)
% hObject    handle to StartDetector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StartDetector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StartDetector


% --- Executes during object creation, after setting all properties.
function StartDetector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartDetector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function EndDetector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndDetector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Turning.
% function Turning_Callback(hObject, eventdata, handles)
% hObject    handle to Turning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Turning contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Turning


% --- Executes during object creation, after setting all properties.
% function Turning_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to Turning (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: listbox controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --- Executes on button press in btnTurning.
% function btnTurning_Callback(hObject, eventdata, handles)
%     load('Preload\\Nodes.mat');
%     load('Preload\\Links.mat');
%     NET.addAssembly('System.Data');
%     import System.Data.SqlClient.*;
%     
%     %Date selection mode
%     obj_txtConsecutiveDays = handles.txtConsecutiveDays;
%     obj_rdbConsectuive = handles.rdbConsectuive;
%     obj_rdbEveryWeekday = handles.rdbEveryWeekday;
% 
%     %Time period
%     obj_txtStartTime = handles.txtStartTime;
%     obj_txtStartHour = handles.txtStartHour;
%     obj_txtEndHour = handles.txtEndHour;
% 
%     %Date selection mode
%     val_txtConsecutiveDays = get(obj_txtConsecutiveDays, 'String');
%     val_rdbConsectuive = get(obj_rdbConsectuive, 'Value');
%     val_rdbEveryWeekday = get(obj_rdbEveryWeekday, 'Value');
%     
%     %Time period values
%     val_txtStartTime = get(obj_txtStartTime, 'String');
%     val_txtStartHour = get(obj_txtStartHour, 'String');
%     val_txtEndHour = get(obj_txtEndHour, 'String');
% 
%     txtMode = 1;
%     if val_rdbConsectuive == 1
%         txtMode = 1;
%     else
%         txtMode = 2;
%     end
%     
%     [Chain] = ClickonTurningList(handles.Turning);
%     
%     if (isempty(Chain))
%         disp('Links are empty!');
%         return;
%     end
% 
%     MainEntry(str2num(val_txtConsecutiveDays), txtMode, ...
%     val_txtStartTime, str2num(val_txtStartHour), str2num(val_txtEndHour), Chain);
