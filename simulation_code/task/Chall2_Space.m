function [] = Chall2_Space()
%% Global parameters
global Rwd_std;
global window; global windowRect;

global DirName
global planet_num;
global timer;
global Chall2TimeLimit;
global TotalScore;
global Gain1;
global Gain2;

%% Default Settings - from Tutorial
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

%% Space window setting
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','TextEncodingLocale','UTF-8');
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
nominalFrameRate = Screen('NominalFrameRate', window);

[xPixels,yPixels] = Screen('WindowSize', window);  % size of display
TotalWindowSize = [xPixels,yPixels];
ExpRectSize = [800 600];
[xCenter, yCenter] = RectCenter(windowRect);


%% Space start
planet_num = 0; % Planet number
timer = clock;
chall2_planet_list = [];
chall2_mouse_event = [];

%% Planet setting end
x_list = [50 150 250];
y_list = [50 150 250];

%% Space Setting
space_size = [300 300];
space_rect = [0 0 space_size];
space_X_range = [xCenter-space_size(1)./2,xCenter+space_size(1)./2];
space_Y_range = [yCenter-space_size(2)./2,yCenter+space_size(2)./2];
ExpRectSize = [800 600];

deg = (x_list ./ space_size(1)) .* pi; % rad
dstnt = (3 .* Rwd_std) .* (y_list ./ space_size(2));

idx_mat = magic(3);
idx_mat = idx_mat(randperm(3),randperm(3));
for i = 1:9
    [deg_idx,dstnt_idx] = find(idx_mat==i);
    dstnt_token = dstnt(dstnt_idx);
    deg_token = deg(deg_idx);
    
    start_t = etime(clock,timer);
    chall2_mouse_event = [chall2_mouse_event;Chall2_Planet(dstnt_token,deg_token)];
    end_t = etime(clock,timer);
    WaitString{1} = double('화면을 터치해 다음 행성으로 이동합니다.');
    wait_touch(WaitString,xCenter,yCenter);
    Screen('TextSize', window, 20);
    
    planet_token = [planet_num,dstnt_token,deg_token,start_t,end_t];
    chall2_planet_list = [chall2_planet_list;planet_token];
    planet_num = planet_num + 1;
end

%Save planet information
if(~(isempty(chall2_planet_list)))
    result_path1 = sprintf('%s/Chall2_Planet_Information',DirName);
    save(result_path1,'chall2_planet_list');
end
%Save mouse event information
if(~(isempty(chall2_mouse_event)))
    Gain = sum(chall2_mouse_event(:,7));
    score_path = sprintf('%s/Chall2_MouseEvent',DirName);
    save(score_path,'chall2_mouse_event');
else
    Gain = 0;
end

% wait for touch to start next task
% then terminate
EndString{1} = double('실험을 종료하려면 화면을 터치하십시오.');
TotalScore = TotalScore + Gain;
Gain2 = Gain;
wait_touch(EndString,xCenter,yCenter,Gain);
TotalScoreString{1} = double(sprintf('인센티브 과제 점수 : %s',num2str(Gain1)));
TotalScoreString{2} = double(sprintf('테스트 과제 점수 : %s',num2str(Gain2)));
TotalScoreString{3} = double(sprintf('총 점수 : %s',num2str(TotalScore)));



tmp_yPos = yCenter-100;
for ii = 1:length(TotalScoreString)
    StrBound = Screen('TextBounds',window,TotalScoreString{ii});
    DrawFormattedText(window, TotalScoreString{ii}, xCenter-StrBound(3)./2,tmp_yPos, white);
    tmp_yPos = tmp_yPos + 50;
end
Screen('Flip', window);
score_path = sprintf('%s/Score',DirName);
save(score_path,'Gain1','Gain2','TotalScore');
KbStrokeWait;
end