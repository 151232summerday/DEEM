function[vel_def]=eva_func_deficit_caching(interval_dir_num,N,coordinate,theta,a,kappa,R)

% N : the fixed number of wind turbines
% cooridinate : the coordinates of every wind turbines(1*2N)
% theta : the value of the wind direction
% a : the axial induction factor
% kappa : the spreading constant for land case
% R : the rotor diameter

global thetaVeldefijMatrix;
global turbineMoved;

vel_def(1 : N) = 0;
movedTurbine = 1;
for i=1:N
    if(turbineMoved(i) == 1)
        movedTurbine = i;
    end
end

for i = 1 : N

    vel_def_i = 0;
  
    if(i ~= movedTurbine)
        [affected, dij] = downstream_wind_turbine_is_affected(coordinate,movedTurbine,i,theta,kappa,R);
        if(affected)  
            def = a / (1 + kappa * dij / R)^2;
            def = restrict(def, 1);
        else      
            def = 0;
        end 
        vel_def_i = sum((thetaVeldefijMatrix(i,:,interval_dir_num)).^2) - (thetaVeldefijMatrix(i,movedTurbine,interval_dir_num))^2 + def^2;
        thetaVeldefijMatrix(i,movedTurbine,interval_dir_num) = def;
    else
        for j = 1 : N   
            [affected,dij] = downstream_wind_turbine_is_affected(coordinate,j,i,theta,kappa,R);
            if(affected)  
                def = a / (1 + kappa * dij / R)^2;
                def = restrict(def, 1);
            else
                def = 0;      
            end
            vel_def_i = vel_def_i + def^2; 
            thetaVeldefijMatrix(i,j,interval_dir_num) = def;
        end
    end
    vel_def_i = restrict(vel_def_i, 1);
    vel_def(i) = sqrt(vel_def_i);
end
end

function[affected,dij] = downstream_wind_turbine_is_affected(coordinate,upstream_wind_turbine, ...,
    downstream_wind_turbine,theta,kappa,R)
    affected = 0;
    Tijx = (coordinate(2 * downstream_wind_turbine - 1) - coordinate(2 * upstream_wind_turbine - 1));
    Tijy = (coordinate(2 * downstream_wind_turbine) - coordinate(2 * upstream_wind_turbine));
    dij = cosd(theta) * Tijx + sind(theta) * Tijy;
    lij = sqrt((Tijx^2 + Tijy^2) - (dij)^2);
    l = dij * kappa + R;
    if((upstream_wind_turbine ~= downstream_wind_turbine) && (l > lij-R) && (dij > 0))
        affected = 1;
    end
end

function[res] = restrict(src,bound)
    if(src > bound)
        res = bound;
    else
        res = src;
    end
end