function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 23-Feb-2016 21:47:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

handles.constants.displayMode.layers = 100;
handles.constants.displayMode.backprojection = 101;
if isdeployed
    handles.constants.lytroSettingsFile = fullfile(ctfroot, 'lytro_settings.mat');
else
    handles.constants.lytroSettingsFile = './lytro_settings.mat';
end

handles.data = struct;
handles.data.editor = LightFieldEditor();
handles.data.animationState = 0;
handles.data.lightfield = [];
handles.data.attenuator = [];
handles.data.evaluation = [];
handles.data.axesLayersDisplayMode = handles.constants.displayMode.layers;
handles.data.axesLayersPage = 1;
handles.data.backprojection = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editPath_Callback(hObject, eventdata, handles)
% hObject    handle to editPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPath as text
%        str2double(get(hObject,'String')) returns contents of editPath as a double


% --- Executes during object creation, after setting all properties.
function editPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupProjectionType.
function popupProjectionType_Callback(hObject, eventdata, handles)
% hObject    handle to popupProjectionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupProjectionType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupProjectionType

switch get(hObject, 'Value')
    case 1 % Perspective
        set([handles.editFOVY, handles.editFOVX], 'Enable', 'Off');
        set([handles.editBaselineY, handles.editBaselineX, handles.editCameraPlaneZ], 'Enable', 'On');
        set(handles.checkboxTiling, 'Value', 1);
        set([handles.editTileResY, handles.editTileResX, handles.sliderOverlap, handles.textOverlap, ...
             handles.checkboxTiling], 'Enable', 'On'); 
    case 2 % Oblique
        set([handles.editFOVY, handles.editFOVX], 'Enable', 'On');
        set([handles.editBaselineY, handles.editBaselineX, handles.editCameraPlaneZ], 'Enable', 'Off');
        % Tiling not supported for oblique projection
        set(handles.checkboxTiling, 'Value', 0);
        set([handles.editTileResY, handles.editTileResX, handles.sliderOverlap, handles.textOverlap, ...
             handles.checkboxTiling], 'Enable', 'Off'); 
end


% --- Executes during object creation, after setting all properties.
function popupProjectionType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupProjectionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnBrowse.
function btnBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_clear_warning(handles.textImportInfo);

switch get(handles.popupDataType, 'Value')
    case 1 % Image folder
        gui_browse_for_image_folder(handles);
    case 2 % MATLAB file
        gui_browse_for_matlab_file(handles);
    case 3 % Lytro file
        gui_browse_for_lytro_file(handles);
end


function editAngularResY_Callback(hObject, eventdata, handles)
% hObject    handle to editAngularResY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAngularResY as text
%        str2double(get(hObject,'String')) returns contents of editAngularResY as a double

gui_clear_warning(handles.textImportInfo);
val = str2double(get(hObject, 'String'));

if isnan(val)
%     gui_warning(handles.textImportInfo, 'Invalid angular resolution');
    return;
end

% Update slice indices
set(handles.editAngularIndFromY, 'String', '1');
set(handles.editAngularIndStepY, 'String', '1');
set(handles.editAngularIndToY, 'String', val);


% --- Executes during object creation, after setting all properties.
function editAngularResY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAngularResY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAngularResX_Callback(hObject, eventdata, handles)
% hObject    handle to editAngularResX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAngularResX as text
%        str2double(get(hObject,'String')) returns contents of editAngularResX as a double

gui_clear_warning(handles.textImportInfo);
val = str2double(get(hObject, 'String'));

if isnan(val)
%     gui_warning(handles.textImportInfo, 'Invalid angular resolution');
    return;
end

% Update slice indices
set(handles.editAngularIndFromX, 'String', '1');
set(handles.editAngularIndStepX, 'String', '1');
set(handles.editAngularIndToX, 'String', val);

% --- Executes during object creation, after setting all properties.
function editAngularResX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAngularResX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkboxInvY.
function checkboxInvY_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxInvY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxInvY

from = get(handles.editAngularIndFromY, 'String');
stepval = str2double(get(handles.editAngularIndStepY, 'String'));
to = get(handles.editAngularIndToY, 'String');
set(handles.editAngularIndFromY, 'String', to);
set(handles.editAngularIndStepY, 'String', -stepval);
set(handles.editAngularIndToY, 'String', from);


