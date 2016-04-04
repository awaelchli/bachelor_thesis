function varargout = lytro_settings(varargin)
% LYTRO_SETTINGS MATLAB code for lytro_settings.fig
%      LYTRO_SETTINGS, by itself, creates a new LYTRO_SETTINGS or raises the existing
%      singleton*.
%
%      H = LYTRO_SETTINGS returns the handle to a new LYTRO_SETTINGS or the handle to
%      the existing singleton*.
%
%      LYTRO_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LYTRO_SETTINGS.M with the given input arguments.
%
%      LYTRO_SETTINGS('Property','Value',...) creates a new LYTRO_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lytro_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lytro_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lytro_settings

% Last Modified by GUIDE v2.5 08-Feb-2016 21:20:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lytro_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @lytro_settings_OutputFcn, ...
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


% --- Executes just before lytro_settings is made visible.
function lytro_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lytro_settings (see VARARGIN)

% Choose default command line output for lytro_settings
handles.output = hObject;
handles.mainFigure = hObject;
if isdeployed
    handles.constants.lytroSettingsFile = fullfile(ctfroot, 'lytro_settings.mat');
else
    handles.constants.lytroSettingsFile = './lytro_settings.mat';
end

% Update handles structure
guidata(hObject, handles);

lytroPath = '';
defaultLytroPath = '';

if ispc
    defaultLytroPath = [getenv('HOMEDRIVE') getenv('HOMEPATH') '\AppData\Local\Lytro\cameras\'];
end

if exist(handles.constants.lytroSettingsFile, 'file')
    load(handles.constants.lytroSettingsFile, 'lytroPath', 'defaultLytroPath');
    set(handles.editPath, 'String', lytroPath);
else % Settings file does not yet exist
    save(handles.constants.lytroSettingsFile, 'lytroPath', 'defaultLytroPath');
end

info = ['In order to load Lytro light fields, a calibration database is needed. ' ...
            'This database is created once the Lytro software is installed. ' ...
            'The default location is: ' defaultLytroPath];
set(handles.textLytroInfo, 'String', info);

% --- Outputs from this function are returned to the command line.
function varargout = lytro_settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnBrowse.
function btnBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load(handles.constants.lytroSettingsFile, 'defaultLytroPath');
folder = uigetdir(defaultLytroPath, 'Select Lytro cameras folder');

if folder
    set(handles.editPath, 'String', fullfile(folder, filesep));
end


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


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lytroPath = get(handles.editPath, 'String');
save(handles.constants.lytroSettingsFile, 'lytroPath', '-append');
close(handles.mainFigure);


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.mainFigure);
