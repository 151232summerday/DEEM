% print the gragh of wind farm layout

function print_turbine2(N,X,Y,coordinate)

% N: the number of wind turbines
% n: the number of cell in the row
% m: the number of cell in the col
% dx: the length of the cell in the row
% dy: the length of the cell in the column
% coordinate: the coordinates of wind turbines

figure(1);
clf;
axis([0,X,0,Y]);
set(gca,'xtick',0:100:X);   %set X axis
set(gca,'ytick',0:100:Y);   %set Y axis
% linspace(0,dx,n*dx);
% linspace(0,dy,m*dy);

% grid on;
% set(gca,'gridlinestyle','-','linewidth',1)
% box on;
% hold on;

for i= 1:2:2*N  
    tx=coordinate(i);
    ty=coordinate(i+1);
    plot(tx,ty,'ks','MarkerFaceColor','k','MarkerSize',8);
    hold on;
end
hold off;

end