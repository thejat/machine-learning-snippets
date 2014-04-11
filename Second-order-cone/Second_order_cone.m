clc;clear all;close all;


%% Second order cones in 2D

inpts   = [];
outpts  = [];
xu      =  3;
divb    = 30;

constraint1 = @(i,j) sqrt(i^2) <= j;%cone should contain the origin
% constraint1 = @(i,j) sqrt(i^2 + j^2) <= 2*i + j -3;%not a cone
% constraint1 = @(i,j) (sqrt(i^2) <= j) && (sqrt(i^2) <= 2*j
% -1);%intersection is convex, not a cone

for i=-xu:xu/divb:xu
    for j=-xu:xu/divb:xu
        if (constraint1(i,j))
            inpts = [inpts;i,j];
        else
            outpts = [outpts;i,j];
        end
    end
end
if(~isempty(inpts))
    figure;
    scatter(inpts(:,1),inpts(:,2));
    axis([-xu xu -xu xu])
end


%% Second order cones in 3D
clc;clear all;close all;
inpts   = [];
outpts  = [];
xu      =  3;
divb    = 10;

constraint1 = @(A,i,j,k) norm(A*[i;j],2) <= k;

A = randn(2,2);
for i=-xu:xu/divb:xu
    for j=-xu:xu/divb:xu
        for k=-xu:xu/divb:xu
            if (constraint1(A,i,j,k))
                inpts = [inpts;i,j,k];
            else
                outpts = [outpts;i,j,k];
            end
        end
    end
end
% if(~isempty(inpts))
%     figure;
%     hullcoord = convhulln(inpts);
%     scatter3(inpts(hullcoord(:,1),1),inpts(hullcoord(:,2),2),inpts(hullcoord(:,3),3));
%     axis([-xu xu -xu xu -xu xu])
% end
if(~isempty(inpts))
    figure;
    DT = delaunayTriangulation(inpts);
    [K,v] = convexHull(DT);
    trisurf(K,DT.Points(:,1),DT.Points(:,2),DT.Points(:,3),...
       'FaceColor','cyan');
    axis([-xu xu -xu xu -xu xu])
end