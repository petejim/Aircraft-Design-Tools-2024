function [bregTypes, dists, velocs, densitys, SFCs, wPayload, WS, EWF, totalDist] = testCaseGen(nSeg)
% Creates random varition of segments for model validation

bregTypes = randi([0,2],1,nSeg);

totalDist = randi([19000,21000],1); % random total mission distance

randnum = rand(1,nSeg); % get nSeg amount of random fractions
normrandnum = randnum./sum(randnum); % ensure random fractions add to 1
dists = normrandnum.*totalDist; % multiply total distance by random fractions for segments

velocs = randi([80,130],1,nSeg);

densitys = 0.002 + (0.001545-0.002).*rand(1,nSeg); %0.002377 + (0.001545-0.002377).*rand(1,nSeg); % from SL to 14k ft standard

SFCs = 0.25 + (0.35-0.25).*rand(1, nSeg); % r = a + (b-a).*rand(N,1)

wPayload = randi([600,900],1);

WS = randi([25,34],1);

EWF = 0.17 + (0.25-0.17).*rand(1); % FIND RANGE, r = a + (b-a).*rand(N,1)

end