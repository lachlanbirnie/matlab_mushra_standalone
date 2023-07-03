% MUSHRA_STANDALONE - Simple MUSHRA training and test GUI in MATLAB.
% The configuration/settings of the test are defined at the beginning of
% this matlab script. The MUSHRA test uses pre-rendered .wav signals.
%
% Syntax:  mushra_standalone()
%
% Other m-files required: none
% Subfunctions: lb_mushra_training()
%               lb_mushra_test()
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 31-Aug-2021
% Last revision: 16-Sept-2021

%% - Settings -------------------------------------------------------------

fs = 48000;  % Sampling frequency of signals.
device = 'default';  % Audio player device. 

% --- Techno ---

techno_reference = fullfile(["mushra_test_signals/techno_r_N1.wav"]);

techno_signals = fullfile(["mushra_test_signals/techno_b_N1.wav" ...
                          ,"mushra_test_signals/techno_t_N1.wav" ...
                          ,"mushra_test_signals/techno_c_N1.wav" ...
                          ]);
              
techno_training_names = ["techno-A" ...
                        ,"techno-B" ...
                        ,"techno-C" ...
                        ];
             
techno_test_names = ["techno-b" ...
                    ,"techno-t" ...
                    ,"techno-c" ...
                    ];
                
% --- Speech --- 

speech_reference = fullfile(["mushra_test_signals/speech_r_N1.wav"]);

speech_signals = fullfile(["mushra_test_signals/speech_b_N1.wav" ...
                          ,"mushra_test_signals/speech_t_N1.wav" ...
                          ,"mushra_test_signals/speech_c_N1.wav" ...
                          ]);
             
speech_training_names = ["speech-A" ...
                        ,"speech-B" ...
                        ,"speech-C" ...
                        ];
                    
speech_test_names = ["speech-b" ...
                    ,"speech-t" ...
                    ,"speech-c" ...
                    ];

%% - Training -------------------------------------------------------------

instructions = ["Listen to each signal and processing method, become familiar with the differences between them." ...
               ,"" ...
               ,"While listening to 'techno' adjust your volume to your normal level for music listening." ...
               ,"" ...
               ,"Listen for:" ...
               ,"Spectral differences (low, medium, high frequency content)" ...
               ,"Spatial differences (if the sound is inside or outside of your head, the location of the source, how narrow or wide the sound source is)" ...
               ,"" ...
               ,"Close the figure to move onto test." ...
               ];

lb_mushra_training([techno_signals; speech_signals], ...
                   [techno_training_names; speech_training_names], ...
                   instructions, ...
                   device, ...
                   fs);

%% - Techno music, basic audio quality ------------------------------------

instructions = ["Rank each signal on OVERALL QUALITY with how similar it is to the reference from bad to excellent (0 to 100)." ...
               ,"" ...
               ,"Listen for: Spectral differences (low, medium, high frequency content), Spatial differences (if the sound is inside or outside of your head, the location of the source, how narrow or wide the sound source is) " ...
               ,"" ...
               ,"Close the figure and click SAVE to move onto the next test." ...
               ];

lb_mushra_test(techno_reference, ...
               techno_signals, ...
               techno_test_names, ...
               instructions, ...
               device, ...
               fs);

%% - Speech, basic audio quality ------------------------------------------

instructions = ["Rank each signal on OVERALL QUALITY with how similar it is to the reference from bad to excellent (0 to 100)." ...
               ,"" ...
               ,"Listen for: Spectral differences (low, medium, high frequency content), Spatial differences (if the sound is inside or outside of your head, the location of the source, how narrow or wide the sound source is) " ...
               ,"" ...
               ,"Close the figure and click SAVE to end the test." ...
               ];

lb_mushra_test(speech_reference, ...
               speech_signals, ...
               speech_test_names, ...
               instructions, ...
               device, ...
               fs);
           
return;  % End of test. 
           
% -------------------------------------------------------------------------
% - functions -
% -------------------------------------------------------------------------
function [] = lb_mushra_training(SIGNALS, SIG_NAMES, INSTRUCTIONS, ...
                                 AUDIO_DEVICE_NAME, FS)
