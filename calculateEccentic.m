function Offset = calculateEccentic(E,d)
% Offset = calculateEccentic(E,d)
% d(mm)
% E(du)

x=tan(E*pi/180)*d;
rect=[0 0 1920 1080];
% get(0,'ScreenSize');
% rect=Screen('Rect', max(Screen('Screens')));
%[width, height]=Screen('DisplaySize', max(Screen('Screens')));
width=1235; % in mm
Offset=x*rect(3)/width;
end






