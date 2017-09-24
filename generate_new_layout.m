function[muSolution]=generate_new_layout(newpoint, solution, N,...,
                     X,Y,minimumDistance1)

    global turbineMoved;
    solutionBackup = solution;
    mutatedNodes(1:size(solution,2)) = 0;
    currentNode = ceil(rand()*N);
    mutatedNodes(currentNode) = 1; 
    turbineMoved(currentNode) = 1;

    %Update solution
    solution(2 * currentNode-1) = newpoint(1);
    solution(2 * currentNode) = newpoint(2);
    
    %Get nearest neighbours
    [neighbourIndex, distanceFromNode] = computeNeighbours(solution, currentNode);%ÉýÐò
    
    if(~isInBounds(newpoint(1), newpoint(2),X,Y)||isTooCloseToOtherNodes(solution, currentNode, neighbourIndex,minimumDistance1))         
       muSolution = solutionBackup;
    else 
       muSolution = solution;
    end

end

function[bool]=isInBounds(x,y,boundX,boundY)

    bool=(x>=40)&&(y>=40)&&(x<=boundX-40)&&(y<=boundY-40);

end

function[bool]=isTooCloseToOtherNodes(variables, currentNode, neighbourIndex,minimumDistance1) 
    
    if(determineDistance(variables, currentNode, neighbourIndex(1))<minimumDistance1)
        bool = 1;
    else
        bool = 0;
    end
    
end

function[index, distance] = computeNeighbours(variables, node)

    numNodes = size(variables,2)/2;
    neighbours(1:numNodes-1) = 0;
    for neighbour = 1:(node-1)
        neighbours(neighbour) = determineDistance(variables, node, neighbour);
    end
    for neighbour = (node+1):numNodes
        neighbours(neighbour-1) = determineDistance(variables, node, neighbour);
    end

    [distance, index] = sort(neighbours);
    for i=1:numNodes-1
        if(index(i)>node-1)
            index(i) = index(i)+1;
        end
    end
end

function[distance]= determineDistance(variables, node1, node2);

    xDiff = variables(2 * node1-1) - variables(2 * node2-1);
    yDiff = variables(2 * node1) - variables(2 * node2);

    distance = sqrt(xDiff*xDiff + yDiff*yDiff);
end