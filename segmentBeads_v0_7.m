
%Created by Bernhard Wallmeyer, 02.05.2018
%Version 0.1 edited on 09.05.2018

function varargout = segmentBeads_v0_7(varargin)
% segmentbeads_v0_7 MATLAB code for segmentBeads_v0_7.fig
%      segmentbeads_v0_7, by itself, creates a new segmentbeads_v0_7 or raises the existing
%      singleton*.
%
%      H = segmentbeads_v0_7 returns the handle to a new segmentbeads_v0_7 or the handle to
%      the existing singleton*.
%
%      segmentbeads_v0_7('CALLBACK',hObject,eventData,handles,...) calls
%      the local function named CALLBACK in segmentbeads_v0_7.M with the
%      given input arguments.
%
%      segmentbeads_v0_7('Property','Value',...) creates a new segmentbeads_v0_7 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segmentBeads_v0_7_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segmentBeads_v0_7_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segmentBeads_v0_7

% Last Modified by GUIDE v2.5 16-Jun-2020 16:44:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmentBeads_v0_7_OpeningFcn, ...
                   'gui_OutputFcn',  @segmentBeads_v0_7_OutputFcn, ...
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


% --- Executes just before segmentBeads_v0_7 is made visible.
function segmentBeads_v0_7_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segmentBeads_v0_7 (see VARARGIN)
% Choose default command line output for segmentBeads_v0_7
handles.output = hObject;

%add the libraries in the path 
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));

handles.radius_peak=3;%in pixels
handles.clippingLevel=0.5;%minimal amount of peak height intensity that defines bead surface
handles.diameter_openclose=6;%in pixels; define the size of gaps that should be closed
handles.lmax=2;
handles.dx=0.457;
handles.dz=4.0;
handles.ForcesCalculated=0;
handles.interp=1;
handles.youngsmod=2100;

%create the listener for the sliders; to ensure that values change
%continously
handles.sliderListener = addlistener(handles.clipping,'ContinuousValueChange',@(hFigure,eventdata) clippingContValCallback(hObject,eventdata));
handles.sliderListenerInterp = addlistener(handles.interpolation,'ContinuousValueChange',@(hFigure,eventdata) interpolationContValCallback(hObject,eventdata));
handles.sliderListenerBeadx = addlistener(handles.beadx,'ContinuousValueChange',@(hFigure,eventdata) beadxContValCallback(hObject,eventdata));
handles.sliderListenerBeady = addlistener(handles.beady,'ContinuousValueChange',@(hFigure,eventdata) beadyContValCallback(hObject,eventdata));
handles.sliderListenerFrame = addlistener(handles.frame,'ContinuousValueChange',@(hFigure,eventdata) frameContValCallback(hObject,eventdata));
handles.sliderListenerSegFrame = addlistener(handles.segframe,'ContinuousValueChange',@(hFigure,eventdata) segframeContValCallback(hObject,eventdata));
handles.sliderListenerSegBead = addlistener(handles.segbead,'ContinuousValueChange',@(hFigure,eventdata) segbeadContValCallback(hObject,eventdata));
handles.sliderListenerCutout = addlistener(handles.cutout,'ContinuousValueChange',@(hFigure,eventdata) cutoutContValCallback(hObject,eventdata));
handles.sliderListenerPeak = addlistener(handles.peak,'ContinuousValueChange',@(hFigure,eventdata) peakContValCallback(hObject,eventdata));
handles.sliderListenerOpenclose = addlistener(handles.openclose,'ContinuousValueChange',@(hFigure,eventdata) opencloseContValCallback(hObject,eventdata));
% handles.sliderListenerMaxorder = addlistener(handles.maxorder,'ContinuousValueChange',@(hFigure,eventdata) maxorderContValCallback(hObject,eventdata));

handles.NBeads=0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segmentBeads_v0_7 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = segmentBeads_v0_7_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in segmentBeads.
function segmentBeads_Callback(hObject, eventdata, handles)
% hObject    handle to segmentBeads (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=segmentBeads(hObject,handles);
plotSegBead(hObject,handles);
plotForceDipol(hObject,handles);
guidata(hObject, handles);

function plotSegBead(hObject, handles)
    %plotting of relevant pixels
%          [M,I]=max(handles.Beads(handles.currentBead).cutout,[],3);
%         [max_val,max_slice]=max(M(:));
%         handles.Beads(handles.currentBead).RGB=cat(3,handles.Beads(handles.currentBead).cutout,max_val*handles.Beads(handles.currentBead).binary,max_val*handles.Beads(handles.currentBead).harmonics);
%  C=imfuse(handles.Beads(handles.currentBead).cutout(:,:,handles.currentSegFrame),handles.Beads(handles.currentBead).binary(:,:,handles.currentSegFrame),'falsecolor','ColorChannels',[1 2 0]);
%  RGB = ind2rgb(handles.Beads(handles.currentBead).harmonics(:,:,handles.currentSegFrame),[1 0 0]);
%  D=imfuse(C,RGB,'blend','Scaling','joint');
% imshow(D,'Parent',handles.plotsegmentation);
max_val=max(handles.Beads(handles.currentBead).cutout(:));
red=uint16(65535*handles.Beads(handles.currentBead).cutout(:,:,handles.currentSegFrame)/max_val);
green=65535*uint16(handles.Beads(handles.currentBead).binary(:,:,handles.currentSegFrame));
blue=65535*uint16(handles.Beads(handles.currentBead).harmonics(:,:,handles.currentSegFrame));
RGB=cat(3,red,green,blue);
imshow(RGB,'Parent',handles.plotsegmentation);
guidata(hObject, handles);

% --- Executes on slider movement.
function clipping_Callback(hObject, eventdata, handles)
% hObject    handle to clipping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 sliderValue = round(get(handles.clipping,'Value'),2,'decimal');
 set(handles.label_clipping,'String',num2str(sliderValue));
 handles.clippingLevel=sliderValue;
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function clipping_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clipping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function label_clipping_CreateFcn(hObject, eventdata, handles)
% hObject    handle to label_clipping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

 function peakContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.peak,'Value'));
 set(handles.label_peak,'String',num2str(sliderValue));
 handles.radius_peak=sliderValue;
 guidata(hFigure);
 
 function opencloseContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.openclose,'Value'));
 set(handles.label_openclose,'String',num2str(sliderValue));
 handles.diameter_openclose=sliderValue;
 guidata(hFigure);

%   function maxorderContValCallback(hFigure,eventdata)
%  % test it out - get the handles object and write the current value
%  % to the edit box
%  handles = guidata(hFigure);
%  sliderValue = round(get(handles.maxorder,'Value'));
%  set(handles.label_maxorder,'String',num2str(sliderValue));
%  handles.lmax=sliderValue;
%  guidata(hFigure);
 
 function clippingContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.clipping,'Value'),2,'decimal');
 set(handles.label_clipping,'String',num2str(sliderValue));
 handles.clippingLevel=sliderValue;
 guidata(hFigure);
 
  function interpolationContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.interpolation,'Value'),0);
 set(handles.interpolation_label,'String',num2str(sliderValue));
 handles.interp=sliderValue;
 guidata(hFigure);

 function beadxContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.beadx,'Value'));
 set(handles.label_beadx,'String',num2str(sliderValue));
 handles.iBead(1)=sliderValue;
 plotBeadPos(hFigure,handles);
 guidata(hFigure);
 
 function beadyContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.beady,'Value'));
 set(handles.label_beady,'String',num2str(sliderValue));
 handles.iBead(2)=sliderValue;
 plotBeadPos(hFigure,handles);
 guidata(hFigure);
 
 function frameContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.frame,'Value'));
 set(handles.label_frame,'String',num2str(sliderValue));
 handles.CurrentFrame=sliderValue;
 handles.iBead(3)=sliderValue;
 plotBeadPos(hFigure,handles);
 guidata(hFigure);
 
 function segframeContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.segframe,'Value'));
 set(handles.label_segframe,'String',num2str(sliderValue));
 handles.currentSegFrame=sliderValue;
 plotSegBead(hFigure,handles);
 guidata(hFigure);
 
 function segbeadContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.segbead,'Value'));
 set(handles.label_segbead,'String',num2str(sliderValue));
 handles.currentBead=sliderValue;
 handles.segframe.Max=size(handles.Beads(handles.currentBead).cutout,3);
 handles.segframe.Value=round(size(handles.Beads(handles.currentBead).cutout,3)/2);
 handles.segframe.SliderStep=[1/size(handles.Beads(handles.currentBead).cutout,3) 2/size(handles.Beads(handles.currentBead).cutout,3)];
 handles.currentSegFrame=round(size(handles.Beads(handles.currentBead).cutout,3)/2);
 plotSegBead(hFigure,handles);
 plotForceDipol(hFigure,handles);
 guidata(hFigure);
 
 function cutoutContValCallback(hFigure,eventdata)
 % test it out - get the handles object and write the current value
 % to the edit box
 handles = guidata(hFigure);
 sliderValue = round(get(handles.cutout,'Value'));
 set(handles.label_cutout,'String',num2str(sliderValue));
 handles.cutoutBox=[sliderValue, sliderValue, sliderValue];
 plotBeadPos(hFigure,handles);
 guidata(hFigure);
 
