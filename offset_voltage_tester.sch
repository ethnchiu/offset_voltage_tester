v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {simulator_commands.sym} 240 -50 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=true 
value="
.lib cornerMOSlv.lib mos_tt_mismatch

.param mm_ok=1
.param mc_ok=1
.param temp=27

.param VDD=1.2
.param VCM=1.175
.param VIND_INIT=0

.param TPER=2n
.param TSE_DLY=0.35n
.param TSE_W=0.75n
.param TR=50p
.param TF=50p
.param TEVAL=1.00n

VDD_S VDD 0 \{VDD\}

* SE Pulse:
* 0V -> VDD @ TSE_DLY
* Stays high for TSE_W
* Repeats every TPER
VSE SE 0 PULSE(0 \{VDD\} \{TSE_DLY\} \{TR\} \{TF\} \{TSE_W\} \{TPER\})

VVIND VIND_CTRL 0 \{VIND_INIT\}

B_BLDRV BLDRV 0 V = \{VCM + v(VIND_CTRL) / 2\}
B_BLBDRV BLBDRV 0 V = \{VCM - v(VIND_CTRL) / 2\}

RBL BLDRV BL 50
RBLB BLBDRV BLB 50

.control

set noaskquit
set numdgt=10
set wr_singlescale
set wr_vecnames

let mc_runs = 500

let vin_min = -0.05
let vin_max = 0.05
let vind_range = vin_max - vin_min
let nbit = 10
let voutd_th = 0
let out_pol = 1

let tstep = 10p
let tper = 2n
let teval = 1.00n
let tmax = 10p

let max_cycles = 4 * nbit + 4
let tstop = max_cycles * tper

setplot new
set scratch = $curplot

let run = 0
dowhile run < mc_runs
    source /foss/designs/offset_voltage_tester/offset_voltage_tester.sp
    
    let run = run + 1
end

rusage time

.endc
"}
C {lab_wire.sym} -120 140 0 1 {name=p9 sig_type=std_logic lab=BL}
C {lab_wire.sym} -40 140 0 1 {name=p10 sig_type=std_logic lab=BLB}
C {/foss/designs/sram_sense_amp/cells/blocks/sense_amp/schematic/sense-amp.sym} 0 0 0 0 {name=x1}
C {lab_wire.sym} 70 -80 1 0 {name=p11 sig_type=std_logic lab=BLB}
C {lab_wire.sym} -150 0 0 0 {name=p12 sig_type=std_logic lab=SE}
C {lab_wire.sym} 0 -80 1 0 {name=p13 sig_type=std_logic lab=VDD}
C {lab_wire.sym} -70 -80 1 0 {name=p14 sig_type=std_logic lab=BL}
C {gnd.sym} 0 80 0 0 {name=l8 lab=0}
C {lab_wire.sym} 150 30 0 1 {name=p15 sig_type=std_logic lab=Voutn}
C {lab_wire.sym} 150 -30 0 1 {name=p16 sig_type=std_logic lab=Voutp}
C {lab_wire.sym} 40 140 0 1 {name=p1 sig_type=std_logic lab=Voutp}
C {lab_wire.sym} 120 140 0 1 {name=p2 sig_type=std_logic lab=Voutn}
C {parax_cap.sym} -120 150 0 0 {name=C1 gnd=0 value=50f m=1}
C {parax_cap.sym} -40 150 0 0 {name=C2 gnd=0 value=50f m=1}
C {parax_cap.sym} 40 150 0 0 {name=C3 gnd=0 value=10f m=1}
C {parax_cap.sym} 120 150 0 0 {name=C4 gnd=0 value=10f m=1}
