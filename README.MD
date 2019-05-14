# Curi Dynamic Model

This repository contains the code to simulate the dynamic model of power grid with low inertia in a dq framework. The project was developed for the class EE290O "21st Century Power System Dynamics", a graduate seminar at UC Berkeley in Spring 2019. 

The code is written in Matlab and has the following features:

- Network model in dq framework
- 4 states synchronous generator model
- Constant impedance loads
- 3 states DC/AC converter using average dynamics

Equations can be found in device_equations folder. Run main_2bus_example to see the evolution of a 1 generator 1 load system without any controller and main_2bus_closed_loop to see how it behaves with a simplified AVR model and PI turbine controller.

The model is based on the following literature: 
 - [Control of low-inertia power grids: A model reduction approach](https://ieeexplore.ieee.org/document/8264521)
