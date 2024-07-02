# Experimental Equipment for Orthostatic Exercise

The Experimental Equipment for Orthostatic Exercise project, developed by the Real World Informatics Lab at the University of Tokyo, is designed to aid individuals in standing up from a soft chair.

## Code

### Prerequisites

The project is implemented in MATLAB. Ensure you have MATLAB installed along with the "Data Acquisition Toolbox."

Additionally, two National Instruments libraries are required to interface with the National Instruments USB-6009 device. The executables, named "ni-daqmx_24.3_online.exe" and "ni-system-configuration_24.3_online.exe," are located at the root of the project.

All code files are located in the "codes" folder.

### Calibration

Due to the initial force applied to the sensors, you must run the "calibration.m" program. Ensure the switch is set to remote mode.

This program will reverse the motors to loosen the strap and collect 1000 filtered values from all four sensors. It calculates the mean of these values, providing an offset applied in subsequent programs via a JSON file.

### Using the Chair (still in development)

To operate the chair, run the "main.m" program. This program instructs the motors to apply a 40N force to the strap using a PID loop. It monitors real-time values to detect when the user intends to stand. By increasing the force to 100N, the strap tightens, making it easier for the user to stand by converting the chair from soft to firm.

### Debugging

To read values in real-time and control the chair manually, run the "debug.m" program. By default, it won't display any values. You need to pass arguments to view specific data.

- `debug` - No display.
- `debug('-raw')` - Displays raw sensor values.
- `debug('-filt')` - Displays filtered sensor values.
- `debug('-calib')` - Displays calibrated, filtered values.
- `debug('-f')` - Displays resultant forces from each motor.

You can combine arguments to view multiple data sets simultaneously, such as `debug('-filt', '-calib')` to display both filtered and calibrated values.

These arguments are also applicable to the "main.m" program.

### Storing Data

To analyze the values and create a program that detects variations, we need to store data on the force evolution when someone is standing up from the chair. This is why we developed the program "get_values.m," which collects sensor information and stores it in "data_stored.mat." Each time, it will prompt for a name to be associated with the new data.

## CAD

The "cad" folder contains the SolidWorks CAD files for the project.