% --- Executes on button press in checkboxInvX.
function checkboxInvX_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxInvX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxInvX

from = get(handles.editAngularIndFromX, 'String');
stepval = str2double(get(handles.editAngularIndStepX, 'String'));
to = get(handles.editAngularIndToX, 'String');
set(handles.editAngularIndFromX, 'String', to);
set(handles.editAngularIndStepX, 'String', -stepval);
set(handles.editAngularIndToX, 'String', from);


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.editor = LightFieldEditor();
gui_clear_warning(handles.textImportInfo);

switch get(handles.popupDataType, 'Value')
    case 1 % Folder with images
        gui_load_light_field_from_image_collection(hObject, handles);
    case 2 % MATLAB file
        gui_warning(handles.textImportInfo, 'Not yet implemented');
    case 3 % Lytro file
        gui_load_light_field_from_lytro_file(hObject, handles);
end

set(hObject, 'Enable', 'On');


% --- Executes on slider movement.
function sliderSpatialScale_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSpatialScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

s = sprintf('%.2f', get(hObject, 'Value'));
set(handles.editSpatialScale, 'String', s);


% --- Executes during object creation, after setting all properties.
function sliderSpatialScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSpatialScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

minScale = 0.1;
maxScale = 1;
sliderStep = [0.1, 0.1] / (maxScale - minScale); % major and minor steps of 0.1
set(hObject, 'Min', minScale);
set(hObject, 'Max', maxScale);
set(hObject, 'SliderStep', sliderStep);
set(hObject, 'Value', 1);


% --- Executes on selection change in popupDataType.
function popupDataType_Callback(hObject, eventdata, handles)
% hObject    handle to popupDataType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupDataType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupDataType

switch get(hObject, 'Value')
    case 1 % Folder with images
        gui_enable_all_import_controls(handles);
        set(handles.popupProjectionType, 'Value', 1);
        set(handles.editFOVY, 'Enable', 'off');
        set(handles.editFOVX, 'Enable', 'off');
        set(handles.checkboxInvY, 'Value', 0);
        set(handles.checkboxInvX, 'Value', 0);
        set(handles.popupFileType, 'Value', 1);
        set(handles.sliderSpatialScale, 'Value', 1);
        set(handles.editBaselineY, 'String', 1);
        set(handles.editBaselineX, 'String', 1);
        set(handles.editCameraPlaneZ, 'String', 1);
        set(handles.editSensorSizeY, 'String', 1);
        set(handles.editSensorSizeX, 'String', 1);
        set(handles.editSensorPlaneZ, 'String', 0);
        set(handles.editPath, 'String', '');
    case 2 % MATLAB file
        gui_enable_all_import_controls(handles);
        set(handles.checkboxInvY, 'Value', 0);
        set(handles.checkboxInvX, 'Value', 0);
        set(handles.editAngularResY, 'Enable', 'off');
        set(handles.editAngularResX, 'Enable', 'off');
        set(handles.editFOVY, 'Enable', 'off');
        set(handles.editFOVX, 'Enable', 'off');
        set(handles.popupProjectionType, 'Value', 1);
        set(handles.popupFileType, 'Enable', 'off');
        set(handles.popupProjectionType, 'Enable', 'off');
    case 3 % Lytro file
        gui_enable_all_import_controls(handles);
        set(handles.popupProjectionType, 'Enable', 'off');
        set(handles.editFOVY, 'Enable', 'off');
        set(handles.editFOVX, 'Enable', 'off');
        set(handles.checkboxInvY, 'Value', 0);
        set(handles.checkboxInvX, 'Value', 0);
        set(handles.popupFileType, 'Enable', 'off');
        set(handles.sliderSpatialScale, 'Value', 1);
        set(handles.editBaselineY, 'String', 1);
        set(handles.editBaselineX, 'String', 1);
        set(handles.editCameraPlaneZ, 'String', 1);
        set(handles.editSensorSizeY, 'String', 1);
        set(handles.editSensorSizeX, 'String', 1);
        set(handles.editSensorPlaneZ, 'String', 0);
        set(handles.editPath, 'String', '');
        set(handles.editAngularResY, 'Enable', 'off');
        set(handles.editAngularResX, 'Enable', 'off');
        set(handles.checkboxInvY, 'Enable', 'off');
        set(handles.checkboxInvX, 'Enable', 'off');
end