% lachlan's MUSHRA training script.
% =========================================================================
% Project   : fb_project_2021 (centered-to-bilateral)
% File      : lb_mushra_training.m
% Creation  : 30-08-21
% Author    : lachlan.birnie (@anu.edu.au @gmail.com)
% Version   : 13-09-21
%
% Description
%
%   The pre-training UI before a mushra test. List all the test signals and
%   let people click on them.
%
% Inputs
%
%   SIGNALS     [NxM] matrix of strings of each signal .wav file name. 
%               N = source signals, M = methods.
%
%   SIG_NAMES   [NxM] matrix of strings, names of each signal. 
%
%   INSTRUCTIONS = 'string of instructions given at the top of ui'
%
%   AUDIO_DEVICE_NAME = 'default', name of audio device to play signals.
%
%   FS = 48000;  Sampling frequency of all the test signals. 
%
% History
%   
%   13-09-21 - Use audioDeviceWriter for all versions of MATLAB.
%
% =========================================================================

%% - inputs ---------------------------------------------------------------

% [NxM] matrix of strings of each signal. N = source signals, M = methods.
if ~exist('SIGNALS','var')
    SIGNALS = ["results/space_0p8_100irls_48khz_N1/reference.wav", ...
               "results/space_0p8_100irls_48khz_N1/mymethod.wav", ...
               "results/space_0p8_100irls_48khz_N1/conventional.wav"; ...
               "results/castanets_0p8_100irls_48k_N1/reference.wav", ...
               "results/castanets_0p8_100irls_48k_N1/mymethod.wav", ...
               "results/castanets_0p8_100irls_48k_N1/conventional.wav"];
end
    
% [NxM] matrix of names of each signal. 
if ~exist('SIG_NAMES','var')
    SIG_NAMES = ["techno-reference", ...
                 "techno-translation", ...
                 "techno-conventional";
                 "castanets-reference", ...
                 "castanets-translation", ...
                 "castanets-conventional"];
end

if ~exist('INSTRUCTIONS','var') || isempty(INSTRUCTIONS)
    INSTRUCTIONS = 'Get familiar with the different signals';
end

if ~exist('AUDIO_DEVICE_NAME','var') || isempty(AUDIO_DEVICE_NAME)
    AUDIO_DEVICE_NAME = 'default';
end

if ~exist('FS','var') || isempty(FS)
    FS = 48000;
end

%% - constants ------------------------------------------------------------

% processings.
frame_size = 512;

% Colors.
Color.bg = [.95 .95 .95];  % Background.
Color.fg = [0 0 0];  % Foreground.

color_off = [.8 .8 .8];
color_on = [.5 1 .5];

Color.playbtn_font = Color.fg;  % Play button font.
Color.playbtn_off = color_off;
Color.playbtn_on = color_on;

% Positioning.
btn_zone_ypos = 0.05;
btn_zone_ylen = 0.65;
btn_zone_xpos = 0.05;
btn_zone_xlen = 0.9;
instr_yoffset = 0.01;  % y offset of instructions above play buttons.

%% - initial variables ----------------------------------------------------
current_track = 1;  % Index's the current track to play.
current_frame = inf;  % Index of the frame being played.

%% - load test signals ----------------------------------------------------

% Information of each test signal, grouped into array of structures.
Testsig = struct();

for i = (1 : size(SIGNALS, 1))
    for j = (1 : size(SIGNALS, 2))

        % Load all signals.
        Testsig(i,j).name = SIG_NAMES(i,j);  % Name test signal.
        [Testsig(i,j).data, Testsig(i,j).fs] = audioread(SIGNALS(i,j));

        if Testsig(i,j).fs ~= FS
            error('Sampling frequencies dont match');
        end

        % Segment signals into frames.
        Testsig(i,j).frames = signal_to_frames(Testsig(i,j).data, ...
                                               frame_size);
        Testsig(i,j).total_frames = size(Testsig(i,j).frames, 2);
        
    end
end

%% - audio device interface -----------------------------------------------

AudioPlayer = audioDeviceWriter;
AudioPlayer.Device = AUDIO_DEVICE_NAME;
AudioPlayer.SampleRate = FS;
AudioPlayer.SupportVariableSizeInput = true;
AudioPlayer.BufferSize = 128; %frame_size;

%% - gui ------------------------------------------------------------------

Gui = struct();

