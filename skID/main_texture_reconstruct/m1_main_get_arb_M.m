helicity=pi;%helicity_y: 0 (right neel),pi (left neel), pi/2 (bloch CW),-pi/2 (bloch (CCW)
domain=32;
domainWall=4;

sim_size_x=128;
sim_size_y=128;
sim_height=150;

im_skel=zeros(sim_size_y,sim_size_x);
im_skel(64,64)=1;


im_dist = bwdist(im_skel,'Euclidean');
[Gmag,Gdir] = imgradient(im_dist);

[imx,imy,imz,im_weight]=s3_recon_profile_2(0,helicity,domain,domainWall,im_dist,Gdir);
plot_rgb_vec(imx,imy,imz)

magx = double(imx);
magy = double(imy);
magz = double(imz);

ovf_filename='simpleSK_leftneel_640nm_80nm.ovf';
mag_mat=zeros([sim_size_x*sim_size_y*sim_height,3]);

act_mat=[reshape(rot90(fliplr(magx)),sim_size_x*sim_size_y,1),reshape(rot90(fliplr(magy)),sim_size_x*sim_size_y,1),reshape(rot90(fliplr(magz)),sim_size_x*sim_size_y,1)];
act_mat_l=sim_size_x*sim_size_y;
for coli=0:3:28
    sum(abs(act_mat)~=1)
    mag_mat((coli)*act_mat_l+1:((coli)*act_mat_l+act_mat_l),:)=act_mat;
    sum(abs(mag_mat((coli)*act_mat_l+1:((coli)*act_mat_l+act_mat_l),:))~=1)
end

%dlmwrite('mag_mat.txt',mag_mat,' ')

ovfhead=["#"    "OOMMF:"               "rectangular"               "mesh"    "v1.0"    ""...
    "#"    "Segment"              "count:"                    "1"       ""        "" ...
    "#"    "Begin:"               "Segment"                   ""        ""        "" ...
    "#"    "Begin:"               "Header"                    ""        ""        "" ...
    "#"    "Desc:"                "Time"                      "(s)"     ":"       "0"...
    "#"    "Title:"               "m"                         ""        ""        "" ...
    "#"    "meshtype:"            "rectangular"               ""        ""        "" ...
    "#"    "meshunit:"            "m"                         ""        ""        "" ...
    "#"    "xbase:"               "5e-09"                     ""        ""        "" ...
    "#"    "ybase:"               "5e-09"                     ""        ""        "" ...
    "#"    "zbase:"               "5e-10"                     ""        ""        "" ...
    "#"    "xstepsize:"           "4e-09"                     ""        ""        "" ...
    "#"    "ystepsize:"           "4e-09"                     ""        ""        "" ...
    "#"    "zstepsize:"           "1e-09"                     ""        ""        "" ...
    "#"    "xmin:"                "0"                         ""        ""        "" ...
    "#"    "ymin:"                "0"                         ""        ""        "" ...
    "#"    "zmin:"                "0"                         ""        ""        "" ...
    "#"    "xmax:"                "1.280e-06"                 ""        ""        "" ...
    "#"    "ymax:"                "1.280e-06"                 ""        ""        "" ...
    "#"    "zmax:"                "1.280e-07"                 ""        ""        "" ...
    "#"    "xnodes:"              "128"                       ""        ""        "" ...
    "#"    "ynodes:"              "128"                       ""        ""        "" ...
    "#"    "znodes:"              "150"                       ""        ""        "" ...
    "#"    "ValueRangeMinMag:"    "1e-08"                     ""        ""        "" ...
    "#"    "ValueRangeMaxMag:"    "1"                         ""        ""        "" ...
    "#"    "valueunit:"           ""                          ""        ""        "" ...
    "#"    "valuemultiplier:"     "1"                         ""        ""        "" ...
    "#"    "End:"                 "Header"                    ""        ""        "" ...
    "#"    "Begin:"               "Data"                      "Text"    ""        "" ];

ovftail=["#" "End:" "Data Text"...
"#" "End:" "Segment"];

fileID = fopen(ovf_filename,'w+');
fprintf(fileID,'%s %s %s %s %s%s\n',ovfhead);
fprintf(fileID,'%.5f %.5f %.5f\n',mag_mat');
fprintf(fileID,'%s %s %s \n%s %s %s\n',ovftail);
fclose('all')