% --- Executes during object creation, after setting all properties.
function popupDataType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupDataType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderAngularScale_Callback(hObject, eventdata, handles)
% hObject    handle to sliderAngularScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

s = sprintf('%.2f', get(hObject, 'Value'));
set(handles.editAngularScale, 'String', s);


% --- Executes during object creation, after setting all properties.
function sliderAngularScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderAngularScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editFOVY_Callback(hObject, eventdata, handles)
% hObject    handle to editFOVY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFOVY as text
%        str2double(get(hObject,'String')) returns contents of editFOVY as a double

gui_clear_warning(handles.textImportInfo);

% if isnan(str2double(get(hObject, 'String')))
%     gui_warning(handles.textImportInfo, 'Invalid field of view');
% end


% --- Executes during object creation, after setting all properties.
function editFOVY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFOVY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFOVX_Callback(hObject, eventdata, handles)
% hObject    handle to editFOVX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFOVX as text
%        str2double(get(hObject,'String')) returns contents of editFOVX as a double

gui_clear_warning(handles.textImportInfo);

% if isnan(str2double(get(hObject, 'String')))
%     gui_warning(handles.textImportInfo, 'Invalid field of view');
% end

% --- Executes during object creation, after setting all properties.
function editFOVX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFOVX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupFileType.
function popupFileType_Callback(hObject, eventdata, handles)
% hObject    handle to popupFileType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupFileType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupFileType


% --- Executes during object creation, after setting all properties.
function popupFileType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupFileType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBaselineY_Callback(hObject, eventdata, handles)
% hObject    handle to editBaselineY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBaselineY as text
%        str2double(get(hObject,'String')) returns contents of editBaselineY as a double

gui_clear_warning(handles.textImportInfo);

% if isnan(str2double(get(hObject, 'String')))
%     gui_warning(handles.textImportInfo, 'Invalid baseline');
% end


% --- Executes during object creation, after setting all properties.
function editBaselineY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBaselineY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBaselineX_Callback(hObject, eventdata, handles)
% hObject    handle to editBaselineX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBaselineX as text
%        str2double(get(hObject,'String')) returns contents of editBaselineX as a double

gui_clear_warning(handles.textImportInfo);

% if isnan(str2double(get(hObject, 'String')))
%     gui_warning(handles.textImportInfo, 'Invalid baseline');
% end


% --- Executes during object creation, after setting all properties.
function editBaselineX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBaselineX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editCameraPlaneZ_Callback(hObject, eventdata, handles)
% hObject    handle to editCameraPlaneZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCameraPlaneZ as text
%        str2double(get(hObject,'String')) returns contents of editCameraPlaneZ as a double

gui_clear_warning(handles.textImportInfo);

% if isnan(str2double(get(hObject, 'String')))
%     gui_warning(handles.textImportInfo, 'Invalid Z value for camera plane');
% end


% --- Executes during object creation, after setting all properties.
function editCameraPlaneZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCameraPlaneZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editSpatialScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpatialScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function editAngularScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAngularScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function editSensorSizeY_Callback(hObject, eventdata, handles)
% hObject    handle to editSensorSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSensorSizeY as text
%        str2double(get(hObject,'String')) returns contents of editSensorSizeY as a double

gui_clear_warning(handles.textImportInfo);

% if isnan(str2double(get(hObject, 'String')))
%     gui_warning(handles.textImportInfo, 'Invalid size for image plane');
%     return;
% end


% --- Executes during object creation, after setting all properties.
function editSensorSizeY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSensorSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSensorSizeX_Callback(hObject, eventdata, handles)
% hObject    handle to editSensorSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSensorSizeX as text
%        str2double(get(hObject,'String')) returns contents of editSensorSizeX as a double

gui_clear_warning(handles.textImportInfo);

% if isnan(str2double(get(hObject, 'String')))
%     gui_warning(handles.textImportInfo, 'Invalid size for image plane');
%     return;
% end


% --- Executes during object creation, after setting all properties.
function editSensorSizeX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSensorSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSensorPlaneZ_Callback(hObject, eventdata, handles)
% hObject    handle to editSensorPlaneZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSensorPlaneZ as text
%        str2double(get(hObject,'String')) returns contents of editSensorPlaneZ as a double

gui_clear_warning(handles.textImportInfo);

