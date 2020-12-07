function [] = Pre_Space()
%% Global parameters
global Rwd; global Pnlty;
global Rwd_Peak; global Pnlty_Peak;
global Rwd_std; global Pnlty_std;

global PreTimeLimit;
global DirName

global window; global windowRect;
global planet_num;
global timer; % variable for timeline

%% Default Screen Settings - from Tutorial
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

%% Space Setting
space_size = [300 300];
space_rect = [0 0 space_size];
space_X_range = [xCenter-space_size(1)./2,xCenter+space_size(1)./2];
space_Y_range = [yCenter-space_size(2)./2,yCenter+space_size(2)./2];

% wait for touch to start next task
% then start the task
StartString{1} = double('화면을 터치해 탐험을 시작하십시오.');
StartString{2} = double('잊지 마세요!!! 1단계는 행성을 탐험해서 점수를 얻는 곳과 아닌 곳을 배우는 단계입니다. ');
StartString{3} = double('이 과제에서 얻은 점수는 인센티브에 포함되지 않습니다.');
StartString{4} = double('대신 2단계와 3단계를 위해 여러 행성 안에 점수의 위치를 잘 배우세요 ');
wait_touch(StartString,xCenter,yCenter);

%% Space start
end_flag = 0; % when recieve the quit sign, set end_flag
planet_num = 0; % Planet number
timer = clock; % Global Timer start

pre_planet_list = []; % Initialize matrix for planet informations
pre_mouse_event = []; % Initialize matrix for mouse event

% Initial Mouse cursor location
x_dot = xCenter;
y_dot = yCenter;

% Infinite loop until end_flag is set
while(1)
    end_flag = CheckTimeEnd(PreTimeLimit);
    go_flag = 0; % when user press the "Go" button, set decide_flag
    t0 = clock; % local timer start;
    last_clk = 0; % record last click time;
    
    Screen('Flip', window);
    
    while ~go_flag % if user didn't press go button
        end_flag = CheckTimeEnd(PreTimeLimit);
        if(end_flag)
            break;
        end
        [buttons, x, y] = get_win_touch;
        
        % if Mouse clikced, refractory period is 0.2 sec.
        if (buttons == 1 && (etime(clock,t0) - last_clk > 0.1))
            t = etime(clock,t0); % click time
            last_clk = t;
            
            isGoPressed = xCenter+ExpRectSize(1)./4 +20 < x && ...
                x < xCenter+ExpRectSize(1)./4 + 150 && ...
                yCenter - ExpRectSize(2)./2+100-30 < y && ...
                y < yCenter-ExpRectSize(2)./2+100 + 60;
            
            if(isGoPressed) % if user click 'Go' button
                go_flag = 1;
                planet_num = planet_num + 1;
                break;
            end
            
            %when user click outside of square
            if(x < space_X_range(1))
                x = space_X_range(1);
            elseif(x > space_X_range(2))
                x = space_X_range(2);
            end
            
            if(y < space_Y_range(1))
                y = space_Y_range(1);
            elseif(y > space_Y_range(2))
                y = space_Y_range(2);
            end
            
            x_dot = x;
            y_dot = y;
        end
        
        % Planet deciding button
        DrawFormattedText(window, 'Go', xCenter+ExpRectSize(1)./4 + 50 , yCenter-ExpRectSize(2)./2 +100 , white);
        
        %% Planet setting start
        spaceRect = CenterRectOnPointd(space_rect,xCenter,yCenter);
        Screen('FillRect', window, white, spaceRect);
        
        % Draw a white dot where the mouse cursor is
        Screen('DrawDots', window, [x_dot y_dot], 5, black, [], 2);
        
        %% Planet setting end
        deg = ((x_dot - space_X_range(1)) ./ space_size(1)) .* pi; % rad
        dstnt = (3 .* Rwd_std) .* ((y_dot - space_Y_range(1)) ./ space_size(2));
        
        %% Draw Planet
        %            DrawPlanet(window,deg,dstnt,[xCenter, yCenter - ExpRectSize(2)./2]);
        Screen('Flip', window);
        
        String1 = double('탐험할 행성을 선택해 주세요.');
        DrawFormattedText(window, String1,'center', yCenter-ExpRectSize(2)./2 -120, white);
        Screen('TextSize', window, 20);
    end
    
    if(~end_flag)
        start_t = etime(clock,timer);
        pre_mouse_event = [pre_mouse_event;Pre_Planet(dstnt,deg)];
        end_t = etime(clock,timer);
        
        planet_token = [planet_num,dstnt,deg,start_t,end_t];
        pre_planet_list = [pre_planet_list;planet_token];
    else
        %Save planet information
        if(~(isempty(pre_planet_list)))
            result_path1 = sprintf('%s/Pre_Planet_Information',DirName);
            save(result_path1,'pre_planet_list');
        end
        
        %Save mouse event information
        if(~(isempty(pre_mouse_event)))
            result_path2 = sprintf('%s/Pre_MouseEvent',DirName);
            save(result_path2,'pre_mouse_event');
        end
        
        % wait for touch to start next task
        % then terminate
        NextString{1} = double('화면을 터치해 2단계를 시작하십시오.');
        NextString{2} = double('잊지 마세요!!! 2단계는 배운 것을 바탕으로 점수를 최대한 많이 모으는 단계입니다.');
        NextString{3} = double('이 과제에서 얻은 점수는 인센티브에 포함됩니다.');
        NextString{4} = double('보너스(꾸욱 누르는 방식)를 적절히 사용하여 많은 점수를 얻으세요!.');
        wait_touch(NextString,xCenter,yCenter);
        break;
    end
end
end