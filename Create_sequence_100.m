function seq=Create_sequence_100
%% Create stimuli presequence- preseq(:,1) is picture number; preseq(:,2) is female/male/old/young ; preseq(:,3) is condition

% create con1 con2 ============
x1=[];
for i=1:8
    x1=[x1 randperm(13)];
end
x1(2,:)=repelem((1:8),13);
x1=x1';
x1(:,3)=repelem([1 2],13*4);
prex1=Shuffle(x1,2);



%% Assign picture number

y1=[repelem((1:8),13) repelem((9:16),26)]';

for k=1:size(prex1,1)
    A=find(y1==prex1(k,2));
    prex1(k,4)=A(prex1(k,1));
end

seq=prex1(:,3:4);

end










    