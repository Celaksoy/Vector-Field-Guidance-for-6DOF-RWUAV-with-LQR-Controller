# Vector Field Guidance for 6DOF RWUAV with LQR Controller

## Project Description

This project presents the modeling, simulation, and control of a 6-DOF Rotary Wing Unmanned Aerial Vehicle (RWUAV) using MATLAB and Simulink.

A custom RWUAV model based on MATLAB’s helicopter dynamics framework is developed and enhanced with:

* Trim computation
* System linearization
* LQR controller design
* Vector Field Guidance (VFG) based autopilot

The objective is to achieve stable flight and accurate trajectory tracking under different operating conditions.

## Technologies Used

* MATLAB
* Simulink
* Control System Toolbox

## Methodology

The following steps are implemented in the project:

1. **Nonlinear Modeling**
   A 6-DOF RWUAV model is constructed based on helicopter dynamics.

2. **Trim Analysis**
   Steady-state operating points are computed for the nonlinear system.

3. **Linearization**
   The nonlinear model is linearized around trim conditions.

4. **LQR Controller Design**
   An optimal state-feedback controller is designed for stability and performance.

5. **Vector Field Guidance (VFG)**
   A guidance algorithm is integrated to enable trajectory/path following.

## Project Structure

* "heli_model.slx" → Main nonlinear RWUAV simulation model
* "trim_model.slx" → Trim computation model
* "Trim_Lin_Lqr.m" → Trim calculation, linearization, and LQR controller design
* "HelicopterParameterEstimation.mapp" → Design parameter calculation

---

## How to Run

1. Open MATLAB
2. Run "Trim_Lin_Lqr.m"
3. The parameter interface will open
4. Click the "Calculate" button
5. Close the interface after computation

## Results

* The LQR controller stabilizes the RWUAV around the trim condition
* The Vector Field Guidance algorithm enables smooth and accurate trajectory tracking
* The integrated system demonstrates robust performance under nominal conditions

## Author

* Celal AKSOY
