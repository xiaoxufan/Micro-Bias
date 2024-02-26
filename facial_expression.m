 
clear all
Screen('Preference', 'SkipSyncTests', 1);

%%  Experment information
blackrockData = 1;
patient_ID=input('Patient_ID? ("YXX"):','s');
emu_run_No=input('EMU Run number? :');
run_No=input('Run number? 1 or 2 :');
seqdir=[pwd '/Data/' patient_ID];
runseq=Create_sequence_100;
if run_No==1
    % seq=Create_sequence_100;
    mkdir(seqdir)
    % save([seqdir '/seq.mat'],'seq');
    % runseq=seq(1:size(seq,1)/3,:);
% elseif run_No==2
%     load([seqdir '/seq.mat'])
%     runseq=seq(size(seq,1)/3+1:2*size(seq,1)/3,:);
% elseif run_No==3
%     load([seqdir '/seq.mat'])
%     runseq=seq(2*size(seq,1)/3+1:end,:);
end
%% Prepare Parameter

dis=2000; % distance between participants and screen
n_trials=size(runseq,1);
path=pwd;
backgroundColor_widow = 100; 
whichscreen=2; %%0 is two screen;1 is no.1 screen;2 is no.2 screen
[windowPtr, rect]=Screen('OpenWindow',whichscreen,backgroundColor_widow);
[width,height] = RectSize(rect); %size of screen

videoData=1;
%% Flicker

baseRect = [0 0 50 50];
flickerColor = [255 255 255];
flickerLocation = flickerRectLoc(windowPtr,baseRect,'BottomLeft');

%% Size setup (in degree)

%size of stimuli=864*1080
size1=2*calculateEccentic(12/2,dis);% in degree
size2=2*calculateEccentic(15/2,dis);% in degree
destinationRect=CenterRect([0 0 size1 size2], rect);
% Fixation in pixel
FixationRect=CenterRect([0,0,12,12],rect);

%% key Setup 

KbName('UnifyKeyNames');
leftKey=KbName( 'w');% Left
rightKey=KbName( 'o'); %Right
escapekey = KbName('ESCAPE');
startkey=KbName('SPACE');
% TriggerKey = KbName('5%');

%% Make texture

for i=1:size(runseq,1)
    dir1=cat(2,path,'/pic');
    image=imread([dir1 '/f' int2str(i) '.png']);
    picture(i)=Screen('MakeTexture',windowPtr,image);
end

%% Before start
Screen('TextSize', windowPtr, 50); 
HideCursor; 
Screen('FillRect',windowPtr,backgroundColor_widow);
Ins1='Press left button if you think the face is happy.';
Ins2='Press right button if you think the face is sad.';
Ins3='Press SPACE to start experiment and recording.';
Screen('DrawText',windowPtr,Ins1,rect(3)/4,rect(4)/3);
Screen('DrawText',windowPtr,Ins2,rect(3)/4,(rect(4)/3)+100);
Screen('DrawText',windowPtr,Ins3,rect(3)/4,(rect(4)/3)+200);
Screen('Flip',windowPtr);

[touch, secs, keyCode] = KbCheck(-1);
touch = 0;
while ~(touch && (keyCode(startkey) || keyCode(escapekey)))
	[touch, secs, keyCode] = KbCheck(-1);
end
keyCode(startkey)=0;