Gui.Fig = figure('Name', 'Lachlans MUSHRA training', 'Units' ...
                ,'normalized', 'Position', [0.05 0.05 0.9 0.85] ...
                ,'Color', Color.bg, 'Tag', 'Fig' ...
                ,'CloseRequestFcn', @cb_close ...
                );
            
% --- Play buttons ---

for i = (1 : size(Testsig, 1))
    for j = (1 : size(Testsig, 2))
    
        % Play button positions.
        xind = btn_zone_xpos ...
               + (btn_zone_xlen / size(Testsig, 2)) * 0.05 ...
               + (btn_zone_xlen / size(Testsig, 2)) * (j - 1);
        yind = btn_zone_ypos ...
               + (btn_zone_ylen / size(Testsig, 1)) / 4 ...
               + (btn_zone_ylen / size(Testsig, 1)) * (i - 1);
        xlen = (btn_zone_xlen / size(Testsig, 2)) * 0.8;
        ylen = (btn_zone_ylen / size(Testsig, 1)) / 2;


        Testsig(i,j).Playbtn = ...
            uicontrol('Style', 'push' ...
                      ,'Units', 'normalized' ...
                      ,'FontSize', 18 ...
                      ,'FontWeight', 'bold' ...
                      ,'BackgroundColor', Color.playbtn_off ...
                      ,'ForegroundColor', Color.playbtn_font ...
                      ,'Tag', sprintf('Playbtn-%i-%i', i, j) ...
                      ,'UserData', sub2ind(size(Testsig), i, j) ...
                      ,'String', Testsig(i,j).name ...
                      ,'Position', [xind, yind, xlen, ylen] ...
                      ,'Callback', @cb_play_button_pressed ...
                      );

    end
end

% --- Instructions box ---
top_btn_pos = Testsig(end,end).Playbtn.Position;
instr_ypos = top_btn_pos(2) + top_btn_pos(4) + instr_yoffset;
instr_ylen = 1 - instr_ypos;
annotation('textbox', ...
           'Units', 'normalized', ...
           'VerticalAlignment', 'middle', ...
           'HorizontalAlignment', 'center', ...
           'Color', Color.fg, ...
           'EdgeColor', 'none', ...
           'FontSize', 12, ...
           'FontWeight', 'bold', ...
           'String', INSTRUCTIONS, ...
           'Position', [0.1, instr_ypos, 0.8, instr_ylen]);

% -------------------------------------------------------------------------
%% - main loop that plays signals - 
% -------------------------------------------------------------------------

stop_test = false;  % Flag to stop loop when figure closes. 

while(1)
    
    drawnow;
    
    if (current_frame < Testsig(current_track).total_frames)
    
        frame_to_play = squeeze(...
            Testsig(current_track).frames(:,current_frame,:));
        under_run = AudioPlayer.step(frame_to_play);

        if under_run
            fprintf('WARNING: underrun %i \n', under_run);
        end
    
        current_frame = current_frame + 1;
    
    end
    
    if stop_test
        break;
    end
    
end

% end of function.
return;











%% - callback functions ---------------------------------------------------

function [] = cb_play_button_pressed(hObject, EventData) 
    stop_track(current_track);
    start_track(hObject.UserData);  % Start the pressed track.
end

function [] = cb_close(hObject, EventData)
    % Close.
    delete(gcf);
    stop_test = true;  % Stop playing music by breaking the main loop.
end

%% - sub functions --------------------------------------------------------

function [] = stop_track(ind)
    % Change colors to disabled.
    Testsig(ind).Playbtn.BackgroundColor = Color.playbtn_off;
end

function [] = start_track(ind)
    % Play the new track.
    current_track = ind;
    current_frame = 1;
    
    % Change colors to enabled.
    Testsig(ind).Playbtn.BackgroundColor = Color.playbtn_on;
end

function [X] = signal_to_frames(x, frame_size)
    
    % Find whole number of frames for signal length.
%     T = ceil(size(x,1) / frame_size);  % zero pad signal.
    T = floor(size(x,1) / frame_size);  % crop signal. 
    
    % Find total number of samples. 
    nx = T * frame_size;
    
    % Crop / zero-pad signal to even number of frames.
    zpx = zeros(nx, size(x,2));
    ind = min(nx, size(x,1));
    zpx(1:ind, :) = x(1:ind, :);
    
    % Initialize frames.
    X = zeros(frame_size, T, size(x,2));
    
    % Segment signal.
    for t = (0 : T-1)
        ind = (t*frame_size+1 : t*frame_size+frame_size);
        X(:,t+1,:) = x(ind, :);
    end
    
