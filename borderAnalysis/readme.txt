The main lines are 27-36. The rest is book keeping or matrix reorganization (which depends on how the seeds are organized)

 
The main thing is that you calculate a pixel-pixel correlation matrix (called “R_seed_VM” in the attached code), then the 
spatial dot product (line 27) then find the borders (line 33; I think the spatial derivative of the similarity matrix is 
done in the “edge” function)