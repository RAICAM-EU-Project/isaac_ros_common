# IsaacSIM with ROS2 and Px4 based robots and Drones

## Installation

### Prerequisites for host PC
- Ubuntu 20.04/22.04 Operating System
- NVIDIA GPU (RTX 2070 or higher)
- NVIDIA GPU Driver (recommended version 525.85)

### ROS2 Hummble 
- Follow the latest instructions at the [official page](https://docs.ros.org/en/humble/Installation.html)

### tmux
```bash
sudo apt install tmux
cd && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

if you are new to tmux or not already familiar wit tmux
```bash
wget https://raw.githubusercontent.com/SasaKuruppuarachchi/SasaKuruppuarachchi/main/.tmux.conf -P ~/
```
go to .tmux.conf and edit line 12 "set -g prefix \`". This charactor "\`" depends on your keyboard layout.

### Nucleus Server
[Download](https://docs.omniverse.nvidia.com/install-guide/latest/workstation-install.html) and install Omniverse Launcher and install [Nucleus Server](https://docs.omniverse.nvidia.com/launcher/latest/workstation-launcher.html#collaboration-tab)
Go to library and install ISAACSIM.

### Enable ROS2 extension
Open IsaacSIM > Window > Extension > ROS2 bridge – enable (Autoload)

### Installing Qgroundcontrol (for PX4 based implementations)
Follow the latest instructions at the [official page](https://docs.qgroundcontrol.com/master/en/qgc-user-guide/getting_started/download_and_install.html)

### Installing docker
Follow the latest instructions at the [official docker page](https://docs.docker.com/engine/install/ubuntu/)

### Installing Portainer CE
Portainer CE is an open-source GUI for creating and managing docker containers. Install it following [these instructions](https://docs.portainer.io/start/install-ce/server/docker/linux)

### Installing Nvidia Docker
Install the Nvidia Container toolkit with [These Instructions](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

### General Installation

1. Set your workspace definitions and Clone the repo to your ros2 workspace
   ```bash
   echo "export WORKSPACES_DIR='/home/sasa/workspace'" >> ~/.bashrc
   echo "export ISAAC_ROS_DEV_DIR='/home/sasa/workspace/raicam-ros'" >> ~/.bashrc
   source ~/.bashrc
   cd $ISAAC_ROS_DEV_DIR && git clone https://github.com/RAICAM-EU-Project/isaac_ros_common.git -b your_branch
   ```

2. Get git submodules
   ```bash
   cd isaacsim_ros2_drone
   git submodule update --init --recursive
   cd px4
   git clone -b v1.14.0-rc2 https://github.com/PX4/PX4-Autopilot.git --recursive
   ```

3. Build a docker image with shell script.
   ```bash
   cd docker
   chmod +x build_docker_image.sh
   ./build_docker_image.sh
   ```

4. Launch a docker container
   ```bash
   ./launch_docker.sh
   ```
5. Launch Isaac Sim

   At this point, you are expected to have NVIDIA Isaac Sim fully installed and working. To make sure you have everything setup correctly, open a new terminal window (Ctrl+Alt+T), and test the following commands:

   Check that the simulator app can be launched

   - Run the simulator with the --help argument to see all available options
   ```bash
   ISAACSIM --help
   ```
   - Run the simulator. A new window should open
   ```bash
   ISAACSIM
   ```
   Check that you can launch the simulator from a python script (standalone mode)

   - Run the bundled python interpreter and see if it prints on the terminal "Hello World."
   ```bash
   ISAACSIM_PYTHON -c "print('Hello World.')"
   ```

   - Run the python interpreter and check if we can run a script that starts the simulator and adds cubes to the world
   ```bash
   ISAACSIM_PYTHON ${ISAACSIM_PATH}/standalone_examples/api/omni.isaac.core/add_cubes.py
   ```

   If you were unable to run the commands above successfuly, then something is incorrectly configured. Please do not proceed with this installation until you have everything setup correctly.

> [!NOTE]
> Secondary screens could freeze due to a bug in Nvidia driver. Disconnect and reconnect the HDMI
> If Isaac sim failed to launch please post the log in issues section

6. Attach to docker in new terminal to build and launch Px4_Auopilot
   ```bash
   docker exec -it isaac-sim-ros2 bash
   cd /root
   cd PX4-Autopilot
   make px4_sitl_default none
   ```
   if PX4 lauched properly you can exit out of it.

> [!NOTE]
> For the first time, launching Isaac Sim takes a very long time.
> Isaac Sim must be fully launched to spawn the robot.

### Enabling Pegasus Simulator in Isaacsim (First Operation)

1. Launch ``ISAACSIM`` application.

2. Open the Window->extensions on the top menubar inside Isaac Sim.
   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/extensions_menu_bar.png)

3. On the Extensions manager menu, we can enable or disable extensions. By pressing the settings button, we can 
add a path to the Pegasus-Simulator repository.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/extensions_widget.png)

4. The path inserted should be the path to the repository followed by ``/extensions``.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/ading_extension_path.png)


5. After adding the path to the extension, we can enable the Pegasus Simulator extension on the third-party tab.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/pegasus_inside_extensions_menu.png)


When enabling the extension for the first time, the python requirements should be install automatically for the build in 
``ISAACSIM_PYTHON`` , and after a few seconds, the Pegasus widget GUI should pop-up.

6. The Pegasus Simulator window should appear docked to the bottom-right section of the screen.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/pegasus_gui_example.png)

## Getting Started

1. Open a new terminal to launch QGC
   ```bash
   docker exec -it isaac-sim-ros2 bash
   su ubuntu
   cd
   ./QGroundControl.AppImage
   ```

2. If Isaacsim is not running alunch in a new terminal
   ```bash
   docker exec -it isaac-sim-ros2 bash
   ISAACSIM
   ```
3. Make sure the Pegasus Simulator Extension is enabled.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/pegasus_inside_extensions_menu.png)

4. On the Pegasus Simulator tab in the bottom-right corner, click on the ``Load Scene`` button.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/tutorials/load_scene.png)

5. Again, on the Pegasus Simulator tab, click on the ``Load Vehicle`` button.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/tutorials/load_vehicle.png)
6. Press the ``play`` button on the simulator's control bar on the left corner.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/tutorials/play.png)

7. On QGroundControl, an arrow representing the vehicle should pop-up. You can now perform a take-off, but pressing the
``take-off`` button on top-left corner of QGroundControl.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/tutorials/take_off.png)

8. On QGroundControl, left-click on a place on the map, press ``Go to location`` and slide at the bottom of the screen
to confirm the target waypoint for the drone to follow.

   ![alt text](https://github.com/PegasusSimulator/PegasusSimulator/blob/main/docs/_static/tutorials/go_to_location.png)


<!-- 7. Build ros2 source codes
   ```bash
   colcon build && source install/setup.bash
   ```

8. Launch the package

   7.1. For Mobile Robot
   - To launch simulator
   ```bash
   ros2 run isaac_ros2_scripts launcher
   ``` -->