end

end

function [] = lb_mushra_test(REFERENCE, SIGNALS, SIG_NAMES, ... 
                        INSTRUCTIONS, AUDIO_DEVICE_NAME, FS)
% lachlan's MUSHRA script.
% =========================================================================
% Project   : fb_project_2021 (centered-to-bilateral)
% File      : lb_mushra.m
% Creation  : 27-08-21
% Author    : lachlan.birnie (@anu.edu.au @gmail.com)
% Version   : 13-09-21
%
% Description
%
%   Very simple MUSHRA test of pre-rendered binaural signals. 
%
% Inputs
%
%   REFERENCE = "string of reference signal .wav file to load"
%
%   SIGNALS = ["Array of strings of each .wav file to test"]
%
%   SIG_NAMES = ["Array of strings of the name of each test method"]
%
%   INSTRUCTIONS = 'string of instructions given at the top of the MUSHRA
%                   test figure'
%
%   AUDIO_DEVICE_NAME = 'default', name of audio device to play signals.
%
%   FS = 48000;  Sampling frequency of all the test signals. 
%
% Outputs
%
%   Saves .mat file to /mushra_results/current-time.mat 
%
%   .mat contains a structure with fields:
%       .name = name of test signal.
%       .value = score given to test signal 0 to 100. 
%
% History
%   
%   13-09-21 - Use audioDeviceWriter for all versions of MATLAB.
%
% =========================================================================

%% - inputs ---------------------------------------------------------------

if ~exist('REFERENCE','var')
    REFERENCE = "results/space_0p8_100irls_48khz_N1/reference.wav";
end

if ~exist('SIGNALS','var')
    SIGNALS = ["results/space_0p8_100irls_48khz_N1/reference.wav", ...
        "results/space_0p8_100irls_48khz_N1/mymethod.wav", ...
        "results/space_0p8_100irls_48khz_N1/conventional.wav"];
end

if ~exist('SIG_NAMES','var')
    SIG_NAMES = ["hidden-reference", "translation", "conventional"];
end
   
if ~exist('INSTRUCTIONS','var') || isempty(INSTRUCTIONS)
    INSTRUCTIONS = 'Rank the signals compared to the reference';
end
   
if ~exist('AUDIO_DEVICE_NAME','var') || isempty(AUDIO_DEVICE_NAME)
    AUDIO_DEVICE_NAME = 'default';
end

if ~exist('FS','var') || isempty(FS)
    FS = 48000;
end
           
% --- check inputs ---
if (length(REFERENCE) > 1)
    error('Can only have one reference signal');
end

if ~isstring(SIGNALS)
    error('SIGNALS should be array of stings.');
end

%% - constants ------------------------------------------------------------

% processings.
frame_size = 1024;

% Colors.
Color.bg = [.95 .95 .95];  % Background.
Color.fg = [0 0 0];  % Foreground.

color_off = [.8 .8 .8];
color_on = [.5 1 .5];

Color.slider_off = color_off;
Color.slider_on = color_on;

Color.score_bg = Color.bg;  % Score number background.
Color.score_font = Color.fg;  % Score number font.

Color.grade_line = [.2 .2 .2];  % Grade line color.
Color.grade_label = [.2 .2 .2];  % Grade label text color.

Color.playbtn_font = Color.fg;  % Play button font.
Color.playbtn_off = color_off;
Color.playbtn_on = color_on;

% Slider positions.
slider_height = 0.55;  % Top height of sliders.
slider_floor = 0.05;  % Bottom height of sliders.
slider_start_width = 0.1;  % Starting x-position of sliders.
slider_total_width = 0.85;  % Total width of all the sliders.

% Score number positions.
score_yoffset = 0.02;  % y offset above the slider.
score_height = 0.05;

% Play button positions.
playbtn_yoffset = 0.02;  % y offset above the score number.
playbtn_height = 0.05;

% Grade lables and lines.
line_thickness = 0.005;  % Score line thinkness.

% Instructions box.
instr_yoffset = 0.01;  % y offset above the play buttons.

%% - initial variables ----------------------------------------------------
current_track = 1;  % Index's the current track to play.
pause_track = true;  % Flag to pause the playback.

