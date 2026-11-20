# parts (v3)

One STEP file per part (units mm). All parts are saved in assembly coordinates — open them together and they line up.

| No | File | Part |
|---|---|---|
| 01 | `01_TopPlate.step` | Top plate |
| 02 | `02_BasePlate.step` | Base plate |
| 03 | `03_LowerArm_Left.step` | Lower arm, left (3 built-in pins) |
| 04 | `04_LowerArm_Right.step` | Lower arm, right (3 built-in pins) |
| 05 | `05_UpperArms_with_Pins_and_TopSlideRod.step` | Upper arm pair + center/lower pins + top slide rod |
| 06 | `06_UpperLinks_with_TopPivotRod.step` | Upper link pair + top pivot rod |
| 07 | `07_LowerLinks_with_BottomSlideRod.step` | Lower link pair + bottom slide rod |

Parts 05–07 have pins/rods fused in and cannot be assembled after printing separately — print the full set with the `.3mf` in [`../assembly/`](../assembly).
