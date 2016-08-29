function [ Gr ] = RDF( points,im,nSteps )
%RDF Summary of this function goes here
%   Detailed explanation goes here

[m,n]=size(im);

midptX=m/2;
midptY=n/2;

distXY=sqrt((points(:,1)-midptX).^2+(points(:,2)-midptY).^2);
[~,minInd]=min(distXY);

avgD=length(points)/(m*n);
%%for verification
% figure;
% plot(points(:,1),points(:,2),'b.');
% hold on
% plot(points(minInd,1),points(minInd,2),'r.')
maxR=min([points(minInd,1),points(minInd,2),m-points(minInd,1),n-points(minInd,2)]);
distXYr=sqrt((points(:,1)-points(minInd,1)).^2+(points(:,2)-points(minInd,2)).^2);
distXYr_fil=distXYr(distXYr<maxR);

[localN,edges]=histcounts(distXYr_fil,nSteps);
Gr=zeros(1,length(localN));
for i=1:length(localN)
    localV=pi*((edges(i+1))^2-(edges(i))^2);
    localD=localN(i)/localV;
    Gr(i)=localD/avgD;
end

end