%% - load test signals ----------------------------------------------------

total_signals = length(SIGNALS) + length(REFERENCE);

% Shuffle the order of the test signals (reference is always index 1).
new_order = randperm(length(SIGNALS));  % Shuffled indexs 1 to N.

% Information of each test signal, grouped into array of structures.
% Note that the order of the signals in Testsig is already randomized.
% Execept for the reference which is always at index 1. 
Testsig = struct();

for i = (1 : total_signals)
    
    % Load all signals.
    if (i==1)
        % Load reference as first signal. 
        Testsig(i).name = 'reference';
        [Testsig(i).data, Testsig(i).fs] = audioread(REFERENCE); 
    else
        % Load test signals in shuffled order.
        irand = new_order(i-1);
        Testsig(i).name = SIG_NAMES(irand);  % Name test signal.
        [Testsig(i).data, Testsig(i).fs] = audioread(SIGNALS(irand));
    end
    
    if Testsig(i).fs ~= FS
        error('Sampling frequencies dont match');
    end
    
    % Segment signals into frames.
    Testsig(i).frames = signal_to_frames(Testsig(i).data, frame_size);

end

% - check signal lengths -
total_frames = size(Testsig(1).frames, 2);

for i = (2 : total_signals)
    if size(Testsig(i).frames, 2) ~= total_frames
        error('Signals are not the same length');
    end
end

%% - audio device interface -----------------------------------------------

AudioPlayer = audioDeviceWriter;
AudioPlayer.Device = AUDIO_DEVICE_NAME;
AudioPlayer.SampleRate = FS;
AudioPlayer.SupportVariableSizeInput = true;
AudioPlayer.BufferSize = 128; %frame_size;

%% - gui ------------------------------------------------------------------

Gui = struct();

Gui.Fig = figure('Name', 'Lachlans MUSHRA test', 'Units', 'normalized', ...
                'Position', [0.05 0.05 0.9 0.85], 'Color', Color.bg, ...
                'Tag', 'Fig', 'CloseRequestFcn', @cb_save_close);

% --- Grade lines and labels ---

line_start = slider_start_width / 2;
line_length = slider_total_width + line_start;
line_ypos = @(y) slider_floor + slider_height * y;  % Line y-position.

% line and label position as a function of y = percent of vertical space.
line_pos = @(y) [line_start, line_ypos(y), line_length, line_thickness];

label_pos = @(y) [0, line_ypos(y), slider_start_width, slider_height / 5];

% Line and label properties. 
line_spec = {'line', 'LineWidth', 3, 'Units', 'normalized', ...
              'Color', Color.grade_line};
         
label_spec = {'textbox', 'Units', 'normalized', 'VerticalAlignment', ...
               'middle', 'HorizontalAlignment', 'right', 'Color', ...
               Color.grade_label, 'EdgeColor', 'none','FontSize', 18, ...
               'FontWeight','bold'};
         
% Make lines and labels. 
annotation(line_spec{:}, 'Position', line_pos(0));
annotation(label_spec{:}, 'String', 'Bad', 'Position', label_pos(0));

annotation(line_spec{:}, 'Position', line_pos(0.2));
annotation(label_spec{:}, 'String', 'Poor', 'Position', label_pos(0.2));

annotation(line_spec{:}, 'Position', line_pos(0.4));
annotation(label_spec{:}, 'String', 'Fair', 'Position', label_pos(0.4));

annotation(line_spec{:}, 'Position', line_pos(0.6));
annotation(label_spec{:}, 'String', 'Good', 'Position', label_pos(0.6));

annotation(line_spec{:}, 'Position', line_pos(0.8));
annotation(label_spec{:},'String','Excellent','Position',label_pos(0.8));

annotation(line_spec{:}, 'Position', line_pos(1));


% --- Sliders and scores ---

% Note, the sliders and scores are tracked by their Tag and UserData.
% Tag = 'Score1' or 'Score2' or 'Slider3' ... etc.
% UserData = 1, 2, or 3 ... etc. The index of the Test signal.
%
% When a slider is move, cb_slider_moved() is called, which will find the
% score with the same index (UserData) as the slider, and then update the
% score value. 

