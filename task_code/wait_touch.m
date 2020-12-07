function [] = wait_touch(msgString,xPos,yPos, Gain)
% Window Setting
global window;
white = WhiteIndex(window);

% diplay gain
if nargin > 3
    gain_string = double(sprintf('Á¡¼ö: %s',num2str(sum(Gain))));
    GainStrBound = Screen('TextBounds',window,gain_string);
    DrawFormattedText(window, gain_string, xPos-GainStrBound(3)./2,yPos-100, white);
end
Screen('Flip', window);
wait2sec = clock;

while(~get_win_touch || etime(clock,wait2sec) < 1)
    tmp_yPos = yPos;
    for ii = 1:length(msgString)
        StrBound = Screen('TextBounds',window,msgString{ii});
        DrawFormattedText(window, msgString{ii}, xPos-StrBound(3)./2,tmp_yPos, white);
        Screen('TextSize', window, 25);
        tmp_yPos = tmp_yPos + 50;
    end
    Screen('Flip', window);
end

end