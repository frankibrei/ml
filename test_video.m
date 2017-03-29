% video test
% 
vid_fn1='C:\\Temp\\ff5_stampfer_3.avi';
vid_fn2='C:\\Temp\\ff9_saege_2.avi';
vid_fn3='C:\\Temp\\ff12_ruehrbesen_2.avi';
% len=8192;
% freq=100;
% y=zeros(len,2);
% y(:,1)=sin([1:len]*2*pi*freq);
% y(:,2)=y(:,1);
% %implay(vid_fn);
% h = implay(vid_fn);
% sound(y);
% play(h.DataSource.Controls);

% videoFReader = vision.VideoFileReader(vid_fn);
% videoPlayer = vision.VideoPlayer;
% 
% nstep=0;
% while ~isDone(videoFReader)
%    frame = step(videoFReader);
%    step(videoPlayer,frame);
%    nstep=nstep+1;
% end
% nstep
% 
% file1 = fullfile('C:\\Temp\\','ff5_stampfer_3.avi');
% pdMovie1 = aviread(file1);
% fileinfo1 = aviinfo(file1)

avi = VideoReader(fullfile(vid_fn1));
ii = 1;
while hasFrame(avi)
   mov1(ii) = im2frame(readFrame(avi));
   ii = ii+1;
end

avi = VideoReader(fullfile(vid_fn2));
ii = 1;
while hasFrame(avi)
   mov2(ii) = im2frame(readFrame(avi));
   ii = ii+1;
end

avi = VideoReader(fullfile(vid_fn3));
ii = 1;
while hasFrame(avi)
   mov3(ii) = im2frame(readFrame(avi));
   ii = ii+1;
end


f = figure('Color',[0 0 0]);
f.Position = [300 300 avi.Width avi.Height];

ax = gca;
ax.Units = 'pixels';
ax.Position = [0 0 avi.Width avi.Height];

%image(mov(1).cdata,'Parent',ax)
axis off

 set(gca,'Color',[0.8 0.8 0.8]);
set(gca,'Color',[0 0 0]);

movie(mov1,1,avi.FrameRate);

ii

movie(mov2,1,avi.FrameRate);

movie(mov3,1,avi.FrameRate);


