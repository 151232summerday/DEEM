%evaluation function for phase two (velocity deficit)

function[vel_def]=eva_func_deficit_caching(interval_dir_num,N,coordinate,theta,a,kappa,R)

% N : the fixed number of wind turbines
% revise_Dx : the length of wind cell in X axis direction
% revise_Dy : the length of wind cell in Y axis direction
% cooridinate : the coordinates of every wind turbines(1*2N)
% theta : the value of the wind direction
% a : the axial induction factor
% kappa : the spreading constant for land case
% R : the rotor diameter

global thetaVeldefijMatrix;
global turbineMoved;

%calculate the distance between the uptream and downstream turbines in one direction(theta)
vel_def(1:N)=0;
temp = 0;
movedTurbine = 1;
for i=1:N
    if(turbineMoved(i)==1)
        movedTurbine = i;
    end
end

for i=1:N
   vel_def_i=0;
  
   if(i~=movedTurbine)
   
      Tijx=(coordinate(2*i-1)-coordinate(2*movedTurbine-1));
      Tijy=(coordinate(2*i)-coordinate(2*movedTurbine));
      dij=cosd(theta)*Tijx+sind(theta)*Tijy;
      lij=sqrt((Tijx^2+Tijy^2)-(dij)^2);
      l=dij*kappa+R; 
%        fprintf('The  turbine is %d\n',j);
%        disp(cosd(theta)*Tijx*revise_Dx);
%        disp(sind(theta)*Tijy*revise_Dy);
%        fprintf('The distance of turbine %d is %f\n',j,dij);   

      if((movedTurbine~=i)&&(l>lij-R)&&(dij>0))  %turbine i is under the effect of turbine j
          def=a/(1+kappa*dij/R)^2;
          if (def>1)
              def=1;
          end
          temp = def;
      else      %turbine i isn't under the effect of turbine j
          temp = 0;
      end 
      %vel_def_i = sum((thetaVeldefijMatrix{interval_dir_num}(i,:)).^2) - (thetaVeldefijMatrix{interval_dir_num}(i,movedTurbine))^2 + temp^2;
      %thetaVeldefijMatrix{interval_dir_num}(i,movedTurbine) = temp;
      vel_def_i = sum((thetaVeldefijMatrix(i,:,interval_dir_num)).^2) - (thetaVeldefijMatrix(i,movedTurbine,interval_dir_num))^2 + temp^2;
      thetaVeldefijMatrix(i,movedTurbine,interval_dir_num) = temp;
   else
           for j=1:N
                Tijx=(coordinate(2*i-1)-coordinate(2*j-1));
                Tijy=(coordinate(2*i)-coordinate(2*j));
                 dij=cosd(theta)*Tijx+sind(theta)*Tijy;
                 lij=sqrt((Tijx^2+Tijy^2)-(dij)^2);
                 l=dij*kappa+R; 
%        fprintf('The  turbine is %d\n',j);
%        disp(cosd(theta)*Tijx*revise_Dx);
%        disp(sind(theta)*Tijy*revise_Dy);
%        fprintf('The distance of turbine %d is %f\n',j,dij);   

               if((j~=i)&&(l>lij-R)&&(dij>0))  %turbine i is under the effect of turbine j
                  def=a/(1+kappa*dij/R)^2;
                  if (def>1)
                      def=1;
                  end
                  temp = def;
                  vel_def_i=vel_def_i+def^2;  
               else
                  temp = 0;
                  vel_def_i=vel_def_i+0;      %turbine i isn't under the effect of turbine j
               end
               %thetaVeldefijMatrix{interval_dir_num}(i,j) = temp;
               thetaVeldefijMatrix(i,j,interval_dir_num) = temp;
          end
   end
      
      
      
   if(vel_def_i>1)
       vel_def_i=1;
   end
   vel_def(i)=sqrt(vel_def_i);
  % fprintf('The velocity deficit of turbine %d is %f\n',i,vel_def(i));
end

end