% if isnan(str2double(get(hObject, 'String')))
%     gui_warning(handles.textImportInfo, 'Invalid Z value for image plane');
% end


% --- Executes during object creation, after setting all properties.
function editSensorPlaneZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSensorPlaneZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnAnimate.
function btnAnimate_Callback(hObject, eventdata, handles)
% hObject    handle to btnAnimate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(~handles.data.animationState)
    handles.data.animationState = 1;
    set(handles.btnAnimate, 'Enable', 'off');
    drawnow;
    gui_animateLightField( handles.data.lightfield.lightFieldData, handles );
    handles.data.animationState = 0;
    set(handles.btnAnimate, 'Enable', 'on');
end


% --- Executes during object creation, after setting all properties.
function btnAnimate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btnAnimate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function editAngularIndFromY_Callback(hObject, eventdata, handles)
% hObject    handle to editAngularIndFromY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAngularIndFromY as text
%        str2double(get(hObject,'String')) returns contents of editAngularIndFromY as a double


% --- Executes during object creation, after setting all properties.
function editAngularIndFromY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAngularIndFromY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAngularIndStepY_Callback(hObject, eventdata, handles)
% hObject    handle to editAngularIndStepY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAngularIndStepY as text
%        str2double(get(hObject,'String')) returns contents of editAngularIndStepY as a double


% --- Executes during object creation, after setting all properties.
function editAngularIndStepY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAngularIndStepY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAngularIndToY_Callback(hObject, eventdata, handles)
% hObject    handle to editAngularIndToY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAngularIndToY as text
%        str2double(get(hObject,'String')) returns contents of editAngularIndToY as a double


% --- Executes during object creation, after setting all properties.
function editAngularIndToY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAngularIndToY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAngularIndFromX_Callback(hObject, eventdata, handles)
% hObject    handle to editAngularIndFromX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAngularIndFromX as text
%        str2double(get(hObject,'String')) returns contents of editAngularIndFromX as a double


% --- Executes during object creation, after setting all properties.
function editAngularIndFromX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAngularIndFromX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAngularIndStepX_Callback(hObject, eventdata, handles)
% hObject    handle to editAngularIndStepX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAngularIndStepX as text
%        str2double(get(hObject,'String')) returns contents of editAngularIndStepX as a double


% --- Executes during object creation, after setting all properties.
function editAngularIndStepX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAngularIndStepX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAngularIndToX_Callback(hObject, eventdata, handles)
% hObject    handle to editAngularIndToX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAngularIndToX as text
%        str2double(get(hObject,'String')) returns contents of editAngularIndToX as a double


% --- Executes during object creation, after setting all properties.
function editAngularIndToX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAngularIndToX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderLayers_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = round(get(hObject, 'Value'));
set(handles.textLayers, 'String', val);
set(hObject, 'Value', val);

thickness = str2double(get(handles.editThickness, 'String'));
n = val;
spacing = thickness / (n - 1);

set(handles.editSpacing, 'String', spacing);

% --- Executes during object creation, after setting all properties.
function sliderLayers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

minLayers = 2;
maxLayers = 10;
sliderStep = [1, 1] / (maxLayers - minLayers); % major and minor steps of 1
set(hObject, 'Min', minLayers);
set(hObject, 'Max', maxLayers);
set(hObject, 'SliderStep', sliderStep);
set(hObject, 'Value', 5);


function editThickness_Callback(hObject, eventdata, handles)
% hObject    handle to editThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editThickness as text
%        str2double(get(hObject,'String')) returns contents of editThickness as a double

thickness = str2double(get(hObject, 'String'));
n = get(handles.sliderLayers, 'Value');
spacing = thickness / (n - 1);

set(handles.editSpacing, 'String', spacing);

% --- Executes during object creation, after setting all properties.
function editThickness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to editSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpacing as text
%        str2double(get(hObject,'String')) returns contents of editSpacing as a double

spacing = str2double(get(hObject, 'String'));
n = get(handles.sliderLayers, 'Value');
thickness = (n - 1) * spacing;

set(handles.editThickness, 'String', thickness);

% --- Executes during object creation, after setting all properties.
function editSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLayerSizeY_Callback(hObject, eventdata, handles)
% hObject    handle to editLayerSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLayerSizeY as text
%        str2double(get(hObject,'String')) returns contents of editLayerSizeY as a double


