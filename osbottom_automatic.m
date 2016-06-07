function osbottom_automatic(result_folder,n_steps,gradient_offset,overwrite) 

% by Sebastian Menze, 2016
% call like this:
% osbottom_automatic('D:\S2015843_PHELMERHANSSEN_1173\adcp_processing\geomar\result',50,1,0) 

%% constants
% n_steps=50;
% gradient_offset=1;
% overwrite=1;

% result_folder='D:\S2015843_PHELMERHANSSEN_1173\adcp_processing\geomar\result'

directory_all=dir(fullfile(result_folder,'*_dat.mat'));

dir_size=size(directory_all,1);  

for i_file=1:dir_size
    
    
    
% open file
filename=[result_folder,'\',directory_all(i_file).name];      

watermask_file=filename;
watermask_file(end-7:end)='_bot.mat';

if ~exist(watermask_file) | exist(watermask_file) & overwrite==1

load(filename)

disp(['--> ',num2str(i_file,'%05d'),' find bottom in ',directory_all(i_file).name])
% process data
amp_smooth = smooth2a(  d.amp ,5,20);
    
Gx = [-1 1];
Gy = Gx';
% Ix = conv2(amp_smooth,Gx,'same');
gradient_y = conv2(amp_smooth,Gy,'same');
gradient_y(gradient_y>0)=0;
      
indicies=floor(linspace(1,size(gradient_y,2),n_steps));

x_bottom=size(d.amp,1);

ix=1:n_steps;
x=1:x_bottom;

% figure(5)
% clf
% hold on

for i=ix
       
y=gradient_y(:,indicies(i));
y_matrix(:,i)=y;

bottom_index(i)=abs(sum(y(1:10)))/abs(sum(y(10:end)));
amp_index(i)=abs(sum(amp_smooth(1:10,ix(i))))/abs(sum(amp_smooth(10:end,ix(i))));

if bottom_index(i)>1  % bottom is too close, no usable data    
ix_bottom(i) = 1;
 
else % bottom far enough away
       
gradient_sum(i)=sum(y);

if gradient_sum(i)<-30 % bottom is present
 
[f_gauss,gof_gauss(i)] = fit(x',y,'gauss2');

gaussian(x,i) = feval(f_gauss,x);
   
[~,ix_min]=min(gaussian(:,i));

    ix_bottom(i)=ix_min-gradient_offset;
else % no bottom
    
 
upper_layer_signal=detrend(d.amp(1:30,i));
Y=fft(upper_layer_signal);
L=30;
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

u_l_fft(i,:)=P1;

[f_gauss_2,gof_gauss_2(i)] = fit([1:16]',P1,'gauss1');
gaussian_2 = feval(f_gauss_2,[1:16]');

% plot(P1,'.k')
% plot(gaussian_2,'-r')
% drawnow

    
if f_gauss_2.b1 > 2 &  sum(d.amp(1:30,i)) > 2e03 % bottom is too close, no usable data
ix_bottom(i) = 1;


else
    ix_bottom(i)=x_bottom;
       
end
   
end    
end

end

ix_bottom(ix_bottom<1)==1;

bottom=interp1(indicies,ix_bottom,1:size(amp_smooth,2));

figure(1)
clf

subplot(211)
title(directory_all(i_file).name)
  hold on
 imagesc(d.amp)
  plot(bottom,'-r')
%  plot(indicies,ix_bottom,'or')
 set(gca,'Ydir','reverse','xlim',[0 size(d.amp,2)],'ylim',[0 size(d.amp,1)]  )
  colorbar
  
  subplot(212)
 imagesc(gradient_y)
  hold on
  colorbar
  
%   subplot(313)
%   boxplot(u_l_fft)
 
  drawnow
  
mkdir('automatic_bottom_detection_images')
  set(gcf,'PaperPositionMode','auto')
  print(gcf,'-dtiff',['automatic_bottom_detection_images/bottom_detection_',num2str(i_file,'%05d'),'.tiff'],'-r150') 
%%

watermask=nan(size(d.amp));
for i=1:size(watermask,2)
if bottom>1
watermask(1:bottom(i),i)=1;    
else
end
end

watermask_file=filename;
watermask_file(end-7:end)='_bot.mat';
save(watermask_file,'watermask')

clearvars -except d directory_all dir_size result_folder n_steps gradient_offset overwrite

end

end