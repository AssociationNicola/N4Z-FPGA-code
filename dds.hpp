/// DDS driver
///
/// (c) Koheron

#ifndef __DRIVERS_DDS_HPP__
#define __DRIVERS_DDS_HPP__

#include <context.hpp>

#include <array>
#include <limits>
#include <cmath>

class Dds
{
  public:
    Dds(Context& _ctx)
    : ctx(_ctx)
    , ctl(ctx.mm.get<mem::control>())
    , sts(ctx.mm.get<mem::status>())
    {

    }

    void set_dds_freq(double freq_hz) {


        if (std::isnan(freq_hz)) {
            ctx.log<ERROR>("FFT::set_dds_freq Frequency is NaN\n");
            return;
        }

        if (freq_hz > double(prm::adc_clk)/ 2) {
            freq_hz = double(prm::adc_clk) / 2;
        }

        if (freq_hz < 0.0) {
            freq_hz = 0.0;
        }

        double factor = (uint64_t(1) << 42) / double(prm::adc_clk);

        // Use left shift above of 42 rather than 48 as the adc_clk is actually that of the SCK which is 64 X fs!

        //ctl.write<reg::phase_incr0, uint64_t>(phase_incr);

        ctl.write_reg<uint64_t>(reg::phase_incr0, uint64_t(factor * freq_hz));
        dds_freq = freq_hz;

        ctx.log<INFO>("fs %lf ,  ref. frequency set to %lf \n", double(prm::adc_clk), freq_hz);
    }

  private:
    Context& ctx;
    Memory<mem::control>& ctl;
    Memory<mem::status>& sts;

    double dds_freq = 0.0;

};

#endif // __DRIVERS_DDS_HPP__