% --- Executes during object creation, after setting all properties.
function editLayerSizeY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLayerSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLayerSizeX_Callback(hObject, eventdata, handles)
% hObject    handle to editLayerSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLayerSizeX as text
%        str2double(get(hObject,'String')) returns contents of editLayerSizeX as a double


% --- Executes during object creation, after setting all properties.
function editLayerSizeX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLayerSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTileResY_Callback(hObject, eventdata, handles)
% hObject    handle to editTileResY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTileResY as text
%        str2double(get(hObject,'String')) returns contents of editTileResY as a double


% --- Executes during object creation, after setting all properties.
function editTileResY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTileResY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTileResX_Callback(hObject, eventdata, handles)
% hObject    handle to editTileResX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTileResX as text
%        str2double(get(hObject,'String')) returns contents of editTileResX as a double


% --- Executes during object creation, after setting all properties.
function editTileResX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTileResX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLayerResY_Callback(hObject, eventdata, handles)
% hObject    handle to editLayerResY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLayerResY as text
%        str2double(get(hObject,'String')) returns contents of editLayerResY as a double


% --- Executes during object creation, after setting all properties.
function editLayerResY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLayerResY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLayerResX_Callback(hObject, eventdata, handles)
% hObject    handle to editLayerResX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLayerResX as text
%        str2double(get(hObject,'String')) returns contents of editLayerResX as a double


% --- Executes during object creation, after setting all properties.
function editLayerResX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLayerResX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderOverlap_Callback(hObject, eventdata, handles)
% hObject    handle to sliderOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = get(hObject, 'Value');
set(handles.textOverlap, 'String', 100 * val);


% --- Executes during object creation, after setting all properties.
function sliderOverlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

minOverlap = 0;
maxOverlap = 0.5;
sliderStep = [0.05, 0.05] / (maxOverlap - minOverlap); % major and minor steps of 0.05
set(hObject, 'Min', minOverlap);
set(hObject, 'Max', maxOverlap);
set(hObject, 'SliderStep', sliderStep);
set(hObject, 'Value', 0.5);


% --- Executes on button press in btnNextLayer.
function btnNextLayer_Callback(hObject, eventdata, handles)
% hObject    handle to btnNextLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.axesLayersPage = min(handles.data.axesLayersPage + 1, handles.data.attenuator.numberOfLayers);
set(handles.textLayerPageNumber, 'String', handles.data.axesLayersPage);

gui_display_layers(handles);

guidata(hObject, handles);


% --- Executes on button press in btnPrevLayer.
function btnPrevLayer_Callback(hObject, eventdata, handles)
% hObject    handle to btnPrevLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.axesLayersPage = max(1, handles.data.axesLayersPage - 1);
set(handles.textLayerPageNumber, 'String', handles.data.axesLayersPage);

gui_display_layers(handles);

guidata(hObject, handles);


% --- Executes on selection change in popupAlgorithm.
function popupAlgorithm_Callback(hObject, eventdata, handles)
% hObject    handle to popupAlgorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupAlgorithm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupAlgorithm


% --- Executes during object creation, after setting all properties.
function popupAlgorithm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupAlgorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editIterations_Callback(hObject, eventdata, handles)
% hObject    handle to editIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIterations as text
%        str2double(get(hObject,'String')) returns contents of editIterations as a double


% --- Executes during object creation, after setting all properties.
function editIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnRunOptimization.
function btnRunOptimization_Callback(hObject, eventdata, handles)
% hObject    handle to btnRunOptimization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_clear_warning(handles.textOptimizationInfo);

if isempty(handles.data.lightfield)
    gui_warning(handles.textOptimizationInfo, 'No light field loaded');
    return;
end

attenuator = gui_create_attenuator(handles);
if isempty(attenuator)
    return;
end
handles.data.attenuator = attenuator;

set(hObject, 'Enable', 'off');
set(handles.textRMSE, 'String', '');
set(handles.textPSNR, 'String', '');
drawnow;
try
    switch get(handles.checkboxTiling, 'Value')
        case 0 % Tiling off
            attenuator = gui_run_optimization_no_tiles(handles);
        case 1 % Tiling on
            attenuator = gui_run_optimization_tiles(handles);
    end
catch ex
    set(hObject, 'Enable', 'on');
    rethrow(ex);
end

