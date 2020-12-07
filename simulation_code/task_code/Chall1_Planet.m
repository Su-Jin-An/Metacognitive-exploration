function [mouse_event] = Chall1_Planet(dstnt,deg)
%% Global parameters
global window; global windowRect;

global Rwd; global Pnlty;
global Rwd_Peak; global Pnlty_Peak;
global Rwd_std; global Pnlty_std;

global DirName;
global planet_num;
global timer;
global Chall1TimeLimit;

%% Input Parameter
Rwd_dstnt = dstnt; % related to shape of the planet
Rwd_ang_rad = deg; % rad
PlanetColor = [1-deg./pi deg./pi 0];

%% Default Settings - from Tutorial
white = WhiteIndex(window);
black = BlackIndex(window);
grey = white / 2;

nominalFrameRate = Screen('NominalFrameRate', window);
[xPixels,yPixels] = Screen('WindowSize', window);  % size of display
TotalWindowSize = [xPixels,yPixels];
ExpRectSize = [800 600]; %size of experiment size
[xCenter, yCenter] = RectCenter(windowRect);

%% Planet Screen
planet_size = [350 350];
baseRect = [0 0 planet_size];
maxDiameter = max(baseRect) * 1.01;
planetRect = CenterRectOnPointd(baseRect,xCenter,yCenter-50);
[planet_xCenter,planet_yCenter] = RectCenter(planetRect);

planet_X_range = [planet_xCenter-planet_size(1)./2,planet_xCenter+planet_size(1)./2];
planet_Y_range = [planet_yCenter-planet_size(2)./2,planet_yCenter+planet_size(2)./2];

%% Initialize - Planet, Text setting, Mouse setting
% Draw Planet

Screen('FrameRect', window, grey, planetRect);
Screen('Flip', window);

% Text - Mouse Pointer Position
Screen('TextSize', window, 20);
SetMouse(xCenter, yCenter, window); % initial position of the mouse
cur_pos = [xCenter yCenter];

%Mouse event list
mouse_event = []; % record mouse event timing and position.

%% Reward Position Setting
cord_diff = (TotalWindowSize - planet_size)./2; % difference between planet coordinate and window coordinate

Rwd_X_Center = planet_xCenter - planet_X_range(1);
Rwd_Y_Center = planet_yCenter - planet_Y_range(1);

Rwd_Pos_x = Rwd_X_Center + Rwd_dstnt .* cos(Rwd_ang_rad);
Rwd_Pos_y = Rwd_Y_Center + Rwd_dstnt .* sin(Rwd_ang_rad);
Rwd_Neg_x = Rwd_X_Center - Rwd_dstnt .* cos(Rwd_ang_rad);
Rwd_Neg_y = Rwd_Y_Center - Rwd_dstnt .* sin(Rwd_ang_rad);

%% make distribution
Dist_size = planet_size +1;

Dist_grid_pos = default_dist(Dist_size,Rwd_Pos_x,Rwd_Pos_y,Rwd_std);
Dist_grid_neg = default_dist(Dist_size,Rwd_Neg_x,Rwd_Neg_y,Pnlty_std);

plotDist(Dist_grid_pos,Dist_grid_neg,Dist_size,'Chall1');

%% Recording
t0 = clock; % timer start;
t_clk = clock; %timer for long click;
last_clk = -1; % record last click time;
Screen('TextSize', window, 20);
first_touch = 0;

end_flag = 0;

