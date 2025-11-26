#!/bin/bash
#
# Copyright (c) 2021, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
wget https://raw.githubusercontent.com/SasaKuruppuarachchi/SasaKuruppuarachchi/main/.tmux.conf -P ~/

# Append custom bashrc snippet (idempotent)
BASHRC_SNIPPET_SRC="/workspaces/isaac_ros-dev/src/isaac_ros_common/scripts/bashrc"
if ! grep -q "isaac_ros_common container user shell customizations" /home/admin/.bashrc 2>/dev/null; then
  if [ -f "$BASHRC_SNIPPET_SRC" ]; then
    cat "$BASHRC_SNIPPET_SRC" >> /home/admin/.bashrc
  else
    echo "WARNING: bashrc snippet not found at $BASHRC_SNIPPET_SRC" >&2
  fi
fi

#add i2c dev permissions
sudo chown :i2c /dev/i2c-1 && sudo chmod g+rw /dev/i2c-1
# Build ROS dependency
echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
source /opt/ros/${ROS_DISTRO}/setup.bash

#tentative
sudo apt-get update
rosdep update
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# python get-pip.py
cd /workspaces/dds/Micro-XRCE-DDS-Agent/build && sudo make install && sudo ldconfig /usr/local/lib/
cd /workspaces/lidar_ws/src/Livox-SDK2/build && sudo make install && sudo ldconfig /usr/local/lib/
cd /workspaces/isaac_ros-dev

#rosdep fix-permissions
#rosdep install -y -r -q --from-paths src --ignore-src

cd /opt/depthgoals
pip install .
source /opt/depthgoals/src/depthgoals/deployment/src/install/setup.bash

# Restart udev daemon
sudo service udev restart

$@