if isempty(attenuator)
    set(hObject, 'Enable', 'on');
    return;
end
handles.data.attenuator = attenuator;
handles.data.axesLayersDisplayMode = handles.constants.displayMode.layers;
handles.data.axesLayersPage = 1;

set(handles.textOptimizationInfo, 'String', [get(handles.textOptimizationInfo, 'String'), ' Forward-Projection ... ']);
drawnow;

try
    evaluation = gui_reconstruct_lightfield(handles);
catch ex
    set(hObject, 'Enable', 'on');
    rethrow(ex);
end
handles.data.evaluation = evaluation;

set(handles.textOptimizationInfo, 'String', [get(handles.textOptimizationInfo, 'String'), 'Done.']);
set(hObject, 'Enable', 'on');

guidata(hObject, handles);
gui_enable_layer_preview(handles, 'on');
gui_enable_reconstruction_preview(handles, 'on');
gui_display_layers(handles);
gui_update_layerNumbers_for_print(handles);

% --- Executes on button press in checkboxTiling.
function checkboxTiling_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxTiling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxTiling

switch get(hObject, 'Value')
    case 1 % Tiling on
        set(handles.editTileResY, 'Enable', 'on');
        set(handles.editTileResX, 'Enable', 'on');
        set(handles.sliderOverlap, 'Enable', 'on');
        set(handles.textOverlap, 'Enable', 'on');
    case 0 % Tiling off
        set(handles.editTileResY, 'Enable', 'off');
        set(handles.editTileResX, 'Enable', 'off');
        set(handles.sliderOverlap, 'Enable', 'off');
        set(handles.textOverlap, 'Enable', 'off');
end

% --- Executes on button press in btnBackProject.
function btnBackProject_Callback(hObject, eventdata, handles)
% hObject    handle to btnBackProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.data.lightfield)
    gui_warning(handles.textOptimizationInfo, 'No light field loaded');
    return;
end

attenuator = gui_create_attenuator(handles);
if isempty(attenuator) 
    return;
end
handles.data.attenuator = attenuator;

set(handles.textOptimizationInfo, 'String', 'Running back-projection ... ');
set(hObject, 'Enable', 'off');
drawnow;
try
    b = gui_backprojection(handles);
catch ex
    set(hObject, 'Enable', 'on');
    rethrow(ex);
end
handles.data.backprojection = b;
set(handles.textOptimizationInfo, 'String', 'Running back-projection ... Done.');
set(hObject, 'Enable', 'on');

handles.data.axesLayersDisplayMode = handles.constants.displayMode.backprojection;
handles.data.axesLayersPage = 1;
guidata(hObject, handles);

gui_enable_layer_preview(handles, 'on');
gui_display_layers(handles);


% --- Executes on button press in checkboxGrayscale.
function checkboxGrayscale_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxGrayscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxGrayscale



function editOutputFolder_Callback(hObject, eventdata, handles)
% hObject    handle to editOutputFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOutputFolder as text
%        str2double(get(hObject,'String')) returns contents of editOutputFolder as a double


% --- Executes during object creation, after setting all properties.
function editOutputFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOutputFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnBrowseOutput.
function btnBrowseOutput_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowseOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path = uigetdir('', 'Select a Folder for the Output');
if path == 0 % User cancelled
    return;
end

path = fullfile(path, filesep);
set(handles.editOutputFolder, 'String', path);


% --- Executes on button press in checkboxSaveLayers.
function checkboxSaveLayers_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSaveLayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSaveLayers


