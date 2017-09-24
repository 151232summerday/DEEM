function[newLayout] = generate_new_layout(newPos, layout, N, X, Y, minDistance)

    global turbineMoved;
    newLayout = layout;
    curTurbine = ceil(rand() * N); 
    turbineMoved(curTurbine) = 1;

    %Update layout
    layout(2 * curTurbine - 1) = newPos(1);
    layout(2 * curTurbine) = newPos(2);
    
    %Get nearest neighbours
    [neighbourIndex, ~] = computeNeighbours(layout, curTurbine);
    
    if(isInBounds(newPos(1), newPos(2), X, Y) && ~isTooCloseToOtherNodes(layout, curTurbine, neighbourIndex, minDistance))         
       newLayout = layout;
    end
end

function[bool] = isInBounds(x, y, boundX, boundY)

    bool = (x >= 40) && (y >= 40) && (x <= boundX - 40) && (y <= boundY - 40);
end

function[bool] = isTooCloseToOtherNodes(layout, curTurbine, neighbourIndex,minDistance) 
    
    if(determineDistance(layout, curTurbine, neighbourIndex(1)) < minDistance)
        bool = 1;
    else
        bool = 0;
    end
end

function[index, distance] = computeNeighbours(layout, curTurbine)

    numTurbines = size(layout, 2) / 2;
    neighbours(1 : numTurbines - 1) = 0;
    for neighbour = 1 : (curTurbine - 1)
        neighbours(neighbour) = determineDistance(layout, curTurbine, neighbour);
    end
    for neighbour = (curTurbine + 1) : numTurbines
        neighbours(neighbour - 1) = determineDistance(layout, curTurbine, neighbour);
    end

    [distance, index] = sort(neighbours);
    for i=1 : numTurbines-1
        if(index(i) > curTurbine - 1)
            index(i) = index(i) + 1;
        end
    end
end

function[distance] = determineDistance(layout, Turbine1, Turbine2)

    xDiff = layout(2 * Turbine1-1) - layout(2 * Turbine2-1);
    yDiff = layout(2 * Turbine1) - layout(2 * Turbine2);
    distance = sqrt(xDiff * xDiff + yDiff * yDiff);
end