% --------------------------------------------------------------------
function File_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to File_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenImage_Entry_Callback(hObject, eventdata, handles)
% hObject    handle to OpenImage_Entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%input of filepath
handles.pathname=uigetdir;
handles.tiffs=dir(horzcat(handles.pathname,filesep,'*.tif*'));
handles.listbox3.Value=1;
handles.currentTiff=1;
handles.listbox3.String = {handles.tiffs.name};
handles=loadImage(hObject,handles);

guidata(hObject, handles);


function handles=loadImage(hObject,handles)
file_img=horzcat(handles.pathname,filesep,handles.tiffs(handles.currentTiff).name);
%% Load metadata of image and image itself
handles.info=imfinfo(file_img);
handles.z_end=size(handles.info,1);

handles.NY=handles.info.Width;
handles.NX=handles.info.Height;

%handles.img=zeros(handles.NY,handles.NX,handles.z_end,'uint16');

%for iPlane=1:handles.z_end
%    handles.img(:,:,iPlane)=imread(file_img,iPlane)';%%Matlab defines x&y-axis the other way round!
%end

handles.img = loadtiff(file_img);

handles.CurrentFrame=round(handles.z_end/2);
handles.iBead=[round(handles.NX/2),round(handles.NY/2),round(handles.z_end/2)];
handles.frame.Enable='on';
handles.frame.SliderStep=[1/handles.z_end 2/handles.z_end];
handles.frame.Max=handles.z_end;
handles.frame.Value=round(handles.z_end/2);
handles.beadx.Enable='on';
handles.beadx.SliderStep=[1/handles.NX 2/handles.NX];
handles.beadx.Max=handles.NX;
handles.beadx.Value=handles.iBead(1);
handles.beady.Enable='on';
handles.beady.SliderStep=[1/handles.NY 2/handles.NY];
handles.beady.Max=handles.NY;
handles.beady.Value=handles.iBead(2);
handles.cutout.Enable='on';
handles.cutoutBox=[min([handles.NY handles.NX])/2, min([handles.NY handles.NX])/2, min([handles.NY handles.NX])/2];
handles.cutout.SliderStep=[1/handles.cutoutBox(1) 2/handles.cutoutBox(1)];
handles.cutout.Max=handles.cutoutBox(1);
handles.cutout.Value=handles.cutoutBox(1);
handles.retainBeadPos.Enable='on';
handles.retainFullStack.Enable='on';
handles.segmentBeads.Enable='on';
handles.peak.Max=round(0.1*min([handles.NX handles.NY]));
handles.peak.SliderStep=[1/handles.peak.Max 2/handles.peak.Max];
handles.peak.Enable='on';
handles.openclose.Max=round(0.1*min([handles.NX handles.NY]));
handles.openclose.SliderStep=[1/handles.peak.Max 2/handles.peak.Max];
handles.openclose.Enable='on';
% handles.maxorder.Enable='on';
intensity_values=sort(handles.img(:));
handles.max_val=mean(intensity_values(round(9999/10000*size(intensity_values,1)):end));
plotBeadPos(hObject, handles)

guidata(hObject, handles);
    

function plotBeadPos(hObject, handles)
    %plotting of relevant pixels
%  intensity_values=sort(handles.img(:));
%  max_val=mean(intensity_values(round(9999/10000*size(intensity_values,1)):end));
%  [M,I]=max(handles.img,[],3);
%  [max_val,max_slice]=max(M(:));
 %min_val=handles.max_val/3;%min(min(handles.img(:,:,I(max_slice))));
 hold(handles.plotwindow,'off');
 imshow(handles.img(:,:,handles.CurrentFrame),[],'Parent',handles.plotwindow)
 %imshow(handles.img(:,:,handles.CurrentFrame),[min_val handles.max_val],'Parent',handles.plotwindow);
 hold(handles.plotwindow,'on');
 plot(handles.iBead(1),handles.iBead(2),'r+','MarkerSize',50,'Parent',handles.plotwindow);
 hold(handles.plotwindow,'on')
 rectangle('Position',[handles.iBead(1)-handles.cutoutBox(1),handles.iBead(2)-handles.cutoutBox(2),2*handles.cutoutBox(1),2*handles.cutoutBox(2)],'Parent',handles.plotwindow,'EdgeColor','r');
guidata(hObject, handles);


% --- Executes on button press in retainBeadPos.
function retainBeadPos_Callback(hObject, eventdata, handles)
% hObject    handle to retainBeadPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NBeads=handles.NBeads+1;
handles.Beads(handles.NBeads).iBead=handles.iBead;
handles.Beads(handles.NBeads).cutoutBox=handles.cutoutBox;
%activate trigger that current bead is in a cutout box
handles.Beads(handles.NBeads).cutoutTrigger=1;
handles.Beads(handles.NBeads).radius_peak=handles.radius_peak;
handles.Beads(handles.NBeads).diameter_openclose=handles.diameter_openclose;
handles.Beads(handles.NBeads).clippingLevel=handles.clippingLevel;
handles.Beads(handles.NBeads).interp=handles.interp;
handles.Beads(handles.NBeads).lmax=handles.lmax;
handles.Beads(handles.NBeads).youngsmod=handles.youngsmod;
handles.Beads(handles.NBeads).filename=handles.tiffs(handles.currentTiff).name;
handles.Beads(handles.NBeads).pathname=handles.pathname;
handles.Beads(handles.NBeads).img=cutoutBead(handles.img, handles.iBead, handles.cutoutBox);
handles.Beads(handles.NBeads).dx=handles.dx;
handles.labelRetained.String=horzcat('Retained cutout at',' ',num2str(handles.iBead),' of ',handles.tiffs(handles.currentTiff).name);

guidata(hObject,handles);