for i = (1 : total_signals)
    
    % Slider position.
    xind = slider_start_width ...
        + (slider_total_width / total_signals) / 4 ...
        + (slider_total_width / total_signals) * (i - 1);
    yind = slider_floor;
    xlen = (slider_total_width / total_signals) / 2;
    ylen = slider_height;
    
    Testsig(i).Slider = ...
        uicontrol('Style', 'slider' ...
                 ,'Units', 'normalized' ...
                 ,'Position', [xind, yind, xlen, ylen] ...
                 ,'Value', 0.5 ...
                 ,'BackgroundColor', Color.slider_off ...
                 ,'SliderStep', [0.01, 0.01] ...
                 ,'Enable', 'off' ...
                 ,'Callback', @cb_slider_moved ...
                 ,'Tag', sprintf('Slider%i', i) ...
                 ,'UserData', i ...  % Store index into user data.
                 );

    % Score position.
    score_pos = [xind, (yind + ylen) + score_yoffset, xlen, score_height];
             
    Testsig(i).Score = ...
        uicontrol('Style', 'text' ...
                 ,'Units', 'normalized' ...
                 ,'Position', score_pos ...
                 ,'String', '50' ...
                 ,'Enable', 'on' ...
                 ,'FontSize', 24 ...
                 ,'FontWeight', 'bold' ...
                 ,'ForegroundColor', Color.score_font ...
                 ,'BackgroundColor', Color.score_bg ... 
                 ,'Tag', sprintf('Score%i', i) ...
                 ,'UserData', i ...
                 );
             
    if (i == 1)
        % Handle reference.
        Testsig(i).Slider.Value = 1;
        Testsig(i).Slider.Enable = 'off';
        Testsig(i).Slider.BackgroundColor = Color.slider_off;
        Testsig(i).Score.String = '100';
    end
    
end

% --- Play buttons ----

for i = (1 : total_signals)
    
    % Play button position, above the score box position.
    score_pos = Testsig(i).Score.Position;  % [x, y, xlen, ylen]
    play_pos = [score_pos(1), ...
                score_pos(2) + score_pos(4) + playbtn_yoffset, ...
                score_pos(3), ... 
                playbtn_height];
            
    Testsig(i).Playbtn = ...
        uicontrol('Style', 'push' ...
                  ,'Units', 'normalized' ...
                  ,'FontSize', 18 ...
                  ,'FontWeight', 'bold' ...
                  ,'BackgroundColor', Color.playbtn_off ...
                  ,'ForegroundColor', Color.playbtn_font ...
                  ,'Tag', sprintf('Playbtn%i', i) ...
                  ,'UserData', i ...
                  ,'String', sprintf('Play Sig %i', i-1) ...
                  ,'Position', play_pos ...
                  ,'Callback', @cb_play_button_pressed ...
                  );
              
    if (i == 1)
        % Handle reference.
        Testsig(i).Playbtn.String = 'Play Reference';
        Testsig(i).Playbtn.FontSize = 12;
        Testsig(i).Playbtn.BackgroundColor = Color.playbtn_off;
    end

end

% --- Pause Button ---
% Placed above the grade labels on the far left. 
score_pos = Testsig(1).Score.Position;
pause_pos = [0.01 ...
            ,score_pos(2) + score_pos(4) + playbtn_yoffset ...
            ,slider_start_width - 0.01 ...
            ,playbtn_height];

Pausebtn = ...
    uicontrol('Style', 'push' ...
              ,'Units', 'normalized' ...
              ,'FontSize', 18 ...
              ,'FontWeight', 'bold' ...
              ,'BackgroundColor', Color.playbtn_on ...
              ,'ForegroundColor', Color.playbtn_font ...
              ,'Tag', 'Pausebtn' ...
              ,'UserData', 0 ...
              ,'String', 'PAUSE' ...
              ,'Position', pause_pos ...
              ,'Callback', @cb_pause_button_pressed ...
              );
          
% --- Instructions box ---
instr_ypos = pause_pos(2) + pause_pos(4) + instr_yoffset;
instr_ylen = 1 - instr_ypos;
annotation('textbox', ...
           'Units', 'normalized', ...
           'VerticalAlignment', 'middle', ...
           'HorizontalAlignment', 'center', ...
           'Color', Color.grade_label, ...
           'EdgeColor', 'none', ...
           'FontSize', 12, ...
           'FontWeight', 'bold', ...
           'String', INSTRUCTIONS, ...
           'Position', [0.1, instr_ypos, 0.8, instr_ylen]);

