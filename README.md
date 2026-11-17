# Scissor Lift Mechanism

> Term project — **Machinery** course
> Kinematic & force analysis, symbolic modeling, Simscape Multibody simulation, and a physical prototype of a scissor lift.

<p align="center">
  <img src="media/animation/scissor_lift.gif" width="480" alt="Scissor lift animation">
</p>

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Part I — Mechanism Basics](#part-i--mechanism-basics)
3. [Part II — Symbolic Analysis](#part-ii--symbolic-analysis)
4. [Part III — Simscape Multibody Simulation](#part-iii--simscape-multibody-simulation)
5. [Part IV — Built Prototype](#part-iv--built-prototype)
6. [How to Run](#how-to-run)
7. [Repository Structure](#repository-structure)
8. [Team](#team)

---

## Project Overview

| Item | Value |
|---|---|
| Mechanism type | Scissor lift (`n`-stage, X-linkage) |
| Function | Converts horizontal/actuator motion into vertical platform lift |
| Actuator | e.g. lead screw / linear actuator / hydraulic cylinder |
| Number of stages | `n = ?` |
| Link length `L` | `? mm` |
| Lift range | `h_min = ? mm` → `h_max = ? mm` |
| Rated load | `? N` |
| Material / Manufacturing | e.g. PLA 3D-printed, aluminum sheet |
| CAD | Fusion 360 / SolidWorks (`hardware/mechanical/`) |

---

## Part I — Mechanism Basics

### 1.1 Kinematic Diagram & Link Identification
<p align="center"><img src="media/diagrams/kinematic_diagram.png" width="520"></p>

| Link | Role | Length (mm) | Mass (g) |
|---|---|---|---|
| 1 | Ground / base frame | | |
| 2 | Scissor arm A | | |
| 3 | Scissor arm B | | |
| 4 | Platform | | |
| 5 | Slider (roller) | | |
| 6 | Actuator | | |

Joints: revolute (pins, center pivot) and prismatic (sliding rollers).

### 1.2 Degrees of Freedom (Grübler–Kutzbach)
```
DOF = 3(n − 1) − 2·j1 − j2
    = 3(? − 1) − 2(?) − 0 = 1
```
→ one input (actuator) fully determines platform height.

### 1.3 Lift Range & Working Space
- Arm angle range: `θ_min = ?°` → `θ_max = ?°`
- Platform height: `h(θ) = n · L · sin θ`
- Stroke of actuator / slider vs. height

<p align="center"><img src="media/plots/height_vs_angle.png" width="480"></p>

### 1.4 Mechanical Advantage & Critical Position
- Actuator force is highest at the **lowest position** (small θ) — design point.
- Mechanical advantage vs. θ:

<p align="center"><img src="media/plots/actuator_force_vs_height.png" width="480"></p>

---

## Part II — Symbolic Analysis
Files: [`simulation/symbolic/`](simulation/symbolic)

### 2.1 Position
`x = L cos θ`, `h = n L sin θ`

### 2.2 Velocity & Acceleration
`ḣ = n L cos θ · θ̇`  ·  `ḧ = n L (cos θ · θ̈ − sin θ · θ̇²)`

### 2.3 Force Analysis (virtual work / static equilibrium)
`F_act = W · (dh/dx) = ...`

### 2.4 Results Summary
| Quantity | Value | At θ = |
|---|---|---|
| Max actuator force | | |
| Max platform velocity | | |
| Max pin reaction | | |

---

## Part III — Simscape Multibody Simulation
Files: [`simulation/multibody/`](simulation/multibody)

1. Export CAD assembly → Simscape Multibody (`smimport`)
2. Add joint actuation / load on platform
3. Compare with symbolic results

<p align="center"><img src="media/plots/symbolic_vs_simscape.png" width="520"></p>

| Quantity | Symbolic | Simscape | Error (%) |
|---|---|---|---|
| Max height | | | |
| Max actuator force | | | |

---

## Part IV — Built Prototype
<p align="center"><img src="media/prototype/built_mechanism.jpg" width="480"></p>

- Materials, fasteners, actuator used
- Measured height range vs. theoretical
- Problems found & improvements

Bill of materials: [`hardware/bom.csv`](hardware/bom.csv)

---

## How to Run
**Requirements:** MATLAB R20xx · Symbolic Math Toolbox · Simscape · Simscape Multibody

```matlab
>> RUN_ME
```
`RUN_ME.m` runs the symbolic analysis, opens the Simscape model, and saves plots to `media/plots/`.

---

## Repository Structure
```
Scissor-Lift-Mechanism/
├── README.md
├── RUN_ME.m                    # One-click runner
├── docs/                       # Report (PDF) & presentation slides
├── hardware/
│   ├── mechanical/
│   │   ├── parts/              # .f3d / .sldprt / .step of each link
│   │   └── assembly/           # Full assembly (.f3z / .step)
│   ├── drawings/               # 2D engineering drawings (PDF)
│   └── bom.csv                 # Bill of materials
├── simulation/
│   ├── symbolic/               # Symbolic Math scripts (.m) + output tables
│   └── multibody/              # Simscape model (.slx) + import script
├── data/                       # Raw results (.csv) — simulation & measurements
└── media/
    ├── diagrams/               # Kinematic diagram, FBD
    ├── plots/                  # Graphs from analysis
    ├── animation/              # GIF / video of motion
    └── prototype/              # Photos of the built mechanism
```

---

## Team
| Name | Student ID | Responsibility |
|---|---|---|
| | | CAD & prototype |
| | | Symbolic analysis |
| | | Simscape simulation |

**Course:** Machinery · **Instructor:** — · **Semester:** —