% --- Executes on slider movement.
function frame_Callback(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 sliderValue = round(get(handles.frame,'Value'));
 handles.CurrentFrame=sliderValue;
 handles.iBead(3)=sliderValue;
 plotBeadPos(hObject, handles)
 guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function cutout_Callback(hObject, eventdata, handles)
% hObject    handle to cutout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 sliderValue = round(get(handles.cutout,'Value'));
 handles.cutoutBox=[sliderValue, sliderValue, sliderValue];
 plotBeadPos(hObject, handles)
 guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function cutout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function beadx_Callback(hObject, eventdata, handles)
% hObject    handle to cutout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 sliderValue = round(get(handles.beadx,'Value'));
 handles.iBead(1)=sliderValue;
 plotBeadPos(hObject, handles)
 guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function beadx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function beady_Callback(hObject, eventdata, handles)
% hObject    handle to cutout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 sliderValue = round(get(handles.beady,'Value'));
 handles.iBead(2)=sliderValue;
 plotBeadPos(hObject, handles)
 guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function beady_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function peak_Callback(hObject, eventdata, handles)
% hObject    handle to peak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of peak as text
%        str2double(get(hObject,'String')) returns contents of peak as a double
 sliderValue = round(get(handles.peak,'Value'));
 set(handles.label_peak,'String',num2str(sliderValue));
 handles.radius_peak=sliderValue;
 guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function peak_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function openclose_Callback(hObject, eventdata, handles)
% hObject    handle to openclose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 sliderValue = round(get(handles.openclose,'Value'));
 set(handles.label_openclose,'String',num2str(sliderValue));
 handles.diameter_openclose=sliderValue;
 guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function openclose_CreateFcn(hObject, eventdata, handles)
% hObject    handle to openclose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% % --- Executes on slider movement.
% function maxorder_Callback(hObject, eventdata, handles)
% % hObject    handle to maxorder (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'Value') returns position of slider
% %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%  sliderValue = round(get(handles.maxorder,'Value'));
%  set(handles.label_maxorder,'String',num2str(sliderValue));
%  handles.lmax=sliderValue;
%  guidata(hObject,handles);


% % --- Executes during object creation, after setting all properties.
% function maxorder_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to maxorder (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: slider controls usually have a light gray background.
% if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor',[.9 .9 .9]);
% end



function resolution_Callback(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resolution as text
%        str2double(get(hObject,'String')) returns contents of resolution as a double
handles.dx=str2double(get(hObject,'String'));
 guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function segframe_Callback(hObject, eventdata, handles)
% hObject    handle to segframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 sliderValue = round(get(handles.segframe,'Value'));
 handles.currentSegFrame=sliderValue;
 plotSegBead(hObject, handles)
 guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function segframe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function segbead_Callback(hObject, eventdata, handles)
% hObject    handle to segbead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 sliderValue = round(get(handles.segbead,'Value'));
 handles.currentBead=sliderValue;
 handles.segframe.Max=size(handles.Beads(handles.currentBead).cutout,3);
 handles.segframe.Value=round(size(handles.Beads(handles.currentBead).cutout,3)/2);
 handles.segframe.SliderStep=[1/size(handles.Beads(handles.currentBead).cutout,3) 2/size(handles.Beads(handles.currentBead).cutout,3)];
 handles.currentSegFrame=round(size(handles.Beads(handles.currentBead).cutout,3)/2);
 plotSegBead(hObject, handles)
 plotForceDipol(hObject,handles);
 guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function segbead_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segbead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3
handles.currentTiff=handles.listbox3.Value;
handles=loadImage(hObject,handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calcforce.
function calcforce_Callback(hObject, eventdata, handles)
% hObject    handle to calcforce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Generate mesh with equidistant points on sphere
handles=calcForce(hObject,handles);
plotForceDipol(hObject, handles);
guidata(hObject, handles);

function plotForceDipol(hObject, handles)
    %plotting of relevant pixels
%          [M,I]=max(handles.Beads(handles.currentBead).cutout,[],3);
%         [max_val,max_slice]=max(M(:));
%         handles.Beads(handles.currentBead).RGB=cat(3,handles.Beads(handles.currentBead).cutout,max_val*handles.Beads(handles.currentBead).binary,max_val*handles.Beads(handles.currentBead).harmonics);
%  C=imfuse(handles.Beads(handles.currentBead).cutout(:,:,handles.currentSegFrame),handles.Beads(handles.currentBead).binary(:,:,handles.currentSegFrame),'falsecolor','ColorChannels',[1 2 0]);
%  RGB = ind2rgb(handles.Beads(handles.currentBead).harmonics(:,:,handles.currentSegFrame),[1 0 0]);
%  D=imfuse(C,RGB,'blend','Scaling','joint');
% imshow(D,'Parent',handles.plotsegmentation);
red=mean(handles.Beads(handles.currentBead).cutout(:,:,:),3);
red=uint16(65536*red/max(red(:)));
green=mean(handles.Beads(handles.currentBead).binary(:,:,:),3);
green=uint16(65536*green/max(green(:)));
blue=mean(handles.Beads(handles.currentBead).harmonics(:,:,:),3);
blue=uint16(65536*blue/max(blue(:)));
RGB=cat(3,red,green,blue);
imshow(RGB,'Parent',handles.plotforcedipol);
if handles.ForcesCalculated==1
x=round([handles.Forces(handles.currentBead).ractio(1);handles.Forces(handles.currentBead).rreactio(1)]/(handles.Beads(handles.currentBead).dx/4))+round(size(green,1)/2);
y=round([handles.Forces(handles.currentBead).ractio(2);handles.Forces(handles.currentBead).rreactio(2)]/(handles.Beads(handles.currentBead).dx/4))+round(size(green,1)/2);
z=round([handles.Forces(handles.currentBead).ractio(3);handles.Forces(handles.currentBead).rreactio(3)]/(handles.Beads(handles.currentBead).dx/4))+round(size(green,1)/2);
u=[handles.Forces(handles.currentBead).Factio(1);handles.Forces(handles.currentBead).Freactio(1)];
v=[handles.Forces(handles.currentBead).Factio(2);handles.Forces(handles.currentBead).Freactio(2)];
w=[handles.Forces(handles.currentBead).Factio(3);handles.Forces(handles.currentBead).Freactio(3)];
hold(handles.plotforcedipol,'on');
q=quiver(handles.plotforcedipol,y,x,v*10^9,u*10^9,2,'LineWidth',0.5);
hold(handles.plotforcedipol,'off');

% Show Force and Tension on the GUI
%set(handles.ampdipol,'String',horzcat('Force: ',num2str(round(norm(handles.Forces(handles.currentBead).Factio)*10^9,2)),' nN, Tension: ',num2str(round(norm(handles.Forces(handles.currentBead).Tactio),2)),' Pa'));

% Show only the Tension on the GUI
set(handles.ampdipol,'String',horzcat('Tension: ',num2str(round(norm(handles.Forces(handles.currentBead).Tactio),2)),' Pa'));


%handles.ampdipol.String=horzcat(num2str(round(norm(handles.currentBead).Factio)*10^9,2),' nN');
% annotation('arrow',[x(1),y(1)],[x(1),y(1)]+[u(1),v(1)])
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function OpenSeg_Entry_Callback(hObject, eventdata, handles)
% hObject    handle to OpenSeg_Entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.segfilename,handles.pathname]=uigetfile;
load(horzcat(handles.pathname,handles.segfilename));
handles.Beads=Beads;
handles.ForcesCalculated=exist('Forces');
if handles.ForcesCalculated==1
    handles.Forces=Forces;
end
handles.tiffs=dir(horzcat(handles.pathname,filesep,'*.tif*'));
handles.listbox3.Value=1;
handles.currentTiff=1;
handles.listbox3.String = {handles.tiffs.name};
handles=loadImage(hObject,handles);

if (size(handles.Beads,2)>1)
    handles.segbead.Enable='on';
    handles.segbead.Max=size(handles.Beads,2);
    handles.segbead.Value=1;
    handles.segbead.SliderStep=[1/size(handles.Beads,2) 2/size(handles.Beads,2)];
end
handles.currentBead=1;
handles.segframe.Enable='on';
handles.segframe.Max=size(handles.Beads(handles.currentBead).cutout,3);
handles.segframe.Value=round(size(handles.Beads(handles.currentBead).cutout,3)/2);
handles.segframe.SliderStep=[1/size(handles.Beads(handles.currentBead).cutout,3) 2/size(handles.Beads(handles.currentBead).cutout,3)];
handles.currentSegFrame=round(size(handles.Beads(handles.currentBead).cutout,3)/2);
plotSegBead(hObject,handles);
plotForceDipol(hObject,handles);
handles.calcforce.Enable='on';
guidata(hObject, handles);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard


% --- Executes on button press in retainFullStack.
function retainFullStack_Callback(hObject, eventdata, handles)
% hObject    handle to retainFullStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NBeads=handles.NBeads+1;
handles.Beads(handles.NBeads).iBead=handles.iBead;
handles.Beads(handles.NBeads).cutoutBox=handles.cutoutBox;
%deactivate cutout trigger because full stack should be segmented
% handles.Beads(handles.NBeads).cutoutTrigger=0;
handles.Beads(handles.NBeads).interp=handles.interp;
handles.Beads(handles.NBeads).radius_peak=handles.radius_peak;
handles.Beads(handles.NBeads).diameter_openclose=handles.diameter_openclose;
handles.Beads(handles.NBeads).clippingLevel=handles.clippingLevel;
handles.Beads(handles.NBeads).lmax=handles.lmax;
handles.Beads(handles.NBeads).youngsmod=handles.youngsmod;
handles.Beads(handles.NBeads).filename=handles.tiffs(handles.currentTiff).name;
handles.Beads(handles.NBeads).pathname=handles.pathname;
handles.Beads(handles.NBeads).img=handles.img;
handles.Beads(handles.NBeads).dx=handles.dx;
handles.labelRetained.String=horzcat('Retained full stack',' ',handles.tiffs(handles.currentTiff).name);

guidata(hObject,handles);


% --- Executes on button press in checkboxCompression.
function checkboxCompression_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxCompression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxCompression


% --- Executes on slider movement.
function interpolation_Callback(hObject, eventdata, handles)
% hObject    handle to interpolation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 sliderValue = round(get(handles.interpolation,'Value'),0);
 set(handles.interpolation_label,'String',num2str(sliderValue));
 handles.interp=sliderValue;
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function interpolation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interpolation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in exportfigs.
function exportfigs_Callback(hObject, eventdata, handles)
% hObject    handle to exportfigs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[save_file,save_path]=uiputfile([handles.pathname,filesep,'*.mat'],'Save path');
save_fig=figure('Visible','off');
axes_new=copyobj(handles.plotsegmentation,save_fig);
set(axes_new,'units','normalized','Position',get(groot,'DefaultAxesPosition'));
legend(axes_new,'show');
set(save_fig,'CreateFcn','set(gcbf,''Visible'',''on'')');
savefig(save_fig,[save_path,save_file(1:end-4),'_segmentation','.fig']);
delete(save_fig);
save_fig=figure('Visible','off');
axes_new=copyobj(handles.plotforcedipol,save_fig);
set(axes_new,'units','normalized','Position',get(groot,'DefaultAxesPosition'));
legend(axes_new,'show');
set(save_fig,'CreateFcn','set(gcbf,''Visible'',''on'')');
savefig(save_fig,[save_path,save_file(1:end-4),'_forcedipol','.fig']);
delete(save_fig);


% --- Executes on button press in autoBeadPos.
function autoBeadPos_Callback(hObject, eventdata, handles)
% hObject    handle to autoBeadPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.trackfilename,handles.trackpathname]=uigetfile;
answer = inputdlg('Enter timepoint belonging to image:',...
             'Timepoint', [1 50]);
tp = str2num(answer{1});

handles=autoRetainBeadPos(hObject,handles,tp);

guidata(hObject,handles);

function handles=autoRetainBeadPos(hObject,handles,tp)
load(horzcat(handles.trackpathname,handles.trackfilename));
set(handles.resolution,'string',num2str(dx));
set(handles.resolution_z,'string',num2str(dz));
handles.dx=dx;
handles.dz=dz;

%Get all spots
spotlist=[];
for j=1:size(tracks,2)
    spotlist=vertcat(spotlist,[tracks(j).t tracks(j).m]);
end

%Get centers of current time point
rows=find(spotlist(:,1)==tp);
centers=zeros(size(spotlist(rows,2:4)));
centers(:,1:2)=(round(spotlist(rows,2:3)/dx)+1);
centers(:,3)=(round(spotlist(rows,4)/dz)+1);
nCenters=size(centers,1);

img_tmp=sort(handles.img(:),'ascend');
offset=mean(img_tmp(1:round(0.1*size(img_tmp,1))));

for j=1:nCenters
    handles.NBeads=handles.NBeads+1;
    handles.Beads(handles.NBeads).iBead=centers(j,:);
    handles.Beads(handles.NBeads).cutoutBox=findCutoutBox(handles.img, centers(j,:), handles.clippingLevel, offset);
    %activate trigger that current bead is in a cutout box
%     handles.Beads(handles.NBeads).cutoutTrigger=1;
    handles.Beads(handles.NBeads).radius_peak=handles.radius_peak;
    handles.Beads(handles.NBeads).diameter_openclose=handles.diameter_openclose;
    handles.Beads(handles.NBeads).clippingLevel=handles.clippingLevel;
    handles.Beads(handles.NBeads).interp=handles.interp;
    handles.Beads(handles.NBeads).lmax=handles.lmax;
    handles.Beads(handles.NBeads).youngsmod=handles.youngsmod;
    handles.Beads(handles.NBeads).filename=handles.tiffs(handles.currentTiff).name;
    handles.Beads(handles.NBeads).pathname=handles.pathname;
    handles.Beads(handles.NBeads).img=cutoutBead(handles.img, centers(j,:), handles.Beads(handles.NBeads).cutoutBox);
    handles.Beads(handles.NBeads).dx=handles.dx;
    handles.Beads(handles.NBeads).dz=handles.dz;
end
handles.labelRetained.String=horzcat('Retained',' ',num2str(nCenters),' Beads in ',handles.tiffs(handles.currentTiff).name);
guidata(hObject, handles);

function cutoutBox=findCutoutBox(img, iBead, clippingLevel, offset)
%Extract intensity from center of bead
peakIntensity=img(iBead(2),iBead(1),iBead(3))-offset;
%Extract intensity profiles along x, y and z. Find point where intensity drops below threshold 
xProfile=((img(:,iBead(1),iBead(3))-offset)<(clippingLevel*peakIntensity));
x_high=find(xProfile(iBead(2):end),1);
x_low=find(flip(xProfile(1:iBead(2))),1);
yProfile=((img(iBead(2),:,iBead(3))-offset)<(clippingLevel*peakIntensity));
y_high=find(yProfile(iBead(1):end),1);
y_low=find(flip(yProfile(1:iBead(1))),1);
zProfile=((img(iBead(2),iBead(1),:)-offset)<(clippingLevel*peakIntensity));
zProfile=squeeze(zProfile);
z_high=find(zProfile(iBead(3):end),1);
z_low=find(flip(zProfile(1:iBead(3))),1);
%keyboard
%Define length of cutout box in each direction
x_size=ceil(1.3*max(x_high-1,x_low-1));
y_size=ceil(1.3*max(y_high-1,y_low-1));
z_size=ceil(1.3*max(z_high-1,z_low-1));

% max_size=max([x_size,y_size,z_size]);
% %Return cutout box
% cutoutBox=[max_size,max_size,max_size];
cutoutBox=[x_size,y_size,z_size];

function cutout = cutoutBead(img, iBead, cutoutBox)
    %coordinates that should be cut out of image
    x_low=max(iBead(2)-cutoutBox(1),1);
    x_high=min(iBead(2)+cutoutBox(1),size(img,2));
    y_low=max(iBead(1)-cutoutBox(2),1);
    y_high=min(iBead(1)+cutoutBox(2),size(img,1));
    z_low=max(iBead(3)-cutoutBox(3),1);
    z_high=min(iBead(3)+cutoutBox(3),size(img,3));
    
cutout=img(x_low:x_high,y_low:y_high,z_low:z_high);                

function youngs_Callback(hObject, eventdata, handles)
% hObject    handle to youngs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of youngs as text
%        str2double(get(hObject,'String')) returns contents of youngs as a double
handles.youngsmod=1000*str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function youngs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to youngs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function batch_Callback(hObject, eventdata, handles)
% hObject    handle to batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.batchfilename,handles.batchpathname]=uigetfile;
load(horzcat(handles.batchpathname,handles.batchfilename));
handles.radius_peak=radius_peak;%in pixels
handles.clippingLevel=clippingLevel;%minimal amount of peak height intensity that defines bead surface
handles.diameter_openclose=diameter_openclose;%in pixels; define the size of gaps that should be closed
handles.lmax=lmax;
handles.interp=interp_factor;
handles.youngsmod=youngsmod;
handles.trackpathname=track_path;
handles.trackfilename=track_file;

counter=0;
[b,n]=RunLength(path_pattern);
for j=1:Ntp
    if isfield(handles,'Beads')
        handles=rmfield(handles,'Beads');
    end
    if isfield(handles,'Forces')
        handles=rmfield(handles,'Forces');
    end
    handles.NBeads=0;
    handles.pathname=fixPath(b,n,num2str(j-1));
    handles.tiffs=dir(horzcat(handles.pathname,filesep,'*.tif*'));
    handles.listbox3.Value=1;
    handles.currentTiff=1;
    handles.listbox3.String = {handles.tiffs.name};
    handles=loadImage(hObject,handles);
    handles=autoRetainBeadPos(hObject,handles,j-1);
    handles=segmentBeads(hObject,handles);
    handles=calcAnalyticForce(hObject,handles);
    counter=counter+handles.NBeads;
    plotForceDipol(hObject, handles);
    plotSegBead(hObject,handles);
end
handles.labelRetained.String=horzcat('Analysed a total of',' ',num2str(counter),' Beads');
guidata(hObject, handles);

function str = fixPath(b, n, t)
    str=blanks(sum(n));
    index=1;
    for j=1:size(b,2)
       if b(j)=='?'
           repstr=pad(t,n(j),'left','0');
       else
           repstr=pad(b(j),n(j),'left',b(j));
       end
        for k=1:n(j)
            str(index)=repstr(k);
            index=index+1;
        end
    end
        
function handles=segmentBeads(hObject,handles)
noBeads=0;
for j=1:size(handles.Beads,2)
interp=handles.Beads(j).interp;
radius_peak=handles.Beads(j).radius_peak;
radius_cutout=handles.Beads(j).cutoutBox;
% cutoutTrigger=handles.Beads(j).cutoutTrigger;
clipping_level=handles.Beads(j).clippingLevel;%minimal amount of peak height intensity that defines bead surface
diameter_openclose=handles.Beads(j).diameter_openclose;%in pixels; define the size of gaps that should be closed
lmax=handles.Beads(j).lmax;
img=handles.Beads(j).img;
iBeads=handles.Beads(j).iBead;
dx=handles.Beads(j).dx;
dy=dx;
dz=dx;
[~,name,~] = fileparts(handles.Beads(j).filename);
save_dir=horzcat(handles.Beads(j).pathname,filesep,name,'_segmentation');

NX = size(img,1);
NY = size(img,2);
z_end = size(img,3);

%% Segmentation of bead surface
status = mkdir(save_dir);
f = msgbox(strcat('Segmenting bead',' ',num2str(j),' ','of',' ',num2str(size(handles.Beads,2))),'status');

%     %coordinates that should be cut out of image
%     x_low=max(iBeads(2)-radius_cutout,1);
%     x_high=min(iBeads(2)+radius_cutout,size(img,2));
%     y_low=max(iBeads(1)-radius_cutout,1);
%     y_high=min(iBeads(1)+radius_cutout,size(img,1));
%     z_low=max(iBeads(3)-radius_cutout,1);
%     z_high=min(iBeads(3)+radius_cutout,size(img,3));
    
    %get bead-sniplet
%     if (cutoutTrigger==1)
%         cutout_tmp=img(x_low:x_high,y_low:y_high,z_low:z_high);
%     else
        cutout_tmp=img;
%     end
    [X,Y,Z]=meshgrid(1:size(cutout_tmp,2),1:size(cutout_tmp,1),1:size(cutout_tmp,3));
    [Xq,Yq,Zq]=meshgrid(1:1/interp:size(cutout_tmp,2),1:1/interp:size(cutout_tmp,1),1:1/interp:size(cutout_tmp,3));
    cutout=interp3(X,Y,Z,single(cutout_tmp),Xq,Yq,Zq);
    %get peak intensity; calculate baselevel and amount of peak height
    %that defines edge of bead
    intensity_values=sort(cutout_tmp(:));
    intensity_peak=mean(intensity_values(round((100-radius_peak)/100*size(intensity_values,1)):end));%mean(mean(mean(img((iBeads(j,1)-radius_peak):(iBeads(j,1)+radius_peak),(iBeads(j,2)-radius_peak):(iBeads(j,2)+radius_peak),(iBeads(j,3)-radius_peak):(iBeads(j,3)+radius_peak)))));
    baselevel=median(cutout_tmp(:));
    surf_intens=clipping_level*(intensity_peak-baselevel);
    %Smooth image; transform to binary and close gaps
    filtered=imgaussfilt(cutout);
    binary = filtered>(surf_intens+baselevel);
%         binary = cutout>(surf_intens+baselevel);
    se = strel('disk',diameter_openclose);
    binary = imclose(binary,se);
    binary = imopen(binary,se);
    %detect edge using canny edge detection
    binary = canny(single(binary));
    %Save bead image/edge and bead surface in x y z coordinates
    noBeads=noBeads+1;
    handles.Beads(j).binary=binary;
    handles.Beads(j).cutout=cutout;

    f = msgbox({strcat('Segmenting bead',' ',num2str(j),' ','of',' ',num2str(size(handles.Beads,2)));'Calculating edge'},'status','replace');

    %imwrite(uint16(binary(:,:,1)),horzcat(save_dir,filesep,'BinaryBead',num2str(noBeads),'.tif'));
    clear options
    options.overwrite = true;
    options.message = false;
    options.big = true; % Use BigTIFF format
    saveastiff(uint8(binary(:,:,1)), horzcat(save_dir,filesep,'BinaryBead',num2str(noBeads),'.tif'), options);
    %imwrite(uint16(cutout(:,:,1)),horzcat(save_dir,filesep,'Bead',num2str(noBeads),'.tif'));
    %imwrite(uint16(filtered(:,:,1)),horzcat(save_dir,filesep,'FilteredBead',num2str(noBeads),'.tif'));
    globalmin=min(filtered(:));
    globalmax=max(filtered(:));
    saveastiff(uint8((filtered(:,:,1)-globalmin)/(globalmax-globalmin)*255), horzcat(save_dir,filesep,'FilteredBead',num2str(noBeads),'.tif'), options);
    for l=2:size(binary,3)
        %imwrite(uint16(binary(:,:,l)),horzcat(save_dir,filesep,'BinaryBead',num2str(noBeads),'.tif'),'writemode','append');
        options.append = true;
        saveastiff(uint8(binary(:,:,l)), horzcat(save_dir,filesep,'BinaryBead',num2str(noBeads),'.tif'), options);
        %imwrite(uint16(cutout(:,:,l)),horzcat(save_dir,filesep,'Bead',num2str(noBeads),'.tif'),'writemode','append');
        %imwrite(uint16(filtered(:,:,l)),horzcat(save_dir,filesep,'FilteredBead',num2str(noBeads),'.tif'),'writemode','append');
        saveastiff(uint8((filtered(:,:,l)-globalmin)/(globalmax-globalmin)*255), horzcat(save_dir,filesep,'FilteredBead',num2str(noBeads),'.tif'), options);
    end
    ind = find(binary==1);
    [x,y,z] = ind2sub(size(binary),ind);
    bead_surface = [x*dx/interp,y*dy/interp,z*dz/interp];
    save(horzcat(save_dir,filesep,'Bead',num2str(noBeads),'.mat'),'bead_surface')

    tmp=[bead_surface(:,1) bead_surface(:,2) bead_surface(:,3)];
    [center,radius,residuals] = spherefit(tmp(:,1),tmp(:,2),tmp(:,3));
    tmp=tmp-center';

    [az,el,r]=cart2sph(tmp(:,1),tmp(:,2),tmp(:,3));
    el=pi/2-el;
    az=az+pi;

    residuum=Inf;
    spherical_harmonics_parameters=[0 0 0 0 0];
    for o=1:5
        %Fit spherical harmonics
        %         x0=zeros(1,(lmax+1)^2);
    %         x0(1)=sqrt(4*pi)*radius;%[radius 0 0 0 0 0 0 0 0];
    %         fun=@(x)fit_sphericalHarmonics(x, r, el, az, lmax);
        LB=[0 -Inf -pi -pi -pi/2];
        if (handles.checkboxCompression.Value==1.0)
            UB=[Inf 0 pi pi pi/2];
            x0=[sqrt(4*pi)*radius*rand -sqrt(4*pi)*radius*rand 2*pi*rand-pi 2*pi*rand-pi pi*rand-pi/2];
        else
            UB=[Inf Inf pi pi pi/2];
            x0=[sqrt(4*pi)*radius*rand 2*sqrt(4*pi)*radius*rand-sqrt(4*pi)*radius 2*pi*rand-pi 2*pi*rand-pi pi*rand-pi/2];
        end
        fun=@(parameters)fit_principalDeformation(parameters, tmp(:,1), tmp(:,2), tmp(:,3));
        options=optimset('MaxIter',1000*(lmax+1)^2,'MaxFunEvals',1000*size(x0,2));
        %[spherical_harmonics_parameters,residuum,exitflag,fitstats]=fminsearch(fun,x0,options);
        [spherical_harmonics_parameters_tmp,residuum_tmp,exitflag,fitstats]=fminsearchbnd(fun,x0,LB,UB,options);
        if residuum_tmp<residuum
            spherical_harmonics_parameters = spherical_harmonics_parameters_tmp;
            residuum = residuum_tmp;
        end
        switch exitflag
            case 1
                f = msgbox({strcat('Segmenting bead',' ',num2str(j),' ','of',' ',num2str(size(handles.Beads,2)));'Calculating edge';'Spherical-Harmonics-Fit converged'},'status','replace');
            case 0
                f = msgbox({strcat('Segmenting bead',' ',num2str(j),' ','of',' ',num2str(size(handles.Beads,2)));'Calculating edge';'Spherical-Harmonics-Fit did not converg. Max. number of iterations exceeded'},'status','replace');
            case -1
                f = msgbox({strcat('Segmenting bead',' ',num2str(j),' ','of',' ',num2str(size(handles.Beads,2)));'Calculating edge';'Spherical-Harmonics-Fit did not converg. The algorithm was terminated by the output function.'},'status','replace');
        end
    end
    
    handles.Beads(j).spherical_harmonics_parameters=spherical_harmonics_parameters;
    save(horzcat(save_dir,filesep,'Bead',num2str(noBeads),'_SphericalHarmonics.mat'),'spherical_harmonics_parameters','residuum','exitflag','fitstats');
    %csvwrite(horzcat(save_dir,filesep,'beads\Bead',num2str(noBeads),'_SphericalHarmonics.txt'),spherical_harmonics_parameters',0,1);
    %writetable(table({'c_00', 'c_1_1', 'c_10', 'c_11', 'c_2_2', 'c_2_1', 'c_20', 'c_21', 'c_22'}',spherical_harmonics_parameters(:)),horzcat(save_dir,filesep,'beads\Bead',num2str(noBeads),'_SphericalHarmonics.txt'),'WriteVariableNames',false,'Delimiter','space');

    %%
    %save segmented displacement in cartesian coordinates
    displacement=zeros(size(bead_surface,1),6);
    %transform el and az back into matlab-convention
    el=pi/2-el;
    az=az-pi;
    %Calculate bead surface before deformation
    [x_undis,y_undis,z_undis]=sph2cart(az, el,spherical_harmonics_parameters(1)/sqrt(4*pi));
    displacement(:,1:3)=[x_undis,y_undis,z_undis];
    displacement(:,4:6)=tmp-[x_undis,y_undis,z_undis];
    save(horzcat(save_dir,filesep,'Displacement',num2str(noBeads),'.mat'),'displacement')
    csvwrite(horzcat(save_dir,filesep,'Displacement',num2str(noBeads),'.txt'),displacement)

    %%
    %save fitted displacement in cartesian coordinates

    %transform el and az back into physics-convention
%         el=pi/2-el;
%         az=az+pi;
%         
    %[az,el,~]=cart2sph((X(:)-mean(X(:)))*(dx),(Y(:)-mean(Y(:)))*(dx),(Z(:)-mean(Z(:)))*(dx));
    %[x_undis,y_undis,z_undis]=sph2cart(az, el,spherical_harmonics_parameters(1)/sqrt(4*pi));
    displacement_harmonic=zeros(size(x_undis,1),6);
    displacement_harmonic(:,1:3)=[x_undis,y_undis,z_undis];
%         displacement_harmonic(:,4:6)=displacement_principalDeformation(spherical_harmonics_parameters,tmp(:,1), tmp(:,2), tmp(:,3));
    displacement_harmonic(:,4:6)=displacement_principalDeformation(spherical_harmonics_parameters,x_undis, y_undis, z_undis);
    save(horzcat(save_dir,filesep,'Displacement_harmonic',num2str(noBeads),'.mat'),'displacement_harmonic')
    csvwrite(horzcat(save_dir,filesep,'Displacement_harmonic',num2str(noBeads),'.txt'),displacement_harmonic)

    harmonics=zeros(size(binary));
    for i=1:size(displacement_harmonic,1)
        itmp=round((displacement_harmonic(i,1:3)+displacement_harmonic(i,4:6)+center')/(dx/interp));
        if (all(itmp<size(binary)) && all(itmp>0))
            harmonics(itmp(1),itmp(2),itmp(3))=1;
        end
    end
    harmonics = imclose(harmonics,se);
    %harmonics = imopen(harmonics,se);
    clear options
    options.overwrite = true;
    options.message = false;
    options.big = true; % Use BigTIFF format
    saveastiff(uint8(harmonics(:,:,1)), horzcat(save_dir,filesep,'FittedBead',num2str(noBeads),'.tif'), options);
    %imwrite(uint16(harmonics(:,:,1)),horzcat(save_dir,filesep,'FittedBead',num2str(noBeads),'.tif'));
    for l=2:size(harmonics,3)
        options.append = true;
        saveastiff(uint8(harmonics(:,:,l)), horzcat(save_dir,filesep,'FittedBead',num2str(noBeads),'.tif'), options);
        %imwrite(uint16(harmonics(:,:,l)),horzcat(save_dir,filesep,'FittedBead',num2str(noBeads),'.tif'),'writemode','append');
    end
    handles.Beads(j).harmonics=harmonics;

    [M,I]=max(cutout,[],3);
    [max_val,max_slice]=max(M(:));
    handles.Beads(j).RGB=cat(3,cutout,max_val*binary,max_val*harmonics);
end
if (noBeads>1)
    handles.segbead.Enable='on';
    handles.segbead.Max=size(handles.Beads,2);
    handles.segbead.Value=1;
    handles.segbead.SliderStep=[1/size(handles.Beads,2) 2/size(handles.Beads,2)];
end
handles.currentBead=1;
handles.calcforce.Enable='on';
handles.segframe.Enable='on';
handles.segframe.Max=size(handles.Beads(handles.currentBead).cutout,3);
handles.segframe.Value=round(size(handles.Beads(handles.currentBead).cutout,3)/2);
handles.segframe.SliderStep=[1/size(handles.Beads(handles.currentBead).cutout,3) 2/size(handles.Beads(handles.currentBead).cutout,3)];
handles.currentSegFrame=round(size(handles.Beads(handles.currentBead).cutout,3)/2);
Beads=handles.Beads;
save(horzcat(handles.pathname,filesep,'Beads.mat'),'Beads','-v7.3')        
guidata(hObject,handles);
        
% function handles=calcForce(hObject,handles)
% N=5000;%intended number of points on surface
% A=4*pi/N;%average area per point
% d=sqrt(A);
% Mel=round(pi/d);%number of circles of latitude
% del=pi/Mel;%distance between circles of latitude
% daz=A/del;%distance between points in azimuthal direction; in the end del~daz and del*daz=A
% el=0;
% az=0;
% Ncount=0;
% for m=0:Mel-1
%    eltmp=pi*(m+0.5)/Mel;
%    Maz=round(2*pi*sin(eltmp)/daz);%number of points on current circle of latitude
%    for n=0:Maz-1
%        el=[el;eltmp];
%        az=[az;2*pi*n/Maz-pi];
%    end
%    Ncount=Ncount+1;
% end
% el=el(2:end);
% az=az(2:end);
% 
% %% Calculate force dipols
% displacementfiles=dir(horzcat(handles.tiffs(1).folder,filesep,'*/Displacement_harmonic*.txt'));
% parameterfiles=dir(horzcat(handles.tiffs(1).folder,filesep,'*/Bead*_SphericalHarmonics.mat'));
% for j=1:size(handles.Beads,2)
% youngsmod=handles.Beads(j).youngsmod;
% f = msgbox({strcat('Calculating force-dipol for bead',' ',num2str(j),' ','of',' ',num2str(size(handles.Beads,2)))},'status','replace');
% %%Generate comsol model
% load(horzcat(parameterfiles(j).folder,filesep,parameterfiles(j).name));
% r=spherical_harmonics_parameters(1)/(sqrt(4*pi));
% modeltag=strrep(horzcat(displacementfiles(j).folder,'Bead',num2str(j)),filesep,'');
% model=calcStress(youngsmod,0.49,1000,r,horzcat(displacementfiles(j).folder,filesep,displacementfiles(j).name),modeltag);
% 
% %Get stress tensor from model
% [x,y,z]=sph2cart(az-pi,el-pi/2,r);
% [sx,sxy,sxz,sy,syz,sz]=mphinterp(model,{'solid.sx','solid.sxy','solid.sxz','solid.sy','solid.syz','solid.sz'},'coord',[x';y';z']);
% 
% %Calculate force acting at every point of mesh
% I=zeros(size(az,1),3);
% for k=1:size(az,1)
%     sigma=[sx(k) sxy(k) sxz(k); sxy(k) sy(k) syz(k); sxz(k) syz(k) sz(k)];
%     n=[sin(el(k))*cos(az(k));sin(el(k))*sin(az(k));cos(el(k))];
%     I(k,:)=sigma*n;
% end
% 
% %Rotate system such that Bead aligns with z-axis
% q0=cos(spherical_harmonics_parameters(3));
% az0=spherical_harmonics_parameters(4);
% el0=spherical_harmonics_parameters(5);
% tmp=[cos(el0)*cos(az0), -sin(az0), -sin(el0)*cos(az0); ...
% 		cos(el0)*sin(az0),  cos(az0), -sin(el0)*sin(az0); ...
% 		sin(el0),           0,         cos(el0)];
% q1=sin(spherical_harmonics_parameters(3))*tmp(1,1);
% q2=sin(spherical_harmonics_parameters(3))*tmp(2,1);
% q3=sin(spherical_harmonics_parameters(3))*tmp(3,1);
% q = quaternion(q0,q1,q2,q3);
% n = RotateVector( q, [x,y,z] );
% [azrot,elrot,~]=cart2sph(n(:,1),n(:,2),n(:,3));
% theta=pi/2+elrot;
% phi=azrot+pi;
% ind1=find(theta<pi/2);
% Factio=-sum(I(ind1,:));
% Tactio=Factio;
% xactio=mean(x(ind1));
% yactio=mean(y(ind1));
% zactio=mean(z(ind1));
% ind2=find(theta<=pi/2);
% Freactio=-sum(I(ind2,:));
% Treactio=Freactio;
% xreactio=mean(x(ind2));
% yreactio=mean(y(ind2));
% zreactio=mean(z(ind2));
% 
% handles.Forces(j).Factio=()Factio/norm(Factio);
% handles.Forces(j).Tactio=Tactio;
% handles.Forces(j).ractio=[xactio,yactio,zactio];
% handles.Forces(j).Freactio=Freactio;
% handles.Forces(j).Treactio=Treactio;
% handles.Forces(j).rreactio=[xreactio,yreactio,zreactio];
% handles.Forces(j).source=horzcat(displacementfiles(j).folder,filesep,displacementfiles(j).name);
% 
% end
% Forces=handles.Forces;
% handles.ForcesCalculated=1;
% save(horzcat(handles.pathname,filesep,'Beads.mat'),'Forces','-v7.3','-append')        
% guidata(hObject,handles);

% --- Executes on button press in calcanalytic.
function calcanalytic_Callback(hObject, eventdata, handles)
% hObject    handle to calcanalytic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=calcAnalyticForce(hObject,handles);
plotForceDipol(hObject, handles);
guidata(hObject, handles);

function handles=calcAnalyticForce(hObject,handles)
% Calculate mesh on bead surface for calculation of force-dipol direction
N=5000;%intended number of points on surface of bead
A=4*pi/N;%average area per point
d=sqrt(A);
Mel=round(pi/d);%number of circles of latitude
del=pi/Mel;%distance between circles of latitude
daz=A/del;%distance between points in azimuthal direction; in the end del~daz and del*daz=A
el=0;
az=0;
Ncount=0;
for m=0:Mel-1
   eltmp=pi*(m+0.5)/Mel;
   Maz=round(2*pi*sin(eltmp)/daz);%number of points on current circle of latitude
   for n=0:Maz-1
       el=[el;eltmp];
       az=[az;2*pi*n/Maz-pi];
   end
   Ncount=Ncount+1;
end
el=el(2:end);
az=az(2:end);

% Calculate force dipols
% parameterfiles=dir(horzcat(handles.tiffs(1).folder,filesep,'*/Bead*_SphericalHarmonics.mat'));
for j=1:size(handles.Beads,2)
youngsmod=handles.Beads(j).youngsmod;
spherical_harmonics_parameters=handles.Beads(j).spherical_harmonics_parameters;
f = msgbox({strcat('Calculating force-dipol for bead',' ',num2str(j),' ','of',' ',num2str(size(handles.Beads,2)))},'status','replace');
%Load parameterfiles
% load(horzcat(parameterfiles(j).folder,filesep,parameterfiles(j).name));

%Rotate force into lab coordinate system
%get cartesian coordinates
[x,y,z]=sph2cart(az-pi,el-pi/2,spherical_harmonics_parameters(1)/sqrt(4*pi));
%Rotate system such that Bead aligns with z-axis
q0=cos(spherical_harmonics_parameters(3));
az0=spherical_harmonics_parameters(4);
el0=spherical_harmonics_parameters(5);
tmp=[cos(el0)*cos(az0), -sin(az0), -sin(el0)*cos(az0); ...
		cos(el0)*sin(az0),  cos(az0), -sin(el0)*sin(az0); ...
		sin(el0),           0,         cos(el0)];
q1=sin(spherical_harmonics_parameters(3))*tmp(1,1);
q2=sin(spherical_harmonics_parameters(3))*tmp(2,1);
q3=sin(spherical_harmonics_parameters(3))*tmp(3,1);
q = quaternion(q0,q1,q2,q3);
n = RotateVector( q, [x,y,z] );
[azrot,elrot,~]=cart2sph(n(:,1),n(:,2),n(:,3));
theta=pi/2+elrot;
phi=azrot+pi;
ind1=find(theta<=pi/2);
xactio=mean(x(ind1));
yactio=mean(y(ind1));
zactio=mean(z(ind1));
ind2=find(theta>pi/2);
xreactio=mean(x(ind2));
yreactio=mean(y(ind2));
zreactio=mean(z(ind2));
direction=[xactio-xreactio,yactio-yreactio,zactio-zreactio];
direction=direction/vecnorm(direction);
Factio=getForce(spherical_harmonics_parameters(1)*10^(-6), spherical_harmonics_parameters(2)*10^(-6), youngsmod, 0.49)*direction;
Tactio=getTension(spherical_harmonics_parameters(1)*10^(-6), spherical_harmonics_parameters(2)*10^(-6), youngsmod, 0.49)*direction;
Freactio=-Factio;
Treactio=-Tactio;

handles.Forces(j).Factio=Factio;
handles.Forces(j).Tactio=Tactio;
handles.Forces(j).ractio=[xactio,yactio,zactio];
handles.Forces(j).Freactio=Freactio;
handles.Forces(j).Treactio=Treactio;
handles.Forces(j).rreactio=[xreactio,yreactio,zreactio];

end
Forces=handles.Forces;
handles.ForcesCalculated=1;
save(horzcat(handles.pathname,filesep,'Beads.mat'),'Forces','-v7.3','-append')        
guidata(hObject,handles);

function [F] = getForce(c00, c20, E, nu)
%GETFORCE Returns the magnitude of the force dipol
%   According to the force-dipol model this is the analytical solution of
%   the force
mu=E/(2*(1+nu));
Nr=2*nu/(1-2*nu)+1/(2*(2-3*nu)*(1-2*nu))+1/(2*(2-3*nu));

%Nt=0.5-0.5/(2*(2-3*nu)); I CORRECT THE WRONG LINE BY BERNHARD
Nt = 0.5 - 1/(2*(2-3*nu));
N=Nr/4+3*Nt/2;
F=(mu*c20*sqrt(5)*c00*N)/2;

function [T] = getTension(c00, c20, E, nu)
%GETFORCE Returns the magnitude of the tension dipol
%   According to the force-dipol model this is the analytical solution of
%   the tension
mu=E/(2*(1+nu));
Nr=2*nu/(1-2*nu)+1/(2*(2-3*nu)*(1-2*nu))+1/(2*(2-3*nu));
%Nt=0.5-0.5/(2*(2-3*nu)); Line corrected by Alejandro
Nt = 0.5 - 1/(2*(2-3*nu));
N=Nr/4+3*Nt/2;
% N=(2*nu/(1-2*nu)-(1+1/(1-2*nu))/(2*(2-3*nu))+1);
T=(mu*c20*sqrt(5)*N)/(2*c00);

% --------------------------------------------------------------------
function batchforces_Callback(hObject, eventdata, handles)
% hObject    handle to batchforces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.batchfilename,handles.batchpathname]=uigetfile;
load(horzcat(handles.batchpathname,handles.batchfilename));
handles.radius_peak=radius_peak;%in pixels
handles.clippingLevel=clippingLevel;%minimal amount of peak height intensity that defines bead surface
handles.diameter_openclose=diameter_openclose;%in pixels; define the size of gaps that should be closed
handles.lmax=lmax;
handles.interp=interp_factor;
handles.youngsmod=youngsmod;
handles.trackpathname=track_path;
handles.trackfilename=track_file;

counter=0;
[b,n]=RunLength(path_pattern);
for j=1:Ntp
    if isfield(handles,'Beads')
        handles=rmfield(handles,'Beads');
    end
    if isfield(handles,'Forces')
        handles=rmfield(handles,'Forces');
    end
    handles.NBeads=0;
    handles.pathname=fixPath(b,n,num2str(j-1));
    handles.tiffs=dir(horzcat(handles.pathname,filesep,'*.tif*'));
    handles.listbox3.Value=1;
    handles.currentTiff=1;
    handles.listbox3.String = {handles.tiffs.name};
    load(horzcat(handles.pathname,filesep,'Beads.mat'));
    handles.Beads=Beads;
    handles.currentBead=1;
    handles.currentSegFrame=1;
    
    handles=calcAnalyticForce(hObject,handles);
    counter=counter+handles.NBeads;
    plotForceDipol(hObject, handles);
    plotSegBead(hObject,handles);
end
handles.labelRetained.String=horzcat('Analysed a total of',' ',num2str(counter),' Beads');
guidata(hObject, handles);

function resolution_z_Callback(hObject, eventdata, handles)
% hObject    handle to resolution_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resolution_z as text
%        str2double(get(hObject,'String')) returns contents of resolution_z as a double
handles.dz=str2double(get(hObject,'String'));
 guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function resolution_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resolution_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in cutoutDeconvolve.
function cutoutDeconvolve_Callback(hObject, eventdata, handles)
% hObject    handle to cutoutDeconvolve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.trackfilename,handles.trackpathname]=uigetfile;
answer = inputdlg('Enter timepoint belonging to image:',...
             'Timepoint', [1 50]);
tp = str2num(answer{1});

handles=autoRetainBeadPosDeconvolve(hObject,handles,tp);

guidata(hObject,handles);

function handles=autoRetainBeadPosDeconvolve(hObject,handles,tp)
load(horzcat(handles.trackpathname,handles.trackfilename));
set(handles.resolution,'string',num2str(dx));
set(handles.resolution_z,'string',num2str(dz));
handles.dx=dx;
handles.dz=dz;
aspectRatio=dz/dx;

%Get all spots
spotlist=[];
for j=1:size(tracks,2)
    spotlist=vertcat(spotlist,[tracks(j).t tracks(j).m]);
end

%Get centers of current time point
rows=find(spotlist(:,1)==tp);
centers=zeros(size(spotlist(rows,2:4)));
centers(:,1:2)=(round(spotlist(rows,2:3)/dx)+1);
centers(:,3)=(round(spotlist(rows,4))+1);
nCenters=size(centers,1);

img_tmp=sort(handles.img(:),'ascend');
offset=mean(img_tmp(1:round(0.1*size(img_tmp,1))));


for j=1:nCenters
    handles.NBeads=handles.NBeads+1;
    handles.Beads(handles.NBeads).iBead=centers(j,:);
    handles.Beads(handles.NBeads).cutoutBox=findCutoutBox(handles.img, centers(j,:), handles.clippingLevel, offset);
    %activate trigger that current bead is in a cutout box
%     handles.Beads(handles.NBeads).cutoutTrigger=1;
    handles.Beads(handles.NBeads).radius_peak=handles.radius_peak;
    handles.Beads(handles.NBeads).diameter_openclose=handles.diameter_openclose;
    handles.Beads(handles.NBeads).clippingLevel=handles.clippingLevel;
    handles.Beads(handles.NBeads).interp=handles.interp;
    handles.Beads(handles.NBeads).lmax=handles.lmax;
    handles.Beads(handles.NBeads).youngsmod=handles.youngsmod;
    handles.Beads(handles.NBeads).filename=handles.tiffs(handles.currentTiff).name;
    handles.Beads(handles.NBeads).pathname=handles.pathname;
    handles.Beads(handles.NBeads).img=cutoutDeconvolveBead(handles.img, centers(j,:), handles.Beads(handles.NBeads).cutoutBox,handles.psf,aspectRatio,horzcat(handles.pathname,filesep,'RelativeChange',num2str(j)));
    handles.Beads(handles.NBeads).dx=handles.dx;
    handles.Beads(handles.NBeads).dz=handles.dz;
    handles.Beads(handles.NBeads).psf=handles.psf;
end
handles.labelRetained.String=horzcat('Retained',' ',num2str(nCenters),' Beads in ',handles.tiffs(handles.currentTiff).name);
guidata(hObject, handles);

function cutout = cutoutDeconvolveBead(img, iBead, cutoutBox, psf, aspectRatio, filename)
    %coordinates that should be cut out of image
    %cut out bigger volume for deconvolution
    x_low=max(iBead(2)-3*cutoutBox(1),1);
    x_high=min(iBead(2)+3*cutoutBox(1),size(img,2));
    y_low=max(iBead(1)-3*cutoutBox(2),1);
    y_high=min(iBead(1)+3*cutoutBox(2),size(img,1));
    z_low=max(iBead(3)-3*cutoutBox(3),1);
    z_high=min(iBead(3)+3*cutoutBox(3),size(img,3));
    cutout_tmp=img(x_low:x_high,y_low:y_high,z_low:z_high);
    %calculate shifted iBead in big cutout
    iBead_shifted=[iBead(1)-y_low,iBead(2)-x_low,iBead(3)-z_low];
    %Interpolate cutout-volume along z-axis
    [X,Y,Z]=meshgrid(1:size(cutout_tmp,2),1:size(cutout_tmp,1),1:size(cutout_tmp,3));
    [Xq,Yq,Zq]=meshgrid(1:size(cutout_tmp,2),1:size(cutout_tmp,1),1:1/aspectRatio:size(cutout_tmp,3));
    I=interp3(X,Y,Z,single(cutout_tmp),Xq,Yq,Zq);
    %deconvolve the volume
    I=I/max(I(:));
    I=edgetaper(I,psf);
    weight=double(imgaussfilt3(I));
    J=deconvlucy({I},psf,1,single(0.0),weight);
    change=J{3}-J{2};
    norm_factor=0.5*(J{3}+J{2});
    norm_factor=sum(norm_factor(:));
    rel_change=sum(abs(change(:)))/norm_factor;
    isOptim=false;
    while ~isOptim
        J=deconvlucy(J,psf,1,single(0.0),weight);
        change=J{3}-J{2};
        norm_factor=0.5*(J{3}+J{2});
        norm_factor=sum(norm_factor(:));
        rel_change=vertcat(rel_change,sum(abs(change(:)))/norm_factor);
        if rel_change(end)>rel_change(end-1)
            isOptim=true;
        end
    end
    %save(filename,'rel_change');
    %cut out the relevant part of the deconvolved volume
    x_low=max(iBead_shifted(2)-cutoutBox(1),1);
    x_high=min(iBead_shifted(2)+cutoutBox(1),size(I,1));
    y_low=max(iBead_shifted(1)-cutoutBox(2),1);
    y_high=min(iBead_shifted(1)+cutoutBox(2),size(I,2));
    z_low=round(max(aspectRatio*iBead_shifted(3)-aspectRatio*cutoutBox(3),1));
    z_high=round(min(aspectRatio*iBead_shifted(3)+aspectRatio*cutoutBox(3),size(I,3)));
    tmp=J{3};
cutout=tmp(x_low:x_high,y_low:y_high,z_low:z_high);

% --- Executes on button press in retainDeconBeadPos.
function retainDeconBeadPos_Callback(hObject, eventdata, handles)
% hObject    handle to retainDeconBeadPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NBeads=handles.NBeads+1;
handles.Beads(handles.NBeads).iBead=handles.iBead;
handles.Beads(handles.NBeads).cutoutBox=handles.cutoutBox;
%activate trigger that current bead is in a cutout box
handles.Beads(handles.NBeads).cutoutTrigger=1;
handles.Beads(handles.NBeads).radius_peak=handles.radius_peak;
handles.Beads(handles.NBeads).diameter_openclose=handles.diameter_openclose;
handles.Beads(handles.NBeads).clippingLevel=handles.clippingLevel;
handles.Beads(handles.NBeads).interp=handles.interp;
handles.Beads(handles.NBeads).lmax=handles.lmax;
handles.Beads(handles.NBeads).youngsmod=handles.youngsmod;
handles.Beads(handles.NBeads).filename=handles.tiffs(handles.currentTiff).name;
handles.Beads(handles.NBeads).pathname=handles.pathname;
handles.Beads(handles.NBeads).img=cutoutDeconvolveBead(handles.img, handles.iBead, handles.Beads(handles.NBeads).cutoutBox,handles.psf,handles.dz/handles.dx);
handles.Beads(handles.NBeads).dx=handles.dx;
handles.Beads(handles.NBeads).dz=handles.dz;
handles.labelRetained.String=horzcat('Retained cutout at',' ',num2str(handles.iBead),' of ',handles.tiffs(handles.currentTiff).name);

guidata(hObject,handles);

% --- Executes on button press in loadPSF.
function loadPSF_Callback(hObject, eventdata, handles)
% hObject    handle to loadPSF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.psffilename,handles.psfpathname]=uigetfile('*.*');
%Load PSF
file_psf=horzcat(handles.psfpathname,handles.psffilename);
psf_tmp=loadtiff(file_psf);
psf_tmp=psf_tmp/max(psf_tmp(:));
%Interpolate PSF along z-axis, such that dx=dz in the interpolated PSF
aspectRatio=handles.dz/handles.dx;
[Xpsf,Ypsf,Zpsf]=meshgrid(1:size(psf_tmp,2),1:size(psf_tmp,1),1:size(psf_tmp,3));
[Xqpsf,Yqpsf,Zqpsf]=meshgrid(1:size(psf_tmp,2),1:size(psf_tmp,1),1:1/aspectRatio:size(psf_tmp,3));
handles.psf=interp3(Xpsf,Ypsf,Zpsf,single(psf_tmp),Xqpsf,Yqpsf,Zqpsf);

guidata(hObject,handles);
