%cut down the partical fly speed
function[speed]=cut_down_speed(x,speed)

% x : the length of constrained boundary 
% speed : the flying speed of partical

a= x/10;
while(1)
   if (abs(speed)>a)
       speed=speed/2;
   else
       break;
   end
   %fprintf('the new speed is %.4f\n',speed)
end
end