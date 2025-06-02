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
echo "alias runagipix='cd /workspaces/isaac_ros-dev/src/isaac_ros_common && ./run.sh'" >> ~/.bashrc
echo "alias runas2='cd /workspaces/aerostack2_ws/src/aerostack2/as2_aerial_platforms/project_agipix/ && ./launch_as2.bash -s -t -g'" >> ~/.bashrc
echo "alias stopas2='cd /workspaces/aerostack2_ws/src/project_agipix/ && ./stop.bash'" >> ~/.bashrc
echo "alias sorpx4='source /workspaces/aerostack2_ws/install/setup.bash'" >> ~/.bashrc
echo "export AEROSTACK2_WORKSPACE=/workspaces/aerostack2_ws" >> ~/.bashrc
echo "export PX4_FOLDER=/workspaces/aerostack2_ws/src/thirdparty/PX4-Autopilot" >> ~/.bashrc

echo "alias runagi='cd /workspaces/agipix_control/src/agipix_px4_autonomy/tmux/ && ./start.sh -s'" >> ~/.bashrc
echo "alias sorcon='source /workspaces/agipix_control/install/setup.bash'" >> ~/.bashrc
echo "alias bilcon='cd /workspaces/agipix_control && colcon build --packages-skip px4_msgs'" >> ~/.bashrc
echo "alias sorlidar='source /workspaces/lidar_ws/install/setup.bash'" >> ~/.bashrc
echo "export PATH="$HOME/.local/bin:$PATH"" >> ~/.bashrc

echo "Creating non-root container '${USERNAME}' for host user uid=${HOST_USER_UID}:gid=${HOST_USER_GID}"

if [ ! $(getent group ${HOST_USER_GID}) ]; then
  groupadd --gid ${HOST_USER_GID} ${USERNAME} &>/dev/null
else
  CONFLICTING_GROUP_NAME=`getent group ${HOST_USER_GID} | cut -d: -f1`
  groupmod -o --gid ${HOST_USER_GID} -n ${USERNAME} ${CONFLICTING_GROUP_NAME}
fi

if [ ! $(getent passwd ${HOST_USER_UID}) ]; then
  useradd --no-log-init --uid ${HOST_USER_UID} --gid ${HOST_USER_GID} -m ${USERNAME} &>/dev/null
else
  CONFLICTING_USER_NAME=`getent passwd ${HOST_USER_UID} | cut -d: -f1`
  usermod -l ${USERNAME} -u ${HOST_USER_UID} -m -d /home/${USERNAME} ${CONFLICTING_USER_NAME} &>/dev/null
  mkdir -p /home/${USERNAME}
  # Wipe files that may create issues for users with large uid numbers.
  rm -f /var/log/lastlog /var/log/faillog
fi

# Update 'admin' user
chown ${USERNAME}:${USERNAME} /home/${USERNAME}
echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME}
chmod 0440 /etc/sudoers.d/${USERNAME}
adduser ${USERNAME} video >/dev/null
adduser ${USERNAME} plugdev >/dev/null
adduser ${USERNAME} sudo  >/dev/null

# If jtop present, give the user access
if [ -S /run/jtop.sock ]; then
  JETSON_STATS_GID="$(stat -c %g /run/jtop.sock)"
  addgroup --gid ${JETSON_STATS_GID} jtop >/dev/null
  adduser ${USERNAME} jtop >/dev/null
fi

# Run all entrypoint additions
shopt -s nullglob
for addition in /usr/local/bin/scripts/entrypoint_additions/*.sh; do
  if [[ "${addition}" =~ ".user." ]]; then
    echo "Running entryrypoint extension: ${addition} as user ${USERNAME}"
    gosu ${USERNAME} ${addition}
  else
    echo "Sourcing entryrypoint extension: ${addition}"
    source ${addition}
  fi
done
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
cd /workspaces/agipix_control
#rosdep fix-permissions
#rosdep install -y -r -q --from-paths src --ignore-src

# Restart udev daemon
service udev restart

exec gosu ${USERNAME} "$@"
