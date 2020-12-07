function [IsEnd] = CheckTimeEnd(TimeLimit)
    global window; global windowRect;
    global timer;
    
    white = WhiteIndex(window);
    [xCenter, yCenter] = RectCenter(windowRect);  
    
    IsEnd = 0; % Time Over?
    RemainTime = TimeLimit - etime(clock,timer); %calculate remain time
    RemainTimeString = [num2str(floor(RemainTime))];
    if(RemainTime < 0) %if end
        IsEnd = 1;
    elseif(RemainTime < 10) % if remain time is less than 10 sec
        DrawFormattedText(window, RemainTimeString, xCenter, 25, white);
    else
        IsEnd = 0;

end