Screen('FillRect',windowPtr,backgroundColor_widow);
Screen('Flip',windowPtr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start BlackRock Aquisition %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

savefname = ['EMU-' num2str(emu_run_No,'%03d') '_subj-' patient_ID '_task-facial_expression_run-' num2str(run_No)];
incr=2;
while exist(savefname,'file')
    savefname(end-1:end) = sprintf('%02d',incr);
    incr=incr+1;
end

if blackrockData == 1
%     [onlineNSP,blackrockData,video]=StartBlackrockAquisition(savefname,videoData);
onlineNSP=TaskComment(savefname,'start'); 
end

WaitSecs(1);

%% Main program 

QuitFlag=0;
answer=cell(n_trials,5); % answer and RTtime
t_on=GetSecs;
%=========================== Loop start ==================================

for trial=1:n_trials

    stim=picture(runseq(trial,2));

    ts=GetSecs;
    firstFrameEachStim = 1;  %A variable to set the label for the first frame of each stim
    while 1       
        if GetSecs-ts>0.4
            Screen('DrawTexture',windowPtr,stim,[],OffsetRect(destinationRect,0,0));
            Screen('DrawText',windowPtr,[num2str(trial) '/104'],rect(3)*3/4,rect(4)*9/10);
            Screen('Flip',windowPtr);
        else
            Screen('DrawTexture',windowPtr,stim,[],OffsetRect(destinationRect,0,0));
            Screen('FillRect',windowPtr, flickerColor, flickerLocation, 1); %flicker
            Screen('DrawText',windowPtr,[num2str(trial) '/104'],rect(3)*3/4,rect(4)*9/10);
            Screen('Flip',windowPtr);
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if firstFrameEachStim
            switch runseq(trial,1)
                case 1
                    commentWord='1 100% happy';
                case 2
                    commentWord='2 100% sad';
                case 3
                    commentWord='3 10% happy';
                case 4
                    commentWord='4 10% sad';
            end
            
            if blackrockData == 1
                for jj = onlineNSP % this uses the output of TaskComment to determine how many NSPs are online
                    cbmex('comment',167,0,commentWord,'instance',jj-1);
                    %added cbmex comment gets sent to each NSP (1=NSP-2 and 0=NSP1)
                end
%                 cbmex('comment', 167, 0, commentWord);
            end
            firstFrameEachStim = 0;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         % ==== check answer
            [keyIsDown,timeSecs ,keyCode] = KbCheck(-1);
            if keyIsDown && keyCode(rightKey)
                answer{trial,1}=1;
                answer{trial,2}='perceived happy';
                answer{trial,3}=timeSecs-ts;
                if blackrockData == 1
                    for jj = onlineNSP % this uses the output of TaskComment to determine how many NSPs are online
                        cbmex('comment',255,0,answer{trial,2},'instance',jj-1);
                        %added cbmex comment gets sent to each NSP (1=NSP-2 and 0=NSP1)
                    end
%                     cbmex('comment',255, 0, answer{trial,2});
                end
                break
            elseif keyIsDown && keyCode(leftKey)
                answer{trial,1}=-1;
                answer{trial,2}='perceived sad';
                answer{trial,3}=timeSecs-ts;
                if blackrockData == 1
                    for jj = onlineNSP % this uses the output of TaskComment to determine how many NSPs are online
                        cbmex('comment',255,0,answer{trial,2},'instance',jj-1);
                        %added cbmex comment gets sent to each NSP (1=NSP-2 and 0=NSP1)
                    end
%                     cbmex('comment', 255, 0, answer{trial,2});
                end
                break
            elseif (touch && keyCode(escapekey))
                QuitFlag=QuitFlag+1;
                break
            end
            keyIsDown=0;
         % ====
    end
    Screen('FillRect',windowPtr,backgroundColor_widow);
    Screen('Flip',windowPtr);
    % ==== Assign answer value
    answer{trial,4}=runseq(trial,1);
    answer{trial,6}=runseq(trial,2);
    switch runseq(trial,1)
        case 1
            answer{trial,5}='100% happy';
        case 2
            answer{trial,5}='100% sad';
        case 3
            answer{trial,5}='10% happy';
        case 4
            answer{trial,5}='10% sad';
    end
    % ====
    
    % Quit ~~~~~~~~~~~
    if QuitFlag~=0
        disp('Got it. Exit right now.')
        % Stop Blackrock
        TaskComment(savefname,'kill');         
        exitTask(patient_ID,savefname,answer);
        return
    end
    % Quit ~~~~~~~~~~~
    WaitSecs(0.5);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Stop BlackRock Aquisition %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ShowCursor;
if blackrockData == 1
    TaskComment(savefname,'stop');
%     StopBlackrockAquisition(savefname,onlineNSP,video);
end

exitTask(patient_ID,savefname,answer);

function exitTask(patient_ID,savefname,answer)
Screen('CloseAll');
% t_off=GetSecs;
% disp(['total time is ' num2str(t_off-t_on) ' s'])
%% Save answer
savedir = fullfile(userpath,'PatientData',patient_ID,'Micro-Bias');
if ~exist(savedir,'dir')
    mkdir(savedir)
end
filename = [savefname,'_',datestr(now,'YYYYmmDDHHMM'),'.mat'];
save(fullfile(savedir,filename),'answer');
end