% -------------------------------------------------------------------------
%% - main loop that plays signals - 
% -------------------------------------------------------------------------

current_frame = 1;  % Next frame to play in the main loop. 
stop_test = false;  % Flag to stop loop when figure closes. 

while(1)
    
    drawnow;
    
    if ~pause_track 
        
        frame_to_play = squeeze(Testsig(current_track).frames(:,current_frame,:));
        under_run = AudioPlayer.step(frame_to_play);

        if under_run
            fprintf('WARNING: underrun %i \n', under_run);
        end

        current_frame = current_frame + 1;
        if current_frame > total_frames
            current_frame = 1;
        end
        
    end

    if stop_test
        break;
    end
    
end

% end of function.
return;









%% - callback functions ---------------------------------------------------

% --- Sliders and scores ---

function [] = cb_slider_moved(hObject, EventData)
    ind = hObject.UserData;  % Get index of the slider that moved.    
    % Update the score text above the slider. 
    Testsig(ind).Score.String = sprintf('%i',round(hObject.Value * 100));
end

% --- Play button ---

function [] = cb_play_button_pressed(hObject, EventData) 
    stop_track(current_track);  % Stop the current track.
    start_track(hObject.UserData);  % Start the pressed track.
end

% --- Pause button ---

function [] = cb_pause_button_pressed(hObject, EventData) 
    stop_track(current_track);  % Stop the current track.
    pause_track = true;
    Pausebtn.BackgroundColor = Color.playbtn_on;
end

% --- Close figure ---
function [] = cb_save_close(hObject, EventData)
    
    % Ask to save and close.
    prompt = questdlg('Press save to save results?' ...
                 ,'cb_save_close' ...
                 ,'Save' ...
                 ,'Save' ...
                 );
        
    % Save scores.
    if strcmp(prompt,'Save')
        % Make save location.
        folder = [pwd filesep 'mushra_results'];
        file = @() strrep(strrep( ...
            sprintf('MUSHRA_SCORES_%s.mat',datetime),' ','_'),':','-');

        if ~isfolder(folder)
            mkdir(folder);
        end
        
        % Collect the scores.
        Scores = struct();
        for ind = (1 : length(Testsig))
            Scores(ind).name = Testsig(ind).name;
            Scores(ind).value = str2double(Testsig(ind).Score.String);
        end
        
        save([folder filesep file()], 'Scores');
    end
    
    % Close.
    delete(gcf);
    stop_test = true;  % Stop playing music by breaking the main loop.
    
end

%% - sub functions --------------------------------------------------------

function [] = stop_track(ind)
    % Change colors to disabled.
    Testsig(ind).Slider.BackgroundColor = Color.slider_off;
    Testsig(ind).Playbtn.BackgroundColor = Color.playbtn_off;
    Pausebtn.BackgroundColor = Color.playbtn_off;
    
    % Disable scoring.
    Testsig(ind).Slider.Enable = 'off';
end

function [] = start_track(ind)
    current_track = ind;  % Play the new track.
    pause_track = false;  % Unpause the track.
    
    % Change colors.
    Testsig(ind).Slider.BackgroundColor = Color.slider_on;
    Testsig(ind).Playbtn.BackgroundColor = Color.playbtn_on;
    
    if (ind ~= 1)
        % If the new track isnt the reference, enable scoring.
        Testsig(ind).Slider.Enable = 'on';
    end
end

function [X] = signal_to_frames(x, frame_size)
    
    % Find whole number of frames for signal length.
%     T = ceil(size(x,1) / frame_size);  % zero pad signal.
    T = floor(size(x,1) / frame_size);  % crop signal. 
    
    % Find total number of samples. 
    nx = T * frame_size;
    
    % Crop / zero-pad signal to even number of frames.
    zpx = zeros(nx, size(x,2));
    ind = min(nx, size(x,1));
    zpx(1:ind, :) = x(1:ind, :);
    
    % Initialize frames.
    X = zeros(frame_size, T, size(x,2));
    
    % Segment signal.
    for t = (0 : T-1)
        ind = (t*frame_size+1 : t*frame_size+frame_size);
        X(:,t+1,:) = x(ind, :);
    end
    
end

end