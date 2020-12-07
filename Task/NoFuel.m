function [] = NoFuel(planetRect,dstnt,deg,TimeLimit)
global window; global windowRect;
global timer;
global DirName;
global planet_num;

white = WhiteIndex(window);
black = BlackIndex(window);
grey = white / 2;

[xCenter, yCenter] = RectCenter(windowRect);
ExpRectSize = [800 600]; %size of experiment size
while(1)
    buttons = get_win_touch;
    [x, y] = GetMouse(window);
    
    Screen('TextSize', window, 20);
    Screen('FrameRect', window, grey, planetRect);
    % back to the space text print
    DrawFormattedText(window, 'Back', xCenter-ExpRectSize(1)./2 , yCenter-ExpRectSize(2)./2, white);
    %draw planet shape
    %         DrawPlanet(window,deg,dstnt,[xCenter,  yCenter - ExpRectSize(2)./2]);
    % Flip to the screen
    Screen('Flip', window);
    
    MsgString = 'No Fuel';
    NoFuelMsgBound = Screen('TextBounds',window,MsgString);
    DrawFormattedText(window, MsgString, xCenter-NoFuelMsgBound(3)./2,yCenter-70, white);
    
    if(CheckTimeEnd(TimeLimit))
        break;
    end
    
    if (sum(buttons) == 1) % if Mouse clikced, refractory period is 1 sec.
        if(xCenter-ExpRectSize(1)./2-30 < x && x < xCenter-ExpRectSize(1)./2 + 100 && yCenter - ExpRectSize(2)./2-30 < y && y < yCenter-ExpRectSize(2)./2 + 60) % if user click 'back' button
            break;
        end
    end
end
end

