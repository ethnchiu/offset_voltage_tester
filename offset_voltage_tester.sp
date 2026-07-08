*ng_script
echo "MC run " $&run

reset

let k = 0
while k < max_cycles
    let tsamp = k*tper + teval
    stop when time = $&tsamp
    let k = k + 1
end

let vind_dir = 1
let reset_state = 1
let count = 1

let vind_sar_val = vin_min + vind_range/2
let vind_val = vin_min

let vos_r = 0
let vos_f = 0
let vod_last = 0
let lsb = 0
let vos_candidate = 0
let search_done = 0

alter VVIND = $&vind_val

tran $&tstep $&tstop

set dt = $curplot
setplot $scratch

while search_done = 0
    
    let npts = length({$dt}.time)
    let vop = {$dt}.v(Voutp)[npts-1]
    let von = {$dt}.v(Voutn)[npts-1]
    let vod_last = vop - von
    
    if reset_state = 1
        let vind_val = vind_sar_val
        alter VVIND = $&vind_val
        let reset_state = 0
        resume
	setplot $scratch
        continue
    end
    
    if count < nbit
    
        let count = count + 1
    
        if vod_last > voutd_th
    
    	    let vind_sar_val = vind_sar_val - vind_range/(2^count)

    	    if vind_dir = 1
    	        let reset_state = 1
    	    end
    
        else
    
    	    let vind_sar_val = vind_sar_val + vind_range/(2^count)
    
    	    if vind_dir = 0
    	        let reset_state = 1
    	    end
    
        end
    
        if reset_state = 1
    	    if vind_dir = 1
    	        let vind_val = vin_min
    	    else
    	        let vind_val = vin_max
    	    end
        else
    	    let vind_val = vind_sar_val
        end
    
        alter VVIND = $&vind_val
        resume
	setplot $scratch
        continue
    
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
    	    let vind_sar_val = vin_min + vind_range/2
    	    let reset_state = 1
    	    let vind_val = vin_max
    
    	    alter VVIND = $&vind_val
    	    resume
	    setplot $scratch
    	    continue
    
        else
    
    	    let vos_f = vos_candidate
    	    let search_done = 1
    	    break
    
        end
    end
end

setplot $scratch
let vos_r_save = $&vos_r
let vos_f_save = $&vos_f

setscale run

if run = 0
    set wr_vecnames
    unset appendwrite
    wrdata vos_r.out vos_r_save
    wrdata vos_f.out vos_f_save
    unset wr_vecnames
    set appendwrite
else
    wrdata vos_r.out vos_r_save
    wrdata vos_f.out vos_f_save
end

destroy $dt 
setplot $scratch
