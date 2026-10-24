# Turbine second law

A Matlab model of an adiabatic turbine, built to help me understand why the thermodynamics 2nd law still matters when the 1st law balances

## Why?

In Thermo I, I could never build a solid physical intuition for the 2nd law beyond just plugging nums into formulas. I knew energy in and out was conserved like a strict scalar ledger, but I couldn't visualize why a process was forbidden from just running in reverse. When I modeled this turbine, the 1st law residual was zero at every efficiency, so we can infer all the energy was accounted for. But entropy generation says something was still "lost." If the energy is all still in the system( hot exhaust), what exactly does "lost" mean?

## The Model

Air enters at 926.8 C and 1000 kPa and expands to 100 kPa at 1 kg/s mass flow rate. 
Ideal gas, constant specific heats, surroundings is at 25 C

I changed the isentropic efficiency and compute, for each value:

- exit temperature and shaft power from the 1st law
- entropy generation from the ideal gas entropy change
- the work potential lost, given by surr temp. times entropy gen
