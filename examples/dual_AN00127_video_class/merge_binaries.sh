echo "MERGING BINARIES TO SINGLE APPLICATION"

# Make new "merged" xe file
cp bin/t0/app_video_demo_t0.xe bin/app_video_demo.xe

# split the secondary tile binary
cd bin/t2
xobjdump --split app_video_demo_t2.xe
cd -

#replace both tiles of node 1 from other binary
# --replace <node,tile,file> | : Replace sector data from <file> in the executable <tilereference,file>
xobjdump bin/app_video_demo.xe -r 1,0,bin/t2/image_n1c0_2.elf
xobjdump bin/app_video_demo.xe -r 1,1,bin/t2/image_n1c1_2.elf