function [] = display_msg(msgString,xPos,yPos)
    % Window Setting
    global window;
    white = WhiteIndex(window);
    
    % Display message String
    StrBound = Screen('TextBounds',window,msgString);
    DrawFormattedText(window, msgString, xPos-StrBound(3)./2,yPos, white);
end