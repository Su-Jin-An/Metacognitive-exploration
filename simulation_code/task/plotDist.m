function [E_grid] = plotDist(Dist_grid_pos,Dist_grid_neg,planet_size,mode)
global Rwd; global Pnlty;
global DirName;
global planet_num;
Dist_size = planet_size+1;
before_name = sprintf('./%s/%s_Planet%d_Dist',DirName,mode,planet_num);

%make mesh grid
xgv = 1:planet_size(1);
ygv = 1:planet_size(2);
[X,Y] = meshgrid(xgv,ygv);

%plot Expected value until 30sec
E_grid = (1-Dist_grid_pos).*Rwd + (1-Dist_grid_neg).*Pnlty;
h1 = figure('Visible','Off');surf(X,Y,E_grid);
colormap(flipud(jet))
colorbar;
view([0 90]);
title_string = sprintf('Expected value in planet %d',planet_num);
title(title_string);
xlim([1 Dist_size(1)]);
ylim([1 Dist_size(2)]);
set(h1,'units','pix','pos',[0,0,800,800]);
saveas(h1,before_name,'jpg');
end