touch_time = 0;
touch_pt = [-1,-1];
start_marker = -1;
while ~end_flag % Until end_flag is setting
    end_flag = CheckTimeEnd(Chall1TimeLimit);
    % Draw circle again for every loop
    Screen('FrameRect', window, grey, planetRect);
    % Get the current position of the mouse
    [buttons, x, y] = get_win_touch;
    if(buttons)
        first_touch = 1;
    end
    
    % calculate confidence
    if(buttons && isequal(touch_pt, [-1,-1]))
        start_marker = 0;
        touch_pt = [x,y];
        touch_timer = clock;
        touch_time = etime(clock,touch_timer);
    else
        if(buttons && (sqrt(sum((touch_pt-[x,y]).^2))<5))
            if(etime(clock,touch_timer)<=3)
                start_marker = 1;
                touch_time = etime(clock,touch_timer);
            else
                start_marker = 0;
                touch_pt = [x,y];
                touch_timer = clock;
                touch_time = etime(clock,touch_timer);
            end
        elseif(buttons && (sqrt(sum((touch_pt-[x,y]).^2))>=5))
            start_marker = 0;
            touch_pt = [x,y];
            touch_timer = clock;
            touch_time = etime(clock,touch_timer);
        else
            start_marker = 0;
            touch_timer = clock;
            touch_time = 0;
            touch_pt = [-1,-1];
        end
    end
    
    x_pp = x;
    y_pp = y;
    %when user click outside of square
    if(x < planet_X_range(1))
        x_pp = planet_X_range(1);
    elseif(x > planet_X_range(2))
        x_pp = planet_X_range(2);
    end
    
    if(y < planet_Y_range(1))
        y_pp = planet_Y_range(1);
    elseif(y > planet_Y_range(2))
        y_pp = planet_Y_range(2);
    end
    
    % Draw a white dot where the mouse cursor is
    if(~first_touch)
        x_pp = xCenter;
        y_pp = yCenter-50;
    end
    Screen('DrawDots', window, [x_pp y_pp], 5, white, [], 2);
    
    x_p = x_pp - cord_diff(1)+1; % change x and y as a coordinate of planet
    y_p = planet_size(2) - (y_pp - cord_diff(2))-50+1;
    
    if(etime(clock,t0) > 40) % After 40sec, diplay 'No Fuel' Message
        NoFuel(planetRect,dstnt,deg,Chall1TimeLimit);
        end_flag = 1;
    end
    
    clk = sum(buttons);
    if (clk == 1) && (etime(clock,t0) - last_clk > 0.25) % if Mouse clicked, refractory period is 0.25 sec.
        global_t = etime(clock,timer);
        t = etime(clock,t0); % click time
        last_clk = t;
        
        if(xCenter+ExpRectSize(1)./4+20 < x && x < xCenter+ExpRectSize(1)./4 + 150 && yCenter - ExpRectSize(2)./2-30 < y && y < yCenter-ExpRectSize(2)./2 + 60) % if user click 'back' button
            end_flag = 1;
            break;
        end
        
        % calculate gain
        gain = 0;
        raw_rwd = gain;
        inside_chk = mod(sum(x > planet_X_range),2) && mod(sum(y > planet_Y_range),2);
        if(inside_chk) % if not click outside of planet and
            pos_sum = sum(Dist_grid_pos(y_p,x_p,:));
            neg_sum = sum(Dist_grid_neg(y_p,x_p,:));
            
            theta = [pos_sum neg_sum];
            value = rand(1, 2);
            gain = 0;
            gain = gain + sum ((theta < value) .* [Rwd Pnlty]);
            raw_rwd = gain;
            %                 gain = 0.25 * gain;
        end
        
        % calculate bonus
        if(touch_time < 1)
            bonus = 1;
        elseif(touch_time <3)
            bonus = touch_time;
        else
            bonus = 3;
        end
        
        gain = bonus * gain;
        
        %             make string for gain
        RewardString = ['?'];
        gain_len = length(RewardString).*5;
        x_pre = x_pp;
        y_pre = y_pp;
        
        %make string for bonus
        bonus = round(bonus*100)/100;
        BonusString = ['x',num2str(bonus)];
        
        
        %record
        event_vec = [planet_num,global_t, t, x_p, y_p, raw_rwd, gain,touch_time,start_marker]; % record any mouse button click
        mouse_event = [mouse_event; event_vec]; %Output
    end
    
    %draw gain
    if((etime(clock,t0) - last_clk < 0.2) && exist('gain','var'))
        DrawFormattedText(window, RewardString, x_pre-gain_len,y_pre-100, white);
    end
    
    %draw bonus
    if((etime(clock,t0) - last_clk < 0.2))
        DrawFormattedText(window, BonusString, xCenter + ExpRectSize(1)./2,yCenter - ExpRectSize(2)./2, white);
        EmptybaseRect = [0 0 100 15];
        EmptyRects = CenterRectOnPointd(EmptybaseRect,xCenter + ExpRectSize(1)./2 + 50, yCenter - ExpRectSize(2)./2 - 20);
        FillbaseRect = [0 0 (bonus-1) * 50 15];
        FillRects = CenterRectOnPointd(FillbaseRect,xCenter + ExpRectSize(1)./2 + (bonus-1) * 25, yCenter - ExpRectSize(2)./2 - 20);
        Screen('FrameRect', window, white, EmptyRects);
        Screen('FillRect', window, white, FillRects);
        
    end
    
    % back to the space text print
    DrawFormattedText(window, 'Back', xCenter+ExpRectSize(1)./4+50 , yCenter-ExpRectSize(2)./2, white);
    
    String1 = double('행성 안을 클릭해 점수를 모으세요.');
    DrawFormattedText(window, String1, 'center' , yCenter-ExpRectSize(2)./2 -110, white);
    
    
    
    %draw planet shape
    %     DrawPlanet(window,deg,dstnt,[xCenter, yCenter - ExpRectSize(2)./2]);
    
    % Flip to the screen
    Screen('Flip', window);
end
end


