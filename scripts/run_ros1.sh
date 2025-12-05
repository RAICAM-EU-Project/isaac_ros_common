xhost +local:root

docker run -it --rm \
    -v /home/sasa/workspace/ros1:/workspaces/ros1 \
    --net=host \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -e ROS_MASTER_URI=http://localhost:11311 \
    -e ROS_IP=$(hostname -I | awk '{print $1}') \
    --gpus all \
    kanai1192/ros-noetic-yolo:latest \
    bash

