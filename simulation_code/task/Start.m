%% Initialization - Clear the workspace and the screen
sca; close all; clearvars;

%% Set Inputs as global variable
global Rwd; global Pnlty;
global Rwd_Peak; global Pnlty_Peak;
global Rwd_std; global Pnlty_std;

%% Set Time limit of tasks
global PreTimeLimit; PreTimeLimit = 1080; % Time for Pre-Task (sec) / 1080 sec
global Chall1TimeLimit; Chall1TimeLimit = 360; % Time for Challenge Task 1 (sec) / 360 sec 
global Chall2TimeLimit; Chall2TimeLimit = 40; % Time for each Planet in Challenge Task 2 (sec), Total : 9 times / 40 sec
global TotalScore; TotalScore = 0;% Total score for challenge task;
%% Make result directory
global DirName;
DateTime = datetime('now','Format','yyyy-MM-dd''T''HHmm');
S_DateTime = char(DateTime);
DirName = sprintf('%s',S_DateTime);
mkdir(DirName);

%% Load Inputs
LoadInputs();
InputFilePath = sprintf('%s/Input.txt',DirName);
copyfile('Input.txt',InputFilePath); % Copy Input files into result directory

%% Save MouseEventTag and PlanetInformation Tag
result_path1 = sprintf('%s/Planet_Information_Tag',DirName);
result_path2 = sprintf('%s/Mouse_Event_Tag',DirName);

Planet_Information_Tag{1} = 'col1 - Planet #';
Planet_Information_Tag{2} = 'col2 - Distance between reward and penalty (pixel)';
Planet_Information_Tag{3} = 'col3 - Degree of Distribution (rad) ';
Planet_Information_Tag{4} = 'col4 - Global Start Time (sec) ';
Planet_Information_Tag{5} = 'col5 - Global End Time (sec) ';
save(result_path1,'Planet_Information_Tag');

Mouse_Event_Tag{1} = 'col1 - Planet #';
Mouse_Event_Tag{2} = 'col2 - Global Time (sec)';
Mouse_Event_Tag{3} = 'col3 - L ocal Time (sec)';
Mouse_Event_Tag{4} = 'col4 - x Position of touch (pixels)';
Mouse_Event_Tag{5} = 'col5 - y Position of touch (pixels)';
Mouse_Event_Tag{6} = 'col6 - Raw Reward(10,0,-10)';
Mouse_Event_Tag{7} = 'col7 - Gain';
Mouse_Event_Tag{8} = 'col8 - Confidence';
Mouse_Event_Tag{9} = 'col9 - Start/Continu e Marker(0: touched new point) / 1: keep touching the point)';

save(result_path2,'Mouse_Event_Tag');

%% Start Simulation
Pre_Space(); sca;
Chall1_Space(); sca;
Chall2_Space(); sca;