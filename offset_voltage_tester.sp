*ng_script
* ngspice control script for SRSAR comparator offset extraction
* Source this file from the xschem .control loop after defining:
* run, vin_min, vin_max, vind_range, nbit, voutd_th, out_pol,
* tstep, tmax, tper, teval, max_cycles, tstop, scratch.

echo "MC run " $&run

delete
reset
delete

save v(Voutp) v(Voutn) v(VIND_CTRL) v(BL) v(BLB) v(SE)

let k = 0
while k < max_cycles
    let tsamp = k*tper + teval
    stop when time = $&tsamp
    let k = k + 1
end

let vind_dir = 1
let reset_state = 1
let count = 1
let cycle = 0
let nreset = 0

let vind_mid = vin_min + vind_range/2
let vind_sar_val = vind_mid
let vind_val = vin_min

let vos_r = 0
let vos_f = 0
let vod_last = 0
let lsb = 0
let vos_candidate = 0
let search_done = 0
let next_step = 0

alter VVIND = $&vind_val
tran $&tstep $&tstop 0 $&tmax

set dt = $curplot
setplot $scratch

while search_done = 0

    let npts = length({$dt}.time)
    let vop = {$dt}.v(Voutp)[npts-1]
    let von = {$dt}.v(Voutn)[npts-1]

    * out_pol = +1 when v(Voutp)-v(Voutn) is the logic-high decision for
    * positive VIND. Set out_pol = -1 if your sense-amp pins are inverted.
    let vod_last = out_pol * (vop - von)

    if cycle >= max_cycles
        echo "ERROR: SRSAR exceeded max_cycles; check clock/evaluation timing or output polarity."
        let search_done = 1
        break
    end

    if reset_state = 1
        let vind_val = vind_sar_val
        let reset_state = 0
    else
        if count < nbit
            let count = count + 1
            let next_step = vind_range/(2^count)

            if vod_last > voutd_th
                let vind_sar_val = vind_sar_val - next_step
                if vind_dir = 1
                    let reset_state = 1
                end
            else
                let vind_sar_val = vind_sar_val + next_step
                if vind_dir = 0
                    let reset_state = 1
                end
            end

            if reset_state = 1
                let nreset = nreset + 1
                if vind_dir = 1
                    let vind_val = vin_min
                else
                    let vind_val = vin_max
                end
            else
                let vind_val = vind_sar_val
            end

        else
            let lsb = vind_range/(2^count)

            if vod_last > voutd_th
                let vos_candidate = vind_sar_val - lsb/2
            else
                let vos_candidate = vind_sar_val + lsb/2
            end

            if vind_dir = 1
                let vos_r = vos_candidate

                let vind_dir = 0
                let count = 1
                let vind_sar_val = vind_mid
                let reset_state = 1
                let vind_val = vin_max
                let nreset = nreset + 1
            else
                let vos_f = vos_candidate
                let search_done = 1
                break
            end
        end
    end

    alter VVIND = $&vind_val
    let cycle = cycle + 1
    resume
    setplot $scratch
end

setplot $scratch
let vos_hyst = vos_r - vos_f
let vos_r_save = $&vos_r
let vos_f_save = $&vos_f
let vos_hyst_save = $&vos_hyst
let cycles_save = $&cycle
let resets_save = $&nreset

setscale run

if run = 0
    set wr_vecnames
    unset appendwrite
    wrdata vos_r.out vos_r_save
    wrdata vos_f.out vos_f_save
    wrdata vos_mc.out vos_r_save vos_f_save vos_hyst_save cycles_save resets_save
    unset wr_vecnames
    set appendwrite
else
    wrdata vos_r.out vos_r_save
    wrdata vos_f.out vos_f_save
    wrdata vos_mc.out vos_r_save vos_f_save vos_hyst_save cycles_save resets_save
end

destroy $dt
delete
setplot $scratch
