## SRSAR Measurement for Sense Amplifier Offset Voltage

This xschem project implements an ngspice-compatible offset voltage tester for comparators. The offset voltage tester utilizes a smart resettable successive approximation register (SRSAR) algorithm [1] to obtain a comparator's rising and falling offset voltage. The target application is for use with the IIC-OSIC-TOOLS Docker image [2] and its accompanying open-source PDKs and tools.

[1] H. Omran, “Fast and accurate technique for comparator offset voltage simulation,” Microelectronics Journal, vol. 89, pp. 91–97, Jul. 2019, doi: [https://doi.org/10.1016/j.mejo.2019.05.004](https://doi.org/10.1016/j.mejo.2019.05.004).
[2] Institute for Integrated Circuits and Quantum Computing at the Johannes Kepler University Linz (IIC-JKU). "IIC-OSIC-TOOLS." GitHub. [https://github.com/iic-jku/IIC-OSIC-TOOLS](https://github.com/iic-jku/IIC-OSIC-TOOLS) (accessed May 6, 2026).
