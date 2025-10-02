function kOptimal = findElbow(distortions)
    nPoints = length(distortions);
    allCoord = [1:nPoints; distortions]';
    firstPoint = allCoord(1, :);
    lastPoint = allCoord(end, :);
    
    lineVec = lastPoint - firstPoint;
    lineVecNorm = lineVec / norm(lineVec);
    
    vecFromFirst = allCoord - firstPoint;
    
    scalarProduct = vecFromFirst * lineVecNorm';
    
    proj = scalarProduct * lineVecNorm;
    
    distanceToLine = vecnorm(vecFromFirst - proj, 2, 2);
    
    [~, kOptimal] = max(distanceToLine);
end