%Description:
%This routine takes the centroids mat generated by m1*.m to assists the
%2D guassian fit on the unfiltered image - dgrayIm. It does both an
%isotropic and anisotropic fit. TO optimise the process, the fit is done
%only on a selected area of interest rather than the whole image. Therefore
%the window to fit (ie size and position) dynamically varies with each 
%centroid position. 

%problems:
%#1 the size of window to fit drastically changes the fit -> need to optimised
%this
%#2 need to retrieve te error of fit (ie confidence band etc)

%**************************************************
%*******Options************************************
%Option 1: fit masked by constant noise
%Option 2: fit on constant noise

fitOp=2;

redraw=0; %0: no figure to compare x-section 1: yes
drawMask=1;


%**************************************************
%*******data inputs********************************
%**************************************************

center=centroids(:,1:2); %retrieve the est center points of skx
radius=centroids(:,3); %retrieve the est radius of skx
im=dgrayIm; %original image to fit on
[m,n]=size(im);

    %fit parameters:
    %7 parameters: xi,yi,c,a,noise,residue,jacobian
    fiti = zeros(length(center),7); %initialization
    xyfit = zeros(length(center),7); %store aniso fit
    isofit =zeros(length(center),7); %store iso fit


    %fit option (on or masked by noise):
    if fitOp==1
        noiseub=0;
        noiselb=0;
    else
        noiseub=255;
        noiselb=0;    
    end
    
%**************************************************
%*******fit routine********************************
%**************************************************
%individually fitted
[l,~]=size(center);
minR=0.4;
maxR=4;
stepR=0.4;
stdevRes=zeros(l,int8(maxR-minR)/stepR);
sigFit=zeros(l,int8(maxR-minR)/stepR);
    for i = 1:l
        ind=1;
        for range=(minR:stepR:maxR);
            %range
            r=range*radius(i);
            %***dynamic mesh routine***
            %***define a bounding box that encloses the skx****
            %*** fit is done in the defined box****
            x1=(int16(center(i,1)-r));
            x2=(int16(center(i,1)+r));

            y1=(int16(center(i,2)-r));
            y2=(int16(center(i,2)+r));

            %*****Handle pointers out of matrix range*******
                if x1<1;
                    x1=1;
                end
                if x2>n
                    x2=n;
                end
                if y1<1;
                    y1=1;
                end
                if y2>m
                    y2=m;
                end

            %Portion of image to be fitted based on bounding box
            portion=dgrayIm(y1:y2,x1:x2);%portion to be fitted

            %%******fit routine********
            opts_iso.iso=true;
            opts_tilted.tilted=false;
            zi=portion;
            [yf,xf]=size(portion);
            [xi,yi] = meshgrid(-((xf-1)/2):((xf-1)/2),-((yf-1)/2):((yf-1)/2));
            tmpiso= autoGaussianSurf(xi,yi,zi,opts_iso);
            %tmpxy = autoGaussianSurf(xi,yi,zi,opts_tilted);
            %xyfit(i,1:5) = [tmpxy.x0+double(center(i,1)) tmpxy.y0+double(center(i,2)) tmpxy.sigmax tmpxy.sigmay tmpxy.sigmax/tmpxy.sigmay];
            isofit(i,1:5) = [tmpiso.x0+double(center(i,1)) tmpiso.y0+double(center(i,2)) tmpiso.sigma tmpiso.a tmpiso.b];
            
            %****getting the residue*****
            residue=zi-tmpiso.G;
            [~,sigmahat] = normfit(residue(:));
            stdevRes(i,ind)=sigmahat;
            sigFit(i,ind)=tmpiso.sigma;
            ind=ind+1;

        end
        
        msg=sprintf('skyrmion %i fitted',i);
        disp(msg);
        
                %********cross section plots for visual relief LOL **************
        if redraw==1
            zi = a*exp(-((xi-x0).^2/2/sigma^2 +(yi-y0).^2/2/sigma^2)) + b;
            mask=Gfun2D(size(im),fiti(i,1),fiti(i,2),fiti(i,3),fiti(i,4),fiti(i,5));

            %*****boundary for ploting*****
            a1=int16(fiti(i,1)-3*fiti(i,3));
            a2=int16(fiti(i,1)+3*fiti(i,3));
            if a1<1
                a1=1;
            end
            if a2>length(mask)
                a2=length(mask);
            end

            %*****plot figure*****     
            figure
            if fiti(i,2)>0 && fiti(i,2)<=length(mask)

                plot(a1:a2,mask(fiti(i,2),a1:a2));%fit plot
                hold on;
                plot(a1:a2,im(fiti(i,2),a1:a2));%actual image plot

            end
        end
    end
    figure
    plot((minR:stepR:maxR),sigFit(1,:));
    figure
    plot((minR:stepR:maxR),stdevRes(1,:));
    figure
    plot(diff(stdevRes(1,:)));
    figure
    imshow(dgrayIm,[0,max(max(dgrayIm))])
    for i = 1:length(isofit)
        hold on
        plot(isofit(i,1),isofit(i,2),'r.','MarkerSize',10);
    end
%**************************************************
%*******consoladation********************************
%**************************************************    
    figure
    histfit(isofit(:,3)*2.3548*5/1024);
    %[mu, sigma] = normfit(fit(:,3),10);
    mu=mean(isofit(:,3));
    sigma=std(isofit(:,3));
    
    filteredIndex = ((isofit(:,3)>(mu-sigma)).*(isofit(:,3)<(mu+sigma)))>0;
    filteredFit=isofit(filteredIndex,3);
    
    figure
    histfit(filteredFit*2.3548*5/1024);
    FWHM=mu*2*(2*log(2))^0.5;
    FWHMer=sigma*2*(2*log(2))^0.5;
    
    figure
    imshow(dgrayIm,[0,max(max(dgrayIm))])
    
%%drawing and saving the image
[m,n]=size(binIm);
whiteImage = 255 * ones(m, n, 'uint8');
for i = 1:length(isofit)
    
    whiteImage(round(isofit(i,1)),round(isofit(i,2)))=false;
end

whiteImage=logical(whiteImage);
imwrite(whiteImage,'white.png','png');

% gh=figure;
% imshow(whiteImage)
% 
%     
f=getframe(gca);
[X, map] = frame2im(f);
imwrite(X,'white.png','png');
    