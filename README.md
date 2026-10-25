# Second law analysis of an adiabatic air turbine

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



## Results

### T-s diagram at 60%

<img src="ts_diagram.jpg" width="480" alt="T-s diagram at 60% efficiency">

Vertical line is the ideal turbine (no entropy change). The dashed line
is my real turbine, which ends at 853 K instead of 621 K. The 232 kW of
missing shaft work is still in the air, and it splits into two parts: the red
area (T0 * sgen, about 95 kW) can't be recovered or turned into work, and the blue area
(about 138 kW) could still be recovered and used in principle.

### Moving Past 100% efficiency
<img src="Forbidden zone.png" width="480" alt="Forbidden zone">

Above 100% the 1st law residual is still zero, so the energy balance still accepts
it. But entropy gen goes negative (abt -0.21 kJ/kg-K at 120%), so the
2nd law rejects it. 

### Cost of being away from the wall
<img src="Work split.png" width="480" alt="Lost vs recoverable work as the turbine approaches the ideal">

This is my favorite plot. The whole height of the colored area is the
missing work, the work the real turbine gives up or loses compared to the
ideal one. It stays in the air as extra exhaust heat, so the 1st law is
fine with it. The 2nd law splits it in two. The red part (t0 * s_gen) is the
work potential lost to entropy generation, and the blue part could still be
used in principle.

At 50% efficiency about 290 kW is missing, and about 114 kW of that is lost.
At 60% it is 232 kW, with 95 kW lost. As the efficiency goes up, the real
turbine gets closer to the wall, and both colors shrink together until they reach zero at 100%.
At the wall there is no entropy generation, so nothing is lost, and the
real turbine is the ideal one, so there is no extra exhaust heat to
recover either.

Both colors shrink as efficiency goes up, but the red part of the missing work grows a little (about 39% at 50%, to about 48% near 100%), because the leftover exhaust heat is at a lower temperature and so is less usable


> **A note on "the wall":** this is my own way of thinking about the 2nd law, not a
> textbook term. In Thermo I, I could do the 2nd law math but I couldn't
> picture what it was actually doing. I started thinking of it as a wall:
> the 1st law tells you how much energy in and out, but the 2nd law is what
> decides which side of the wall you're on. For example an ideal turbine sits exactly
> on it. Every real turbine sits to the left of it. Nothing can cross to
> the right. The forbidden zone (2nd plot) plot is my way of visualizing it.




## Limitations

- **Efficiency is not predicted.** The model takes isentropic
  efficiency as input. It shows the 2nd law given an efficiency,
  not how to compute one from blade design or losses.

- **Adiabatic assumption.** No heat transfer across the turbine boundary.
  This means all entropy generation comes from internal irreversibilities,
  and sgen equals the entropy change of the air directly.

- **Constant cp, constant k, ideal gas.** Real air properties ofc vary with
  temperature, so absolute numbers shift by some margin. Bur the qualitative
  split between lost and recoverable work is unchanged.

- **The 1st law residual is zero by construction in code.** T2 is set by the
  efficiency definition, so the residual check confirms internal
  consistency of the code, not a physical result. The 2nd law is what
  rules out impossible efficiencies.

- **My own visual framing.** The "wall," the T-s shading, the forbidden
  zone plot and the work split plot are my way of drawing this, not standard textbook figures. The underlying quantities (T0 x s_gen, lost work
  potential) are standard however.