% --- Executes on button press in checkboxReconstructedViews.
function checkboxReconstructedViews_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxReconstructedViews (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxReconstructedViews


% --- Executes on button press in checkboxErrorImages.
function checkboxErrorImages_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxErrorImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxErrorImages


% --- Executes on button press in checkboxBackProjection.
function checkboxBackProjection_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBackProjection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxBackProjection



function editPrintFrom_Callback(hObject, eventdata, handles)
% hObject    handle to editPrintFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPrintFrom as text
%        str2double(get(hObject,'String')) returns contents of editPrintFrom as a double


% --- Executes during object creation, after setting all properties.
function editPrintFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrintFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPrintTo_Callback(hObject, eventdata, handles)
% hObject    handle to editPrintTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPrintTo as text
%        str2double(get(hObject,'String')) returns contents of editPrintTo as a double


% --- Executes during object creation, after setting all properties.
function editPrintTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrintTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMatrixSizeY_Callback(hObject, eventdata, handles)
% hObject    handle to editMatrixSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMatrixSizeY as text
%        str2double(get(hObject,'String')) returns contents of editMatrixSizeY as a double


% --- Executes during object creation, after setting all properties.
function editMatrixSizeY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMatrixSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMatrixSizeX_Callback(hObject, eventdata, handles)
% hObject    handle to editMatrixSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMatrixSizeX as text
%        str2double(get(hObject,'String')) returns contents of editMatrixSizeX as a double


% --- Executes during object creation, after setting all properties.
function editMatrixSizeX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMatrixSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxMarkers.
function checkboxMarkers_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxMarkers

switch get(hObject, 'Value')
    case 0
        set(handles.editMarkerSize, 'Enable', 'off');
    case 1
        set(handles.editMarkerSize, 'Enable', 'on');
end


function editMarkerSize_Callback(hObject, eventdata, handles)
% hObject    handle to editMarkerSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMarkerSize as text
%        str2double(get(hObject,'String')) returns contents of editMarkerSize as a double


% --- Executes during object creation, after setting all properties.
function editMarkerSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMarkerSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnGeneratePDF.
function btnGeneratePDF_Callback(hObject, eventdata, handles)
% hObject    handle to btnGeneratePDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_clear_warning(handles.textPrintInfo);

if isempty(handles.data.evaluation)
    gui_warning(handles.textPrintInfo, 'Nothing to print');
    return;
end

gui_generate_PDF(handles);


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_clear_warning(handles.textSaveInfo);

if isempty(handles.data.evaluation)
    gui_warning(handles.textSaveInfo, 'No data available to save');
    return;
end

outputFolder = get(handles.editOutputFolder, 'String');
if ~isdir(outputFolder)
    gui_warning(handles.textSaveInfo, 'Path is not a folder');
    return;
end

set(hObject, 'Enable', 'Off');
try
    gui_save_results(handles);
catch ex
    set(hObject, 'Enable', 'On');
    rethrow(ex);
end
set(hObject, 'Enable', 'On');



function editRecIndexY_Callback(hObject, eventdata, handles)
% hObject    handle to editRecIndexY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRecIndexY as text
%        str2double(get(hObject,'String')) returns contents of editRecIndexY as a double

set(hObject, 'ForegroundColor', 'Black');


% --- Executes during object creation, after setting all properties.
function editRecIndexY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRecIndexY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRecIndexX_Callback(hObject, eventdata, handles)
% hObject    handle to editRecIndexX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRecIndexX as text
%        str2double(get(hObject,'String')) returns contents of editRecIndexX as a double

set(hObject, 'ForegroundColor', 'Black');


% --- Executes during object creation, after setting all properties.
function editRecIndexX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRecIndexX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupReconstructionPreview.
function popupReconstructionPreview_Callback(hObject, eventdata, handles)
% hObject    handle to popupReconstructionPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupReconstructionPreview contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupReconstructionPreview


% --- Executes during object creation, after setting all properties.
function popupReconstructionPreview_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupReconstructionPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnShowReconstruction.
function btnShowReconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to btnShowReconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_display_reconstruction_or_error(handles);


% --- Executes during object creation, after setting all properties.
function textImportInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textImportInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject, 'String', '');


% --- Executes during object creation, after setting all properties.
function textOptimizationInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textOptimizationInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject, 'String', '');


% --- Executes during object creation, after setting all properties.
function textSaveInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textSaveInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject, 'String', '');


% --- Executes during object creation, after setting all properties.
function textPrintInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textPrintInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject, 'String', '');


% --------------------------------------------------------------------
function menuExamples_Callback(hObject, eventdata, handles)
% hObject    handle to menuExamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_settings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuItem_locateLytro_Callback(hObject, eventdata, handles)
% hObject    handle to menuItem_locateLytro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lytro_settings;


% --- Executes on selection change in popupSizeUnit.
function popupSizeUnit_Callback(hObject, eventdata, handles)
% hObject    handle to popupSizeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupSizeUnit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSizeUnit


% --- Executes during object creation, after setting all properties.
function popupSizeUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSizeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSaveMATFiles.
function checkboxSaveMATFiles_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSaveMATFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSaveMATFiles
